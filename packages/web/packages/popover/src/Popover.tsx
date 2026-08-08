import type { ReactElement, ReactNode } from 'react'

export type PopoverPlacement = 'top' | 'bottom'

export interface PopoverProps {
  /** Whether the panel is showing. */
  open: boolean
  children: ReactNode
  /** Which side of the anchor the panel sits on, and therefore which way the arrow points. Default `top`. */
  placement?: PopoverPlacement
  /** Concatenated after the package's own classes, for skinning. */
  className?: string
  onMouseEnter?: () => void
  onMouseLeave?: () => void
}

/**
 * The panel half of a hover popover: positioned against its
 * `<PopoverAnchor>`, with the arrow that points back at the trigger and the
 * invisible bridge that spans the gap between the two.
 *
 * It is rendered whether or not it is open, and hidden with `opacity` +
 * `visibility` rather than unmounted. That is deliberate and load-bearing:
 * an unmounted panel is absent from the server-rendered HTML, so its content
 * would exist only for a reader with a pointer and JavaScript. Everything
 * inside a popover is in the document from the first byte.
 *
 * The paint (surface, border, radius, shadow) and the geometry (width, gap,
 * arrow size) are all custom properties declared on `.hover-popover` — see
 * css/base.css. Override them on your own selector rather than restating the
 * rules, so the arrow keeps matching the panel it grows out of.
 */
export function Popover({
  open,
  children,
  placement = 'top',
  className,
  onMouseEnter,
  onMouseLeave,
}: PopoverProps): ReactElement {
  const cls = [
    'hover-popover',
    `hover-popover--${placement}`,
    open ? 'hover-popover--open' : '',
    className,
  ]
    .filter(Boolean)
    .join(' ')

  return (
    <div className={cls} onMouseEnter={onMouseEnter} onMouseLeave={onMouseLeave}>
      {children}
    </div>
  )
}
