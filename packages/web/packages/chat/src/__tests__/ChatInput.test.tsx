import { describe, it, expect, vi } from 'vitest'
import { render, screen, fireEvent } from '@testing-library/react'
import { ChatInput, submitChatInput } from '../components/ChatInput'

describe('ChatInput', () => {
  it('draws its send button by default', () => {
    render(<ChatInput onSend={() => {}} />)
    expect(screen.getByRole('button', { name: 'Send' })).toBeInTheDocument()
  })

  it('leaves the send button out when told to, and Enter still sends', () => {
    const onSend = vi.fn()
    render(<ChatInput onSend={onSend} sendButton={false} />)
    expect(screen.queryByRole('button', { name: 'Send' })).toBeNull()
    const input = screen.getByRole('textbox', { name: 'Message' })
    fireEvent.change(input, { target: { value: 'hi' } })
    fireEvent.keyDown(input, { key: 'Enter' })
    expect(onSend).toHaveBeenCalledWith('hi')
  })
})

describe('submitChatInput', () => {
  it("sends the composer's text through the form and clears it", () => {
    const onSend = vi.fn()
    const { container } = render(<ChatInput onSend={onSend} sendButton={false} />)
    const input = screen.getByRole<HTMLInputElement>('textbox', { name: 'Message' })
    fireEvent.change(input, { target: { value: '  hello  ' } })
    expect(submitChatInput(container)).toBe(true)
    expect(onSend).toHaveBeenCalledWith('hello')
    expect(input.value).toBe('')
  })

  it('sends nothing from an empty or disabled box, or with no composer', () => {
    const onSend = vi.fn()
    const { container, rerender } = render(<ChatInput onSend={onSend} />)
    fireEvent.change(screen.getByRole('textbox'), { target: { value: '   ' } })
    expect(submitChatInput(container)).toBe(false)
    rerender(<ChatInput onSend={onSend} disabled />)
    fireEvent.change(screen.getByRole('textbox'), { target: { value: 'x' } })
    expect(submitChatInput(container)).toBe(false)
    expect(submitChatInput(document.createElement('div'))).toBe(false)
    expect(submitChatInput(null)).toBe(false)
    expect(onSend).not.toHaveBeenCalled()
  })
})
