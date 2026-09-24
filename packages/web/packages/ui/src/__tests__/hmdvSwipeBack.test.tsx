/**
 * HierarchicalMenuDetail's narrow stack and the page's swipe-back gesture.
 *
 * THE SWIPE IS THE BACK YOU CAN SEE. The page's flick-right gesture first OFFERS itself at the
 * element under the finger (`offerSwipeBack`, lib/swipe-back.ts) and falls back to
 * `history.back()` only when nothing claims it. That fallback is the wrong answer inside a stack
 * showing a Back: it skips the unsaved-work guard, it leaves the page outright when the host keeps
 * its selection in memory, and on a routed host it lands on whatever entry happens to be previous
 * rather than one pane up. So the stack claims the gesture whenever it shows a Back, and answers it
 * with exactly what that Back runs.
 *
 * This block is a fork of HierarchicalTopicDetail's frame, so it carries its own copy of the narrow
 * stack and needs its own pin: HTDV's (hierarchicalTopicDetail.test.tsx) cannot see this one. The
 * claim itself is shared (hooks/useSwipeBackClaim.ts, pinned in useSwipeBackClaim.test.tsx); what
 * this file pins is that THIS stack hands it the Back it shows, exactly while it shows one.
 */
import { act, render, screen, within } from '@testing-library/react'
import { describe, it, expect, vi } from 'vitest'
import { HierarchicalMenuDetail } from '../blocks/hierarchical-menu-detail'
import type { TopicLevel } from '../blocks/hierarchical-topic-detail'
import { offerSwipeBack } from '../lib/swipe-back'

// The block keys module-scoped surface state by the ROOT level's id and that state deliberately
// outlives a mount, so each render gets its own ids rather than inheriting a neighbour's.
let surfaceSeq = 0

const REGIONS = [
  { id: 'us', label: 'us-west-1' },
  { id: 'eu', label: 'eu-central-1' },
]
const TOPICS = [
  { id: 'apps', label: 'Applications' },
  { id: 'users', label: 'Users' },
]

const clears = () => ({ regions: vi.fn(), topics: vi.fn() })

/** Two levels, Regions then Topics, selected as far as `sel` says. */
function levelsFor(
  sel: { region?: string; topic?: string },
  onClear: ReturnType<typeof clears>,
): TopicLevel[] {
  const surface = `hmd-swipe-${++surfaceSeq}`
  return [
    {
      id: `${surface}-regions`,
      title: 'Regions',
      items: REGIONS,
      selectedId: sel.region ?? null,
      onSelect: () => {},
      onClear: onClear.regions,
    },
    {
      id: `${surface}-topics`,
      title: 'Topics',
      items: TOPICS,
      selectedId: sel.topic ?? null,
      onSelect: () => {},
      onClear: onClear.topics,
    },
  ]
}

const col = (i: number): HTMLElement => {
  const el = document.querySelector(`[data-htd-col="${i}"]`)
  if (!(el instanceof HTMLElement)) throw new Error(`no column ${i}`)
  return el
}

/** Offer the gesture at `el`, inside act: the answer may be a React update. */
const swipeBackFrom = (el: Element): boolean => {
  let answered = false
  act(() => {
    answered = offerSwipeBack(el)
  })
  return answered
}

describe('HierarchicalMenuDetail — narrow, swipe-back', () => {
  it('a swipe on the detail runs its Back and claims the gesture', () => {
    const onClear = clears()
    render(
      <HierarchicalMenuDetail layoutMode="narrow" levels={levelsFor({ region: 'us', topic: 'apps' }, onClear)}>
        <p>the detail</p>
      </HierarchicalMenuDetail>,
    )
    expect(swipeBackFrom(screen.getByText('the detail'))).toBe(true)
    expect(onClear.topics).toHaveBeenCalledTimes(1)
    expect(onClear.regions).not.toHaveBeenCalled()
  })

  it('a swipe on a list pane runs the Back that pane shows', () => {
    const onClear = clears()
    render(
      <HierarchicalMenuDetail layoutMode="narrow" levels={levelsFor({ region: 'us' }, onClear)}>
        <p>the detail</p>
      </HierarchicalMenuDetail>,
    )
    // Topics is the pane on top, and its Back clears the region it was opened from.
    expect(swipeBackFrom(within(col(1)).getByRole('button', { name: /Users/ }))).toBe(true)
    expect(onClear.regions).toHaveBeenCalledTimes(1)
  })

  it('leaves the gesture to the page on the root list, where no Back is showing', () => {
    const onClear = clears()
    render(
      <HierarchicalMenuDetail layoutMode="narrow" levels={levelsFor({}, onClear)}>
        <p>the detail</p>
      </HierarchicalMenuDetail>,
    )
    expect(swipeBackFrom(within(col(0)).getByRole('button', { name: /us-west-1/ }))).toBe(false)
    expect(onClear.regions).not.toHaveBeenCalled()
  })

  it('a stack nested in another stack’s detail answers first, and the outer one stands aside', () => {
    const outer = clears()
    const inner = clears()
    render(
      <HierarchicalMenuDetail layoutMode="narrow" levels={levelsFor({ region: 'us', topic: 'apps' }, outer)}>
        <HierarchicalMenuDetail layoutMode="narrow" levels={levelsFor({ region: 'eu', topic: 'users' }, inner)}>
          <p>inner detail</p>
        </HierarchicalMenuDetail>
      </HierarchicalMenuDetail>,
    )
    expect(swipeBackFrom(screen.getByText('inner detail'))).toBe(true)
    expect(inner.topics).toHaveBeenCalledTimes(1)
    expect(outer.topics).not.toHaveBeenCalled()
  })

  it('a nested stack showing no Back of its own leaves the gesture to the stack around it', () => {
    // The inner stack sits on its root list, so the only Back on screen is the outer detail's. A
    // listener that claimed the gesture without a Back to run would swallow that one.
    const outer = clears()
    const inner = clears()
    render(
      <HierarchicalMenuDetail layoutMode="narrow" levels={levelsFor({ region: 'us', topic: 'apps' }, outer)}>
        <HierarchicalMenuDetail layoutMode="narrow" levels={levelsFor({}, inner)}>
          <p>inner detail</p>
        </HierarchicalMenuDetail>
      </HierarchicalMenuDetail>,
    )
    // Document order puts the outer stack's root list first; the inner one is inside its detail.
    const innerRoot = [...document.querySelectorAll<HTMLElement>('[data-htd-col="0"]')].at(-1)!
    expect(swipeBackFrom(within(innerRoot).getByRole('button', { name: /us-west-1/ }))).toBe(true)
    expect(outer.topics).toHaveBeenCalledTimes(1)
    expect(inner.regions).not.toHaveBeenCalled()
  })
})
