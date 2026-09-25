/// <reference types="@testing-library/jest-dom/vitest" />
import type { ComponentProps } from 'react'
import { render, screen, cleanup, fireEvent, within, act } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, describe, expect, it, vi } from 'vitest'
import { TopicRail } from '../blocks/topic-detail'
// Through the barrel, as a host reaches it: the export is half of what makes it shareable.
import { ListToolButton } from '../blocks'

afterEach(cleanup)

const props = {
  items: [
    { id: 'a', label: 'Alpha', sublabel: 'first' },
    { id: 'b', label: 'Beta' },
    { id: 'c', label: 'Gamma' },
  ],
  selectedId: null,
  onSelect: () => {},
  emptyLabel: 'Nothing here yet.',
  collapsed: false,
  onToggle: () => {},
  title: 'Topics',
}

const toolbar = () => document.querySelector('[data-htd-toolbar]') as HTMLElement | null
const header = () => document.querySelector('[data-htd-header]') as HTMLElement
const rowLabels = () => screen.queryAllByRole('button').map((b) => b.textContent).filter((t) => t && /Alpha|Beta|Gamma/.test(t))
const magnifier = () => within(toolbar()!).getByRole('button', { name: 'Search' })
const popover = () => document.querySelector('[data-htd-search]') as HTMLElement

// Mike, 2026-09-24: the page-wide filter strip was clunky, so each list carries its own operations
// on a toolbar row under its title — `+`, search, then the list's own tools.
describe('the topic list toolbar', () => {
  it('is absent from a list with no tools, unless a sibling asked for the row', () => {
    render(<TopicRail {...props} />)
    expect(toolbar()).toBeNull()
    cleanup()
    render(<TopicRail {...props} reserveToolbar />)
    expect(toolbar()).not.toBeNull()
  })

  // The stacks ask `hasListTools` whether any level has a toolbar; a rail that answered the same
  // question differently would drop a lone tool that the stacks counted.
  it.each<[string, Pick<ComponentProps<typeof TopicRail>, 'onNew' | 'search' | 'titleActions'>]>([
    ['a +', { onNew: () => {} }],
    ['search', { search: {} }],
    ['its own tools', { titleActions: <button type="button">Tools</button> }],
  ])('is shown for a list whose only tool is %s', (_, tools) => {
    render(<TopicRail {...props} {...tools} />)
    expect(toolbar()).not.toBeNull()
  })

  it('carries the + and the list tools, and the title row no longer does', () => {
    const onNew = vi.fn()
    render(<TopicRail {...props} onNew={onNew} newLabel="New Topic" titleActions={<button type="button">Tools</button>} />)
    const bar = toolbar()!
    fireEvent.click(within(bar).getByRole('button', { name: 'New Topic' }))
    expect(onNew).toHaveBeenCalledOnce()
    expect(within(bar).getByRole('button', { name: 'Tools' })).toBeInTheDocument()
    expect(within(header()).queryByRole('button', { name: 'New Topic' })).toBeNull()
    expect(within(header()).queryByRole('button', { name: 'Tools' })).toBeNull()
  })

  it('is not shown on a collapsed icon strip', () => {
    render(<TopicRail {...props} collapsed onNew={() => {}} search={{}} />)
    expect(toolbar()).toBeNull()
  })

  it('reads +, then search, then the list tools', () => {
    // The order the stacks' prop docs promise their hosts; they used to describe the `+` as
    // right-justified in the header, after the list tools.
    render(<TopicRail {...props} onNew={() => {}} newLabel="New Topic" search={{}} titleActions={<button type="button">Tools</button>} />)
    const bar = within(toolbar()!)
    const follows = (a: Node, b: Node) => (a.compareDocumentPosition(b) & Node.DOCUMENT_POSITION_FOLLOWING) !== 0
    expect(follows(bar.getByRole('button', { name: 'New Topic' }), magnifier())).toBe(true)
    expect(follows(magnifier(), bar.getByRole('button', { name: 'Tools' }))).toBe(true)
  })
})

// A host's own tool on the toolbar — the Manage features puzzle piece, a bucket's settings gear —
// reads as one of the list's tools only while it is drawn exactly like the rail's own. The puzzle
// piece copied the class literal and the gear used a ghost Button, drawn larger and brighter.
describe('ListToolButton', () => {
  it("draws a host's tool exactly like the rail's own, keeping the props the host adds", () => {
    const tool = (
      <ListToolButton label="Manage workspace features" aria-haspopup="dialog">
        <span aria-hidden>⧉</span>
      </ListToolButton>
    )
    render(<TopicRail {...props} onNew={() => {}} newLabel="New Topic" search={{}} titleActions={tool} />)
    const host = within(toolbar()!).getByRole('button', { name: 'Manage workspace features' })
    expect(host.className).toBe(within(toolbar()!).getByRole('button', { name: 'New Topic' }).className)
    expect(host.className).toBe(magnifier().className)
    expect(host).toHaveAttribute('aria-haspopup', 'dialog')
  })

  it('is a plain button named by its label, muted until active turns it gold', () => {
    const { rerender } = render(<ListToolButton label="Bucket settings" />)
    const button = screen.getByRole('button', { name: 'Bucket settings' })
    // Not a submit: a host's toolbar may well sit inside a form.
    expect(button).toHaveAttribute('type', 'button')
    expect(button).toHaveAttribute('title', 'Bucket settings')
    expect(button).toHaveClass('text-apt-text-muted')
    rerender(<ListToolButton label="Bucket settings" active />)
    expect(button).toHaveClass('text-apt-gold')
    expect(button).not.toHaveClass('text-apt-text-muted')
  })
})

describe('topic list search', () => {
  it('pops a field over the list and filters on label and sublabel', () => {
    render(<TopicRail {...props} search={{ placeholder: 'Search topics' }} />)
    expect(screen.queryByRole('searchbox')).toBeNull()
    fireEvent.click(within(toolbar()!).getByRole('button', { name: 'Search topics' }))
    const field = screen.getByRole('searchbox', { name: 'Search topics' })
    expect(field).toHaveFocus()
    fireEvent.change(field, { target: { value: 'FIRST' } })
    expect(rowLabels()).toEqual([expect.stringContaining('Alpha')])
  })

  it('keeps the selected row whatever the query', () => {
    render(<TopicRail {...props} selectedId="c" search={{}} />)
    fireEvent.click(within(toolbar()!).getByRole('button', { name: 'Search' }))
    fireEvent.change(screen.getByRole('searchbox'), { target: { value: 'beta' } })
    expect(rowLabels()).toHaveLength(2)
  })

  it('Escape closes the field and clears the query', () => {
    render(<TopicRail {...props} search={{}} />)
    fireEvent.click(within(toolbar()!).getByRole('button', { name: 'Search' }))
    const field = screen.getByRole('searchbox')
    fireEvent.change(field, { target: { value: 'beta' } })
    fireEvent.keyDown(field, { key: 'Escape' })
    expect(screen.queryByRole('searchbox')).toBeNull()
    expect(rowLabels()).toHaveLength(3)
  })

  it('says when nothing matches', () => {
    render(<TopicRail {...props} search={{}} />)
    fireEvent.click(within(toolbar()!).getByRole('button', { name: 'Search' }))
    fireEvent.change(screen.getByRole('searchbox'), { target: { value: 'zzz' } })
    expect(screen.getByText('Nothing matches “zzz”.')).toBeInTheDocument()
  })

  it('leaves filtering to the host when the query is controlled', () => {
    const onQueryChange = vi.fn()
    render(<TopicRail {...props} search={{ query: 'beta', onQueryChange }} />)
    // The host owns the rows it passes, so the rail shows them all.
    expect(rowLabels()).toHaveLength(3)
    fireEvent.click(within(toolbar()!).getByRole('button', { name: 'Search' }))
    fireEvent.change(screen.getByRole('searchbox'), { target: { value: 'gam' } })
    expect(onQueryChange).toHaveBeenCalledWith('gam')
  })

  it('leaves the empty label to the host when the query is controlled', () => {
    // The host's list is empty while a new query's read is in flight, and only the host knows
    // that — the notebook's "Loading…" used to be replaced by "Nothing matches".
    render(<TopicRail {...props} items={[]} emptyLabel="Loading…" search={{ query: 'beta', onQueryChange: () => {} }} />)
    expect(screen.getByText('Loading…')).toBeInTheDocument()
    expect(screen.queryByText(/Nothing matches/)).toBeNull()
  })
})

// Closing the pop-over unmounts the field that has focus, and focus used to fall to <body>; the
// field's own blur closed it on Tab onto ✕, so Clear was out of the keyboard's reach.
describe('the search pop-over and the keyboard', () => {
  const closers: [string, (field: HTMLElement) => void][] = [
    ['Escape', (field) => fireEvent.keyDown(field, { key: 'Escape' })],
    ['Enter', (field) => fireEvent.keyDown(field, { key: 'Enter' })],
    ['✕', () => fireEvent.click(screen.getByRole('button', { name: 'Clear search' }))],
  ]
  it.each(closers)('hands focus back to the magnifier when %s closes the field', (_, close) => {
    render(<TopicRail {...props} search={{}} />)
    fireEvent.click(magnifier())
    const field = screen.getByRole('searchbox')
    expect(field).toHaveFocus()
    close(field)
    expect(screen.queryByRole('searchbox')).toBeNull()
    expect(magnifier()).toHaveFocus()
  })

  it('stays closed after Enter, keeping the query', async () => {
    // Enter's keypress goes to the magnifier the focus was just handed to, and a button takes it
    // as a click — which would reopen the field Enter closed.
    const user = userEvent.setup()
    render(<TopicRail {...props} search={{}} />)
    await user.click(magnifier())
    await user.keyboard('beta{Enter}')
    expect(screen.queryByRole('searchbox')).toBeNull()
    expect(magnifier()).toHaveFocus()
    expect(rowLabels()).toEqual([expect.stringContaining('Beta')])
  })

  it('stays open when Tab moves from the field onto ✕', async () => {
    const user = userEvent.setup()
    render(<TopicRail {...props} search={{}} />)
    await user.click(magnifier())
    await user.tab()
    expect(screen.getByRole('button', { name: 'Clear search' })).toHaveFocus()
    expect(screen.getByRole('searchbox')).toBeInTheDocument()
  })

  it('closes when focus leaves it, keeping the query', async () => {
    const user = userEvent.setup()
    render(<TopicRail {...props} search={{}} />)
    await user.click(magnifier())
    await user.keyboard('beta')
    await user.tab() // onto ✕, still inside
    await user.tab() // out, onto the list
    expect(screen.queryByRole('searchbox')).toBeNull()
    expect(rowLabels()).toEqual([expect.stringContaining('Beta')])
  })
})

// In the hub's covered stack each rail sits in an `overflow-hidden` column no wider than the
// rail, and on a rail narrower than the field the column cut off the ✕ and the end of the query.
// jsdom has no layout, so the column's clip and both boxes' edges are stated here.
describe('the search pop-over inside a clipping column', () => {
  const rect = (left: number, right: number) =>
    ({ left, right, x: left, width: right - left, top: 0, bottom: 0, y: 0, height: 0, toJSON: () => ({}) }) as DOMRect
  const placeAt = (el: Element, left: number, right: number) =>
    vi.spyOn(el, 'getBoundingClientRect').mockReturnValue(rect(left, right))
  const renderIn = (clips: boolean) => {
    render(
      <div data-testid="column" style={clips ? { overflowX: 'hidden' } : undefined}>
        <TopicRail {...props} search={{}} />
      </div>,
    )
    return screen.getByTestId('column')
  }

  it('stops at the edge of the box that clips it, and follows that edge', () => {
    const column = placeAt(renderIn(true), 0, 150)
    placeAt(toolbar()!, 20, 150)
    fireEvent.click(magnifier())
    expect(popover().style.maxWidth).toBe('130px')
    column.mockReturnValue(rect(0, 200))
    fireEvent(window, new Event('resize'))
    expect(popover().style.maxWidth).toBe('180px')
  })

  it('follows the column as it wipes open around a rail whose own width never moves', () => {
    // The covered stack's reveal widens the COLUMN; the toolbar inside it never resizes.
    const watching = new Map<Element, () => void>()
    const realObserver = globalThis.ResizeObserver
    globalThis.ResizeObserver = class {
      cb: () => void
      constructor(cb: () => void) {
        this.cb = cb
      }
      observe(el: Element) {
        watching.set(el, this.cb)
      }
      unobserve() {}
      disconnect() {
        watching.clear()
      }
    } as unknown as typeof ResizeObserver
    try {
      const columnEl = renderIn(true)
      const column = placeAt(columnEl, 0, 48)
      placeAt(toolbar()!, 0, 240)
      fireEvent.click(magnifier())
      expect(popover().style.maxWidth).toBe('48px')
      column.mockReturnValue(rect(0, 240))
      act(() => watching.get(columnEl)?.())
      expect(popover().style.maxWidth).toBe('240px')
      // Closing stops the watching.
      fireEvent.keyDown(screen.getByRole('searchbox'), { key: 'Escape' })
      expect(watching.size).toBe(0)
    } finally {
      globalThis.ResizeObserver = realObserver
    }
  })

  it('is not capped where nothing clips it', () => {
    placeAt(renderIn(false), 0, 150)
    placeAt(toolbar()!, 20, 150)
    fireEvent.click(magnifier())
    expect(popover().style.maxWidth).toBe('')
  })
})

// A rail filtering its own rows measured just the MATCHES when something else made it
// re-measure, and kept that width after the query cleared, ellipsising the full list.
describe('auto-fit while the rail filters its own rows', () => {
  it('never measures the matches, and measures the whole list again once the query clears', () => {
    // jsdom has no layout: a column of rows is as wide as its widest row, at 10px a character.
    const real = Object.getOwnPropertyDescriptor(HTMLElement.prototype, 'scrollWidth')
    Object.defineProperty(HTMLElement.prototype, 'scrollWidth', {
      configurable: true,
      get(this: HTMLElement) {
        const rows = [...this.querySelectorAll('[data-htd-row]')]
        return rows.reduce((w, r) => Math.max(w, (r.textContent ?? '').length * 10), 0)
      },
    })
    try {
      const long = { id: 'long', label: 'x'.repeat(30) } // 300px, inside the fit range
      const wider = { id: 'wider', label: 'y'.repeat(35) } // 350px, and no match for "beta"
      const onFit = vi.fn()
      const rail = (items: typeof props.items) => <TopicRail {...props} items={items} onFit={onFit} search={{}} />
      const { rerender } = render(rail([long, ...props.items]))
      fireEvent.click(magnifier())
      fireEvent.change(screen.getByRole('searchbox'), { target: { value: 'beta' } })
      // A new row lands while the query hides it — a searched Personas rail's `+`. The rail
      // used to measure the one match here, and nothing measured it again after Escape.
      rerender(rail([long, ...props.items, wider]))
      fireEvent.keyDown(screen.getByRole('searchbox'), { key: 'Escape' })
      expect(onFit.mock.calls.map(([w]) => w)).toEqual([300, 350])
    } finally {
      if (real) Object.defineProperty(HTMLElement.prototype, 'scrollWidth', real)
      else delete (HTMLElement.prototype as unknown as Record<string, unknown>).scrollWidth
    }
  })
})
