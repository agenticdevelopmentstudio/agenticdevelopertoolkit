---
id: 85ce8c4b-5233-48af-9268-30cddd4747f9
title: Accordion
domain: agenticdevelopercookbook://ingredients/accordion
type: ingredient
version: 1.1.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Stacked collapsible sections with clickable triggers and expanding/collapsing
  panels indicated by a rotating chevron.
platforms:
- web
tags:
- ui
- collapsible
- expansion
depends-on: []
related: []
references: []
---

# Accordion

## Overview

An accordion is a container of vertically stacked collapsible sections. Each section consists of a clickable trigger (header) and a hidden or visible panel (content area). The accordion exports four composable components: `Accordion` (root container), `AccordionItem` (section wrapper), `AccordionTrigger` (clickable header), and `AccordionPanel` (collapsible content area). Accordions compress long-form content into a scannable, space-efficient interface, allowing users to reveal only the information they need.

## Behavioral Requirements

- **must-export-four-components**: The accordion MUST export four components as named exports: `Accordion`, `AccordionItem`, `AccordionTrigger`, and `AccordionPanel`.
- **must-render-chevron-icon**: The `AccordionTrigger` MUST render a ChevronDown icon immediately after the trigger's child content, positioned to the right of the label.
- **must-rotate-chevron-on-open**: The chevron icon MUST rotate 180 degrees when its accordion panel is open (via CSS transform: rotate(180deg)), and MUST return to 0 degrees when closed.
- **must-apply-item-border**: The `AccordionItem` component MUST apply a bottom border between sections (border-b border-apt-border).
- **must-wrap-panel-with-padding**: The `AccordionPanel` component MUST wrap its children in a div element with bottom padding (pb-3), creating vertical spacing between content and the next trigger.
- **must-use-base-ui-primitives**: All accordion components MUST delegate expand/collapse logic and ARIA attribute management to `@base-ui/react/accordion` primitives (AccordionPrimitive.Root, Item, Trigger, Panel).
- **must-set-data-slot-attributes**: The accordion MUST set `data-slot` attributes on rendered elements: "accordion" on root, "accordion-item" on items, "accordion-trigger" on triggers, "accordion-panel" on panels.
- **must-forward-props-to-primitives**: Each component MUST forward arbitrary props (via spread operator) to its corresponding primitive, allowing consumers to extend behavior and styling.
- **must-support-classname-override**: Each component MUST accept a `className` prop and merge it with default classes using the `cn()` utility, allowing consumers to add or override styles.
- **should-provide-hover-feedback**: The trigger SHOULD change text color on hover (hover:text-apt-text) to indicate interactivity.
- **should-provide-focus-feedback**: The trigger SHOULD change text color when focused (focus-visible:text-apt-text) to indicate keyboard navigation.

## Appearance

- **Corner radius**: None (default; overridable via className prop)
- **Padding**: Trigger: 12px vertical (py-3), content-driven horizontal (no explicit left/right); Panel wrapper: 12px bottom (pb-3)
- **Font**: Trigger: 14px size (text-sm), 500 weight (font-medium); Panel: 14px size (text-sm)
- **Background**: Transparent (default; inherited from parent)
- **Foreground/Text**: Trigger default: apt-text; Trigger muted (chevron): apt-text-muted; Panel: apt-text-muted
- **Border**: Item: 1px solid bottom (border-b border-apt-border); Trigger: none; Panel: none
- **Shadow**: None
- **Min/Max size**: Chevron icon: 16×16px (size-4); no min/max constraints on root

## States

| State | Appearance change |
|-------|-------------------|
| Default (closed) | Chevron points downward (0 degrees); panel content hidden by overflow-hidden; trigger text in apt-text color |
| Hover | Trigger text transitions to apt-text color (focus/hover/default convergence) |
| Focus (keyboard navigation) | Trigger text transitions to apt-text color; outline-none applied (outline delegated to primitive) |
| Open/Expanded | Chevron rotates to 180 degrees (points upward); panel transitions open via overflow hidden animation; panel content visible |
| Closed/Collapsed | Chevron at 0 degrees (points downward); panel hidden via overflow-hidden; animation applies on close |

## Accessibility

- **Role/trait**: Trigger MUST be a button (delegated to AccordionPrimitive.Trigger). Panel MUST be a region (delegated to AccordionPrimitive.Panel).
- **Label requirements**: Trigger child content (text) serves as the accessible name for the accordion section. Screen readers announce this text when the trigger is focused.
- **State announcement**: The aria-expanded attribute on the trigger MUST reflect the panel's open/closed state and MUST be announced by screen readers.
- **Keyboard navigation**: Trigger MUST be keyboard accessible and respond to Enter and Space keys to toggle the panel (delegated to AccordionPrimitive.Trigger).
- **Minimum tap target**: Trigger touch target MUST be at least 44×44px (WCAG 2.1 AA). Actual implementation depends on container padding and layout; current CSS (py-3 + text-sm) should meet this threshold.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| accordion-001 | must-export-four-components | `import { Accordion, AccordionItem, AccordionTrigger, AccordionPanel } from "..."` | All four components are named exports; no errors on import |
| accordion-002 | must-render-chevron-icon | Render `<AccordionTrigger>Section Title</AccordionTrigger>` | ChevronDown icon renders after "Section Title" text |
| accordion-003 | must-rotate-chevron-on-open | Open accordion panel via click or BaseUI control | Chevron element has CSS transform: rotate(180deg) applied |
| accordion-004 | must-apply-item-border | Render `<AccordionItem>...</AccordionItem>` with inspect element | Element has class border-b and border-apt-border; bottom border is visible |
| accordion-005 | must-wrap-panel-with-padding | Render `<AccordionPanel>Content</AccordionPanel>`; inspect DOM | Panel contains inner div with pb-3 class; content wrapped with 12px bottom padding |
| accordion-006 | must-use-base-ui-primitives | Inspect React component tree via DevTools | AccordionPrimitive.Root, Item, Trigger, Panel present in component tree |
| accordion-007 | must-set-data-slot-attributes | Inspect rendered HTML elements | Root has data-slot="accordion"; items have data-slot="accordion-item"; triggers have data-slot="accordion-trigger"; panels have data-slot="accordion-panel" |
| accordion-008 | must-forward-props-to-primitives | Pass `disabled` or `value` prop to AccordionPrimitive components | Props are passed through without error; behavior is delegated to primitive |
| accordion-009 | must-support-classname-override | Render `<AccordionTrigger className="bg-red-500">Label</AccordionTrigger>` | Custom bg-red-500 class is applied; trigger has red background |
| accordion-010 | should-provide-hover-feedback | Hover over trigger with mouse | Trigger text color transitions smoothly to hover:text-apt-text |
| accordion-011 | should-provide-focus-feedback | Tab to trigger and focus it | Trigger text color transitions to focus-visible:text-apt-text |

## Edge Cases

- **Empty trigger text**: If `AccordionTrigger` receives no children or null children, chevron MUST still render and rotate on panel open. Screen reader announcement is degraded but component does not error.
- **Empty panel content**: If `AccordionPanel` receives no children or null children, wrapper div with pb-3 still renders. Component does not error.
- **Null or undefined className**: If className prop is null, undefined, or omitted, default classes MUST apply via `cn()` utility. No runtime error occurs.
- **Conflicting className properties**: If className prop contains a Tailwind class that conflicts with a default class (e.g., py-4 vs. py-3), the merge order in `cn()` determines precedence. Consumers who specify a class take precedence over defaults.
- **Multiple panels open simultaneously**: Not applicable — `@base-ui/react/accordion` primitives control multi-open behavior via props; the wrapper components do not enforce single-open-only, delegation is complete to primitives.
- **Very long trigger text**: No special handling; text wraps naturally. Chevron remains positioned to the right via flex layout (flex flex-1 items-center justify-between).
- **Very long panel content**: No special handling; panel height is not constrained. Consumers can add max-height and overflow-y: auto via className if needed.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `className` | string | undefined | Additional CSS classes merged with defaults via cn() utility; allows customization of appearance and layout |
| `children` | ReactNode | undefined | Content rendered inside: trigger text for AccordionTrigger, panel content for AccordionPanel |
| `...props` | any | — | Arbitrary props forwarded to underlying AccordionPrimitive components |

## Deep Linking

Not applicable: Accordion is a UI component with no built-in deep linking support. Deep linking to accordion sections is handled by parent page/routing logic if needed.

## Localization

Not applicable: Component contains no hardcoded user-facing strings. All text (trigger labels, panel content) is provided by consumers via children prop.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | NEEDS REVIEW: Component applies transitions (transition-colors on trigger, transition-transform on chevron) without respecting prefers-reduced-motion media query. An implementation MUST wrap the transition classes in a conditional that checks `prefers-reduced-motion: reduce` and removes transitions when motion is reduced. Evidence would be: component updated to check @media (prefers-reduced-motion: reduce) or integration with design system motion tokens that respect the preference. |
| Increase Contrast | Design system color tokens (apt-text, apt-text-muted, apt-border) SHOULD be defined with sufficient contrast to meet WCAG 2.1 AA standards (4.5:1 for text). Component itself does not implement special handling for prefers-contrast media query; contrast depends on token values. |
| Differentiate Without Color | Chevron icon direction (down = closed, up = open) provides state indication independent of color. The aria-expanded attribute provides semantic indication for assistive technology. |

## Feature Flags

Not applicable: Feature flag support is not a concern of the accordion component itself. If the design system requires feature-gating accordion, consumers can wrap the component or control its visibility via app-level feature flag logic.

## Analytics

Not applicable: Analytics event tracking is not a component-level concern. Consumers can attach custom event handlers via props passed to AccordionPrimitive components to emit analytics events (e.g., on expand, collapse, focus).

## Privacy

Not applicable: Component collects no user data and transmits nothing. Consumers using the accordion do not expose private information through the component itself.

## Logging

Not applicable: Logging is a consumer concern. The underlying @base-ui/react/accordion library may emit logs; consumers can enable logging if needed for debugging.

## Platform Notes

- **React/Web**: Accordion wraps `@base-ui/react/accordion` primitives and applies Tailwind CSS styling. Exported as "use client" (client-side rendering). The component is compositional: consumers assemble Root, Item, Trigger, and Panel subcomponents to build accordion structures. Styling is applied via Tailwind classes and cn() for merge. The ChevronDown icon is from lucide-react.

- **SwiftUI**: Start from DisclosureGroup or a custom view with @State for open/closed. Recreate chevron rotation using a rotation effect (.rotationEffect) on Image(systemName: "chevron.down"). Wrap each item in a VStack with dividers between sections. Apply padding using .padding(.vertical, 12) and .padding(.horizontal) modifiers. Text styling via .font(.system(size: 14, weight: .medium)). Respect motion preferences by wrapping rotation animations in `if !accessibilityReduceMotionEnabled { ... }`.

- **Compose**: Use LazyColumn or Column for the container and Surface or Card for each item. Implement expand/collapse via state and AnimatedVisibility or animateContentSize for panel animation. Render a rotating Icon (Icons.Default.ArrowDown) with rotationZ = if (isOpen) 180f else 0f. Use Spacer and Padding for spacing. Font styling via fontSize and fontWeight parameters. Conditionally apply animations based on the LocalMotionSettings or animate conditionally when prefers-reduced-motion is not set.

- **UIKit / AppKit**: For UIKit, use UITableViewController or UICollectionViewController with custom cells for trigger and collapsible panels. Implement disclosure via state callbacks and setContentOffset or similar scroll logic. Use CABasicAnimation for chevron rotation (CABasicAnimation(keyPath: "transform.rotation.z")). Disable animations when UIAccessibility.isReduceMotionEnabled is true. For AppKit, use NSOutlineView or NSViewController with collapsible subviews. Both require manual chevron rotation animation and state management, with motion preference checks to conditionally apply animations.

- **WinUI 3**: Implement using ItemsControl with Expander control (which provides native expand/collapse functionality and chevron). Set Expander.Header to trigger content and Expander.Content to panel content. Use StackPanel set to Vertical for the item container. Apply borders via Border.Stroke property. Styling via Foreground (text color), Background, and FontSize properties. WinUI's Expander natively provides ARIA attributes (aria-expanded, button role), keyboard support (Enter/Space), and rotation animation on the toggle button. When implementing custom animations, check UISettings.AnimationsEnabled or SystemParameters.ReduceMotionEnabled to conditionally apply motion.

## Design Decisions

1. **Four-Component Export Pattern**: Exporting Accordion, AccordionItem, AccordionTrigger, and AccordionPanel as separate components follows the composition pattern established by @base-ui/react/accordion and allows maximum flexibility for consumers. Consumers can customize each part independently rather than accepting a monolithic component.

2. **Chevron Rotation Animation**: The chevron rotates 180 degrees to indicate open/closed state. This is a recognizable UI pattern and provides clear visual feedback. The rotation is applied via CSS transform (rotate-180 class) on the icon element, which is smoother than swapping images.

3. **Bottom Padding on Panel**: Panel content is wrapped in a div with pb-3 (12px) bottom padding to create visual breathing room between the panel content and the next item's border/trigger. This is a fixed spacing decision; consumers can override via className prop.

4. **Data-Slot Attributes**: Setting data-slot on each component enables predictable CSS targeting (via `[data-slot="accordion-trigger"]` selectors) and makes automated testing more stable, decoupling tests from class names which may change.

5. **Delegation to @base-ui/react/accordion**: All expand/collapse logic, ARIA attribute management, and keyboard handling is delegated to the underlying primitive library. This keeps the wrapper lightweight and ensures WCAG compliance is maintained as the primitive is updated.

6. **CSS Transitions**: Trigger text and chevron use transition-colors and transition-transform for smooth visual feedback. This may not respect prefers-reduced-motion; consumers using high-motion-sensitivity accessibility settings should provide media query overrides or disable transitions conditionally.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| Four components exported and callable | Passed | Structure |
| Chevron icon renders | Passed | Appearance |
| Chevron rotates on expand | Passed | Appearance |
| ARIA attributes delegated to primitive | Passed | Accessibility |
| Keyboard navigation delegated to primitive | Passed | Accessibility |
| Focus-visible state applied | Passed | Accessibility |
| Bottom border applied to items | Passed | Appearance |
| Panel content wrapped with padding | Passed | Appearance |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.1.0 | 2026-09-22 | Claude Haiku 4.5 | Revise: clarify Reduce Motion gap as genuine accessibility concern; update Platform Notes with motion preference checks for all platforms |
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from web source |
