---
id: 3ec6618a-03a4-4740-9655-e6e47c05cf2b
title: WindowFooterBar
domain: agenticdevelopertoolkit://recipes/window-footer-bar
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Fixed-height footer bar for window bottom edge with status text and trailing
  accessory slot.
platforms:
- swift
- macos
tags:
- window-chrome
- status-display
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# WindowFooterBar

## Overview

A fixed-height status bar component positioned at the bottom edge of a document window. It displays a status string at the leading edge (truncated by middle if too long, with full text as tooltip) and provides a trailing slot for accessory views such as progress indicators or badges. The component uses theme-aware colors and a hairline separator at the top edge.

## Behavioral Requirements

- **must-render-hairline**: Component MUST render a hairline separator at its top edge using the border theme role.
- **must-display-status-text**: Component MUST display the status string at the leading edge in caption text role with secondary text theme.
- **must-truncate-status-middle**: Component MUST truncate status text by the middle when it exceeds available width.
- **must-provide-tooltip**: Component MUST display the full status text as a tooltip when not empty; when status is empty, tooltip MUST be cleared.
- **must-maintain-height**: Component MUST maintain a fixed height of 22pt.
- **must-center-status-vertically**: Component MUST center-align the status label vertically within the bar.
- **must-support-trailing-accessories**: Component MUST accept an array of NSView objects for the trailing slot and render them in horizontal order.
- **must-center-trailing-vertically**: Component MUST center-align trailing accessory views vertically within the bar.
- **must-apply-trailing-spacing**: Component MUST apply 6pt spacing between trailing accessory views.
- **must-maintain-margins**: Component MUST maintain 10pt leading and trailing margins from the bar edges.
- **must-ensure-minimum-gap**: Component MUST maintain at least 8pt minimum gap between status label and trailing accessories when both are present.
- **must-support-theme**: Component MUST apply theme-aware colors: elevated surface background, border-role hairline, and secondary text.
- **must-accept-accessibility-prefix**: Component MUST require an accessibility prefix string during initialization.
- **must-set-status-accessibility-id**: Component MUST assign an accessibility identifier to the status label using the provided prefix (formatted as `{prefix}.status`).

## Appearance

- **Height**: 22pt (fixed)
- **Corner radius**: None (rectangular)
- **Padding**: Leading 10pt, trailing 10pt (from bar edges); 8pt minimum horizontal gap between status and accessories
- **Font**: Caption text size (inherited from ThemedLabel secondary text role)
- **Background**: Themed elevated surface
- **Foreground/Text**: Themed secondary text color
- **Border**: 1pt hairline at top edge, themed border role
- **Shadow**: None
- **Spacing**: 6pt between trailing accessory views; status label centered vertically, trailing accessories centered vertically

## States

| State | Appearance change |
|-------|------------------|
| Default | Status text visible; hairline and background applied; trailing accessories visible if present |
| Status truncated | Status text truncated by middle; full text available in tooltip on hover |
| Empty status | Tooltip cleared; label space available for trailing accessories |
| Empty accessories | Trailing slot hidden; status text uses available horizontal space |

## Accessibility

- **Role**: Container (NSView subclass; does not have an interactive role itself)
- **Status label**: Assigned accessibility ID using provided prefix
- **Label requirements**: Status text serves as the accessible content; full untruncated text is available via tooltip
- **State changes**: Status text updates are reflected in accessibility element content
- **Minimum tap target**: Not applicable; component is not interactive

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| window-footer-001 | must-maintain-height | Component instantiated with any status | Bar height equals 22pt |
| window-footer-002 | must-render-hairline | Component rendered | Hairline separator visible at top edge |
| window-footer-003 | must-display-status-text | `status = "File.txt"` | Text "File.txt" visible at leading edge |
| window-footer-004 | must-truncate-status-middle | `status = "very/long/file/path/that/exceeds/available/width.txt"` | Text truncated in middle with ellipsis; full path accessible via tooltip |
| window-footer-005 | must-provide-tooltip | `status = "example text"` | Hovering over status displays full "example text" |
| window-footer-006 | must-provide-tooltip | `status = ""` | No tooltip displayed |
| window-footer-007 | must-center-status-vertically | Component rendered | Status label vertically centered within 22pt height |
| window-footer-008 | must-support-trailing-accessories | `trailingAccessories = [view1, view2]` | Both views rendered horizontally in trailing slot |
| window-footer-009 | must-apply-trailing-spacing | `trailingAccessories = [view1, view2]` | 6pt horizontal space between view1 and view2 |
| window-footer-010 | must-center-trailing-vertically | `trailingAccessories = [view1, view2]` | Accessory views vertically centered within bar |
| window-footer-011 | must-support-trailing-accessories | `trailingAccessories = []` then `trailingAccessories = [newView]` | Previous accessory removed; newView rendered in its place |
| window-footer-012 | must-set-status-accessibility-id | `init(accessibilityPrefix: "project.footer")` | Status label accessibility ID is "project.footer.status" |

## Edge Cases

- **Empty status string**: Status label renders as empty; tooltip is nil; trailing accessories have full trailing slot width.
- **Very long status string**: Text is truncated by middle; tooltip preserves full string; no horizontal scroll occurs.
- **Empty trailing accessories array**: Trailing slot is empty; no layout errors occur; status label can expand to available width.
- **Rapid status updates**: Status text and tooltip update without layout thrashing; component remains at fixed 22pt height.
- **Trailing accessories with varying heights**: All accessories center-aligned vertically to bar center; no clipping or overflow.
- **Accessory replacement**: Existing accessories removed from view hierarchy and replaced with new array; no memory leaks or dangling views.
- **Long accessory list**: Accessories squeeze toward trailing edge; 6pt spacing maintained; minimum gap (8pt) from status preserved until width exhausted.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `accessibilityPrefix` | String | (required) | Namespace for accessibility identifiers; used to derive status label ID |

## Deep Linking

Not applicable: WindowFooterBar is a non-interactive display component with no user navigation targets.

## Localization

Not applicable: Component displays application-provided status strings; no hardcoded user-facing text.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Animation not applicable; component is static display |
| Increase Contrast | Component respects theme-aware colors; no additional configuration needed |
| Differentiate Without Color | Status text is the primary affordance; no color-only status indicators |

## Feature Flags

Not applicable: No feature flags referenced in component implementation.

## Analytics

Not applicable: Component is passive display element with no user interactions.

## Privacy

Not applicable: Component displays caller-provided status strings; no data is collected, stored, or transmitted.

## Logging

Not applicable: No logging instrumentation defined in component source.

## Platform Notes

- **AppKit** (source): `WindowFooterBar` in `packages/apple/AgenticDeveloperToolkit/SourcesUI/macOS/Chrome/WindowFooterBar.swift`. Composed of `NSStackView` for trailing accessories and `NSView` constraints for layout. Uses `ThemedLabel`, `ThemedBackgroundView`, and `ThemedSeparatorView` for theme integration. Accessibility requires string prefix at init time.
- **SwiftUI**: Implement as a view container with a ZStack or VStack. Leading edge contains a Text view with `lineLimit(1)` and `.truncationMode(.middle)`. Trailing edge uses HStack with 6pt spacing for accessories. Apply a Divider at top. Use `@Environment(\.colorScheme)` for theme-aware colors. Set accessibility identifier via `.accessibilityIdentifier()` modifier.
- **Compose**: Use Row layout with `horizontalArrangement = Arrangement.SpaceBetween`. Leading slot: Text with `maxLines = 1`, `overflow = TextOverflow.Ellipsis`. Divider at top with border. Trailing slot: Row with 6dp spacing for accessories. Apply Material 3 surface colors. Accessibility ID via `testTag()` or `semantics()`.
- **UIKit**: Implement as UIView subclass. Use UIStackView (horizontal) for layout. Leading: UILabel with `lineBreakMode = .byTruncatingMiddle`. Add UIView separator at top via CALayer. Trailing: UIStackView (horizontal) with 6pt spacing. Apply UIColor semantic colors for elevated surface and border. Set accessibilityIdentifier on label.
- **WinUI 3**: Implement as a UserControl containing a Grid. Top row: Border with 1pt stroke for hairline. Content row: StackPanel (Horizontal). Leading cell: TextBlock with `TextTrimming="CharacterEllipsis"` and tooltip via ToolTipService.SetToolTip. Trailing cell: StackPanel (Horizontal) with 6pt spacing for Buttons or other controls. Use Fluent 2 SurfaceAlt and Divider tokens. Set `AutomationProperties.AutomationId` with prefix.

## Design Decisions

- **Fixed height of 22pt**: Designed to visually balance with macOS tab bar height, ensuring windows with both elements appear compositionally stable rather than bottom-heavy.
- **Truncation by middle**: Status strings are typically paths or identifiers where the end (filename or key identifier) is more important than the beginning (directory structure). Middle truncation preserves both ends, maximizing user recognition when text is clipped.
- **Required accessibility prefix**: Window contexts vary (multiple window types sharing footer bar code); requiring a prefix ensures accessibility identifiers are unique per window type and testable in UI automation, avoiding ambiguity.
- **Margin consistency (10pt leading/trailing)**: Matches standard macOS window chrome margin conventions; 8pt inter-element gap ensures breathing room between status text and accessories without excessive waste.
- **Trailing accessory array over slot builder**: Fixed array property is simpler for callers to manage than a closure; removal and replacement are explicit and obvious, reducing layout surprises.

## Compliance

Not applicable: No compliance checks defined for this ingredient.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from WindowFooterBar.swift source |
