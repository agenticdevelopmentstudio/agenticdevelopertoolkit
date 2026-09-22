---
id: 28436339-4eda-46e9-b45f-f58a26949641
title: Doc Table of Contents
domain: agenticdevelopercookbook://ingredients/doc-table-of-contents
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Sticky right-rail component displaying a scrollable list of document headings
  with active-heading highlight.
platforms:
- typescript
- web
tags:
- navigation
- documentation
- scrollspy
depends-on: []
related: []
references:
- https://developer.mozilla.org/en-US/docs/Web/CSS/position
- https://developer.mozilla.org/en-US/docs/Web/API/Element/scrollIntoView
approved-by: ''
approved-date: ''
---

# Doc Table of Contents

## Overview

The Doc Table of Contents is a sticky, scrollable navigation rail positioned to the right of a document. It displays a list of the document's headings, indented by heading depth, with a visual marker (accent color border and bold text) indicating which section the user is currently viewing. It automatically scrolls to keep the active heading visible and smooth-scrolls the page when a heading is clicked. The component renders nothing when the heading list is empty, making it suitable for variable-length documents.

## Behavioral Requirements

- **must-accept-headings-array**: Component MUST accept a `headings` array of `HeadingEntry` objects containing at minimum an `id`, `text`, and `depth` property for each heading.
- **must-render-nothing-when-empty**: Component MUST render nothing (return null) when the `headings` array is empty or all headings are filtered by `excludeIds`.
- **must-filter-headings**: Component MUST filter headings based on the optional `excludeIds` iterable, excluding any heading whose `id` is in the set.
- **must-track-active-heading**: Component MUST track which heading is currently in the viewport using a scrollspy mechanism and highlight it as the active heading.
- **must-show-active-heading-styling**: Component MUST render the active heading with an accent-colored left border (1px width), primary text color, and medium font weight.
- **must-show-inactive-heading-styling**: Component MUST render inactive headings with a transparent left border (maintaining alignment), dim text color, and regular font weight.
- **must-hover-inactive-headings**: Component MUST change inactive heading text color to secondary on hover to indicate interactivity.
- **must-indent-by-depth**: Component MUST indent headings proportionally to their depth: depth-3 headings MUST have 6 units of left padding, all other headings MUST have 3 units.
- **must-scroll-page-on-click**: Component MUST smooth-scroll the document to the target heading's element when clicked, preventing default link behavior.
- **must-use-custom-title**: Component MUST accept an optional `title` prop (ReactNode) and MUST default to "On this page" when not provided.
- **must-transition-colors**: Component MUST apply a CSS transition effect to color changes when the active state changes.
- **must-respect-custom-classname**: Component MUST accept an optional `className` prop and merge it with the component's default classes without losing the sticky positioning or layout structure.
- **must-accept-html-attributes**: Component MUST accept standard HTML element attributes (spread via `...rest` on the aside element) and apply them to the component's root element.
- **must-use-monospace-title**: Component MUST render the title in monospace font, uppercase, small size (10px), medium weight, and dim color.
- **must-hide-below-xl**: Component MUST hide on screens smaller than the XL breakpoint and show only on XL and larger screens.
- **must-be-sticky-positioned**: Component MUST use CSS sticky positioning, offsetting from the top by the value of the CSS custom property `--adh-header-height` (defaulting to 3.5rem if not defined).
- **must-have-fixed-width**: Component MUST have a fixed width of 14 rem (56 units) and MUST NOT grow or shrink.
- **must-have-left-border**: Component MUST render a left border (1px width) on the heading list using the `--color-border-subtle` custom property.
- **must-use-custom-properties**: Component MUST use CSS custom properties (`--color-accent`, `--color-text-primary`, `--color-text-dim`, `--color-text-secondary`, `--color-border-subtle`) for all colors and MUST NOT use hardcoded color values.

## Appearance

- **Corner radius**: None; component uses only sharp edges.
- **Padding**: Vertical 2 rem (8 units) × horizontal 1 rem (4 units) on the container; individual headings use vertical 0.125 rem (0.5 units) and horizontal padding based on depth (3 units or 6 units).
- **Font**: Title uses monospace, 10px, medium weight, uppercase. Headings use sans-serif, small size (14px), regular weight (inactive) or medium weight (active).
- **Background**: Transparent; no background color is applied.
- **Foreground/Text**: Title uses `--color-text-dim`. Inactive headings use `--color-text-dim` with hover state to `--color-text-secondary`. Active heading uses `--color-text-primary` and font-medium.
- **Border**: Left border on the heading list uses `--color-border-subtle` (1px width). Individual headings have a left border that is 1px wide and uses `--color-border-transparent` (inactive) or `--color-accent` (active).
- **Shadow**: None.
- **Min/Max size**: Minimum width 14 rem; maximum height is viewport height minus header height with overflow-y-auto scrolling.

## States

| State | Appearance change |
|-------|------------------|
| Default | Inactive heading with dim text, transparent border. |
| Inactive (on hover) | Text color changes from dim to secondary; border remains transparent. |
| Active | Left border changes to accent color; text color changes to primary; font weight changes to medium. |
| Scrolled out of view | Heading remains in list; active marker updates as viewport changes. |

## Accessibility

- **Role**: The component renders as an `<aside>` (supplementary content region). The heading list renders as an unordered list (`<ul>`) with anchor links (`<a href="#id">`).
- **Label requirements**: The component's title (rendered as an `<h4>`) serves as the region label. Heading links MUST have accessible text derived from the heading content (the `heading.text` property).
- **Keyboard navigation**: All heading links MUST be keyboard-accessible via Tab and Enter (standard anchor link behavior). Focus indicators are browser-supplied.
- **Announce state changes**: Screen readers will announce heading links as navigational anchors. The active heading's increased font weight and color are visual affordances; the actual "current page location" is conveyed by the user's scroll position and the anchor link target.
- **Minimum tap target**: Links MUST have a minimum touch target of 44×44 pt. The current implementation uses `py-0.5` (2px vertical) and text-sm with line-height, which MAY NOT meet the 44×44 pt requirement; this is a layout constraint inherited from the document design and is not the component's responsibility.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| doc-toc-001 | must-accept-headings-array | `headings=[{id:"h1", text:"Introduction", depth:2}, {id:"h2", text:"Methods", depth:2}]` | Component renders a list with two anchor links. |
| doc-toc-002 | must-render-nothing-when-empty | `headings=[]` | Component returns null; no HTML is rendered. |
| doc-toc-003 | must-filter-headings | `headings=[{id:"h1", text:"Title", depth:1}, {id:"h2", text:"Appendix", depth:2}]`, `excludeIds=["h1"]` | Component renders only the "Appendix" link; "Title" is hidden. |
| doc-toc-004 | must-track-active-heading | User scrolls document so heading with id "h2" is in viewport. | Component's scrollspy hook identifies "h2" as active; link receives active styling. |
| doc-toc-005 | must-show-active-heading-styling | Heading with id "h1" is active. | Link renders with accent-colored left border, primary text color, medium font weight. |
| doc-toc-006 | must-show-inactive-heading-styling | Heading with id "h2" is inactive. | Link renders with transparent left border, dim text color, regular font weight. |
| doc-toc-007 | must-hover-inactive-headings | User hovers over an inactive heading link. | Text color changes to secondary. |
| doc-toc-008 | must-indent-by-depth | `headings=[{id:"h1", text:"Intro", depth:2}, {id:"h2", text:"Subsection", depth:3}]` | "Intro" link has pl-3 (3 units); "Subsection" link has pl-6 (6 units). |
| doc-toc-009 | must-scroll-page-on-click | User clicks a heading link with `href="#h2"`. | Page smooth-scrolls to the element with id "h2"; link's default behavior is prevented. |
| doc-toc-010 | must-use-custom-title | `title="Table of Contents"` | Component renders the custom title instead of the default "On this page". |
| doc-toc-011 | must-use-custom-title (default) | No `title` prop provided. | Component renders "On this page". |
| doc-toc-012 | must-transition-colors | User scrolls to change the active heading. | CSS transition effect smooths the color and border changes over approximately 150ms. |
| doc-toc-013 | must-respect-custom-classname | `className="my-custom-class"` | Component renders the aside with both the default DOC_TABLE_OF_CONTENTS_CLASS styles and the custom class applied. |
| doc-toc-014 | must-accept-html-attributes | `data-testid="toc"` | Component renders the aside with the `data-testid` attribute set to "toc". |
| doc-toc-015 | must-use-monospace-title | Component is rendered. | Title renders in font-mono, 10px, medium weight, uppercase, dim color. |
| doc-toc-016 | must-hide-below-xl | Screen width is 800px (below XL breakpoint, typically 1280px in Tailwind). | Component does not render (hidden by `hidden xl:block`). |
| doc-toc-017 | must-be-sticky-positioned | User scrolls the document past the component's initial position. | Component remains visible and sticky, offset from the top by `--adh-header-height`. |
| doc-toc-018 | must-have-fixed-width | Component is rendered. | Component width is exactly 14 rem (224px); does not scale with content. |
| doc-toc-019 | must-use-custom-properties | Component is rendered in a themed environment providing `--color-accent`, `--color-text-primary`, etc. | All colors derive from CSS custom properties; component respects theme changes. |

## Edge Cases

- **Empty headings array**: Component returns null and renders no HTML. This is by design; empty documents have no navigation targets.
- **All headings excluded**: If `excludeIds` excludes every heading in the array, `listed` becomes empty and the component returns null.
- **Heading with no matching element**: If a heading's id does not correspond to an element in the DOM (e.g., the heading list includes an id that was not rendered), `document.getElementById()` returns null and `.scrollIntoView()` is not called. This does not throw an error due to optional chaining (`?.scrollIntoView()`).
- **Very long heading text**: Text overflows the component's fixed width of 14 rem. The component does not truncate or wrap text; the text will overflow horizontally unless the parent's overflow is constrained.
- **Rapid scroll events**: The scrollspy hook debounces or batches scroll events to avoid excessive re-renders. The exact debounce timing is defined by the `useScrollSpy` hook and not configurable via component props.
- **Click on active heading**: Clicking an already-active heading scrolls to it again. The smooth-scroll behavior is re-triggered.
- **Custom title is empty or null**: If `title` is an empty string or null, the component still renders the `<h4>` element, but it will be empty.
- **CSS custom properties not defined**: The component uses fallback values only for `--adh-header-height` (3.5rem); other custom properties have no fallbacks. If the theme does not define `--color-accent`, the browser will use the initial (transparent/black) color.
- **Screen resizes from below XL to XL**: Component transitions from hidden to visible. No re-render or data loss occurs; the component's state is preserved.

## Configuration

Not applicable: The component accepts a fixed set of props for content and styling. No additional configuration options are exposed.

## Deep Linking

Not applicable: The component renders anchor links to document headings but does not implement its own deep-linking behavior. Deep links are managed by the browser's standard anchor link mechanism.

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| `doc-toc.title` | "On this page" | Default title when the `title` prop is not provided. |

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Component SHOULD respect the `prefers-reduced-motion` media query; the `transition-colors` class on heading links SHOULD be disabled when reduce-motion is enabled. Not currently implemented in source. |
| Increase Contrast | Component color tokens (`--color-accent`, `--color-text-primary`, etc.) SHOULD be adjusted by the theme to meet contrast ratios. Component does not control this. |
| Differentiate Without Color | Active headings rely on color to indicate state. The component SHOULD apply a visual indicator (e.g., bold text, border) in addition to color. Currently, the component uses both color and font-weight (medium) to indicate the active state, satisfying this requirement. |

## Feature Flags

Not applicable: The component has no feature flags. All behaviors are always enabled.

## Analytics

Not applicable: The component does not emit analytics events. Analytics integration is the responsibility of the document or application layer.

## Privacy

Not applicable: The component does not collect, store, or transmit personal data. It operates entirely on client-side document state.

## Logging

Not applicable: The component does not emit logging events. Debugging can be performed via browser developer tools (inspecting the scrollspy state and active heading).

## Platform Notes

- **SwiftUI**: On iOS and macOS, implement using a `List` of navigation links to document section identifiers. Use `ScrollViewReader` to scroll the list to keep the active section visible. Replicate the scrollspy behavior using a `GeometryReader` and `onScrollGeometryChange` modifier to track which section is currently in the viewport. Apply accent color and bold font to the active link. Respect `horizontalSafeArea` for edge padding.
- **Compose**: On Android, implement using a vertical `LazyColumn` of `TextButton` components bound to document heading ids. Use `LazyListState.animateScrollToItem()` for smooth scrolling. Implement scrollspy by observing the main document's scroll position (e.g., via `ScrollState` or a `NestedScrollConnection`) and updating the active heading state. Apply Material Design 3 accent color and headline style to the active link; use label/body style for inactive links.
- **React/Web**: Use a sticky `<aside>` with `position: sticky; top: var(--adh-header-height, 3.5rem)`. Render an unordered list of anchor links. Use a custom hook (e.g., `useScrollSpy`) to track the active heading based on scroll position. Apply conditional Tailwind classes for active/inactive styling. Smooth-scroll on click via `Element.scrollIntoView({ behavior: "smooth" })`.
- **AppKit / UIKit**: On macOS (AppKit), implement using an `NSOutlineView` or vertical stack of `NSButton` components. On iOS (UIKit), use a `UITableView` with custom cells for each heading link. Implement scrollspy by observing the main document's scroll position (e.g., via `UIScrollViewDelegate` or `Combine` publishers). Apply tint color and semibold font to the active link. Use `UIView.animate()` for color transitions. On iPad, present as a sidebar; on iPhone, present as a drawer or modal.
- **WinUI 3**: On Windows, implement using a `ListView` or `ItemsStackPanel` of `HyperlinkButton` controls bound to document heading URIs. Set `VerticalAlignment="Stretch"` and `Width="224"` (14 rem). Use a `ScrollViewer` for overflow. Implement scrollspy by registering a `ScrollViewerViewChanging` event handler on the main document and updating the selected item based on the document's scroll offset. Apply accent color and `FontWeight.SemiBold` to the selected link; use `SystemControlForegroundBaseHighBrush` for active and subtle for inactive. Use `ThemeShadow` for any elevation if needed. Respect the system's `HighContrast` setting by using dynamic brushes from the theme resource dictionary.

## Design Decisions

- **Fixed width and horizontal ellipsis**: The component has a fixed width of 14 rem to align with the document's grid and maximize readability. Long heading text overflows horizontally rather than wrapping, maintaining a consistent, predictable layout.
- **Monospace title**: The title renders in monospace font to distinguish it as "component chrome" rather than document content, following design conventions for supplementary UI.
- **Depth-based indentation**: Heading depth (h2, h3, etc.) is represented via left padding (3 or 6 units), not a tree hierarchy or nested list, because the document's heading outline is already visible in the main content.
- **No depth limit**: The component indents based on heading depth but does not hide or skip headings at deep nesting levels (e.g., h4, h5, h6). All headings are included in the list.
- **Scrollspy timing**: The active heading is determined by which heading's element is closest to the viewport top at the moment of scroll. If headings are close together, the active marker may flip rapidly; no debounce or "sticky" behavior favors the previous active heading.
- **Smooth scroll on click**: Clicking a heading smooth-scrolls the page instead of an instant jump to improve the user's awareness of the navigation action and reduce visual jarring.
- **CSS custom properties for colors**: All color values are sourced from CSS custom properties, allowing the component to respect theme changes and adapt to light/dark mode without prop drilling or conditional styling.

## Compliance

Not applicable: Component compliance is the responsibility of the document application and theme layer. The component uses semantic HTML (`<aside>`, `<ul>`, `<li>`, `<a>`) and respects color contrast via theme tokens, but no specific compliance checks are embedded in the component.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation |
