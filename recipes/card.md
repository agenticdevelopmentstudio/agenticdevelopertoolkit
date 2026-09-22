---
id: ea565474-df7a-42bd-9613-5dd0cd861911
title: Card
domain: agenticdevelopercookbook://ingredients/card
type: ingredient
version: 1.1.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A bordered content container; two divergent web implementations exist — a
  fixed kicker/title/children block and a composable slot-based family.
platforms:
- typescript
- web
tags:
- component
- card
- container
- ui
depends-on: []
related: []
references:
- agenticdevelopercookbook://guidelines/cookbook/ui/platform-design-languages
approved-by: ''
approved-date: ''
---

# Card

## Overview

`Card` groups related content inside a single visually-bounded container. Two independent web implementations exist in the given sources, and they are structurally different rather than variants of one shared component:

- **Landing Card** (`packages/web/packages/landing/src/blocks/Card.tsx`) is a fixed-shape tile for a `Cards` grid: an optional small `kicker` label, a required `<h3>` title, and required `children` content, all inside one `<div className="lp-card">`.
- **UI Card family** (`packages/web/packages/ui/src/components/card.tsx`) is a compound, slot-based family of six independently composable components (`Card`, `CardHeader`, `CardTitle`, `CardDescription`, `CardContent`, `CardFooter`), each a styled `<div>` that forwards `className` and other props. Unlike the Landing Card, the UI `Card` itself imposes no required child structure — callers assemble whichever slots they need.

This recipe documents both under the single `card` ingredient name because both sources use the exported name `Card`, but implementors MUST treat them as two distinct implementations, not as configuration options of one component (see Design Decisions).

## Behavioral Requirements

Landing Card (`packages/web/packages/landing/src/blocks/Card.tsx`):

- **must-render-container-div**: Landing Card MUST render its content inside a single `<div className="lp-card">` element.
- **must-render-title-heading**: Landing Card MUST render the `title` prop inside an `<h3>` element.
- **must-render-children-after-title**: Landing Card MUST render `children` content within the container, after the title.
- **must-omit-kicker-when-undefined**: Landing Card MUST NOT render a kicker element when the `kicker` prop is `undefined`.
- **may-render-kicker-label**: Landing Card MAY render a `kicker` label, inside a `<span className="lp-card__kicker">`, positioned before the title, when `kicker` is provided (not `undefined`).
- **must-require-title-and-children-props**: Landing Card MUST require callers to supply `title` and `children` — both are non-optional in the component's type signature; only `kicker` is optional.

UI Card family (`packages/web/packages/ui/src/components/card.tsx`):

- **must-export-six-slot-components**: The UI Card family MUST export exactly six components: `Card`, `CardHeader`, `CardTitle`, `CardDescription`, `CardContent`, `CardFooter`.
- **must-render-div-root**: Each of the six UI Card family components MUST render a `div` as its root element.
- **must-set-data-slot-attribute**: Each of the six UI Card family components MUST set a `data-slot` attribute on its root element identifying its role (`card`, `card-header`, `card-title`, `card-description`, `card-content`, `card-footer`, respectively).
- **must-merge-classname-prop**: Each of the six UI Card family components MUST merge a caller-supplied `className` prop with its own default class list via the `cn` utility, rather than discarding either.
- **must-forward-rest-props**: Each of the six UI Card family components MUST spread all other received props onto its rendered root `div` element.
- **may-compose-any-slot-subset**: Consumers MAY include any subset and ordering of `CardHeader`, `CardTitle`, `CardDescription`, `CardContent`, and `CardFooter` inside `Card`, since `Card` itself renders only the props (including `children`) it receives, without requiring any specific slot structure.

## Appearance

Both implementations express appearance by class name rather than by literal value, and the class name is the requirement. The UI Card family names Tailwind utilities and `apt-*` design tokens inline; the Landing Card sets no inline styling at all — its entire appearance is carried by the external `lp-card` and `lp-card__kicker` CSS classes, so those class names are its complete appearance contract.

- **Corner radius**:
  - UI Card family: the `Card` root MUST use the `rounded-xl` Tailwind utility; no sub-slot sets its own corner radius.
  - Landing Card: no radius is set in the component; the `lp-card` class carries it. An implementation MUST apply `lp-card` to the container to obtain it.
- **Padding**:
  - UI Card family: the `Card` root MUST use vertical padding `py-6` and sets no horizontal padding of its own; `CardHeader`, `CardContent`, and `CardFooter` MUST each add horizontal padding `px-6`. `Card` MUST use `gap-6` between its top-level children and `CardHeader` MUST use `gap-1.5` between its own children.
  - Landing Card: no padding is set in the component; the `lp-card` class carries the container padding, and `lp-card__kicker` carries any spacing around the kicker label.
- **Font**:
  - UI Card family: `CardTitle` MUST use `font-semibold` with `leading-none`; `CardDescription` MUST use `text-sm`. `Card`, `CardHeader`, `CardContent`, and `CardFooter` set no font utility and inherit from their ancestor. No literal point size appears in the source; the Tailwind scale step is the specification.
  - Landing Card: the title renders inside an `<h3>` and therefore takes the document's `h3` typography; the kicker takes its type from the `lp-card__kicker` class. The component sets no font utility or inline style.
- **Background**:
  - UI Card family: the `Card` root MUST use the `bg-apt-bg` token; no sub-slot sets a background.
  - Landing Card: no background is set in the component; the `lp-card` class carries it.
- **Foreground/Text**:
  - UI Card family: `Card` and `CardTitle` MUST use the `text-apt-text` token; `CardDescription` MUST use `text-apt-text-muted`. `CardHeader`, `CardContent`, and `CardFooter` set no text color and inherit `text-apt-text` from the `Card` root.
  - Landing Card: no text color is set in the component; the `lp-card` and `lp-card__kicker` classes carry it.
- **Border**:
  - UI Card family: the `Card` root MUST use `border` (the Tailwind default 1px width) with the `border-apt-border` color token; no sub-slot has its own border.
  - Landing Card: no border is set in the component; the `lp-card` class carries any border.
- **Shadow**:
  - UI Card family: the `Card` root MUST use `shadow-sm`; no sub-slot has its own shadow.
  - Landing Card: no shadow is set in the component; the `lp-card` class carries any shadow.
- **Min/Max size**: Neither implementation constrains width or height. The UI `Card` sets no sizing utility, so it fills the inline size its parent gives it and sizes to its content in the block direction; the Landing Card takes its size from the `lp-card` class and from the `Cards` grid track it occupies.

## States

Not applicable: Card is a static, non-interactive container and does not define any interactive states beyond the default render state.

| State | Appearance change |
|-------|------------------|
| Default | — |

## Accessibility

- **Role/trait**: Neither source sets an explicit ARIA `role`. Both render a plain `<div>` (`<div className="lp-card">` in Landing Card; `<div data-slot="card" ...>` in the UI Card family), which carries no implicit interactive role — it is a generic, non-interactive container.
- **Label requirements**: Landing Card renders its `title` prop into a visible `<h3>`, so a card built from it is reachable through heading navigation. The UI Card family's `CardTitle` renders a plain `<div data-slot="card-title">` with no heading semantics, and neither source sets `aria-labelledby`, `aria-label`, or a grouping role on the container. NEEDS REVIEW: what is missing is a decision on whether a titled content container built from the UI Card family must expose its title as a heading or as the accessible name of a labelled group — the source cannot settle this, because the family deliberately leaves element semantics to the caller. Evidence that would settle it: a WCAG 2.1 AA audit of a rendered page using the family against SC 1.3.1 (Info and Relationships) and SC 2.4.6 (Headings and Labels), plus confirmation from the design owner of which slot is intended to carry the accessible name.
- **Announce state changes**: Not applicable: Card has no interactive states to announce.
- **Minimum tap target**: Not applicable: Card is not an interactive element in either source — no `onClick`/`onPress` handler exists.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| card-001 | must-render-container-div | `<Card title="T">child</Card>` (Landing Card) | Output contains a `<div>` with class `lp-card` wrapping the title and children. |
| card-002 | must-render-title-heading | `title="Hello"` (Landing Card) | Output contains an `<h3>` element whose text is "Hello". |
| card-003 | must-render-children-after-title | `title="T"`, `children=<p>Body</p>` (Landing Card) | Output contains `<h3>T</h3>` immediately followed by the children markup. |
| card-004 | must-omit-kicker-when-undefined | `kicker` left unset, `title="T"`, `children="C"` (Landing Card) | No element with class `lp-card__kicker` appears anywhere in the output. |
| card-005 | may-render-kicker-label | `kicker="Preview"`, `title="T"`, `children="C"` (Landing Card) | A `<span class="lp-card__kicker">Preview</span>` renders before the `<h3>`. |
| card-006 | must-require-title-and-children-props | Compile `<Card />` with no `title`/`children` (Landing Card, TypeScript) | Compilation fails, citing missing required properties `title` and `children`. |
| card-007 | must-export-six-slot-components | `import { Card, CardHeader, CardTitle, CardDescription, CardContent, CardFooter }` (UI Card family) | All six imports resolve to defined function exports. |
| card-008 | must-render-div-root | Render each of the six UI Card family components with no props | Each renders a `<div>` as its outermost node. |
| card-009 | must-set-data-slot-attribute | Render `<Card />`, `<CardHeader />`, `<CardTitle />`, `<CardDescription />`, `<CardContent />`, `<CardFooter />` | Each rendered root `div` carries its matching `data-slot` value (`card`, `card-header`, `card-title`, `card-description`, `card-content`, `card-footer`). |
| card-010 | must-merge-classname-prop | `<Card className="extra-class" />` | The rendered root `div`'s `class` attribute contains both `extra-class` and the component's default classes (e.g. `rounded-xl`). |
| card-011 | must-forward-rest-props | `<Card data-testid="x" />` | The rendered root `div` carries `data-testid="x"`. |
| card-012 | may-compose-any-slot-subset | `<Card><CardContent>Only content</CardContent></Card>` (Header/Title/Description/Footer omitted) | Renders without error, containing only the `CardContent` slot's markup. |

## Edge Cases

- **Null/empty input — Landing Card**: `title` and `children` are typed as required, non-optional `ReactNode`, and the source applies no runtime guard to either. The container `<div className="lp-card">` and the `<h3>` are unconditional in the source, so with `title={null}` or `title=""` the component MUST still render an empty `<h3>` inside the container, and with empty `children` it MUST still render the container. The only runtime guard is on the kicker, and it tests `undefined` by identity (`kicker === undefined ? null : ...`): `kicker={null}` or `kicker=""` therefore renders an empty `<span class="lp-card__kicker">` rather than omitting it, and implementations MUST reproduce that distinction between `undefined` and other empty values.
- **Null/empty input — UI Card family**: No component performs prop validation. `Card` rendered with no children renders an empty `<div>` with its default classes — nothing in source prevents an empty card. This is a MUST: the UI Card family MUST render its default-classed `<div>` regardless of whether children are supplied, per the unconditional `{...props}`/`children` spread in each component.
- **Boundary values**: Not applicable: Neither source exposes a numeric/length-constrained input (no min/max props, no character limits).
- **Concurrent access**: Not applicable: Both implementations are stateless, pure render functions with no internal state and no shared mutable resource; there is nothing to serialize.
- **Error states**: Not applicable: Card is a presentational container with no error-handling responsibility; errors would originate from child content, not the container itself.
- **Offline/disconnected state**: Not applicable: Neither source performs a network request; both are purely local rendering components.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `kicker` | `ReactNode` | `undefined` | Landing Card only. Optional label rendered above the title; the kicker element is omitted entirely when `undefined`. |
| `title` | `ReactNode` | none (required) | Landing Card only. Required content rendered inside an `<h3>`. |
| `children` | `ReactNode` | none (required) | Landing Card only. Required content rendered after the title. |
| `className` | `string` | `undefined` | UI Card family (all six components). Additional classes merged with each component's default classes via `cn`. |
| *(rest props)* | native `div` attributes | none | UI Card family (all six components). Any other native `div` attribute is forwarded to the root element via prop spreading. |

## Deep Linking

Not applicable: Card is a layout primitive, not a navigable screen or route target.

## Localization

Not applicable: neither implementation defines any built-in copy or default string. All visible text (`kicker`, `title`, `children` in Landing Card; the slot content passed into the UI Card family) is fully supplied by the caller as props/children. There is no string key defined anywhere in either source file.

## Accessibility Options

Not applicable as a behavior the component implements: neither source branches on an accessibility display option. The table records what each option therefore means for this component.

| Option | Behavior |
|--------|----------|
| Reduce Motion | No transition or animation is applied in either source; nothing to disable under Reduce Motion. |
| Increase Contrast | No high-contrast variant is defined. Contrast comes from whatever the `apt-*` tokens (UI Card family) or the `lp-card` class (Landing Card) resolve to for the active theme; the components themselves do not branch on the setting. |
| Differentiate Without Color | The card conveys no information by color: structure is carried by the border and the slot layout (UI Card family) and by the `<h3>` title and kicker label (Landing Card), so there is no color-only distinction to differentiate. |

## Feature Flags

Not applicable: Card renders unconditionally; neither source reads or gates a feature flag.

## Analytics

Not applicable: Card is a presentational container and does not emit analytics events. Event tracking, if needed, is the responsibility of content or parent components that consume the card.

## Privacy

- **Data collected**: None. Neither source file collects, stores, or transmits any data; both are purely presentational and receive all content via props/children.
- **Storage**: Not applicable — neither source contains storage code.
- **Transmission**: Not applicable — neither source performs a network request.
- **Retention**: Not applicable — no data is collected or stored.

## Logging

Not applicable: Card does not perform logging; it is a presentational component with no internal state or event lifecycle to track.

## Platform Notes

- **SwiftUI**: No native `Card` primitive exists; compose a `VStack` (`HStack` for a footer-like row) inside a container view, applying `.background()`, `.clipShape(RoundedRectangle(cornerRadius:))`, `.overlay(RoundedRectangle().stroke())`, and `.shadow()` to reproduce the UI Card family's `bg-apt-bg`/`rounded-xl`/`border-apt-border`/`shadow-sm`. Map `CardHeader`/`CardTitle`/`CardDescription`/`CardContent`/`CardFooter` to nested `VStack`/`Text` views, using `VStack(spacing:)` for the `gap-6`/`gap-1.5` rhythm and `.padding(.horizontal)`/`.padding(.vertical)` for the `px-6`/`py-6` split, since SwiftUI has no `data-slot`-style attribute mechanism. Add `.accessibilityElement(children: .contain)` with `.accessibilityLabel()` on the container and `.accessibilityAddTraits(.isHeader)` on the title to supply the group and heading semantics the web source leaves unset.
- **Compose**: Use Material 3's `androidx.compose.material3.Card` as the base container, configuring its `shape`, `colors`, `border`, and `elevation` parameters to match `rounded-xl`/`bg-apt-bg`/`border-apt-border`/`shadow-sm`; note that M3's default `Card` is filled and elevated, so an outlined, near-flat look needs `OutlinedCard` or an explicit `CardDefaults.cardElevation`. Nest `Column`/`Row` composables for the header/content/footer slots, using `Arrangement.spacedBy()` for `gap-6`/`gap-1.5` and `Modifier.padding()` for `px-6`/`py-6`. Use `Modifier.semantics(mergeDescendants = true)` plus `heading()` on the title composable to recover the semantics the source's plain `div` does not carry.
- **React/Web**: This is the source platform; implement as given — the Landing Card as a fixed `div`/`h3` structure driven by the `lp-card`/`lp-card__kicker` CSS classes, and the UI Card family as the six `cn`-composed Tailwind `div` components shown in source.
- **AppKit / UIKit**: No native card container exists. Compose an `NSView` (an `NSBox`, or a plain `NSView` with `wantsLayer = true`) or a `UIView`, setting `layer.cornerRadius` with `layer.masksToBounds`, `layer.borderWidth`/`layer.borderColor`, and `layer.shadowOpacity`/`shadowRadius`/`shadowOffset` to reproduce corner radius, border, and shadow — note that a single layer cannot both mask and cast a shadow, so use a wrapper view for the shadow and an inner masked view for the rounded fill. Lay the header/title/description/content/footer out as an `NSStackView`/`UIStackView`, with `spacing` standing in for `gap-6`/`gap-1.5` and `layoutMargins` for `px-6`/`py-6`, since neither framework has a `data-slot` equivalent. Set `isAccessibilityElement = false` on the container and `accessibilityTraits = .header` on the title label to recover the `<h3>` semantics.
- **WinUI 3**: Use a `Border` wrapping a `StackPanel` (or `Grid`) as the root, setting `CornerRadius`, `BorderBrush`/`BorderThickness`, and `Background` to the theme resources standing in for `rounded-xl`/`border-apt-border`/`bg-apt-bg`, and apply a `ThemeShadow` through the root element's `Shadow` and `Translation` properties to approximate `shadow-sm`. Nest `StackPanel`s for the header, content, and footer slots, with the footer panel using `Orientation="Horizontal"` and `VerticalAlignment="Center"` to match the source's `flex items-center`. WinUI 3 has no flexbox `gap`, so reproduce `gap-6`/`gap-1.5` with `StackPanel.Spacing` (or an explicit `Margin` on each child inside a `Grid`), and express the source's `py-6`/`px-6` split as `Padding` on the root `Border` for the vertical axis plus `Padding` on each slot panel for the horizontal axis. There is no `data-slot` equivalent: give each slot an `x:Name`, or define the whole card as a templated `ContentControl` whose `ControlTemplate` exposes `Header`, `Content`, and `Footer` `ContentPresenter`s. The card is non-interactive, so set `IsTabStop="False"` and define no `VisualStateManager` states for pointer, press, or focus; set `AutomationProperties.Name` on the root and `AutomationProperties.HeadingLevel="Level3"` on the title `TextBlock` to match the Landing Card's `<h3>`.

## Design Decisions

- Both source files export a component named `Card`, but they are not variants of one component: Landing Card has a fixed kicker/title/children shape with a semantic `<h3>` title, while the UI Card family is an unstructured, slot-based composition whose `CardTitle` is a plain `<div>` with no heading semantics. This recipe documents both under one ingredient name because that is how the sources are named, but implementors MUST choose one implementation deliberately rather than treating them as interchangeable — mixing them (e.g., expecting the UI Card family's `CardTitle` to behave like Landing Card's `<h3>`) will produce different accessibility and layout results.
- The UI Card family expresses every color and size as a Tailwind utility class or an `apt-*` design token (e.g. `bg-apt-bg`, `border-apt-border`, `text-apt-text-muted`) rather than as a literal value. The class and token names are therefore stated as the requirement throughout Appearance: an implementation conforms by using the named token, and the concrete pixel or color value is whatever the project's Tailwind and token configuration binds to it. The source comment states the intent — the family mirrors hub's component so the shared library and hub render identically — which is why the token indirection is load-bearing and MUST NOT be flattened into hard-coded values.
- The Landing Card sets no inline styling whatsoever: its appearance lives entirely in the external `lp-card` and `lp-card__kicker` CSS classes. This recipe therefore reports those class names as the appearance contract for that implementation; a port to another platform takes its visual values from that stylesheet, not from the component file.
- The kicker guard tests `kicker === undefined` by identity rather than by truthiness, so a `null` or empty-string kicker still renders an empty `<span class="lp-card__kicker">`. The source comment explains why the kicker is a separate slot at all — the heading names the thing and the kicker says what kind of thing it is, a distinction that is lost if the two are folded into one prop at the same weight.
- Neither implementation sets an ARIA role, label association, or tap target, because neither is an interactive control in source — both are static containers. This recipe does not invent accessibility behavior that is not present in the code (see Accessibility).

## Compliance

Not applicable: Card is a static, presentational container with no data collection, interactive states, network requests, or persistent state. As a purely render-time component with no side effects, it has no security, privacy, or compliance requirements beyond what its parent component or caller is responsible for.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.1.0 | 2026-09-22 | Mike Fullerton | State the Tailwind utilities, `apt-*` tokens and `lp-card`/`lp-card__kicker` class names as the appearance contract in place of unresolved-value placeholders; answer the sizing, kicker-guard and accessibility-option questions directly from source; fill the Accessibility Options table; add automation, semantics and layout detail to every platform note. One open accessibility question about the family's non-heading title is left for the reviewer. |
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation from `packages/web/packages/landing/src/blocks/Card.tsx` and `packages/web/packages/ui/src/components/card.tsx`. |
