"use client"

import { useEffect, useRef, useState, type ReactElement, type ReactNode } from "react"

import { cn } from "../lib/utils"

// A website's own icon, found by asking the site for it — or the caller's
// fallback glyph where it has none. There is no single place a site keeps its
// icon: `/favicon.ico` is the old convention, and a Next.js app that declares
// `app/icon.svg` or `app/icon.png` serves it at `/icon.svg` / `/icon.png` and
// may have no `.ico` at all. So each candidate is tried in turn and the first
// one that loads is kept.
//
// The image is requested from the site itself, never through a third-party
// favicon service, so drawing a link does not tell anyone else which links a
// page draws.
//
// A failed load can happen BEFORE hydration — the server-rendered <img> starts
// fetching as soon as the HTML arrives — and React never sees that `error`
// event. The effect re-checks a finished image that decoded to nothing, which
// is what a pre-hydration failure leaves behind.

/** Where a site's icon usually is, most likely first. The bare `/icon` and
 * `/apple-icon` are where Next.js serves an icon generated from `app/icon.tsx`,
 * which has no file extension and no static copy at any of the other paths. */
export const FAVICON_PATHS = [
  "/favicon.ico",
  "/icon.svg",
  "/icon.png",
  "/icon",
  "/apple-icon.png",
  "/apple-icon",
]

export interface FaviconProps {
  /** Any address on the site; only its origin is used. */
  href: string
  /** Rendered once every candidate has failed (e.g. a lucide `Globe`). */
  fallback?: ReactNode
  /** Square size in px. */
  size?: number
  className?: string
}

function originOf(href: string): string | null {
  try {
    return new URL(href).origin
  } catch {
    return null
  }
}

export function Favicon({ href, fallback = null, size = 16, className }: FaviconProps): ReactElement {
  const origin = originOf(href)
  const [tried, setTried] = useState(0)
  const ref = useRef<HTMLImageElement>(null)

  const failed = origin == null || tried >= FAVICON_PATHS.length
  const next = (): void => setTried((n) => n + 1)

  useEffect(() => {
    const img = ref.current
    if (img && img.complete && img.naturalWidth === 0) next()
  }, [tried])

  if (failed) return <>{fallback}</>
  return (
    <img
      ref={ref}
      // One element per candidate, so a new src is a new load with its own events.
      key={tried}
      src={origin + FAVICON_PATHS[tried]}
      alt=""
      aria-hidden="true"
      width={size}
      height={size}
      decoding="async"
      onError={next}
      className={cn("shrink-0 rounded-[3px] object-contain", className)}
    />
  )
}
