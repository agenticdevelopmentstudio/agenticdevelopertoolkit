---
id: 6579e030-0455-453c-81cf-177dae3dd82e
title: Field Value
domain: agenticdevelopertoolkit://recipes/field-value
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Displays field values in their appropriate format based on type, rendering
  URLs, images, addresses, and text content safely.
platforms:
- typescript
- web
tags:
- display
- field-rendering
- data-presentation
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Field Value

## Overview

FieldValue is a presentational component that renders a field's value in the appropriate format based on its type. It handles multiple field types including text, email, phone, URL, image, address, date, select, boolean, multi-select, markdown, and textarea. The component is designed for displaying registry profile data and uses the optional `resolveImageUrl` prop to convert attachment IDs to URLs, returning nothing when values are empty or unresolvable.

## Behavioral Requirements

- **must-render-based-on-type**: Component MUST render different markup for each supported field type: text, date, select, email, phone, url, boolean, multi_select, image, address, markdown, textarea.
- **must-return-null-for-empty-text**: Component MUST return nothing (null) when type is text, date, select, or default case and value converts to an empty string.
- **must-return-null-for-empty-multi-select**: Component MUST return nothing when type is multi_select and array is empty or not an array.
- **must-return-null-for-empty-address**: Component MUST return nothing when type is address and all address parts (line1, line2, city, region, postalCode, country) are empty or falsy.
- **must-render-url-as-link**: Component MUST render type url as an `<a>` element with href set to the string value, with class rp-field__link.
- **must-strip-protocol-from-url**: Component MUST display the URL text with the leading protocol (http:// or https://) removed.
- **must-use-security-attributes-for-url**: Component MUST set rel="noopener noreferrer nofollow" and target="_blank" on URL links.
- **must-render-email-as-text**: Component MUST render type email as plain text in a span with class rp-field__text, NOT as a mailto link, regardless of value visibility settings.
- **must-render-phone-as-text**: Component MUST render type phone as plain text in a span with class rp-field__text, NOT as a tel link.
- **must-render-boolean-as-yes-no**: Component MUST render type boolean as "Yes" when value is truthy, "No" when falsy, in a span with class rp-field__text.
- **must-render-multi-select-as-list**: Component MUST render type multi_select as an unordered list with class rp-field__tags containing list items with class rp-field__tag.
- **must-convert-multi-select-items-to-string**: Component MUST convert each multi_select item to a string before rendering.
- **must-use-image-resolver**: Component MUST use resolveImageUrl prop to convert image attachment IDs to URLs when provided.
- **must-render-nothing-for-unresolvable-image**: Component MUST render nothing (not a broken-image placeholder) when image ID is empty or resolveImageUrl returns null.
- **must-render-image-with-alt-text**: Component MUST render type image as an img element with src from resolveImageUrl and alt set to field.label.
- **must-render-image-with-class**: Component MUST render image with class rp-field__image.
- **must-render-address-as-comma-separated**: Component MUST render type address by joining all non-empty address parts (line1, line2, city, region, postalCode, country) with ", ".
- **must-handle-address-as-object**: Component MUST accept address value as an object with keys line1, line2, city, region, postalCode, country, defaulting to empty object if value is not an object.
- **must-render-markdown-as-text**: Component MUST render type markdown as pre-wrapped text in a paragraph with class rp-field__prose, NOT as HTML.
- **must-render-textarea-as-text**: Component MUST render type textarea as pre-wrapped text in a paragraph with class rp-field__prose, NOT as HTML.
- **must-support-delivery-label-lookup**: Component MUST apply DELIVERY_LABEL mapping (in_person → "In person", virtual → "Virtual", hybrid → "In person or virtual") to text, date, select, and default types before rendering.
- **must-render-unmapped-values-as-is**: Component MUST render the original string value if it is not found in DELIVERY_LABEL mapping.
- **must-use-rp-field-text-class**: Component MUST use class rp-field__text for text, email, phone, boolean, and address field types.
- **must-convert-value-to-string**: Component MUST convert all non-address values to strings using String() coercion.
- **must-handle-null-undefined-values**: Component MUST treat null and undefined values as empty strings using the nullish coalescing operator.

## Appearance

- **Container**: No container styling applied by component; styling delegated to parent or CSS classes.
- **Text rendering**: Text fields use class rp-field__text for styling.
- **Link rendering**: URL fields use class rp-field__link for styling, displayed as clickable text without visible protocol.
- **List rendering**: multi_select renders as unordered list with rp-field__tags (ul) and rp-field__tag (li) classes.
- **Prose rendering**: markdown and textarea render in paragraph elements with class rp-field__prose, preserving whitespace.
- **Image rendering**: Images use class rp-field__image with alt text from field.label.

## States

| State | Appearance change |
|-------|------------------|
| Rendered (value present) | Field markup displays based on type |
| Empty (no value or empty array) | Component returns nothing; no markup rendered |
| Unresolvable (image ID cannot be resolved) | Component returns nothing; no broken-image indicator shown |

## Accessibility

- Role/trait: Component is a display element, not interactive. Links for URLs are keyboard-accessible and indicate external navigation (target="_blank", rel="noopener").
- Label requirements: Image elements use field.label as alt text for screen reader context.
- Text content: All text content is available to assistive technologies; HTML markup in markdown/textarea is rendered as plain text to prevent content injection.
- No interactive controls: Component contains no buttons, form inputs, or keyboard-navigable elements in the default case (URL links are standard navigable elements).

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| field-value-001 | must-render-url-as-link, must-strip-protocol-from-url, must-use-security-attributes-for-url | `{ type: 'url', value: 'https://example.com', label: 'Website' }` | `<a class="rp-field__link" href="https://example.com" rel="noopener noreferrer nofollow" target="_blank">example.com</a>` |
| field-value-002 | must-return-null-for-empty-text | `{ type: 'text', value: '', label: 'Name' }` | `null` |
| field-value-003 | must-render-email-as-text | `{ type: 'email', value: 'user@example.com', label: 'Email' }` | `<span class="rp-field__text">user@example.com</span>` |
| field-value-004 | must-render-phone-as-text | `{ type: 'phone', value: '+1-555-1234', label: 'Phone' }` | `<span class="rp-field__text">+1-555-1234</span>` |
| field-value-005 | must-render-boolean-as-yes-no | `{ type: 'boolean', value: true, label: 'Active' }` | `<span class="rp-field__text">Yes</span>` |
| field-value-006 | must-render-boolean-as-yes-no | `{ type: 'boolean', value: false, label: 'Active' }` | `<span class="rp-field__text">No</span>` |
| field-value-007 | must-render-multi-select-as-list, must-convert-multi-select-items-to-string | `{ type: 'multi_select', value: ['Option A', 'Option B'], label: 'Tags' }` | `<ul class="rp-field__tags"><li class="rp-field__tag" key="Option A">Option A</li><li class="rp-field__tag" key="Option B">Option B</li></ul>` |
| field-value-008 | must-return-null-for-empty-multi-select | `{ type: 'multi_select', value: [], label: 'Tags' }` | `null` |
| field-value-009 | must-use-image-resolver, must-render-image-with-alt-text, must-render-image-with-class | `{ type: 'image', value: 'attachment-123', label: 'Profile Photo' }`, resolveImageUrl returns 'https://cdn.example.com/img/attachment-123.jpg' | `<img class="rp-field__image" src="https://cdn.example.com/img/attachment-123.jpg" alt="Profile Photo" />` |
| field-value-010 | must-render-nothing-for-unresolvable-image | `{ type: 'image', value: 'missing-id', label: 'Photo' }`, resolveImageUrl returns null | `null` |
| field-value-011 | must-render-address-as-comma-separated, must-handle-address-as-object | `{ type: 'address', value: { line1: '123 Main St', city: 'Springfield', country: 'USA' }, label: 'Address' }` | `<span class="rp-field__text">123 Main St, Springfield, USA</span>` |
| field-value-012 | must-return-null-for-empty-address | `{ type: 'address', value: { line1: '', line2: '', city: '', region: '', postalCode: '', country: '' }, label: 'Address' }` | `null` |
| field-value-013 | must-render-markdown-as-text | `{ type: 'markdown', value: '# Hello\nWorld', label: 'Bio' }` | `<p class="rp-field__prose"># Hello\nWorld</p>` |
| field-value-014 | must-render-textarea-as-text | `{ type: 'textarea', value: 'Line 1\nLine 2', label: 'Notes' }` | `<p class="rp-field__prose">Line 1\nLine 2</p>` |
| field-value-015 | must-support-delivery-label-lookup | `{ type: 'text', value: 'in_person', label: 'Delivery' }` | `<span class="rp-field__text">In person</span>` |
| field-value-016 | must-support-delivery-label-lookup, must-render-unmapped-values-as-is | `{ type: 'text', value: 'custom-value', label: 'Delivery' }` | `<span class="rp-field__text">custom-value</span>` |
| field-value-017 | must-handle-null-undefined-values | `{ type: 'text', value: null, label: 'Optional' }` | `null` |
| field-value-018 | must-handle-null-undefined-values | `{ type: 'text', value: undefined, label: 'Optional' }` | `null` |

## Edge Cases

- **Empty value for any type**: When value is empty string, null, or undefined, the component returns nothing unless the type specifically requires string coercion (email, phone render empty strings as `<span class="rp-field__text"></span>`).
- **Non-array value for multi_select**: If value is not an array, it is coerced to an empty array, resulting in null render.
- **Invalid image resolver result**: When resolveImageUrl is provided but returns null, the component renders nothing rather than a broken image.
- **Address as non-object**: If address value is not an object or is null, it defaults to an empty object, resulting in null render.
- **Null resolveImageUrl prop**: When resolveImageUrl prop is not provided, unresolvable IDs are handled using optional chaining (`resolveImageUrl?.(id) ?? null`), resulting in null render.
- **URL with no protocol**: When URL value has no http:// or https:// prefix, the full URL is displayed as-is.
- **Whitespace in multi_select items**: Array items are converted to strings but not trimmed; leading/trailing whitespace is preserved.

## Configuration

Not applicable: FieldValue is a presentational component with no configuration options.

## Deep Linking

Not applicable: FieldValue is a display component with no deep linking behavior.

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| delivery.in_person | "In person" | DELIVERY_LABEL mapping for in_person field value |
| delivery.virtual | "Virtual" | DELIVERY_LABEL mapping for virtual field value |
| delivery.hybrid | "In person or virtual" | DELIVERY_LABEL mapping for hybrid field value |
| boolean.yes | "Yes" | Boolean true rendering |
| boolean.no | "No" | Boolean false rendering |

## Accessibility Options

Not applicable: FieldValue responds to no platform accessibility display options as it is a static display component with no interactive states or dynamic rendering modes.

## Feature Flags

Not applicable: FieldValue has no feature flag configuration.

## Analytics

Not applicable: FieldValue is a display component with no user interaction and does not emit analytics events.

## Privacy

- **Data collected**: No data is collected by this component.
- **Storage**: No data is stored.
- **Transmission**: Image URLs are transmitted to CDN endpoints via img src attribute; all other data is rendered inline and not transmitted.
- **Retention**: No data retention; rendering is ephemeral per page load.

## Logging

Not applicable: FieldValue performs no logging.

## Platform Notes

- **TypeScript/Web**: Source file is `packages/web/packages/registry-profile/src/FieldValue.tsx`. Uses React with className binding for CSS styling. CSS classes (rp-field__link, rp-field__text, rp-field__tags, rp-field__tag, rp-field__image, rp-field__prose) are applied based on field type. The `resolveImageUrl` prop accepts optional resolver; URL security is enforced with standard rel/target attributes.

- **SwiftUI**: Implement as a container view that accepts a `PublicField` and optional image URL resolver. Use a Switch statement or conditional logic to branch on field.type and render appropriate SwiftUI views (Text, Link, List, Image, etc.). For URLs, use Link with security attributes. For images, load asynchronously via the resolver and apply placeholder/error handling. Use SwiftUI's native text styling for text types, font sizes for prose blocks, and layout containers for lists.

- **Compose**: Implement as a composable function accepting field and resolveImageUrl lambda. Use when-expression to branch on field type. Render text types as Text composable with appropriate text styling. URLs as ClickableText with external link icon. Images as AsyncImage with coil loading library and alt text. Address and multi_select as Column/Row layouts. Markdown and textarea as selectable Text to prevent unwanted formatting.

- **AppKit / UIKit**: Implement as a view controller or view subclass that configures NSTextView/UITextView, NSButton/UIButton, or NSImageView/UIImageView based on field type. For URLs, use NSAttributedString/NSAttributedString with link attributes and open in default browser. For images, load asynchronously via provided resolver callback. Use Auto Layout for flexible sizing. Handle null/empty values by hiding or removing views. Set accessibility labels and traits (link, image, button) appropriate to each field type.

- **WinUI 3**: Implement as a user control or data template that branches on field.type using xaml data template selectors or code-behind switch logic. Use TextBlock for text types with TextTrimming for long content. Use Hyperlink for URLs with NavigationTransportedEventArgs to open externally. Use Image control with async image source converter for images. Use ItemsRepeater or ListView for multi_select. Use RichTextBlock for markdown/textarea to display pre-wrapped plain text without HTML parsing. Bind alt text and link attributes to appropriate control properties.

## Design Decisions

The component returns null (renders nothing) rather than empty containers for empty values because an empty profile with missing pictures and unfilled fields reads better than one with visible placeholder UI. This follows the principle that absence of data is cleaner than attempting to gracefully degrade rendering.

Email and phone are rendered as plain text (not `mailto:` or `tel:` links) because visibility of these fields is server-controlled; they only reach the client when published, and the client's responsibility is merely display, not augmentation. Linkifying would create a new attack surface for scraper tools targeting contact information by CSS selector.

Markdown and textarea are rendered as pre-wrapped plain text (not HTML) because the component runs on untrusted sites the registry does not control. Safe markdown-to-HTML conversion cannot be guaranteed in this context, so the conservative choice is to render all markup as literal text.

The DELIVERY_LABEL mapping is hardcoded rather than externalized as it is a fixed enumeration tied to the specific registry field type "delivery mode" and is not a localization concern — it is a semantic transformation of field values specific to this component's domain.

## Compliance

Not applicable: FieldValue has no platform-specific compliance requirements and contains no authentication, data persistence, or external service integration.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
