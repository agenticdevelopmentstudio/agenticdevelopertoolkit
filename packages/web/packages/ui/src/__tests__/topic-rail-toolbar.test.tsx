/// <reference types="@testing-library/jest-dom/vitest" />
import { render, screen, cleanup, fireEvent, within } from '@testing-library/react'
import { afterEach, describe, expect, it, vi } from 'vitest'
import { TopicRail } from '../blocks/topic-detail'

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
})
