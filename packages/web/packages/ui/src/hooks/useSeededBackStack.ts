"use client"

import { useEffect, useLayoutEffect, useRef } from "react"

/**
 * Make the BROWSER's Back walk up a routed topic stack, one level per press — and say so when a
 * level's clear cannot.
 *
 * The in-page Back and the page's swipe-back (lib/swipe-back.ts) are the stack's own: they call
 * the deepest level's `onClear`. The browser's Back is not. iOS Safari's Back button and its edge
 * swipe — which starts inside the gutter the page's swipe leaves alone, precisely because it is
 * the browser's — go to whatever history entry precedes this one. After in-page navigation that is
 * the previous selection, which is right. After a DEEP LINK there is nothing before it but the
 * site the visitor came from, so Back left the site with the item still chosen, and on a phone
 * there was no way back up the stack but the small chevron.
 *
 * So a page LOADED onto a selection gets the history it would have had if the visitor had clicked
 * their way there: one entry per selected level, shallowest first, each at that level's
 * `clearHref` — the address where that level has nothing chosen — with the page itself pushed back
 * on top. Back then lands on the address of "this level, nothing selected", exactly what the
 * in-page Back shows.
 *
 * Seeded entries carry `_N`, which a router that patches `history` (Next's app router does) treats
 * as someone else's and leaves alone, and a marker naming the address. When Back lands on one, the
 * stack that is still mounted clears the level that leads there, with `{ replace: true }` so the
 * seeded entry becomes the host's own entry rather than gaining a twin. Nothing mounted to answer
 * (the visitor navigated away and came back through history) means the entry is left to the
 * router — Next reloads an entry it does not own, which lands on the right page, only slower.
 *
 * Only ONCE per document, and only on a fresh load (`navigate`): a reload or a return through
 * history already has its entries, and seeding again would stack a second copy under them.
 *
 * The popstate listener is attached the first time a stack seeds and never removed — attached
 * then, from an effect in a component beneath the router, it is registered before the router's
 * own listener, so it answers first and can keep the router from reloading an entry the stack
 * handles. It is also a CAPTURE listener, which at the window runs ahead of bubble listeners in
 * current browsers, for the stacks that mount after the router's listener exists.
 */

/** A clearable level, as this hook sees one: whether it is chosen, where it clears to, how. */
export interface SeedableLevel {
  selectedId: string | null
  clearHref?: string
  onClear: (opts?: { replace?: boolean }) => void
}

const SEED_KEY = "__adhTopicSeed"

let seeded = false
let listening = false
/** The mounted stack's answer to a Back that landed on a seeded entry: true when it handled it. */
let answer: ((href: string) => boolean) | null = null

function resolve(href: string): string {
  const url = new URL(href, window.location.href)
  return url.pathname + url.search
}

function here(): string {
  return window.location.pathname + window.location.search
}

function onPopState(event: PopStateEvent): void {
  const href = (event.state as Record<string, unknown> | null)?.[SEED_KEY]
  if (typeof href !== "string" || !answer?.(href)) return
  event.stopImmediatePropagation()
}

function freshLoad(): boolean {
  const nav = performance.getEntriesByType?.("navigation")[0] as PerformanceNavigationTiming | undefined
  return !nav || nav.type === "navigate"
}

/** The seeded Back stack for `levels` (outermost first). A no-op unless every selected level
 *  declares a `clearHref`. */
export function useSeededBackStack(levels: readonly SeedableLevel[]): void {
  const latest = useRef(levels)
  useLayoutEffect(() => {
    latest.current = levels
  })

  // While mounted, this stack answers Backs onto seeded entries: the selected level that clears to
  // that address clears, in place.
  useEffect(() => {
    const mine = (href: string): boolean => {
      const target = resolve(href)
      const level = latest.current.find(
        (l) => l.selectedId != null && l.clearHref !== undefined && resolve(l.clearHref) === target,
      )
      if (!level) return false
      level.onClear({ replace: true })
      return true
    }
    answer = mine
    return () => {
      if (answer === mine) answer = null
    }
  }, [])

  // A dead clear: a selected level whose "nothing selected here" address is the page already on
  // screen. Its Back, swipe and breadcrumb can only reload what is showing — say which one.
  useEffect(() => {
    const now = here()
    for (const level of levels) {
      if (level.selectedId == null || level.clearHref === undefined) continue
      if (resolve(level.clearHref) === now) {
        console.error(
          `[HierarchicalTopicDetail] "${level.selectedId}" is selected at ${now}, which is also this ` +
            `level's clearHref — its onClear cannot clear it, so Back and the breadcrumbs are dead here. ` +
            `The cleared address must show this level with nothing selected.`,
        )
      }
    }
  })

  useEffect(() => {
    if (seeded) return
    seeded = true
    if (!freshLoad()) return
    const chosen: SeedableLevel[] = []
    for (const level of levels) {
      if (level.selectedId == null) break
      chosen.push(level)
    }
    if (chosen.length === 0 || chosen.some((l) => l.clearHref === undefined)) return

    const page = here()
    const trail: string[] = []
    for (const level of chosen) {
      const href = resolve(level.clearHref!)
      if (href !== page && href !== trail.at(-1)) trail.push(href)
    }
    if (trail.length === 0) return

    if (!listening) {
      window.addEventListener("popstate", onPopState, { capture: true })
      listening = true
    }
    const state: unknown = window.history.state
    const pageHref = page + window.location.hash
    trail.forEach((href, i) => {
      const entry = { _N: true, [SEED_KEY]: href }
      if (i === 0) window.history.replaceState(entry, "", href)
      else window.history.pushState(entry, "", href)
    })
    window.history.pushState(state, "", pageHref)
    // `levels` is read once, on the first commit: the seed describes how the page was LOADED.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])
}

/** Test seam: forget that this document seeded, and stop answering. */
export function resetSeededBackStackForTests(): void {
  seeded = false
  answer = null
  if (listening) window.removeEventListener("popstate", onPopState, { capture: true })
  listening = false
}
