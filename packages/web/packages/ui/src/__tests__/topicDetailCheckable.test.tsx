/**
 * BATCH MODE on a rail's rows (`TopicLevel.checkable`): a checkbox per row, ticking one reports the
 * id and nothing else. The rule under test is the one that is easy to lose and expensive to lose —
 * a tick is NOT a selection. The user enters batch mode to pick rows to Delete, Export or Transfer;
 * if ticking also moved the single selection, the detail pane would swap out from under them on
 * every tick, and the row they were reading would be gone by the time they had chosen four.
 *
 * Rendered through the real HierarchicalTopicDetail so the props are exercised over the same path a
 * consumer uses (level -> TopicRail -> TopicList), not against TopicList directly.
 */
import { render, screen, fireEvent } from '@testing-library/react'
import { describe, it, expect, vi } from 'vitest'
import { HierarchicalTopicDetail, type TopicLevel } from '../blocks/hierarchical-topic-detail'

const ITEMS = [
  { id: 'gh1', label: 'GitHub (acme)' },
  { id: 'gh2', label: 'GitHub (fishlamp)' },
]

function renderLevel(over: Partial<TopicLevel> = {}, onSelect = vi.fn()) {
  const level: TopicLevel = {
    id: 'integrations',
    title: 'Integrations',
    items: ITEMS,
    selectedId: null,
    onSelect,
    onClear: () => {},
    ...over,
  }
  return render(
    <HierarchicalTopicDetail levels={[level]}>
      <div>detail</div>
    </HierarchicalTopicDetail>,
  )
}

describe('TopicLevel.checkable', () => {
  it('renders no checkboxes until the level asks for them', () => {
    renderLevel()
    expect(screen.queryAllByRole('checkbox')).toHaveLength(0)
  })

  it('renders one checkbox per row, named for the row', () => {
    renderLevel({ checkable: true, checkedIds: new Set<string>(), onToggleChecked: vi.fn() })
    expect(screen.getAllByRole('checkbox')).toHaveLength(2)
    expect(screen.getByRole('checkbox', { name: 'GitHub (acme)' })).toBeInTheDocument()
  })

  it('reflects checkedIds', () => {
    renderLevel({
      checkable: true,
      checkedIds: new Set(['gh2']),
      onToggleChecked: vi.fn(),
    })
    expect(screen.getByRole('checkbox', { name: 'GitHub (acme)' })).not.toBeChecked()
    expect(screen.getByRole('checkbox', { name: 'GitHub (fishlamp)' })).toBeChecked()
  })

  it('ticking reports the id and does NOT change the single selection', () => {
    const onSelect = vi.fn()
    const onToggleChecked = vi.fn()
    renderLevel({ checkable: true, checkedIds: new Set<string>(), onToggleChecked }, onSelect)
    fireEvent.click(screen.getByRole('checkbox', { name: 'GitHub (acme)' }))
    expect(onToggleChecked).toHaveBeenCalledExactlyOnceWith('gh1')
    expect(onSelect).not.toHaveBeenCalled()
  })

  it('still selects when the ROW is clicked in batch mode', () => {
    const onSelect = vi.fn()
    renderLevel(
      { checkable: true, checkedIds: new Set<string>(), onToggleChecked: vi.fn() },
      onSelect,
    )
    fireEvent.click(screen.getByRole('button', { name: /GitHub \(acme\)/ }))
    expect(onSelect).toHaveBeenCalledWith('gh1')
  })
})
