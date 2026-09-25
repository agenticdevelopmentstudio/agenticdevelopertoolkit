"use client"

import { createContext, useContext, type ReactElement, type ReactNode } from "react"

/** What a help popover is FOR, which is the only thing its icon says.
 *  Three cover the cases the feature was asked for; a fourth is added when
 *  something needs one. */
export type HelpFlavor = "help" | "info" | "new"

export interface HelpEntry {
  /** Optional heading above the body. Omitted for the header's site-name entry,
   *  which is derived from SEO copy and has no title to invent. */
  title?: string
  /** A string, not a ReactNode: 37 of adh's 41 site configs are `.ts` and cannot
   *  hold JSX, and this value is declared in those files. */
  body: string
  /** Default `info`. */
  flavor?: HelpFlavor
}

/** A site's help copy, keyed by the id a <HelpEnabled> names.
 *
 *  NOT adh's other help store, which is easy to mistake this for. That one lives
 *  in the consuming application, over its own per-locale help content file, and is
 *  ROUTE-keyed — `<feature>` / `<feature>/<topic>` — and serves the hierarchical
 *  topic/detail views under the `source-help-from-config` rule, returning a
 *  bare string for a pane to show in place. This one is keyed by a UI element's
 *  id, spans a whole site rather than one feature's routes, and carries a flavor.
 *  Different key space, different surface; neither is a migration target for the
 *  other. */
export type SiteHelp = Record<string, HelpEntry>

// Well-known ids belong in a plain `.ts` module of the consuming app's own, not
// here: this module is `"use client"`, and a server-side site definition has to be
// able to read an id without pulling a client component into the server graph.

const HelpContentContext = createContext<SiteHelp>({})

/** Publishes a site's help copy to everything below it.
 *
 *  Mounted at the document level rather than passed to the header, because four
 *  sites replace the shared header entirely via MarketingRootHtml's `header`
 *  slot — a prop would reach the shared header and miss them. */
export function HelpContentProvider({
  help,
  children,
}: {
  help: SiteHelp
  children: ReactNode
}): ReactElement {
  return (
    <HelpContentContext.Provider value={help}>{children}</HelpContentContext.Provider>
  )
}

/** The entry for `id`, or undefined when the site declared none.
 *
 *  Undefined rather than a throw, including with no provider mounted at all:
 *  the first consumer is in the header on every page of every site, so a throw
 *  here turns a typo into a white screen. <HelpEnabled> warns to the console
 *  instead, once per unknown id. */
export function useHelpEntry(id: string): HelpEntry | undefined {
  const help = useContext(HelpContentContext)
  // `hasOwn`, not a bare index: `SiteHelp` is a plain object literal written by
  // hand in a site config, so it inherits Object.prototype. A bare `help[id]`
  // answers ids like `constructor` or `toString` with a function, and
  // <HelpEnabled> would take that truthy value for an entry and render a popover
  // out of `undefined` copy rather than warning that the id is unknown.
  return Object.hasOwn(help, id) ? help[id] : undefined
}
