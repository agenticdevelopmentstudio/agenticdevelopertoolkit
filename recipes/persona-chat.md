---
id: 447d0e33-c66e-4bf9-8511-e7823bdbcf9b
title: Persona Chat
domain: agenticdevelopercookbook://ingredients/persona-chat
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Mode-based routing container that renders inline, three-pane, or mobile chat
  interfaces with a persona participant and optional user participant.
platforms:
- typescript
- web
tags:
- chat
- messaging
- persona
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Persona Chat

## Overview

PersonaChat is a routing container component that dispatches to one of three chat interface modes based on the `mode` prop: `inline` (embedded chat box with adaptive sizing), `three-pane` (side-by-side conversation and details), or `mobile` (full-screen overlay). It manages communication with a chat backend, displays a persona participant, optionally includes a user participant, and renders an optional welcome message. The component is the entry point for integrating different chat UI layouts into applications.

## Behavioral Requirements

- **must-accept-mode-prop**: Component MUST accept a `mode` prop with value `'inline'`, `'three-pane'`, or `'mobile'`.
- **must-route-by-mode**: Component MUST render `InlineChat` when `mode` is `'inline'`, `ThreePaneChat` when `mode` is `'three-pane'`, and `MobileChat` when `mode` is `'mobile'`.
- **must-accept-backend**: Component MUST accept and forward a `backend` prop (type `ChatBackend`) to the rendered chat layout.
- **must-accept-persona**: Component MUST accept and forward a `persona` prop (type `ChatParticipant`) to the rendered chat layout.
- **should-accept-user**: Component SHOULD accept an optional `user` prop (type `ChatParticipant`) and forward it to the rendered chat layout when provided.
- **should-accept-welcome-message**: Component SHOULD accept an optional `welcomeMessage` prop (type `string`) and forward it to the rendered chat layout when provided.
- **should-accept-class-name**: Component SHOULD accept an optional `className` prop (type `string`) and forward it to the rendered chat layout for custom styling.
- **should-accept-sizing-inline**: Component SHOULD accept an optional `sizing` prop (type `InlineChatSizing`) for `inline` mode, forwarding it only when `mode` is `'inline'`, controlling active/inactive sizing behavior and transitions.
- **should-handle-mobile-open**: Component SHOULD accept an optional `open` prop (type `boolean`, default `false`) for `mobile` mode, forwarding it to control overlay visibility.
- **should-handle-mobile-close**: Component SHOULD accept an optional `onClose` callback (type `() => void`, default no-op) for `mobile` mode, forwarding it to handle overlay dismissal.

## Appearance

Not applicable: PersonaChat is a routing component without direct visual presentation; appearance is delegated entirely to the selected layout component (`InlineChat`, `ThreePaneChat`, or `MobileChat`).

## States

Not applicable: PersonaChat does not define or manage visual or interactive states; state management belongs to the routed layout components.

## Accessibility

Not applicable: PersonaChat has no interactive elements or labels of its own; accessibility concerns are the responsibility of the routed child components.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|----|----|----|
| persona-chat-001 | must-route-by-mode | `mode='inline'`, backend, persona | Renders `InlineChat` component |
| persona-chat-002 | must-route-by-mode | `mode='three-pane'`, backend, persona | Renders `ThreePaneChat` component |
| persona-chat-003 | must-route-by-mode | `mode='mobile'`, backend, persona | Renders `MobileChat` component |
| persona-chat-004 | must-accept-backend | backend prop provided | Backend forwarded to child component |
| persona-chat-005 | must-accept-persona | persona prop provided | Persona forwarded to child component |
| persona-chat-006 | should-accept-user | user prop provided | User forwarded to child component |
| persona-chat-007 | should-accept-user | user prop omitted | Child component receives undefined user |
| persona-chat-008 | should-accept-welcome-message | welcomeMessage prop provided | Welcome message forwarded to child component |
| persona-chat-009 | should-accept-welcome-message | welcomeMessage prop omitted | Child component receives undefined welcomeMessage |
| persona-chat-010 | should-accept-class-name | className prop provided | className forwarded to child component |
| persona-chat-011 | should-accept-sizing-inline | `mode='inline'`, sizing prop provided | sizing forwarded to InlineChat component |
| persona-chat-012 | should-accept-sizing-inline | `mode='three-pane'`, sizing prop provided | sizing prop ignored; not forwarded to ThreePaneChat |
| persona-chat-013 | should-handle-mobile-open | `mode='mobile'`, open={true} | open={true} forwarded to MobileChat |
| persona-chat-014 | should-handle-mobile-open | `mode='mobile'`, open prop omitted | open={false} forwarded to MobileChat (default) |
| persona-chat-015 | should-handle-mobile-close | `mode='mobile'`, onClose callback provided | onClose forwarded to MobileChat component |
| persona-chat-016 | should-handle-mobile-close | `mode='mobile'`, onClose prop omitted | Default no-op callback forwarded to MobileChat |

## Edge Cases

- **Invalid mode**: If `mode` is a value other than `'inline'`, `'three-pane'`, or `'mobile'`, the component does not match any case in the switch statement and renders nothing. MUST return null or undefined for unknown modes without error.
- **Missing required props**: If `backend` or `persona` are not provided, the component forwards undefined to the child component, which is responsible for handling or signaling the error. PersonaChat MUST NOT validate these props itself.
- **Null/undefined participants**: If `user` is explicitly null or undefined, the component forwards it as-is to the child component, which determines whether this is acceptable.
- **Sizing prop on non-inline modes**: When `mode` is `'three-pane'` or `'mobile'` and `sizing` is provided, PersonaChat MUST NOT forward the `sizing` prop; the child component does not accept it.
- **onClose on non-mobile modes**: When `mode` is not `'mobile'` and `onClose` is provided, PersonaChat MUST NOT forward it; the child component does not accept it. The callback is silently dropped.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `mode` | `'inline' \| 'three-pane' \| 'mobile'` | (required) | Determines which chat layout to render |
| `backend` | `ChatBackend` | (required) | Chat backend implementation for message exchange |
| `persona` | `ChatParticipant` | (required) | The persona (non-user) participant in the chat |
| `user` | `ChatParticipant` | undefined | Optional user participant; if omitted, only persona is displayed |
| `welcomeMessage` | `string` | undefined | Optional greeting message displayed on chat initialization |
| `className` | `string` | undefined | Optional CSS class name applied to the rendered layout component |
| `sizing` | `InlineChatSizing` | undefined | Inline mode only; configures active/inactive sizing and transitions |
| `open` | `boolean` | `false` | Mobile mode only; controls whether the overlay is visible |
| `onClose` | `() => void` | `() => {}` | Mobile mode only; callback when user dismisses the overlay |

## Deep Linking

Not applicable: PersonaChat does not define deep linking behavior; routing and deep link handling are delegated to the containing application and the selected layout component.

## Localization

Not applicable: PersonaChat contains no user-facing strings of its own; localization is the responsibility of the child layout components and the `welcomeMessage` prop passed by the caller.

## Accessibility Options

Not applicable: PersonaChat has no interactive elements that respond to accessibility display options; accessibility concerns (Reduce Motion, Increase Contrast, etc.) are delegated to child layout components.

## Feature Flags

Not applicable: The source code contains no feature flag logic; mode selection is controlled by the caller and can be made conditional by wrapper logic.

## Analytics

Not applicable: PersonaChat does not emit analytics events directly; event tracking is the responsibility of the selected layout component (`InlineChat`, `ThreePaneChat`, or `MobileChat`).

## Privacy

Not applicable: PersonaChat handles no data collection, storage, or transmission directly; privacy concerns are delegated to the backend implementation and child layout components.

## Logging

Not applicable: The source code contains no logging; debugging and diagnostic output are the responsibility of the backend implementation and child layout components.

## Platform Notes

- **Web**: `PersonaChat.tsx` is a React component in `packages/web/packages/chat/src/modes/` that uses a switch statement to dispatch to one of three layout components. Props are passed conditionally based on mode; `sizing` and `onClose` are mode-specific.
- **SwiftUI**: Implement a mode-scoped container using `@State` to track the active mode and `@ViewBuilder` to dispatch between three distinct chat UI compositions. Use `@Environment` or a custom environment key for the backend and persona.
- **Compose**: Implement as a composable function using `when` to branch on `mode`, passing `backend` and `persona` through `CompositionLocal` or function parameters to the selected layout composable.
- **AppKit / UIKit**: Implement as a view controller or view container that holds a reference to one of three child view controller/view pairs based on mode, managing prop forwarding in `viewDidLoad` or `init`.
- **WinUI 3**: Implement as a XAML UserControl with a `Mode` dependency property (`enum` with `Inline`, `ThrePane`, `Mobile` values) and content presenter that changes `Content` via `{x:Bind Mode, Converter=ModeToViewConverter}`. Use attached properties or a behavior to forward `Backend`, `Persona`, and mode-specific props to the selected view.

## Design Decisions

The component uses a simple switch statement to dispatch to child layout components rather than a polymorphic factory pattern. This design is appropriate because:

1. The three modes represent fundamentally different UI layouts (embedded box, side-by-side panes, full-screen overlay), not interchangeable implementations of the same interface.
2. Each mode has distinct prop requirements (`sizing` for inline, `open`/`onClose` for mobile), making a unified prop interface unwieldy.
3. The component remains thin and transparent, with no business logic beyond routing; it is a presentation-level router, not a behavioral container.

Mode selection is caller-determined, allowing parent components to choose layout based on viewport, user preference, device type, or application state. PersonaChat does not enforce mode validity; an invalid mode renders nothing, which signals a configuration error to the developer without throwing or logging.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| Prop forwarding | passed | Source Fidelity |
| Mode routing | passed | Behavioral Requirements |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation |
