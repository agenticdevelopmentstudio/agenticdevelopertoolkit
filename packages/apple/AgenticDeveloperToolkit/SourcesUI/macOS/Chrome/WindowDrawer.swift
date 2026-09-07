import AppKit

/// One tab in a `WindowDrawer`.
///
/// A value, not a view: the drawer makes the view the first time the tab is
/// shown and keeps it, so a tab that is never opened costs nothing.
@MainActor
public struct DrawerTab {

    /// Stable, and the suffix of the tab's accessibility identifier — so a UI
    /// test names the tab the same way the code selects it.
    public let id: String
    public let title: String
    public let symbolName: String
    public let makeView: @MainActor () -> NSView

    public init(
        id: String,
        title: String,
        symbolName: String,
        makeView: @escaping @MainActor () -> NSView
    ) {
        self.id = id
        self.title = title
        self.symbolName = symbolName
        self.makeView = makeView
    }
}

/// A tabbed drawer on a window's trailing edge.
///
/// A drawer slides out *beside* the window instead of taking width from it,
/// which is the whole point — disclosing help must not reflow the thing it is
/// explaining, and closing it must not leave a gap where prose used to be.
/// AppKit animates the slide, tracks the window and flips the drawer to the
/// other edge when the screen has no room; none of that is ours to write.
///
/// `NSDrawer` has been deprecated since 10.13, and AppKit's suggested
/// replacement is `NSSplitViewController` — precisely the pane-that-steals-width
/// this is not. It is still in the SDK and still works. This type carries the
/// deprecation on purpose: a deprecated declaration is a warning-free zone for
/// the API it wraps, so AppKit's drawer vocabulary stays inside this one file
/// and every window sees only `WindowDrawer`.
///
/// Two things the drawer deliberately does **not** do:
///
/// - It does not remember whether it was open. Settings remembers its drawer in
///   `UserSettings`; the project window remembers its own per repository. A
///   preference belongs to whoever the preference is about.
/// - It does not know what a tab contains. A tab is an id, a title, a symbol and
///   a `() -> NSView`, which is what lets this live below the code that has help
///   to show.
@available(macOS, deprecated: 10.13, message: "Wraps NSDrawer, deprecated since macOS 10.13")
@MainActor
public final class WindowDrawer: NSObject {

    /// Wide enough for a comfortable measure at explanation size; the user can
    /// drag the outer edge between the min and max below from there.
    ///
    /// `nonisolated` because it is used as a default argument value below: a
    /// default-argument expression compiles as a standalone, non-isolated
    /// function regardless of the initializer's own actor, so referencing a
    /// `@MainActor`-isolated static from one is a warning today and an error
    /// under the Swift 6 language mode. The property is a `CGFloat` literal —
    /// `Sendable` and safe to read from any isolation — so `nonisolated` costs
    /// nothing.
    public static nonisolated let defaultContentWidth: CGFloat = 300
    private static let minContentWidth: CGFloat = 220
    private static let maxContentWidth: CGFloat = 520

    private let drawer: NSDrawer
    private let tabs: [DrawerTab]
    private let accessibilityPrefix: String
    private let container = ThemedBackgroundView(role: .surface)
    private let body = NSView()

    /// The drawer's own content, and the view its body swaps into. Exposed for
    /// the identifiers on them — a test, and a UI test, need a handle on both.
    public var contentView: NSView { self.container }
    public var bodyView: NSView { self.body }

    /// Exposed so a test — and a UI test, through its identifier — can find the
    /// strip. Hidden when there is only one tab: a segmented control with one
    /// segment is a button that does nothing.
    public let tabStrip = NSSegmentedControl()

    private var madeViews: [String: NSView] = [:]

    public private(set) var selectedTabID: String?

    public var isOpen: Bool {
        self.drawer.state == NSDrawer.State.openState.rawValue
            || self.drawer.state == NSDrawer.State.openingState.rawValue
    }

    /// How wide the drawer is, in points. The drawer does not remember this
    /// across launches — its owner does — so the owner needs to read what the
    /// user dragged it to and write back what it remembered.
    ///
    /// Clamped on the way in to the same range the drag itself is clamped to: a
    /// remembered value outside it is either corrupt or from a build with
    /// different limits, and either way obeying it produces a drawer the user
    /// cannot drag back.
    public var contentWidth: CGFloat {
        get { self.drawer.contentSize.width }
        set {
            let clamped = min(max(newValue, Self.minContentWidth), Self.maxContentWidth)
            self.drawer.contentSize = NSSize(
                width: clamped, height: self.drawer.contentSize.height)
        }
    }

    public var tabStripIsHidden: Bool { self.tabStrip.isHidden }

    /// Fired after the drawer opens or closes, so a help button can restyle
    /// itself. The drawer can be moved by something other than that button.
    public var onVisibilityChange: (() -> Void)?

    /// - Parameter accessibilityPrefix: namespaces the drawer's own controls —
    ///   `<prefix>.tabs` for the strip, `<prefix>.tab.<id>` for each segment.
    public init(
        parentWindow: NSWindow,
        accessibilityPrefix: String,
        tabs: [DrawerTab],
        contentWidth: CGFloat = WindowDrawer.defaultContentWidth
    ) {
        self.drawer = NSDrawer(
            contentSize: NSSize(width: contentWidth, height: parentWindow.frame.height),
            preferredEdge: .maxX)
        self.tabs = tabs
        self.accessibilityPrefix = accessibilityPrefix
        self.selectedTabID = tabs.first?.id

        super.init()

        self.buildTabStrip(prefix: accessibilityPrefix)
        self.buildContainer()

        self.drawer.parentWindow = parentWindow
        self.drawer.contentView = self.container
        // Height is the window's to decide; only the width is draggable.
        self.drawer.minContentSize = NSSize(width: Self.minContentWidth, height: 0)
        self.drawer.maxContentSize = NSSize(width: Self.maxContentWidth, height: 0)

        self.showSelectedTab()
        self.observeParentWindow(parentWindow)
    }

    private func buildTabStrip(prefix: String) {
        self.tabStrip.segmentStyle = .texturedRounded
        self.tabStrip.trackingMode = .selectOne
        self.tabStrip.segmentCount = self.tabs.count
        for (index, tab) in self.tabs.enumerated() {
            self.tabStrip.setLabel(tab.title, forSegment: index)
            self.tabStrip.setImage(
                NSImage(systemSymbolName: tab.symbolName, accessibilityDescription: tab.title),
                forSegment: index)
            self.tabStrip.setToolTip(tab.title, forSegment: index)
        }
        self.tabStrip.selectedSegment = self.tabs.isEmpty ? -1 : 0
        self.tabStrip.target = self
        self.tabStrip.action = #selector(self.tabStripChanged)
        self.tabStrip.accessibilityID("\(prefix).tabs")
        // One segment is a button that does nothing. Keep it in the hierarchy
        // so a second tab later needs no layout change — just unhide it.
        self.tabStrip.isHidden = self.tabs.count < 2
    }

    private func buildContainer() {
        self.container.accessibilityID(self.accessibilityPrefix)
        for child in [self.tabStrip, self.body] {
            child.translatesAutoresizingMaskIntoConstraints = false
            self.container.addSubview(child)
        }

        let stripHeight: CGFloat = self.tabStrip.isHidden ? 0 : 32
        NSLayoutConstraint.activate([
            self.tabStrip.topAnchor.constraint(equalTo: self.container.topAnchor, constant: 8),
            self.tabStrip.centerXAnchor.constraint(equalTo: self.container.centerXAnchor),

            self.body.topAnchor.constraint(
                equalTo: self.container.topAnchor, constant: stripHeight),
            self.body.leadingAnchor.constraint(equalTo: self.container.leadingAnchor),
            self.body.trailingAnchor.constraint(equalTo: self.container.trailingAnchor),
            self.body.bottomAnchor.constraint(equalTo: self.container.bottomAnchor)
        ])
    }

    // MARK: - Tabs

    /// The view for a tab, made on first ask and kept. `nil` for an id that is
    /// not one of this drawer's tabs.
    @discardableResult
    public func view(forTab id: String) -> NSView? {
        if let existing = self.madeViews[id] { return existing }
        guard let tab = self.tabs.first(where: { $0.id == id }) else { return nil }
        let view = tab.makeView()
        self.madeViews[id] = view
        return view
    }

    @objc private func tabStripChanged() {
        let index = self.tabStrip.selectedSegment
        guard index >= 0, index < self.tabs.count else { return }
        self.selectedTabID = self.tabs[index].id
        self.showSelectedTab()
    }

    private func showSelectedTab() {
        guard let id = self.selectedTabID, let view = self.view(forTab: id) else { return }
        self.body.accessibilityID("\(self.accessibilityPrefix).tab.\(id)")
        guard view.superview !== self.body else { return }

        for subview in self.body.subviews { subview.removeFromSuperview() }
        view.translatesAutoresizingMaskIntoConstraints = false
        self.body.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.body.topAnchor),
            view.leadingAnchor.constraint(equalTo: self.body.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.body.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: self.body.bottomAnchor)
        ])
    }

    /// Selects a tab without changing whether the drawer is open. An id that
    /// names no tab is ignored — better a stale tab than a blank drawer.
    private func select(_ id: String?) {
        guard let id, let index = self.tabs.firstIndex(where: { $0.id == id }) else { return }
        self.selectedTabID = id
        self.tabStrip.selectedSegment = index
        self.showSelectedTab()
    }

    // MARK: - Open and close

    public func open(selecting id: String? = nil) {
        self.select(id)
        self.drawer.open()
        self.onVisibilityChange?()
    }

    public func close() {
        self.drawer.close()
        self.onVisibilityChange?()
    }

    /// Closes if it is already open *on that tab*; otherwise opens on it. That
    /// is the help button's contract: one click discloses help, a second click
    /// puts it away, and a click while some other tab is showing switches to
    /// help rather than closing a drawer the reader is still using.
    public func toggle(selecting id: String? = nil) {
        if self.isOpen, id == nil || id == self.selectedTabID {
            self.close()
        } else {
            self.open(selecting: id)
        }
    }

    // MARK: - NSDrawer's other sharp edge

    /// A drawer can only open on a window that is already on screen, and a
    /// window's first content is chosen while it is still being made visible —
    /// so an opening call at that moment is silently dropped. Re-applying when
    /// the window arrives is what makes "remembered open" actually open on
    /// launch rather than on the second try.
    ///
    /// Registered by selector rather than by block so the observation is
    /// zeroing-weak and needs no `deinit` to undo.
    private func observeParentWindow(_ window: NSWindow) {
        let center = NotificationCenter.default
        for name in [NSWindow.didBecomeKeyNotification, NSWindow.didBecomeMainNotification] {
            center.addObserver(
                self,
                selector: #selector(self.parentWindowDidAppear),
                name: name,
                object: window)
        }
    }

    /// Re-asserts whatever the owner last asked for. The owner sets this when
    /// it restores its remembered state; the drawer itself remembers nothing.
    public var reapplyVisibility: (() -> Void)?

    @objc private func parentWindowDidAppear() {
        self.reapplyVisibility?()
    }
}
