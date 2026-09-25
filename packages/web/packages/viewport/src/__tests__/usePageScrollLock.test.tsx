import { describe, it, expect, vi, afterEach, beforeEach } from 'vitest'
import { createRef } from 'react'
import { renderHook } from '@testing-library/react'
import { usePageScrollLock } from '../usePageScrollLock'

beforeEach(() => {
  // jsdom has no scrollTo; the release calls it.
  vi.spyOn(window, 'scrollTo').mockImplementation(() => {})
})

afterEach(() => {
  document.documentElement.removeAttribute('style')
  document.body.removeAttribute('style')
  vi.restoreAllMocks()
})

describe('usePageScrollLock', () => {
  it('leaves the page alone while inactive', () => {
    renderHook(() => usePageScrollLock(false))
    expect(document.documentElement.style.overflow).toBe('')
    expect(document.body.style.position).toBe('')
  })

  it('pins the body at the current scroll offset while active', () => {
    vi.spyOn(window, 'scrollY', 'get').mockReturnValue(240)
    renderHook(() => usePageScrollLock(true))
    expect(document.documentElement.style.overflow).toBe('hidden')
    expect(document.body.style.position).toBe('fixed')
    expect(document.body.style.top).toBe('-240px')
    expect(document.body.style.width).toBe('100%')
  })

  it('restores the prior styles and scroll position on release', () => {
    vi.spyOn(window, 'scrollY', 'get').mockReturnValue(240)
    const scrollTo = vi.spyOn(window, 'scrollTo').mockImplementation(() => {})
    document.body.style.position = 'relative'
    const { rerender } = renderHook(({ on }: { on: boolean }) => usePageScrollLock(on), {
      initialProps: { on: true },
    })
    rerender({ on: false })
    expect(document.documentElement.style.overflow).toBe('')
    expect(document.body.style.position).toBe('relative')
    expect(document.body.style.top).toBe('')
    expect(scrollTo).toHaveBeenCalledWith({ top: 240, behavior: 'instant' })
  })

  describe('scroll gestures', () => {
    /** A scroller inside the allowed overlay, 100px tall over 300px of content, at `top`. */
    function scroller(top: number): { allow: HTMLDivElement; inner: HTMLDivElement } {
      const allow = document.createElement('div')
      const inner = document.createElement('div')
      inner.style.overflowY = 'auto'
      Object.defineProperty(inner, 'clientHeight', { value: 100 })
      Object.defineProperty(inner, 'scrollHeight', { value: 300 })
      inner.scrollTop = top
      allow.append(inner)
      document.body.append(allow)
      return { allow, inner }
    }

    function wheel(target: Element, deltaY: number): boolean {
      const e = new WheelEvent('wheel', { deltaY, bubbles: true, cancelable: true })
      target.dispatchEvent(e)
      return e.defaultPrevented
    }

    /** A one-finger drag on `target` from y=200 by `by` px; whether the move was cancelled. */
    function drag(target: Element, by: number): boolean {
      const touch = (y: number) => [{ clientX: 50, clientY: y }]
      const start = new Event('touchstart', { bubbles: true, cancelable: true })
      Object.defineProperty(start, 'touches', { value: touch(200) })
      target.dispatchEvent(start)
      const move = new Event('touchmove', { bubbles: true, cancelable: true })
      Object.defineProperty(move, 'touches', { value: touch(200 + by) })
      target.dispatchEvent(move)
      return move.defaultPrevented
    }

    it('cancels a wheel over the page outside the overlay', () => {
      const { allow } = scroller(0)
      const ref = createRef<HTMLElement>()
      ;(ref as { current: HTMLElement }).current = allow
      const page = document.createElement('p')
      document.body.append(page)
      renderHook(() => usePageScrollLock(true, ref))
      expect(wheel(page, 40)).toBe(true)
    })

    it("lets the overlay's own scroller move while it has room, and stops it chaining out at the end", () => {
      const { allow, inner } = scroller(0)
      const ref = createRef<HTMLElement>()
      ;(ref as { current: HTMLElement }).current = allow
      renderHook(() => usePageScrollLock(true, ref))
      expect(wheel(inner, 40)).toBe(false) // room below
      expect(wheel(inner, -40)).toBe(true) // already at the top
      expect(drag(inner, -30)).toBe(false) // finger up: scrolls towards the end
      expect(drag(inner, 30)).toBe(true) // finger down at the top: would chain out
    })

    it('stops cancelling once released', () => {
      const page = document.createElement('p')
      document.body.append(page)
      const { rerender } = renderHook(({ on }: { on: boolean }) => usePageScrollLock(on), {
        initialProps: { on: true },
      })
      expect(wheel(page, 40)).toBe(true)
      rerender({ on: false })
      expect(wheel(page, 40)).toBe(false)
    })
  })
})
