---
id: f5d2eb1c-fb0e-48e3-b124-7e730ac8231c
title: MarkdownQuickReference
domain: agenticdevelopertoolkit://recipes/markdown-quick-reference
type: ingredient
version: 1.2.0
status: review
language: en
created: '2026-06-26'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: "An outline-button toolbar control that opens a dismissible popover listing common markdown syntax (headings, bold/italic, code, lists, links, quote)."
platforms:
  - typescript
  - web
tags:
  - markdown
  - popover
  - help
  - reference
  - toolbar
depends-on:
  - agenticdevelopertoolkit://recipes/button
related:
  - agenticdevelopertoolkit://recipes/markdown-editor
references: []
approved-by: ''
approved-date: ''
---

# MarkdownQuickReference

## Overview

A standalone toolbar control in `@agenticdevelopertoolkit/ui`
(`components/markdown-quick-reference`). It renders an outline `Button` that
opens a dismissible `Popover` listing the common GitHub-flavoured markdown
syntax — headings, bold/italic, inline + fenced code, bullet/numbered lists,
links, and blockquote.

It is built on the shared `Popover` primitive, so it inherits outside-click and
Escape dismissal plus focus restore to the trigger. It is wired into the
`MarkdownEditor` toolbar by default, but is exported on its own so any editor
toolbar can drop it in. It holds no state of its own and takes no value.

## Behavioral Requirements

- **must-render-labelled-trigger**: The control MUST render a single `Button`
  trigger whose accessible name is `Markdown quick reference`, regardless of the
  visible trigger text.
- **must-start-closed**: The control MUST NOT render the reference content until
  the trigger is activated (the popover starts closed).
- **must-open-on-trigger**: The control MUST open the popover and reveal the
  reference content when the trigger is activated (click or keyboard).
- **must-list-common-syntax**: The open popover MUST list, at minimum, headings,
  bold, italic, inline code, fenced code block, bullet list, numbered list,
  link, and blockquote — each as a label paired with its literal markdown
  snippet.
- **must-dismiss-on-escape**: The control MUST close the popover when Escape is
  pressed while it is open.
- **must-dismiss-on-outside-click**: The control MUST close the popover when a
  pointer interaction occurs outside it.
- **must-restore-focus**: The control MUST return focus to the trigger when the
  popover closes.
- **must-honor-custom-trigger-label**: The control MUST render `triggerLabel` as
  the visible trigger text while keeping the fixed `Markdown quick reference`
  accessible name.

## Appearance

```
┌ trigger ─────────┐
│ [▮] Markdown     │  ← outline Button (size sm), BookText icon + label
└──────────────────┘
        ▼ on open (popover, side=bottom align=end, w-80)
  ┌──────────────────────────────────────┐
  │ MARKDOWN QUICK REFERENCE              │  ← mono uppercase caption
  │ Headings     # H1 / ## H2 / ### H3    │  ← <dl>: term | <code> snippet
  │ Bold         **bold text**            │
  │ Italic       _italic text_            │
  │ Inline code  `inline code`            │
  │ Code block   ```ts … ```              │
  │ Bullet list  - one / - two            │
  │ Numbered     1. one / 2. two          │
  │ Link         [label](https://url)     │
  │ Blockquote   > quoted text            │
  └──────────────────────────────────────┘
```

- Trigger: shared `Button` via `buttonVariants({ variant: "outline", size: "sm" })`
  with a leading `BookText` icon (`data-icon="inline-start"`).
- Popover surface: the shared `PopoverContent` (`bg-apt-surface`,
  `border-apt-border`, `text-apt-text`), widened to `w-80`.
- Caption: `font-mono text-[0.7rem] uppercase tracking-wider text-apt-text-muted`.
- Rows: a two-column `<dl>` — `<dt>` label in `text-apt-text-muted`, `<dd>` a
  `whitespace-pre-wrap` mono `<code>` in `text-apt-text`.
- Tokens only: no raw hex, no arbitrary colors, no `!important`.

## States

| State | Appearance change |
|---|---|
| Closed (default) | Only the outline trigger button is shown; no popover content in the DOM |
| Trigger hover/focus | Standard outline-Button hover + gold focus ring (`focus-visible`) |
| Open | `aria-expanded="true"` on the trigger; the portalled popover lists the syntax |
| Dismissed (Escape / outside-click) | Popover unmounts; focus returns to the trigger |

## Accessibility

- The trigger is a real `<button>` with `aria-label="Markdown quick reference"`,
  so the accessible name is stable even when the visible label changes.
- Open/closed state is conveyed via the Popover's `aria-expanded` /
  `aria-controls` wiring on the trigger (from the shared primitive).
- Escape closes the popover; focus is restored to the trigger (handled by the
  shared `Popover`).
- The reference content is a semantic `<dl>` (term/description pairs), so the
  label↔snippet relationship is exposed to assistive tech.
- Content is reference-only (no focusable controls), so there is no focus trap to
  manage beyond the primitive's defaults.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|---|---|---|---|
| T1 | must-render-labelled-trigger, must-start-closed | Render the control | One button named `Markdown quick reference`; no `Markdown quick reference` caption text in the DOM |
| T2 | must-open-on-trigger, must-list-common-syntax | Click the trigger | The popover shows the caption plus `Headings`, `Bold`, `Inline code`, `Code block`, `Link`, `Blockquote` |
| T3 | must-dismiss-on-escape, must-restore-focus | Open, then press Escape | The popover content is removed; focus returns to the trigger |
| T4 | must-honor-custom-trigger-label | Render with `triggerLabel="Syntax"` | The trigger shows `Syntax` but is still named `Markdown quick reference` |

## Edge Cases

- The syntax list is a fixed, hard-coded reference (no props feed it), so the
  content never varies between consumers — one authoritative cheatsheet.
- Fenced-code and list snippets contain newlines; the `<code>` uses
  `whitespace-pre-wrap` so multi-line snippets render literally.
- `side` / `align` are forwarded to the popover positioner; near a viewport edge
  the shared primitive flips/clamps the popover to stay on screen.
- Re-opening after dismissal re-mounts fresh content (the control is stateless).

## Configuration

`@agenticdevelopertoolkit/ui/components/markdown-quick-reference`

| Option | Type | Default | Description |
|---|---|---|---|
| `side` | `PopoverContentProps["side"]` | `"bottom"` | Popover placement side |
| `align` | `PopoverContentProps["align"]` | `"end"` | Popover alignment along the side |
| `triggerLabel` | `ReactNode` | `"Markdown"` | Visible text on the trigger button |
| `className` | `string` | — | Extra classes on the trigger button |

```ts
type PopoverContentProps = React.ComponentProps<typeof PopoverContent>

export function MarkdownQuickReference(props: {
  side?: PopoverContentProps["side"]
  align?: PopoverContentProps["align"]
  triggerLabel?: React.ReactNode
  className?: string
}): React.ReactElement
```

## Deep Linking

Not applicable: this is a reusable UI primitive exported for toolbar integration and does not participate in app routing or deep linking.

## Localization

Not applicable: all user-facing strings are hard-coded in the component (`"Markdown quick reference"` as aria-label, `"Markdown"` as default trigger text) and are not localized per source.

## Accessibility Options

Not applicable: this is a lightweight reference popover that inherits focus management and keyboard dismissal from the shared `Popover` primitive. Consumers may wrap it with accessibility option handlers (e.g., reduce motion) if needed.

## Feature Flags

Not applicable: this ingredient is a reusable UI component and is not gated by feature flags.

## Analytics

Not applicable: this ingredient is presentational. Consumers may instrument trigger activation and popover interactions in their own event tracking systems.

## Privacy

Not applicable: this component collects no data, performs no network requests, and stores no persistent state.

## Logging

This ingredient is presentational and emits no structured log events. Opening or
dismissing the reference is local UI state and is not reported to the consumer.

## Platform Notes

- **React / Web (TypeScript)**: Component at `packages/web/packages/ui/src/components/markdown-quick-reference.tsx`, built on the shared `Popover` + `Button` primitives. Re-exports `SyntaxQuickReference` composed with the authoritative `MARKDOWN_SYNTAX` array. Demo lives in `ui-showcase` (Overlays group); re-run `gen-sources.py` after edits.
- **SwiftUI**: Start with a `Popover` anchored to a `Button` trigger. The reference list renders as a scrollable container of label–snippet pairs, each pair using a two-column layout (label on the left in secondary foreground color, snippet on the right in monospace font `Font.system(.body, design: .monospaced)`). Dismissal via the popover's auto-dismiss on outside tap and keyboard handling with `.onKeyPress(.escape)`.
- **Compose**: Start with a Material Design 3 `Popover` (or `DropdownMenu` for a simpler alternative) anchored to an `IconButton` trigger. Render the syntax list as a `LazyColumn` of rows, each holding a label and a monospace code snippet using `fontFamily = FontFamily.Monospace`. Dismissal is handled by tapping outside the popover or pressing Escape.
- **AppKit / UIKit**: macOS uses an `NSPopover` anchored to the trigger button in the toolbar; iOS 16+ uses a `UIMenu` with child actions for each syntax item. On both platforms, render the list as a scrollable container with term–snippet pairs displayed in rows. Use monospace fonts (macOS: `NSFont(name: "Monaco", size: 11)`, iOS: `UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)`). Dismissal on outside tap (Popover) or menu selection (UIMenu).
- **WinUI 3**: Start with a `Flyout` or `TeachingTip` anchored to the trigger `Button` and opened via `Flyout.ShowAt(sender)`. Render the syntax reference as an `ItemsRepeater` or `Grid` within the Flyout, with rows containing a `TextBlock` pair (label and snippet), both in monospace `FontFamily="Cascadia Mono"`. Light-dismiss is built-in; map web outside-click dismissal to `Flyout.IsLightDismissEnabled="true"` and Escape key dismissal to the Flyout's keyboard handling.

## Design Decisions

- **Decision**: The syntax list is hard-coded inside the component rather than a
  prop. **Rationale**: It is a fixed reference; a single authoritative cheatsheet
  (DRY) is better than letting each consumer pass a divergent list.
- **Decision**: Built on the shared `Popover` (not a bespoke overlay or the modal
  `Dialog`). **Rationale**: Reuse the platform dismissal + focus-restore behavior;
  a lightweight, non-modal reference should not trap focus or dim the page.
- **Decision**: A fixed `aria-label` independent of `triggerLabel`. **Rationale**:
  Keeps the accessible name stable for tests and assistive tech even when a
  consumer shortens the visible label.

## Compliance

| Check | Status | Category |
|---|---|---|
| Artifact formatting (ingredient) | passed | artifact-formatting |
| UI guidelines — no raw hex, no `!important`, apt-* tokens | passed | adh-ui-guidelines |
| Reuse-first — built on shared Popover + Button | passed | adh-ui-guidelines |

## Change History

| Version | Date | Author | Summary |
|---|---|---|---|
| 1.2.0 | 2026-09-22 | Claude Haiku 4.5 | Rewrite Platform Notes with concrete translation guidance for SwiftUI, Compose, AppKit/UIKit, and WinUI 3 |
| 1.1.0 | 2026-09-22 | Claude Haiku 4.5 | Update domain URI, fill all template sections with "Not applicable" explanations where no source implementation exists, correct status to review |
| 1.0.0 | 2026-06-26 | Mike Fullerton | Initial recipe for the shared markdown quick-reference popover (contract c11) |
