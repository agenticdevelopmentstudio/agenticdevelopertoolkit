---
id: 9c5e7d75-e253-4dce-b12c-7eaede9ee405
title: Pane Title Bar View
domain: agenticdevelopercookbook://ingredients/pane-title-bar-view
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A fixed-height title bar for document panes with truncated title, trailing
  gear control, and variable accessory area.
platforms:
- swift
tags:
- ui
- chrome
- macos
depends-on: []
related: []
references: []
---

# Pane Title Bar View

## Overview

The Pane Title Bar View is a reusable chrome component that renders the title bar for a document pane within a multi-pane editor. It provides four regions in left-to-right order: leading controls (close/minimize/zoom buttons), title text, accessory views supplied by the pane's content, and a trailing gear button for options. The title truncates in the middle when space is constrained, and the gear control remains at the trailing edge regardless of content width, establishing a consistent visual anchor across all panes in a window.

## Behavioral Requirements

- **must-render-title-label**: The component MUST render a text label displaying the current title text.
- **must-truncate-title-in-middle**: The component MUST truncate the title text in the middle (not at trailing edge) when the available width is insufficient to display the full title.
- **must-sync-tooltip-with-title**: The component MUST set the title label's tooltip to the full title text when the title is non-empty, and clear it (set to nil) when the title is empty.
- **must-render-fixed-height**: The component MUST have a fixed height of 26pt and MUST NOT resize vertically based on content.
- **must-support-accessory-views**: The component MUST support an ordered array of accessory views positioned between the title and the gear control.
- **must-replace-accessory-views-atomically**: When the accessory views array is replaced, the component MUST remove all previous accessory views from the view tree and add all new views in the provided array order.
- **must-support-optional-gear-view**: The component MUST support an optional gear view supplied by the pane owner and positioned at the trailing edge, with a default trailing margin of 6pt from the pane edge.
- **must-keep-gear-trailing**: When a gear view is present, the component MUST keep it at the trailing edge and constrain all other content to its leading side, maintaining a 6pt gap between the accessory stack and the gear.
- **must-center-content-vertically**: The component MUST vertically center all child elements (controls, title label, accessory views, gear view) within the bar.
- **must-honor-yield-width-request**: When `yieldWidthToContainer()` is called, the component MUST set the content compression resistance priority of itself and all subviews (depth-first) to the lowest value (1) for the horizontal axis, allowing the container to constrain its width without resistance.
- **must-apply-yield-to-future-subviews**: When width-yielding is enabled, any accessory views or gear views added after the call to `yieldWidthToContainer()` MUST also have their compression resistance priority set to the lowest value for the horizontal axis.
- **should-spacing-between-accessories**: The component SHOULD maintain 4pt spacing between consecutive accessory views.

## Appearance

- **Height**: 26pt (fixed)
- **Background**: Themed elevated surface color (via ThemedBackgroundView with role `.elevatedSurface`)
- **Bottom border**: 1pt hairline separator using themed border color (via ThemedSeparatorView with role `.border`)
- **Title label**: 13pt body text role, primary text color (via ThemedLabel)
- **Accessory stack spacing**: 4pt between items, centered vertically
- **Leading margin**: 6pt from leading edge to controls cluster
- **Title leading margin**: 8pt from controls trailing edge to title label
- **Accessory leading margin**: 8pt minimum gap from title trailing edge to accessory stack leading edge (when title is visible)
- **Trailing margin**: 6pt from gear view (or accessory stack if no gear) to pane edge

## States

| State | Appearance change |
|-------|------------------|
| With title | Title text is displayed |
| Empty title | Title label is empty; tooltip is nil |
| No gear view | Accessory stack extends to trailing margin (6pt from edge) |
| Gear view present | Accessory stack stops at gear leading edge with 6pt gap |
| No accessory views | Accessory stack is empty; title and gear remain visible |

## Accessibility

- **Label**: The title label is assigned accessibility ID `pane.title` so assistive technologies can identify the pane name.
- **Role**: The component itself is a container; child elements (title label, controls, gear) provide their own accessibility semantics.
- **Title text**: The title SHOULD be meaningful and not truncated in accessibility announcements — the full title is available via the tooltip property.
- **Assistive technology**: The component does not announce state changes; it is a static chrome element.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| pane-title-bar-001 | must-render-title-label | Initialize component; set title to "My File.txt" | Title label displays "My File.txt" |
| pane-title-bar-002 | must-sync-tooltip-with-title | Set title to "Long File Name"; then set title to "" | Tooltip equals "Long File Name" after first set; tooltip is nil after second set |
| pane-title-bar-003 | must-render-fixed-height | Initialize component; read height | Height is exactly 26pt |
| pane-title-bar-004 | must-truncate-title-in-middle | Set title to "VeryLongFileName.extension"; constrain pane width to 80pt | Title text truncates in middle (e.g., "VeryLong...extension") not "VeryLongFile..." |
| pane-title-bar-005 | must-support-accessory-views | Set accessoryViews to [viewA, viewB] | Both views appear in accessory stack in order |
| pane-title-bar-006 | must-replace-accessory-views-atomically | Set accessoryViews to [viewA]; then set to [viewC, viewD] | viewA is removed from view tree; viewC and viewD appear in order; no views are orphaned |
| pane-title-bar-007 | must-support-optional-gear-view | Initialize component; gearView is nil by default | Gear area is empty; accessory stack extends to trailing margin |
| pane-title-bar-008 | must-support-optional-gear-view, must-keep-gear-trailing | Set gearView to a button; set accessoryViews to [viewA] | Gear button appears at trailing edge; viewA appears to its left with 6pt gap |
| pane-title-bar-009 | must-center-content-vertically | Initialize component; inspect layout | Title label centerY equals bar centerY; accessory stack centerY equals bar centerY; gear centerY equals bar centerY |
| pane-title-bar-010 | must-honor-yield-width-request | Call yieldWidthToContainer(); inspect constraints | Component no longer demands intrinsic width; parent can set any width >= 0 without resistance |
| pane-title-bar-011 | must-apply-yield-to-future-subviews | Call yieldWidthToContainer(); then set gearView; inspect gear constraint | Gear has compression resistance priority 1 (minimum) for horizontal axis |
| pane-title-bar-012 | should-spacing-between-accessories | Set accessoryViews to [viewA, viewB]; inspect stack spacing | Spacing between viewA and viewB is 4pt |

## Edge Cases

- **Empty title**: Setting title to empty string sets tooltip to nil. Subsequent title sets restore tooltip if title is non-empty.
- **Very long title**: Title truncates in middle; full text is preserved in tooltip and is reachable via accessibility.
- **No accessory views**: Accessory stack is empty but present; layout remains valid with title and optional gear only.
- **Rapid accessory replacement**: If accessory views are replaced while still measuring layout, new views are added to stack in order; old views are removed atomically before new ones are added.
- **No gear view**: Accessory stack extends to 6pt trailing margin; setting gear later repositions accessory stack and activates new trailing constraint.
- **Width constraint below minimum**: When yielding width and container constrains bar to very narrow width (< 26pt), title truncates completely and accessory views may be clipped. Gear remains visible at trailing edge.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `title` | String | "" | The pane's title text, displayed in the label and as tooltip when non-empty. |
| `accessoryViews` | [NSView] | [] | Array of views to display between title and gear, in left-to-right order. |
| `gearView` | NSView? | nil | Optional view for the trailing gear button or menu control, positioned at trailing edge. |

## Deep Linking

Not applicable: This is a chrome component without user-addressable content requiring deep linking.

## Localization

Not applicable: The component displays no user-facing strings of its own; localization is the responsibility of the title text and accessory views supplied by the pane's content.

## Accessibility Options

Not applicable: The component does not respond to system accessibility display options (reduce motion, increase contrast, differentiate without color); it renders static chrome.

## Feature Flags

Not applicable: No feature flags are defined in the source code.

## Analytics

Not applicable: This component does not own analytics tracking; such concerns belong to the pane content and application layer.

## Privacy

Not applicable: The component does not collect, store, or transmit data.

## Logging

Not applicable: No logging is defined in the source code.

## Platform Notes

- **Source (AppKit/macOS)**: `PaneTitleBarView.swift` uses NSView, NSStackView, NSLayoutConstraint, and AppKit-specific classes (ThemedBackgroundView, ThemedSeparatorView, ThemedLabel, PaneControlCluster). The layout is achieved entirely via Auto Layout constraints. The title label has `lineBreakMode = .byTruncatingMiddle` to truncate in the middle. Compression resistance priorities are used to yield width to the container.

- **SwiftUI**: A SwiftUI equivalent would use HStack as the root container with fixed height via `frame(height: 26)`. The title would be a Text view with `.lineLimit(1)` and `.truncationMode(.middle)`. Accessory views would be inserted into the HStack dynamically via a ForEach loop. The gear would be anchored to the trailing edge within the HStack, and `.layoutPriority` would control compression resistance for width-yielding. Background and border would use ZStack with custom modifiers.

- **Compose (Android)**: A Compose equivalent would use Row with `modifier = Modifier.height(26.dp)` and `horizontalArrangement = Arrangement.Center` (vertical centering via `verticalAlignment = Alignment.CenterVertically`). The title would be a Text composable with `overflow = TextOverflow.Ellipsis` and `maxLines = 1`, but truncation behavior requires custom layout logic. Accessory views and gear would be Box composables added to the Row in order. Spacer with `weight(1f)` would handle width-yielding. Background would be applied via `modifier.background()`.

- **AppKit / UIKit**: UIKit equivalent (iOS) would replace NSStackView with UIStackView, NSView with UIView, and use UILabel for the title with `lineBreakMode = .byTruncatingMiddle`. Layout would use UIStackView's `alignment = .center` for vertical centering. Constraints use the same NSLayoutConstraint API as AppKit. UIAppearance or custom view subclasses would replace themed views. macOS via AppKit (the source) is the definitive implementation.

- **WinUI 3**: A WinUI 3 equivalent would use StackPanel with `Orientation="Horizontal"` and `Height="26"` (pixels). The title would be a TextBlock with `TextTrimming="CharacterEllipsis"` and `TextWrapping="NoWrap"`, but center-truncation requires a custom TextBlock subclass or layout override. The gear Button would be right-aligned via StackPanel child properties (HorizontalAlignment="Right"). Background would be set via the StackPanel's Background property. Accessory items would be added to the StackPanel's Children collection. Width-yielding maps to `HorizontalAlignment="Stretch"` with `MaxWidth` removed.

## Design Decisions

- **Middle truncation over trailing**: The title truncates in the middle rather than at the trailing edge because the gear button's position serves as a consistent visual anchor across all panes. Truncating the trailing end would push the gear off-screen when space is tight; truncating the middle preserves the gear's position and ensures users can always identify and access the pane options menu.

- **Fixed height of 26pt**: The height of 26pt is explicitly chosen to accommodate a 13pt label and small square button (control cluster) while keeping chrome minimal so a three-pane editor does not spend a quarter of its height on chrome. This is a non-negotiable trade-off between readability and usable content area.

- **Width-yielding as opt-in**: The `yieldWidthToContainer()` method is not called by default. It must be explicitly called by the container (e.g., a split view dividing width). This opt-in approach keeps the component's default behavior consistent — it declares its preferred width — while allowing containers that need flexible width division to override that preference. The default respects the intrinsic width needs of the title and controls; the override supports constrained layouts.

- **Atomic replacement of accessory views**: When the accessory views array is reassigned, all old views are removed from the view tree before new ones are added. This atomic replacement prevents temporary visual glitches where old and new views might briefly coexist, and it ensures layout is consistent and predictable.

- **Tooltip mirrors title**: The title label's tooltip is synchronized with the title text. When truncation occurs, users can hover over the title to see the full text. This pattern is standard in AppKit and reduces the need for separate UI to display the complete title.

## Compliance

Not applicable: No compliance concerns (security, data privacy, accessibility legal requirements) are applicable to this component beyond standard UI accessibility, which is addressed in the Accessibility section.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude | Initial creation from source code |
