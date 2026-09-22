---
id: 8e7fa376-f174-4a10-b2ef-2a5c10854d4e
title: Connection Overlay
domain: agenticdevelopercookbook://ingredients/connection-overlay
type: ingredient
version: 1.1.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Modal card that obscures the current view when a live feed becomes unreachable,
  displaying connection status and retry countdown.
platforms:
- web
tags:
- connection-status
- modal
- network
depends-on: []
related: []
references: []
---

# Connection Overlay

## Overview

Connection Overlay is a modal card displayed over the current board or dashboard when a live data feed becomes unreachable (dark). It presents a calm, non-alarming state to the user rather than tearing down panels or displaying an error. The component shows the current connection status (either a backend deployment or unreachability), a spinner, a countdown timer to the next automatic retry attempt, and a manual "Try again now" button. The component obscures the underlying content with a semi-opaque background and blur effect, making it clear the view is temporarily unavailable without destroying the user's context.

## Behavioral Requirements

- **must-hide-when-connection-active**: Component MUST NOT be rendered (return null) when the `active` prop is `false`.
- **must-show-after-delay**: Component MUST NOT be shown in the DOM until the `active` prop has been `true` for at least 1200ms; if `active` becomes `false` before 1200ms elapses, the component MUST NOT appear.
- **must-hide-immediately-on-recovery**: Component MUST be hidden immediately (synchronously) when `active` transitions from `true` to `false`, regardless of elapsed time or remaining countdown.
- **must-display-deploying-status-within-grace-period**: Component MUST display the heading "Backend deploying" when the outage duration is less than 90,000ms (90 seconds).
- **must-display-unreachable-status-after-grace-period**: Component MUST display the heading "Backend unreachable" when the outage duration is 90,000ms or greater.
- **must-display-deploying-subtext-when-deploying**: Component MUST display the subtitle "The backend is restarting — reconnecting automatically. This usually takes a moment." when the heading is "Backend deploying".
- **must-display-unreachable-subtext-when-unreachable**: Component MUST display the subtitle "Still can't reach the backend. Retrying automatically." when the heading is "Backend unreachable".
- **must-display-countdown**: Component MUST display a countdown value that MUST count down once per second from 15 to 0, then reset to 15 and repeat.
- **must-auto-retry-on-countdown-zero**: Component MUST invoke the `onRetry` callback exactly once when the countdown reaches 0 seconds, then immediately reset the countdown to 15.
- **must-provide-manual-retry-button**: Component MUST display a button labeled "Try again now" that, when clicked, resets the countdown to 15 and immediately invokes the `onRetry` callback.
- **must-display-detail-text-after-grace-period**: Component MUST display the `detail` prop text (if provided and not null) only when the outage duration is 90,000ms or greater; the detail text MUST NOT be displayed during the deploying phase.
- **must-use-aria-live-region**: Component MUST set `role="status"` and `aria-live="polite"` on the root overlay element to announce connection state changes to assistive technologies.
- **must-hide-countdown-from-screen-readers**: Component MUST mark the countdown timer display with `aria-hidden="true"` to prevent the per-second countdown from being announced to screen readers.
- **must-prevent-interaction-with-underlying-content**: Component MUST render an overlay that covers the full viewport (inset: 0) at z-index 50, with a background that obscures the underlying content, preventing visual and interactive access to the view beneath.
- **must-display-spinner-icon**: Component MUST display an animated spinner icon (34px size) colored with the blue theme token.

## Appearance

- **Container positioning**: Absolute, full inset (top, right, bottom, left: 0), z-index 50
- **Container background**: color-mix(in srgb, bg 90%, transparent) with 3px blur (backdrop-filter: blur(3px) + -webkit-backdrop-filter: blur(3px))
- **Card container**: Flex column, center-aligned, centered horizontally and vertically in viewport
- **Card padding**: 28px vertical × 34px horizontal
- **Card border radius**: 12px
- **Card background**: Surface theme token (var(--color-apt-surface))
- **Card border**: 1px solid, border theme token (var(--color-apt-border))
- **Card shadow**: 0 8px 40px rgba(0,0,0,0.35)
- **Card gap between elements**: 13px
- **Card max-width**: 46ch
- **Font family**: ui-monospace with monospace fallback
- **Heading font**: 17px, weight 700, letter-spacing 0.02em, text color (var(--color-apt-text))
- **Subheading font**: 12.5px, color muted (var(--color-apt-text-muted)), line-height 1.5
- **Countdown font**: 11.5px, color dim (var(--color-apt-text-dim))
- **Button padding**: 7px vertical × 18px horizontal
- **Button border radius**: 8px
- **Button background**: Blue theme token (var(--color-apt-blue))
- **Button text color**: white
- **Button text font**: 12.5px, weight 600, family monospace
- **Button cursor**: pointer
- **Button appearance**: none (reset default browser styling)
- **Detail text font**: 10.5px, color dim (var(--color-apt-text-dim)), opacity 0.75, word-break break-word
- **Detail text margin-top**: Not specified in source; follows after button

## States

| State | Appearance change |
|-------|------------------|
| Hidden (active=false or delay not elapsed) | Component does not render (returns null) |
| Shown (active=true, delay elapsed, deploying) | Heading: "Backend deploying", subheading: deployment-specific text, spinner visible, countdown visible, no detail text |
| Shown (active=true, delay elapsed, unreachable) | Heading: "Backend unreachable", subheading: unreachable-specific text, spinner visible, countdown visible, detail text displayed (if provided) |
| Button hovered (CSS hover not implemented in source) | No hover state defined in source code |
| Button focused (CSS focus not implemented in source) | No focus state defined in source code |
| Button active/pressed (CSS active not implemented in source) | No active state defined in source code |

## Accessibility

- **Role**: The root element MUST have `role="status"` to announce it as a live region.
- **Live announcements**: The root element MUST have `aria-live="polite"` to announce connection state changes to screen readers.
- **Spinner icon**: MUST have `aria-hidden="true"` to hide it from screen readers (decorative only).
- **Countdown timer**: MUST have `aria-hidden="true"` to prevent per-second countdown announcements, as the heading and subheading already convey state.
- **Detail text announcement**: No explicit aria-label or description provided; the detail text is visible text and will be read by screen readers.
- **Button labeling**: The "Try again now" button MUST have visible text label; no additional aria-label is provided in source.
- **Keyboard interaction**: The retry control is a native `<button type="button">`, so it sits in the document tab order and is activated by Enter and Space through built-in button semantics; keyboard activation reaches the same click handler as a pointer. The source adds no `keydown` or `keyup` handlers, and the overlay exposes no dismiss action to any input device — it is removed only when the consumer sets `active` to `false` — so there is no Escape path to specify.
- **Touch target size**: The button declares no `min-height` or `min-width`; its hit area is the 7px × 18px padding around one line of 12.5px monospace text, resolving to roughly 29–31 CSS px tall. NEEDS REVIEW: whether that height is acceptable is a decision the source cannot make — it clears the 24×24 CSS px floor of WCAG 2.1 AA (SC 2.5.8) but not the 44×44 figure of WCAG SC 2.5.5 AAA and the Apple Human Interface Guidelines. Settle it with a measured hit box on the shipping dashboards plus a decision on whether the overlay is reachable from touch or pen input; if it is, the button needs an explicit minimum height.
- **Focus management**: The layer is modal in intent (`must-prevent-interaction-with-underlying-content`) but the source installs no focus trap, moves no focus into the card when it appears, and restores no focus when it is removed. NEEDS REVIEW: the layer swallows pointer input across the region it covers, yet keyboard and screen-reader focus can still land on the controls it obscures, so a keyboard user can operate a panel they cannot see. What is missing is a containment decision, not an implementation detail. Settle it with a keyboard walkthrough of a dashboard while the overlay is shown, plus a decision on whether focus MUST be confined to "Try again now" while shown and returned to the previously focused element on recovery.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| overlay-001 | must-hide-when-connection-active | active=false | Component returns null; nothing rendered |
| overlay-002 | must-show-after-delay | active=true, wait 1200ms | Component renders in DOM after 1200ms delay |
| overlay-003 | must-show-after-delay (too early) | active=true, wait 500ms | Component does not render before 1200ms elapsed |
| overlay-004 | must-hide-immediately-on-recovery | active=true (shown), then active=false | Component removed from DOM immediately; shown state set to false |
| overlay-005 | must-display-deploying-status-within-grace-period | active=true, elapsedMs < 90000 | Heading text is "Backend deploying" |
| overlay-006 | must-display-unreachable-status-after-grace-period | active=true, elapsedMs >= 90000 | Heading text is "Backend unreachable" |
| overlay-007 | must-display-deploying-subtext-when-deploying | active=true, elapsedMs < 90000 | Subheading text is "The backend is restarting — reconnecting automatically. This usually takes a moment." |
| overlay-008 | must-display-unreachable-subtext-when-unreachable | active=true, elapsedMs >= 90000 | Subheading text is "Still can't reach the backend. Retrying automatically." |
| overlay-009 | must-display-countdown | active=true, shown=true | Countdown displays starting at 15 and decrements by 1 every second |
| overlay-010 | must-auto-retry-on-countdown-zero | active=true, shown=true, countdown reaches 0 | onRetry callback invoked exactly once; countdown resets to 15 |
| overlay-011 | must-provide-manual-retry-button | active=true, shown=true | Button with text "Try again now" is rendered and clickable |
| overlay-012 | must-provide-manual-retry-button (click) | Button clicked while countdown=10 | onRetry callback invoked; countdown resets to 15 immediately |
| overlay-013 | must-display-detail-text-after-grace-period | active=true, elapsedMs >= 90000, detail="Network timeout" | Detail text "Network timeout" is displayed |
| overlay-014 | must-display-detail-text-after-grace-period (no display during deploy) | active=true, elapsedMs < 90000, detail="Error" | Detail text is not displayed |
| overlay-015 | must-display-detail-text-after-grace-period (null detail) | active=true, elapsedMs >= 90000, detail=null | Detail text element is not rendered |
| overlay-016 | must-use-aria-live-region | active=true, shown=true | Root div has role="status" and aria-live="polite" |
| overlay-017 | must-hide-countdown-from-screen-readers | active=true, shown=true | Countdown div has aria-hidden="true" |
| overlay-018 | must-prevent-interaction-with-underlying-content | active=true, shown=true | Overlay div has position: absolute, inset: 0, z-index: 50; background obscures view beneath |
| overlay-019 | must-display-spinner-icon | active=true, shown=true | Loader2 icon (34px, animated, blue) is rendered with aria-hidden="true" |

## Edge Cases

- **Rapid active toggles**: If `active` toggles from true to false to true within the 1200ms delay window, the timer resets and the component waits a full 1200ms from the most recent `true` value before showing. (Confirmed by setTimeout cleanup in useEffect.)
- **Null or undefined detail prop**: If `detail` is `null` or `undefined`, the detail element is not rendered (conditional: `detail && !deploying`). No error is thrown.
- **Zero countdown on button click**: Clicking the button when countdown=1 will set countdown=15, reset the ref, and invoke onRetry. The next tick will fire 1 second later (not immediately).
- **onRetry callback changes between renders**: The component stores `onRetry` in a ref (`onRetryRef`) to prevent re-triggering the interval effect when the callback identity changes. The latest callback is always called, even if it was replaced since the last tick.
- **Strict Mode double-invoke**: React Strict Mode unmounts and remounts effects during development. The countdown interval is properly cleaned up and re-initialized, preventing double-retry invocations (confirmed by use of ref instead of setState in the interval callback).
- **Component unmounted while shown**: If the component is unmounted while `shown=true`, the interval is cleaned up (clearInterval in useEffect return).
- **Active set to false during interval tick**: The effect exits early if `shown=false`; even if `active` is false, the interval does not tick. The state setters in the interval body are not executed.
- **Very long outage (elapsed > 90 seconds)**: The grace period is a fixed 90,000ms; outages longer than this display "Backend unreachable" indefinitely and allow detail text to be shown. No special behavior for hours-long outages.
- **Detail text longer than card width**: The detail div has `word-break: break-word`, causing long strings to wrap within the 46ch max-width container.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `active` | boolean | (required) | True when the live feed is dark (unreachable); false when connection is healthy. Controls visibility and state of the overlay. |
| `onRetry` | function | (required) | Callback invoked when the user clicks "Try again now" or when the 15-second countdown reaches 0. Receives no arguments. |
| `detail` | string \| null | undefined | Optional error detail text displayed only after the grace period (elapsedMs >= 90000) expires. If null or undefined, the detail section is not rendered. |

## Deep Linking

Not applicable: Connection Overlay is a modal overlay component without its own deep link path. It is shown conditionally within a parent view (Overview/Details board or dashboard) and does not represent a distinct navigable destination.

## Localization

Not applicable: every visible string — "Backend deploying", "Backend unreachable", both subtitles, "Retrying in {countdown}s" and "Try again now" — is a hard-coded English literal in the component. The source defines no string keys, no message catalogue and no locale parameter, so there is no key table to fill; translating the component means changing those literals in source.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | The spinner carries the `animate-spin` class unconditionally and the source never reads `prefers-reduced-motion`, so the rotation and the once-per-second countdown update continue unchanged when Reduce Motion is on. No enter or exit transition is applied to the overlay, so there is nothing else to disable. |
| Increase Contrast | Not applicable: All colors use ADH theme tokens (var(--color-apt-*)) that are defined by the consuming application. The component passes through whatever theme colors are set; contrast is determined by the theme, not the component. |
| Differentiate Without Color | Not applicable: The spinner and countdown are identifiable by non-color attributes (animated icon shape, numeric countdown value). The primary status message is text-based. |

## Feature Flags

Not applicable: the component is always enabled. It reads no flag service and exposes no enable/disable option; the consumer controls whether it appears solely through the `active` prop.

## Analytics

Not applicable: the source fires no analytics events. Nothing is emitted on render, on the deploying-to-unreachable transition, on the button click, or on auto-retry, and the component imports no telemetry client. A consumer that wants outage or retry metrics instruments its own `onRetry` handler.

## Privacy

- **Data collected**: None. The component does not collect, store, or transmit any user data beyond the `detail` prop string (which is provided by the consumer).
- **Storage**: No data is stored persistently or in sessionStorage/localStorage.
- **Transmission**: No network requests are initiated by the component. The `onRetry` callback is delegated to the consumer.
- **Retention**: No data is retained.

## Logging

Not applicable: the component performs no logging. It declares no subsystem or category and makes no `console` or logger call on any path — show, hide, tick, auto-retry or manual retry. Outage diagnostics come from the `detail` prop the consumer passes in and from the consumer's own retry handler.

## Platform Notes

- **React / Web (source platform)**: `packages/web/packages/ui/src/components/connection-overlay.tsx`, vendored as `@agenticdevelopertoolkit/ui`. Specific to this file: the `"use client"` directive for the Next.js server/client boundary; `useState`/`useRef`/`useEffect` for state, with `setTimeout` for the 1,200ms debounce and `setInterval` for the 1s tick; the `remainingRef` + `onRetryRef` pair that keeps the auto-retry out of a `setState` updater (which React may run twice under StrictMode) and off the effect's dependency list (an inline consumer callback would otherwise reset the countdown on every parent render); the `Loader2` spinner from `lucide-react`; inline styles rather than classes; and the modern CSS the layer leans on — `inset: 0`, `color-mix(in srgb, …)` and `backdrop-filter: blur(3px)` with its `-webkit-` twin.

- **SwiftUI**: Start from `.overlay(alignment: .center)` on the board view (or a `ZStack` layer), gated by the debounced `shown` state, so the board is covered rather than replaced — `.sheet` and `.fullScreenCover` are wrong here because both are dismissible and take over the screen. The scrim is `Color(.aptBg).opacity(0.9)` over `.background(.ultraThinMaterial)`; SwiftUI has no `backdrop-filter`, and material is the nearest equivalent. The card is a `VStack(spacing: 13)` with `.padding(.vertical, 28).padding(.horizontal, 34)`, `.background(Color(.aptSurface), in: RoundedRectangle(cornerRadius: 12))`, `.overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.aptBorder), lineWidth: 1))`, `.shadow(color: .black.opacity(0.35), radius: 20, y: 8)` and `.frame(maxWidth: 360)` — there is no `ch` unit, so convert 46ch against the monospace face. Spinner: `ProgressView().progressViewStyle(.circular).controlSize(.large).tint(Color(.aptBlue))`, which animates itself, so nothing replaces `animate-spin`. Timing: a cancellable `Task` with `try await Task.sleep(for: .milliseconds(1200))` for the debounce, and `.onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect())` for the tick, cancelled in `.onDisappear`. Type: `.font(.system(size: 17, weight: .bold, design: .monospaced))` for the heading with `.kerning(0.34)` for the 0.02em tracking. Accessibility: `.accessibilityElement(children: .contain)` plus `.accessibilityAddTraits(.updatesFrequently)` and `.accessibilityLabel(heading)` stand in for `role="status"`/`aria-live="polite"`; mark the spinner and the countdown `.accessibilityHidden(true)`. Give the button `.frame(minWidth: 44, minHeight: 44)` — the source's 7×18 padding does not reach the HIG target.

- **Compose**: Start from a `Box(Modifier.matchParentSize())` inside the board's own `Box`, not `Dialog` — a dialog draws in its own window and dims the whole screen, while this layer must cover only the board. If a `Dialog` is unavoidable, pass `DialogProperties(usePlatformDefaultWidth = false, dismissOnBackPress = false, dismissOnClickOutside = false)` to match a layer that has no dismiss action. Scrim: `Modifier.background(MaterialTheme.colorScheme.background.copy(alpha = 0.9f))`; there is no portable backdrop blur, so either apply `Modifier.blur(3.dp)` to the content beneath on Android 12+ or drop the blur and keep the 90% scrim. Card: `Surface(shape = RoundedCornerShape(12.dp), border = BorderStroke(1.dp, …), shadowElevation = 8.dp)` around a `Column(verticalArrangement = Arrangement.spacedBy(13.dp), horizontalAlignment = Alignment.CenterHorizontally, modifier = Modifier.widthIn(max = 360.dp).padding(horizontal = 34.dp, vertical = 28.dp))`. Spinner: `CircularProgressIndicator(modifier = Modifier.size(34.dp), color = …)`. Timing: `LaunchedEffect(active) { delay(1_200); shown = true }` for the debounce and `LaunchedEffect(shown) { while (true) { delay(1_000); … } }` for the tick — coroutine cancellation on key change replaces the `clearTimeout`/`clearInterval` cleanup. `rememberUpdatedState(onRetry)` is the direct analogue of `onRetryRef`. Map the tokens onto a Material 3 `ColorScheme` and use `FontFamily.Monospace`. Accessibility: `Modifier.semantics { liveRegion = LiveRegionMode.Polite }` on the layer, `Modifier.clearAndSetSemantics {}` on the countdown and the spinner, and `Modifier.defaultMinSize(minWidth = 48.dp, minHeight = 48.dp)` on the button for the Material 3 target size.

- **AppKit / UIKit**: UIKit — add a plain `UIView` constrained to the board view's edges rather than presenting a `UIViewController`, which would replace the board instead of sitting over it. Layer a `UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))` under a 0.9-alpha background colour for the scrim. The card is a `UIStackView(axis: .vertical, spacing: 13)` inside a container with `layer.cornerRadius = 12`, `layer.borderWidth = 1`, `layer.shadowOffset = CGSize(width: 0, height: 8)`, `layer.shadowRadius = 20`, `layer.shadowOpacity = 0.35`, and `directionalLayoutMargins` of 28/34. Spinner: `UIActivityIndicatorView(style: .large)` with `color` set, or a `UIImageView` driven by a repeating `CABasicAnimation` on `transform.rotation.z` if the Loader2 glyph is kept. Timing: a `DispatchWorkItem` (or `Timer`) for the 1.2s debounce and `Timer.scheduledTimer(withTimeInterval: 1, repeats: true)` added to `RunLoop.main` in `.common` mode so the countdown keeps ticking during scroll tracking; invalidate both when the view is hidden or deallocated. AppKit — the same layering with `NSVisualEffectView(material: .hudWindow, blendingMode: .withinWindow)`, an `NSStackView` card and `NSProgressIndicator(style: .spinning)`. Replace the `--color-apt-*` custom properties with a `UIColor`/`NSColor` asset-catalogue set carrying light and dark variants; neither framework inherits CSS custom properties. Accessibility: there is no `aria-live`, so post `UIAccessibility.post(notification: .announcement, argument: heading)` (AppKit: `NSAccessibility.post(element:notification:.announcementRequested)`) when the heading changes, set `isAccessibilityElement = false` on the countdown label and the spinner, and give the button a 44×44pt minimum frame on iOS.

- **WinUI 3**: Place a `Grid` spanning the board's rows and columns inside the page's root `Grid`, with `Canvas.ZIndex="50"` — not a `ContentDialog`, which dims and disables the entire window and is dismissible, whereas this layer covers only the board and has no dismiss action. Scrim: a `SolidColorBrush` over the page background with `Opacity="0.9"`; XAML has no `backdrop-filter`, so get the blur from a window `DesktopAcrylicBackdrop` or from a `Microsoft.UI.Composition` `GaussianBlurEffect` painted through a `CompositionBrush` on the layer. Card: a `Border` with `CornerRadius="12"`, `BorderThickness="1"`, `BorderBrush="{ThemeResource CardStrokeColorDefaultBrush}"`, `Background="{ThemeResource CardBackgroundFillColorDefaultBrush}"`, `Padding="34,28"`, `MaxWidth="460"` and a `ThemeShadow` with a `Translation` Z offset for the `0 8 40` shadow, wrapping a `StackPanel Spacing="13" HorizontalAlignment="Center"`. Spinner: `<ProgressRing IsActive="True" Width="34" Height="34" Foreground="{ThemeResource AccentFillColorDefaultBrush}"/>`. Timing: a `DispatcherTimer` with `Interval="0:0:1"` for the tick and a second `DispatcherTimer` (or `Task.Delay(1200)` with a `CancellationTokenSource`) for the show debounce; stop both in `Unloaded`. Bind `Heading`, `Sub`, `Retrying in {countdown}s` and the detail row's `Visibility` with `x:Bind` against a ViewModel implementing `INotifyPropertyChanged`, using a `BoolToVisibilityConverter` for the detail row — the equivalent of the `detail && !deploying` guard. Typography: `FontFamily="Cascadia Mono"`, heading on `{StaticResource SubtitleTextBlockStyle}` with `FontWeight="Bold"`, subtitle on `{StaticResource CaptionTextBlockStyle}` with `Foreground="{ThemeResource TextFillColorSecondaryBrush}"`, countdown with `TextFillColorTertiaryBrush`. The stock `Button` style already supplies the `CommonStates` visual states (`Normal`, `PointerOver`, `Pressed`, `Disabled`); the source defines none, so accept the Fluent defaults rather than flattening them. Accessibility: `AutomationProperties.LiveSetting="Polite"` on the layer with `AutomationProperties.Name` carrying the heading replaces `role="status"` + `aria-live="polite"`; set `AutomationProperties.AccessibilityView="Raw"` on the countdown `TextBlock` and the `ProgressRing`; set `MinWidth="44" MinHeight="44"` on the button to reach the Fluent 2 target size. Map each `--color-apt-*` token onto the `ThemeResource` brushes above so the layer follows the app's light/dark theme.

## Design Decisions

1. **Show delay (1200ms)**: The component does not display immediately when the feed goes dark, allowing brief network hiccups and deploy moments to pass without alarming the user. 1200ms (1.2 seconds) was chosen to cover typical deploy restart times while remaining imperceptible as "delay" to the user. This decision trades instant feedback for reduced false-alarm noise.

2. **Grace period (90 seconds)**: Outages under 90 seconds are framed as "Backend deploying" (expected, calm) rather than "Backend unreachable" (unexpected, concerning). This threshold was chosen based on typical backend restart times; outages longer than this are abnormal enough to warrant explicit acknowledgment of unreachability.

3. **Retry countdown (15 seconds)**: The auto-retry cadence is 15 seconds, independent of the consuming application's own poll clock. A fixed countdown was chosen so the displayed number always counts cleanly down to a real retry without drift or desynchronization. 15 seconds balances frequent attempts (keeping user wait time low) against backend load (not hammering a recovering service).

4. **Countdown persists across heading changes**: When the outage crosses the 90-second grace period and the heading switches from "deploying" to "unreachable", the countdown continues without reset. This prevents a jarring visual reset and maintains the assumption that retries are continuing steadily.

5. **Detail text hidden during deploy phase**: Error details are only shown after the grace period expires, keeping the deploy-phase message simple and reassuring. During the brief deploy window, technical error details would be distracting and irrelevant.

6. **ref-based callback storage (onRetryRef)**: The `onRetry` callback is stored in a ref and updated on every render, but not included in the useEffect dependency array. This prevents the interval effect from re-triggering when the callback reference changes (e.g., inline arrow function in the parent). A consumer passing a new callback every render is common and should not reset the countdown.

7. **aria-hidden on countdown and spinner**: The countdown timer updates every second and would spam a screen reader if announced. The spinner is purely decorative. Both are hidden from assistive technologies; the heading and subheading convey all necessary state.

8. **Absolute positioning with inset: 0**: The overlay covers the entire parent container (must be position: relative or have a containing block context). Using `inset: 0` (shorthand for top/right/bottom/left) is cleaner and more maintainable than specifying each side individually.

9. **App-agnostic color tokens**: All colors reference ADH theme tokens (var(--color-apt-*)) rather than hard-coded values. This allows the component to adapt to the consuming application's theme without modification, supporting both light and dark mode themes applied at the app level.

10. **Obscuring background (90% opacity + blur)**: The background is intentionally opaque (90%) and blurred to make the overlay the clear focus and prevent interaction with the view beneath. A transparent overlay would blur the distinction; a fully opaque one would hide context entirely. 90% opacity with blur strikes a balance between these concerns.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| Keyboard activation | passed | Accessibility |
| Focus containment | open — see Accessibility | Accessibility |
| Touch target size | open — see Accessibility | Accessibility |
| Motion preferences | not met — spinner animates regardless of prefers-reduced-motion | Accessibility |
| Contrast | delegated to the consuming app's theme tokens | Accessibility |
| Localization support | Not applicable | Internationalization |
| Offline behavior | Not applicable | Connectivity |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.1.0 | 2026-09-22 | Mike Fullerton | Replace unresolved-gap placeholders with source-traced facts; add concrete translation guidance to Platform Notes; reword Compliance statuses |
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from source code |
