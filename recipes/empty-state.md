---
id: e86eb195-1ec2-4b12-8a24-79f8c03f65ce
title: Empty State
domain: agenticdevelopertoolkit://recipes/empty-state
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A standardized placeholder component displaying centered content with an
  optional icon, title, description, and action.
platforms:
- typescript
- web
tags:
- placeholder
- empty-state
- ui-component
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Empty State

## Overview

The Empty State component renders a standardized "nothing here yet" placeholder — a centered container with a dashed border that displays a title, optional description, optional icon, and optional action. It provides a consistent treatment across panes and views where content is absent, replacing ad-hoc border-dashed boxes with a single blessed component.

## Behavioral Requirements

- **must-render-title**: Component MUST render the `title` prop as required content in a centered layout.
- **must-display-dashed-border**: Component MUST display a dashed border around the container.
- **may-render-icon**: Component MAY render an `icon` prop if provided; when rendered, the icon MUST be positioned above the title.
- **may-render-description**: Component MAY render a `description` prop if provided; when rendered, the description MUST appear below the title.
- **may-render-action**: Component MAY render an `action` prop if provided; when rendered, the action MUST appear below the description.
- **must-accept-classname**: Component MUST accept and apply a `className` prop for custom styling via class composition.
- **must-center-content**: Component MUST center all content both horizontally and vertically within the container.
- **must-maintain-minimum-height**: Component MUST enforce a minimum height of 160 pixels.

## Appearance

- **Container**: Flex layout, centered items, dashed border, rounded corners
- **Padding**: 6 units (24px in standard Tailwind spacing)
- **Border**: Dashed style, single width, color token `apt-border`
- **Border radius**: Medium radius (`rounded-lg`, typically 8px)
- **Minimum height**: 160px
- **Gap between elements**: 8px (2 units)
- **Icon size**: 6×6 units (24px)
- **Icon color**: `apt-text-dim`
- **Title font**: Small (0.875rem), color `apt-text-muted`
- **Description font**: Extra small (0.75rem), color `apt-text-dim`, max-width constrained to prose width
- **Action margin**: Top margin of 4px (1 unit)

## States

| State | Appearance change |
|-------|-------------------|
| Default | Dashed border, centered content, standard spacing |

Not applicable: Component is a static presentation container with no interactive states.

## Accessibility

- **Role**: Container/region (no interactive semantics required; content determines role)
- **Content responsibility**: The `title`, `description`, and `action` are provided as ReactNode by the consumer; component does not wrap them with semantic markup
- **Minimum height and padding**: Ensure adequate spacing around content for readability
- **Icon visual only**: Icon is purely presentational; no aria-label is required on the component itself

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| empty-state-001 | must-render-title | `title="No items"` | Title text "No items" appears centered in container |
| empty-state-002 | must-display-dashed-border | Default props | Container has visible dashed border |
| empty-state-003 | must-maintain-minimum-height | Default props | Container height is at least 160px |
| empty-state-004 | may-render-icon | `icon={<Icon />}` | Icon is rendered above title and is 24×24px |
| empty-state-005 | may-render-description | `description="Try adding an item"` | Description text appears below title |
| empty-state-006 | may-render-action | `action={<Button>Create</Button>}` | Action button appears below description |
| empty-state-007 | must-accept-classname | `className="bg-red-100"` | Custom class is applied to container |
| empty-state-008 | must-center-content | `title="Centered"` with width constraint | Title text is centered horizontally and vertically within container |
| empty-state-009 | may-render-icon, may-render-description, may-render-action | `title`, no other props | Only title is rendered; description, action, and icon are absent |

## Edge Cases

- **Null or empty title**: Title is required; behavior with null, undefined, or empty ReactNode is undefined. Implementation SHOULD either treat null as an error or render an empty placeholder to preserve layout.
- **Very long title text**: Component renders title with `text-center` and no truncation constraint; long titles may wrap or overflow depending on container width. Component respects consumer's width context.
- **Long description text**: Description has `max-w-prose` constraint; text wrapping is handled by the prose width, preventing excessive line length.
- **No icon provided**: Icon div is not rendered (conditional render); layout remains centered.
- **All optional props omitted**: Component renders only title and border container, maintaining 160px minimum height.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `title` | ReactNode | (required) | Primary text content displayed in the container |
| `description` | ReactNode | undefined | Optional secondary text displayed below title |
| `action` | ReactNode | undefined | Optional action element (e.g., button) displayed below description |
| `icon` | ReactNode | undefined | Optional icon element displayed above title |
| `className` | string | undefined | Optional CSS class(es) merged with base styles via class composition |

## Deep Linking

Not applicable: Component is a presentational element without route or deep-link semantics. Deep linking is managed by the parent route or view that contains the Empty State.

## Localization

Not applicable: Component does not manage string content; all text is provided by the consumer as props. Localization is the responsibility of the calling code.

## Accessibility Options

- **Reduce Motion**: Not applicable; component is static and has no animations.
- **Increase Contrast**: Component uses design tokens (`apt-border`, `apt-text-muted`, `apt-text-dim`) that are defined at the design system level; contrast adherence is delegated to the token definitions.
- **Differentiate Without Color**: Component relies on design tokens; differentiation without color is the responsibility of the design system and the consuming code providing meaningful text content.

## Feature Flags

Not applicable: Component has no conditional behavior requiring feature flags.

## Analytics

| Event | Properties | When |
|-------|-----------|------|
| `empty_state.viewed` | `{ }` | Parent view renders component on screen |
| `empty_state.action_clicked` | `{ }` | User interacts with the action element (if provided) |

Note: Analytics tracking is delegated to the consumer; component itself does not emit events.

## Privacy

- **Data collected**: None — component is a presentational wrapper with no data collection or transmission.
- **Storage**: Not applicable.
- **Transmission**: Not applicable.
- **Retention**: Not applicable.

## Logging

Not applicable: Component performs no operations requiring debug or error logging.

## Platform Notes

- **React/Web**: Implemented as a functional component with React hooks optional. Uses Tailwind CSS for styling via the `cn` utility (class-name composition). Border color and text colors use design tokens (`apt-border`, `apt-text-muted`, `apt-text-dim`) provided by the design system. Icon size is 24px; description is constrained to `max-w-prose`. Files: `packages/web/packages/ui/src/components/empty-state.tsx`.
- **Swift/iOS**: Map to a `VStack` with `alignment: .center` and a dashed `Divider` or custom shape for the border. Use system foreground and background colors from the app's color set that correspond to `apt-text-muted` and `apt-text-dim`. Ensure minimum height constraint of 160pt and padding of 24pt. Icon size: 24×24pt.
- **Kotlin/Android**: Map to a `Column` with `Arrangement.Center` and `Alignment.CenterHorizontally`. Use a custom `Canvas` or `Shape` to render the dashed border. Apply Material Design 3 colors that correspond to the web tokens. Minimum height: 160dp, padding: 24dp. Icon size: 24×24dp.
- **AppKit/UIKit**: Map to `NSStackView` (macOS) or `UIStackView` (iOS) with vertical axis, center alignment, and center distribution. Render dashed border using `CAShapeLayer` with dash pattern. Use app-defined colors for text and border. Minimum height: 160pt, padding: 24pt. Icon size: 24×24pt.
- **WinUI 3**: Map to a `StackPanel` with `Orientation.Vertical` and `HorizontalAlignment.Center`. Use a `Border` with a custom dashed dash array stroke style (via a `SolidColorBrush` and stroke properties in XAML). Apply `CornerRadius` for rounded corners. Text colors and border color from app's resource dictionary matching `apt-border`, `apt-text-muted`, `apt-text-dim`. Minimum height: 160, padding: 24. Icon size: 24×24.

## Design Decisions

- **Dashed border as visual marker**: The dashed border is a deliberate design choice to signal that the state is empty or transitional, distinct from a standard container. This treatment replaces ad-hoc border-dashed utility classes across the application.
- **Optional icon positioning**: The icon is positioned above the title to allow for a visual cue (e.g., an empty folder icon) without forcing its inclusion. This flexibility supports use cases ranging from minimal (title-only) to rich (icon + title + description + action).
- **Fixed 160px minimum height**: The minimum height ensures the placeholder is substantial enough to be noticeable even when title is brief. Padding and gap values are tuned to this minimum.
- **Consumer-provided content**: The component does not constrain the semantic meaning of `action` — it accepts any ReactNode. This allows consumers to provide buttons, links, or other interactive elements appropriate to their context.
- **Design token delegation**: Colors use app-defined tokens (`apt-border`, `apt-text-muted`, `apt-text-dim`) rather than hard-coded values, ensuring consistency across the design system and supporting theme switching.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| WCAG 2.1 AA minimum contrast | Delegated to design tokens | Accessibility |
| Semantic HTML structure | Consumer-provided content owns structure | Accessibility |
| Touch target size (if action present) | Delegated to action element | Accessibility |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation from web source |
