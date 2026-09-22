---
id: d8f2a4c1-9e5b-4a2f-b8c9-e7f3a2d5c1b6
title: "Markdown Document Editor"
domain: agenticdevelopertoolkit://recipes/markdown-document-editor
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: 2026-09-22
author: Claude Haiku 4.5
copyright: 2026 Agentic Developer Toolkit
license: MIT
summary: "A markdown source editor with live preview, responsive layout toggling between split and tabbed views, and debounced rendering."
platforms:
- typescript
- web
- swift
- macos
- ios
tags: 
  - markdown
  - editor
  - form-input
  - live-preview
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Markdown Document Editor

## Overview

A markdown document editing component that pairs a source editor with a live preview pane. The component responds to viewport width: on wide viewports it displays editor and preview side-by-side in a split view; on narrow viewports it switches to a tabbed interface showing one pane at a time. Preview rendering is debounced to avoid expensive recalculation on every keystroke. The component remembers the user's last chosen layout mode and restores it when the viewport widens again.

## Behavioral Requirements

- **must-render-editor-pane**: The component MUST render a text editor pane for markdown content input.
- **must-render-preview-pane**: The component MUST render a preview pane showing the rendered markdown output.
- **must-sync-content-to-preview**: The component MUST update the preview pane when the editor content changes.
- **must-debounce-preview-render**: The component MUST debounce preview rendering by 300 milliseconds (±50ms) to defer expensive rendering operations beyond keystroke velocity.
- **must-show-split-layout-above-threshold**: The component MUST display editor and preview side-by-side when the viewport width is at least 700px or greater.
- **must-show-tabbed-layout-below-threshold**: The component MUST display editor and preview as tabs (one visible at a time) when the viewport width is below 700px.
- **must-provide-layout-mode-toggle**: The component MUST provide a control allowing the user to switch between available layout modes (split or tabbed, as permitted by the current viewport width).
- **must-preserve-layout-preference**: The component MUST remember the user's last deliberately chosen layout mode and restore it when the viewport transitions to a wider state that can accommodate the preferred mode (e.g., if the user chooses Preview on a narrow viewport, widening to split-capable width restores Preview rather than defaulting to Split).
- **must-clamp-mode-to-available-set**: When the viewport narrows and the currently active layout mode is no longer available, the component MUST switch to a layout mode that is available for the new size (e.g., narrowing from split-capable width when in Split mode to a width that only permits edit and preview modes MAY select Edit).
- **must-show-empty-preview**: The component MUST display a placeholder message (e.g., "Nothing to preview yet.") when the preview pane is shown and the editor content is empty or contains only whitespace.
- **must-not-announce-preview-updates**: The component MUST NOT mark the preview pane as a live region (aria-live) to prevent screen readers from re-announcing the entire rendered document to users when the preview updates after the debounce fires.
- **must-accept-optional-header**: The component MUST accept an optional header element to be rendered above the editor and preview panes, positioned outside both panes (header is a document-level concern, not a view-specific one).
- **must-accept-optional-overlay**: The component MUST accept an optional overlay element to be rendered inside the editor pane's positioning context (e.g., for a typeahead listbox or drag affordance that must position relative to the textarea).
- **must-accept-preview-class-name**: The component MUST accept an optional CSS class name to be applied to the preview pane for styling (e.g., to match the editor pane's vertical bulk when the layout is not full-height).
- **must-accept-theme-id**: The component MUST accept an optional theme identifier to control the reading theme used by the preview pane (passed to the MarkdownReadingPalette; defaults to that palette's own default theme if omitted).
- **must-accept-subject-label**: The component MUST accept an optional subject string to be used as the accessible name for the layout mode toggle's two toggle groups (defaults to "Editor"; e.g., "Note Editor", "Discussion Editor") to disambiguate when multiple markdown editors appear on the same page.
- **must-forward-editor-props**: The component MUST forward unrecognized props to the underlying markdown editor component (`value`, `onChange`, `label`, `onUpload`, `toolbarExtras`, `className`, etc.) without modification or filtering.
- **must-fill-by-default**: The component MUST fill its container by default (`fill={true}`), accepting content height from its container; the component SHOULD accept a `fill={false}` option to size the editor by row count instead.

## Appearance

- **Layout container**: Flex column with gap between header, control strip, and panes row. No horizontal scroll.
- **Panes row**: Flex row with gap between panes. Min-width 0 to enable flex shrinking on overflow. Min-height varies by fill mode.
- **Editor pane**: Flex column, flex-1 to fill available width in split mode. On narrow viewports (tabbed mode), displays conditionally.
- **Preview pane**: Flex column, flex-1 to fill available width in split mode. On narrow viewports (tabbed mode), displays conditionally. Border (1px), rounded corners (md), background color inherited from theme.
- **Split layout**: Editor pane takes 50% width, preview pane takes 50% width, gap between them. Both stretch to fill container height.
- **Tabbed layout**: One pane visible at a time, fills available space.
- **Min-height floor (fill mode)**: When `fill={true}`, the panes row SHOULD have a minimum height floor (e.g., 14rem / 224px) to ensure the editor textarea is large enough to write in. When `fill={false}`, no floor is applied; sizing is driven by textarea row count.

## States

| State | Description |
|-------|-------------|
| Default | Both panes visible (split layout) or editor pane visible (tabbed, default tab). |
| Editor tab active | On narrow viewports: editor pane is visible, preview is hidden. Toolbar shows "Editor" tab as selected. |
| Preview tab active | On narrow viewports: preview pane is visible, editor is hidden. Toolbar shows "Preview" tab as selected. |
| Preview rendering | After content change, debounce timer is active. Preview pane shows stale rendered content (or empty state) until debounce fires. |
| Preview ready | Debounce has fired, preview has been re-rendered with current editor content. |
| Empty content | Editor is empty or contains only whitespace. Preview pane displays placeholder message. |
| Disabled preview | `isPreviewAvailable={false}` or equivalent. Only edit mode is available; preview pane is not shown; toolbar does not offer preview or split options. |
| Focused editor | Editor textarea has focus. |
| Focused overlay | Optional overlay element (e.g., typeahead listbox) has focus; overlay is positioned within the editor pane's context. |

## Accessibility

- **Role**: The component is a container. Panes inside are not exposed as separate roles; the editor pane contains a text area (button list entry), the preview pane contains rendered content (document or article).
- **Label for layout toggle**: The toolbar's two toggle groups (for split/tabbed/preview/editor switches) use the `subject` prop as their accessible name (e.g., `aria-label="Editor layout"`, `aria-label="Note Editor layout"`). Defaults to "Editor" if not specified. This ensures a screen-reader user navigating the rotor can distinguish between multiple editors on the same page.
- **Preview pane live region**: The preview pane MUST NOT be marked with `aria-live="polite"` or `aria-live="assertive"`. Setting `aria-live="off"` explicitly prevents screen readers from re-announcing the entire rendered document every time the preview updates after the debounce (300ms after each keystroke). Announcements of specific interactive elements within the preview (links, headings, etc.) are handled by assistive technology's document navigation, not live region updates.
- **Empty state placeholder**: The "Nothing to preview yet." placeholder message is screen-reader accessible as regular text content within the preview pane.
- **Keyboard navigation**: The layout toggle buttons and mode toggles in the toolbar are keyboard navigable. Tab order follows the visual layout: toolbar controls precede the panes. The editor textarea is focusable and editable via keyboard. Content in the preview pane is navigable via standard document navigation (headings, links, etc.) if it is a live document view.
- **Focus management**: Focus is not automatically moved when the user switches layout modes (e.g., clicking "Preview" does not steal focus from the editor textarea). Focus remains where the user left it; if the previously focused element is no longer visible in the new layout, focus moves to the container.
- **Overlay positioning context**: An optional overlay (typeahead listbox, etc.) is positioned relative to the editor pane's frame, not the window. Screen readers will announce the overlay's content as it appears; the overlay's own accessibility is the responsibility of the overlay component.
- **Touch target size**: Layout toggle buttons and mode toggle buttons on the toolbar MUST have a touch target of at least 44×44pt (iOS) or 48×48dp (Android). Web buttons MUST have a clickable area of at least 44×44px.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| markdown-editor-001 | must-render-editor-pane, must-render-preview-pane | Mount component with `value=""` | Both editor and preview panes are rendered in the DOM. Editor textarea is empty; preview shows placeholder. |
| markdown-editor-002 | must-sync-content-to-preview, must-debounce-preview-render | Mount component, type "# Hello" into editor | After 300ms, preview pane updates to show rendered `<h1>Hello</h1>` (or platform equivalent). |
| markdown-editor-003 | must-show-split-layout-above-threshold | Mount component at 800px width with `isPreviewAvailable={true}` | Editor and preview panes are displayed side-by-side, each taking 50% width. |
| markdown-editor-004 | must-show-tabbed-layout-below-threshold | Mount component at 600px width with `isPreviewAvailable={true}` | Editor and preview are shown as tabs. Only one pane is visible at a time. |
| markdown-editor-005 | must-provide-layout-mode-toggle | Mount component; locate toolbar | Toolbar displays mode toggle control(s). User can click to switch between available modes. |
| markdown-editor-006 | must-preserve-layout-preference | Mount at 600px in tabbed mode, user selects "Preview" tab, then resize to 800px | Resize to 800px triggers layout change to split-capable. Split mode activates; "Preview" pane is visible (user's preference is restored, not defaulted to Split). |
| markdown-editor-007 | must-clamp-mode-to-available-set | Mount at 800px in Split mode with `isPreviewAvailable={true}`, then resize to 600px | Resize to 600px narrows available modes to [Edit, Preview] (no Split). Component clamps to Edit mode (or Preview if that was the user's last choice before narrowing). Split option is unavailable in toolbar. |
| markdown-editor-008 | must-show-empty-preview | Mount component with `value=""`, visible in split or preview-only mode | Preview pane displays "Nothing to preview yet." (or equivalent placeholder). |
| markdown-editor-009 | must-not-announce-preview-updates | Mount component; enable screen reader; edit content | After debounce, screen reader does NOT announce the entire rendered preview document. Only new/changed elements or interactive controls within the preview are navigable via standard document nav (e.g., heading rotor, link list). |
| markdown-editor-010 | must-accept-optional-header | Mount with `header={<div>Document Title</div>}` | Header element is rendered above the control strip and panes. |
| markdown-editor-011 | must-accept-optional-overlay | Mount with `overlay={<div>Typeahead</div>}` while editor is focused; overlay is conditionally shown | Overlay is positioned inside the editor pane's positioning context. Overlay is visible only when the editor pane is visible (tabbed mode: overlay disappears when user switches to preview tab). |
| markdown-editor-012 | must-accept-preview-class-name | Mount with `previewClassName="custom-class"` | Preview pane element has the custom class applied in addition to default classes. |
| markdown-editor-013 | must-accept-theme-id | Mount with `themeId="dark"` | Preview pane renders with the "dark" reading theme (passed to MarkdownReadingPalette). |
| markdown-editor-014 | must-accept-subject-label | Mount two instances with `subject="Note"` and `subject="Comment"` | Each instance's toolbar toggle groups have unique accessible names: "Note Editor layout" and "Comment Editor layout" (screen readers can distinguish them). Default is "Editor" if subject is omitted. |
| markdown-editor-015 | must-forward-editor-props | Mount with `value="test"`, `onChange={callback}`, `label="Body"` | Props are forwarded to the editor pane. Content is "test"; onChange fires when user edits; label is applied to the textarea. |
| markdown-editor-016 | must-fill-by-default | Mount with no `fill` prop | Component expands to fill container height (`fill={true}` is the default). Min-height floor is applied. |
| markdown-editor-017 | must-fill-by-default | Mount with `fill={false}` | Component sizes by textarea row count. No height-based floor is applied. |

## Edge Cases

- **Empty or null content**: When the editor content is empty, `null`, or contains only whitespace (spaces, tabs, newlines), the preview pane shows the empty state placeholder and does NOT attempt to render markdown.
- **Rapid keystroke stream**: User types 10 characters in quick succession. Debounce is reset for each keystroke. Preview renders once, 300ms after the user stops typing (not after each character).
- **Debounce cancellation**: User types, debounce timer starts. Before 300ms elapses, the component is unmounted or the preview is disabled. The pending render is cancelled and does not run.
- **Programmatic content updates**: If the host programmatically sets the `value` prop to a new string (not user typing), the debounce timer starts, and preview renders 300ms later (same as keystroke). The component guards against infinite loops: setting the `value` prop to the same string it already holds does NOT trigger a re-render.
- **Mode change during debounce**: User edits, debounce starts. Before debounce fires, user switches from edit mode to preview mode. Debounce still fires on schedule; preview updates on completion.
- **Viewport resize during layout transition**: User is in split mode on a 800px viewport. Viewport resizes to 600px (tabbed mode). While the layout is transitioning, does the preview re-render? The implementation debounces based on content changes, not layout changes; layout changes do not trigger re-renders independently.
- **Preview disabled toggle**: `isPreviewAvailable` prop changes from `true` to `false`. Only edit mode is available. If the user was viewing preview, the layout switches to edit. Setting `isPreviewAvailable` back to `true` restores the previous mode preference.
- **Overlay focus while tabbed**: User is in edit mode on a narrow viewport with an overlay (e.g., typeahead) open. User clicks the preview tab. The overlay is hidden (it belongs to the editor pane and is only rendered when the editor pane is visible). Focus moves to the preview pane.
- **Concurrent edits (web only)**: Not applicable: the component is single-threaded on the main React render loop. Edits are serialized by React's event model.
- **Offline rendering (web only)**: The MarkdownRenderer is a client-side component and does not depend on network connectivity for rendering. Markdown rendering occurs locally.

## Configuration

Not applicable: this component does not accept configuration options beyond its props (defaultLayout, defaultTab, subject, overlay, previewClassName, themeId, and forwarded editor props). No separate configuration object is needed.

## Deep Linking

Not applicable: this component is a pane within a document editor, not a top-level navigation target. Deep linking is the responsibility of the host application (which may deep link to a document containing this editor).

## Localization

Not applicable: this component does not render user-facing text strings (beyond the "Nothing to preview yet." placeholder and the default "Editor" subject). Localization of the placeholder and button labels is the responsibility of the host application or the underlying toolbar and palette components (MarkdownEditorToolbar, MarkdownReadingPalette).

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Preview updates should respect prefers-reduced-motion. Debounce timer and rendering should complete without animation or transition delays. Pane switching (tabbed mode) should be instant or use a discrete, non-animated transition. |
| Increase Contrast | Preview pane inherits contrast from MarkdownReadingPalette theme (e.g., "dark" or "high-contrast" theme). Host application may pass a high-contrast themeId prop. |
| Differentiate Without Color | If the layout toggle buttons use color alone to indicate state, add additional visual indicators (e.g., icon, checkmark, underline) to communicate the active mode without relying on color. |

## Feature Flags

Not applicable: this component does not have built-in feature flags. If the host application needs to gate the component's availability or specific features (e.g., preview availability), they should use `isPreviewAvailable` prop and conditional rendering.

## Analytics

Not applicable: this component does not emit analytics events. The host application is responsible for tracking user interactions (e.g., "user switched to preview mode", "user edited markdown document"). If needed, the host can attach event listeners to the onChange callback and toolbar callbacks.

## Privacy

Not applicable: the component does not collect or transmit any user data beyond passing the markdown content to the preview renderer, which operates locally. No data leaves the device.

## Logging

Not applicable: this component does not perform any logging. Internal state changes (render count, debounce scheduling, layout changes) are implementation details and not exposed via logging APIs. Tests may access `renderCount` property on the Apple implementation via `@testable import` for verification.

## Platform Notes

- **Web (React/TypeScript)**: Implemented in `packages/web/packages/markdown/src/components/MarkdownDocumentEditor.tsx`. Uses React hooks (`useState`, `useEffect`) for state management. Debounce is implemented with a custom `useDebounced` hook. Layout state is managed by `useSplitView` from `@agenticdevelopertoolkit/ui/blocks/split-view-control`. Responsive width check is implicit in the viewport width; the threshold (700px) is exported as `SPLIT_MIN_WIDTH` constant. Forward all props to the underlying `MarkdownEditor` component via spread operator (`...editor`).

- **SwiftUI**: For SwiftUI adoption, start from a view that composes `TextEditor` for markdown input and a markdown renderer view for preview. Use a `@State` property to track the current layout mode and viewport width (via `GeometryReader`). Use `DispatchQueue.main.asyncAfter` for the 300ms debounce, cancelling the previous work item when content changes. Conditionally show the editor and preview views based on layout mode and available width (GeometryReader). Use `@StateObject` for the split-view control state to persist the user's mode preference across layout changes.

- **Compose (Android)**: For Compose adoption, start with a `Column` or `Box` composable containing editor and preview regions. Use a `State<String>` for the markdown content and a `State<LayoutMode>` for the current layout. Implement debounce using `LaunchedEffect` with a `delay` to schedule the preview re-render 300ms after content changes. Use `WindowInfo.widthDp` or `LocalConfiguration.current.screenWidthDp` to detect the viewport width threshold (700dp). Conditionally render editor and preview composables based on layout mode (split shows both in a `Row`, tabbed shows one in a `Column` with a tab selector).

- **AppKit / UIKit**: Implemented in `packages/apple/AgenticDeveloperToolkit/SourcesUI/Shared/Markdown/MarkdownEditorController.swift`. Inherits from `PlatformViewController` (macro that dispatches to `NSViewController` on macOS or `UIViewController` on iOS). Uses `NSTextView` / `UITextView` for markdown input via the `MarkdownTextPane` component. Preview is a child view controller (`MarkdownViewerController`). Layout is driven by `NSLayoutConstraint` (AutoLayout); constraints are rebuilt in `applyPanes()` whenever the layout mode changes. Debounce is implemented with `DispatchQueue.main.asyncAfter` and `DispatchWorkItem` cancellation. Viewport width threshold check is `view.bounds.width >= Self.splitWidthThreshold` (700pt). Preference persistence is via `preferredMode` private property.

- **WinUI 3**: For WinUI 3 adoption, build a `UserControl` containing a markdown editor (`TextBox` or a third-party markdown editor control like `Markdig` or `AvalonEdit`) and a preview pane (using `WebView2` or a custom renderer for rendered HTML output). Use data binding to bind `Content` property to the editor's text and the preview pane's rendered HTML. Use `ActualWidth` of a `Grid` column to detect the viewport width and switch layout modes. Implement debounce with `DispatcherTimer` (set `Interval` to 300ms; cancel and restart it when content changes). Use a `ComboBox` or toggle button group to switch between layout modes. Store the user's mode preference in the application settings or a view model property that survives layout changes. Bind the preview pane's visibility to the layout mode (use `Visibility.Visible` / `Visibility.Collapsed`).

## Design Decisions

1. **Preview debounce duration (300ms)**: The web source applies a 300ms debounce to defer expensive markdown rendering (including syntax highlighting via Shiki) beyond keystroke velocity. The Apple implementation uses the same 0.3-second threshold. This delay is short enough to feel responsive (three frames at 60fps) but long enough to avoid rendering on every character input. Users can still see immediate visual feedback from the editor; the preview catches up after they pause or stop typing.

2. **Split layout threshold (700px)**: Both implementations use 700px (web) and 700pt (Apple) as the breakpoint below which the split layout is unavailable. This width accommodates two columns of readable prose (roughly 40–50 characters per column at typical font sizes). Below this threshold, a split view would leave each pane too narrow to be usable, so tabbed layout is enforced.

3. **Mode preference restoration logic**: When the viewport widens and the split layout becomes available, the component restores the user's last deliberately chosen mode (e.g., Preview) rather than defaulting to Split. This honors the user's intent: if they chose Preview on a narrow viewport and then widen their window, Preview remains the active pane. Only a deliberate choice (user clicking a toggle) updates the preference; a layout-driven fallback (narrowing the window) does not. This prevents mode "drift" when resizing.

4. **No preview re-announcement on update**: The preview pane is explicitly marked with `aria-live="off"` to suppress live region announcements when the preview updates. Announcing the entire rendered document every 300ms would create constant, overwhelming screen-reader noise. Screen-reader users instead navigate the preview's content structure (headings, links, etc.) on demand, using standard document navigation techniques.

5. **Optional header outside panes**: The header prop allows a host to render document identity fields (title, slug, categories, etc.) above the split-view control and panes, positioned at the document level rather than specific to the editor or preview. This reflects the data model: these fields belong to the document, not to a particular view of the document body.

6. **Overlay positioning relative to editor pane**: The optional overlay (e.g., typeahead listbox) is rendered inside the editor pane's positioning context (`position: relative` container on web, `addSubview` within the editor pane on Apple). This ensures the overlay positions relative to the textarea and is hidden when the editor pane is hidden in tabbed mode. It also keeps the overlay's z-order scoped to the editor, preventing it from overlapping the preview pane in split mode.

7. **Default fill={true}**: Unlike the underlying `MarkdownEditor` component (which defaults to `fill={false}`), this component defaults to `fill={true}` because both layout modes (split and tabbed) are designed to fill their container height by construction. Passing `fill={false}` is an opt-in override for hosts that need fixed-height sizing (e.g., the notebook's NoteFields component).

8. **Min-height floor in fill mode**: When `fill={true}`, a minimum height floor (e.g., 14rem) is applied to the panes row to ensure the textarea has enough vertical space to be usable for writing (roughly 10rem after label and toolbar). Without the floor, a container shorter than the editor's minimum needs would allow the panes to shrink to zero height, and all content would overflow. In `fill={false}` mode, no floor is applied; sizing is driven by the textarea's row count.

9. **Programmatic content synchronization guard**: To prevent infinite loops when the host updates the `value` prop, the component checks `content !== oldValue` before triggering a re-render. This allows programmatic updates (host sets the value to a new string) to flow through the editor pane and trigger the debounce, but prevents a no-op update from re-rendering.

## Compliance

Not applicable: this component is a container and does not directly implement compliance concerns (e.g., GDPR consent, PCI compliance). Compliance is the responsibility of the host application.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from web (MarkdownDocumentEditor.tsx) and Apple (MarkdownEditorController.swift) sources. |
