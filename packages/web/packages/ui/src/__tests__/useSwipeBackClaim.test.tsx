/**
 * `useSwipeBackClaim` — how an in-page Back answers the page's swipe-Back gesture.
 *
 * The narrow stacks' own tests (hierarchicalTopicDetail.test.tsx, hmdvSwipeBack.test.tsx) pin that
 * each stack hands the hook the Back it SHOWS. What they cannot reach is the claim underneath it:
 * that the Back which runs is the one the last commit showed — never one from a render React threw
 * away, and already the new one before the browser paints — that the listener is added once, and
 * that it comes off with the surface. Those are asserted here, once, against a bare surface.
 */
/// <reference types="@testing-library/jest-dom/vitest" />
import { act, render, screen } from '@testing-library/react'
import {
  Suspense,
  startTransition,
  use,
  useLayoutEffect,
  useRef,
  type ReactNode,
} from 'react'
import { createRoot } from 'react-dom/client'
import { afterEach, describe, it, expect, vi } from 'vitest'
import { useSwipeBackClaim } from '../hooks/useSwipeBackClaim'
import { offerSwipeBack, SWIPE_BACK_EVENT } from '../lib/swipe-back'

/** A surface whose only job is to answer the gesture with `back`. */
function Surface({
  name,
  back,
  children,
}: {
  name: string
  back: (() => void) | null
  children?: ReactNode
}) {
  const rootRef = useRef<HTMLDivElement>(null)
  useSwipeBackClaim(rootRef, back)
  return (
    <div ref={rootRef} data-testid={name}>
      <span>{`${name} content`}</span>
      {children}
    </div>
  )
}

/** Suspends on `on` for as long as it is pending. */
function Waits({ on }: { on: Promise<void> }) {
  use(on)
  return null
}

/** Flick at `el` the way the page's gesture does; `true` when something claimed it. */
function swipeBackFrom(el: Element): boolean {
  let answered = false
  act(() => {
    answered = offerSwipeBack(el)
  })
  return answered
}

afterEach(() => {
  vi.restoreAllMocks()
})

describe('useSwipeBackClaim', () => {
  it('claims the offer and runs the Back it was given', () => {
    const back = vi.fn()
    render(<Surface name="stack" back={back} />)
    expect(swipeBackFrom(screen.getByText('stack content'))).toBe(true)
    expect(back).toHaveBeenCalledTimes(1)
  })

  it('declines while it shows no Back, so the page falls back to history', () => {
    render(<Surface name="stack" back={null} />)
    expect(swipeBackFrom(screen.getByText('stack content'))).toBe(false)
  })

  it('leaves an offer a surface nested inside it has already claimed', () => {
    // The finger was on the inner one. The outer one going back as well would pop two levels for
    // one flick.
    const outer = vi.fn()
    const inner = vi.fn()
    render(
      <Surface name="outer" back={outer}>
        <Surface name="inner" back={inner} />
      </Surface>,
    )
    expect(swipeBackFrom(screen.getByText('inner content'))).toBe(true)
    expect(inner).toHaveBeenCalledTimes(1)
    expect(outer).not.toHaveBeenCalled()
  })

  it('answers an offer the surface nested inside it declined', () => {
    const outer = vi.fn()
    render(
      <Surface name="outer" back={outer}>
        <Surface name="inner" back={null} />
      </Surface>,
    )
    expect(swipeBackFrom(screen.getByText('inner content'))).toBe(true)
    expect(outer).toHaveBeenCalledTimes(1)
  })

  it('runs the latest committed Back without subscribing again', () => {
    // A Back is a fresh closure every render; following it must not mean a new listener per render.
    const add = vi.spyOn(EventTarget.prototype, 'addEventListener')
    const first = vi.fn()
    const second = vi.fn()
    const { rerender } = render(<Surface name="stack" back={first} />)
    rerender(<Surface name="stack" back={second} />)
    expect(swipeBackFrom(screen.getByText('stack content'))).toBe(true)
    expect(second).toHaveBeenCalledTimes(1)
    expect(first).not.toHaveBeenCalled()

    rerender(<Surface name="stack" back={null} />)
    expect(swipeBackFrom(screen.getByText('stack content'))).toBe(false)
    expect(add.mock.calls.filter(([type]) => type === SWIPE_BACK_EVENT)).toHaveLength(1)
  })

  it('has the new Back in hand before the browser paints', () => {
    // Refreshed by a passive effect, the Back could lag a painted frame behind the screen: the new
    // Back showing, the old one running. So offer from the LAYOUT pass of the very commit that
    // changed it — from a later sibling, whose layout effect runs after the surface's own.
    const first = vi.fn()
    const second = vi.fn()
    function OfferInLayout() {
      useLayoutEffect(() => {
        offerSwipeBack(screen.getByText('stack content'))
      })
      return null
    }
    const { rerender } = render(
      <>
        <Surface name="stack" back={first} />
      </>,
    )
    rerender(
      <>
        <Surface name="stack" back={second} />
        <OfferInLayout />
      </>,
    )
    expect(second).toHaveBeenCalledTimes(1)
    expect(first).not.toHaveBeenCalled()
  })

  it('never runs a Back from a render React threw away', async () => {
    // A transition that suspends is rendered and then discarded: nothing commits, and the screen
    // keeps the Back it had. A Back written down during that render would outlive it — the same
    // way HTDV's revealed list once did (see `reveal` in blocks/hierarchical-topic-detail.tsx).
    const committed = vi.fn()
    const discarded = vi.fn()
    const pending = new Promise<void>(() => {})
    const tree = (back: () => void, wait: Promise<void> | null) => (
      <Suspense fallback={<p>loading</p>}>
        <Surface name="stack" back={back}>
          {wait && <Waits on={wait} />}
        </Surface>
      </Suspense>
    )
    const host = document.body.appendChild(document.createElement('div'))
    const root = createRoot(host)
    try {
      await act(async () => root.render(tree(committed, null)))
      await act(async () => {
        startTransition(() => root.render(tree(discarded, pending)))
      })
      // Still the committed screen, not the fallback: the transition is held, not shown.
      expect(screen.queryByText('loading')).toBeNull()

      expect(swipeBackFrom(screen.getByText('stack content'))).toBe(true)
      expect(committed).toHaveBeenCalledTimes(1)
      expect(discarded).not.toHaveBeenCalled()
    } finally {
      act(() => root.unmount())
      host.remove()
    }
  })

  it('stops answering once the surface unmounts', () => {
    const back = vi.fn()
    const { unmount } = render(<Surface name="stack" back={back} />)
    const surface = screen.getByTestId('stack')
    unmount()
    // A listener left on the detached root would still answer an offer dispatched at it.
    expect(swipeBackFrom(surface)).toBe(false)
    expect(back).not.toHaveBeenCalled()
  })
})
