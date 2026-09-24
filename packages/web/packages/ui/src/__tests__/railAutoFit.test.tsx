/**
 * Every rail is as wide as ITS OWN rows.
 *
 * Each `TopicRail` measures its own rows and reports the answer up (`onFit`) — the 240px
 * default was a number nobody measured, and a rail full of `agenticdeveloperhub-deployment`
 * truncated every row while the rail of two-letter groups wasted half its width. The answers
 * were pooled for a while, every rail rendering at the maximum so that columns never moved
 * under the pointer; that traded the whole visible benefit away, because one wide sibling
 * pinned every short rail open and the pool was sticky besides (Mike). Auto-sizing that never
 * sizes anything DOWN is not auto-sizing, so each rail now keeps its own answer.
 *
 * WHAT THIS HAS TO FAKE. The measurement asks the layout engine for the list box's
 * `max-content` width, and jsdom has no layout engine — it reports every box at 0. So
 * `scrollWidth` is stubbed with the one thing a real engine would answer: the widest ROW,
 * which is what `max-content` means for a column of rows. Everything between that number and
 * the rendered column width is the code under test.
 */
import { render } from "@testing-library/react"
import { describe, it, expect, beforeEach, afterEach } from "vitest"

import { HierarchicalTopicDetail, type TopicLevel } from "../blocks/hierarchical-topic-detail"
import { MIN_FIT_RAIL, MAX_FIT_RAIL } from "../blocks/topic-detail"

/** Wide enough that a monospace-ish 10px/char model lands inside the clamp. */
const PX_PER_CHAR = 10

const GROUPS = [
  { id: "eu", label: "eu" },
  { id: "us", label: "us" },
]
const REPOS = [
  { id: "r1", label: "agenticdeveloperhub-deployment" }, // 30 chars → 300px
  { id: "r2", label: "shipr" },
]

function levels(): TopicLevel[] {
  const mk = (
    id: string,
    title: string,
    items: { id: string; label: string }[],
    selectedId: string | null,
  ): TopicLevel => ({
    id,
    title,
    items,
    selectedId,
    onSelect: () => {},
    onClear: () => {},
  })
  // The root carries a selection because a child list is only ON SCREEN once its parent has
  // one — an unselected level is the frontier, and there is nothing past the frontier.
  return [mk("fit-groups", "Projects", GROUPS, "eu"), mk("fit-repos", "Repositories", REPOS, null)]
}

/** `scrollWidth` = the widest row in this box, which is what `max-content` resolves to for a
 *  column of rows. Any box holding no rows keeps jsdom's 0 and so reports nothing. */
function installMeasurementHarness() {
  const real = Object.getOwnPropertyDescriptor(HTMLElement.prototype, "scrollWidth")
  Object.defineProperty(HTMLElement.prototype, "scrollWidth", {
    configurable: true,
    get(this: HTMLElement) {
      const rows = [...this.querySelectorAll("[data-htd-row]")]
      return rows.reduce((w, r) => Math.max(w, (r.textContent ?? "").length * PX_PER_CHAR), 0)
    },
  })
  return () => {
    if (real) Object.defineProperty(HTMLElement.prototype, "scrollWidth", real)
    else delete (HTMLElement.prototype as unknown as Record<string, unknown>).scrollWidth
  }
}

/** The HEADER's `max-content` is its title: answer the header's own text at the same rate the
 *  rows are measured, layered over the row harness (which answers 0 for a box with no rows). */
function stubHeaderWidth() {
  const rowsOnly = Object.getOwnPropertyDescriptor(HTMLElement.prototype, "scrollWidth")!
  Object.defineProperty(HTMLElement.prototype, "scrollWidth", {
    configurable: true,
    get(this: HTMLElement) {
      if (this.hasAttribute("data-htd-header")) return (this.textContent ?? "").length * PX_PER_CHAR
      return rowsOnly.get!.call(this)
    },
  })
  return () => Object.defineProperty(HTMLElement.prototype, "scrollWidth", rowsOnly)
}

/** Give the RAIL BOXES a rendered width, the way a browser does and jsdom never does.
 *
 *  A rail is `border-box` with a hairline right border, so `offsetWidth - clientWidth` is 1 —
 *  and that hairline is the only thing the measurement is entitled to add to its content. The
 *  point of stating it here is the gap between the box's current width and its content's: the
 *  formula under test must not read that gap as chrome. Every other element keeps jsdom's 0.
 */
function installBoxHarness(currentRailPx: number) {
  const realOffset = Object.getOwnPropertyDescriptor(HTMLElement.prototype, "offsetWidth")
  const realClient = Object.getOwnPropertyDescriptor(HTMLElement.prototype, "clientWidth")
  // The rail BOX is the `<aside>`; `data-htd-col` sits on the positioned wrapper that gives it
  // its width, so the aside's rendered width is that wrapper's.
  const isRail = (el: HTMLElement) => el.tagName === "ASIDE" && !!el.closest("[data-htd-col]")
  const railWidth = (el: HTMLElement) => {
    const box = el.closest("[data-htd-col]")
    const stated = box instanceof HTMLElement ? parseFloat(box.style.width) : NaN
    return Number.isFinite(stated) ? stated : currentRailPx
  }
  Object.defineProperty(HTMLElement.prototype, "offsetWidth", {
    configurable: true,
    get(this: HTMLElement) {
      return isRail(this) ? railWidth(this) : 0
    },
  })
  Object.defineProperty(HTMLElement.prototype, "clientWidth", {
    configurable: true,
    get(this: HTMLElement) {
      return isRail(this) ? railWidth(this) - RAIL_BORDER : 0
    },
  })
  return () => {
    for (const [name, real] of [
      ["offsetWidth", realOffset],
      ["clientWidth", realClient],
    ] as const) {
      if (real) Object.defineProperty(HTMLElement.prototype, name, real)
      else delete (HTMLElement.prototype as unknown as Record<string, unknown>)[name]
    }
  }
}

/** The rail's one hairline — its whole box, since a rail has no padding. */
const RAIL_BORDER = 1

const boxWidth = (i: number): string => {
  const el = document.querySelector(`[data-htd-col="${i}"]`)
  if (!(el instanceof HTMLElement)) throw new Error(`no column ${i}`)
  return el.style.width
}

describe("TopicRail auto-fit", () => {
  let restore: () => void
  beforeEach(() => {
    restore = installMeasurementHarness()
  })
  afterEach(() => restore())

  it("sizes each rail to its own rows, not to its widest sibling", () => {
    render(
      <HierarchicalTopicDetail levels={levels()}>
        <p>detail</p>
      </HierarchicalTopicDetail>,
    )
    // THE TWO RAILS COME OUT DIFFERENT WIDTHS, which is the whole point. 30 characters of
    // repository name is 300px and the repositories rail renders at it; the groups rail holds
    // two two-letter labels, measures 20px, and lands on the floor — not on its sibling's 300.
    // Both of those are what the rail's own rows asked for.
    expect(MIN_FIT_RAIL).toBeLessThan(30 * PX_PER_CHAR)
    expect(boxWidth(0)).toBe(`${MIN_FIT_RAIL}px`)
    expect(boxWidth(1)).toBe(`${30 * PX_PER_CHAR}px`)
  })

  it("gives back the slack when the wide rail's rows get short", () => {
    // The stickiness half of the same bug. The pool kept every answer forever, so a rail that
    // had once been wide — or had since unmounted entirely — held every other rail open for
    // the rest of the session. Re-rendering with short rows has to move the column back.
    const ls = levels()
    const { rerender } = render(
      <HierarchicalTopicDetail levels={ls}>
        <p>detail</p>
      </HierarchicalTopicDetail>,
    )
    expect(boxWidth(1)).toBe(`${30 * PX_PER_CHAR}px`)

    const short = [...ls]
    short[1] = { ...short[1]!, items: [{ id: "r2", label: "shipr" }] }
    rerender(
      <HierarchicalTopicDetail levels={short}>
        <p>detail</p>
      </HierarchicalTopicDetail>,
    )
    expect(boxWidth(1)).toBe(`${MIN_FIT_RAIL}px`)
  })

  it("scales the floor to the document's own root font", () => {
    // `MIN_FIT_RAIL` is 150 design px, written against the browser's 16px default. The adh
    // family sets `html` to 12px, where those 150 units are 200 design px — wide enough to
    // swallow every short rail on its own, which is how a two-row rail came out as wide as a
    // forty-row one even after the pooling went. The floor has to be read in the document's
    // units, so at a 12px root it lands at 112.5, not 150.
    document.documentElement.style.fontSize = "12px"
    try {
      render(
        <HierarchicalTopicDetail levels={levels()}>
          <p>detail</p>
        </HierarchicalTopicDetail>,
      )
      expect(boxWidth(0)).toBe(`${(MIN_FIT_RAIL * 12) / 16}px`)
      // And the rail whose rows exceed the floor is untouched by the root font: 300px of
      // measured content is 300px of content whatever `rem` happens to mean.
      expect(boxWidth(1)).toBe(`${30 * PX_PER_CHAR}px`)
    } finally {
      document.documentElement.style.fontSize = ""
    }
  })

  it("never lets one pathological row eat the detail pane", () => {
    const long = [{ id: "x", label: "x".repeat(400) }]
    const ls = levels()
    ls[1] = { ...ls[1]!, items: long }
    render(
      <HierarchicalTopicDetail levels={ls}>
        <p>detail</p>
      </HierarchicalTopicDetail>,
    )
    expect(boxWidth(1)).toBe(`${MAX_FIT_RAIL}px`)
  })

  it("reports what the CONTENT needs, not the width the rail already has", () => {
    // The regression. `chrome` used to be `aside.offsetWidth - list.offsetWidth`, measured
    // while the list was momentarily `max-content` and the aside was not — so it was the SLACK
    // between them, and `content + slack` is the aside's current width by definition. Every
    // rail handed back its own input, nothing ever moved off the 240px fallback, and a rail of
    // two two-letter groups rendered as wide as one holding a deployment slug.
    //
    // Stated as the arithmetic that separates the two: a 300px content in a 500px box is 301,
    // never 500.
    const restoreBoxes = installBoxHarness(500)
    try {
      render(
        <HierarchicalTopicDetail levels={levels()}>
          <p>detail</p>
        </HierarchicalTopicDetail>,
      )
      expect(boxWidth(1)).toBe(`${30 * PX_PER_CHAR + RAIL_BORDER}px`)
    } finally {
      restoreBoxes()
    }
  })

  it("is wide enough for its HEADER when the title outgrows the rows", () => {
    // A rail sized to its rows alone truncated its own title — a two-row list under a long
    // heading read "Repositor…" (Mike: "wide enough for their contents and their headers
    // both"). The header's max-content is its title, so the stub answers the header's text.
    const TITLE = "Repositories awaiting their deployment" // 38 chars → 380px
    const restoreHeader = stubHeaderWidth()
    try {
      const ls = levels()
      ls[1] = { ...ls[1]!, title: TITLE, items: [{ id: "r2", label: "shipr" }] }
      render(
        <HierarchicalTopicDetail levels={ls}>
          <p>detail</p>
        </HierarchicalTopicDetail>,
      )
      expect(boxWidth(1)).toBe(`${TITLE.length * PX_PER_CHAR}px`)
    } finally {
      restoreHeader()
    }
  })

  it("rounds a FRACTIONAL row width up, never down", () => {
    // `scrollWidth` is an integer rounded down from the text's real advance: a label 126.47px
    // wide got a 126px rail and ellipsized ("Consultant Regist…" in the hub's Hub rail). The
    // bounding rect keeps the fraction, and the rail rounds it UP to the pixel that holds it.
    const real = Element.prototype.getBoundingClientRect
    Element.prototype.getBoundingClientRect = function (this: Element) {
      const isList = this.tagName !== "ASIDE" && !this.hasAttribute("data-htd-col")
      const rows = isList ? [...this.querySelectorAll("[data-htd-row]")] : []
      if (!rows.length) return real.call(this)
      const width =
        rows.reduce((w, r) => Math.max(w, (r.textContent ?? "").length * PX_PER_CHAR), 0) + 0.4
      return { x: 0, y: 0, top: 0, left: 0, width, height: 0, right: width, bottom: 0, toJSON() {} }
    }
    try {
      render(
        <HierarchicalTopicDetail levels={levels()}>
          <p>detail</p>
        </HierarchicalTopicDetail>,
      )
      expect(boxWidth(1)).toBe(`${30 * PX_PER_CHAR + 1}px`)
    } finally {
      Element.prototype.getBoundingClientRect = real
    }
  })

  it("leaves a level that states its own width alone", () => {
    // The measurement is what a rail does when nobody has decided for it. A caller who HAS
    // decided — a fixed column of properties, a rail sized to sit beside something else —
    // is not overruled by its contents.
    const ls = levels()
    ls[1] = { ...ls[1]!, width: 320 }
    render(
      <HierarchicalTopicDetail levels={ls}>
        <p>detail</p>
      </HierarchicalTopicDetail>,
    )
    expect(boxWidth(1)).toBe("320px")
  })
})
