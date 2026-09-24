import { describe, it, expect } from 'vitest'
import { isModifiedClick, type ClickModifiers } from '../lib/navigation-guard'

// The ONE definition of "a click the browser keeps", shared by the guard's click
// interceptor and every adh chrome handler that turns a link click into something
// in-page. Five hand-written copies preceded it and one (the footer's Legal links)
// had already dropped the button check, so the whole rule is pinned here.

const plain: ClickModifiers = {
  button: 0,
  metaKey: false,
  ctrlKey: false,
  shiftKey: false,
  altKey: false,
}

describe('isModifiedClick', () => {
  it('leaves a plain primary click to the caller', () => {
    expect(isModifiedClick(plain)).toBe(false)
  })

  it.each([
    ['meta (Cmd: new tab)', { metaKey: true }],
    ['ctrl (new tab)', { ctrlKey: true }],
    ['shift (new window)', { shiftKey: true }],
    ['alt (download)', { altKey: true }],
  ])('hands a %s click to the browser', (_name, modifier) => {
    expect(isModifiedClick({ ...plain, ...modifier })).toBe(true)
  })

  it.each([
    ['middle', 1],
    ['secondary', 2],
  ])('hands a %s-button click to the browser', (_name, button) => {
    expect(isModifiedClick({ ...plain, button })).toBe(true)
  })

  it('does not read defaultPrevented: "already handled" is a separate question', () => {
    // A caller that must also bail on a prevented click asks that beside this call.
    // Folding it in would make the guard's primary de-dupe look like a modifier rule.
    const handled = { ...plain, defaultPrevented: true }
    expect(isModifiedClick(handled)).toBe(false)
  })

  it('accepts a real DOM MouseEvent', () => {
    expect(isModifiedClick(new MouseEvent('click', { button: 0 }))).toBe(false)
    expect(isModifiedClick(new MouseEvent('click', { button: 0, metaKey: true }))).toBe(true)
  })
})
