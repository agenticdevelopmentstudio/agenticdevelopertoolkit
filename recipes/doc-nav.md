---
id: ef7191ff-63a9-442a-b6d0-f8452a0aa1d6
title: Document Navigation Tree
domain: agenticdevelopercookbook://ingredients/doc-nav
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Hierarchical document navigation tree with collapsible sections, adaptive
  desktop/mobile layouts, and active page tracking.
platforms:
- web
tags:
- navigation
- tree
- document-structure
depends-on: []
related: []
references: []
---

# Document Navigation Tree

## Overview

A hierarchical navigation component that renders document structure as a tree with three distinct node types: collapsible sections (depth 0), navigable branches (depth 1+), and leaf pages with optional inline heading links. Adapts layout from a sticky desktop sidebar to a mobile slide-over drawer; tracks active page via route path and manages section expansion state independently of navigation. Used in document hosting contexts where readers need to orient themselves within a multi-section document tree and navigate quickly between pages and heading anchors.

## Behavioral Requirements

- **must-render-sections**: Component MUST render top-level section nodes as collapsible controls with mono uppercase labels; clicking the chevron control MUST toggle that section's visibility.
- **must-render-branches**: Component MUST render branch nodes (children with their own children) as navigable links that always appear when their parent section is expanded, without a second collapse control.
- **must-render-leaves**: Component MUST render leaf nodes (children with no further children) as navigable links.
- **must-render-headings**: Component MUST render a leaf node's inline page headings (from `node.headings` array) as a sub-list of links indented beneath that leaf.
- **must-track-active-page**: Component MUST accept an `activePath` prop and highlight the current page link (using `aria-current="page"` and visual styling) when `activePath` matches the node's `href`.
- **must-track-ancestor**: Component MUST apply ancestor styling to branch nodes whose `href` is a prefix of `activePath` (e.g., `/docs/guides/` is an ancestor of `/docs/guides/getting-started`).
- **must-support-heading-scrolling**: When a heading link's page is already active (`activePath` matches the leaf's `href`), clicking the heading MUST prevent default navigation and scroll the target heading element into view smoothly; when the page is not active, the link MUST navigate normally.
- **must-set-hash-on-heading-scroll**: When scrolling to a heading on the active page, component MUST update `window.history.replaceState` to set the URL hash without triggering navigation.
- **must-preserve-section-state-on-route-change**: Section expansion state MUST NOT change when `activePath` updates; it MUST only change when the toggle control is clicked.
- **must-manage-drawer-open-state**: Component MUST accept an `open` prop to control drawer visibility and MUST call `onClose` when the scrim backdrop is clicked or the close button is clicked.
- **must-initialize-expanded-sections**: On mount, component MUST set expanded sections to include all sections whose `href` matches `activePath` or is a prefix of it.
- **must-order-children**: Component MUST render a node's children in a fixed order: leaf nodes first, then branch nodes; the order does NOT follow the input array order.
- **must-distinguish-link-component**: Component MUST accept a `LinkComponent` prop and use it for all navigation links; if omitted, MUST default to a plain `<a href>` element.
- **must-support-top-and-bottom-links**: Component MUST render fixed navigation rows (`topLinks` and `bottomLinks`) above and below the tree respectively, each behind its own divider rule.
- **must-render-headings-only-on-leaves**: Inline page headings MUST only render when present on leaf nodes; branch nodes MUST NOT render heading sub-lists.

## Appearance

- **Desktop layout**: Sticky aside, positioned at `top: var(--adh-header-height, 3.5rem)`, width `24rem` (expandable to `32rem` at `xl` breakpoint), right-aligned border, `overflow-y-auto` with scrolling independent of viewport
- **Mobile layout**: Slide-over drawer positioned at `left: 0`, width `18rem`, appearing on top of a semi-transparent scrim (`bg-black/50`)
- **Section labels**: Font-mono, text-xs, font-medium, uppercase, tracking-widest, color `var(--color-accent)`, gray text transitioning on hover
- **Branch and leaf links**: Text-sm for branches/leaves, text-xs for headings; secondary text color by default, primary on hover; selected/ancestor links use semibold or medium weight
- **Selected indicator**: Vertical accent bar (1px width, `var(--color-accent)` color) at left edge of selected link
- **Indentation**: Links and headings use consistent padding-inline-start (0.875rem); nested lists add 0.875rem left margin per level
- **Dividers**: Border-top line (1px, `var(--color-border-subtle)` above fixed rows, `var(--color-border)` within tree levels
- **No text wrapping (desktop)**: Desktop nav uses `whitespace-nowrap` with `overflow-x-auto`; mobile allows wrapping

## States

| State | Appearance change |
|-------|-------------------|
| Section expanded | Chevron icon rotated 90°, section's child list visible |
| Section collapsed | Chevron icon at 0°, section's child list hidden |
| Link selected (exact match) | Semibold weight, primary text color, left accent bar |
| Link ancestor (prefix match) | Medium weight, primary text color, no accent bar |
| Link hover | Text color transitions to primary |
| Link default | Secondary text color |
| Heading link (not on page) | Text-xs, dim text color, appears as nested link |
| Heading link (on page, hover) | Text-xs, secondary text color, scrolls instead of navigating |
| Drawer open | Overlay and drawer visible, scrim blocks pointer events |
| Drawer closed | Drawer hidden, page content under aside fully visible |

## Accessibility

- **Navigation landmark**: Component renders a `<nav>` element (both desktop aside and mobile drawer use semantic nav)
- **Aria-current**: Selected links MUST carry `aria-current="page"` to announce to assistive technology
- **Section collapse button**: Collapse control MUST have `aria-expanded={true|false}` and an accessible label (`aria-label="Expand/Collapse [section name]"`)
- **Scrim not announced**: Scrim overlay carries `aria-hidden="true"` and is not focusable, ensuring screen readers do not announce it as a control
- **Drawer dismiss button**: Close button MUST have `aria-label` (e.g., "Close navigation")
- **Heading links nested under leaf**: Heading links appear in a nested list and inherit semantic structure from the leaf's `<li>` parent
- **Color not sole indicator**: Selected state uses both bold weight AND accent bar, not color alone
- **Contrast**: All text must meet WCAG AA contrast requirements against their backgrounds
- **Minimum touch target**: Section collapse button MUST be at least 44×44px (achieved via padding); links have `py-0.5` (0.125rem) vertical padding, totaling roughly 24-28px height and relying on spacing rather than individual link height for target size

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| doc-nav-001 | must-render-sections | nodes with depth 0 | Sections render as collapsible divs with chevron button, mono uppercase label, and aria-expanded attribute |
| doc-nav-002 | must-render-branches | node with children that have children | Branch links render without collapse control; appear when parent section is expanded |
| doc-nav-003 | must-render-leaves | node with children that have no further children | Leaf links render; if node has headings array, render heading sub-list below leaf |
| doc-nav-004 | must-track-active-page | activePath="/docs/guides" with matching node href | Link styled with semibold, primary color, and left accent bar; aria-current="page" set |
| doc-nav-005 | must-track-ancestor | activePath="/docs/guides/getting-started" with ancestor node href="/docs/guides/" | Ancestor link styled with medium weight and primary color; no accent bar |
| doc-nav-006 | must-support-heading-scrolling | activePath matches leaf, heading link clicked | preventDefault called, target element scrolled into view smoothly, history.replaceState called with hash |
| doc-nav-007 | must-support-heading-scrolling | activePath does NOT match leaf, heading link clicked | Link navigates normally (default behavior not prevented) |
| doc-nav-008 | must-preserve-section-state-on-route-change | Section expanded, activePath changed | Expanded state unchanged; only toggle control changes it |
| doc-nav-009 | must-manage-drawer-open-state | open=true, onClose callback provided | Drawer rendered and visible; clicking scrim calls onClose; clicking close button calls onClose |
| doc-nav-010 | must-initialize-expanded-sections | activePath="/section1/page" on mount | Sections containing that page auto-expanded; other sections collapsed |
| doc-nav-011 | must-order-children | node with mixed leaves and branches in arbitrary input order | Leaves rendered first, then branches, regardless of input order |
| doc-nav-012 | must-distinguish-link-component | LinkComponent prop with custom link component provided | Custom component used for all links; defaulting to `<a href>` if omitted |
| doc-nav-013 | must-support-top-and-bottom-links | topLinks array with entries | Fixed rows render above tree with divider below them |
| doc-nav-014 | must-support-top-and-bottom-links | bottomLinks array with entries | Fixed rows render below tree with divider above them |
| doc-nav-015 | must-render-headings-only-on-leaves | branch node with headings array | Heading sub-list does NOT render; headings only on leaves |

## Edge Cases

- **Empty children array**: If `node.children` is undefined or empty array, node is treated as a leaf; no branch or heading sub-list renders.
- **No headings**: If `node.headings` is undefined or empty array, NavHeadings returns null and no heading sub-list renders.
- **Heading element not found**: If `document.getElementById(heading.id)` returns null when scrolling, the scroll is skipped and hash is not set; link click event is still prevented.
- **Active path not in tree**: If `activePath` does not match any node `href`, no links styled as selected; section expansion state still initialized based on prefix matches.
- **Circular or malformed tree**: Component does not validate tree structure; if a node's href appears as a prefix of itself (invalid) or circular parent-child relationships exist, behavior is undefined; tree MUST be acyclic and well-formed by the host.
- **Very deep nesting**: No hard depth limit; performance depends on tree size and React reconciliation; excessively deep trees (50+ levels) may encounter scroll performance issues.
- **Drawer open at `lg` breakpoint**: Desktop nav is `hidden lg:block`; drawer renders at all breakpoints; both rendering simultaneously with `open=true` at `lg+` creates duplicate nav in DOM but only drawer is visible to user.
- **Route change during scroll**: If `activePath` changes while `element.scrollIntoView()` is in progress, the scroll completes but may scroll to an element that is no longer "on page" in the component's view (rare edge case, depends on timing).
- **Missing active page headings**: If `activePath` matches a node but the node has no `headings` array, component renders the leaf link without heading sub-list; this is correct behavior.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| nodes | HdvNavNode[] | required | Top-level sections of the document tree |
| activePath | string | required | Current route path; used to highlight active link and expand parent sections |
| topLinks | DocNavTopLink[] | [] | Fixed navigation rows above the tree |
| bottomLinks | DocNavTopLink[] | [] | Fixed navigation rows below the tree |
| LinkComponent | React component | DefaultDocLink (a href) | Router link component for all navigation links |
| open | boolean | false | Controls drawer visibility; only affects mobile drawer |
| onClose | () => void | undefined | Callback when drawer is dismissed by scrim or close button |
| title | ReactNode | "Navigation" | Drawer heading text |
| closeLabel | string | "Close navigation" | aria-label for drawer close button |
| className | string | undefined | CSS class applied to desktop aside only; not copied to drawer |
| ...rest | HTMLAttributes | {} | Standard HTML attributes (id, data-*, etc.) applied to desktop aside only |

## Deep Linking

Not applicable: this component is a navigation chrome, not a linkable destination. Page URLs are determined by the document tree nodes' `href` props, which the host provides.

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| Collapse {label} | Localized in aria-label | Button announces collapse action for section with given label |
| Expand {label} | Localized in aria-label | Button announces expand action for section with given label |
| Navigation | Used as drawer heading (title prop) | Drawer header text |
| Close navigation | Used as close button label (closeLabel prop) | Drawer dismiss button accessible name |

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Chevron rotation transition (duration-150) and smooth scroll behavior respond to `prefers-reduced-motion`; in reduced-motion mode, rotation should be instant and scroll should snap instead of smooth. NEEDS REVIEW: The source applies the `duration-150` rotation and `scroll-behavior: smooth` unconditionally and never checks `prefers-reduced-motion`. Missing is the reduced-motion branch; a rendering under `prefers-reduced-motion: reduce` showing an instant chevron and a snapped scroll would settle it. |
| Increase Contrast | All text colors (secondary, primary, dim, accent) MUST meet WCAG AA 4.5:1 contrast against their backgrounds at all times; component relies on theme tokens to provide these values and does not override them. |
| Differentiate Without Color | Selected state uses BOTH bold weight and a vertical accent bar, not color alone; this is sufficient for color-blind users to distinguish selected from unselected. |

## Feature Flags

Not applicable: the component has no feature flags. All functionality is always enabled.

## Analytics

Not applicable: the component does not emit analytics events. Analytics instrumentation is the host's responsibility.

## Privacy

Not applicable: this component does not collect, store, or transmit user data. Navigation state (expanded sections, active path) exists only in React component memory and the browser URL.

## Logging

Not applicable: the component does not perform any logging.

## Platform Notes

- **React/Web**: Component is a React functional component using hooks (`useState`, `useCallback`) and JSX. Uses `lucide-react` for icons (ChevronRight, X) and `classnames` library (`cn` utility). Tailwind CSS for styling with custom CSS variables (`--adh-header-height`, `--color-*` tokens). Requires React 16.8+. Source file: `packages/web/packages/ui/src/blocks/doc-nav.tsx`.

- **SwiftUI**: Port to SwiftUI would start from `NavigationStack` or a custom tree view. Sections would be `DisclosureGroup` with a chevron icon and section label. Leaves and branches would use `NavigationLink`. Active page tracking would use `@State` for expanded sections and accept `activePath` as a binding. Heading navigation would use `ScrollViewReader` to scroll to heading anchors on the current page. Drawer behavior maps to a sheet modifier with conditional presentation.

- **Compose**: Start from `Column` for the tree structure and `LazyColumn` for scrolling. Use `Row` with `IconButton` for section collapse control. `Text` for labels, `ClickableText` or custom `Modifier.clickable` for links. `mutableStateOf<Set<String>>` for expanded sections. Heading scrolling would use `LazyListState.scrollToItem()` within a `Modifier.verticalScroll(rememberScrollState())`. Drawer implemented as `ModalBottomSheet`.

- **AppKit / UIKit**: Use `NSOutlineView` (macOS) or implement a table view with custom cells (iOS). Section nodes render as parent rows with disclosure triangle. Branches and leaves as child rows. `NSTableView` manages expand/collapse state. For headings, implement an `NSViewController` or `UIViewController` hierarchy. Drawer on iOS uses `UISheetPresentationController`. Route tracking via URL observation or navigation controller delegate.

- **WinUI 3**: Use `TreeView` XAML control with `TreeViewNode` for sections, branches, and leaves. Section nodes have `Collapsed` and `Expanded` visual states; toggle chevron icon via binding to `IsExpanded`. Apply `PointerEntered` / `PointerExited` for hover styling. Heading sub-lists would use a second-level TreeView or an Expander control. For the drawer, use `NavigationView` or `SplitView` with conditional panel visibility; overlay with a `Grid` and semi-transparent `Border` for the scrim. Bind `activePath` to XAML with highlighting logic in code-behind or a converter. Smooth scroll heading navigation via `FrameworkElement.StartAnimation()` or XAML composition.

## Design Decisions

- **Controlled drawer open state**: The drawer's `open` prop is controlled by the host, not managed internally by the component. This is intentional: the "open" button lives in a separate header component outside the nav subtree. An uncontrolled drawer would leave that button silently dead after the drawer closed. Controlled state ensures the two stay in sync.

- **Section state held above both renderings**: Desktop and mobile render the same tree description twice (as two React component instances). If section expansion state were held inside the tree component, the desktop and mobile copies would diverge: the user opens a section on mobile, closes the drawer, and the section is now closed on mobile but still open on desktop. The solution is to hold `expanded` and `toggle` above both renderings, in `DocNav`, so both instances see the same state. A single-rendering host (desktop only) can omit this and let the tree own its own state via `useExpandedSections`.

- **Expansion state does not auto-update on navigation**: When `activePath` changes, the component does NOT automatically open sections. It seeds the initial expansion from `activePath` on mount only. This preserves a reader's deliberate collapse choices as they navigate. Automatically closing a section they had opened would feel hostile.

- **Headings are nav component, not anchor behavior**: The heading sub-list is part of the nav tree, not a separate anchoring feature. Links to headings on the current page scroll instead of navigating; from any other page, they navigate normally. This allows users to jump within a long page without losing their place in the tree and also makes heading links shareable (the URL carries the hash).

- **No viewport scrolling on mobile**: The mobile drawer scrolls its own contents (`overflow-y-auto` on `nav`), not the page body. This prevents the page from scrolling when the nav is open, which would be disorienting for mobile users trying to navigate.

- **Desktop nav never wraps, mobile allows wrapping**: The desktop sidebar uses `whitespace-nowrap` and `overflow-x-auto` to prevent multi-line entries; a row that wraps reads as two separate nav items. Mobile deliberately omits this so that long labels wrap onto a second line instead of requiring horizontal scroll, which is more natural on phone-sized screens.

- **Children ordered by type, not input order**: Leaves are always rendered before branches at every level. This is intentional: a reader scanning a section wants the section's own pages before its sub-directories. Without this reordering, the tree would read differently depending on how the host happened to sort the input array, reducing predictability.

- **Color is not the only selected indicator**: The selected link uses both bold weight AND a left accent bar. This satisfies the WCAG requirement that status must be distinguishable without color alone.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| [WCAG 2.1 AA text contrast](agenticdevelopercookbook://compliance/accessibility#wcag-21-aa) | passed | All text colors must meet 4.5:1 contrast; delegated to theme tokens |
| [Keyboard navigation](agenticdevelopercookbook://compliance/accessibility#keyboard-navigation) | passed | All interactive elements (section toggle, links) are keyboard-accessible via tab and enter; scrim dismissal requires only pointer interaction and is not keyboard-accessible (intentional: keyboard user closes drawer via X button or escape) |
| [Touch target size](agenticdevelopercookbook://compliance/accessibility#touch-target-size) | passed | Section collapse button targets are padded to 44×44px or greater; links rely on accumulated `py-0.5` padding and line spacing rather than individual link height |
| [Semantic HTML](agenticdevelopercookbook://compliance/markup#semantic-html) | passed | Nav renders `<nav>` element; sections use `<div>`, links use the host's `LinkComponent` (which defaults to `<a>`); lists use `<ul>` and `<li>` |
| [Aria-current usage](agenticdevelopercookbook://compliance/accessibility#aria-current) | passed | Selected links carry `aria-current="page"` per ARIA spec |
| [Reduce motion](agenticdevelopercookbook://compliance/accessibility#reduce-motion) | failed | Component does not detect or respond to `prefers-reduced-motion` media query; chevron rotation and smooth scroll should respect this preference. This is a source limitation, not an implementation gap. |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | | Initial creation |
