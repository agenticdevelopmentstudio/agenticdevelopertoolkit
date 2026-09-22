---
id: d9df7837-8e06-460a-a703-60441d74eeed
title: Categories and Tags
domain: agenticdevelopercookbook://ingredients/categories-and-tags
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A two-row composition pairing a single category selection with a set of tags,
  sharing label alignment.
platforms:
- web
tags:
- classification
- form-fields
depends-on: []
related: []
references: []
---

# Categories and Tags

## Overview

The Categories and Tags component is a composition of two independent field components—a category field and a tag set field—arranged vertically in a shared table-like layout. The component coordinates the label alignment between the two rows by sharing a CSS custom property, ensuring visual consistency when captions are right-aligned. Each field maintains its own state; the component manages neither category nor tag data, only layout and disabled state.

## Behavioral Requirements

- **must-compose-two-fields**: Component MUST render `CategoryField` with `layout="inline"` and `TagSetField` with `layout="inline"` vertically stacked.
- **must-share-label-width**: Component MUST set the `--apt-field-label-w` CSS custom property on its root element to ensure both rows' label columns have equal width and right edges align.
- **must-accept-category-data**: Component MUST accept a `category` object containing `label`, `noun`, `options`, `value`, and `onChange`; it MUST pass these to `CategoryField`.
- **must-accept-category-nodes**: Component MUST accept an optional `category.nodes` array and pass it to `CategoryField` for breadcrumb and rename behavior.
- **must-accept-category-rename**: Component MUST accept an optional `category.onRename` callback and pass it to `CategoryField`.
- **must-accept-tags-data**: Component MUST accept a `tags` object containing `label`, `noun`, `options`, `value` (array), and `onChange`; it MUST pass these to `TagSetField`.
- **must-disable-both-rows**: Component MUST pass the `disabled` prop (default `false`) to both `CategoryField` and `TagSetField`.
- **must-forward-classname**: Component MUST accept and merge a `className` prop into its root element using the `cn()` utility.
- **must-use-gap-between-rows**: Component MUST apply a `gap-3` class to create vertical spacing between the two rows.
- **must-render-data-slot**: Component MUST set `data-slot="categories-and-tags"` on its root element.
- **must-require-category-label-noun**: Component MUST NOT provide defaults for `category.label` or `category.noun`; the host MUST supply these.
- **must-require-tags-label-noun**: Component MUST NOT provide defaults for `tags.label` or `tags.noun`; the host MUST supply these.

## Appearance

- **Container**: Flex column layout, full width, no fixed height.
- **Gap between rows**: 12px (Tailwind `gap-3`).
- **Label column width**: Shared via CSS custom property `--apt-field-label-w`, overridable by host via `className`.
- **Child rows**: Both use inline layout as defined by `CategoryField` and `TagSetField`.
- **No border, shadow, or background**: The component has no intrinsic visual styling; appearance is inherited from child components.

## States

Not applicable: This component is a layout container with no interactive states of its own. State behavior (e.g., disabled, focus, loading) is defined by the child components `CategoryField` and `TagSetField`.

## Accessibility

Not applicable: Accessibility is delegated to the child components `CategoryField` and `TagSetField`. The component contributes no interactive controls or visible labels of its own.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| cat-tag-001 | must-compose-two-fields, must-render-data-slot | Render with category and tags props | Root element renders with `data-slot="categories-and-tags"` and contains both `CategoryField` and `TagSetField` children |
| cat-tag-002 | must-share-label-width | Render with both rows | Root element has `--apt-field-label-w` custom property set via inline style or className |
| cat-tag-003 | must-accept-category-data | `category.label="Type"`, `category.noun="type"`, `category.options=["A","B"]`, `category.value="A"`, `category.onChange=spy` | `CategoryField` receives all category props and onChange fires on user selection |
| cat-tag-004 | must-accept-category-nodes | `category.nodes=[{...}]` present | `CategoryField` receives nodes prop |
| cat-tag-005 | must-accept-category-rename | `category.onRename=spy` present | `CategoryField` receives onRename callback |
| cat-tag-006 | must-accept-tags-data | `tags.label="Tags"`, `tags.noun="tag"`, `tags.options=["x","y"]`, `tags.value=["x"]`, `tags.onChange=spy` | `TagSetField` receives all tags props and onChange fires on user selection |
| cat-tag-007 | must-disable-both-rows | `disabled=true` | Both `CategoryField` and `TagSetField` receive `disabled={true}` |
| cat-tag-008 | must-forward-classname | `className="custom-class"` | Root element has `custom-class` merged into its classList via `cn()` |
| cat-tag-009 | must-use-gap-between-rows | Render with both rows | Root element has `gap-3` class applied |
| cat-tag-010 | must-require-category-label-noun | `category.label` undefined, `category.noun` undefined | Component renders but passes `undefined` to `CategoryField`; host must supply these values |
| cat-tag-011 | must-require-tags-label-noun | `tags.label` undefined, `tags.noun` undefined | Component renders but passes `undefined` to `TagSetField`; host must supply these values |

## Edge Cases

- **Empty category options list**: When `category.options` is an empty array, `CategoryField` receives it and determines rendering behavior; this component does not filter or default it.
- **Empty tags options list**: When `tags.options` is an empty array, `TagSetField` receives it and determines rendering behavior; this component does not filter or default it.
- **Empty category value**: When `category.value=""` (empty string), the component passes it through as-is; no category is selected.
- **Empty tags value array**: When `tags.value=[]` (empty array), no tags are selected; the component passes it through as-is.
- **Missing category.nodes**: When `category.nodes` is undefined or omitted, `CategoryField` receives undefined and operates without breadcrumb/rename support; this is valid.
- **Missing category.onRename**: When `category.onRename` is undefined or omitted, `CategoryField` receives undefined and rename behavior is disabled; this is valid.
- **Disabled state with active user interaction**: When `disabled=true`, both rows are marked disabled but still render; child components determine whether clicks or keyboard input are accepted.
- **className override of label width**: When host passes `className` containing a `--apt-field-label-w` override, the override MUST take precedence via the `cn()` merge order.

## Configuration

Not applicable: This component accepts props only; it does not expose configuration via environment variables, feature flags, or external settings.

## Deep Linking

Not applicable: This component is a form field, not a standalone route target. Deep linking behavior is the responsibility of the host application.

## Localization

Not applicable: The component does not emit any user-facing strings; all text (`category.label`, `category.noun`, `tags.label`, `tags.noun`) is supplied by the host and assumed to be localized before being passed to the component.

## Accessibility Options

Not applicable: Accessibility option handling (Reduce Motion, Increase Contrast, Differentiate Without Color) is delegated to child components `CategoryField` and `TagSetField`.

## Feature Flags

Not applicable: This component does not use feature flags. Feature flag gating is the responsibility of the host application.

## Analytics

Not applicable: This component emits no analytics events. Event tracking is delegated to the child components `CategoryField` and `TagSetField`, and to the host's application-level analytics.

## Privacy

Not applicable: This component stores no data, collects no user information, and transmits nothing. Data handling is the responsibility of the host application.

## Logging

Not applicable: This component performs no logging. Logging is delegated to child components and the host application.

## Platform Notes

- **React/Web**: Source implementation at `packages/web/packages/ui/src/blocks/categories-and-tags.tsx`. Uses Tailwind CSS (`flex`, `w-full`, `flex-col`, `gap-3`), the `cn()` utility for classname merging, and the `FIELD_LABEL_GROUP_CLASS` constant exported from the same package for shared label-width management. The component is marked "use client" for React Server Components compatibility.
- **SwiftUI**: Start with a `VStack(spacing: 12)` to replicate the flex column and gap. Compose a `CategoryField` view and a `TagSetField` view as children. Use a shared environment value (e.g., `@Environment(\.labelColumnWidth)`) to synchronize label widths across both rows. Supply all label and noun strings via bindings from the host, matching the TypeScript interface exactly.
- **Compose**: Use a `Column(verticalArrangement = Arrangement.spacedBy(12.dp))` for the flex column and gap. Compose a `CategoryField` and `TagSetField` as children. Use a mutable state holder or shared composition local to synchronize label widths. Accept `label` and `noun` strings as parameters and pass them through; do not assume defaults.
- **AppKit / UIKit**: Stack a category control and a tag control vertically using `NSStackView` (AppKit) or `UIStackView` (UIKit) with spacing 12 and axis `.vertical`. Use a shared width constraint or layout guide to align labels. Accept label and noun strings as view configuration parameters, mirroring the TypeScript interface.
- **WinUI 3**: Use a `StackPanel` with `Orientation="Vertical"` and `Spacing=12` (theme units). Compose a category control and tag control as children. Synchronize label column width using a shared `double` property or `x:Bind` to a view model's label width value. All label and noun strings MUST be sourced from the view model; do not hard-code or use resource strings without host intent.

## Design Decisions

1. **No default label or noun values**: The component explicitly requires the host to supply `category.label`, `category.noun`, `tags.label`, and `tags.noun`. This design avoids embedding assumptions about the semantic meaning of the fields (e.g., whether a field is for "categories" in a research system vs. "types" in a work-tracking system). The host controls all user-facing language.

2. **CSS custom property for label alignment**: Rather than accepting a fixed `labelWidth` prop, the component uses `--apt-field-label-w` to share alignment logic with sibling components (e.g., `document-identity-field.tsx`) that use the same constant. This avoids duplication and ensures consistency where the same alignment strategy is applied elsewhere in the UI.

3. **Single `disabled` prop for both rows**: Both fields are disabled or enabled together because they edit a single logical draft or record. This prevents inconsistent states (e.g., category editable but tags read-only), simplifying the host's state management.

4. **No filtering or defaulting of options or values**: The component passes `options` and `value` through to child components without transformation. Empty arrays, undefined values, and missing optional properties are all valid and flow through as-is. This keeps the component transparent and delegates validation and defaulting to the host.

## Compliance

Not applicable: This component is a layout composition with no inherent compliance requirements. Compliance concerns (accessibility standards, security policies, data handling) are the responsibility of the host application and the child components it composes.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation |
