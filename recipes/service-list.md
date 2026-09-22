---
id: fe09968a-6575-40d0-b0b8-af6ce52d8efd
title: Service List
domain: agenticdevelopertoolkit://recipes/service-list
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Displays a list of services with titles, descriptions, and formatted pricing
  information.
platforms:
- typescript
- web
tags:
- list
- services
- pricing
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Service List

## Overview

The Service List component displays a collection of services with their titles, optional descriptions, and formatted pricing. It renders as a semantic section containing an unordered list of service items. When the services array is empty, the component renders nothing.

## Behavioral Requirements

- **must-render-section**: Component MUST render a `<section>` element when the services array contains one or more items.
- **must-not-render-empty**: Component MUST NOT render any output when the services array is empty or null.
- **must-render-heading**: Component MUST render an `<h2>` heading with the text "Services" within the section.
- **must-render-list**: Component MUST render an unordered list (`<ul>`) containing one list item per service.
- **must-display-title**: Component MUST display each service's title as an `<h3>` heading within the list item.
- **must-display-price**: Component MUST display each service's formatted price using the priceText formatter.
- **should-display-description**: Component SHOULD display each service's description text when the description property is present and non-empty.
- **must-use-semantic-html**: Component MUST use semantic HTML elements (section, heading, list) rather than divs.

## Appearance

- **Corner radius**: None (component uses browser default)
- **Padding**: Defined by CSS classes (rp-services, rp-services__list, rp-service)
- **Font**: Inherited from parent; no inline font styling applied
- **Background**: Inherited from parent; no inline background color applied
- **Foreground/Text**: Inherited from parent; no inline text color applied
- **Border**: None applied by component
- **Shadow**: None applied by component
- **Min/Max size**: No constraints applied by component

## States

| State | Appearance change |
|-------|------------------|
| Default | Services displayed in list format |
| Empty | No output rendered |

## Accessibility

- **Role**: The component uses semantic HTML (`<section>`, `<h2>`, `<ul>`, `<li>`, `<h3>`, `<p>`), which provides correct semantic roles to assistive technologies.
- **Heading hierarchy**: Uses `<h2>` for "Services" section heading and `<h3>` for individual service titles, maintaining proper document outline.
- **List structure**: Unordered list markup provides clear list semantics to screen readers.
- **Text content**: All text content (titles, descriptions, prices) is marked up as text, not images or non-semantic elements.
- **No interactive elements**: This component contains no interactive controls; it is a static display component.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| service-list-001 | must-render-section, must-render-heading, must-render-list | services = [{title: "Web Design", description: "Custom website design", pricingModel: "hourly", priceMin: 75, priceMax: 150, currency: "USD"}] | Renders `<section class="rp-services">` with `<h2 class="rp-services__heading">Services</h2>` and `<ul class="rp-services__list">` |
| service-list-002 | must-display-title, must-display-price, should-display-description | services = [{title: "Web Design", description: "Custom website design", pricingModel: "hourly", priceMin: 75, priceMax: 150, currency: "USD"}] | Renders `<h3>Web Design</h3>`, `<p>Custom website design</p>`, and price as "$75–$150 per hour" |
| service-list-003 | must-display-price | services = [{title: "Consultation", pricingModel: "free"}] | Renders price text as "Free" |
| service-list-004 | must-display-price | services = [{title: "Trade Services", pricingModel: "barter"}] | Renders price text as "Trade or barter" |
| service-list-005 | must-display-price | services = [{title: "Custom Rate", pricingModel: "hourly"}] (with no priceMin/priceMax) | Renders price text as "Rate on request" |
| service-list-006 | should-display-description | services = [{title: "Service Name", description: null}] | Does not render description paragraph |
| service-list-007 | must-not-render-empty | services = [] | Component returns null; no output rendered |
| service-list-008 | must-use-semantic-html | Any valid services array | All rendered elements use semantic HTML tags (section, h2, ul, li, h3, p) |

## Edge Cases

- **Empty services array**: Component returns null and renders nothing (verified by conditional check at line 952).
- **Single service**: Component correctly renders section, heading, and list with one item.
- **Missing description**: Component conditionally renders description paragraph only when service.description is truthy (line 960).
- **Price edge cases**: priceText function handles free, barter, null priceMin/priceMax, and range pricing. When both priceMin and priceMax are provided but equal, displays single value instead of range.
- **Missing priceMin and priceMax**: priceText returns "Rate on request" when both values are null.
- **Currency formatting**: Uses Intl.NumberFormat with maximumFractionDigits: 0 to format prices (no decimal places).
- **List key**: Component uses service.title as the React key, which should be unique within the services array.

## Configuration

Not applicable: Component accepts a single `services` prop array as input; no configuration options or settings exposed.

## Deep Linking

Not applicable: This component is a display component with no interactive navigation or state that would warrant deep linking.

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| services.heading | "Services" | Section heading text; appears inline in component |
| pricing.free | "Free" | Displayed when pricingModel is "free" |
| pricing.barter | "Trade or barter" | Displayed when pricingModel is "barter" |
| pricing.rate_on_request | "Rate on request" | Displayed when both priceMin and priceMax are null |
| pricing.per_hour | "per hour" | Suffix displayed for hourly pricing model |
| pricing.per_job | "per job" | Suffix displayed for per_job pricing model |
| pricing.per_deliverable | "per deliverable" | Suffix displayed for per_deliverable pricing model |
| pricing.per_month | "per month" | Suffix displayed for subscription pricing model |

## Accessibility Options

- **Reduce Motion**: Not applicable. Component has no animations or motion effects.
- **Increase Contrast**: Component relies on CSS styling via classes; contrast requirements are handled by the CSS implementation, not the component.
- **Differentiate Without Color**: Component uses text and semantic markup; no information conveyed by color alone.

## Feature Flags

Not applicable: Component accepts data via props only; no feature flags control rendering behavior.

## Analytics

Not applicable: Component contains no analytics event tracking or user interaction handlers.

## Privacy

- **Data collected**: Component displays service data passed via props; does not collect user data.
- **Storage**: No local storage or persistent storage by component.
- **Transmission**: Component does not transmit data; it only displays data provided via props.
- **Retention**: No retention of data by component; rendering is stateless.

## Logging

Not applicable: Component contains no logging statements.

## Platform Notes

- **React/Web**: Renders semantic HTML using JSX. Uses `services.map()` to iterate over the array and `Intl.NumberFormat` for currency formatting. CSS classes (rp-services, rp-services__list, rp-service, etc.) handle styling. Key prop uses service.title; ensure titles are unique within the array to avoid React reconciliation issues.
- **SwiftUI**: Map the services array using a `List` with `ForEach`. Use `Section(header: Text("Services"))` for the heading. Display title with `Text` at heading level, description conditionally with `.lineLimit(nil)`, and price using a localized NumberFormatter configured for currency. Apply `.listStyle(.plain)` or appropriate list style.
- **Compose**: Use a `LazyColumn` or `Column` within a `Surface` for the section. Display the "Services" heading with appropriate typography style. Iterate services using `.forEach` and render `Row` or `Column` layouts for each item. Format price using NumberFormat or Locale-aware price formatting. Apply conditional rendering for description using `if (service.description != null)`.
- **AppKit / UIKit**: Use `UIStackView` (vertical axis) as container, or `NSStackView` on macOS. Add `UILabel` or `NSTextField` for "Services" heading, then an unordered list view (custom `UITableViewController` or `UICollectionViewController`). For each service, render title as bold, description as regular text, and price formatted using `NumberFormatter` with currency style. Conditionally include description based on presence.
- **WinUI 3**: Use a `StackPanel` with `Orientation="Vertical"` as container. Add a `TextBlock` for "Services" heading with `FontSize` 18 and `FontWeight` SemiBold. Use an `ItemsControl` or `ListViewBase` bound to the services collection. For each item, create a template with `TextBlock` for title (FontWeight Bold), conditional `TextBlock` for description, and `TextBlock` for formatted price. Format price using `NumberFormatInfo` for the appropriate culture with CurrencySymbol.

## Design Decisions

The component delegates all styling to CSS classes rather than applying inline styles. This maintains separation of concerns and allows styling to be managed independently. The key prop uses service.title, assuming titles are unique within a given services array; if titles are not guaranteed unique, the calling context should ensure uniqueness or provide an explicit unique identifier prop.

The priceText function is implemented inline in the component file and handles all pricing model formatting logic. This centralization simplifies pricing display but ties formatting tightly to this component. If pricing formatting is needed elsewhere, consider extracting to a shared utility function.

The component renders nothing when the services array is empty (returns null at line 952). This allows parent layouts to collapse the section entirely rather than rendering an empty section with a heading.

## Compliance

Not applicable: Component contains no authentication, authorization, network requests, or sensitive data handling requiring compliance verification.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from ServiceList.tsx source |
