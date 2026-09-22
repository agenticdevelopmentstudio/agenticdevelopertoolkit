---
id: 96e5e0cf-79a9-4873-9745-03442849b2fd
title: Orb Row
domain: agenticdevelopertoolkit://recipes/orb-row
type: ingredient
version: 1.1.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Navigation row displaying a series of site orbs with gradient backgrounds,
  emoji indicators, and current-page highlighting.
platforms:
- typescript
- web
tags:
- navigation
- site-navigation
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Orb Row

## Overview

Orb Row renders a horizontal navigation bar listing available sites as circular "orbs". Each orb displays an emoji icon with a gradient background and supports a "current" state to indicate the active site. The component is accessible via semantic navigation markup and ARIA attributes, and can be visually "docked" (a rendering variant for fixed positioning contexts).

## Behavioral Requirements

- **must-render-orb-links**: The component MUST render each site as an `<a>` element with `href` pointing to the site's URL.
- **must-apply-current-state**: The component MUST apply the `is-current` class to the link whose `id` matches `currentSite`.
- **must-set-aria-current**: When a link is current, the component MUST set `aria-current="page"` on that link; other links MUST NOT have `aria-current` set.
- **must-render-emoji-hidden**: The component MUST render the emoji in a `<span>` with `aria-hidden="true"` so it is not announced by assistive technologies.
- **must-render-tooltip-role**: The component MUST render the site name in a `<span>` with `role="tooltip"`.
- **must-apply-gradient-background**: The component MUST apply each site's `iconGradient` value as the CSS `background` style property on the orb link.
- **must-render-indicator-when-current**: When a site is current, the component MUST render an indicator `<span>` with class `orb-row-here` and `aria-hidden="true"`.
- **must-set-navigation-role**: The component MUST render the container with `role="navigation"` and `aria-label="Agentic family"`.
- **must-set-docked-class**: When the `docked` prop is `true`, the component MUST apply the `is-docked` class to the root container.
- **must-apply-custom-class**: The component MUST append any `className` prop value to the root container's class list.

## Appearance

- **Container**: Role is navigation; displays as a horizontal row of orbs.
- **Orb**: Circular element with gradient background; contains centered emoji and tooltip label.
- **Emoji**: Small icon representing the site, centered within the orb.
- **Tooltip**: Site name displayed as a tooltip (positioning and visibility determined by CSS).
- **Indicator**: Visual marker (the `orb-row-here` span) appended when site is current.
- **Docked variant**: When `docked=true`, the container receives the `is-docked` class for layout adjustment (specific appearance defined by stylesheet).

## States

| State | Appearance change |
|-------|------------------|
| Default | Orb shows emoji with gradient background; tooltip hidden or shown on hover. |
| Current | `is-current` class applied; aria-current="page" set; indicator span rendered. |
| Docked | `is-docked` class applied to container; specific layout adjustments via stylesheet. |

## Accessibility

- **Role**: Container is a navigation landmark with `role="navigation"`.
- **Label**: Container includes `aria-label="Agentic family"` to identify the navigation purpose.
- **Link labels**: Each link receives `aria-label="{site.name}"` for screen reader announcement.
- **Current page indicator**: Links use `aria-current="page"` to mark the current page, as per WCAG best practices.
- **Emoji handling**: Emoji spans have `aria-hidden="true"` to prevent redundant announcements.
- **Indicator handling**: Current-page indicator span has `aria-hidden="true"` (visual only).
- **Tooltip role**: Tooltip span has `role="tooltip"` to associate the site name as a tooltip.
- **Minimum tap target**: Touch target size is not specified in source and is defined by stylesheet; SHOULD be at least 44×44px per mobile HIG standards.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| orb-row-001 | must-render-orb-links | sites=[{id:"a",url:"https://site-a.com",name:"Site A",emoji:"🅰",iconGradient:"linear-gradient(...)"}] | Rendered `<a href="https://site-a.com">` element |
| orb-row-002 | must-set-navigation-role | (default) | Root element has `role="navigation"` and `aria-label="Agentic family"` |
| orb-row-003 | must-apply-current-state, must-set-aria-current | currentSite="a", sites with id "a" | Link with id "a" has class `is-current` and `aria-current="page"`; other links lack both. |
| orb-row-004 | must-apply-gradient-background | sites=[{...iconGradient:"linear-gradient(to right, #ff0000, #0000ff)"}] | Link's style attribute includes `background: linear-gradient(to right, #ff0000, #0000ff)` |
| orb-row-005 | must-render-emoji-hidden, must-render-tooltip-role | sites=[{name:"Example",emoji:"🎯"}] | Emoji in `<span aria-hidden="true">🎯</span>`; site name in `<span role="tooltip">Example</span>` |
| orb-row-006 | must-render-indicator-when-current | currentSite="x", sites with id "x" | Indicator `<span class="orb-row-here" aria-hidden="true"></span>` rendered inside current link |
| orb-row-007 | must-set-docked-class | docked=true | Root element includes `is-docked` class |
| orb-row-008 | must-apply-custom-class | className="custom-class" | Root element includes `custom-class` in its class list |
| orb-row-009 | must-render-emoji-hidden | (any site) | Emoji span is not selectable by assistive technology |
| orb-row-010 | must-set-aria-current | currentSite=null or not in sites list | No link has `aria-current` set |

## Edge Cases

- **Empty sites array**: Component renders a navigation container with no orbs. No error is thrown; the component degrades gracefully.
- **currentSite not in sites**: No orb receives the current state. The component does not error; aria-current is not applied to any link.
- **currentSite is null/undefined**: Same as above; no orb is marked current.
- **Missing site properties**: The component does not validate site properties and renders them directly without null or undefined checks. If any required property (url, name, emoji, iconGradient) is missing, the component will render an incomplete or broken link and the caller is responsible for ensuring all site data is well-formed.
- **className prop is empty string**: Empty strings are filtered out before joining; class attribute does not contain empty tokens.
- **docked=false and docked=undefined**: No `is-docked` class applied; both cases are treated identically.

## Configuration

Not applicable: This component accepts configuration only through React props (sites, currentSite, docked, className) defined at render time, not through a runtime configuration table.

## Deep Linking

Not applicable: This component contains links to other sites but does not itself define a deep-link target; deep linking to the orb-row component is not a use case.

## Localization

Not applicable: The component renders only the site names and emoji provided by the `sites` array; all text is data-driven and localization is handled by the caller passing localized site names.

## Accessibility Options

Not applicable: The component does not respond to accessibility display options (reduce motion, increase contrast, differentiate without color). Style changes for these options are the responsibility of the consuming stylesheet.

## Feature Flags

Not applicable: No feature flags are defined or consumed in the source code.

## Analytics

Not applicable: The component does not emit analytics events; navigation actions are handled by the browser (link navigation).

## Privacy

Not applicable: The component does not collect, transmit, or store user data.

## Logging

Not applicable: The component does not log diagnostic information.

## Platform Notes

- **React/Web**: OrbRow.tsx renders a semantic `<nav>` container with `role="navigation"`, mapping over the sites array to create links. The component applies a gradient background via inline style, manages the current state with conditional className and aria-current, and uses aria-hidden for decorative elements. Styling (dimensions, spacing, animations) is defined separately in the associated CSS.

- **SwiftUI**: Build from a VStack or LazyHStack of NavigationLink buttons, each with a circular background view colored by a gradient created from the site's iconGradient string. Bind the current site via selection state. Use Label to pair an emoji image with the site name, marking the emoji with isHidden if needed. Apply the conditional is-current state via a .border() or .overlay() modifier. Handle the docked state via .environment() or a conditional frame.

- **Compose**: Use a Row (or LazyRow for many sites) with NavigationLink or a custom onClick handler. Each item is a Column or Box with a background gradient (parsed from iconGradient), centered emoji, and Text for the name. Apply Modifier.padding() to match orb sizing and use .selectable() or a Modifier.background() state for the current page. The is-current class maps to a Modifier condition.

- **AppKit / UIKit**: Use a UIStackView or NSStackView (axis horizontal) with NSButton or UIButton subclasses styled as circular orbs. Apply the background gradient using CAGradientLayer or UIGradientView. Manage current state via button selection state (isSelected or highlighted). For a11y, set accessibilityLabel to site name, accessibilityTraits to .link, and set accessibilityCustomContent for aria-current equivalence. Render the emoji as an NSImageView or UIImageView from a font or symbol.

- **WinUI 3**: Create a repeating ItemsControl or ListView with a custom DataTemplate per site. Each template contains a Button with a Grid background (using a LinearGradientBrush created from the iconGradient string), centered TextBlock for the emoji, and a tooltip trigger showing the site name. Bind the current site to the ItemsControl.SelectedItem or use a VisualStateManager state group (named "CommonStates" + custom "IsCurrent") to toggle appearance. The is-current class maps to the "IsCurrent" VisualState, applying a border, scale transform, or color change. Handle docked via the Button.Margin property or a separate RootGrid.ColumnDefinitions binding.

## Design Decisions

The component treats the sites array as read-only and the currentSite prop as external state; it does not manage navigation or page state itself. Each site is a simple data object with url, name, emoji, and iconGradient provided by the caller. The use of aria-current="page" follows WCAG best practices for marking the active page in navigation landmarks. The emoji and indicator are marked aria-hidden because they are purely visual reinforcements of the site name conveyed by aria-label and the link href. The tooltip span's role="tooltip" signals to assistive technologies that the site name is contextual help, though CSS determines whether it is visually displayed on hover or always visible.

## Compliance

Not applicable: No specific compliance checks are defined in source or applicable external standards for this component.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.1.0 | 2026-09-22 | Mike Fullerton | Remove non-genuine review marker; clarify missing property handling in Edge Cases |
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
