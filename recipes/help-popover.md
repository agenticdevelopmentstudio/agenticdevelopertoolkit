---
id: 56828ee6-f522-45da-a9d8-6e1a99adf4e2
title: Help Popover
domain: agenticdevelopertoolkit://recipes/help-popover
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A popover panel displaying contextual help, information, or feature announcements
  with a flavor icon, optional title, and body text.
platforms:
- typescript
- web
tags:
- help
- popover
- accessibility
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Help Popover

## Overview

Help Popover is the content panel portion of a help popover UI pattern. It displays contextual help, informational guidance, or feature announcements next to a trigger control. The component combines a flavor-specific icon (help, information, or what's new), an optional title, and body text inside a positioned popover with an arrow. It is intended for brief, contextual guidance that does not block user interaction with the underlying content.

## Behavioral Requirements

- **must-accept-entry-prop**: The component MUST accept a `HelpEntry` prop containing the popover content.
- **must-accept-side-prop**: The component MUST accept an optional `side` prop controlling popover vertical/horizontal positioning (`"top"`, `"bottom"`, `"left"`, or `"right"`), with `"bottom"` as the default.
- **must-accept-align-prop**: The component MUST accept an optional `align` prop controlling popover alignment along the positioning axis (`"start"`, `"center"`, or `"end"`), with `"start"` as the default.
- **must-render-flavor-icon**: The component MUST render an icon corresponding to the flavor value in `entry.flavor`, defaulting to `"info"` if not specified. The three supported flavors are `"help"` (CircleHelp icon), `"info"` (Info icon), and `"new"` (Sparkles icon).
- **must-render-body-text**: The component MUST render the text from `entry.body` in the popover panel.
- **must-render-arrow**: The component MUST render an arrow pointing from the popover to its anchor control.
- **must-render-optional-title**: If `entry.title` is provided, the component MUST render it as a distinct, visually emphasized element. If `entry.title` is not provided or is empty, the component MUST NOT render a title section.
- **must-constrain-width**: The component MUST constrain the popover panel width to 320px (Tailwind `w-80`).
- **must-set-accessible-name**: The component MUST set an accessible name (via `aria-label`) combining the flavor label (Help, Information, or What's new) with the title if present. The pattern MUST be `"{flavor}: {title}"` when title exists, or `"{flavor}"` when title is absent.
- **must-hide-icon-from-a11y-tree**: The component MUST mark the flavor icon as decorative (via `aria-hidden="true"`) since the flavor information is conveyed by the panel's accessible name.
- **must-apply-color-tokens**: The component MUST apply the design system color tokens for text: `apt-text` for the title, `apt-text-muted` for the icon and body text.

## Appearance

- **Width**: 320px (fixed)
- **Icon size**: 4×4px (Lucide default, 16px interpreted as size-4 in Tailwind)
- **Icon color**: `apt-text-muted` (design system token for muted text)
- **Icon margin**: 0.5px top margin, no left/right margin
- **Content gap**: 2.5px horizontal gap between icon and text block
- **Title font**: font-weight `500` (medium), inherits body size
- **Title color**: `apt-text` (design system token for primary text)
- **Title margin**: 1px bottom margin (creates visual separation from body)
- **Body font**: inherits body size and line-height
- **Body color**: `apt-text-muted` (design system token for muted text)
- **Text block**: `min-w-0` applied to allow text truncation within flex layout
- **Arrow**: Rendered by PopoverContent component; inherits popover positioning and alignment

## States

| State | Appearance change |
|-------|------------------|
| Default (closed) | Popover is not rendered; trigger control is visible |
| Open | Popover panel is visible with all content rendered; arrow points to anchor |
| With title | Title paragraph rendered above body text; title is font-medium |
| Without title | Only body text is rendered; no empty space for title |

## Accessibility

- **Role**: Dialog (provided by PopoverContent wrapper; popover panel announces as `role="dialog"`)
- **Accessible name**: Set via `aria-label` on PopoverContent; combines flavor label with title if present (e.g., "Help: Getting Started" or "Information")
- **Icon trait**: Decorative image (via `aria-hidden="true"`); the icon's semantic meaning is captured in the panel's accessible name
- **Keyboard navigation**: Keyboard access to the popover is the responsibility of the trigger control and PopoverContent's dismiss mechanism; this component focuses and announces when the popover opens
- **Screen reader announcement**: On open, screen readers announce the dialog role and accessible name; the title and body text are then available for exploration
- **Minimum tap target**: Not applicable; the component contains no interactive controls. Tap target size is determined by the trigger control that opens the popover.
- **Color contrast**: Text colors (`apt-text`, `apt-text-muted`) are design system tokens; their contrast ratios SHOULD meet WCAG AA standards (requires verification of token definitions)

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| help-001 | must-accept-entry-prop | `entry={ flavor: "help", title: "Help", body: "This is a help message" }` | Component renders without error; body text "This is a help message" appears in the popover |
| help-002 | must-render-flavor-icon | `entry={ flavor: "help", title: "", body: "Text" }` | CircleHelp icon is rendered with `data-help-flavor="help"` attribute |
| help-003 | must-render-flavor-icon | `entry={ flavor: "info", title: "", body: "Text" }` | Info icon is rendered with `data-help-flavor="info"` attribute |
| help-004 | must-render-flavor-icon | `entry={ flavor: "new", title: "", body: "Text" }` | Sparkles icon is rendered with `data-help-flavor="new"` attribute |
| help-005 | must-render-flavor-icon | `entry={ flavor: undefined, title: "", body: "Text" }` | Info icon is rendered (default flavor); `data-help-flavor="info"` attribute is set |
| help-006 | must-render-body-text | `entry={ flavor: "info", title: "", body: "Help text content" }` | Body text "Help text content" is rendered in a paragraph with `apt-text-muted` color |
| help-007 | must-render-optional-title | `entry={ flavor: "info", title: "Getting Started", body: "Learn how to use this feature" }` | Title text "Getting Started" is rendered as a font-medium paragraph with `mb-1` spacing |
| help-008 | must-render-optional-title | `entry={ flavor: "info", title: "", body: "Body only" }` | No title element is rendered; only body text appears |
| help-009 | must-constrain-width | `entry={ flavor: "info", title: "Title", body: "Longer body text that might wrap across multiple lines should still respect the 320px width constraint" }` | PopoverContent has `className="w-80"` applied; width is 320px |
| help-010 | must-set-accessible-name | `entry={ flavor: "help", title: "Getting Started", body: "Text" }` | `aria-label="Help: Getting Started"` is set on PopoverContent |
| help-011 | must-set-accessible-name | `entry={ flavor: "info", title: "", body: "Information text" }` | `aria-label="Information"` is set on PopoverContent |
| help-012 | must-hide-icon-from-a11y-tree | `entry={ flavor: "new", title: "Feature Launch", body: "Text" }` | Icon has `aria-hidden="true"` attribute; screen reader skips the icon and announces the panel name |
| help-013 | must-apply-color-tokens | `entry={ flavor: "info", title: "Title", body: "Body" }` | Title has `text-apt-text` color; icon and body have `text-apt-text-muted` color |
| help-014 | must-accept-side-prop | `side="top"` | PopoverContent receives `side="top"` and positions popover above anchor |
| help-015 | must-accept-side-prop | `side="left"` | PopoverContent receives `side="left"` and positions popover left of anchor |
| help-016 | must-accept-side-prop | (side prop not provided) | PopoverContent receives `side="bottom"` (default) |
| help-017 | must-accept-align-prop | `align="center"` | PopoverContent receives `align="center"` and centers popover along positioning axis |
| help-018 | must-accept-align-prop | `align="end"` | PopoverContent receives `align="end"` and aligns popover to end of positioning axis |
| help-019 | must-accept-align-prop | (align prop not provided) | PopoverContent receives `align="start"` (default) |
| help-020 | must-render-arrow | (any valid entry) | `arrow` prop is passed to PopoverContent as `true`; arrow is rendered connecting popover to anchor |

## Edge Cases

- **Null or undefined entry**: Not applicable; the component does not guard against null `entry` and will error. Callers MUST provide a valid `HelpEntry` prop.
- **Empty body text**: If `entry.body` is an empty string, the component MUST render an empty paragraph. A popover with only an icon and optional title (no body) appears incomplete and is not a supported use case.
- **Empty title**: If `entry.title` is an empty string or omitted, the component MUST NOT render the title section; only the body text is rendered.
- **Null or undefined flavor**: If `entry.flavor` is `undefined` or `null`, the flavor defaults to `"info"` and the Info icon is rendered.
- **Invalid flavor value**: If `entry.flavor` contains a value not in the `FLAVORS` table (`"help"`, `"info"`, `"new"`), the component will error attempting to look up the icon and label. Callers MUST ensure flavor is one of the three valid values.
- **Long title text**: Title text longer than approximately 30 characters may wrap to multiple lines; no specific line-clamp or truncation is applied by this component.
- **Long body text**: Body text is not constrained in height or line count; if `entry.body` is very long (e.g., multiple paragraphs), the popover panel will grow vertically. No maximum height or scrolling behavior is defined in this component.
- **Whitespace in entry strings**: Leading or trailing whitespace in `entry.title` or `entry.body` is preserved and rendered as-is; no trimming is performed by this component.
- **Special characters or markup in entry strings**: The component renders entry text as plain text; if `entry.body` or `entry.title` contains HTML markup or special characters (e.g., `<`, `>`), they are not interpreted. The caller is responsible for providing plain-text content.

## Configuration

Not applicable; the component accepts no configuration props beyond `entry`, `side`, and `align`.

## Deep Linking

Not applicable; Help Popover is a content panel with no independent URL or navigation capability. Deep linking is the responsibility of the trigger control and hosting application.

## Localization

Not applicable; the component renders no user-facing strings of its own. Localization of the flavor labels (Help, Information, What's new) and entry content (title and body) is the responsibility of the caller. The flavor labels are defined in the `FLAVORS` constant and SHOULD be externalized to a localization system if multi-language support is required.

## Accessibility Options

Not applicable; the component does not respond to platform accessibility display options such as Reduce Motion or Increase Contrast. Motion and contrast are controlled by PopoverContent and the design system color tokens (`apt-text`, `apt-text-muted`).

## Feature Flags

Not applicable; the component is not gated by feature flags.

## Analytics

Not applicable; the component itself does not emit analytics events. Analytics instrumentation (e.g., tracking popover opens, user interactions with the help content) SHOULD be implemented at the trigger control or application level.

## Privacy

Not applicable; the component does not collect, store, or transmit any user data.

## Logging

Not applicable; the component does not emit logs.

## Platform Notes

- **React/Web**: Help Popover is implemented as a functional React component using Tailwind CSS for styling and Lucide React for icons. The component composes PopoverContent (a Base UI Popover wrapper) and must be used with a Popover.Trigger element to be functional. Import from `agenticdevelopertoolkit/ui/components/help-popover`.
- **SwiftUI**: Implement using SwiftUI's `.popover()` modifier or `Menu` with Label. Render an Image or SF Symbol for the flavor icon (help.circle, info.circle, or sparkles for the three flavors), a Text view for the optional title (font(.headline) or similar emphasis), and a Text view for the body. Set `.accessibilityElement(children: .combine)` on the popover container and apply a custom `accessibilityLabel` combining flavor and title as described in Accessibility. Use `preferredContentSize` or frame modifiers to constrain width to 320pt.
- **Kotlin (Compose)**: Implement using `Popup` or `DropdownMenu` with a `Card` or `Surface` for the panel. Use Material Design 3 icon resources (HelpOutline, Info, or AutoAwesome) for the three flavors. Apply `width(320.dp)` and use `Row` for the icon+text layout. Set the popover container's `semantics { contentDescription = ... }` combining flavor and title per the Accessibility section. Apply color tokens from the design system (`SurfaceColor.OnSurface` for `apt-text`, `SurfaceColor.OnSurfaceVariant` for `apt-text-muted`).
- **AppKit / UIKit**: Implement as a subclass of `UIViewController` (popover controller) or SwiftUI view bridged to UIKit via `UIHostingController`. Use `UIImage(systemName:)` to load SF Symbols (help.circle, info.circle, sparkles) for the three flavors. Render using UIStackView or SwiftUI; apply `preferredContentSize = CGSize(width: 320, height: ...)`. Set the view controller's `accessibilityLabel` combining flavor and title. Apply UIColor or semantic color assets for text (`UIColor.label` for `apt-text`, `UIColor.secondaryLabel` for `apt-text-muted`).
- **WinUI 3**: Implement as a `Flyout` with a `FlyoutPresenter` for positioning control (Top, Bottom, Left, Right). Use `FontIcon` or `SymbolIcon` with Segoe MDL2 Assets or Segoe Fluent Icons (Help, Info, or Sparkles) for the three flavors. Render a `StackPanel` (Horizontal) containing the icon and a `StackPanel` (Vertical) for title and body text. Set `Width="320"` on the Flyout content. Bind the Flyout's `Title` property (or apply `AutomationProperties.Name`) to combine flavor and title per Accessibility. Apply Fluent 2 brushes (`TextFillColorPrimaryBrush` for `apt-text`, `TextFillColorSecondaryBrush` for `apt-text-muted`).

## Design Decisions

1. **Flavor icon is decorative**: The flavor (help, info, new) is conveyed via the popover panel's accessible name using the flavor label (Help, Information, What's new). The icon is marked `aria-hidden="true"` to prevent redundant announcement by screen readers. This simplifies the accessible name and avoids icon-label duplication.

2. **Fixed width at 320px**: The popover panel width is constrained to prevent overly wide content and ensure readability. The width matches common content widths in the design system and accommodates most help text without requiring horizontal scroll.

3. **Title is optional and visually emphasized**: When a title is present, it is rendered with `font-medium` weight to distinguish it from body text and provide visual hierarchy. When absent, the component renders only body text without empty space, avoiding visual clutter.

4. **Default flavor is "info"**: If `entry.flavor` is not provided, the component defaults to `"info"` (Info icon). This is the most neutral and widely applicable flavor for general help content.

5. **Default positioning is bottom-start**: The `side` and `align` props default to `"bottom"` and `"start"`, respectively. This positions the popover below the trigger control and aligned to its left edge, a common popover placement that does not obscure the trigger or surrounding content in most contexts.

6. **Color tokens drive styling**: Text colors are applied via design system tokens (`apt-text`, `apt-text-muted`) rather than hardcoded values. This ensures consistency with the application's color scheme and supports light/dark mode switching via token overrides.

## Compliance

Not applicable; the component does not require formal compliance tracking beyond the accessibility requirements documented in the Accessibility section.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation |
