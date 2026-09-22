---
id: 292f17e2-1df8-4126-a26c-4160e8e88708
title: Detail Pane
domain: agenticdevelopercookbook://ingredients/detail-pane
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A collapsible panel that displays detailed information for a selected topic,
  including title, description, images, and related links.
platforms:
- typescript
- web
tags:
- detail-display
- panel
- three-pane-layout
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Detail Pane

## Overview

The Detail Pane is a collapsible side panel that displays contextual details for a selected topic in a three-pane layout. It renders the topic's title, description, images, and linked references, and manages its visibility state independently. The pane is typically positioned to the right of a main content area and can be toggled open or closed by parent controls.

## Behavioral Requirements

- **must-render-header**: The pane MUST render a fixed header labeled "Details" at the top of the panel.
- **must-accept-topic-data**: The pane MUST accept an optional `topic` prop containing title, description, links, images, and a message index.
- **must-conditionally-render-content**: When `topic` is null, the pane MUST render an empty content area. When `topic` is provided, the pane MUST render all non-empty fields from the topic data.
- **must-render-title**: When a topic is present, the pane MUST render the topic's title as a distinct visual element.
- **must-render-optional-description**: When a topic is present and has a non-empty description, the pane MUST render the description below the title.
- **must-render-images**: When a topic is present and has images, the pane MUST render each image with its `src` attribute. If an image lacks an `alt` attribute, the pane MUST use an empty string.
- **must-fire-image-load-callback**: When an image finishes loading, the pane MUST call the optional `onImageLoad` callback if provided.
- **must-render-links-section**: When a topic is present and has links, the pane MUST render a "Links" label followed by a list of clickable links.
- **must-link-properties**: Each link MUST open in a new tab (target="_blank") with `rel="noopener noreferrer"`. If a link has no label, the pane MUST display the URL as the link text.
- **must-support-visibility-state**: The pane MUST accept a `visible` prop and apply a CSS class indicating visibility state (`pc-pane-visible` when true, `pc-pane-hidden` when false).
- **must-keep-content-mounted-when-hidden**: When `visible` is false, the pane MUST keep the header and all topic content mounted in the DOM. It MUST NOT unmount the subtree and MUST NOT apply `inert`, `aria-hidden`, or a negative `tabIndex` to the root element or its descendants.
- **must-not-manage-focus**: The pane MUST NOT set, move, or restore focus when `visible` changes. Changing `visible` MUST change only the root element's class name and MUST leave the active element exactly as it was.
- **must-render-literal-ui-strings**: The pane MUST render "Details" and "Links" as literal English text. It MUST NOT resolve either string through a localization key, catalog, or translation hook.
- **must-support-ref-forwarding**: The pane MUST support ref forwarding to expose the root `HTMLDivElement`.
- **must-include-connector-anchor**: The pane MUST render a ConnectorAnchor element with an id constructed from the message index in the format `panel-{messageIndex}-in`.

## Appearance

- **Container background**: Inherits from parent styling; uses `pc-detail-pane` CSS class for styling.
- **Header styling**: "Details" header uses `pc-panel-header` CSS class.
- **Content area**: Uses `pc-detail-content` CSS class for layout wrapper.
- **Title styling**: Topic title uses `pc-detail-title` CSS class.
- **Description styling**: Topic description uses `pc-detail-desc` CSS class.
- **Images container**: Images are wrapped in a `pc-detail-images` container; each image uses `pc-detail-image` class.
- **Links label**: Uses `pc-detail-links-label` CSS class.
- **Links container**: Links are wrapped in a `pc-detail-links` container; each link is an `<a>` element.
- **Visibility classes**: Root element receives `pc-pane-visible` (when visible=true) or `pc-pane-hidden` (when visible=false) for visibility transitions.

## States

| State | Appearance change |
|-------|------------------|
| Visible | Root element has `pc-pane-visible` class; pane is displayed or animated into view |
| Hidden | Root element has `pc-pane-hidden` class; pane is hidden or animated out of view. Content stays mounted and focus is not moved |
| Empty (no topic) | Content area is rendered but empty; header remains visible |
| Loaded (topic present) | All available topic fields are rendered; images display when loaded |

## Accessibility

- **Role**: The pane does not have an explicit ARIA role; it is a plain `div` container. The "Details" header is also a `div`, not a heading element, so it carries no heading semantics and serves as a visual landmark only.
- **Link accessibility**: Links use native `<a>` elements and are keyboard accessible. Link text MUST be meaningful (either the label or the URL).
- **Image alt text**: Images MUST have an `alt` attribute; if not provided in the source data, an empty string is used (Note: empty alt strings should only be used for decorative images; if images are content, ensure they are marked with descriptive alt text in the data source).
- **Focus across visibility transitions**: The pane performs no focus management. Toggling `visible` swaps `pc-pane-visible` for `pc-pane-hidden` on the root element and does nothing else: the subtree is not unmounted, `inert`/`aria-hidden`/`tabIndex` are never applied, and `focus()` is never called. Focus therefore stays wherever it was — including on a link inside the pane after the pane is hidden. Because the component makes no such guarantee itself, the stylesheet that defines `pc-pane-hidden` MUST remove the pane from both the accessibility tree and the tab order, using `display: none` or `visibility: hidden`. A hidden style built only from `opacity`, `transform`, or off-screen positioning leaves the pane's links focusable and announced while the pane is not visible, which is a WCAG 2.1 SC 2.4.3 (Focus Order) failure. See Design Decisions, item 6.
- **Semantic structure**: The pane uses semantic nesting of `div` elements with CSS classes for styling; consider adding ARIA landmarks or headings if used as a primary content region in the application.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| detail-001 | must-render-header, must-render-literal-ui-strings | pane rendered | Header element contains the literal text "Details" |
| detail-002 | must-conditionally-render-content | topic = null | Content area renders empty (no topic title/description/images/links) |
| detail-003 | must-render-title | topic = {title: "Test Topic", ...} | Title element renders with text "Test Topic" |
| detail-004 | must-render-optional-description | topic = {description: "Test desc", ...} | Description element renders below title |
| detail-005 | must-render-optional-description | topic = {description: "", ...} | Description element does not render |
| detail-006 | must-render-images | topic = {images: [{src: "/img.jpg", alt: "Alt text"}], ...} | Image element renders with src="/img.jpg" and alt="Alt text" |
| detail-007 | must-render-images | topic = {images: [{src: "/img.jpg"}], ...} | Image element renders with alt="" |
| detail-008 | must-fire-image-load-callback | image loads + onImageLoad provided | onImageLoad callback is invoked |
| detail-009 | must-render-links-section, must-render-literal-ui-strings | topic = {links: [{label: "Link1", url: "http://example.com"}], ...} | Links section renders with the literal label "Links" and a clickable link with text "Link1" |
| detail-010 | must-link-properties | topic = {links: [{label: "Link1", url: "http://example.com"}], ...} | Link element has target="_blank" and rel="noopener noreferrer" |
| detail-011 | must-link-properties | topic = {links: [{label: "", url: "http://example.com"}], ...} | Link element displays URL text "http://example.com" |
| detail-012 | must-support-visibility-state | visible = true | Root element has class "pc-pane-visible" |
| detail-013 | must-support-visibility-state | visible = false | Root element has class "pc-pane-hidden" |
| detail-014 | must-include-connector-anchor | topic = {messageIndex: 5, ...} | ConnectorAnchor element renders with id="panel-5-in" |
| detail-015 | must-keep-content-mounted-when-hidden | topic present, rendered with visible = true, then re-rendered with visible = false | Title, description, image and link elements are all still present in the DOM; the root element has no `inert`, `aria-hidden`, or `tabindex` attribute |
| detail-016 | must-not-manage-focus | topic with one link, visible = true; focus that link, then re-render with visible = false | `document.activeElement` is still the link element; the component issues no focus() call |
| detail-017 | must-not-emit-analytics | topic present; render, load an image, click a link, toggle visible | No analytics event is dispatched by the component; the module references no analytics client |
| detail-018 | must-not-log | topic present; render, load an image, toggle visible, render with topic = null | No console or logger output is produced by the component |

## Edge Cases

- **Null topic with visible=true**: The pane renders with visibility class applied but no content to display. Expected: header "Details" renders; content area is empty.
- **Empty arrays**: When `topic.images` or `topic.links` are empty arrays (length=0), those sections do not render. Expected: only the title and description render if present.
- **Missing optional fields**: If topic lacks a description (field undefined or empty) or has empty arrays for images/links, those sections are conditionally omitted. Expected: only available fields render.
- **Image load failure**: If an image fails to load, the pane does not render an error state. Expected: placeholder behavior depends on CSS and browser defaults; no error callback exists in the source.
- **Concurrent image loads**: When multiple images are present and load asynchronously, `onImageLoad` callback fires for each image's load event. Expected: callback invoked once per image.
- **Null ref forwarding**: If the ref prop is not provided or is null, the component still renders and functions normally. Expected: no error; optional ref is handled by React.forwardRef.
- **Focus held inside a hidden pane**: If a link inside the pane holds focus when `visible` flips to false, the component leaves focus on that link. Expected: focus is unchanged (MUST, per must-not-manage-focus); whether the link remains reachable by keyboard depends entirely on how `pc-pane-hidden` is styled (see Accessibility).
- **Topic replaced while hidden**: If `topic` changes while `visible` is false, the pane re-renders the new topic immediately, because its content is never unmounted. Expected: on the next show the pane already displays the new topic, with no intermediate empty state (MUST, per must-keep-content-mounted-when-hidden).

## Configuration

Not applicable: This is a presentational component with no configuration options. All behavior is controlled via props (topic, visible, onImageLoad).

## Deep Linking

Not applicable: The component does not implement deep linking. Deep linking is a routing concern handled by the parent three-pane layout component.

## Localization

The pane is not localized. It renders two hardcoded English strings and contains no localization layer: neither string is read from a key, a message catalog, or a translation hook, and no fallback or locale-selection logic exists. The keys below are names a consuming application would have to introduce; they do not exist in the source. See **must-render-literal-ui-strings**.

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| none — hardcoded | "Details" | Header text of the detail pane, written as a literal in the component markup |
| none — hardcoded | "Links" | Section label rendered above the links list, written as a literal in the component markup |

Link labels and image alt text are not UI strings: they arrive through the `topic` prop and are rendered verbatim, so localizing them is the caller's responsibility.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Not specified in source. Parent layout or CSS media queries should suppress `pc-pane-visible`/`pc-pane-hidden` transition animations if reduce-motion is enabled. |
| Increase Contrast | Not specified in source. Parent styling or CSS should ensure links meet WCAG AA contrast ratios. |
| Differentiate Without Color | Not specified in source. Link styling should not rely on color alone to indicate state. |

Not applicable: This component delegates motion and contrast concerns to its CSS classes and parent styling. The component itself does not implement these options.

## Feature Flags

Not applicable: The component does not expose feature flags. Feature control is handled by the parent layout if needed.

## Analytics

Not applicable: the pane emits no analytics events. The source imports no analytics client, declares no event names, and has exactly one callback — `onImageLoad`, invoked from the `<img>` `onLoad` handler as a layout notification, not as an instrumentation hook.

- **must-not-emit-analytics**: The pane MUST NOT emit analytics events. A consuming application that needs instrumentation MUST add it at the call site — for example by wrapping the `onImageLoad` callback it passes in, by observing the `visible` prop it controls, or by attaching its own handler to the rendered links.

## Privacy

- **Data collected**: The component does not collect data. It displays data passed via props.
- **Storage**: No data is stored locally by the component.
- **Transmission**: No data transmission is performed by the component itself. Links open via standard browser navigation (target="_blank").
- **Retention**: The component does not persist state across sessions.

Not applicable: This component is a stateless presentational component that does not handle sensitive data or perform data collection.

## Logging

Not applicable: the pane performs no logging. The source declares no subsystem and no category, imports no logger, and contains no `console` call on any path — including image load, visibility change, and the null-topic branch.

- **must-not-log**: The pane MUST NOT write log messages. A consuming application that needs diagnostics MUST emit them at the call site, where the `topic` and `visible` props and the `onImageLoad` callback are already available.

## Platform Notes

- **React/Web**: The source platform. `DetailPane.tsx` in `packages/web/packages/chat/src/modes/three-pane/` is a single `forwardRef` function component with no state and no effects; its sibling import `./connectors/ConnectorAnchor` is what ties the pane to the layout's connector lines, so a port must provide an equivalent anchor identified as `panel-{messageIndex}-in`. All appearance lives in the `pc-`-prefixed classes supplied by a parent stylesheet, which is also where the show/hide mechanism is defined — the component only names the class.

- **SwiftUI**: Start from a `VStack(alignment: .leading)` inside a `ScrollView`, with the header as a `Text("Details")`, the body driven by `if let topic`, images as `AsyncImage` (use its phase transition to fire the `onImageLoad` equivalent), and links as `Link(label, destination:)`, which already opens externally so no `target="_blank"` analogue is needed. Drive visibility from an `isVisible` `Bool` with `.opacity`/`.offset` plus `.animation`. Note the difference from the source: SwiftUI drops a view from the accessibility tree only when it is not rendered or is marked `.accessibilityHidden(true)`, so apply `.accessibilityHidden(!isVisible)` to match a correctly styled hidden pane. The ConnectorAnchor maps to an `.anchorPreference` on the title row that publishes its bounds to the layout.

- **Compose**: Use a `Column` in a `verticalScroll`, `Text` for header, title and description, `AsyncImage` (Coil) with `onSuccess` for the load callback, and `ClickableText` with `LocalUriHandler.current.openUri(url)` for links. Wrap the pane in `AnimatedVisibility(visible = visible)`, which unmounts content on exit — a deliberate divergence from the source, which keeps content mounted; if mounted-while-hidden matters (to preserve scroll position or image decode state), use `Modifier.alpha` plus `Modifier.semantics { invisibleToUser() }` instead. ConnectorAnchor becomes an `onGloballyPositioned` callback reporting the title row's bounds.

- **AppKit / UIKit**: Build the pane as an `NSStackView` / `UIStackView` (`.vertical`) inside an `NSScrollView` / `UIScrollView`, with `NSTextField`/`UILabel` for header, title and description, `NSImageView`/`UIImageView` fed by an async loader whose completion fires the load callback, and `NSButton` with the `.link` bezel style / `UIButton` calling `NSWorkspace.shared.open` / `UIApplication.shared.open` for links. Toggle visibility with the root view's `isHidden`, which — unlike the source's class swap — removes the view from both the accessibility tree and the key-view loop automatically; if animating with `alphaValue`/`alpha` instead, also set `accessibilityElementsHidden = true` and resign first responder explicitly. ConnectorAnchor maps to a zero-size marker view whose frame is converted into the layout's coordinate space for the connector drawing layer.

- **WinUI 3**: Use a `Grid` with two rows (header, content) inside a `ScrollViewer` as the root, a `TextBlock` for the "Details" header, and an `ItemsRepeater` (or `ItemsControl`) bound to the images and links collections. Images are `Image` elements with `ImageOpened` wired to the load callback; links are `HyperlinkButton` elements with `NavigateUri` set, which opens the default browser and so already matches `target="_blank"` with `rel="noopener noreferrer"`. Model the visible/hidden pair as `VisualState`s (`PaneVisible`, `PaneHidden`) in a `VisualStateManager.VisualStateGroups` on the root, driven by `VisualStateManager.GoToState`, and animate with a `Storyboard` or a `Microsoft.UI.Composition` implicit `Opacity`/`Translation` animation. End the hide state with the root's `Visibility="Collapsed"`: a collapsed element is skipped by both tab navigation and Narrator, which is exactly what the web version's stylesheet has to do explicitly. Express the `pc-` classes as `Style` resources keyed in a `ResourceDictionary` (`DetailPaneStyle`, `PanelHeaderStyle`, `DetailTitleStyle`, `DetailDescStyle`, `DetailLinksLabelStyle`) so the visual contract stays in one place. ConnectorAnchor becomes a zero-width `Border` in the title row, named with `x:Name="PanelAnchorIn"`, whose position the layout reads through `TransformToVisual(layoutRoot).TransformPoint(...)`.

## Design Decisions

1. **Ref forwarding**: The component uses `forwardRef` to expose the root `HTMLDivElement` to parent consumers. This enables advanced layout control (e.g., measuring the pane's dimensions) without importing the component directly. This is a common React pattern for layout-sensitive components.

2. **Empty alt strings for images**: When image data lacks an `alt` attribute, the component assigns an empty string rather than a fallback description. This is correct for decorative images but relies on the data source to provide meaningful alt text for content images. Consumers MUST ensure image data includes descriptive alt text.

3. **Link opening behavior**: Links always open in a new tab (`target="_blank"`) with security attributes (`rel="noopener noreferrer"`). This prevents the three-pane layout from being interrupted when a user follows a link. Consumers should document this behavior to users.

4. **Connector anchor placement**: The ConnectorAnchor is rendered at the start of the title, using a CSS class (`pc-connector-anchor-in`) to position it visually. The message index is embedded in the anchor ID to support bidirectional linking in the three-pane layout. This design ties the pane's visual structure to the message flow; changes to title structure may require updates to the anchor positioning.

5. **Conditional rendering of sections**: Images and links sections only render if their arrays are non-empty. This keeps the UI clean when data is sparse. Consumers should expect variable content heights and plan layout accordingly.

6. **Visibility is styling only, and focus is left untouched**: Hiding the pane is expressed entirely as a class name (`pc-pane-hidden`) on the root element. The component deliberately keeps its content mounted, applies no `inert`/`aria-hidden`/`tabIndex`, and never calls `focus()`. This keeps the component free of effects, lets the layout animate the pane in and out without losing scroll position or image decode state, and keeps the connector anchor measurable while the pane is offscreen. The cost is that part of the accessibility contract lives in the stylesheet: `pc-pane-hidden` MUST resolve to `display: none` or `visibility: hidden` so a hidden pane leaves the tab order and the accessibility tree. This is the one obligation of the component that cannot be met from inside the component, and it is why a pane hidden with opacity alone strands keyboard focus on an invisible link.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| [semantic-html-structure](agenticdevelopercookbook://compliance/web#semantic-html-structure) | failed | Web accessibility |
| [link-security](agenticdevelopercookbook://compliance/web#link-security) | passed | Web security |
| [image-loading-performance](agenticdevelopercookbook://compliance/web#image-loading-performance) | failed | Web performance |

- `semantic-html-structure` fails because the pane is built entirely from `div` elements: the "Details" header and the topic title are `div`s rather than heading elements, and the root carries no landmark role.
- `link-security` passes because every link carries `rel="noopener noreferrer"` alongside `target="_blank"`.
- `image-loading-performance` fails because each `<img>` is rendered with only `src` and `alt` — no `loading`, `decoding`, `width`, or `height` attributes — so images load eagerly and reserve no layout space.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| — | 2026-09-22 | — | Replace hedged gap markers in Accessibility, Localization, Analytics and Logging with statements traced to the source; add focus, mounting, literal-string, no-analytics and no-logging requirements plus their test vectors |
| — | — | — | Initial creation |
