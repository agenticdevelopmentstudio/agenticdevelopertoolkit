"use client"

import { useEffect, useLayoutEffect, useRef, type RefObject } from "react"

import { SWIPE_BACK_EVENT } from "../lib/swipe-back"

/**
 * Answer the page's swipe-Back gesture with the in-page Back rooted at `rootRef` — the ANSWERING
 * half of the seam in lib/swipe-back.ts, whose `offerSwipeBack` is the asking half.
 *
 * `back` is what the surface's VISIBLE Back runs right now, or `null` while it shows none. `null`
 * is how a surface says "not mine": the offer bubbles on to a surface around this one, and past
 * the last of them to the page's own fallback (`history.back()`). Pass exactly the Back the screen
 * shows, never a cousin of it — one gesture, one visible Back.
 *
 * One hook, not a listener per surface: HTDV's and HMD's narrow stacks each grew the same fifteen
 * lines to answer this event, and two copies of one answer are how two stacks come to answer one
 * gesture differently. What those lines decided is the part worth sharing:
 *
 *  - **Subscribed once.** The listener goes on when the root mounts and comes off when it
 *    unmounts. A Back is usually a fresh closure every render; re-subscribing whenever it changed
 *    would churn a DOM listener per render for nothing.
 *  - **The Back that runs is the one the COMMIT showed.** `back` is kept in a ref a layout effect
 *    refreshes — never one written during render. React can render and then throw that render
 *    away (a transition that suspends, or that an urgent update interrupts), and a ref the
 *    discarded render wrote outlives it. HTDV's narrow stack learned this with its revealed list:
 *    it remembered the last selection it had seen in a ref written during render, a discarded
 *    render used the change up, and the render that committed left the list on top of the row
 *    just picked (see `reveal` in blocks/hierarchical-topic-detail.tsx). A LAYOUT effect rather
 *    than a passive one because it runs before the browser paints, so there is no frame in which
 *    the screen shows one Back while the gesture would run another.
 *  - **An offer already claimed is left alone.** Bubbling reaches the innermost answerer first —
 *    the surface the finger was on — so an outer one that finds `defaultPrevented` set must not
 *    ALSO go back: that would pop two levels for one flick.
 *
 * `rootRef` must hold the surface's own root for as long as the component is mounted: the
 * listener is bound to the element it held at mount.
 */
export function useSwipeBackClaim(
  rootRef: RefObject<HTMLElement | null>,
  back: (() => void) | null,
): void {
  const latest = useRef<(() => void) | null>(null)
  useLayoutEffect(() => {
    latest.current = back
  })
  useEffect(() => {
    const root = rootRef.current
    if (!root) return
    const answer = (event: Event) => {
      const run = latest.current
      if (!run || event.defaultPrevented) return
      event.preventDefault()
      run()
    }
    root.addEventListener(SWIPE_BACK_EVENT, answer)
    return () => root.removeEventListener(SWIPE_BACK_EVENT, answer)
  }, [rootRef])
}
