---
id: 968f66df-4c2d-47ba-92cf-ff1e34f5deb2
title: Paper Search View
domain: agenticdevelopertoolkit://recipes/paper-search-view
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Searchable paper corpus interface with author filtering and customizable
  labels.
platforms:
- typescript
- web
tags:
- search
- papers
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Paper Search View

## Overview

Paper Search View is a React component that provides a search interface for a public paper corpus. It wraps SearchView to handle paper-specific configuration, including API endpoint setup, document type registration, and author filtering. The component is designed to be mounted on both a corpus-wide search page and on individual author index pages, with the only difference being the optional `authorSlug` prop that narrows results to a single author.

## Behavioral Requirements

- **must-accept-document-href**: Component MUST accept a required `documentHref` prop that is a function accepting a PaperSearchHit and returning a string representing the document's URL on the host.
- **must-configure-search-source**: Component MUST configure a SearchSource with endpoints for results (`/public/papers`), tags (`/public/papers/tags`), and categories (`/public/papers/categories`).
- **must-apply-no-store-cache**: Component MUST set cache policy to `no-store` on fetch requests to ensure search results reflect the current corpus state.
- **must-accept-author-slug**: Component MAY accept an optional `authorSlug` prop; when provided, search results MUST be filtered to that author.
- **must-accept-base-url**: Component MAY accept an optional `baseUrl` prop to override the default API prefix (defaults to same-origin `/api`).
- **must-accept-search-label**: Component MAY accept an optional `searchLabel` prop; when omitted, defaults to `Search research papers`.
- **must-accept-search-placeholder**: Component MAY accept an optional `searchPlaceholder` prop; when omitted, defaults to `Search papers…`.
- **must-accept-landmark-label**: Component MAY accept an optional `searchLandmarkLabel` prop; when omitted, defaults to `Research paper search`.
- **must-register-document-type**: Component MUST register `markdownDocumentType` as the document type for search results.
- **must-render-search-view**: Component MUST render the wrapped SearchView component with all configured props passed through.

## Appearance

Not applicable: Paper Search View is a wrapper component that delegates all visual rendering to the wrapped SearchView component. The appearance is determined entirely by SearchView's implementation.

## States

Not applicable: Paper Search View is a stateless wrapper component. All state management is handled by the wrapped SearchView component.

## Accessibility

Not applicable: Accessibility is the responsibility of the wrapped SearchView component, which receives the searchLabel, searchPlaceholder, and searchLandmarkLabel props to support accessible naming.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| psv-001 | must-accept-document-href | PaperSearchViewProps with documentHref function | SearchView rendered with documentHref passed through |
| psv-002 | must-configure-search-source | Default props (no baseUrl, no authorSlug) | SearchSource configured with endpoints `/public/papers`, `/public/papers/tags`, `/public/papers/categories` and baseUrl `/api` |
| psv-003 | must-apply-no-store-cache | Any props | SearchSource fetchInit set to `{ cache: 'no-store' }` |
| psv-004 | must-accept-author-slug | PaperSearchViewProps with authorSlug='author-name' | SearchSource fixedParams includes `{ author: 'author-name' }` (lowercase) |
| psv-005 | must-accept-base-url | PaperSearchViewProps with baseUrl='/custom/api' | SearchSource baseUrl set to `/custom/api` |
| psv-006 | must-accept-search-label | PaperSearchViewProps with searchLabel='Custom label' | SearchView receives searchLabel='Custom label' |
| psv-007 | must-accept-search-label | PaperSearchViewProps without searchLabel | SearchView receives searchLabel='Search research papers' |
| psv-008 | must-accept-search-placeholder | PaperSearchViewProps with searchPlaceholder='Custom…' | SearchView receives searchPlaceholder='Custom…' |
| psv-009 | must-accept-search-placeholder | PaperSearchViewProps without searchPlaceholder | SearchView receives searchPlaceholder='Search papers…' |
| psv-010 | must-accept-landmark-label | PaperSearchViewProps with searchLandmarkLabel='Custom landmark' | SearchView receives searchLandmarkLabel='Custom landmark' |
| psv-011 | must-accept-landmark-label | PaperSearchViewProps without searchLandmarkLabel | SearchView receives searchLandmarkLabel='Research paper search' |
| psv-012 | must-register-document-type | Any props | SearchView receives documentType=markdownDocumentType |

## Edge Cases

- **Missing documentHref**: documentHref is a required prop with no default. Omitting it will cause a TypeScript compilation error; the component MUST NOT render without this prop.
- **authorSlug whitespace**: When authorSlug is provided, it MUST be trimmed and converted to lowercase before being passed to fixedParams. Empty string after trimming MUST be treated as if authorSlug was not provided.
- **baseUrl override**: When baseUrl is provided, it MUST override the default `/api` value. No validation of baseUrl format is performed by the component.
- **Label customization**: The searchLabel, searchPlaceholder, and searchLandmarkLabel props exist to support host-specific terminology. The component MUST NOT validate or modify these values.
- **Empty corpus response**: No edge case handling is specified for empty search results; this is handled by SearchView.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| documentHref | `(hit: PaperSearchHit) => string` | Required | URL mapping function for search result links |
| authorSlug | `string` | undefined | Author slug to filter corpus results |
| baseUrl | `string` | `/api` | API prefix override |
| searchLabel | `string` | `Search research papers` | Accessible label for search input |
| searchPlaceholder | `string` | `Search papers…` | Placeholder text for search input |
| searchLandmarkLabel | `string` | `Research paper search` | Landmark label for search region |

## Deep Linking

Not applicable: Paper Search View is a search interface component. Deep linking to specific papers is handled by the documentHref prop, which is configured by the host application to route to the appropriate paper pages.

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| searchLabel | `Search research papers` | Accessible label for the search field |
| searchPlaceholder | `Search papers…` | Placeholder text shown in search input |
| searchLandmarkLabel | `Research paper search` | Landmark/region label for accessibility |

## Accessibility Options

Not applicable: Paper Search View is a wrapper component. Accessibility option support (Reduce Motion, Increase Contrast, Differentiate Without Color) is implemented by SearchView. The component passes through the necessary labels to support keyboard and screen reader navigation.

## Feature Flags

Not applicable: Paper Search View does not implement feature flags. Feature flag behavior, if any, is managed by SearchView or the underlying backend API.

## Analytics

Not applicable: Paper Search View does not directly emit analytics events. Analytics tracking is the responsibility of the wrapped SearchView component.

## Privacy

Not applicable: Paper Search View does not collect, store, or transmit sensitive user data. It is a stateless wrapper that passes requests through to SearchView and the backend API. Privacy obligations belong to SearchView and the search backend.

## Logging

Not applicable: Paper Search View does not implement logging. Any debug or error logging is handled by SearchView or the backend API.

## Platform Notes

- **Web**: PaperSearchView is defined in `packages/web/packages/search/src/components/PaperSearchView.tsx`. It is a React functional component that wraps SearchView (`./SearchView`). The paperSearchSource helper function constructs the SearchSource configuration. Developers import both `PaperSearchView` and `paperSearchSource` directly.
- **SwiftUI**: Implement as a SwiftUI View that configures a search interface using native SwiftUI SearchFieldModifier or similar standard search control. Accept the same configuration parameters (documentHref closure, authorSlug, baseUrl, label customizations) and pass them to an underlying SearchView implementation.
- **Compose**: Implement as a Composable function accepting the same parameters as the web component. Use Compose Material 3 SearchBar or similar native component for the search field. Configure the underlying SearchView Composable with the provided SearchSource configuration.
- **AppKit / UIKit**: Implement as a view controller or view class wrapping NSSearchField (AppKit) or UISearchBar (UIKit). Accept the same configuration parameters and configure the underlying search view implementation with the SearchSource endpoints and options.
- **WinUI 3**: Implement as a UserControl containing an AutoSuggestBox from WinUI 3 (or SearchBox if targeting earlier Windows versions). Configure the AutoSuggestBox to query the SearchSource endpoints `/public/papers`, `/public/papers/tags`, and `/public/papers/categories` at the provided baseUrl (default `/api`). Implement author filtering by including the author parameter in requests when authorSlug is provided. Use the provided label customizations (searchLabel as the control's label, searchPlaceholder as the TextBlock placeholder text, searchLandmarkLabel as the accessibility name). Bind documentHref as a navigation callback when results are selected.

## Design Decisions

Paper Search View exists as a wrapper component to prevent configuration drift between different mounting contexts (corpus-wide search page and author index page). By centralizing the SearchSource configuration and prop defaults in one place, the component enforces consistency without requiring duplicate configuration at each call site. This decision prioritizes consistency over flexibility, accepting that local customization must go through the explicit props interface rather than allowing direct SearchView configuration at the point of use.

The accessible names are props with defaults rather than literals because the package owns the UI but the host owns the words. This design allows the same component to be mounted on multiple sites or in multiple languages without modification, delegating vocabulary choices to the host application.

The `documentHref` prop is deliberately NOT derived from configuration but is instead required at every call site. This implements the seam doctrine: the URL space belongs to the host, not the search package. The same corpus is addressed differently on different hosts, and the component must not assume or prescribe the URL scheme.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| Source fidelity | Pending | Quality |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation |
