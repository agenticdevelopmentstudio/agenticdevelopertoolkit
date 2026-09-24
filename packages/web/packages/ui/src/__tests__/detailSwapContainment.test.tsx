import { describe, it, expect, vi, beforeEach, afterEach } from "vitest"
import { render, screen } from "@testing-library/react"
import { StrictMode } from "react"

import { HierarchicalTopicDetail, type TopicLevel } from "../blocks/hierarchical-topic-detail"
import { DETAIL_PANE_ATTR } from "../lib/detail-pane"

/**
 * ONE TENANT'S DETAIL PANE CANNOT SURFACE IN ANOTHER'S STACK.
 *
 * The crossfade has to survive a REMOUNT: selecting a row is a route change, and a route change
 * destroys the subtree, so the outgoing pane is stashed — a `cloneNode(true)` of its rendered DOM
 * — in a module-scope map for the next mount to fade from. That map outlives React by design, and
 * that is exactly what makes it dangerous: keyed by the stack's root level id alone, "the same
 * surface" meant "the same widget", so switching workspace handed the next workspace's console
 * the previous one's detail pane, data and all. It was reported from a live hub, and this is the
 * regression test for it.
 *
 * The fix is in the key, because a key is a thing a mount cannot get wrong by accident: the
 * snapshot is filed under the OWNER (`surfaceScope`) and under the root list's actual rows, so a
 * stack may only adopt a pane belonging to the same rows of the same tenant. The window it may do
 * so in is short, and past that window the snapshot is dropped rather than merely refused.
 *
 * The first test is the control — it proves the stash mechanism is genuinely live here, so the
 * silence in the ones after it is containment rather than a harness that fades nothing.
 *
 * jsdom gates the clone path twice over (no layout, no WAAPI); `installCrossfadeHarness` lifts
 * both, exactly as in `detailPaneMarker.test.tsx`.
 */

/** A fade that never finishes, so the ghost stays put for the assertions. */
const pendingAnimation = () =>
  ({ cancel: () => {}, addEventListener: () => {} }) as unknown as Animation

function installCrossfadeHarness(): () => void {
  const sized = { configurable: true, get: () => 800 }
  Object.defineProperty(HTMLElement.prototype, "offsetWidth", sized)
  Object.defineProperty(HTMLElement.prototype, "offsetHeight", sized)
  const proto = HTMLElement.prototype as unknown as { animate?: unknown }
  proto.animate = pendingAnimation
  return () => {
    delete (HTMLElement.prototype as unknown as Record<string, unknown>).offsetWidth
    delete (HTMLElement.prototype as unknown as Record<string, unknown>).offsetHeight
    delete proto.animate
  }
}

let now = 0
const tick = (ms: number) => {
  now += ms
}

let uninstall: () => void
beforeEach(() => {
  uninstall = installCrossfadeHarness()
  now = 2_000_000
  vi.spyOn(Date, "now").mockImplementation(() => now)
})
afterEach(() => {
  uninstall()
  vi.restoreAllMocks()
})

/** The one thing both workspaces genuinely share: the console is the same feature in each. */
const ROOT_LEVEL_ID = "shipr-projects"

const level = (items: { id: string; label: string }[], selectedId: string | null): TopicLevel => ({
  id: ROOT_LEVEL_ID,
  title: "Projects",
  items,
  selectedId,
  onSelect: () => {},
  onClear: () => {},
})

const ACME = [
  { id: "acme-web", label: "acme/web" },
  { id: "acme-api", label: "acme/api" },
]
const OTHER = [{ id: "widgets-site", label: "widgets/site" }]

const ghostPanes = () => document.querySelectorAll(`[${DETAIL_PANE_ATTR}="ghost"]`)

/** One console: a workspace, the rows it lists, the row it has selected, and that row's pane. */
function Console({
  scope,
  items,
  selectedId,
  detail,
}: {
  scope: string
  items: { id: string; label: string }[]
  selectedId: string | null
  detail: string
}) {
  return (
    <HierarchicalTopicDetail levels={[level(items, selectedId)]} surfaceScope={scope}>
      <div>{detail}</div>
    </HierarchicalTopicDetail>
  )
}

describe("the detail swap's stashed pane", () => {
  it("IS adopted across a remount of the same list, which is what it is for", () => {
    const { unmount } = render(
      <Console scope="acme" items={ACME} selectedId="acme-web" detail="acme/web — deploy log" />,
    )
    tick(5_000) // past the settle debounce: what follows reads as a swap, not a mount cascade
    unmount() // the route change

    render(
      <Console scope="acme" items={ACME} selectedId="acme-api" detail="acme/api — deploy log" />,
    )
    expect(ghostPanes()).toHaveLength(1)
    // The same operator, in the same workspace, watching one pane dissolve into the next.
    expect(screen.getByText("acme/web — deploy log")).toBeTruthy()
  })

  it("is NOT adopted by another workspace's console — the leak this file is named for", () => {
    const { unmount } = render(
      <Console scope="acme" items={ACME} selectedId="acme-web" detail="acme/web — deploy log" />,
    )
    tick(5_000)
    unmount() // the workspace switch

    render(<Console scope="widgets" items={OTHER} selectedId={null} detail="Nothing filed here" />)
    expect(ghostPanes()).toHaveLength(0)
    expect(screen.queryByText("acme/web — deploy log")).toBeNull()
  })

  it("is NOT adopted by a stack listing different rows, even with no scope passed at all", () => {
    // A caller who never heard of `surfaceScope` still cannot leak between two different lists:
    // the rows themselves are in the key, so "the same surface" is a claim about content.
    const Unscoped = ({ items, detail }: { items: typeof ACME; detail: string }) => (
      <HierarchicalTopicDetail levels={[level(items, items[0]!.id)]}>
        <div>{detail}</div>
      </HierarchicalTopicDetail>
    )
    const { unmount } = render(<Unscoped items={ACME} detail="acme/web — deploy log" />)
    tick(5_000)
    unmount()

    render(<Unscoped items={OTHER} detail="widgets/site — deploy log" />)
    expect(ghostPanes()).toHaveLength(0)
    expect(screen.queryByText("acme/web — deploy log")).toBeNull()
  })

  it("is dropped once its adoption window has passed, rather than kept and refused", () => {
    const { unmount } = render(
      <Console scope="acme" items={ACME} selectedId="acme-web" detail="acme/web — deploy log" />,
    )
    tick(5_000)
    unmount()
    tick(60_000) // the operator went to lunch

    render(
      <Console scope="acme" items={ACME} selectedId="acme-api" detail="acme/api — deploy log" />,
    )
    expect(ghostPanes()).toHaveLength(0)
    expect(screen.queryByText("acme/web — deploy log")).toBeNull()
  })

  it("is not stranded when a fade is cancelled — StrictMode's mount → unmount → mount", () => {
    // The dev hub runs under StrictMode, which unmounts and remounts on the SAME DOM. The unmount
    // cancelled the fade the first mount had just started, a cancelled animation never fires the
    // "finish" that empties the overlay, and every settings topic was drawn over the one before
    // it at full opacity. The harness's fade never finishes either, so a ghost here can only mean
    // a cancel path that forgot to empty the overlay.
    const { unmount } = render(
      <Console scope="acme" items={ACME} selectedId="acme-web" detail="acme/web — deploy log" />,
    )
    tick(5_000)
    unmount()

    render(
      <StrictMode>
        <Console scope="acme" items={ACME} selectedId="acme-api" detail="acme/api — deploy log" />
      </StrictMode>,
    )
    expect(ghostPanes()).toHaveLength(0)
    expect(screen.queryByText("acme/web — deploy log")).toBeNull()
  })
})
