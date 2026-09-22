---
id: a7cbe25c-53d1-4aec-b76e-59b1c0876728
title: Crud
domain: agenticdevelopertoolkit://recipes/crud
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Data model for CRUD capability permissions (create, read, update, delete)
  with defaults and parent-clamping.
platforms:
- typescript
- web
tags:
- permissions
- access-control
- crud
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Crud

## Overview

The Crud data model represents four independent permission capabilities: create, read, update, and delete. It is used across the platform wherever permission sets are managed — application→schema grants, bucket access grants, and other access-control contexts. The model provides three core capabilities: definition via independent boolean flags, defaults for the most-restrictive and read-only access patterns, and a parent-clamping utility to ensure child permissions never exceed a parent's permissions.

## Behavioral Requirements

- **must-export-interface**: The Crud interface MUST export four boolean properties: `create`, `read`, `update`, `delete`, each representing an independent permission capability.
- **must-provide-key-list**: An exported constant `CRUD_KEYS` MUST be an ordered array of the four capability names in the order: `["create", "read", "update", "delete"]`.
- **must-provide-letter-mapping**: An exported `CRUD_LETTER` object MUST map each key to its canonical single-letter representation: `create` → `"C"`, `read` → `"R"`, `update` → `"U"`, `delete` → `"D"`.
- **must-provide-no-access-default**: A `noAccess()` function MUST return a Crud instance with all four properties set to `false`.
- **must-provide-read-only-default**: A `readOnly()` function MUST return a Crud instance with `read` set to `true` and all other properties set to `false`.
- **must-clamp-child-to-parent**: A `clampToParent(child: Crud, parent: Crud)` function MUST return a new Crud instance where each capability is the logical AND of the child and parent values: if either the child or parent denies a capability, the result MUST deny it.

## Appearance

Not applicable: Crud is a data model with no visual representation.

## States

Not applicable: Crud is a data model representing static permission flags, not an interactive component with state transitions.

## Accessibility

Not applicable: Crud is a data model with no user-facing interface.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| crud-001 | must-export-interface | Import Crud type | Crud type exports create, read, update, delete as boolean properties |
| crud-002 | must-provide-key-list | Access CRUD_KEYS constant | Array equals `["create", "read", "update", "delete"]` in that order |
| crud-003 | must-provide-letter-mapping | Access CRUD_LETTER["create"], CRUD_LETTER["read"], CRUD_LETTER["update"], CRUD_LETTER["delete"] | Returns `"C"`, `"R"`, `"U"`, `"D"` respectively |
| crud-004 | must-provide-no-access-default | Call noAccess() | Returns `{ create: false, read: false, update: false, delete: false }` |
| crud-005 | must-provide-read-only-default | Call readOnly() | Returns `{ create: false, read: true, update: false, delete: false }` |
| crud-006 | must-clamp-child-to-parent | Call clampToParent({ create: true, read: true, update: false, delete: false }, { create: true, read: false, update: true, delete: true }) | Returns `{ create: true, read: false, update: false, delete: false }` |
| crud-007 | must-clamp-child-to-parent | Call clampToParent({ create: false, read: false, update: false, delete: false }, { create: true, read: true, update: true, delete: true }) | Returns `{ create: false, read: false, update: false, delete: false }` |
| crud-008 | must-clamp-child-to-parent | Call clampToParent({ create: true, read: true, update: true, delete: true }, noAccess()) | Returns `{ create: false, read: false, update: false, delete: false }` |

## Edge Cases

- **Null or undefined input**: The interface defines the shape but does not validate input at runtime. Callers MUST ensure they pass valid Crud objects; functions do not perform null checking or type validation.
- **All capabilities true**: When all four properties are `true`, the object represents full access. This state is valid and supported.
- **All capabilities false**: The `noAccess()` function produces this state intentionally as the most-restrictive default. It is valid.
- **Clamping identity (child equals parent)**: When the child and parent are identical, `clampToParent()` MUST return an equivalent object (all values AND'd with themselves) equal in value to the input.
- **Asymmetric parent restrictions**: The parent may restrict any subset of capabilities independently. For example, a parent may allow create and read but deny update and delete, and the clamping function MUST correctly AND each capability.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| create | boolean | false | Whether the create capability is allowed. Set independently of other capabilities. |
| read | boolean | false | Whether the read capability is allowed. Set independently of other capabilities. |
| update | boolean | false | Whether the update capability is allowed. Set independently of other capabilities. |
| delete | boolean | false | Whether the delete capability is allowed. Set independently of other capabilities. |

## Deep Linking

Not applicable: Crud is a data model with no user-facing navigation.

## Localization

Not applicable: Crud is a data model. The canonical single-letter labels (C/R/U/D) are exported via CRUD_LETTER and are localization-agnostic identifiers.

## Accessibility Options

Not applicable: Crud is a data model with no user-facing interface.

## Feature Flags

Not applicable: Crud is a foundational data model used by permission UIs across the platform; its availability is not feature-flagged.

## Analytics

Not applicable: Crud is a data model and does not emit events itself. Analytics for permission changes occur at the UI layer that uses this model.

## Privacy

Not applicable: Crud is a data model representing access permissions, not a data collection mechanism. It does not store, transmit, or retain user data.

## Logging

Not applicable: Crud is a data model with no runtime behavior to log.

## Platform Notes

- **React/Web**: Crud is a TypeScript interface defined in `packages/web/packages/ui/src/components/crud.tsx`. Callers import the interface and utility functions directly. No platform-specific implementation is required beyond TypeScript type checking. The model is used by permission UI components across all web applications.
- **AppKit / UIKit**: Not yet implemented in the native Apple packages. A Swift equivalent would be a Struct mirroring the four boolean properties and equivalent utility functions for noAccess, readOnly, and clampToParent.
- **Compose**: Not yet implemented for Android. A Kotlin data class with the four boolean properties and companion object functions would provide equivalent semantics.
- **WinUI 3**: Not yet implemented for Windows. A C# struct or class with boolean properties and static helper methods would provide equivalent semantics, following C# naming conventions (PascalCase for types and public methods).
- **Shared pattern**: Across all platforms, the four capabilities MUST be independent booleans (not an enum or bitflags type), to ensure each capability can be toggled independently and the parent-clamping logic (AND per-capability) is unambiguous.

## Design Decisions

**Four independent booleans, not bitflags or enum**. The implementation uses four separate boolean properties rather than a bitmask or enum to ensure clarity: each capability is explicitly named and can be read, set, or reasoned about independently. This makes the permission model immediately readable to developers and avoids bit-shifting or mask operations. The tradeoff is slightly larger memory footprint (16 bytes minimum vs. 1 byte for a flags field), but the clarity and debuggability gain is worth it for a permission model used across many features.

**Most-restrictive default is deny-all**. The `noAccess()` function explicitly denies all capabilities. This follows the principle of least privilege: a newly constructed or reset permission should assume no access until explicitly granted. The `readOnly()` convenience function provides a safe default for read-only access patterns, reducing boilerplate in common cases.

**Parent clamping uses AND logic, not override**. The `clampToParent()` function ANDs each child capability with the parent, never allowing a child to exceed the parent. This preserves the permission hierarchy: a child's grant can never be more permissive than the parent allows. The function returns a new object and does not mutate either input, following a functional style.

**No runtime validation**. The interface and functions do not validate that inputs are well-formed Crud objects or that values are boolean. Validation is the caller's responsibility. This keeps the model lightweight and allows it to be used in strict TypeScript contexts where type checking provides the validation.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| typescript-strict | passed | TypeScript strict mode enabled; all four properties are explicitly typed as boolean; no implicit any. |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation from web source `packages/web/packages/ui/src/components/crud.tsx`. |
