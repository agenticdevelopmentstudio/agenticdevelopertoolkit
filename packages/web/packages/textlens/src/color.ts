/** A colour reduced to the three channels the lens interpolates. */
export type Rgb = readonly [number, number, number]

const RGB_FUNCTION = /^rgba?\(\s*(-?[\d.]+)[\s,]+(-?[\d.]+)[\s,]+(-?[\d.]+)/i

function triple(values: readonly (number | undefined)[]): Rgb | null {
  const [r, g, b] = values
  if (r === undefined || g === undefined || b === undefined) return null
  if (Number.isNaN(r) || Number.isNaN(g) || Number.isNaN(b)) return null
  return [r, g, b]
}

function parseHex(digits: string): Rgb | null {
  // #rgb / #rgba — each digit doubled; #rrggbb / #rrggbbaa — alpha ignored.
  const pairs =
    digits.length === 3 || digits.length === 4
      ? Array.from(digits.slice(0, 3), (digit) => `${digit}${digit}`)
      : digits.length === 6 || digits.length === 8
        ? [digits.slice(0, 2), digits.slice(2, 4), digits.slice(4, 6)]
        : null
  if (!pairs) return null
  return triple(pairs.map((pair) => Number.parseInt(pair, 16)))
}

/**
 * Parse a hex or `rgb()`/`rgba()` colour into channels. Alpha is dropped —
 * the lens interpolates a text colour along a line, and a translucent glyph
 * would blend with whatever it is passing over rather than with the ramp.
 *
 * Returns `null` for anything else (named colours, `hsl()`, `color()`), which
 * `resolveColor` turns into a thrown error naming the offending value.
 */
export function parseColor(value: string): Rgb | null {
  const input = value.trim()
  if (input.startsWith('#')) return parseHex(input.slice(1))

  const match = RGB_FUNCTION.exec(input)
  if (!match) return null
  const [, r, g, b] = match
  return triple([r, g, b].map((raw) => (raw === undefined ? Number.NaN : Number.parseFloat(raw))))
}

/**
 * Resolve a lens colour against an element.
 *
 * A value beginning `--` is read as a CSS custom property off that element's
 * computed style, which is the point of this function: the ramp then has one
 * definition, in the stylesheet, instead of a second copy of the palette
 * hardcoded in JavaScript that goes quietly stale the next time the theme
 * changes.
 *
 * Throws rather than falling back to a default. A lens tinting toward the
 * wrong colour is exactly the kind of failure that survives review, so an
 * unresolvable value is worth a stack trace on the first frame.
 */
export function resolveColor(value: string, element: Element): Rgb {
  const requested = value.trim()
  const literal = requested.startsWith('--')
    ? getComputedStyle(element).getPropertyValue(requested).trim()
    : requested

  const parsed = literal === '' ? null : parseColor(literal)
  if (parsed) return parsed

  const via = requested === literal ? '' : ` (resolved to ${JSON.stringify(literal)})`
  throw new Error(
    `textlens: cannot read ${JSON.stringify(requested)}${via} as a colour. ` +
      'Give a hex or rgb() value, or a custom property that holds one.',
  )
}
