---
id: 42e7a2ea-f138-4edb-899f-43c1946e4ef8
title: FAQ
domain: agenticdevelopercookbook://ingredients/faq
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Accordion display of questions and answers using native HTML details/summary
  elements, requiring no JavaScript for expand/collapse.
platforms:
- web
tags:
- faq
- accordion
- disclosure
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# FAQ

## Overview

The FAQ component renders a list of questions and answers as collapsible disclosure widgets. Each question appears in a clickable summary; clicking expands to reveal the answer. Built entirely from native HTML `<details>` and `<summary>` elements, it requires no JavaScript logic for expand/collapse behavior. The component supports setting one or more entries to start in the expanded state. It remains open when printed and is fully searchable with the browser's Find function.

## Behavioral Requirements

- **must-render-entry-as-details-summary**: Each entry in the entries array MUST render as a `<details>` element wrapping a `<summary>` containing the question and the answer in the details body.
- **must-accept-entries-array**: Component MUST accept an `entries` prop of type `FaqEntry[]`.
- **must-render-question-in-summary**: The `question` field of each FaqEntry MUST render inside a `<summary>` element as the disclosure label.
- **must-render-answer-as-content**: The `answer` field of each FaqEntry MUST render as content inside the `<details>` element, outside the `<summary>`.
- **must-support-open-prop**: Each FaqEntry's `open` field, when set to `true`, MUST cause the corresponding `<details>` element to render with the `open` attribute, starting in the expanded state.
- **must-accept-reactnode-content**: Both `question` and `answer` MUST accept any valid React `ReactNode` value, including strings, numbers, components, and fragments.
- **must-support-browser-toggle**: Users MUST be able to toggle disclosure by clicking the summary, using Enter or Space keys on keyboard focus, or tapping on mobile, with no custom event handlers required — browser-native `<details>` behavior applies.
- **must-preserve-state-when-printed**: When the page is printed, all expanded entries MUST remain open in the print layout.
- **must-be-findable**: All text in questions and answers MUST be discoverable using the browser's Find feature (Ctrl+F / Cmd+F) without JavaScript interception.

## Appearance

The component renders semantic HTML with no inline styles. Appearance is entirely controlled by external CSS via the `lp-faq` class on the root container and browser default `<details>`/`<summary>` styling:

- **Container**: A `<div>` with class `lp-faq` wraps all entries.
- **Entry structure**: Each entry is a native `<details>` element.
- **Summary styling**: Browser default — typically bold text, with a disclosure triangle before the text. Exact appearance (icon shape, animation, colors) depends on the stylesheet.
- **Details content**: Rendered as block content within the details element. Browser default includes margin/padding between summary and content.
- **Visual state indicators**: The browser provides a visual indicator (disclosure triangle rotation or similar) when the details element is open vs. closed.

## States

| State | Behavior |
|-------|----------|
| Closed | Summary visible; answer hidden. Disclosure triangle/icon points right (or icon is neutral). Clicking or pressing Enter/Space toggles to open. |
| Open | Summary visible; answer visible below. Disclosure triangle/icon points down. Clicking or pressing Enter/Space toggles to closed. |
| Focused (keyboard) | When summary receives keyboard focus (via Tab), the summary element shows focus indicator (browser or CSS-defined). |

The component does not manage state internally — all state changes are handled by the browser's native `<details>` element.

## Accessibility

- **Semantic role**: The native `<details>` and `<summary>` elements carry their standard ARIA semantics. Screen readers announce the summary as a disclosure button with expanded/collapsed state.
- **Keyboard navigation**: Tab navigation moves focus between summaries. Enter and Space toggle the open state. Arrow keys are not required (disclosure is a button, not a tree widget).
- **Screen reader announcement**: Screen readers announce the summary text and whether the disclosure is expanded or collapsed. The answer content is announced when the disclosure is expanded.
- **Label requirement**: Each summary MUST contain meaningful text that describes the question or topic (the `question` prop). This label is read by screen readers and serves as the button label.
- **No custom ARIA required**: The `<details>` and `<summary>` elements provide `role=button` and `aria-expanded` semantics automatically; no custom ARIA markup is needed.
- **Focus visibility**: The browser provides a focus indicator on the summary when navigated via keyboard. CSS may customize this via standard focus-visible styling.
- **Minimum touch target**: Not specified in source. Per [WCAG 2.5.5](https://www.w3.org/WAI/WCAG21/Understanding/target-size), the summary click target SHOULD be at least 44×44 CSS pixels; this is the responsibility of the consuming stylesheet.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| faq-001 | must-render-entry-as-details-summary, must-render-question-in-summary, must-render-answer-as-content | entries = `[{ question: "Q1", answer: "A1" }]` | HTML output contains one `<details>` with one `<summary>` containing "Q1" and one text node "A1" as child of details (not summary). |
| faq-002 | must-accept-entries-array | entries = `[]` | Component renders without error; output is `<div class="lp-faq"></div>` (no child details elements). |
| faq-003 | must-support-open-prop | entries = `[{ question: "Q1", answer: "A1", open: true }, { question: "Q2", answer: "A2", open: false }]` | First details element renders with `open` attribute; second does not. |
| faq-004 | must-accept-reactnode-content | entries = `[{ question: <h3>Question</h3>, answer: <p>Answer text</p> }]` | Summary contains the h3; details body contains the p element. Both render without type errors. |
| faq-005 | must-support-browser-toggle | Rendered FAQ with two entries, first closed. User clicks summary of first entry. | HTML details element's `open` attribute is added or toggled by browser; answer becomes visible. |
| faq-006 | must-preserve-state-when-printed | Rendered page with one open, one closed entry. User opens print dialog and prints. | Print preview shows all open entries expanded; browser does not collapse them during print layout. |
| faq-007 | must-be-findable | Rendered FAQ with entry question "What is this?" and answer "It is a FAQ." User presses Ctrl+F and searches for "What is". | Browser Find feature highlights the text in the summary without JavaScript intervention. |

## Edge Cases

- **Empty entries array**: Component MUST render without error. Output is a single `<div class="lp-faq"></div>` with no children.
- **Null or undefined entries**: Not applicable. The prop type is `FaqEntry[]`; null/undefined assignment is a type violation, not a runtime edge case the component handles.
- **Null or undefined question/answer**: React will render `null` or `undefined` as nothing (empty space). If this is undesirable, the caller MUST validate entries before passing to the component.
- **Very long question or answer**: No constraint in source. Content renders as-is; CSS is responsible for text wrapping and overflow handling.
- **Special characters or HTML in question/answer**: Behavior depends on the input type. If `question` is a string, HTML characters are rendered as text (safe). If `question` is a component containing HTML, that HTML renders as intended. No HTML sanitization is performed by the component.
- **Multiple entries with open: true**: All MUST start expanded. Browser allows multiple `<details>` elements to be open simultaneously (unlike a traditional single-open accordion); behavior matches the source design.
- **Key collisions**: Entries are keyed by array index (`key={i}` in the source). If the entries array is mutated (items reordered or removed), React will reuse DOM nodes by index, which may cause state mismatches. This is a known limitation of index-based keying; the component does not validate or warn about it.

## Configuration

Not applicable. The component accepts only the `entries` prop; no configuration options are exposed.

## Deep Linking

Not applicable. The component is an accordion UI element, not a full-page or modal view, and does not define deep-link routes or URL patterns.

## Localization

Not applicable. All text (question and answer) is provided by the caller via the `entries` prop. The component does not render any fixed text strings. Localization is the caller's responsibility.

## Accessibility Options

The component responds to all standard browser and system accessibility settings:

| Option | Behavior |
|--------|----------|
| Reduce Motion | If the user's OS setting prefers reduced motion, the browser's default `<details>` animation (if any) MUST honor the `prefers-reduced-motion` media query. CSS styling using `prefers-reduced-motion` will disable or simplify the disclosure animation. |
| Increase Contrast | The browser's default `<details>` and `<summary>` styling respects the system contrast setting. High-contrast CSS MUST ensure the disclosure button text, background, and focus indicator meet WCAG AA or AAA contrast ratios. |
| Differentiate Without Color | Disclosure state MUST NOT be indicated by color alone. The browser's default triangle or icon indicator provides a shape change; custom CSS styling MUST preserve a non-color differentiator (icon change, text decoration, etc.). |

## Feature Flags

Not applicable. The component does not reference or check any feature flags in the source code.

## Analytics

Not applicable. The component does not emit or listen for analytics events. Analytics instrumentation is the caller's responsibility.

## Privacy

Not applicable. The component does not collect, store, or transmit any user data.

## Logging

Not applicable. The component does not emit any log messages.

## Platform Notes

- **React/Web**: Implemented in `packages/web/packages/landing/src/blocks/Faq.tsx`. Exports a functional component accepting `{ entries: FaqEntry[] }` where `FaqEntry` has `question`, `answer`, and optional `open` fields. Renders entries as native HTML `<details>` and `<summary>` elements wrapped in a `<div class="lp-faq">` container. All state management is delegated to the browser's native disclosure behavior; no React state or event handlers are used for toggle logic.

- **SwiftUI**: Implement using SwiftUI's native `DisclosureGroup` or a custom disclosure wrapper. Each entry becomes a `DisclosureGroup` with the question as the label and the answer as the content. The `isExpanded` binding corresponds to the source's `open` prop. For the equivalent of persistent expansion across app restarts, store the expanded state in `@AppStorage` or similar. SwiftUI does not have native print preservation like HTML, so ensure print templates (if needed) read the current expanded state from the view model.

- **Compose**: Implement using Material Design 3's `OutlinedButton` or a custom collapsible card layout. Each entry is a composable that manages its own expanded state via `mutableStateOf`. Use `AnimatedVisibility` to show/hide the answer content. To replicate print behavior, ensure the Composable reads state from the view model and any PDF export logic preserves the view's current expanded state when generating a print view.

- **AppKit / UIKit**: Implement using `NSOutlineView` (macOS) or a `UITableView` with custom `UITableViewCell` disclosure indicators (iOS). Alternatively, build a custom disclosure view using `NSButton` + `NSStackView` (macOS) or `UIButton` + `UIStackView` (iOS). The `open` prop maps to the selected/expanded row state. Keyboard navigation (Tab, Enter/Space) and VoiceOver support are available through standard table/view accessibility; ensure the disclosure button has a clear `accessibilityLabel` describing the question and `accessibilityHint` indicating it expands/collapses the answer.

- **WinUI 3**: Implement using `Expander` control in the XAML library or a custom ItemsControl with individual `Expander` elements for each question-answer pair. Bind the `Expander.IsExpanded` property to a boolean in the data model (equivalent to the `open` prop). The `Header` property displays the question; the `Content` property displays the answer. Keyboard support (Enter/Space to toggle focus) and narrator screen reader support are provided by the native `Expander` control. To ensure expanded state persists across sessions (if needed), serialize the expanded state to local storage or app settings and restore it on load.

## Design Decisions

- **Native HTML over scripted accordion**: The source uses HTML `<details>` and `<summary>` elements rather than a custom JavaScript accordion component. This design choice eliminates the need for stateful JavaScript logic, reduces bundle size, ensures the component works without client-side rendering, and leverages the browser's built-in accessibility and print handling. Trade-off: the animation and visual styling are browser-default and less customizable than a fully scripted accordion; customization is achieved through CSS.

- **Index-based keying**: The source uses array index as the React key (`key={i}`). This is acceptable for static or rarely-reordered lists but can cause issues if the entries array is mutated (items added, removed, or reordered). The source does not validate or guard against this; it is the caller's responsibility to provide stable data or use unique identifiers (e.g., id fields) in a revised component signature.

- **Optional `open` prop with single-entry default**: The `open` prop is optional and defaults to `false`. The comment in the source notes that "normally exactly one entry carries this" — the UX pattern is to show one answer by default rather than showing all answers closed (which reads as a list of links rather than an FAQ section). This is a design preference and is documented but not enforced by the component; the caller controls which entries are open.

- **No custom event handlers**: The component does not define `onClick`, `onChange`, or other custom handlers. All interactivity is delegated to the browser's native `<details>` implementation. This ensures the component works without JavaScript and respects browser behaviors like print preservation and Find searchability. Callers who need to react to disclosure state changes (e.g., to log an analytics event) must add a wrapper or custom hook outside this component.

## Compliance

Not applicable. The source code does not reference or implement any formal compliance checks.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from web source |
