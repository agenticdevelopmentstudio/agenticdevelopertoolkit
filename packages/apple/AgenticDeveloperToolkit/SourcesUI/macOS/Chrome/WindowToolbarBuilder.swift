import AppKit

/// The three facts about `NSToolbar` that every window in this codebase has
/// had to rediscover, in one place.
///
/// 1. `NSToolbarItem` is a plain `NSObject`. It does not conform to
///    `NSAccessibility`, so `setAccessibilityIdentifier` is not reachable on
///    it and a UI test cannot address it. The identifier has to land on a real
///    view, which is why every button here is a **custom-view** item.
/// 2. The cost of that is validation: AppKit's own header says it "will not
///    send this message for items that have custom views," so
///    `NSToolbarItemValidation` never runs and enablement is the owner's job.
///    This builder deliberately does not paper over that — the owner keeps the
///    button and sets `isEnabled` when its state changes.
/// 3. A disclosure glyph is tinted from **the button's own** resolved scope,
///    not the app-wide palette: a window may carry a theme scope of its own,
///    and the static accessor would ignore it.
///
/// A namespace of static functions rather than an object, because there is no
/// state to keep — and because the one lifetime bug this file must not repeat
/// is an `NSToolbar.delegate` (which is `weak`) with no other owner.
@MainActor
public enum WindowToolbarBuilder {

    /// A borderless, image-only toolbar button in a custom-view item.
    ///
    /// Returns the button as well as the item: the caller needs it to set
    /// `isEnabled`, since validation never fires (fact 2 above).
    ///
    /// - Parameter identifier: doubles as the button's accessibility
    ///   identifier, so a UI test names the control and the toolbar slot with
    ///   one string.
    public static func iconButtonItem(
        identifier: NSToolbarItem.Identifier,
        symbol: String,
        label: String,
        target: AnyObject?,
        action: Selector
    ) -> (item: NSToolbarItem, button: NSButton) {
        let button = NSButton(
            image: NSImage(systemSymbolName: symbol, accessibilityDescription: label) ?? NSImage(),
            target: target,
            action: action)
        button.isBordered = false
        button.imagePosition = .imageOnly
        button.setButtonType(.momentaryChange)
        button.toolTip = label
        button.accessibilityID(identifier.rawValue)

        let item = NSToolbarItem(itemIdentifier: identifier)
        item.label = label
        item.paletteLabel = label
        item.toolTip = label
        item.view = button
        return (item, button)
    }

    /// A real `NSSearchToolbarItem` — the system one, which gets the
    /// expand/collapse behaviour and the ⌘F responder wiring for free — with
    /// its field identified for UI tests.
    public static func searchItem(
        identifier: NSToolbarItem.Identifier,
        placeholder: String,
        delegate: NSSearchFieldDelegate?
    ) -> NSSearchToolbarItem {
        let item = NSSearchToolbarItem(itemIdentifier: identifier)
        item.searchField.placeholderString = placeholder
        item.searchField.delegate = delegate
        item.searchField.accessibilityID(identifier.rawValue)
        return item
    }

    /// Makes a toggle button report the state it toggles: filled and accented
    /// while the thing is disclosed, outlined and secondary while it is not.
    ///
    /// Call it from a live `ThemePaletteObserver` rather than once at
    /// construction — reading the palette on demand leaves the tint stale
    /// until some unrelated refresh happens to run next.
    public static func applyDisclosureAppearance(
        to button: NSButton,
        disclosed: Bool,
        outlineSymbol: String,
        filledSymbol: String,
        showTooltip: String,
        hideTooltip: String
    ) {
        let symbol = disclosed ? filledSymbol : outlineSymbol
        let image = NSImage(systemSymbolName: symbol, accessibilityDescription: button.toolTip)
        button.image = image?.withSymbolConfiguration(
            NSImage.SymbolConfiguration(pointSize: 15, weight: .regular))
        let palette = button.resolvedThemeScope.palette
        button.contentTintColor = disclosed ? palette.accentColor : palette.secondaryTextColor
        button.toolTip = disclosed ? hideTooltip : showTooltip
    }
}

/// One slot in a toolbar built from a list.
///
/// Deliberately small. A window whose toolbar needs more than this — a menu
/// rebuilt on every open, enablement tied to a selection, a live theme observer
/// on one button — should keep being its own `NSToolbarDelegate` and use the
/// factories above. Growing this enum to cover that case would make it as
/// complicated as the delegate it was meant to replace.
public enum WindowToolbarItem {
    case button(identifier: NSToolbarItem.Identifier, symbol: String, label: String, action: Selector)
    case search(identifier: NSToolbarItem.Identifier, placeholder: String)
    case flexibleSpace

    var identifier: NSToolbarItem.Identifier {
        switch self {
        case .button(let identifier, _, _, _): identifier
        case .search(let identifier, _): identifier
        case .flexibleSpace: .flexibleSpace
        }
    }
}

extension WindowToolbarBuilder {

    /// An `NSToolbarDelegate` built from a list of descriptors, for a window
    /// whose toolbar has nothing to say beyond what is in the list.
    ///
    /// **The caller must store it.** `NSToolbar.delegate` is `weak`: a delegate
    /// with no other owner is deallocated the instant configuration returns, and
    /// the toolbar then renders no items at all and reports no error. That is
    /// why `makeToolbar(identifier:)` exists — it hands back a toolbar already
    /// pointed at `self`, which reads correctly only at a call site that is
    /// keeping `self`.
    @MainActor
    public final class Delegate: NSObject, NSToolbarDelegate {

        private let items: [WindowToolbarItem]
        private weak var target: AnyObject?
        private weak var searchDelegate: NSSearchFieldDelegate?

        /// Kept because AppKit skips `NSToolbarItemValidation` for custom-view
        /// items, so the owner has to reach in and set `isEnabled` itself.
        private var buttons: [NSToolbarItem.Identifier: NSButton] = [:]

        public private(set) var searchField: NSSearchField?

        public init(
            items: [WindowToolbarItem],
            target: AnyObject?,
            searchDelegate: NSSearchFieldDelegate? = nil
        ) {
            self.items = items
            self.target = target
            self.searchDelegate = searchDelegate
            super.init()
        }

        /// The button made for an identifier, or `nil` before the toolbar has
        /// asked for it (or for a slot that is not a button).
        public func button(for identifier: NSToolbarItem.Identifier) -> NSButton? {
            self.buttons[identifier]
        }

        /// A toolbar already pointed at this delegate. Call it from somewhere
        /// that keeps the delegate alive.
        public func makeToolbar(identifier: String) -> NSToolbar {
            let toolbar = NSToolbar(identifier: identifier)
            toolbar.delegate = self
            toolbar.displayMode = .iconOnly
            toolbar.allowsUserCustomization = false
            return toolbar
        }

        private var identifiers: [NSToolbarItem.Identifier] { self.items.map(\.identifier) }

        public func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
            self.identifiers
        }

        public func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
            self.identifiers
        }

        public func toolbar(
            _ toolbar: NSToolbar,
            itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
            willBeInsertedIntoToolbar flag: Bool
        ) -> NSToolbarItem? {
            guard let descriptor = self.items.first(where: { $0.identifier == itemIdentifier })
            else { return nil }

            switch descriptor {
            case .flexibleSpace:
                return nil  // AppKit supplies the standard spacer itself.

            case .button(let identifier, let symbol, let label, let action):
                let (item, button) = WindowToolbarBuilder.iconButtonItem(
                    identifier: identifier,
                    symbol: symbol,
                    label: label,
                    target: self.target,
                    action: action)
                self.buttons[identifier] = button
                return item

            case .search(let identifier, let placeholder):
                let item = WindowToolbarBuilder.searchItem(
                    identifier: identifier,
                    placeholder: placeholder,
                    delegate: self.searchDelegate)
                self.searchField = item.searchField
                return item
            }
        }
    }
}
