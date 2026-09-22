---
id: d6ff2cc3-89c8-4744-b3f4-7262e45a3414
title: Help Content
domain: agenticdevelopertoolkit://recipes/help-content
type: ingredient
version: 1.0.1
status: review
language: en
created: 2026-09-22
modified: 2026-09-22
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Context provider and hook for distributing localized help entries keyed by
  component id.
platforms:
- typescript
- web
tags: []
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Help Content

## Overview

HelpContent is a React context provider and hook system for distributing site-specific help text to UI components. A HelpContentProvider publishes a dictionary of help entries (keyed by component id) to its descendants; consuming components retrieve entries by id using the useHelpEntry hook. Each entry supports an optional title, required body text, and an optional flavor that categorizes the help type (help, info, or new).

## Behavioral Requirements

- **must-provide-context**: HelpContentProvider MUST create and provide a React context containing a SiteHelp dictionary to all descendant components.
- **must-accept-help-data**: HelpContentProvider MUST accept a `help` prop of type `Record<string, HelpEntry>`.
- **must-pass-children**: HelpContentProvider MUST render its `children` prop unchanged within the context provider.
- **must-retrieve-entry-by-id**: useHelpEntry MUST retrieve and return the HelpEntry object for a given id string from the context.
- **must-return-undefined-on-missing-id**: useHelpEntry MUST return undefined when the id does not exist in the help dictionary or no HelpContentProvider is mounted.
- **must-not-throw-on-missing-entry**: useHelpEntry MUST NOT throw an error when called without a provider or with an unknown id.
- **must-exclude-inherited-properties**: useHelpEntry MUST use Object.hasOwnProperty to verify id ownership (not inherited from Object.prototype) when retrieving entries.
- **must-support-three-flavors**: The HelpFlavor type MUST support exactly three values: "help", "info", "new".
- **must-default-flavor-to-info**: HelpEntry MUST use "info" as the default value for the optional `flavor` property.
- **must-support-optional-title**: HelpEntry MUST accept an optional `title` property; it MAY be omitted.
- **must-require-body**: HelpEntry MUST require a `body` property as a non-optional field.
- **must-accept-string-body**: HelpEntry `body` MUST be a string, not a ReactNode or JSX element.

## Appearance

Not applicable: HelpContent is a data provider component with no visual rendering. It publishes help text as data for downstream UI components to display.

## States

Not applicable: HelpContent is a stateless data provider component with no interactive or display states.

## Accessibility

Not applicable: HelpContent is a context provider component that has no direct user interaction or visual interface. Accessibility is the responsibility of consuming components that render the help entries it provides.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| help-content-001 | must-provide-context, must-accept-help-data, must-pass-children | Render `<HelpContentProvider help={{id1: {body: "text"}}} children={<Child />} />` | Child component renders and can access context via useHelpEntry |
| help-content-002 | must-retrieve-entry-by-id | Call `useHelpEntry("known_id")` with provider mounted and entry present | Returns HelpEntry object with `body` property |
| help-content-003 | must-return-undefined-on-missing-id | Call `useHelpEntry("unknown_id")` with provider mounted but no matching entry | Returns undefined |
| help-content-004 | must-not-throw-on-missing-entry | Call `useHelpEntry("any_id")` with no HelpContentProvider mounted | Returns undefined; does not throw |
| help-content-005 | must-exclude-inherited-properties | Call `useHelpEntry("constructor")` with provider containing only user-defined entries | Returns undefined; inherited Object.prototype properties are excluded |
| help-content-006 | must-support-three-flavors | Pass `{body: "text", flavor: "help"}`, `{body: "text", flavor: "info"}`, `{body: "text", flavor: "new"}` to HelpEntry | All three flavor values are accepted without type error |
| help-content-007 | must-default-flavor-to-info | Retrieve HelpEntry with no `flavor` property specified | Entry is accessible; flavor property defaults to "info" |
| help-content-008 | must-support-optional-title | Pass HelpEntry without `title` property | Entry is valid and accepted |
| help-content-009 | must-require-body | Attempt to create HelpEntry without `body` property | Type error; body is required |
| help-content-010 | must-accept-string-body | Pass `{body: "plain text"}` and `{body: "multiline\ntext"}` | Both string values accepted; JSX or ReactNode not accepted |

## Edge Cases

- **No provider mounted**: useHelpEntry called without a HelpContentProvider ancestor returns undefined; no error is thrown. This is intentional: the first consumer is in the header on every page of every site, so throwing would turn a typo into a white screen.
- **Prototype pollution prevention**: useHelpEntry("constructor") or other inherited property names return undefined because Object.hasOwnProperty filters to owned properties only, preventing SiteHelp object literals from accidentally returning constructor or other inherited functions.
- **Empty help dictionary**: HelpContentProvider mounted with empty `help={{}}` causes useHelpEntry to return undefined for any id queried.
- **Null or undefined id**: useHelpEntry called with null or undefined returns undefined.
- **Duplicate entry update**: SiteHelp is a plain object; redefining the same key updates the entry, and useHelpEntry returns the current value.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| help | `Record<string, HelpEntry>` | — | A dictionary of help entries keyed by component id. Required for HelpContentProvider. |
| title | string | undefined | Optional heading for a help entry. Omitted for entries with no title. |
| body | string | — | The help text content. Required for every HelpEntry. |
| flavor | "help" \| "info" \| "new" | "info" | Flavor tag categorizing the type of help content. |

## Deep Linking

Not applicable: HelpContent is a data provider component, not a routable page or interactive element.

## Localization

- **body field**: The `body` property is a plain string, not JSX or ReactNode. This is intentional: 37 of 41 consuming site configs are `.ts` files without JSX support and cannot express ReactNode values. Localization of help text is handled by the consuming application over its own per-locale help content file.
- **title field**: The optional `title` property is also a plain string for the same reason.
- **flavor field**: The `flavor` property is not localized; it is a semantic tag for the UI layer to interpret.

## Accessibility Options

Not applicable: HelpContent is a context provider component with no visual rendering or accessibility controls. Consuming components implement accessibility for displayed help content.

## Feature Flags

Not applicable: HelpContent component has no feature flag implementation in the source.

## Analytics

Not applicable: HelpContent component does not implement analytics event tracking. Consuming components that render help entries are responsible for any analytics integration.

## Privacy

Not applicable: HelpContent distributes site configuration help text declared in the consuming application's site definition. No personal data is collected, stored, or transmitted by this component.

## Logging

The `useHelpEntry` hook does not implement logging or console warnings itself; it returns `undefined` when an entry is not found. Consuming components (such as `<HelpEnabled>`) are responsible for warning to the console when an unknown id is requested, preventing downstream components from rendering popovers with undefined content.

## Platform Notes

- **SwiftUI**: Implement as a SwiftUI Environment value providing a dictionary of help entries. Create a `HelpEntry` struct mirroring the TypeScript interface with optional `title`, required `String` body, and `HelpFlavor` enum (info, help, new) with info as default. Expose via `@Environment(\.helpEntries) var helpEntries: [String: HelpEntry]` or through a `@EnvironmentObject` ViewModel that vends `func getHelpEntry(_ id: String) -> HelpEntry?` returning nil for unknown ids. Mount at the app root using `.environment(\.helpEntries, helpDictionary)` to parallelize the document-level provider placement.

- **Compose**: Implement as a CompositionLocal providing a Map<String, HelpEntry> or a function `(String) -> HelpEntry?`. Define `HelpEntry` data class with optional title, required String body, and `HelpFlavor` enum (INFO, HELP, NEW) with INFO default. Create `val LocalHelpEntries = compositionLocalOf<(String) -> HelpEntry?> { { null } }` and mount at the composition root via `CompositionLocalProvider(LocalHelpEntries provides { id -> helpMap[id] }) { ... }`. Consuming components access via `LocalHelpEntries.current?.invoke(id)` or destructure with `val getHelpEntry = LocalHelpEntries.current`.

- **React/Web**: HelpContentProvider is a React function component wrapping React.createContext and Context.Provider. useHelpEntry is a React hook using useContext to retrieve data. The component uses "use client" directive and is appropriate for client-side React patterns (Next.js App Router). Mounted at the document level rather than passed to individual components because some sites replace the shared header entirely, so props to the header would miss them.

- **AppKit / UIKit**: Implement as a singleton service or static property providing a dictionary of help entries. Create `HelpEntry` struct with optional `title: String?`, required `body: String`, and `flavor: HelpFlavor` enum (info, help, new) with info as default. Expose via `class HelpContentService { static let shared = HelpContentService(); var entries: [String: HelpEntry] = [:]; func entry(for id: String) -> HelpEntry? { entries[id] } }`. For environment injection across a view hierarchy, use `@Environment(\.helpEntries)` in SwiftUI or pass the service via `@EnvironmentObject` / `AppDelegate` properties for UIKit, ensuring availability on every view at app startup.

- **WinUI 3**: Implement as a static dictionary in a ResourceDictionary or a static class exposing help entries. Create `public class HelpEntry { public string? Title { get; set; }; public required string Body { get; init; }; public HelpFlavor Flavor { get; set; } = HelpFlavor.Info; }` and `public enum HelpFlavor { Info, Help, New }`. Expose via `public static class HelpContentService { public static Dictionary<string, HelpEntry> Entries { get; } = new(); }` or add entries to a ResourceDictionary keyed by id. Consuming controls access via `{x:Bind local:HelpContentService.Entries[helpId], Mode=OneWay}` for binding, or `HelpContentService.Entries.TryGetValue(id, out var entry)` for code-behind, returning null when not found to suppress rendering.

## Design Decisions

- **String body instead of ReactNode**: The `body` and `title` properties are plain strings, not ReactNode. This allows site configs to be declared in `.ts` files without requiring JSX, accommodating 37 of 41 consuming site configs that are TypeScript modules and cannot hold JSX expressions.
- **Undefined on missing entry instead of throwing**: useHelpEntry returns undefined for unknown ids or when no provider is mounted, rather than throwing an error. This prevents typos in help entry ids from causing white-screen failures, which would cascade to every page since the header component consumes help content on every page.
- **Object.hasOwnProperty check**: The implementation uses Object.hasOwnProperty to exclude inherited properties (e.g., `constructor`, `toString`) from being returned as valid help entries. SiteHelp is a plain object literal and inherits from Object.prototype; a bare index access would return function objects for prototype properties.
- **Document-level provider placement**: HelpContentProvider is mounted at the document level rather than passed to the header component, because four sites replace the shared header entirely via MarketingRootHtml's `header` slot. A prop-based approach would reach the shared header and miss the replaced headers.

## Compliance

Not applicable: HelpContent is a data provider component. Compliance concerns (security, accessibility, data protection) are addressed by consuming components that render the help entries.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.1 | 2026-09-22 | Mike Fullerton | Fix Logging section to reflect actual source behavior; add Platform Notes translation guidance for SwiftUI, Compose, AppKit/UIKit, WinUI 3 |
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
