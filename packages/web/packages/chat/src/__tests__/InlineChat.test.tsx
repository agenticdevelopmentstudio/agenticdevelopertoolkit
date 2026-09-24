import { describe, it, expect, vi } from 'vitest'
import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import { InlineChat } from '../modes/InlineChat'
import type { ChatBackend } from '../backends/types'

function createBackend(response: string = 'reply'): ChatBackend {
  return { sendMessage: vi.fn().mockResolvedValue(response) }
}

describe('InlineChat', () => {
  it('renders with welcome message', () => {
    render(
      <InlineChat
        backend={createBackend()}
        persona={{ name: 'Bot' }}
        welcomeMessage="Hello!"
      />,
    )
    expect(screen.getByText('Hello!')).toBeInTheDocument()
  })

  it('renders input area', () => {
    render(
      <InlineChat backend={createBackend()} persona={{ name: 'Bot' }} />,
    )
    expect(screen.getByPlaceholderText('Type a message...')).toBeInTheDocument()
  })

  it('sends message and shows response', async () => {
    render(
      <InlineChat
        backend={createBackend('Bot says hi')}
        persona={{ name: 'Bot' }}
      />,
    )

    const input = screen.getByPlaceholderText('Type a message...')
    fireEvent.change(input, { target: { value: 'hello' } })
    fireEvent.keyDown(input, { key: 'Enter' })

    await waitFor(() => {
      expect(screen.getByText('Bot says hi')).toBeInTheDocument()
    })
  })

  it('renders inline popovers', async () => {
    const backend: ChatBackend = {
      sendMessage: vi.fn().mockResolvedValue({
        text: 'Check this',
        popover: { title: 'Details', description: 'More info' },
      }),
    }

    render(
      <InlineChat backend={backend} persona={{ name: 'Bot' }} />,
    )

    const input = screen.getByPlaceholderText('Type a message...')
    fireEvent.change(input, { target: { value: 'test' } })
    fireEvent.keyDown(input, { key: 'Enter' })

    await waitFor(() => {
      expect(screen.getByText('Details')).toBeInTheDocument()
      expect(screen.getByText('More info')).toBeInTheDocument()
    })
  })

  it('applies custom className', () => {
    const { container } = render(
      <InlineChat
        backend={createBackend()}
        persona={{ name: 'Bot' }}
        className="custom-chat"
      />,
    )
    expect(container.querySelector('.persona-chat.custom-chat')).toBeInTheDocument()
  })

  it('does not add the hugging class when sizing is omitted (default fixed)', () => {
    const { container } = render(
      <InlineChat backend={createBackend()} persona={{ name: 'Bot' }} />,
    )
    const chat = container.querySelector('.persona-chat')
    expect(chat).toBeInTheDocument()
    expect(chat?.classList.contains('pc-hugging')).toBe(false)
  })

  it('adds the hugging class and inline maxHeight in content-hugging mode', () => {
    const { container } = render(
      <InlineChat
        backend={createBackend()}
        persona={{ name: 'Bot' }}
        sizing={{
          active: {
            mode: 'content-hugging',
            maxHeight: { kind: 'css', value: '300px' },
          },
        }}
      />,
    )
    const chat = container.querySelector('.persona-chat') as HTMLElement | null
    expect(chat).toBeInTheDocument()
    expect(chat?.classList.contains('pc-hugging')).toBe(true)
    // The hook resolves the css value and applies it as inline maxHeight.
    expect(chat?.style.maxHeight).toBe('300px')
  })

  it('collapses to the input bar when idle and expands on focus (minimal inactive)', () => {
    const { container } = render(
      <InlineChat
        backend={createBackend()}
        persona={{ name: 'Bot' }}
        sizing={{ active: { mode: 'fixed' }, inactive: { mode: 'minimal' } }}
      />,
    )
    const chat = container.querySelector('.persona-chat') as HTMLElement
    // Idle: collapsed to the input bar, animated by default.
    expect(chat.classList.contains('pc-collapsed')).toBe(true)
    expect(chat.classList.contains('pc-anim')).toBe(true)

    // Engaging (focusing the input) expands.
    fireEvent.focusIn(screen.getByPlaceholderText('Type a message...'))
    expect(chat.classList.contains('pc-collapsed')).toBe(false)
  })

  it('reports engagement to the host, and lets the host take it over with `engaged`', () => {
    const backend = createBackend()
    const onEngagedChange = vi.fn()
    const chatWith = (engaged: boolean) => (
      <InlineChat
        backend={backend}
        persona={{ name: 'Bot' }}
        sizing={{ active: { mode: 'fixed' }, inactive: { mode: 'minimal' } }}
        engaged={engaged}
        onEngagedChange={onEngagedChange}
      />
    )
    const { container, rerender } = render(chatWith(false))
    const chat = container.querySelector('.persona-chat') as HTMLElement

    fireEvent.focusIn(screen.getByPlaceholderText('Type a message...'))
    expect(onEngagedChange.mock.calls).toEqual([[true]])
    // Controlled, and the host has not followed: the chat stays folded.
    expect(chat.classList.contains('pc-collapsed')).toBe(true)

    rerender(chatWith(true))
    expect(chat.classList.contains('pc-collapsed')).toBe(false)
    rerender(chatWith(false))
    expect(chat.classList.contains('pc-collapsed')).toBe(true)
  })
})
