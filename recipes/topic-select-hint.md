---
id: 86b4d53c-8122-480c-9a33-43e08b063469
title: TopicSelectHint
domain: agenticdevelopercookbook://ingredients/topic-select-hint
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A centered card prompt for selecting an item from a list when no selection
  is active.
platforms:
- typescript
- web
tags:
- selection
- placeholder
- empty-state
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# TopicSelectHint

## Overview

TopicSelectHint is a centered card component displayed when no selection is active in a list-based UI. It provides context-specific guidance to the user about what to select, using dynamic headline generation based on available metadata (item noun, list title). The component renders a mouse-pointer icon, an optional headline, and optional descriptive content, composited into a Card primitive.

## Behavioral Requirements

- **must-render-card**: Component MUST render a Card element containing an icon, optional headline, and optional descriptive content.
- **must-render-icon**: Component MUST render a mouse-pointer icon (MousePointerClick from lucide-react) inside a circular container.
- **must-use-test-hook**: Component MUST set `data-htd-select-hint` attribute on the root container for test targeting.
- **must-accept-custom-title**: Component MUST render the `title` prop as the headline verbatim when provided, taking precedence over computed headlines.
- **must-compute-headline-from-noun**: Component MUST generate the headline as "Select [article] [noun]" when `noun` is provided and `title` is not, with article matching English grammar (a/an).
- **must-compute-headline-from-list-title**: Component MUST generate the headline as "Select an item from [listTitle]" when `listTitle` is provided, `noun` is not, and `title` is not.
- **must-use-fallback-headline**: Component MUST generate the headline as "Select an item from the list" when none of `title`, `noun`, or `listTitle` are provided, and `selectable` is true.
- **must-append-edit-suffix**: Component MUST append " to view or edit it here." to the computed headline when `selectable` is true and no `children` are provided.
- **must-hide-headline-when-not-selectable**: Component MUST not render a headline when `selectable` is false.
- **must-render-children**: Component MUST render the `children` prop as descriptive content when provided.
- **must-hide-headline-when-empty-list**: Component MUST not render a headline when `selectable` is false (indicating an empty list with nothing to select).
- **must-hide-children-when-not-provided**: Component MUST not render a content section when `children` are not provided.
- **must-center-content**: Component MUST center the card horizontally and vertically within its container.

## Appearance

- **Container**: Flex column, full height and width, centered items, overflow-y auto, 24px padding (p-6)
- **Card**: Maximum width 448px (max-w-md), gap 12px (gap-3), padding 32px horizontal × 40px vertical (px-8 py-10), centered text alignment
- **Icon circle**: 44px (size-11), flexbox centered, rounded full, border 1px (border-apt-border), background apt-surface, text color apt-text-dim
- **Icon**: 20px (size-5) MousePointerClick from lucide-react
- **Headline**: Font weight semibold, line height snug, text color apt-text
- **Description text**: Font size 14px (text-sm), line height relaxed, text color apt-text-muted; strong elements are semibold with apt-text color

## States

| State | Appearance change |
|-------|------------------|
| Default | Card displayed with content as specified |
| Empty list (selectable: false) | Headline hidden, description (children) shown if provided |
| No description | Headline shown, no description section rendered |

## Accessibility

- **Role**: The component uses a semantic `div` container with no explicit ARIA role; it functions as a visual prompt and does not require assistive technology interaction.
- **Icon accessibility**: The icon container has `aria-hidden="true"` to hide it from screen readers, treating it as purely decorative.
- **Headline**: Renders as a semantic text node without explicit label requirement; the text content itself serves as the message.
- **Description**: Rendered as plain text content; strong elements within children are styled but not specially announced.
- **Keyboard navigation**: Component does not capture focus or require keyboard interaction; it is a passive display element.
- **Minimum tap target**: The component is not an interactive control and does not define a tap target; it contains no buttons or clickable elements.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| topic-select-hint-001 | must-render-card, must-render-icon, must-use-test-hook | No props (defaults) | Renders Card with mouse-pointer icon, data-htd-select-hint attribute present, default headline "Select an item from the list to view or edit it here." |
| topic-select-hint-002 | must-accept-custom-title | `title="Custom headline"` | Headline renders as "Custom headline" exactly |
| topic-select-hint-003 | must-compute-headline-from-noun | `noun="workspace"` | Headline renders as "Select a workspace to view or edit it here." |
| topic-select-hint-004 | must-compute-headline-from-noun | `noun="item"` | Headline renders as "Select an item to view or edit it here." |
| topic-select-hint-005 | must-compute-headline-from-list-title | `listTitle="Workspaces"` | Headline renders as "Select an item from Workspaces" |
| topic-select-hint-006 | must-compute-headline-from-noun, must-compute-headline-from-list-title | `noun="workspace"` `listTitle="Workspaces"` | Headline renders as "Select a workspace to view or edit it here." (noun takes precedence) |
| topic-select-hint-007 | must-accept-custom-title | `title="Select a group"` `noun="workspace"` | Headline renders as "Select a group" (title takes precedence) |
| topic-select-hint-008 | must-render-children | `children="Choose one to begin editing."` | Description text is rendered below headline |
| topic-select-hint-009 | must-append-edit-suffix | `noun="site"` (no children) | Headline ends with " to view or edit it here." |
| topic-select-hint-010 | must-append-edit-suffix | `noun="site"` `children="Some description"` | Headline does NOT end with " to view or edit it here." |
| topic-select-hint-011 | must-hide-headline-when-not-selectable | `selectable={false}` | Headline is not rendered, only children (if provided) are shown |
| topic-select-hint-012 | must-hide-headline-when-not-selectable | `selectable={false}` (no children) | Card is rendered but both headline and description sections are hidden |
| topic-select-hint-013 | must-hide-children-when-not-provided | `children={undefined}` | No description section is rendered |
| topic-select-hint-014 | must-center-content | Any props | Component is centered in its container both horizontally and vertically |

## Edge Cases

- **Null/undefined noun with null listTitle**: When neither `noun` nor `listTitle` are provided and `selectable=true`, headline defaults to "Select an item from the list" (optionally with edit suffix).
- **Empty string noun**: If `noun=""` is passed, the article function will still attempt to generate an article; behavior depends on runtime string handling (likely generates "an ").
- **Empty string listTitle**: If `listTitle=""` is passed, headline will render as "Select an item from " (trailing space).
- **null/undefined children**: Component correctly skips rendering the children section entirely when not provided.
- **selectable false with empty children**: Component hides the headline but does not render a fallback; only the icon and optional children are shown.
- **Custom title with selectable false**: Custom `title` is ignored when `selectable=false`; headline is not rendered.
- **Very long noun or listTitle**: Component does not define text truncation; long values will wrap or overflow based on Card max-width constraint.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `title` | ReactNode | undefined | Custom headline text; overrides computed headline |
| `noun` | string | undefined | Singular noun for the selectable item (e.g. "workspace", "site") |
| `listTitle` | string | undefined | Display name of the list; used as fallback when noun not provided |
| `selectable` | boolean | true | Whether the list has items to select; false hides headline and shows only children |
| `children` | ReactNode | undefined | Optional descriptive content (e.g. "What these items are and why to pick one") |

## Deep Linking

Not applicable: TopicSelectHint is a passive display component with no deep linking behavior or navigation support.

## Localization

Not applicable: TopicSelectHint generates its headline dynamically from props but does not provide localization infrastructure. Applications using this component are responsible for translating prop values (noun, listTitle, children) before passing them.

## Accessibility Options

Not applicable: TopicSelectHint does not respond to system accessibility display options (Reduce Motion, Increase Contrast, Differentiate Without Color). The component renders static content with no animations or color-dependent information.

## Feature Flags

Not applicable: TopicSelectHint does not define or consume feature flags; it is always enabled.

## Analytics

Not applicable: TopicSelectHint does not emit analytics events. Applications using this component may track when it is displayed, but the component itself provides no instrumentation.

## Privacy

Not applicable: TopicSelectHint does not collect, store, or transmit any data. It renders static UI based on props provided by the application.

## Logging

Not applicable: TopicSelectHint does not emit log events or debug output.

## Platform Notes

- **React/Web**: Implemented in `packages/web/packages/ui/src/blocks/topic-select-hint.tsx`. Uses Tailwind CSS classes and lucide-react for the icon. Composed from the Card primitive. The component is a "use client" directive (Client Component in Next.js). Headline generation uses a custom `article()` helper function for English article selection (a/an).
- **SwiftUI**: Adapt from SwiftUI's VStack and HStack for centering. Use SF Symbols (e.g., `"arrowshape.turn.up.circle"` or equivalent pointer/cursor icon) instead of lucide-react. Compose with a local Card equivalent or SwiftUI's built-in container shapes.
- **Compose**: Use Compose's Column (vertically centered) and Row (icon circle). A Material 3 Card or ElevatedCard for the container. Use Compose Material icons (e.g., `Icons.Default.TouchApp` or custom pointer icon). Apply Compose Modifier chains for sizing, padding, and text styling.
- **AppKit / UIKit**: Use NSStackView (AppKit) or UIStackView (UIKit) for layout. NSImageView or UIImageView with an appropriately sized system or custom pointer icon. NSTextView or UILabel for headline and description. Position the Card in a centered view controller or container view. Apply Auto Layout constraints for centering.
- **WinUI 3**: Use Grid with HorizontalAlignment and VerticalAlignment set to Center. A Border or Card control (from WinUI 3 or a custom control library) for the card container. An Image or IconElement control for the pointer icon (e.g., system icon or custom asset). TextBlock controls for headline and description. Apply grid Row and Column properties for layout; use StackPanel or RelativePanel for nested alignment.

## Design Decisions

- **Headline precedence (title > noun > listTitle > default)**: The hierarchy allows maximum flexibility — a custom title can override computed headlines entirely, while the noun provides specificity. This design prioritizes application control over component magic.
- **Append edit suffix only without children**: The suffix " to view or edit it here." is added to computed headlines when no `children` are provided. When descriptive copy is present, the suffix is omitted to avoid redundancy. This keeps the interface concise and avoids duplicate messaging.
- **Icon is always decorative (aria-hidden)**: The mouse-pointer icon is semantically decorative and conveys no essential information beyond visual guidance. Marking it `aria-hidden` prevents assistive technology from announcing it redundantly with the headline text.
- **No headline when selectable is false**: When the list is empty (`selectable=false`), the headline is hidden because there is nothing to select. The optional `children` prop allows the component to still display explanatory text (e.g., "No workspaces yet. Create one to get started.") without the false call to action.
- **Card max-width constraint (max-w-md)**: The 448px maximum width keeps the component readable and prevents it from sprawling on very wide screens. This is a responsive affordance, not a hard constraint.
- **Tailwind-based styling**: All appearance properties (colors, sizes, spacing) are expressed as Tailwind classes, making the component portable to any Tailwind-configured project. The design tokens (apt-border, apt-surface, apt-text, apt-text-dim, apt-text-muted) must be defined in the host project's Tailwind config.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| Source code traceability | Passed | All requirements traced to source code |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
