---
id: 6c034a7a-3a43-4da6-bc1a-0cbc39f32cc4
title: Registry Profile
domain: agenticdevelopertoolkit://recipes/registry-profile
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Displays a registry entry with profile details, custom fields, services,
  and links.
platforms:
- typescript
- web
tags:
- profile
- registry
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Registry Profile

## Overview

Registry Profile displays a comprehensive view of a single registry entry, including identity information (name, photo, summary), metadata (category, location, languages), custom fields with visibility controls, services, keywords, and external links. The component adapts to the serving context through pluggable image resolution and optional contact affordances.

## Behavioral Requirements

- **must-render-display-name**: Component MUST render the entry's `displayName` as an `<h1>` heading.
- **must-render-photo-when-available**: Component MUST render the entry's photo if `photoAttachmentId` is present and `resolveImageUrl(photoAttachmentId)` returns a non-null value.
- **must-render-photo-alt-empty**: Component MUST set the photo `alt` attribute to an empty string (not a description), as the photo is decorative context for sighted users and the name heading provides textual identity.
- **must-render-summary-when-present**: Component MUST render the entry's `summary` as a paragraph if the summary string is truthy.
- **must-render-category-when-present**: Component MUST render the entry's `category` as a metadata row if the category string is truthy.
- **must-render-location-when-present**: Component MUST render the entry's `locationText` as a metadata row if the location string is truthy.
- **must-render-languages-list**: Component MUST render the entry's `languages` array as a comma-separated string in a metadata row if the array length is greater than zero.
- **must-render-keywords-list**: Component MUST render the entry's `keywords` array as an unordered list of keyword items if the array length is greater than zero.
- **must-render-contact-affordance-conditionally**: Component MUST render the `contact` prop inside a contact container only if `entry.contactMode === 'dm'` AND `contact` is not null or undefined.
- **must-render-all-fields**: Component MUST render every field in `entry.fields` as a description-list item with the field's label and value.
- **must-render-field-visibility-marker**: Component MUST render a visibility marker span inside the field label if the field's visibility is not `public`. The marker text MUST be "Signed-in members only" for `authenticated` visibility and "Private" for `private` visibility.
- **must-not-render-invisible-marker-for-public**: Component MUST NOT render a visibility marker for fields with `public` visibility.
- **must-render-service-list**: Component MUST render a `ServiceList` component with the entry's `services` array.
- **must-render-links-section**: Component MUST render a navigation section with `aria-label="Elsewhere"` containing an unordered list of links if `entry.links` array length is greater than zero.
- **must-render-links-with-fallback-label**: Component MUST render each link with the link's `label` as display text if the label is truthy, otherwise use the `url` as display text.
- **must-set-link-security-attributes**: Component MUST set `rel="noopener noreferrer nofollow"` and `target="_blank"` on all links.
- **must-use-resolver-for-image-urls**: Component MUST use the `resolveImageUrl` prop to resolve all image attachment IDs to URLs. If `resolveImageUrl` is not provided, Component MUST default to looking up the ID in `entry.imageUrls`.
- **must-resolve-to-null-for-missing-images**: Component MUST return `null` from the resolver when an image attachment ID has no corresponding URL.
- **must-accept-null-from-resolver**: Component MUST treat a `null` return value from `resolveImageUrl` as "no image" and render the profile without that image.
- **must-render-as-article**: Component MUST render the profile root as an `<article>` element.

## Appearance

- **Root container**: `<article>` with className `rp`
- **Header section**: `<header>` with className `rp__header`
- **Photo**: `<img>` with className `rp__photo`, rendered only if URL is available
- **Identity container**: `<div>` with className `rp__identity`
- **Display name**: `<h1>` with className `rp__name`
- **Summary**: `<p>` with className `rp__summary`
- **Metadata list**: `<dl>` with className `rp__meta`
- **Metadata row**: `<div>` with className `rp__meta-row`
- **Metadata label**: `<dt>` element
- **Metadata value**: `<dd>` element
- **Keywords list**: `<ul>` with className `rp__keywords`
- **Keyword item**: `<li>` with className `rp__keyword`
- **Contact container**: `<div>` with className `rp__contact`
- **Fields section**: `<dl>` with className `rp__fields`
- **Field container**: `<div>` with className `rp__field` and data attribute `data-field-key={field.key}`
- **Field label**: `<dt>` with className `rp__field-label`
- **Field visibility marker**: `<span>` with className `rp__field-audience` and data attribute `data-audience={field.visibility}`
- **Field value**: `<dd>` with className `rp__field-value`
- **Links section**: `<nav>` with className `rp__links` and `aria-label="Elsewhere"`

## States

| State | Condition | Appearance change |
|-------|-----------|------------------|
| With photo | `photoAttachmentId` present and URL resolves | Photo visible in header |
| Without photo | `photoAttachmentId` absent or URL resolves to null | No photo element rendered |
| With summary | `summary` is truthy | Summary paragraph displayed |
| Without summary | `summary` is falsy | No summary element rendered |
| With metadata | Category, location, or languages present | Metadata rows displayed in definition list |
| With keywords | `keywords.length > 0` | Keywords rendered as list items |
| Without keywords | `keywords.length === 0` | No keywords section rendered |
| Contact available | `contactMode === 'dm'` AND `contact` prop provided | Contact affordance container rendered |
| Contact unavailable | `contactMode !== 'dm'` OR `contact` prop absent | No contact container rendered |
| Field public | `field.visibility === 'public'` | No visibility marker rendered |
| Field authenticated | `field.visibility === 'authenticated'` | "Signed-in members only" marker rendered |
| Field private | `field.visibility === 'private'` | "Private" marker rendered |
| With links | `links.length > 0` | Links navigation section rendered |
| Without links | `links.length === 0` | No links section rendered |

## Accessibility

- **Role**: The root element is an `<article>`, which defines the profile as a standalone, self-contained piece of content.
- **Heading structure**: The display name is an `<h1>`, which provides proper document structure.
- **Photo alt text**: The photo `alt` attribute is an empty string, signaling to assistive technology that it is decorative; the `<h1>` provides the identity.
- **Metadata structure**: The metadata (category, location, languages) is rendered in a description list (`<dl>`), providing semantic structure for screen readers.
- **Links section**: The links navigation has `aria-label="Elsewhere"` to describe the section purpose to assistive technology users.
- **Field labels**: Each field is rendered with a `<dt>` label paired with a `<dd>` value in a definition list, providing semantic structure.
- **Visibility markers**: Visibility markers are inline in the field label, ensuring users encounter the visibility restriction immediately when they reach the field.
- **Field values**: `FieldValue` renders each value by type: `url` as an `<a>` with `rel="noopener noreferrer nofollow"` and `target="_blank"`, `image` as an `<img>` whose `alt` is the field label, and every other type (text, textarea, markdown, date, select, multi_select, boolean, address, email, phone) as text content. The `<dt>` label supplies the accessible name for each `<dd>` value. See the `field-value` recipe.
- **Services**: `ServiceList` is a static section headed by an `<h2>` ("Services") with one `<h3>` per service, continuing the heading hierarchy under the profile's `<h1>`. It has no interactive elements, so there is nothing to reach by keyboard. See the `service-list` recipe.
- **Touch targets**: The only interactive elements are inline text links (the "Elsewhere" links and `url` field values). Inline links within text are exempt from the WCAG 2.5.8 minimum target size; the profile adds no buttons or controls.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| profile-001 | must-render-display-name | `entry.displayName = "Alice"` | Output contains `<h1 class="rp__name">Alice</h1>` |
| profile-002 | must-render-photo-when-available | `entry.photoAttachmentId = "photo-123"`, `resolveImageUrl("photo-123") = "https://cdn.example.com/photo.jpg"` | Output contains `<img class="rp__photo" src="https://cdn.example.com/photo.jpg" alt="" />` |
| profile-003 | must-render-photo-alt-empty | `entry.photoAttachmentId = "photo-123"`, `resolveImageUrl` returns URL | Photo element has `alt=""` (empty string) |
| profile-004 | must-render-summary-when-present | `entry.summary = "Software engineer"` | Output contains `<p class="rp__summary">Software engineer</p>` |
| profile-005 | must-render-summary-when-present | `entry.summary = ""` (empty string) | Output does not contain `rp__summary` element |
| profile-006 | must-render-category-when-present | `entry.category = "Engineering"` | Output contains metadata row with label "Category" and value "Engineering" |
| profile-007 | must-render-category-when-present | `entry.category = null` | Output does not contain category metadata row |
| profile-008 | must-render-location-when-present | `entry.locationText = "San Francisco"` | Output contains metadata row with label "Location" and value "San Francisco" |
| profile-009 | must-render-languages-list | `entry.languages = ["English", "Spanish"]` | Output contains metadata row with label "Languages" and value "English, Spanish" |
| profile-010 | must-render-languages-list | `entry.languages = []` | Output does not contain languages metadata row |
| profile-011 | must-render-keywords-list | `entry.keywords = ["react", "typescript"]` | Output contains `<li class="rp__keyword">react</li>` and `<li class="rp__keyword">typescript</li>` |
| profile-012 | must-render-keywords-list | `entry.keywords = []` | Output does not contain `rp__keywords` element |
| profile-013 | must-render-contact-affordance-conditionally | `entry.contactMode = "dm"`, `contact = <ContactButton />` | Contact container rendered with ContactButton inside |
| profile-014 | must-render-contact-affordance-conditionally | `entry.contactMode = "email"`, `contact = <ContactButton />` | Contact container is not rendered |
| profile-015 | must-render-contact-affordance-conditionally | `entry.contactMode = "dm"`, `contact = null` | Contact container is not rendered |
| profile-016 | must-render-all-fields | `entry.fields = [{key: "email", label: "Email", value: "alice@example.com", visibility: "public"}]` | Output contains field container with data-field-key="email" |
| profile-017 | must-render-field-visibility-marker | `field.visibility = "authenticated"` | Field label contains span with text "Signed-in members only" |
| profile-018 | must-render-field-visibility-marker | `field.visibility = "private"` | Field label contains span with text "Private" |
| profile-019 | must-not-render-invisible-marker-for-public | `field.visibility = "public"` | Field label does not contain visibility marker span |
| profile-020 | must-use-resolver-for-image-urls | `resolveImageUrl` provided | All image URLs are resolved via the provided function, not `entry.imageUrls` |
| profile-021 | must-use-resolver-for-image-urls | `resolveImageUrl` not provided | Component falls back to `entry.imageUrls[id]` |
| profile-022 | must-render-as-article | any input | Root element is `<article class="rp">` |
| profile-023 | must-render-links-section | `entry.links = [{url: "https://example.com", label: "Portfolio"}]` | Output contains `<nav class="rp__links" aria-label="Elsewhere">` with link |
| profile-024 | must-render-links-with-fallback-label | `entry.links = [{url: "https://example.com", label: ""}]` | Link displays the URL as text, not the empty label |
| profile-025 | must-set-link-security-attributes | `entry.links = [{url: "https://example.com", label: "Site"}]` | Link has `rel="noopener noreferrer nofollow" target="_blank"` |

## Edge Cases

- **Null or undefined entry**: Not applicable. The component requires a `PublicEntry` and will error if `entry` is null. The host is responsible for ensuring a valid entry is provided.
- **Empty entry.fields array**: Component MUST render the profile without a fields section if `fields.length === 0`.
- **photoAttachmentId without URL resolution**: If `photoAttachmentId` is present but `resolveImageUrl` returns `null`, Component MUST render the profile without a photo. This is distinguishable from the photo not existing in the entry.
- **All metadata fields falsy**: If category, locationText, languages are all falsy or empty, Component MUST not render the metadata list.
- **Field with empty label**: Not applicable. The source assumes field labels are provided by the server; empty labels are a server data quality issue.
- **Resolver throws an error**: Not applicable. The component assumes the resolver does not throw and returns a string or null. Error handling is the host's responsibility.
- **Very long display name**: Component MUST render the full display name without truncation. CSS styling determines whether the name wraps or overflows.
- **Very long field values**: Component delegates to `FieldValue` component. Edge case handling is FieldValue's responsibility.
- **Concurrent updates to entry prop**: Not applicable. The component is a functional React component and does not maintain mutable state. Behavior when `entry` prop changes is React's re-render lifecycle, not a component-defined edge case.
- **contact prop changes between render cycles**: Component MUST render the new contact prop value on the next render.

## Configuration

Not applicable: RegistryProfile is a presentation component with no configuration options. All behavior is determined by the `entry` data and the optional `resolveImageUrl` and `contact` props.

## Deep Linking

Not applicable: RegistryProfile does not define any deep linking behavior. The host application is responsible for routing to this component and providing the entry data.

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| field-visibility.authenticated | "Signed-in members only" | Marker text shown when a field is visible only to authenticated users |
| field-visibility.private | "Private" | Marker text shown when a field is marked private |
| metadata.category | "Category" | Label for the category metadata row |
| metadata.location | "Location" | Label for the location metadata row |
| metadata.languages | "Languages" | Label for the languages metadata row |
| nav.elsewhere | "Elsewhere" | aria-label for the links navigation section |

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Not applicable: RegistryProfile does not animate. All content is static. |
| Increase Contrast | Deferred to CSS styling and the host application's theme. Component does not define color values. |
| Differentiate Without Color | Deferred to the FieldValue and ServiceList child components and CSS styling. |

## Feature Flags

Not applicable: RegistryProfile has no feature flags. All behavior is always enabled.

## Analytics

Not applicable: RegistryProfile is a presentational component and does not emit analytics events. Event tracking is the host application's responsibility.

## Privacy

- **Data collected**: None. RegistryProfile is a presentation component and collects no telemetry, tracking, or user interaction data.
- **Storage**: Not applicable. Component does not store data.
- **Transmission**: Not applicable. Component does not transmit data beyond rendering what was passed in.
- **Retention**: Not applicable. Component does not retain data.
- **Note**: The component renders data that was passed to it by the host. The host is responsible for privacy handling of the entry data (e.g., filtering fields the viewer is not authorized to see, which the server already does via the `PublicEntry` type and the backend's filtering logic).

## Logging

Not applicable: RegistryProfile does not emit logging. The host application is responsible for logging user interactions with the profile.

## Platform Notes

- **TypeScript/React Web**: Source is a React functional component in TypeScript at `packages/web/packages/registry-profile/src/RegistryProfile.tsx`. Key implementation details: the component uses conditional rendering (`? :`) for optional sections, a resolver pattern for image URLs with a nullish coalescing fallback to `entry.imageUrls`, and an exhaustive `Record<FieldVisibility, string | null>` to ensure visibility markers are defined for every audience type. The component does not fetch data; all content is provided via props.
- **SwiftUI**: Translate the component as a View that renders a scrollable VStack. The header is an HStack with the photo (Image, if available) and a VStack for identity details. Use SwiftUI's @State for conditional rendering of optional sections. Map `FieldVisibility` to a conditional modifier that renders a Text label. Delegate field value rendering to a FieldValue View and link list rendering to a ServiceList View. Use `navigationLink(destination:)` for external links with `openURL` environment action.
- **Compose**: Implement as a Composable function that renders a Column (scrollable) with a Row header containing the photo (Image) and identity content. Use conditional composition (`if` or `when`) for optional sections. Create a metadata state holder mapping category, location, languages to visual rows. Render field items in a LazyColumn with a custom row Composable. Delegate to FieldValue and ServiceList Composables. Use `navController.openUrl()` or `openUri()` for external links.
- **AppKit / UIKit**: Implement as a UIViewController (or SwiftUI View in UIKit integration). The view hierarchy is a scroll view containing a stack view (horizontal or vertical) for the header (image view, vertical stack for identity), followed by nested table/stack views for metadata, keywords, contact, fields, and links. Use UILabel for display name and summary. Use UITableView or UIStackView for fields and metadata rows. Delegate field rendering to a FieldValue view controller. Implement deep links via custom URL schemes or universal links if the host supports them. Apply visibility markers as UILabel overlays on field rows.
- **WinUI 3**: Implement as a XAML UserControl or Page. Use Grid and StackPanel for layout: a StackPanel header contains an Image for the photo and a StackPanel for identity (TextBlock for name, TextBlock for summary). Use ItemsControl or DataGrid for the metadata definition list, rendering each row as a Grid with two TextBlocks. Use ItemsControl for keywords, styling each as a Border with a TextBlock. Conditionally include a ContentPresenter for the contact affordance. Use ItemsControl or DataGrid for fields, with a custom DataTemplate that includes a TextBlock for the label, a conditional TextBlock for the visibility marker, and a custom FieldValue control for the value. Render links as a ListView or ItemsControl with HyperlinkButton controls. Set `rel="noopener noreferrer nofollow"` behavior via URI scheme handlers or by opening links in a new window without passing the current window reference.

## Design Decisions

- **Image resolution via resolver pattern**: The component accepts an optional `resolveImageUrl` function rather than fetching images directly. This allows the host to control image delivery (CDN, proxy, storybook fixtures) without the component knowing which is in use. The fallback to `entry.imageUrls` map supports the common case where the backend already resolved all URLs. This design keeps the component decoupled from the host's infrastructure.
- **Visibility markers inline in field labels**: Visibility markers are rendered inside the `<dt>` field label, not floated beside the field value. This ensures a reader who encounters the marker has not already read a value they believed was public. The marker placement is a compromise between making the visibility constraint immediately visible and avoiding layout reflow.
- **Exhaustive visibility enum**: The `AUDIENCE_NOTE` Record is exhaustive on `FieldVisibility`, meaning adding a new visibility type to the enum will cause a TypeScript error at build time if the marker is not defined. This prevents silent rendering of unmarked fields, which is the failure mode that matters most (an unmarked field reads as public).
- **Private fields stripped server-side**: The component assumes the server has already filtered out fields the viewer is not authorized to see. Rendering only the fields in `entry.fields` is safe because the server removes inaccessible ones. The component does not hide fields in CSS or conditionally skip rendering, which would leave values in the markup where view-source tools could find them.
- **Conditional contact affordance slot**: The `contact` prop is a slot (a React node), not a callback function. This gives the host full control over what contact experience is rendered (the hub messaging composer on an ADH site, no contact on an embedder's site). The slot pattern decouples the component from knowing which contact implementation is in use.
- **No field label localization in component**: Field labels come from `entry.fields[*].label`, which the server provides. The component does not localize these labels; the server is responsible for providing labels in the viewer's language. This keeps localization out of the presentation layer.

## Compliance

Not applicable: This component is a presentational ingredient and does not define compliance requirements. The host application is responsible for ensuring data privacy, security, and accessibility compliance at the application level.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
