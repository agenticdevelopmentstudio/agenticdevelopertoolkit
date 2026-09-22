---
id: e268fe4f-8e83-4189-b1d2-105cd177308c
title: Clip
domain: agenticdevelopercookbook://ingredients/clip
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Auto-playing video component that respects prefers-reduced-motion for accessible
  playback control.
platforms:
- typescript
- web
tags: []
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Clip

## Overview

A video player component that auto-plays on load while respecting the user's `prefers-reduced-motion` preference. When the user has requested reduced motion, the component disables auto-play, disables looping, and enables playback controls to put the user in control. When reduced motion is not requested, the component auto-plays and loops silently without controls.

## Behavioral Requirements

- **must-accept-src**: Component MUST accept a `src` prop containing the public path to an `.mp4` or `.webm` video file.
- **must-accept-label**: Component MUST accept a `label` prop for the accessible name, applied as `aria-label` to the video element.
- **must-render-video-element**: Component MUST render a single `<video>` element with the provided `src`.
- **must-set-aria-label**: Component MUST set `aria-label` on the video element to the value of the `label` prop.
- **must-respect-reduced-motion**: Component MUST read the `prefers-reduced-motion` media query and adapt playback behavior accordingly.
- **must-autoplay-when-motion-allowed**: Component MUST set `autoPlay=true` on the video element when `prefers-reduced-motion` is false.
- **must-disable-autoplay-when-motion-reduced**: Component MUST set `autoPlay=false` on the video element when `prefers-reduced-motion` is true.
- **must-loop-when-motion-allowed**: Component MUST set `loop=true` on the video element when `prefers-reduced-motion` is false.
- **must-disable-loop-when-motion-reduced**: Component MUST set `loop=false` on the video element when `prefers-reduced-motion` is true.
- **must-show-controls-when-motion-reduced**: Component MUST set `controls=true` on the video element when `prefers-reduced-motion` is true.
- **must-hide-controls-when-motion-allowed**: Component MUST set `controls=false` on the video element when `prefers-reduced-motion` is false.
- **must-always-mute**: Component MUST set `muted=true` on the video element.
- **must-play-inline**: Component MUST set `playsInline=true` on the video element.
- **must-respond-to-preference-changes**: Component MUST pause the video immediately when the user changes their OS `prefers-reduced-motion` setting from false to true while the page is open.
- **must-accept-dimensions**: Component MUST accept optional `width` and `height` props and apply them to the video element for layout sizing before content loads.
- **must-support-web-video-formats**: Component MUST accept `.mp4` and `.webm` video sources via the `src` prop.

## Appearance

- **Corner radius**: None (native video element, no rounding)
- **Padding**: None (native video element)
- **Font**: Not applicable (video player displays video content, not text)
- **Background**: Transparent or determined by browser default (video fills its container)
- **Foreground/Text**: Not applicable
- **Border**: None (native video element)
- **Shadow**: None (native video element)
- **Min/Max size**: Sized by parent container or `width`/`height` props; aspect ratio determined by video source

## States

| State | Appearance change |
|-------|------------------|
| Default | Video displays at intrinsic size or dimensions specified by `width`/`height` props |
| Autoplaying (motion allowed) | Video plays silently, loops continuously; no controls visible |
| Paused (motion reduced) | Video is paused; playback controls visible for user interaction |
| Reduced motion active | Controls become visible; autoplay and loop are disabled |

## Accessibility

- **Role**: The component renders a native HTML `<video>` element with the implicit ARIA role of presentation (decorative unless `aria-label` is provided).
- **Label requirements**: MUST have an `aria-label` prop provided to describe the video content. This is the accessible name for screen readers.
- **Announce state changes**: The component does not announce state changes via ARIA live regions; the user controls playback through visible controls when `prefers-reduced-motion` is true.
- **Motion preference**: MUST respect `prefers-reduced-motion: reduce` per [WCAG 2.1 Animation from Interactions](https://www.w3.org/TR/WCAG21/#animation-from-interactions). When enabled, the component must not autoplay or loop without explicit user action.
- **Keyboard control**: When controls are visible (reduced motion), the native video element provides keyboard support (spacebar, arrow keys) for playback control.
- **Minimum tap target**: The browser's native controls (when visible) meet platform-specific tap target minimums (44×44pt on iOS, 48×48dp on Android, per platform HIGs).

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| clip-001 | must-render-video-element, must-accept-src | `src="https://example.com/video.mp4"` | Video element renders with `src` attribute set to the provided URL |
| clip-002 | must-set-aria-label | `label="Demo video"` | Video element has `aria-label="Demo video"` |
| clip-003 | must-accept-dimensions | `width={640}`, `height={360}` | Video element renders with `width="640"` and `height="360"` attributes |
| clip-004 | must-autoplay-when-motion-allowed, must-loop-when-motion-allowed, must-hide-controls-when-motion-allowed | `prefers-reduced-motion` is false | Video element has `autoPlay={true}`, `loop={true}`, `controls={false}` |
| clip-005 | must-disable-autoplay-when-motion-reduced, must-disable-loop-when-motion-reduced, must-show-controls-when-motion-reduced | `prefers-reduced-motion` is true | Video element has `autoPlay={false}`, `loop={false}`, `controls={true}` |
| clip-006 | must-always-mute | Any props | Video element has `muted={true}` |
| clip-007 | must-play-inline | Any props | Video element has `playsInline={true}` |
| clip-008 | must-respond-to-preference-changes | Video is autoplaying with `prefers-reduced-motion` false; user enables `prefers-reduced-motion: reduce` in OS settings | Video element pauses immediately via `ref.current?.pause()` |
| clip-009 | must-support-web-video-formats | `src="video.webm"` | Video element accepts and renders `.webm` format |

## Edge Cases

- **Empty or missing src**: If `src` is an empty string or undefined, the video element will not load any content. The component renders with an empty `src` attribute; the browser displays no video. This is a valid state and requires the host to handle the missing source.
- **Missing label**: If `label` is not provided, the video element has no `aria-label`. This is an accessibility failure; the video is not described for screen reader users. The component does not provide a fallback; the caller is responsible for always providing a label.
- **Invalid video URL**: If `src` points to a URL that does not exist or is not a valid video file, the video element cannot load it. The browser displays a broken video icon or placeholder. The component does not provide error callbacks; the host is responsible for validating the URL.
- **Reduced motion disabled then re-enabled**: If the user toggles `prefers-reduced-motion` from false to true and back to false, the component resumes autoplaying. If the user paused the video before toggling, toggling back to false does not resume playback; the paused state is preserved.
- **Zero or negative dimensions**: If `width` or `height` are 0 or negative, the video element renders with those invalid dimensions. The browser behavior is undefined (likely no visible video). The component does not validate or constrain dimension values.
- **Video ends while looping enabled**: When `loop={true}` (motion allowed), the video replays automatically without interruption. When `loop={false}` (motion reduced), the video stops at the end and requires the user to click play again.
- **Bandwidth or network failure**: If the video fails to load due to network error, the component does not provide error feedback or retry logic. The native video element displays an error indicator; error handling is the caller's responsibility.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `src` | string | — | **Required.** Public path to the `.mp4` or `.webm` video file. |
| `label` | string | — | **Required.** Accessible name for screen readers, describing the video content. |
| `width` | number | — | Optional. Intrinsic width of the video in pixels for layout sizing before load. |
| `height` | number | — | Optional. Intrinsic height of the video in pixels for layout sizing before load. |

## Deep Linking

Not applicable: This component is a playback container for video content. It does not navigate or support deep-linking patterns. The host application provides the video source URL.

## Localization

Not applicable: The component contains no user-facing text. The native video controls (when visible) are localized by the browser. The `label` prop accepts any string and is passed to the accessibility API without translation.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Component disables autoplay, disables looping, and enables controls to put playback control in the user's hands. This is the primary accessibility feature of the component. |
| Increase Contrast | Not applicable: The component renders a native video element. Contrast is determined by the video content and native browser controls. |
| Differentiate Without Color | Not applicable: The component contains no color-dependent information. |

## Feature Flags

Not applicable: The component has no feature flag support. Playback behavior is determined entirely by the `prefers-reduced-motion` preference.

## Analytics

Not applicable: The component does not emit events. Event tracking is the caller's responsibility.

## Privacy

- **Data collected**: None. The component reads the OS `prefers-reduced-motion` preference locally; no data is sent to any service.
- **Storage**: None. The preference is read from the browser's media query API and is not cached or persisted by the component.
- **Transmission**: None. No data leaves the device.
- **Retention**: Not applicable. No data is stored.

## Logging

Not applicable: The component does not emit log events.

## Platform Notes

- **Web/TypeScript**: The component uses `useSyncExternalStore` to read `prefers-reduced-motion` via `window.matchMedia()` and subscribe to changes. The server-side snapshot returns `false` (motion allowed) to prevent hydration mismatch; the client snapshot is corrected on first render. The component renders a native `<video>` element with HTML attributes. Source: `packages/web/packages/landing/src/blocks/Clip.tsx`.
- **SwiftUI**: Use `AVPlayer` wrapped in a `VideoPlayer` view. Apply `allowsExternalPlayback(false)` and `playbackControls` visibility bound to `@Environment(\.accessibilityReduceMotion)`. When reduce motion is true, show controls and disable repeat. When false, hide controls and enable repeat. Use `accessibilityLabel()` to provide a text description of the video content.
- **Compose (Android)**: Use Android's `VideoView` or `ExoPlayer` (recommended). Bind `autoPlay` and `repeatMode` to `isAccessibilityAnimationEnabled()` (inverted; false when motion is reduced). When reduce motion is enabled, set `repeatMode = REPEAT_MODE_OFF` and show player controls. When disabled, set `repeatMode = REPEAT_MODE_ALL` and hide controls. Apply `contentDescription()` for the accessible label. Set `useController=true` when accessibility reduce motion is enabled.
- **AppKit / UIKit**: Use `AVPlayerViewController` to wrap the video. Bind the `showsPlaybackControls` property to `UIAccessibility.isReduceMotionEnabled()`. When reduce motion is true, manually disable `player?.isMuted`, stop looping, and show controls. When false, mute playback and disable controls. Set the view's `accessibilityLabel` to the provided label string. Use `@Environment(\.accessibilityReduceMotion)` to drive the behavior in SwiftUI; use `UIAccessibility.isReduceMotionEnabled()` in UIKit imperative code.
- **WinUI 3**: Use `MediaPlayerElement` from the Windows App SDK. Bind `AutoPlay`, `IsLoopingEnabled`, and control visibility to `UISettings.AnimationsEnabled` (or read `prefers-reduced-motion` equivalent via JavaScript interop if available). When animations are disabled, set `AutoPlay=false`, `IsLoopingEnabled=false`, and expose playback controls in the UI. When animations are enabled, hide controls and set `AutoPlay=true`, `IsLoopingEnabled=true`. Mute audio via `MediaPlayerElement.MediaPlayer.IsMuted = true`. Use `AutomationProperties.Name` for the accessible label.

## Design Decisions

- **Muted always**: The component always sets `muted=true` because auto-playing video with sound is widely blocked by browsers and disruptive to users. The caller can provide user controls to unmute if needed, but auto-play without mute is not a viable strategy on the web.
- **Server-side snapshot assumption**: The server-side snapshot of `useSyncExternalStore` returns `false` (motion allowed) because the server cannot determine the client's OS preferences. This means the initial HTML includes `autoPlay` and `loop` attributes. If the user has enabled reduce motion, React corrects the attributes on first hydration. This is the accepted approach to avoid hydration mismatch.
- **Force-pause on preference change**: The component uses `useEffect` to call `ref.current?.pause()` when `reduced` changes to true. This is necessary because setting `autoPlay=false` does not stop playback that has already started. The imperative pause ensures the video stops immediately.
- **No error handling**: The component does not provide error callbacks or fallback UI. Video loading errors are handled by the browser's native error state. This simplifies the component and makes error handling the caller's responsibility, which is appropriate for a reusable media component.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| [Accessible Labels Required](agenticdevelopercookbook://guidelines/wcag/labels) | passed | Accessibility |
| [Prefers-Reduced-Motion Respected](agenticdevelopercookbook://guidelines/wcag/animation-from-interactions) | passed | Accessibility |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from web source |
