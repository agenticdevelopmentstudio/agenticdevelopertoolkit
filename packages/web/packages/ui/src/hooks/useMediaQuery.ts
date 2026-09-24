"use client"

import { useCallback, useSyncExternalStore } from "react"

/**
 * A phone-width viewport: narrower than Tailwind's `sm` breakpoint (`--breakpoint-sm`, 40rem).
 * Below it a centred dialog or a floating window no longer fits with a margin round it, so it
 * becomes a full-screen sheet — `DialogContent`'s `sheetOnPhone` in CSS, adh's FloatingWindow
 * in JS through this.
 *
 * Spelled exactly as Tailwind emits `max-sm:`, `(width < 40rem)`, not `(max-width: 639px)`, which
 * two components each hand-copied before this existed. A surface that switches in JS and one that
 * switches in CSS must flip at the same width, and the px spelling did not: it disagreed with `sm`
 * for a window between 639 and 640px wide, and at EVERY width once the reader's default font size
 * is not 16px, because a rem in a media query follows that setting and a px does not. It matters
 * more than a mismatch between two surfaces: FloatingWindow switches on this and then wears the
 * dialog's own `PHONE_SHEET_CLASSES`, so between two parted lines it would have neither its floating
 * geometry nor the sheet's. The range syntax needs Safari 16.4, Tailwind v4's own floor, so on an
 * older browser the two fail together (no match here, no `max-sm:` there) rather than apart.
 * `__tests__/phoneSheet.test.tsx` compiles Tailwind and fails if this and `max-sm:` part. Nothing
 * in the fleet redefines `--breakpoint-sm`; a theme that ever does must change this with it.
 */
export const PHONE_MAX_WIDTH = "(width < 40rem)"

/**
 * Subscribe to a CSS media query and return whether it currently matches.
 *
 * SSR-safe: returns `false` on the server, then the real value on the client.
 * Built on `useSyncExternalStore` (not `useEffect`+`setState`) so the matched
 * value is read during render rather than synced in an effect. Use for
 * desktop/mobile gating, e.g. `useMediaQuery("(min-width: 1024px)")`.
 */
export function useMediaQuery(query: string): boolean {
  const subscribe = useCallback(
    (onStoreChange: () => void): (() => void) => {
      if (typeof window === "undefined") return () => {}
      const mql = window.matchMedia(query)
      mql.addEventListener("change", onStoreChange)
      return () => mql.removeEventListener("change", onStoreChange)
    },
    [query],
  )

  const getSnapshot = useCallback(
    (): boolean => typeof window !== "undefined" && window.matchMedia(query).matches,
    [query],
  )

  return useSyncExternalStore(subscribe, getSnapshot, () => false)
}
