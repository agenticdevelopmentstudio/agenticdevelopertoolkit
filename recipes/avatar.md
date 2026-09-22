---
id: e3a2394d-d0d0-4495-bde4-59197f9d7866
title: Avatar
domain: agenticdevelopercookbook://ingredients/avatar
type: ingredient
version: 1.1.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Thin wrapper around Base UI's Avatar primitive (Root/Image/Fallback) exposing
  stable adh-avatar* classes as a public theming surface.
platforms:
- typescript
- web
tags:
- component
- avatar
- ui
depends-on: []
related: []
references: []
---

# Avatar

## Overview

`Avatar` is the shared avatar ingredient in `@agenticdevelopertoolkit/ui`: a thin,
three-part wrapper around Base UI's `Avatar` primitive (`@base-ui/react/avatar`).
It exports `Avatar` (wraps `Avatar.Root`), `AvatarImage` (wraps `Avatar.Image`),
and `AvatarFallback` (wraps `Avatar.Fallback`). Each wrapper's only job is to
apply one of the semantic classes `adh-avatar`, `adh-avatar__image`, or
`adh-avatar__fallback` (merged with any consumer-supplied `className`) and
forward every other prop unchanged to the underlying Base UI primitive. The
module is a client component (`'use client'`). Per the in-source comment, the
semantic class names are a public theming surface — stable DOM hooks consumed
by the theme editor and user CSS themes — skinned externally in
`../styles/components.css`.

## Behavioral Requirements

- **must-render-root-with-semantic-class**: `Avatar` MUST render Base UI's `Avatar.Root` (`AvatarPrimitive.Root`) with the class name `adh-avatar` applied.
- **must-render-image-with-semantic-class**: `AvatarImage` MUST render Base UI's `Avatar.Image` (`AvatarPrimitive.Image`) with the class name `adh-avatar__image` applied.
- **must-render-fallback-with-semantic-class**: `AvatarFallback` MUST render Base UI's `Avatar.Fallback` (`AvatarPrimitive.Fallback`) with the class name `adh-avatar__fallback` applied.
- **must-merge-consumer-classname**: Each of `Avatar`, `AvatarImage`, and `AvatarFallback` MUST merge a consumer-supplied `className` prop with its own semantic class name (via the `cn` helper imported from `../lib/utils`) rather than dropping either class.
- **must-forward-unrecognized-props**: Each of `Avatar`, `AvatarImage`, and `AvatarFallback` MUST forward every prop other than `className` unchanged to its underlying Base UI primitive.
- **must-load-as-client-module**: The module MUST be marked `'use client'`, so `Avatar`, `AvatarImage`, and `AvatarFallback` render as client components.
- **must-preserve-semantic-class-name-contract**: The exported components MUST keep the exact class names `adh-avatar`, `adh-avatar__image`, and `adh-avatar__fallback`, because the in-source comment documents them as a public theming surface consumed by the theme editor and by user CSS themes.

## Appearance

Not applicable: Component applies only semantic class names; styling values are defined externally in `../styles/components.css` and are outside this wrapper's scope.

## States

Not applicable: Component is a stateless rendering wrapper; interactive state management is delegated to Base UI's Avatar primitives.

## Accessibility

Not applicable: Component is a thin wrapper that delegates all accessibility implementation to Base UI's Avatar primitives.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| avatar-001 | must-render-root-with-semantic-class | Render `<Avatar />` with no props | Rendered root element has class `adh-avatar` |
| avatar-002 | must-render-image-with-semantic-class | Render `<AvatarImage />` with no props | Rendered image element has class `adh-avatar__image` |
| avatar-003 | must-render-fallback-with-semantic-class | Render `<AvatarFallback />` with no props | Rendered fallback element has class `adh-avatar__fallback` |
| avatar-004 | must-merge-consumer-classname | Render `<Avatar className="ring-2" />` | Rendered root element has both `adh-avatar` and `ring-2` classes |
| avatar-005 | must-merge-consumer-classname | Render `<AvatarImage className="opacity-0" />` | Rendered image element has both `adh-avatar__image` and `opacity-0` classes |
| avatar-006 | must-merge-consumer-classname | Render `<AvatarFallback className="bg-muted" />` | Rendered fallback element has both `adh-avatar__fallback` and `bg-muted` classes |
| avatar-007 | must-forward-unrecognized-props | Render `<Avatar data-testid="a1" />` | Rendered root element carries `data-testid="a1"` |
| avatar-008 | must-forward-unrecognized-props | Render `<AvatarImage alt="Ada Lovelace" />` | Rendered image element carries `alt="Ada Lovelace"` |
| avatar-009 | must-load-as-client-module | Inspect the compiled module boundary for `avatar.tsx` | Module is flagged as a Client Component (carries the `'use client'` directive) |
| avatar-010 | must-preserve-semantic-class-name-contract | Search `avatar.tsx` for the three class names | `adh-avatar`, `adh-avatar__image`, and `adh-avatar__fallback` are all present verbatim |

## Edge Cases

- **Null/empty `className`** (MUST): When `className` is omitted (`undefined`), `Avatar`, `AvatarImage`, and `AvatarFallback` still render, passing `undefined` as the second argument to `cn`; the wrapper performs no validation of `className` before doing so.
- **No other props supplied** (MUST): Because `{...props}` is spread unconditionally, calling any of the three components with no props beyond (or including) `className` is valid; the wrapper performs no required-prop checking of its own.
- **Boundary values**: Not applicable: Component defines no numeric, length, or size-constrained props of its own (e.g. no `size`, `min`, `max`); any such constraints belong to the underlying Base UI `Avatar.Root`/`Image`/`Fallback` API.
- **Concurrent access**: Not applicable: `Avatar`, `AvatarImage`, and `AvatarFallback` are stateless functional components with no internal state, refs, or module-level mutable data; each render is an independent, pure function call.
- **Error states** (MUST): The wrapper passes image load-failure handling to Base UI's Avatar. When an image fails to load, Base UI's `Avatar.Image` resets and reveals the `AvatarFallback` content; refer to `@base-ui/react/avatar` for the complete fallback-reveal behavior.
- **Offline or disconnected state** (MUST): The wrapper passes network-failure handling to Base UI's Avatar. When the network is unavailable, `AvatarImage` inherits Base UI's retry, timeout, and error-state behavior; refer to `@base-ui/react/avatar` for implementation details.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `className` (on `Avatar`) | `string \| undefined` | `undefined` | Extra class merged with `adh-avatar` via `cn`. |
| `className` (on `AvatarImage`) | `string \| undefined` | `undefined` | Extra class merged with `adh-avatar__image` via `cn`. |
| `className` (on `AvatarFallback`) | `string \| undefined` | `undefined` | Extra class merged with `adh-avatar__fallback` via `cn`. |
| `...props` (on `Avatar`) | `AvatarPrimitive.Root.Props`, minus `className` | — | Forwarded unchanged to Base UI's `Avatar.Root`. |
| `...props` (on `AvatarImage`) | `AvatarPrimitive.Image.Props`, minus `className` | — | Forwarded unchanged to Base UI's `Avatar.Image`. |
| `...props` (on `AvatarFallback`) | `AvatarPrimitive.Fallback.Props`, minus `className` | — | Forwarded unchanged to Base UI's `Avatar.Fallback`. |

The wrapper forwards all other props to the underlying Base UI primitives. Refer to `@base-ui/react/avatar` for the complete property list and platform-specific behavior of `Avatar.Root.Props`, `Avatar.Image.Props`, and `Avatar.Fallback.Props`.

## Deep Linking

Not applicable: Component has no URL routing or deep linking logic.

## Localization

Not applicable: Component has no user-facing strings or localization concerns.

## Accessibility Options

Not applicable: Component does not respond to platform accessibility display options.

## Feature Flags

Not applicable: Component has no feature flag logic.

## Analytics

Not applicable: Component performs no analytics tracking.

## Privacy

- **Data collected**: None. `Avatar`, `AvatarImage`, and `AvatarFallback` perform no data collection of their own; they render whatever `src`/`children`/props a consumer supplies.
- **Storage**: None. This file contains no persistence logic.
- **Transmission**: Not applicable: Component has no transmission logic; any network requests for image loading are delegated to Base UI's `Avatar.Image` implementation.
- **Retention**: None. This file has no caching or retention logic of its own.

## Logging

Not applicable: Component performs no logging.

## Platform Notes

- **SwiftUI**: Start with `Image` and `Text` views in a container (e.g., `ZStack` or `Group`). SwiftUI has no built-in Avatar primitive, so composition is manual. Differs from web in requiring explicit state logic to toggle image visibility when loading or on error; web Avatar delegates this to Base UI's fallback reveal.
- **Compose**: Start with Coil's `AsyncImage` or standard `Image` composable for the image and a `Text` composable for fallback initials. Kotlin/Jetpack Compose has no built-in Avatar primitive, so composition is manual. Differs from web in requiring explicit error handling and fallback reveal within the composable; web delegates this to Base UI.
- **React/Web**: `Avatar`, `AvatarImage`, and `AvatarFallback` (`packages/web/packages/ui/src/components/avatar.tsx`) wrap Base UI's `Avatar.Root`, `Avatar.Image`, and `Avatar.Fallback` (`@base-ui/react/avatar`), applying the semantic classes `adh-avatar`, `adh-avatar__image`, and `adh-avatar__fallback` (skinned in `../styles/components.css`, per the in-source comment) merged with any consumer `className`, and forwarding all other props. The module is a client component (`'use client'`).
- **AppKit / UIKit**: Start with `NSImageView` (macOS) or `UIImageView` (iOS) for the image and `NSTextField`/`UILabel` or button for fallback initials. AppKit/UIKit have no built-in Avatar primitive, so composition is manual. Differs from web in requiring explicit visibility toggling and layout constraints; web Avatar delegates image-with-fallback reveal to Base UI.
- **WinUI 3**: A Windows developer would start from `Microsoft.UI.Xaml.Controls.PersonPicture`, the built-in WinUI 3 avatar control, since it natively provides the same image-with-initials-fallback contract that `Avatar`/`AvatarImage`/`AvatarFallback` compose from three separate Base UI primitives. The key difference: `PersonPicture` bakes the image/fallback decision into one control (via its `ProfilePicture`, `Initials`, and `DisplayName` properties) rather than exposing three independently composable Root/Image/Fallback pieces, so it cannot be skinned through three discrete semantic classes the way `adh-avatar`/`adh-avatar__image`/`adh-avatar__fallback` are; matching this recipe's exact three-part composition on Windows instead requires a custom control built from an `Image` plus a `TextBlock` inside a `Border`/`Grid`, since WinUI 3 has no direct Root/Image/Fallback primitive split.

## Design Decisions

- **Class names as a public theming surface.** The in-source comment states the `adh-avatar*` classes are "a public theming surface for the theme editor and user CSS themes," so they must stay stable rather than being treated as ordinary, freely-renameable implementation classes. This is why `must-preserve-semantic-class-name-contract` is written as a MUST: renaming any of the three classes is a breaking change for every theme built against them, not a local refactor.
- **Thin wrapper by design; behavior lives in Base UI.** `Avatar`, `AvatarImage`, and `AvatarFallback` add no logic beyond class assignment and prop forwarding. Loading/error/fallback-reveal behavior, ARIA semantics, and any interactive states are entirely owned by `@base-ui/react/avatar`, which is delegated to deliberately to keep this wrapper stateless and composable.

## Compliance

Not applicable: Compliance audits (contrast, touch target sizing, class-name stability) are performed against the compiled component and stylesheet context, not expressed in component source code.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.1.0 | 2026-09-22 | Mike Fullerton | Revise Phase 1: replace library-delegation markers with plain statements; update status to review |
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
