import type { ReactElement, ReactNode } from 'react'

export interface PopoverAnchorProps {
  /** The trigger, and the `<Popover>` it opens. */
  children: ReactNode
  /** Concatenated after `hover-popover-anchor`. */
  className?: string
  onMouseLeave?: () => void
}

/**
 * The positioning context a `<Popover>` is measured against — nothing but
 * `position: relative` and the pointer-left handler.
 *
 * It wraps BOTH the trigger and the panel, which is what makes the close
 * delay work: leaving the trigger for the panel does not leave the anchor,
 * so the two elements behave as one hover target rather than a gap the
 * pointer keeps falling through.
 */
export function PopoverAnchor({ children, className, onMouseLeave }: PopoverAnchorProps): ReactElement {
  const cls = className ? `hover-popover-anchor ${className}` : 'hover-popover-anchor'
  return (
    <div className={cls} onMouseLeave={onMouseLeave}>
      {children}
    </div>
  )
}
