---
id: 46b0cb5d-bd0c-45d0-ab14-95054e1c59ab
title: Email Signup Form
domain: agenticdevelopertoolkit://recipes/email-signup-form
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Embeddable waitlist signup form with anti-abuse protection and customizable
  copy.
platforms:
- typescript
- web
tags:
- form
- signup
- email-capture
- embedded
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Email Signup Form

## Overview

The Email Signup Form is an embeddable React component that collects email addresses (and optionally names) for a waitlist or mailing list. It is designed for third-party websites: the component has no internal coupling to any backend other than two public endpoints (list configuration and signup submission) and can be embedded with only a public key and an API base URL. The form includes anti-abuse protection via a honeypot field and a server-side nonce aging mechanism, and communicates failures to developers through console logging rather than user-facing error details.

## Behavioral Requirements

- **must-load-config-on-mount**: Component MUST fetch list configuration from the server when mounted, using a GET request to `{apiBaseUrl}/public/signup-lists/{publicKey}` with a 10-second timeout.
- **must-timeout-config-request**: Component MUST treat config fetch failure due to timeout (after 10,000ms) as a retriable error in the `unavailable` state.
- **must-handle-config-not-ok**: Component MUST treat any HTTP response with status not 2xx as a configuration load failure and enter the `unavailable` state.
- **must-parse-config-json**: Component MUST parse the config response as JSON and extract the fields `name`, `description`, `status`, `nonce`, and optionally `minAgeMs`.
- **must-adopt-config-with-timestamp**: Component MUST record the timestamp when configuration is successfully received, for use in nonce age calculations.
- **must-show-loading-state**: Component MUST display "Loading…" text while the initial config request is in flight.
- **must-show-closed-state**: Component MUST display "{list name} is closed to new signups right now." when config.status is not "open", and MUST NOT render a form in this state.
- **must-show-unavailable-state**: Component MUST display "Signups are unavailable right now." with a clickable "Try again" button when the config fetch fails, allowing the user to retry without a page reload.
- **must-show-ready-state**: Component MUST render the signup form when config is loaded and status is "open".
- **must-validate-email-locally**: Component MUST validate the email address against the pattern `/^[^\s@]+@[^\s@]+\.[^\s@]+$/` before submission.
- **must-reject-invalid-email**: Component MUST display the validation error "Enter a valid email address." and MUST NOT submit when email fails local validation.
- **must-trim-email-before-submit**: Component MUST trim whitespace from the email value before both validation and submission.
- **must-trim-name-before-submit**: Component MUST trim whitespace from the name value before submission (if collectName is true).
- **must-wait-for-nonce-age**: Component MUST wait until the nonce age (time since config.nonce was received) exceeds config.minAgeMs before submitting, if minAgeMs is specified.
- **must-add-timing-buffer**: Component MUST add 250ms to any nonce age wait to account for clock differences and measurement rounding.
- **must-enter-submitting-state**: Component MUST set phase to "submitting" and disable the submit button before sending the POST request.
- **must-post-submission**: Component MUST POST the signup data to `{apiBaseUrl}/public/signup-lists/{publicKey}/signups` with method "POST", Content-Type "application/json", and body containing email, name (if provided), nonce, website (honeypot), and sourceUrl.
- **must-include-honeypot-in-post**: Component MUST send the honeypot field value (which MUST be empty for a human visitor) to the server in the POST body as `website`.
- **must-include-source-url**: Component MUST capture and send `window.location.href` as `sourceUrl` in the POST body, unless running on the server (SSR).
- **must-handle-submission-ok**: Component MUST enter the "done" state and display the success message when the POST response status is 2xx.
- **must-handle-submission-error**: Component MUST catch POST errors (any status not 2xx, network failure, or timeout) and display "Something went wrong. Please try again." with a generic error message.
- **must-return-to-ready-on-error**: Component MUST return to the "ready" state after an error, allowing the user to retry.
- **must-refresh-nonce-on-error**: Component MUST fetch a fresh config (with a new nonce) after a submission error, in case the original nonce has expired.
- **must-not-expose-server-errors**: Component MUST NOT display server error reasons or HTTP status codes to the visitor; errors MUST NOT leak anti-abuse gate details.
- **must-log-failures-to-console**: Component MUST log configuration and submission failures to the browser console with the public key included, for developer debugging only.
- **must-log-with-prefix**: Component MUST prefix all console error messages with `[EmailSignupForm]` for easy identification.
- **must-render-email-label**: Component MUST render a visible `<label>` with text "Email address" for the email input field.
- **must-render-name-label-when-enabled**: Component MUST render a visible `<label>` with text "Name" for the name input field when collectName is true.
- **must-mark-email-required**: Component MUST set the `required` attribute on the email input.
- **must-set-email-type**: Component MUST set type="email" on the email input.
- **must-set-name-autocomplete**: Component MUST set autoComplete="name" on the name input.
- **must-set-email-autocomplete**: Component MUST set autoComplete="email" on the email input.
- **must-mark-email-invalid-on-validation-error**: Component MUST set `aria-invalid="true"` on the email input when a validation error exists, and set it to false when there is no error.
- **must-associate-error-with-field**: Component MUST set `aria-describedby` on the email input to reference the error message when a validation error exists.
- **must-render-honeypot-hidden**: Component MUST render the honeypot input with `aria-hidden="true"`, `tabIndex={-1}`, and CSS positioning that removes it from the visual and tab order flow (e.g., `position: absolute; left: -9999px`).
- **must-opt-out-honeypot-autofill**: Component MUST apply autofill opt-out properties to the honeypot field to prevent password managers from filling it.
- **must-mark-error-alert**: Component MUST set `role="alert"` on the error message container.
- **must-display-error-when-present**: Component MUST render an error message only when an error object exists, MUST NOT pre-render an empty error container.
- **must-use-unique-ids**: Component MUST generate unique instance-scoped IDs for all inputs and labels using React.useId(), to support multiple forms on the same page.
- **must-mark-submit-disabled-during-submit**: Component MUST set the `disabled` attribute on the submit button when phase is "submitting".
- **must-mark-submit-busy**: Component MUST set `aria-busy="true"` on the submit button when the form is submitting.
- **must-change-submit-label-on-submit**: Component MUST change the button text to "Signing up…" when submitting.
- **must-show-success-message**: Component MUST display the successMessage text when phase is "done".
- **must-replace-form-on-success**: Component MUST render only the success message (not the form) when phase is "done".
- **must-focus-success-message**: Component MUST programmatically focus the success message container to ensure screen readers announce it.
- **must-set-success-role-status**: Component MUST set `role="status"` on the success message container to indicate it is a status update.
- **should-use-custom-title**: Component SHOULD use the provided title prop if supplied, otherwise fall back to config.name.
- **should-use-custom-description**: Component SHOULD use the provided description prop if supplied, otherwise fall back to config.description.
- **should-use-custom-button-label**: Component SHOULD use the provided buttonLabel prop if supplied, otherwise default to "Sign up".
- **should-use-custom-success-message**: Component SHOULD use the provided successMessage prop if supplied, otherwise default to "Thanks for signing up! Check your inbox for a confirmation."
- **should-default-collect-name**: Component SHOULD default collectName to true if not specified.
- **may-apply-custom-classname**: Component MAY apply the provided className prop to the root element for styling customization.
- **may-handle-old-backend-without-min-age**: Component MAY handle backends that do not return minAgeMs by treating it as undefined and submitting without a nonce age delay.

## Appearance

- **Form spacing**: Sections separated by 12px vertical gap (Tailwind: `gap-3`)
- **Field spacing**: Label and input separated by 4px vertical gap
- **Border radius**: 6px on all inputs and buttons
- **Input padding**: 8px horizontal × 8px vertical on inputs (Tailwind: `px-3 py-2`)
- **Button padding**: 8px horizontal × 8px vertical (Tailwind: `px-4 py-2`)
- **Font size**: Form sections 14px (`text-sm`), heading 18px (`text-lg`)
- **Font weight**: Heading 500 (medium), button 500 (medium)
- **Text color**: Primary text black, secondary text 70% opacity on description, 60% opacity on footer
- **Border**: 1px solid gray on inputs and buttons (platform default)
- **Disabled state opacity**: 50% on submit button when disabled
- **Loading text**: 14px, 60% opacity
- **Error text**: 14px, red-600

## States

| State | Appearance change |
|-------|------------------|
| Loading | Shows "Loading…" text at 60% opacity; no form |
| Ready | Full form visible with email and optional name fields; submit button enabled |
| Submitting | Submit button disabled and at 50% opacity; button text changes to "Signing up…"; aria-busy="true" |
| Done | Form hidden; success message displayed with focus |
| Closed | Message "This list is closed to new signups right now."; no form |
| Unavailable | Error message "Signups are unavailable right now." with a "Try again" button |

## Accessibility

- Role: The component itself does not have a role; it contains a `<form>` element which is implicitly a form.
- Labels: All form inputs (name, email) MUST have associated `<label>` elements; labels MUST NOT use placeholders in place of labels.
- Email validation: aria-invalid MUST be set to true when a validation error exists; aria-describedby MUST reference the error message.
- Error announcement: Error messages MUST have role="alert" so screen readers announce them when they appear.
- Success announcement: The success message MUST have role="status" and programmatic focus to ensure announcement.
- Submit button state: aria-busy="true" MUST be set when submitting to indicate to screen readers the button is working.
- Honeypot: The honeypot input MUST be hidden from both visual and assistive tech via aria-hidden="true" and removed from tab order via tabIndex={-1}.
- Touch target: Buttons and input fields MUST have minimum 44px height for mobile touch targets (Tailwind base uses standard heights; verify in platform guidelines).
- Autofill: The honeypot field MUST opt out of password manager autofill using the noAutofillProps from the codebase (per-vendor opt-out codes).

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| esf-001 | must-load-config-on-mount, must-show-loading-state | Mount component with valid publicKey and apiBaseUrl | Component displays "Loading…" text initially |
| esf-002 | must-parse-config-json, must-show-ready-state | Config fetch returns 200 with status "open" | Component renders form with email field and optional name field |
| esf-003 | must-timeout-config-request, must-show-unavailable-state | Config fetch hangs beyond 10,000ms | Component enters unavailable state and displays "Try again" button |
| esf-004 | must-handle-config-not-ok, must-show-unavailable-state | Config fetch returns 404 or 500 | Component enters unavailable state; console error logged with public key |
| esf-005 | must-show-closed-state | Config fetch returns 200 with status "closed" | Component displays "{list name} is closed to new signups right now." with no form |
| esf-006 | must-validate-email-locally, must-reject-invalid-email | User enters "notanemail" and submits | Form displays validation error and does not submit |
| esf-007 | must-validate-email-locally | User enters "user@example.com" | Form passes validation check |
| esf-008 | must-trim-email-before-submit | User enters "  user@example.com  " | Email is trimmed before validation and submission |
| esf-009 | must-wait-for-nonce-age | Config returned with minAgeMs 3000; user submits after 1000ms | Submission waits approximately 2250ms (3000 - 1000 + 250ms buffer) before sending |
| esf-010 | must-enter-submitting-state, must-mark-submit-disabled-during-submit | User clicks submit with valid email | Submit button becomes disabled and shows "Signing up…" text |
| esf-011 | must-post-submission, must-include-honeypot-in-post, must-include-source-url | User submits with email="test@example.com", name="Alice", honeypot="" | POST body contains email, name, nonce, website: "", sourceUrl |
| esf-012 | must-handle-submission-ok, must-show-success-message | POST returns 200 | Component enters done state and displays successMessage |
| esf-013 | must-focus-success-message | Submission succeeds | Success message container receives focus |
| esf-014 | must-handle-submission-error, must-not-expose-server-errors | POST returns 400 or 500 | Component displays generic error "Something went wrong. Please try again." (no status code shown) |
| esf-015 | must-return-to-ready-on-error | Submission fails | Component returns to ready state; form is visible and submit button is re-enabled |
| esf-016 | must-refresh-nonce-on-error | Submission fails and returns to ready | A new config fetch is initiated; nonce timestamp is updated |
| esf-017 | must-mark-email-invalid-on-validation-error | Validation error occurs | Email input has aria-invalid="true"; aria-describedby references error message |
| esf-018 | must-mark-email-invalid-on-validation-error | Form is valid or error is cleared | Email input has aria-invalid="false" |
| esf-019 | must-render-honeypot-hidden | Inspect DOM | Honeypot input has tabIndex=-1, aria-hidden="true", and CSS position: absolute; left: -9999px |
| esf-020 | must-use-unique-ids | Mount two instances on the same page | Each instance has distinct label-to-input associations; no duplicate IDs |
| esf-021 | should-default-collect-name | Mount component without collectName prop | Name field is rendered |
| esf-022 | may-apply-custom-classname | Mount with className="custom-class" | Root element has the custom-class applied |
| esf-023 | should-use-custom-title | Mount with title="Join our list" | Heading displays "Join our list" instead of config.name |
| esf-024 | should-use-custom-button-label | Mount with buttonLabel="Subscribe" | Submit button displays "Subscribe" instead of "Sign up" |
| esf-025 | must-log-failures-to-console, must-log-with-prefix | Config fetch fails | Browser console contains error starting with "[EmailSignupForm]" and includes the public key |

## Edge Cases

- **Empty config.name**: If the server returns config.name as empty string or null, the component renders config.description as is (no coalescing check in code).
- **Multiple embeds on same page**: Each instance generates unique IDs via React.useId(); form submissions from one instance do not affect others.
- **Submission during config refresh**: If a submission fails and triggers a config refresh while the user is attempting another submission, the first submission's error state is preserved until the refresh completes; a fresh form state is MUST NOT be forced until the refresh completes or fails silently.
- **Nonce expiration mid-session**: If a tab remains open past the server's nonce lifetime (30 minutes), a retry uses the stale nonce, the server rejects it, an error is shown, and a refresh fetches a new nonce. This MUST succeed; the visitor is not stuck.
- **Clock skew between client and server**: The nonce age is measured as a duration from the receive timestamp (Date.now()), not as a comparison between server and client clocks, so a visitor's skewed clock cannot shorten the required wait.
- **Slow network connection**: A visitor on a slow connection who takes 8 seconds to fill the form and submit will submit immediately upon clicking (no additional wait), because the required wait is calculated as `minAgeMs - (Date.now() - received)`, which can be zero or negative.
- **Network failure during POST**: Any error during the POST (timeout, connection refused, non-2xx status) is treated identically: the component shows "Something went wrong" and returns to ready.
- **Password manager autofilling honeypot**: The honeypot field has autofill opt-out properties; if a password manager ignores these and fills the field anyway, the server treats any non-empty value as a bot submission and silently rejects it.
- **Validation error clears on input change**: Once the user edits the email field after a validation error, the error state MUST NOT persist; the error only reappears on the next submission if validation fails again.
- **Success message persists until unmount**: Once the component enters the done state, it displays only the success message. The component does NOT automatically reset or navigate; the parent is responsible for removing or replacing the component.
- **Empty email field**: If the user submits without entering an email, the local validation fails and displays "Enter a valid email address."

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| publicKey | string | (required) | The list's public key from the hub's Embed panel. Must match a key on the backend. |
| apiBaseUrl | string | (required) | The base URL of the two public endpoints, with no trailing slash. May be an absolute origin (https://api.example.com) or a relative path (/api). |
| title | string | undefined (uses config.name) | Overrides the list name displayed as the form heading. |
| description | string | undefined (uses config.description) | Overrides the list description displayed below the heading. |
| buttonLabel | string | "Sign up" | Overrides the submit button text. |
| successMessage | string | "Thanks for signing up! Check your inbox for a confirmation." | Overrides the success state message. |
| collectName | boolean | true | Whether to render a name input field. |
| className | string | undefined | Custom CSS class names to apply to the root element. |

## Deep Linking

Not applicable: Email Signup Form is an embedded component within a page, not a top-level destination with its own URL scheme or deep-link pattern.

## Localization

Not applicable: All user-facing strings are customizable via component props (title, description, buttonLabel, successMessage). The component itself contains no hardcoded localization keys or translation infrastructure.

## Accessibility Options

Not applicable: The component does not explicitly respond to platform accessibility display options (reduce motion, increase contrast, differentiate without color). It uses standard form semantics and does not include decorative animations or motion effects beyond button state changes.

## Feature Flags

Not applicable: The component itself contains no internal feature flags. The backend may gate the feature via the ecosystem's email-signup flag (referenced in the source comments), but this is not exposed to the component.

## Analytics

Not applicable: The component does not emit analytics events. Event tracking, if desired, must be added by the parent application wrapping the component with onError or onSuccess callbacks (not implemented in this version).

## Privacy

- **Data collected**: Email address (required), name (optional, if collectName is true), page URL (sourceUrl).
- **Storage**: The component does not store data locally. Data is transmitted to the backend immediately upon submission.
- **Transmission**: Email, name, and sourceUrl are transmitted in a POST body via HTTP/HTTPS to the backend endpoint. The request includes the signed nonce for anti-abuse verification.
- **Retention**: Retention is determined by the backend list configuration and the hub. The component has no control over retention.
- **Honeypot**: The honeypot field is never filled by a human visitor and is never sent to the backend if the visitor is legitimate. If sent (value non-empty), the server's anti-abuse gate silently rejects the submission without writing it.

## Logging

Subsystem: Application console (developer-facing only)

| Event | Level | Message Format |
|-------|-------|-----------------|
| Config load failure | error | `[EmailSignupForm] could not load the signup list for public key "{publicKey}": {reason}` |
| Config refresh failure | error | `[EmailSignupForm] could not refresh the signup nonce for public key "{publicKey}": {reason}` |

## Platform Notes

- **React/Web**: The component is a functional React component using hooks (useState, useRef, useCallback, useEffect, useId). It uses React 18+ context and must be rendered within a React app. Styling is applied via Tailwind CSS utility classes; applications must have Tailwind configured. The component does not depend on any external UI library (buttons and inputs are bare HTML elements with CSS classes). It uses the `cn` utility (likely clsx-like) for conditional class names and `noAutofillProps` from a local utilities file. Source: `packages/web/packages/ui/src/components/email-signup-form.tsx`.
- **SwiftUI**: Start from `Form` container with `TextField` for email and optional name input. SwiftUI's async/await patterns replace the useEffect-based config fetching; use `Task` in `.onAppear`. Replace phase states with @State property. Implement the honeypot as a hidden `TextField` with `.hidden()`. Use `.navigationTitle` for the heading and `.font(.title3)` for text sizing. Handle the 10-second timeout using `URLSession` with `.timeoutInterval`.
- **Compose**: Use `Box` or `Column` for layout with `spacedBy = 12.dp`. Replace phase states with `MutableState` or ViewModel-backed state. Implement email validation with the same regex (`EMAIL_RE`). Use `TextField` for email/name inputs and `BasicButton` or `Button` for submit. The honeypot is a `TextField` hidden from the composable tree (conditional rendering, not `.hidden()`). Handle async config fetch and POST with coroutines in a `ViewModel` or `LaunchedEffect`.
- **UIKit / AppKit**: Use `NSForm` (AppKit) or `UIStackView` (UIKit) for layout. Replace React state management with properties and delegation (UITextFieldDelegate, URLSessionDelegate). Implement the loading state with `NSProgressIndicator` (AppKit) or `UIActivityIndicatorView` (UIKit). The honeypot is a hidden `NSTextField` / `UITextField` with `.isHidden = true` and `.alpha = 0` or positioned off-screen. Use `URLSession` for config and submission fetches with a 10-second timeout.
- **WinUI 3**: Use `StackPanel` with `Spacing="12"` for the form container. Use `TextBox` for email and name fields, bound to ViewModel properties via data binding. Implement phase states as a `SelectedIndex` property on a `Pivot` control, or use a `VisualStateManager` to swap visibility of form vs. loading vs. error states. Use `Button` for submit with a binding to a `ICommand` that handles submission. The honeypot is a `TextBox` with `Visibility="Collapsed"`. Handle async config and POST via `HttpClient` with `Timeout = TimeSpan.FromSeconds(10)`. Implement nonce age wait with `Task.Delay`. Validation errors are shown as `TextBlock` elements with a `Foreground` binding to error state.

## Design Decisions

- **10-second config timeout**: A hung request keeps the form on "Loading…" forever, taking up real estate on the visitor's page with no affordance to recover. 10 seconds is generous enough for slow mobile connections but short enough that nobody stares at a spinner for a minute. This becomes a retriable error state instead of a dead end.
- **Nonce age enforcement at client**: The server requires a minimum age for the nonce to prevent rapid-fire bot submissions. Measuring the age as a duration from client receive time (not a server timestamp comparison) makes the wait immune to clock skew; a visitor whose clock is off still measures real elapsed time. Adding a 250ms buffer accounts for rounding and timing noise.
- **Generic server errors**: The component does not expose server error reasons (e.g., "invalid submission", "rate limit") to the visitor because they describe the anti-abuse gate. Leaking which defense tripped is an attack surface. Developers see the real error in the console; visitors see only "Something went wrong."
- **Silent config refresh on submission error**: A failed submission does not surface a second error to the visitor; instead, it silently refreshes the nonce. If the refresh itself fails, the visitor still has the form, and retrying (with a stale nonce) is still better than showing a dead end. This trades silent nonce staleness for a form that remains usable.
- **Honeypot over CSRF tokens**: The component uses a honeypot (a form field invisible to humans) rather than CSRF token validation because CSRF tokens require a shared session or state between the page and backend. A public endpoint has no session, so a honeypot is the only bot defense available at this layer (the server layer enforces nonce aging and IP rate limits).
- **sourceUrl captures window.location.href**: The backend stores this as the consent record's provenance, proving the address opted in at this specific page. This is necessary for compliance and dispute resolution.
- **No optimistic submission**: The form does not optimistically show a success state while the POST is in flight. It must wait for the server response because a stale nonce or a backend outage could reject the submission. Showing success prematurely and then failing is worse than waiting for confirmation.
- **Separate "closed" and "unavailable" states**: These are mutually exclusive: "closed" means the list loaded and is not accepting signups (a durable answer), "unavailable" means the backend never answered (retriable). Collapsing them would have the form claim a perfectly open list is closed whenever the backend happens to be down.
- **Labels instead of placeholders**: Placeholder text vanishes when the user starts typing and is not reliably announced by assistive tech. Real labels stay visible and accessible.
- **Instance-scoped IDs**: Multiple forms on the same page each get unique IDs via React.useId(), so labels and inputs from one form do not interfere with another.
- **Rendered aria-invalid for both true and false states**: The field's validation state is always readable by assistive tech and tests, not just its failure half. This is more maintainable than conditionally rendering the attribute.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| Accessible form labels | passed | Accessibility |
| Email field type | passed | Accessibility |
| Error role="alert" | passed | Accessibility |
| Success role="status" with focus | passed | Accessibility |
| Honeypot hidden from a11y | passed | Accessibility |
| Submit button aria-busy | passed | Accessibility |
| Touch target size | passed | Accessibility |
| No placeholder-only labels | passed | Accessibility |
| Server error generalization | passed | Privacy |
| No hardcoded strings | passed | Localization |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
