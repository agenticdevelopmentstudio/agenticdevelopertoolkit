"use client"
import { useEffect, type RefObject } from 'react'

/** Whether `el` is a scroller with room left to move along `axis` in `sign`'s direction
 *  (+1 towards the end, -1 towards the start). */
function canScroll(el: HTMLElement, axis: 'x' | 'y', sign: number): boolean {
  const cs = getComputedStyle(el)
  const overflow = axis === 'y' ? cs.overflowY : cs.overflowX
  if (overflow !== 'auto' && overflow !== 'scroll') return false
  const pos = axis === 'y' ? el.scrollTop : el.scrollLeft
  const max = axis === 'y' ? el.scrollHeight - el.clientHeight : el.scrollWidth - el.clientWidth
  if (max <= 1) return false
  return sign > 0 ? pos < max - 1 : pos > 0
}

/** Whether a scroll gesture from `target` would move something inside `allow` — a
 *  scroller between the two (both inclusive) with room left in that direction. */
function scrollsInside(
  target: EventTarget | null,
  allow: HTMLElement | null | undefined,
  axis: 'x' | 'y',
  sign: number,
): boolean {
  if (!allow || !(target instanceof Node) || !allow.contains(target)) return false
  for (let el: Node | null = target; el; el = el.parentNode) {
    if (el instanceof HTMLElement && canScroll(el, axis, sign)) return true
    if (el === allow) break
  }
  return false
}

/**
 * While `active`, nothing on the page scrolls except the contents of `allowRef` —
 * for an overlay (a chat, a sheet) whose own contents should be the only thing
 * that moves.
 *
 * Two parts, because a page scrolls two ways:
 *
 * - THE GESTURE. A touch drag or wheel that would not move a scroller inside
 *   `allowRef` is cancelled. That covers every scroller the page has, not just the
 *   document — an app shell that scrolls an inner pane is untouched by anything
 *   done to `<body>` — and it covers iOS Safari panning the whole visual viewport
 *   while the soft keyboard is up. A drag that reaches the end of the overlay's
 *   own scroller stops there instead of chaining out into the page. Two-finger
 *   touches are let through, so pinch-zoom still works.
 * - THE DOCUMENT. iOS scrolls the document itself to bring a focused input above
 *   the keyboard, with no gesture to cancel. `<body>` is pinned with
 *   `position: fixed` at its current offset, which leaves nothing to scroll and
 *   keeps the page looking unmoved. On release the prior inline styles come back
 *   and the scroll position is restored, instantly.
 */
export function usePageScrollLock(
  active: boolean,
  allowRef?: RefObject<HTMLElement | null>,
): void {
  useEffect(() => {
    if (!active || typeof window === 'undefined') return
    const html = document.documentElement.style
    const body = document.body.style
    const y = window.scrollY
    const prior = {
      overflow: html.overflow,
      position: body.position,
      top: body.top,
      left: body.left,
      right: body.right,
      width: body.width,
    }
    html.overflow = 'hidden'
    body.position = 'fixed'
    body.top = `${-y}px`
    body.left = '0'
    body.right = '0'
    body.width = '100%'

    let last: { x: number; y: number } | null = null
    const onTouchStart = (e: TouchEvent): void => {
      const t = e.touches[0]
      last = t ? { x: t.clientX, y: t.clientY } : null
    }
    const onTouchMove = (e: TouchEvent): void => {
      const t = e.touches[0]
      if (e.touches.length > 1 || !t || !last) return
      // The finger's travel, inverted: dragging up scrolls towards the end.
      const dx = last.x - t.clientX
      const dy = last.y - t.clientY
      last = { x: t.clientX, y: t.clientY }
      const axis = Math.abs(dx) > Math.abs(dy) ? 'x' : 'y'
      const d = axis === 'x' ? dx : dy
      if (d === 0) return
      if (!scrollsInside(e.target, allowRef?.current, axis, Math.sign(d))) e.preventDefault()
    }
    const onWheel = (e: WheelEvent): void => {
      if (e.ctrlKey) return // a trackpad pinch: zoom, not scroll
      const axis = Math.abs(e.deltaX) > Math.abs(e.deltaY) ? 'x' : 'y'
      const d = axis === 'x' ? e.deltaX : e.deltaY
      if (d === 0) return
      if (!scrollsInside(e.target, allowRef?.current, axis, Math.sign(d))) e.preventDefault()
    }
    const opts = { capture: true, passive: false } as const
    document.addEventListener('touchstart', onTouchStart, opts)
    document.addEventListener('touchmove', onTouchMove, opts)
    document.addEventListener('wheel', onWheel, opts)

    return () => {
      document.removeEventListener('touchstart', onTouchStart, opts)
      document.removeEventListener('touchmove', onTouchMove, opts)
      document.removeEventListener('wheel', onWheel, opts)
      html.overflow = prior.overflow
      body.position = prior.position
      body.top = prior.top
      body.left = prior.left
      body.right = prior.right
      body.width = prior.width
      window.scrollTo({ top: y, behavior: 'instant' })
    }
  }, [active, allowRef])
}
