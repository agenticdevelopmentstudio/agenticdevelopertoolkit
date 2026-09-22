---
id: 688cd8dc-2927-4a8a-9931-807fe283ed01
title: Closer
domain: agenticdevelopertoolkit://recipes/closer
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A centered container block that serves as the final call to action, positioned
  after hero content.
platforms:
- typescript
- web
tags:
- layout
- container
- call-to-action
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Closer

## Overview

The Closer component is a container block that renders a centered call-to-action section, positioned as the concluding element after introductory or hero content. It provides semantic structure by wrapping a title (rendered as an h2 heading) and arbitrary child content, supporting optional CSS class names for additional styling integration with parent layouts.

## Behavioral Requirements

- **must-render-title**: The component MUST render the `title` prop as the first child within an h2 element.
- **must-render-children**: The component MUST render the `children` prop after the title element.
- **must-apply-lp-closer-class**: The component MUST apply the CSS class `lp-closer` to its root div element.
- **must-merge-optional-classname**: When a `className` prop is provided, the component MUST merge it with the base `lp-closer` class and apply both to the root element, separated by a space.
- **must-filter-empty-strings**: The component MUST filter out empty strings when merging class names to avoid duplicate spaces.

## Appearance

- **Structure**: Block-level container rendered as a `<div>` with `display: block` default behavior.
- **Background**: Transparent (no default background color applied by the component).
- **Padding**: Controlled via CSS class styling; the component applies no inline padding.
- **Border**: None (applied by default; styling managed via CSS).
- **Text alignment**: Center alignment applied via `lp-closer` CSS class (source comment indicates centering behavior).
- **Width**: 100% of container (default block behavior).

## States

The Closer component is a static presentational component with no interactive states. Not applicable: no pressed, focused, loading, or disabled states are supported.

## Accessibility

- **Semantic structure**: The component uses an h2 heading element for the title, providing proper document outline hierarchy.
- **Title labeling**: The title prop establishes context for the section. Screen readers announce the h2 and its content as a heading.
- **Content containment**: Child content is contained within the same block, creating a single logical section for screen readers.
- **Keyboard navigation**: Not applicable — the component is non-interactive. Keyboard focus may enter child elements if they are interactive.

## Conformance Test Vectors

| ID | Requirement | Input | Action | Expected |
|----|-----------|----|--------|----------|
| closer-001 | must-render-title | `title="Get Started"`, `children=<div>form</div>` | Render component | h2 element contains text "Get Started" |
| closer-002 | must-render-children | `title="Call"`, `children=<button>Sign Up</button>` | Render component | Button element is rendered after the h2 |
| closer-003 | must-apply-lp-closer-class | `title="X"`, `children=null` | Render component | Root div has className containing "lp-closer" |
| closer-004 | must-merge-optional-classname | `title="X"`, `className="custom-styling"` | Render component | Root div className equals "lp-closer custom-styling" |
| closer-005 | must-filter-empty-strings | `title="X"`, `className=""` | Render component | Root div className equals "lp-closer" (no trailing space) |
| closer-006 | must-filter-empty-strings | `title="X"`, `className=undefined` | Render component | Root div className equals "lp-closer" |

## Edge Cases

- **Empty title**: When `title=""` is passed, an h2 element is still rendered but contains no text. Expected: MUST render the empty h2.
- **Null or undefined children**: When `children` is null or undefined, the component MUST render the div and h2 without error. No child content renders below the title.
- **Empty className**: When `className=""` is provided, the filter function removes it, leaving only "lp-closer" in the final className.
- **Undefined className**: When `className` is not provided, only "lp-closer" is applied to the root element.
- **ReactNode composition**: The `title` and `children` props accept any valid ReactNode (strings, elements, fragments, arrays). The component renders them without modification. Expected: Component MUST accept and render ReactNode values without error.

## Configuration

Not applicable: the component accepts no configuration beyond its three props (title, children, className). Configuration is handled via CSS class definitions and parent layout composition.

## Deep Linking

Not applicable: the Closer component is a layout container with no inherent link target or navigation functionality.

## Localization

Not applicable: the component has no hardcoded text. The `title` prop is passed by the caller and may be localized by the parent application.

## Accessibility Options

Not applicable: the component is a static container without interactive features or display modes that respond to accessibility settings.

## Feature Flags

Not applicable: the component has no conditional rendering or feature-gated behavior.

## Analytics

Not applicable: the Closer component is a presentational container. Event tracking is handled by child components or parent code.

## Privacy

Not applicable: the component collects no user data and transmits no information.

## Logging

Not applicable: the component performs no operations that require event logging.

## Platform Notes

- **TypeScript / Web (React)**: Implemented in `packages/web/packages/landing/src/blocks/Closer.tsx`. The component uses a functional component signature, accepts ReactNode props for title and children, merges className via `.filter(Boolean).join(' ')` to remove empty strings, and renders a semantic h2 for the title within a centered container div.

- **SwiftUI**: Translate using a VStack or ZStack container with horizontal centering (`.frame(maxWidth: .infinity)` + `.multilineTextAlignment(.center)`). Render a Text element with `.font(.headline)` for semantic heading equivalence, followed by a generic content container. Accept a `@ViewBuilder` closure for children and an optional CSS-like class name (mapped to view modifiers or a custom Style protocol if coordinating with a design system).

- **Compose**: Use a Column (Vertical layout) with `Modifier.fillMaxWidth()` and `horizontalAlignment = Alignment.CenterHorizontally`. Render the title as a Text composable with `TextStyle.headlineSmall` for semantic equivalence. Define a content lambda parameter accepting a `RowScope.() -> Unit` for children. Accept an optional className parameter and apply it via a custom modifier or theme-based styling.

- **AppKit / UIKit**: Use UIView (AppKit NSView) with a vertical stack view (`UIStackView` / `NSStackView` with axis `.vertical`). Center the stack horizontally within its superview. Render the title as UILabel (NSTextField) with font `UIFont.preferredFont(forTextStyle: .headline)` / appropriate header font. Accept a content view parameter and a CSS class name string mapped to a view styling function (e.g., applying layout constraints or appearance attributes).

- **WinUI 3**: Use a StackPanel with Orientation=`Vertical` and HorizontalAlignment=`Center`. Render the title as a TextBlock with FontSize=`20` and FontWeight=`SemiBold` for semantic heading. Define a content property (XAML content or dependency property) for child elements. Accept a CSS class name string parameter and map it to a ResourceDictionary key for ThemeResource or local style application; apply via the FrameworkElement.Style property or dynamic resource binding.

## Design Decisions

- **h2 as title element**: The component always renders the title within an h2 heading. This decision provides semantic structure and establishes hierarchy in screen reader outline navigation. The component assumes it is always a section-level conclusion and does not expose a heading level parameter.

- **className merge strategy**: The className prop is merged with the base class via `.filter(Boolean).join(' ')` to ensure that empty strings do not create duplicate spaces or trailing whitespace. This approach allows callers to conditionally pass class names without manual string trimming. The merge always places `lp-closer` first for CSS specificity consistency.

- **No default styling within the component**: The Closer component does not apply inline styles (e.g., `textAlign: 'center'`). All visual styling, including centering, is delegated to CSS class definitions. This decision allows consumers to fully control appearance via CSS and avoids style conflicts.

- **ReactNode flexibility**: Both `title` and `children` accept ReactNode to support rich content (not just strings) and enable complex compositions in parent layouts. The component passes these through without transformation or cloning.

## Compliance

Not applicable: the component has no specific compliance checks related to security, privacy, or regulatory requirements.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation |
