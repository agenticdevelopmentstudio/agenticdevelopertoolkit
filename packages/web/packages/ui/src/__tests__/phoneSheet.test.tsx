/**
 * The dialog's phone sheet, and the one phone breakpoint JS and CSS share.
 *
 * `DialogContent`'s `sheetOnPhone` turns a centred dialog into a full-screen sheet below
 * Tailwind's `sm`, in CSS (`max-sm:` classes, exported as `PHONE_SHEET_CLASSES` for a surface that
 * is not a dialog). `PHONE_MAX_WIDTH` is that same line for a surface that has to switch in JS
 * (adh's FloatingWindow, which takes both). Before either existed, the User Settings
 * overlay and the FloatingWindow each hand-typed `(max-width: 639px)` and the overlay carried its
 * own copy of the sheet as an inline style — which beat every class the shared dialog had, at
 * every width, and was not the line Tailwind draws: `sm` is 40rem, which follows the reader's
 * default font size where 639px does not.
 *
 * So this compiles Tailwind rather than trusting anyone's memory of it. A class Tailwind does not
 * recognise compiles to NOTHING, silently — a sheet whose `translate` reset is misspelt still
 * renders, a quarter off-screen — so every sheet class on the rendered popup is compiled and must
 * land under exactly `@media ${PHONE_MAX_WIDTH}`.
 *
 * The option is opt-in, and `DialogContent` is every dialog in the fleet: a dialog that does not
 * ask for the sheet must render exactly as it did.
 */
/// <reference types="@testing-library/jest-dom/vitest" />
import { render, cleanup, screen } from '@testing-library/react'
import { compile } from 'tailwindcss'
import { describe, it, expect, afterEach } from 'vitest'

import { Dialog, DialogContent, DialogTitle, PHONE_SHEET_CLASSES } from '../components/dialog'
import { PHONE_MAX_WIDTH } from '../hooks/useMediaQuery'

// This package typechecks without Node's types — its tsconfig loads none, and its own code must
// not lean on them — so the three Node APIs needed to read Tailwind's stylesheets are reached
// through `process.getBuiltinModule` and typed here, for this file alone. (A `?raw` import is no
// way round it: vitest empties every `.css` module, raw ones included, unless `css` is enabled.)
type NodeBuiltins = {
  getBuiltinModule(id: 'node:fs'): { readFileSync(path: string, encoding: 'utf8'): string }
  getBuiltinModule(id: 'node:module'): {
    createRequire(from: string): { resolve(id: string): string }
  }
  getBuiltinModule(id: 'node:path'): { dirname(path: string): string }
}
const node = (globalThis as unknown as { process: NodeBuiltins }).process
const { readFileSync } = node.getBuiltinModule('node:fs')
const { dirname } = node.getBuiltinModule('node:path')
const requireHere = node.getBuiltinModule('node:module').createRequire(import.meta.url)

/**
 * The CSS Tailwind emits for `classes` alone, from its DEFAULT theme — the one every site in the
 * fleet takes `sm` from. A fresh compiler per call: `build()` accumulates every candidate it has
 * ever been given, so a shared one would credit one class with another's rules.
 */
async function tailwind(classes: string[]): Promise<string> {
  const compiler = await compile(
    '@import "tailwindcss/theme.css" layer(theme); @import "tailwindcss/utilities.css" layer(utilities);',
    {
      loadStylesheet: async (id: string) => {
        const path = requireHere.resolve(id)
        return { path, base: dirname(path), content: readFileSync(path, 'utf8') }
      },
    },
  )
  return compiler.build(classes)
}

function popup(): HTMLElement {
  const el = document.querySelector('[data-slot="dialog-content"]')
  if (!(el instanceof HTMLElement)) throw new Error('no open dialog')
  return el
}

function classes(el: HTMLElement): string[] {
  return el.className.split(/\s+/).filter(Boolean)
}

function renderDialog(props: { sheetOnPhone?: boolean; className?: string } = {}) {
  return render(
    <Dialog open>
      <DialogContent {...props}>
        <DialogTitle>Settings</DialogTitle>
        <p>body</p>
      </DialogContent>
    </Dialog>,
  )
}

afterEach(cleanup)

describe('DialogContent sheetOnPhone', () => {
  it('leaves a dialog that does not ask for the sheet centred at every width', () => {
    renderDialog()
    const cls = classes(popup())
    expect(cls.filter((c) => c.startsWith('max-sm:'))).toEqual([])
    for (const c of ['top-1/2', 'left-1/2', '-translate-x-1/2', '-translate-y-1/2', 'max-w-md', 'rounded-xl'])
      expect(cls).toContain(c)
  })

  it('pins a dialog that asks for it to every edge of a phone, with its × still in it', () => {
    renderDialog({ sheetOnPhone: true, className: 'p-0 sm:max-w-[min(72rem,calc(100vw-2rem))]' })
    const cls = classes(popup())
    for (const c of [
      'max-sm:inset-0',
      'max-sm:translate-none',
      'max-sm:w-auto',
      'max-sm:max-w-none',
      'max-sm:h-dvh',
      'max-sm:max-h-none',
      'max-sm:rounded-none',
    ])
      expect(cls).toContain(c)
    // The exported string IS the sheet — every token of it survives the merge onto the popup — so
    // a surface that takes the string rather than the prop gets exactly what this test compiles.
    expect(cls.filter((c) => c.startsWith('max-sm:')).sort()).toEqual(PHONE_SHEET_CLASSES.split(' ').sort())
    // The consumer's classes still merge as they did: its padding replaces the default, and its
    // desktop footprint rides beside the sheet rather than being dropped as a conflict.
    expect(cls).toContain('p-0')
    expect(cls).not.toContain('p-5')
    expect(cls).toContain('sm:max-w-[min(72rem,calc(100vw-2rem))]')
    expect(screen.getByRole('button', { name: 'Close' })).toBeInTheDocument()
  })

  it('compiles every sheet class, and only below exactly PHONE_MAX_WIDTH', async () => {
    renderDialog({ sheetOnPhone: true })
    const sheet = classes(popup()).filter((c) => c.startsWith('max-sm:'))
    expect(sheet.length).toBeGreaterThan(0)
    for (const c of sheet) {
      const css = await tailwind([c])
      expect(css, c).toContain(`@media ${PHONE_MAX_WIDTH}`)
    }
    // The resets that make it a sheet rather than a dialog shoved into a corner.
    expect(await tailwind(['max-sm:translate-none'])).toMatch(/translate:\s*none/)
    expect(await tailwind(['max-sm:h-dvh'])).toMatch(/height:\s*100dvh/)
  })

  it('insets the sheet from the notch with a transparent border, so the × moves in with it', async () => {
    renderDialog({ sheetOnPhone: true })
    const cls = classes(popup())
    expect(cls).toContain('max-sm:border-transparent')
    // A BORDER, not padding: it adds to the dialog's own padding instead of replacing it, and the
    // absolutely placed × is positioned from the padding edge, inside it. The `0px` fallback keeps
    // a browser without the variable at no border rather than the initial `medium`.
    for (const side of ['top', 'right', 'bottom', 'left']) {
      const c = cls.find((x) => x.startsWith(`max-sm:border-${side[0]}-[`))
      expect(c, side).toBeDefined()
      expect(await tailwind([c as string])).toMatch(
        new RegExp(`border-${side}-width:\\s*env\\(safe-area-inset-${side},\\s*0px\\)`),
      )
    }
  })

  it('hands over to a consumer’s `sm:` sizing at the very width the sheet lets go', async () => {
    // The overlay sizes its desktop footprint with `sm:` classes. The two media queries must
    // tile the axis — no width at which neither applies, none at which both do.
    const css = await tailwind(['sm:p-0'])
    expect(css).toContain(`@media ${PHONE_MAX_WIDTH.replace('<', '>=')}`)
  })
})
