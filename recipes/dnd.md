---
id: d8f2a1c3-9e4b-4a7b-8c6d-2f9a1e5b3c7d
title: Drag-and-Drop
domain: agenticdevelopertoolkit://recipes/dnd
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Reorderable lists and boards, plus free-form dragging for calendars and timelines.
platforms:
- typescript
- web
tags:
- drag-and-drop
- ordering
- interaction
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Drag-and-Drop

## Overview

Two distinct drag surfaces: **SortableSurface** for ordered collections (lists or multi-column boards) that report drop position as neighboring items rather than indexes — a safety measure against concurrent reordering; and **DragSurface** for unordered placement (calendar chips landing on dates, timeline bars moving along one axis). Both support pointer and keyboard interaction. The component is a thin wrapper over `@dnd-kit`, unifying its API so views speak one vocabulary for drop position and axis constraint.

## Behavioral Requirements

- **must-accept-sortable-model**: SortableSurface MUST accept a zones array describing ordered collections and their items.
- **must-accept-drag-surface-config**: DragSurface MUST accept an item ID, optional target ID, and pixel delta on drop.
- **must-report-drop-position**: SortableSurface MUST report drop position as `afterId` (item before the dropped item, or null if dropped at top) and `beforeId` (item after, or null if dropped at bottom).
- **must-ignore-no-op-reorder**: SortableSurface MUST NOT report a drop if the item lands in its original position.
- **must-activate-pointer-drag-after-distance**: Pointer drags MUST NOT start until the pointer has moved at least 5 pixels from its starting position.
- **must-re-measure-drop-targets-during-drag**: Droppable zones MUST be re-measured continuously during a drag (not just at drag start), to accommodate zones that grow or scroll during the operation.
- **must-support-pointer-and-keyboard-interaction**: Both SortableSurface and DragSurface MUST support pointer drags and MUST provide keyboard interaction (drag start, arrow keys to move, Enter to drop, Escape to cancel) when keyboard sensor is enabled.
- **must-render-overlay-optionally**: SortableSurface and DragSurface MUST render a DragOverlay component under the pointer during a drag when renderOverlay prop is provided; when omitted, no overlay is rendered.
- **may-constrain-axis**: DragSurface MAY accept an `axis` prop to constrain movement to the x or y axis only.
- **may-render-grip-handle**: DragGrip MAY render a span element with grab/grabbing cursor, icon, and optional accessible label.
- **must-announce-drag-events**: SortableSurface and DragSurface MUST provide accessibility announcements (via aria-live regions) for drag start, drag over a target, drag end, and drag cancel events.
- **must-support-optional-descriptions**: SortableSurface MUST accept `describeItem` and `describeZone` callbacks to customize item and zone names in announcements; DragSurface MUST accept `describeItem` and `describeTarget` callbacks.
- **must-detect-collision-by-closest-corners**: Both surfaces MUST use the `closestCorners` collision detection strategy (not center, overlap, or other strategies).
- **must-set-dragging-item-opacity-low**: During a pointer drag in SortableSurface, the dragged item's element MUST have opacity 0.4 to indicate it is lifted, while the overlay renders the visual representation under the pointer.
- **must-position-drag-item-above-others**: During a pointer drag in DragSurface, the dragged element MUST have `zIndex: 20` and `position: relative` to appear above other content.
- **must-disable-touch-scroll-on-grip**: DragGrip MUST apply the `touch-none` CSS class to prevent browser touch-scroll gesture from interfering with the pointer sensor.
- **should-support-horizontal-layout**: SortableSurface SHOULD accept an `orientation` prop set to `"horizontal"` to handle zones laid out left-to-right; the default orientation is `"vertical"`.
- **must-disable-draggables-conditionally**: Both SortableItem and DragItem MUST accept an `enabled` prop (default true) to disable dragging for specific items (e.g., filtered rows, busy rows).
- **may-spread-keyboard-attributes-conditionally**: SortableItem and DragItem MAY accept a `keyboard` prop (default true for SortableItem, false for DragItem) to control whether dnd-kit's keyboard attributes are spread onto the handle; when false, only listeners are spread.
- **must-provide-sortable-zone-droppable**: SortableZone MUST register its own droppable (via useDroppable) so that drops into an empty zone are reachable.

## Appearance

- **Grip handle cursor**: grab when at rest, grabbing when actively dragging
- **Grip handle icon**: GripVertical from lucide-react, size 14px
- **Grip background color**: apt-text-muted at rest, apt-text on hover
- **Dragged item opacity**: 0.4 during drag in SortableSurface
- **Dragged element z-index**: 20 during drag in DragSurface
- **Grip focus ring**: 2px ring with apt-gold/25 color on focus-visible
- **Grip dimensions**: 6px height, 4px width (w-4 in Tailwind), inline-flex layout
- **Border radius**: rounded (default Tailwind value)
- **Transition**: colors transition smoothly on state change (hover, active)

## States

| State | Appearance change |
|-------|------------------|
| Default | Grab cursor, muted text color |
| Hover | Text color brightens to apt-text |
| Focus (keyboard) | 2px ring with apt-gold/25 |
| Active (pressing down) | Cursor changes to grabbing |
| Dragging (pointer) | Grip remains visible; dragged item (SortableSurface) becomes opacity 0.4 or (DragSurface) positioned relative with z-index 20 |
| Disabled | Handle does not accept drag events |

## Accessibility

- **Role**: DragGrip renders as a span but receives `role="button"` and `tabIndex=0` from dnd-kit's attributes (when keyboard sensor is enabled), making it keyboard-focusable and operable.
- **Label**: DragGrip MUST have an accessible name via aria-label ("Reorder" or "Reorder {subject}" when subject is provided).
- **Announcements**: Live region announcements MUST announce when an item is picked up, when it is dragged over a target or over no target, when it is dropped, and when dragging is cancelled.
- **Keyboard navigation**: Arrow keys move the dragged item to adjacent items (respecting orientation and axis constraints). Enter confirms the drop. Escape cancels the drag.
- **Icon**: GripVertical icon MUST have `aria-hidden="true"` because the accessible affordance is the label and role, not the icon.
- **Minimum touch target**: DragGrip is 24px wide × 24px tall, meeting the 44×44pt minimum on most devices (though smaller on web where density is higher); depends on context.
- **No nested buttons**: DragGrip renders as span (not button) because dnd-kit may spread `role="button"` onto it, and a nested button inside a button is invalid. When the handle is inside another button (calendar chip, timeline bar), the `keyboard` prop MUST be false to prevent spreading attributes.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| dnd-001 | must-accept-sortable-model | SortableSurface with zones array containing two zones, each with two items | Surface renders without error; zones are droppable |
| dnd-002 | must-report-drop-position | Drag item from position 1 to position 2 in same zone | onDrop callback receives { itemId, fromZoneId, toZoneId, afterId (item at pos 1), beforeId (item at pos 3) } |
| dnd-003 | must-ignore-no-op-reorder | Drag item in same zone and drop it in its original position | onDrop callback is NOT invoked |
| dnd-004 | must-activate-pointer-drag-after-distance | Pointer moves 3px from start; then moves 6px from start | Drag does not start at 3px; drag starts and active state is set at 6px+ |
| dnd-005 | must-re-measure-drop-targets-during-drag | Start drag; zone grows in height mid-drag; drop item | Drop calculation uses the updated zone rect, not the original |
| dnd-006 | must-support-pointer-and-keyboard-interaction | Focus on SortableItem's grip; press Space or Enter to start; press Arrow Up/Down to move; press Enter to drop | Drag starts, item moves, drag completes and onDrop is called |
| dnd-007 | must-render-overlay-optionally | SortableSurface with renderOverlay prop provided | DragOverlay renders the result of renderOverlay(itemId) under pointer during drag |
| dnd-008 | must-render-overlay-optionally | SortableSurface without renderOverlay prop | No DragOverlay appears during drag |
| dnd-009 | may-constrain-axis | DragSurface with axis="x" | Dragging vertically has no effect; only horizontal movement is possible |
| dnd-010 | may-constrain-axis | DragSurface with axis="y" | Dragging horizontally has no effect; only vertical movement is possible |
| dnd-011 | must-announce-drag-events | Focus on grip and start drag via keyboard; listen to screen reader announcements | Announcement includes "Picked up {itemName}" |
| dnd-012 | must-support-optional-descriptions | SortableSurface with describeItem={(id) => `Card ${id}`} and describeZone={(id) => `Column ${id}`} | Announcements use "Card X" and "Column Y" instead of bare IDs |
| dnd-013 | must-detect-collision-by-closest-corners | Drag item toward edge of two zones; drop | Item lands in the zone whose corner is closest, not by center or overlap |
| dnd-014 | must-set-dragging-item-opacity-low | Start pointer drag in SortableSurface; inspect element style during drag | `opacity: 0.4` is applied to the dragged item's element |
| dnd-015 | must-position-drag-item-above-others | Start pointer drag in DragSurface; inspect element style during drag | `zIndex: 20` and `position: relative` are applied |
| dnd-016 | must-disable-touch-scroll-on-grip | On touch device, attempt to scroll by dragging on a DragGrip | Pointer sensor receives the move events; browser does not consume scroll |
| dnd-017 | should-support-horizontal-layout | SortableSurface with orientation="horizontal" | Drop calculation uses horizontal center-crossing logic (left+width/2) instead of vertical |
| dnd-018 | must-disable-draggables-conditionally | SortableItem with enabled={false} | Item cannot be picked up; pointer and keyboard sensors are inactive for this item |
| dnd-019 | may-spread-keyboard-attributes-conditionally | SortableItem with keyboard={false} | Only listeners are spread on handleProps; no `role`, `tabIndex`, or attributes are included |
| dnd-020 | must-provide-sortable-zone-droppable | SortableZone with empty itemIds array | Zone's own droppable is reachable; dropping into it lands item at the end of that (empty) zone |

## Edge Cases

- **Empty zone drop target**: When a zone has no items, the zone's own droppable (via useDroppable) is the only collision target. A drop onto an empty zone lands the item at index 0 (afterId = null, beforeId = null).
- **Drag with no target**: Dragging outside all zones and releasing MUST NOT invoke onDrop (checked via `if (!over) return`).
- **Drag originating from invalid zone**: If the dragged item's zone cannot be determined from the zone model, the drag is ignored (checked via `if (fromZoneId === undefined) return`).
- **Cross-zone reorder**: Item is picked up from Zone A and dropped into Zone B. onDrop reports both fromZoneId and toZoneId; the view is responsible for updating its data model.
- **Concurrent drags**: Only one drag is active at a time; new drags are blocked by dnd-kit until the previous drag ends.
- **Concurrent reorders by multiple users**: The SortableDrop report uses item neighbors (afterId, beforeId) rather than indexes, allowing two users to reorder the same collection simultaneously without index collision. Each reports a position relative to two neighbors, which remains valid even if other items are inserted elsewhere.
- **Keyboard drag on disabled item**: When enabled={false}, keyboard sensor does not activate for that item.
- **Pointer on disabled item**: When enabled={false}, pointer sensor does not activate for that item.
- **Drag inside a button**: When the draggable is inside a button element (e.g., a calendar chip, timeline bar), setting keyboard={false} prevents spreading dnd-kit's `role="button"` onto the handle, avoiding a nested button violation.
- **Viewport scroll during drag**: If a scrollable parent scrolls during a drag (e.g., user scrolls a list while dragging), the drop position calculation accounts for the new scroll offset because droppables are re-measured continuously.
- **Overlay rendering fails**: If renderOverlay callback throws an error, DragOverlay still renders but with no content (null). Drag operation is not interrupted.
- **Missing zone in model**: If a zone ID appears in itemsOfZone but not in the zones array passed to the surface, that zone is still droppable, but the view may have inconsistent state.

## Configuration

Not applicable: This component accepts configuration via React props (zones, callbacks, orientation, axis, keyboard) rather than a configuration object. Each surface type (SortableSurface, DragSurface) and item type (SortableItem, DragItem) is configured inline at render time.

## Deep Linking

Not applicable: These drag-and-drop components are interaction primitives with no URL-based state representation or deep link targets.

## Localization

Not applicable: The component renders no user-facing text strings. Accessible names ("Reorder", "Reorder {subject}", item/zone descriptions) are provided by the caller via callbacks (describeItem, describeZone, describeTarget) or via aria-label props, allowing the host app to localize.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Transitions and animations are still applied by dnd-kit (CSS transitions on transform and opacity). A consume-media-query hook or prefers-reduced-motion CSS class in the host app can disable these separately. |
| Increase Contrast | Grip handle's focus ring uses apt-gold/25; contrast may be insufficient for WCAG AA. Host app SHOULD apply a higher-contrast focus ring via CSS override if required. |
| Differentiate Without Color | Grip's hover state uses color change only; consider adding an outline or underline in the host app if users cannot distinguish color. |

## Feature Flags

Not applicable: No feature flags are built into the component. The host app MAY conditionally render SortableSurface or DragSurface based on its own feature flags.

## Analytics

Not applicable: The component does not emit analytics events. The host app SHOULD instrument onDrop callbacks to log drag operations (e.g., "user reordered items", "user moved card to column").

## Privacy

Not applicable: The component does not collect, store, or transmit any user data beyond the immediate drop event (itemId, zone IDs, neighbors). No tracking, logging, or analytics are built in.

## Logging

Not applicable: No logging subsystem is built into the component. Errors (e.g., missing zone, invalid item ID) are silently ignored in onDragEnd callbacks. Host apps MAY add their own logging via onDrop callbacks if needed.

## Platform Notes

- **React/Web**: Source is `packages/web/packages/ui/src/components/dnd.tsx`. SortableSurface and DragSurface wrap `@dnd-kit/core` (DndContext, DragOverlay, sensors) and `@dnd-kit/sortable` (SortableContext, useSortable). Accessibility announcements are driven by dnd-kit's built-in Announcements API (via aria-live). The component uses CSS transforms for drag positioning (via CSS.Translate from @dnd-kit/utilities) and Tailwind classes for static styling. Grip handle renders as a span and accepts attributes from dnd-kit when keyboard={true}, or listeners only when keyboard={false}.
- **Swift/iOS**: Native implementation would start from UIDragInteraction (iOS 11+) for pointer drag recognition and UIAccessibility announcements for screen reader support. Zones would map to UITableView or UICollectionView sections. Items would be draggable cells. DragSurface analogue would disable multi-select and use UIDropInteraction to detect landing zones. A separate keyboard accessibility API (custom actions, VoiceOver rotor) would handle keyboard interaction in lieu of pointer.
- **Kotlin/Android**: Native implementation would start from the Material Design drag-and-drop APIs and compose for Jetpack Compose. Zones map to LazyColumn or LazyRow sections. Items are draggable composables. DragSurface analogue uses custom drag-and-drop with PointerInput and touch events. Keyboard interaction is handled via KeyEvent callbacks and accessibility focus management. Announcements use AccessibilityEventCompat.
- **WinUI 3**: Start from UIElement.ManipulationStarted, ManipulationDelta, and ManipulationCompleted events for pointer drag recognition. Zones are ItemsControl or GridView with custom drag adorner layer. Use XAML Storyboard animations for visual feedback. Keyboard interaction via KeyDown (Arrow keys, Enter, Escape). Announcements use AutomationPeer and UIA_Live_PropertyId (polite or assertive). Drop position reporting requires hit testing on the destination element tree; WinUI does not have a built-in "collision detection" system, so you must manually compute which zone and neighbor the drag crosses using TransformToVisual and GetElementBounds.
- **Pattern (all platforms)**: The core pattern is pointer and keyboard sensor registration, collision detection, and neighbor-based drop reporting. The web version uses dnd-kit to provide these; native platforms must implement them separately, leaning on platform drag-drop APIs where available and custom gesture recognition where not.

## Design Decisions

- **Neighbors over indexes**: SortableDrop reports `afterId` and `beforeId` rather than an index. This solves the concurrent reorder problem where two users simultaneously reorder the same collection — each reports a position relative to two neighbors, which remains valid even if items are inserted elsewhere. An index-based report would be ambiguous when the list changes mid-operation.
- **Pointer activation distance**: 5 pixels is the minimum distance before a pointer drag is recognized. This allows clicks and taps on draggable items to reach their own event handlers (e.g., a card's select or edit button) without immediately starting a drag.
- **Continuous re-measurement**: Droppables are re-measured on every drag move (MeasuringStrategy.Always), not just at drag start. This accommodates zones that grow, shrink, or scroll during the operation.
- **No-op reorder ignored**: If a drag ends with the item landing in its original position (same zone and neighbors), onDrop is not invoked. This avoids spurious writes to the backend for a user who simply jiggles an item.
- **Keyboard attributes optional**: SortableItem and DragItem conditionally spread dnd-kit's `role="button"` and `tabIndex` onto the handle. When keyboard={false}, only listeners are spread. This prevents nested `role="button"` violations when the handle is inside another button (e.g., calendar chip, timeline bar).
- **Overlay optional**: If renderOverlay is omitted, no DragOverlay is rendered. This allows lightweight drag feedback (e.g., just opacity change on the original item) for simple scenarios.
- **Axis constraint for free drag**: DragSurface MAY be constrained to the x or y axis to reflect the semantic meaning of the drag (e.g., a timeline bar moves horizontally to change date; vertical movement is noise). SortableSurface does not support axis constraint because reordering inherently moves along the layout axis.
- **Touch-none CSS on grip**: The Tailwind class `touch-none` is applied to DragGrip to prevent the browser from claiming the touch gesture for scroll. Without it, a touch drag on the grip would be consumed by the browser's scroll handler, and the pointer sensor would never see a move event.

## Compliance

Not applicable: This component is a UI interaction primitive with no compliance checks (accessibility, security, data handling) that exist outside the platform's existing guidelines. Host apps are responsible for ensuring their use of the component (e.g., keyboard support, focus management, error handling) meets WCAG and platform guidelines.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from source |
