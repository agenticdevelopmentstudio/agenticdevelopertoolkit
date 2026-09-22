---
id: f1c3b5e7-9d2a-4f8c-a3c1-7e2f5b9c6d4a
title: Tree Rows
domain: agenticdevelopercookbook://ingredients/tree-rows
type: ingredient
version: 1.1.0
status: review
language: en
created: 2026-09-22
modified: 2026-09-22
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Hierarchical row display for nested parent-child relationships in tables
  and lists, exposing nesting depth and collapse-expand affordance.
platforms:
- typescript
- web
tags:
- tree
- hierarchy
- nested-rows
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Tree Rows

## Overview

Tree Rows exposes the nesting structure of hierarchical data within a flat row list. It exports a flatten algorithm that converts parent-child relationships into display order with depth metadata, a helper to compute ancestor expansion paths, and a visual row label component that renders indentation and a collapse-expand toggle. This allows tables, lists, and card grids to display hierarchy without becoming a new component — all existing column logic, sorting, selection, and keyboard behavior remain unchanged.

## Behavioral Requirements

- **must-flatten-parent-child-forest**: The flatten algorithm MUST accept a flat array of rows and output them in display order with depth and hierarchy metadata.
- **must-order-by-roots-first**: The algorithm MUST place root nodes (those without a parent in the input) at depth 0, in the order they appear in the input.
- **must-order-depth-first**: The algorithm MUST order siblings of each parent in the input order unless a sort comparison function is provided.
- **must-sort-if-provided**: If a comparison function is provided in options, the algorithm MUST sort both roots and all sibling groups according to that function.
- **must-treat-orphans-as-roots**: A row whose `parentId()` result is not present in the input (filtered out, deleted, or missing) MUST be treated as a root at depth 0.
- **must-handle-self-parenting**: A row that is parented to itself MUST be treated as a root.
- **must-handle-cycles**: Rows that form a cycle (a→b→c→a) and are not reached by the depth-first descent MUST be surfaced at depth 0 in input order.
- **must-surface-every-row-exactly-once**: The output MUST contain every row from the input exactly once, in some order. No row MUST be dropped.
- **must-track-children-availability**: For each output row, a boolean `hasChildren` MUST indicate whether that row has any immediate children, regardless of expansion state.
- **must-compute-ancestor-path**: The `ancestorIds()` function MUST return the set of all ancestor IDs between a target ID and the root, given a list of rows and ID/parentId accessors.
- **must-halt-ancestor-search-at-cycle**: The `ancestorIds()` function MUST terminate if a parent is already in the result set (preventing infinite loops in malformed data).
- **must-halt-ancestor-search-at-missing-parent**: The `ancestorIds()` function MUST terminate if a parent ID is not present in the input.
- **must-render-label-span**: `TreeRowLabel` MUST render a `<span>` element containing indent, toggle (or spacer), and children.
- **must-indent-with-ems**: The label MUST apply inline padding based on depth: `depth * 1.25em`.
- **must-render-toggle-button-if-children**: If `hasChildren` is true, the label MUST render a button for toggling expansion.
- **must-render-spacer-if-no-children**: If `hasChildren` is false, the label MUST render a spacer element of identical width to the button (to align content).
- **must-show-toggle-icon**: The toggle button MUST display a chevron icon (ChevronRight from lucide-react, 14px).
- **must-rotate-icon-when-expanded**: When `expanded` is true, the chevron MUST be rotated 90 degrees.
- **must-call-onToggle-on-click**: Clicking the toggle button MUST call the `onToggle()` callback without arguments.
- **must-set-aria-label-on-toggle**: The toggle button MUST have an `aria-label` attribute with the text "Expand {label}" or "Collapse {label}" depending on `expanded`.
- **must-set-aria-expanded-on-toggle**: The toggle button MUST have an `aria-expanded` attribute reflecting the current `expanded` boolean.
- **must-provide-title-on-toggle**: The toggle button MUST have a `title` attribute (tooltip) matching the `aria-label`.
- **must-use-flex-layout-in-label**: The label MUST use flexbox (`display: flex`) with centered items and `gap-1` spacing.
- **must-allow-shrinking-toggle**: The toggle button MUST have `flex-shrink: 0` to prevent compression.
- **must-allow-content-to-wrap-or-overflow**: The label MUST apply `min-w-0` to manage flex overflow and allow content to truncate.
- **must-accept-custom-classname**: `TreeRowLabel` MUST accept an optional `className` prop that is merged with the default classes.
- **must-accept-children-prop**: `TreeRowLabel` MUST render the `children` prop as content after the toggle/spacer.

## Appearance

- **Indent spacing**: `1.25em` per nesting level (computed inline as `depth * 1.25em` padding-inline-start).
- **Toggle button**: Minimal styling with no visible background by default; becomes visible on hover or focus.
- **Toggle size**: 14px chevron icon.
- **Toggle button padding**: `0.5em` (`p-0.5` in Tailwind).
- **Toggle button border-radius**: `rounded` (platform default, typically 0.375rem).
- **Toggle text color**: `text-apt-text-muted` by default, `text-apt-text` on hover.
- **Toggle focus ring**: `focus-visible:ring-2 focus-visible:ring-apt-gold/40` (gold ring with 40% opacity).
- **Toggle transition**: Icon rotation uses `transition-transform`.
- **Spacer size**: Matches button box exactly (14px icon + padding).
- **Flex layout**: Items centered vertically with `gap-1` (0.25rem) between toggle and content.
- **Min-width constraint**: Label applies `min-w-0` to manage flex item truncation.

## States

| State | Appearance change |
|-------|------------------|
| Default (collapsed) | Chevron points right; toggle text reads "Expand {label}". |
| Expanded | Chevron rotated 90 degrees to point down; toggle text reads "Collapse {label}". |
| Leaf (no children) | Toggle button is absent; spacer element preserves layout. |
| Hover (toggle button) | Toggle text color changes from `text-apt-text-muted` to `text-apt-text`. |
| Focus (toggle button) | Focus ring appears: `ring-2 ring-apt-gold/40`. |

## Accessibility

- **Role**: The toggle button is a native `<button>` with `type="button"`.
- **Aria-label**: Required. The button announces "Expand {label}" or "Collapse {label}" to screen readers.
- **Aria-expanded**: Required. The button sets `aria-expanded` to true or false reflecting the current state.
- **Title attribute**: Required. Provides tooltip text matching the aria-label for keyboard users and hover.
- **Label requirement**: Caller MUST pass a descriptive `label` prop (e.g., row title or data) so the toggle can announce which item is being toggled.
- **Leaf indication**: Leaves MUST render a spacer instead of a disabled toggle, so screen readers perceive the layout alignment without an interactive element.
- **Focus visibility**: The button MUST have visible focus indication (ring on focus-visible).
- **Keyboard interaction**: The toggle button is a native button and MUST be keyboard accessible (Enter/Space to activate).
- **No role on label span**: The outer `<span>` is a layout container only and carries no `role` or semantic meaning.
- **Aria-hidden on spacer**: The spacer span MUST have `aria-hidden="true"` to prevent screen readers from announcing empty placeholder content.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| tree-001 | must-flatten-parent-child-forest | Flat array of 3 rows: root A, root B, child of A | Output: A (depth 0), A's child (depth 1), B (depth 0). |
| tree-002 | must-order-by-roots-first, must-order-depth-first | Array: [child of 'missing', root C, root A, child of A] | Output: child-of-missing (depth 0, orphan), C (depth 0), A (depth 0), child-of-A (depth 1). |
| tree-003 | must-treat-orphans-as-roots | Array: [row with parentId='not-in-list', row with id='not-in-list', their sibling] | Orphan appears at depth 0, not dropped. |
| tree-004 | must-sort-if-provided | Array of 3 root rows and a compare function sorting by a custom field | All roots are sorted per the compare function. |
| tree-005 | must-handle-cycles | Array: [row A parented to B, row B parented to A, row C with no parent] | A and B are not reached by descent from C; they are surfaced at depth 0 in input order. |
| tree-006 | must-handle-self-parenting | Array: [row with id='X' and parentId='X', root Y] | Row X is treated as a root at depth 0. |
| tree-007 | must-surface-every-row-exactly-once | Array with mixed hierarchy and cycles | Output length equals input length; each row appears once. |
| tree-008 | must-track-children-availability | Array: [root A with child B, root C with no children] | A has hasChildren=true; C has hasChildren=false; B has hasChildren=false. |
| tree-009 | must-compute-ancestor-path | Rows: A (root), B (parent A), C (parent B); focusId='C' | `ancestorIds()` returns {'A', 'B'}. |
| tree-010 | must-halt-ancestor-search-at-cycle | Rows forming cycle A→B→A; focusId='A' | `ancestorIds()` terminates and returns the set of reached ancestors without infinite loop. |
| tree-011 | must-render-label-span | TreeRowLabel with depth=1, hasChildren=true, label='Item', children=<span>Content</span> | Renders a span with flex layout, padding-inline-start: 1.25em, a button, and the children span. |
| tree-012 | must-indent-with-ems | TreeRowLabel with depth=2 | Rendered span has style `paddingInlineStart: 2.5em`. |
| tree-013 | must-render-toggle-button-if-children | TreeRowLabel with hasChildren=true | Button element is present. |
| tree-014 | must-render-spacer-if-no-children | TreeRowLabel with hasChildren=false | Spacer span is present; button is absent. |
| tree-015 | must-show-toggle-icon | TreeRowLabel with hasChildren=true | ChevronRight icon (14px) is rendered inside the button. |
| tree-016 | must-rotate-icon-when-expanded | TreeRowLabel with expanded=true | Icon has `rotate-90` class. |
| tree-017 | must-call-onToggle-on-click | TreeRowLabel with mock onToggle callback; click the button | onToggle() is called exactly once. |
| tree-018 | must-set-aria-label-on-toggle | TreeRowLabel with expanded=false, label='Folder' | Button aria-label is "Expand Folder". |
| tree-019 | must-set-aria-expanded-on-toggle | TreeRowLabel with expanded=true | Button aria-expanded is "true". |
| tree-020 | must-provide-title-on-toggle | TreeRowLabel with expanded=false, label='Folder' | Button title attribute is "Expand Folder". |
| tree-021 | must-accept-custom-classname | TreeRowLabel with className="custom-class" | Rendered span includes "custom-class" in its className. |
| tree-022 | must-accept-children-prop | TreeRowLabel with children=<strong>Bold text</strong> | Strong element is rendered after the toggle/spacer. |

## Edge Cases

- **Empty input**: If the input rows array is empty, `flattenTree()` returns an empty array.
- **Single root, no children**: Input is a single row with no parent; output is a single TreeRow at depth 0 with hasChildren=false.
- **Null or undefined parentId**: If `parentId()` returns null or undefined for any row, that row is treated as a root.
- **Duplicate IDs**: If two rows have the same ID, only the first encountered is mapped in the ID index; subsequent rows with the same ID are treated as orphans (roots). This behavior is not protected against and may produce unexpected results.
- **Very deep nesting (10+ levels)**: The algorithm MUST handle arbitrary nesting depth. At 10 levels, indent is 12.5em; at 20 levels, 25em. No depth limit is enforced.
- **Large input (1000+ rows)**: The algorithm uses a single O(n) pass to build the index and a single depth-first walk. Scalability is linear in row count.
- **All rows are orphans**: If all rows have missing parents, all are treated as roots and rendered at depth 0.
- **Mixed cycles and valid hierarchy**: Rows in valid chains are reachable and rendered in depth-first order. Rows in cycles are detected at the end and surfaced at depth 0.
- **Expansion set does not match input**: If `expanded` Set contains IDs not in the input, they are ignored. If it omits IDs that are in the input, those rows are treated as collapsed.
- **Label prop is empty string**: `TreeRowLabel` MUST still render; aria-label becomes "Expand " or "Collapse " (with trailing space).
- **TreeRowLabel with depth=0**: Indent is 0 (no padding); toggle and content align to the left edge.
- **TreeRowLabel with negative depth**: The code does not validate depth; negative depths result in negative padding-inline-start, which is likely unintended. Caller is responsible for non-negative depth.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `id` | `(row: T) => string` | Required | Accessor function that returns a unique string ID for each row. |
| `parentId` | `(row: T) => string \| null \| undefined` | Required | Accessor function that returns the ID of the row's parent, or null/undefined for roots. |
| `expanded` | `ReadonlySet<string>` | Omit (expand all) | Set of parent row IDs whose children SHOULD be shown. If omitted, all rows are expanded. |
| `compare` | `(a: T, b: T) => number` | Omit (input order) | Comparison function to sort roots and sibling groups. If omitted, input order is preserved. |

## Deep Linking

Not applicable: Tree Rows is a UI primitive for table and list display, not a navigable destination.

## Localization

Not applicable: Tree Rows contains no user-facing strings beyond the dynamic aria-label, which is constructed from the caller's `label` prop and the English words "Expand" and "Collapse".

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | The component applies `transition-transform` to the chevron icon rotation but does not query `prefers-reduced-motion`; the animation plays regardless of the user's motion preference. NEEDS REVIEW: Animation should disable or shorten under Reduce Motion; confirm implementation. |
| Increase Contrast | Focus ring color and hover state text color MUST use the `apt-gold` and `apt-text` tokens. NEEDS REVIEW: Confirmation that these tokens meet required WCAG contrast ratios. |
| Differentiate Without Color | Toggle state is communicated by aria-expanded, title, and icon rotation (visual), not by color alone. Focus is indicated by a ring, not color. |

## Feature Flags

Not applicable: Tree Rows is a low-level component library export with no runtime feature flags.

## Analytics

Not applicable: Tree Rows is a UI primitive with no built-in event tracking.

## Privacy

Not applicable: Tree Rows does not collect, store, or transmit any user data.

## Logging

Not applicable: Tree Rows does not emit logs.

## Platform Notes

- **React/Web**: Source is `packages/web/packages/ui/src/components/tree-rows.tsx`. Exports `flattenTree()`, `ancestorIds()`, `TreeRowLabel` component, and `TreeRow<T>` interface. Uses Tailwind CSS classes for styling and Lucide React for the ChevronRight icon. The label is a styled `<span>` with a native `<button>` toggle; no custom components required. The component uses React hooks (`React.ReactNode`, `React.ReactElement`) and accepts standard React props.

- **SwiftUI**: A tree-flattening algorithm is feasible in Swift using similar logic (depth-first descent with cycle detection). The visual affordance would use a SwiftUI `HStack` for layout, a `Button` for toggle, a `Spacer` for leaf alignment, and an `Image` for the chevron icon. Styling would use SwiftUI's `.padding()`, `.rotationEffect()` for icon rotation, and accessibility modifiers (`.accessibilityLabel()`, `.accessibilityValue()`). Respect `@Environment(\.legibilityWeight)` and `\.accessibilityReduceMotion` to adapt rotation transitions.

- **Compose (Kotlin/Android)**: A tree-flattening algorithm is feasible as a standalone utility function. The row label would use `Row` for layout with `Modifier.padding()` for indent, an `IconButton` for toggle, a `Spacer` for leaf alignment, and an `Icon` for the chevron. Accessibility is set via `Modifier.semantics()` and `contentDescription` on the button. Use `LocalDensity.current.run { density -> ... }` to compute contrast and respect motion preferences via platform accessibility settings.

- **AppKit / UIKit**: A tree-flattening algorithm is feasible as a pure Swift function. The row label would be a `UIView` subclass or SwiftUI view wrapping `NSView`/`UIView`, with a `UIButton`/`NSButton` for toggle, a `UIView`/`NSView` for the spacer, and an `UIImageView`/`NSImageView` for the chevron. Layout would use Auto Layout or SwiftUI constraints. Query `UIAccessibility.isReduceMotionEnabled` to conditionally disable chevron rotation animation.

- **WinUI 3**: A tree-flattening algorithm is feasible in C#. The row label would use a `StackPanel` (Horizontal) for layout, a `Button` for toggle, a `Border` or empty `Grid` for the spacer (to match button size), and an icon glyph (e.g., Segoe MDL2 ChevronRight) for the chevron. Indentation is applied via `Margin` or `Padding` on the StackPanel. Accessibility is set via `AutomationProperties.Name` and `AutomationProperties.AutomationId` on the button. Toggle state is communicated via `ToggleButton` or a custom button with binding to `IsPressed`; rotation of the chevron can be achieved via `RotateTransform` in a storyboard or code-behind. Respect `UISettings.AnimationsEnabled` to conditionally disable rotation animation.

## Design Decisions

- **Orphan handling**: Orphans are surfaced as roots rather than dropped. This decision prioritizes visibility over strict hierarchy correctness — a user's view will not silently lose rows due to missing parents. The tradeoff is that inconsistent parentId mappings become visible in the UI.

- **Cycle detection**: Cycles are detected only after a full depth-first descent, and unreached rows are surfaced at depth 0 in input order. This ensures no row is lost and all rows are visited exactly once. The cost is O(n) space for the `reached` set and a final O(n) scan.

- **Leaf spacer**: Leaves render a spacer element (not a disabled toggle) to preserve layout alignment across parent and leaf rows. A disabled button would imply interactivity (and accessibility) that does not exist; a spacer is semantic and silent.

- **Chevron icon and rotation**: The toggle uses a ChevronRight glyph (rotated 90° when expanded) instead of a separate DownChevron glyph. This is consistent with the Disclosure component in the same design system and reduces icon count.

- **1.25em indent per level**: Indent is chosen to be visually distinct at moderate nesting depth (up to 5–6 levels) without consuming excessive horizontal space. At 5 levels, 6.25em of left padding is typical for desktop layouts.

- **Minimal button styling**: The toggle button has no visible background or border by default, appearing as a text-muted chevron. Hover and focus states are subtle (text color change and focus ring). This design keeps the row visually clean and focuses attention on the content, not the toggle itself.

## Compliance

Not applicable: No specific compliance checks (WCAG, security, data protection) have been defined for this component at this time.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.1.0 | 2026-09-22 | Mike Fullerton | Revise Reduce Motion and Increase Contrast markers; clarify token requirements and motion animation behavior. |
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation from tree-rows.tsx source. |
