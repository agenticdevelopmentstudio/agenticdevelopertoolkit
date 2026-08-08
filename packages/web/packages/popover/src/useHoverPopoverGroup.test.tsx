import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import { act, renderHook } from '@testing-library/react'
import { useHoverPopoverGroup } from './useHoverPopoverGroup'

describe('useHoverPopoverGroup', () => {
  beforeEach(() => {
    vi.useFakeTimers()
  })

  afterEach(() => {
    vi.useRealTimers()
  })

  it('starts with nothing open', () => {
    const { result } = renderHook(() => useHoverPopoverGroup())
    expect(result.current.openKey).toBeNull()
    expect(result.current.itemProps('a').popoverProps.open).toBe(false)
  })

  it('opens the item whose trigger the pointer enters', () => {
    const { result } = renderHook(() => useHoverPopoverGroup())

    act(() => result.current.itemProps('a').triggerProps.onMouseEnter())

    expect(result.current.openKey).toBe('a')
    expect(result.current.itemProps('a').popoverProps.open).toBe(true)
    expect(result.current.itemProps('b').popoverProps.open).toBe(false)
  })

  it('keeps at most one open when the pointer moves between triggers', () => {
    const { result } = renderHook(() => useHoverPopoverGroup())

    act(() => result.current.itemProps('a').triggerProps.onMouseEnter())
    // Leaving one anchor and entering the next is what a pointer crossing a
    // row actually produces, in this order.
    act(() => {
      result.current.itemProps('a').anchorProps.onMouseLeave()
      result.current.itemProps('b').triggerProps.onMouseEnter()
    })

    expect(result.current.openKey).toBe('b')

    // The close that 'a' scheduled must not take 'b' down with it.
    act(() => void vi.advanceTimersByTime(1000))
    expect(result.current.openKey).toBe('b')
  })

  it('waits out the close delay before closing', () => {
    const { result } = renderHook(() => useHoverPopoverGroup({ closeDelay: 200 }))

    act(() => result.current.itemProps('a').triggerProps.onMouseEnter())
    act(() => result.current.itemProps('a').anchorProps.onMouseLeave())

    act(() => void vi.advanceTimersByTime(199))
    expect(result.current.openKey).toBe('a')

    act(() => void vi.advanceTimersByTime(1))
    expect(result.current.openKey).toBeNull()
  })

  it('cancels a pending close when the pointer reaches the panel', () => {
    const { result } = renderHook(() => useHoverPopoverGroup())

    act(() => result.current.itemProps('a').triggerProps.onMouseEnter())
    act(() => result.current.itemProps('a').anchorProps.onMouseLeave())
    act(() => result.current.itemProps('a').popoverProps.onMouseEnter())

    act(() => void vi.advanceTimersByTime(1000))
    expect(result.current.openKey).toBe('a')
  })

  it('closes on demand, cancelling any pending close', () => {
    const { result } = renderHook(() => useHoverPopoverGroup())

    act(() => result.current.itemProps('a').triggerProps.onMouseEnter())
    act(() => result.current.itemProps('a').anchorProps.onMouseLeave())
    act(() => result.current.close())

    expect(result.current.openKey).toBeNull()
    expect(vi.getTimerCount()).toBe(0)
  })

  it('drops a pending close when the group unmounts', () => {
    const { result, unmount } = renderHook(() => useHoverPopoverGroup())

    act(() => result.current.itemProps('a').triggerProps.onMouseEnter())
    act(() => result.current.itemProps('a').anchorProps.onMouseLeave())
    expect(vi.getTimerCount()).toBe(1)

    unmount()
    expect(vi.getTimerCount()).toBe(0)
  })
})
