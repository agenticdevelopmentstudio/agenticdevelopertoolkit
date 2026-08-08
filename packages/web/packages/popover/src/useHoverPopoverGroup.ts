"use client"
import { useCallback, useEffect, useRef, useState } from 'react'

/** ms between the pointer leaving an anchor and its popover closing. */
const DEFAULT_CLOSE_DELAY = 200

export interface HoverPopoverGroupOptions {
  /**
   * How long to wait, after the pointer leaves an anchor, before closing its
   * popover. The delay is what makes a row of these usable: without it, the
   * few frames the pointer spends between the trigger and the panel read as
   * "left everything", and the panel flickers shut under a hand that is
   * still moving toward it. Default 200ms.
   */
  closeDelay?: number
}

export interface HoverPopoverItemProps {
  /** Spread onto the item's `<PopoverAnchor>`. */
  anchorProps: { onMouseLeave: () => void }
  /** Spread onto whatever element opens the popover. */
  triggerProps: { onMouseEnter: () => void }
  /** Spread onto the item's `<Popover>`. */
  popoverProps: {
    open: boolean
    onMouseEnter: () => void
    onMouseLeave: () => void
  }
}

export interface HoverPopoverGroup {
  /** The key of the open popover, or `null` when none is. */
  openKey: string | null
  /** Close whatever is open, and cancel any pending close. */
  close: () => void
  /** The handlers for one item of the group, keyed however the caller keys its items. */
  itemProps: (key: string) => HoverPopoverItemProps
}

/**
 * Hover-intent state for a SET of popovers where at most one is open.
 *
 * One hook per group rather than one per popover, because "only one open" is
 * a property of the group and there is nowhere else to keep it. Two panels
 * open at once is not a cosmetic problem — they are wide, they overlap, and
 * the second one to open reads as a submenu of the first.
 *
 * Groups nest: a popover whose contents are themselves triggers calls this
 * again for its own row, and the two groups never see each other.
 */
export function useHoverPopoverGroup({
  closeDelay = DEFAULT_CLOSE_DELAY,
}: HoverPopoverGroupOptions = {}): HoverPopoverGroup {
  const [openKey, setOpenKey] = useState<string | null>(null)
  const timerRef = useRef<ReturnType<typeof setTimeout> | null>(null)

  const cancelClose = useCallback((): void => {
    if (timerRef.current !== null) {
      clearTimeout(timerRef.current)
      timerRef.current = null
    }
  }, [])

  const scheduleClose = useCallback((): void => {
    // Cancel first, so there is only ever one pending close. That is also why
    // the callback can clear `openKey` outright rather than checking which
    // item scheduled it: every other transition — opening a sibling,
    // re-entering a panel, closing the group — passes through `cancelClose`
    // too, so a timer that survives to fire always belongs to whatever is
    // currently open.
    cancelClose()
    timerRef.current = setTimeout(() => {
      timerRef.current = null
      setOpenKey(null)
    }, closeDelay)
  }, [cancelClose, closeDelay])

  const open = useCallback(
    (key: string): void => {
      cancelClose()
      setOpenKey(key)
    },
    [cancelClose],
  )

  const close = useCallback((): void => {
    cancelClose()
    setOpenKey(null)
  }, [cancelClose])

  // A pending close outlives the component that scheduled it otherwise, and
  // fires a state update into a tree that is gone.
  useEffect(() => cancelClose, [cancelClose])

  const itemProps = useCallback(
    (key: string): HoverPopoverItemProps => ({
      anchorProps: { onMouseLeave: scheduleClose },
      triggerProps: { onMouseEnter: () => open(key) },
      popoverProps: {
        open: openKey === key,
        onMouseEnter: cancelClose,
        onMouseLeave: scheduleClose,
      },
    }),
    [openKey, open, scheduleClose, cancelClose],
  )

  return { openKey, close, itemProps }
}
