---
id: 4d2b7231-1235-49e9-8b7d-1e7507c6eba7
title: NavChrome
domain: agenticdevelopertoolkit://recipes/nav-chrome
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Fixed navigation bar with burger menu, drawer, and keyboard-managed focus
  for responsive site navigation.
platforms:
- typescript
- web
tags:
- navigation
- drawer
- responsive
- keyboard-accessible
depends-on: []
related: []
references:
- https://www.w3.org/WAI/ARIA/apg/patterns/dialogmodal/
approved-by: ''
approved-date: ''
---

# NavChrome

## Overview

NavChrome is a mobile-first navigation chrome consisting of a fixed bar with a burger menu button, an optional brand/logo, a modal drawer containing navigation links, a scrim overlay, and comprehensive keyboard and focus management. The drawer is modal to both pointer and keyboard—Tab focus is trapped inside when open, Escape closes it, and focus is managed on open and close transitions. It supports smooth scrolling to same-page fragment anchors while moving focus to the target, and degrades gracefully for off-page links.

## Behavioral Requirements

- **must-render-bar**: Component MUST render a fixed bar containing a burger menu button and an optional brand container.
- **must-render-burger**: Component MUST render a button to toggle the drawer open and closed, labeled via `openLabel` prop (default: 'Open menu').
- **must-render-drawer**: Component MUST render a navigation drawer containing an array of anchor links passed via the `links` prop.
- **must-render-close-button**: Component MUST render a close button inside the drawer, labeled via `closeLabel` prop (default: 'Close menu').
- **must-render-scrim**: Component MUST render a scrim overlay that covers the page when the drawer is open.
- **must-render-optional-brand**: Component MUST render the `brand` prop content in the bar if provided; MUST NOT render a brand container if `brand` is undefined.
- **must-render-optional-footer**: Component MUST render the `footer` prop content in the drawer if provided; MUST NOT render a footer container if `footer` is undefined.
- **must-set-nav-label**: Component MUST set `aria-label` on the `<nav>` element to the `navLabel` prop (default: 'Site').
- **must-toggle-open-state**: Component MUST toggle the drawer open state when the burger button or scrim is clicked, or when the drawer close button is clicked.
- **must-close-on-link-click**: Component MUST close the drawer when any navigation link is clicked, regardless of whether the link resolves to a same-page fragment or an off-page URL.
- **must-trap-tab-inside-drawer**: While the drawer is open, component MUST trap Tab key focus inside the drawer: when Tab is pressed with focus on the last focusable element, focus MUST wrap to the first focusable element; when Shift+Tab is pressed with focus on the first focusable element, focus MUST wrap to the last focusable element.
- **must-close-on-escape**: Component MUST close the drawer when the Escape key is pressed while the drawer is open.
- **must-return-focus-to-burger**: Component MUST return focus to the burger button when the drawer is closed, provided the drawer was previously open (not on initial render).
- **must-move-focus-to-close-button**: Component MUST move focus to the close button inside the drawer immediately after the drawer opens.
- **must-set-inert-when-closed**: Component MUST set the `inert` attribute on the drawer when it is closed, removing it when open.
- **must-prevent-tab-outside-drawer**: Component MUST prevent Tab from moving focus outside the drawer by listening on `document` and catching Tab presses, not only on the drawer element itself.
- **must-close-drawer-on-scrim-click**: Component MUST close the drawer when the scrim is clicked.
- **must-query-focusables-on-tab**: Component MUST query the DOM for focusable elements (buttons and anchors with href) each time Tab is pressed, not cache them in state.
- **must-support-fragment-navigation**: Component MUST parse anchor `href` attributes as fragment IDs (e.g., '#section-id'), extract the element by id using `document.getElementById()`, and scroll it into view without using `document.querySelector()`.
- **must-manage-focus-on-fragment-scroll**: Component MUST move focus to the target element after a same-page fragment scroll, using `tabindex="-1"` to make arbitrary elements focusable.
- **must-prevent-default-fragment-scroll**: Component MUST prevent the browser's default anchor navigation and use custom scroll behavior controlled by `scroll-behavior: smooth` on the host's `html` element.
- **must-handle-encoded-fragments**: Component MUST decode percent-encoded fragment IDs using `decodeURIComponent()`, and MUST gracefully handle malformed percent-encoding by falling back to the raw fragment.
- **must-close-on-off-page-link**: Component MUST close the drawer when an off-page link (one that does not resolve to a same-page fragment) is clicked, even if no navigation occurs.
- **must-clear-focus-return-before-fragment-scroll**: Component MUST clear the `wasOpen` focus-return gate before moving focus to a fragment target, so that the focus-return effect does not override the arrival focus.
- **must-handle-empty-focusables**: Component MUST not throw an error if no focusable elements are found inside the drawer (e.g., if the links array is empty and no footer is provided).
- **must-aria-expand-burger**: Component MUST set `aria-expanded` on the burger button to `true` when the drawer is open, `false` when closed.
- **must-aria-hide-scrim**: Component MUST set `aria-hidden="true"` on the scrim.
- **must-use-button-type**: Component MUST render burger and close buttons with `type="button"` to prevent form submission.
- **must-support-custom-labels**: Component MUST accept `openLabel`, `closeLabel`, and `navLabel` props; MUST use default values ('Open menu', 'Close menu', 'Site') when props are undefined.
- **must-prevent-focus-steal-on-load**: Component MUST not move focus on the initial render, even though `wasOpen` is initialized to false.

## Appearance

NavChrome provides semantic structure and class names for styling; visual appearance is the responsibility of the host CSS.

- **Classes for styling**:
  - `.lp-bar`: The fixed navigation bar containing burger and optional brand
  - `.lp-burger`: The burger menu button (also used for the close button with `.lp-drawer-close`)
  - `.lp-brand`: Optional brand/logo container
  - `.lp-drawer`: The modal navigation drawer
  - `.lp-drawer--open`: Class added to drawer when open (modifier)
  - `.lp-drawer-close`: Close button inside the drawer (inherits `.lp-burger`)
  - `.lp-scrim`: The overlay covering the page (not focusable, `aria-hidden="true"`)
  - `.lp-scrim--show`: Class added to scrim when drawer is open (modifier)
  - `.lp-nav`: Navigation anchor links inside the drawer
  - `.lp-foot`: Optional footer content container

- **CSS Custom Properties**:
  - `--lp-chrome-top`: Allows the host to offset the entire chrome (bar, scrim, drawer) below a site header; the component references this but does not set it

## States

| State | Appearance change | aria-expanded | inert |
|-------|------------------|---|---|
| Drawer closed | `.lp-drawer` has no `.lp-drawer--open` class; `.lp-scrim` has no `.lp-scrim--show` class | `false` | `true` (drawer) |
| Drawer open | `.lp-drawer` has `.lp-drawer--open` class; `.lp-scrim` has `.lp-scrim--show` class | `true` | `false` (drawer) |

## Accessibility

- **Role**: The navigation bar is a `<div>` (not a `<header>` to avoid creating an unintended banner landmark when a host header already exists). The drawer is a `<nav>` with `aria-label={navLabel}`.
- **Labels**: Burger button labeled via `aria-label={openLabel}`. Close button labeled via `aria-label={closeLabel}`. Nav drawer labeled via `aria-label={navLabel}`.
- **Focus management**: Focus moves to the close button when drawer opens. Focus returns to the burger button when drawer closes (if it was previously open). Fragment link clicks move focus to the target element with `tabindex="-1"`.
- **Inert**: Drawer is `inert={true}` when closed, preventing keyboard and assistive technology access.
- **Tab trap**: Tab key is trapped inside the drawer when open; focus wraps from last to first and first to last.
- **Escape key**: Escape closes the drawer, the standard dismissal gesture.
- **Scrim**: Scrim has `aria-hidden="true"` and is not focusable; it is a visual overlay for pointer users only.
- **Keyboard accessibility**: All navigation is keyboard-accessible: Escape and Shift+Tab from first element exit the drawer, Tab wraps focus, and all links are reachable.
- **Link semantics**: Links are standard `<a>` elements with real `href` attributes, so they degrade gracefully without JavaScript.
- **Minimum touch target**: Component does not define a minimum tap target size; host CSS MUST ensure burger and close buttons meet platform requirements (44×44pt iOS, 48×48dp Android, etc.).

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| nav-001 | must-render-bar | Render NavChrome with default props | Bar div with className 'lp-bar' contains a button with className 'lp-burger' |
| nav-002 | must-render-burger, must-aria-expand-burger | Render with drawer closed | Burger button has aria-expanded="false" |
| nav-003 | must-render-burger, must-aria-expand-burger | Click burger to open drawer | Burger button has aria-expanded="true" |
| nav-004 | must-toggle-open-state | Render with drawer closed, click burger | Drawer className changes to include 'lp-drawer--open' |
| nav-005 | must-toggle-open-state | Drawer open, click burger again | Drawer className no longer includes 'lp-drawer--open' |
| nav-006 | must-render-scrim, must-close-on-scrim-click | Render with drawer open, click scrim | Drawer closes and scrim className no longer includes 'lp-scrim--show' |
| nav-007 | must-render-drawer, must-render-optional-brand | Render with brand prop | Brand content appears in bar div with className 'lp-brand' |
| nav-008 | must-render-drawer, must-render-optional-brand | Render with brand undefined | No 'lp-brand' div is rendered |
| nav-009 | must-close-on-link-click | Drawer open, click a navigation link with same-page fragment href | Drawer closes |
| nav-010 | must-close-on-link-click | Drawer open, click a navigation link with off-page href | Drawer closes |
| nav-011 | must-support-fragment-navigation, must-prevent-default-fragment-scroll | Render with link href='#section1', click link | Browser default anchor navigation is prevented; target element is located by id |
| nav-012 | must-manage-focus-on-fragment-scroll | Click link href='#section1' where section1 exists | Target element receives focus; tabindex="-1" is set on target |
| nav-013 | must-support-fragment-navigation | Render with link href='#section%20one' | fragmentId() correctly decodes percent-encoding and locates element by decoded id |
| nav-014 | must-handle-encoded-fragments | Render with link href='#%XX' (malformed percent) | fragmentId() catches decodeURIComponent error and uses raw fragment |
| nav-015 | must-trap-tab-inside-drawer | Drawer open with 3 focusable elements, Tab from last element | Focus wraps to first element |
| nav-016 | must-trap-tab-inside-drawer | Drawer open, Shift+Tab from first element | Focus wraps to last element |
| nav-017 | must-prevent-tab-outside-drawer | Drawer open, Shift+Tab from first element | preventDefault() is called on Tab event |
| nav-018 | must-close-on-escape | Drawer open, press Escape key | Drawer closes |
| nav-019 | must-move-focus-to-close-button | Drawer closed, click burger to open | Close button has focus immediately after open |
| nav-020 | must-return-focus-to-burger | Drawer open, click close button or Escape to close | Focus returns to burger button |
| nav-021 | must-prevent-focus-steal-on-load | Render page with NavChrome | No element receives unwanted focus on initial render |
| nav-022 | must-set-inert-when-closed | Drawer closed | Drawer has inert={true} |
| nav-023 | must-set-inert-when-closed | Drawer open | Drawer has inert={false} |
| nav-024 | must-render-optional-footer | Render with footer prop | Footer content appears in drawer with className 'lp-foot' |
| nav-025 | must-render-optional-footer | Render with footer undefined | No 'lp-foot' div is rendered |
| nav-026 | must-set-nav-label | Render with navLabel='Main Navigation' | Nav has aria-label='Main Navigation' |
| nav-027 | must-query-focusables-on-tab | Drawer open, modify focusable elements, press Tab | New focusable elements are included in Tab trap calculation |
| nav-028 | must-handle-empty-focusables | Render with empty links array and no footer, drawer open | Tab key does not throw error; trap simply has no elements to cycle |
| nav-029 | must-close-on-off-page-link | Click link href='/other-page' | Drawer closes; browser navigates to off-page URL |
| nav-030 | must-aria-hide-scrim | Drawer open | Scrim has aria-hidden="true" |

## Edge Cases

- **Bare fragment (#)**: A link with href='#' or an empty href. fragmentId() returns null, and go() allows the browser to handle it (scroll to top). The drawer still closes.
- **Non-existent fragment**: A link with href='#missing-section' where no element has id='missing-section'. fragmentId() returns 'missing-section', getElementById() returns null, go() does not navigate but still closes the drawer and allows the browser to attempt the navigation.
- **Off-page link**: A link with href='/other-page' or 'https://example.com'. fragmentId() returns null (does not start with '#'), go() closes the drawer unconditionally, and allows the browser to navigate.
- **Malformed percent-encoding**: A link with href='#bad%ZZ'. decodeURIComponent() throws, fragmentId() catches and returns the raw fragment 'bad%ZZ'.
- **Empty links array**: No navigation links provided. Drawer renders with only the close button and optional footer. Tab trap works correctly with remaining focusables.
- **No footer**: Footer prop is undefined. Footer container is not rendered.
- **No brand**: Brand prop is undefined. Brand container is not rendered.
- **Focus outside drawer while open**: A click on the scrim or elsewhere that moves focus outside the drawer; the next Tab press pulls focus back into the drawer via the trap.
- **Escape key on page with no drawer**: Escape listener is only attached when drawer is open (useEffect dependency), so no interference with other page Escape handlers.
- **Tab press with no focusable elements**: If focusable array is empty (e.g., no links, no footer, close button is somehow hidden), Tab does nothing and focus does not move.
- **Browser autofocus behavior**: The drawer is rendered off-screen with a transform (delegated to host CSS) and `inert={true}` when closed, preventing browser autofocus from reaching elements inside.
- **Very long page with many focusable elements**: All focusables are queried from the DOM every Tab press, not cached, so new or removed focusables are reflected immediately.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `brand` | `ReactElement \| undefined` | `undefined` | Optional content to render in the bar (e.g., logo, wordmark) |
| `links` | `Array<{ href: string; label: string }>` | required | Array of navigation links; each has `href` (same-page fragment or URL) and `label` (link text) |
| `footer` | `ReactElement \| undefined` | `undefined` | Optional content to render in the drawer footer |
| `openLabel` | `string` | `'Open menu'` | aria-label for the burger button |
| `closeLabel` | `string` | `'Close menu'` | aria-label for the close button |
| `navLabel` | `string` | `'Site'` | aria-label for the nav drawer |

## Deep Linking

| Platform | Pattern | Behavior |
|----------|---------|----------|
| Web | `/#section-id` | Drawer closes; same-page fragment is targeted by id lookup, focus moves to target, scroll-behavior is smooth (set on host html element) |
| Web | `#encoded%20id` | Drawer closes; fragment is percent-decoded before id lookup |
| Web | `/other-page` | Drawer closes; browser navigates to URL (off-page link) |

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| `openLabel` | `'Open menu'` | Burger button aria-label |
| `closeLabel` | `'Close menu'` | Close button inside drawer aria-label |
| `navLabel` | `'Site'` | Navigation drawer aria-label |

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Not applicable: no animated transitions are performed by the component. Animations are delegated entirely to host CSS (e.g., `.lp-drawer--open` state change applies CSS transitions). |
| Increase Contrast | Not applicable: styling is the responsibility of host CSS; component provides only class names and semantic elements. |
| Differentiate Without Color | Not applicable: component uses no color to convey state; state is conveyed through aria-expanded, aria-hidden, and class name changes that are styled by the host. |

## Feature Flags

Not applicable: Feature flags are not implemented in source. The component is always enabled and has no feature flag configuration.

## Analytics

Not applicable: Analytics events are not implemented in source. The component provides no built-in analytics instrumentation. Host applications may attach click listeners or track navigation links independently.

## Privacy

**Data collected**: No data is collected by the component itself. The component stores only internal state (drawer open/closed) in React component state.

**Storage**: No data is persisted.

**Transmission**: No data is transmitted.

**Retention**: No data is retained. State is lost on page reload.

## Logging

Not applicable: Logging is not implemented in source. The component provides no built-in logging instrumentation.

## Platform Notes

- **TypeScript/React**: NavChrome is a React functional component in `/packages/web/packages/landing/src/chrome/NavChrome.tsx`. It uses `useState` for drawer open state, `useRef` for element references to manage focus, and `useEffect` hooks for focus management and keyboard event listeners. The component returns JSX with semantic HTML (`<nav>`, `<button>`, `<a>`) and relies on host CSS for all styling via class names (`.lp-bar`, `.lp-burger`, `.lp-drawer`, `.lp-scrim`, etc.).

- **SwiftUI**: SwiftUI lacks native browser-style drawer and scrim concepts. To port this pattern, use `@State` to track drawer open state, a `ZStack` to layer drawer and scrim, `transition(.move)` or custom animations for the drawer position, and place all content inside a `NavigationView` or `NavigationStack`. Keyboard handling would use `.onReceive(publisher)` to detect physical keyboard or hardware key presses (not applicable to most SwiftUI targets, which are touch-first). Focus management uses `@FocusState` and `focusable()` modifier; Tab trapping is handled via explicit focus restoration in a computed property watching the drawer state.

- **Compose**: Compose does not have a built-in drawer or scrim; use Material's `ModalDrawer` or a custom `Box` with `Modifier.clickable()` for the scrim. State is tracked via `mutableStateOf()`. Keyboard handling uses `Key.Escape` and `Key.Tab` in a `KeyboardOptions` event handler on a `Focusable` wrapper. Focus management uses `FocusRequester` to move focus to the close button on open and back to the burger on close. Tab trapping is performed by querying focusable descendants and wrapping focus manually.

- **AppKit / UIKit**: UIKit uses `UIButton` for the burger and close buttons, `UITableViewController` or custom scroll view for the drawer content, and `UIView` with gesture recognizer for the scrim. State is tracked via a property. Keyboard handling in UIKit is limited; keyboard events are intercepted in a custom `UIViewController` responder chain if full keyboard support is needed. Focus management on iOS uses `setNeedsFocus()` and `becomeFirstResponder()` for UIControl subclasses, though iOS does not support Tab focus cycling the way web browsers do—keyboard navigation is handled by the system's voice-over or accessibility rotor. Dismiss is typically by gesture (swipe) or the close button.

- **WinUI 3**: WinUI 3 uses `NavigationView` for the chrome and `SplitView` or custom `Grid` for drawer positioning. The burger button is a `Button` with icon. The scrim is a `Rectangle` with a semi-transparent brush and `PointerPressed` event handler. State is tracked via XAML binding (`IsOpen` dependency property). Keyboard handling is done via `KeyDown` event on the main `Window`. Tab focus trapping is implemented by storing focus positions in a collection and cycling focus via `Focus()` method on `UIElement`. Escape closes the drawer via a `KeyDown` handler. The drawer uses `x:Name` and `IsOpen` binding to control visibility and opacity; smooth transitions are applied via `Storyboard` animations or `Composition` APIs.

## Design Decisions

1. **Tab trap on document, not drawer**: The keyboard event listener is attached to `document` rather than the drawer element itself. This ensures Tab is caught even when focus has escaped to the scrim (e.g., via a stray click). A listener on the drawer alone would miss these cases and allow Tab to move focus outside the drawer.

2. **Inert attribute for closed drawer**: The drawer is marked `inert={true}` when closed. This removes all closed-drawer elements from the accessibility tree and tab order, preventing keyboard and screen reader users from reaching them. This is more comprehensive than `tabIndex={-1}` alone, which would only hide the drawer from Tab but not from assistive tech.

3. **wasOpen ref gates focus return**: The `wasOpen` ref is used to prevent focus-stealing on the initial render. Without it, the focus-return effect would run on mount (when `wasOpen` is false and then set to true), moving focus to a burger button the user has not yet interacted with. The gate ensures focus is only returned after a deliberate open→closed transition.

4. **Fragment parsing with getElementById, not querySelector**: The code uses `document.getElementById(id)` rather than `document.querySelector()` to resolve fragment targets. This is safe because element ids (unlike CSS selectors) can contain special characters like dots, slashes, and digits at the start. A querySelector would throw a `SyntaxError` on hrefs like `#2024-results` or `mailto:hi@example.com`, whereas getElementById simply returns null for these and allows fallback.

5. **Scrolling delegated to CSS**: The component sets `scroll-behavior: smooth` on the host's `html` element, not in the component. This allows the host to control scroll behavior globally and ensures smooth scrolling works whether the link is clicked from the drawer or elsewhere on the page. The component only calls `scrollIntoView()` to ensure the target is visible and moves focus.

6. **Drawer positioning via CSS transform, not JavaScript**: The drawer is positioned off-screen by the host's `.lp-drawer` and `.lp-drawer--open` CSS rules, not moved by JavaScript. This keeps animations in CSS and allows the host to use transitions or media queries to adjust positioning for different screen sizes.

7. **Brand container always rendered (when brand prop is provided)**: The brand container is not an inline conditional within JSX but a separate div rendered only when the prop is defined. This allows host CSS to apply layout rules to `.lp-brand` consistently.

8. **Burger and close buttons share a class**: Both use `.lp-burger` with `.lp-drawer-close` added to the close button. This allows shared styling for button dimensions and appearance, with additional rules for the close button's X icon transformation (via `.lp-drawer-close` in `chrome.css`).

## Compliance

Not applicable: Compliance checks beyond accessibility and semantic HTML are not defined in source.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from source |
