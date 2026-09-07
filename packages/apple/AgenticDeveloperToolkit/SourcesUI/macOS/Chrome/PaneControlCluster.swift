import AppKit

/// The close / minimize / zoom row at the leading edge of a pane's title bar.
///
/// Deliberately in the same left-to-right order, and with the same meanings, as
/// the three buttons at the leading edge of a window's title bar. A pane is a
/// window-shaped thing inside a window, and a reader who has to learn a second
/// arrangement for it has been charged for nothing
/// (`principle-of-least-astonishment`).
///
/// It reports and does not decide. Closing a pane, working out where it may
/// shrink to, and knowing whether it is currently zoomed all belong to whatever
/// is hosting it; this view is told, through `isZoomed`, `isMinimized` and
/// `canMinimize`, and it renders that.
///
/// Four closures rather than a delegate: there are four events, the host is
/// always exactly one object, and a protocol would make it declare conformance
/// and write four methods to answer three of them.
@MainActor
public final class PaneControlCluster: NSStackView {

    public let closeButton = NSButton()
    public let minimizeButton = NSButton()
    public let zoomButton = NSButton()

    public var onClose: (() -> Void)?
    /// Handed the minimize button, because that button is the anchor the
    /// picker popover hangs from and the host would otherwise have to reach
    /// back in for it.
    public var onMinimize: ((NSButton) -> Void)?
    public var onRestore: (() -> Void)?
    public var onZoom: (() -> Void)?

    /// Flips the zoom glyph and its tooltip. Set by the host; this view never
    /// infers it from a click, because a host is free to refuse.
    public var isZoomed: Bool = false { didSet { applyState() } }

    /// Turns the middle button into restore — glyph, tooltip, action and
    /// accessibility identifier.
    public var isMinimized: Bool = false { didSet { applyState() } }

    /// False for a pane that fills its tab: there is no sibling to hand the
    /// space to. Ignored while minimized, because restoring has to stay
    /// reachable even if the tree changed shape underneath.
    public var canMinimize: Bool = true { didSet { applyState() } }

    public init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        orientation = .horizontal
        spacing = 2
        alignment = .centerY
        setHuggingPriority(.required, for: .horizontal)

        configure(closeButton, action: #selector(closeTapped))
        configure(minimizeButton, action: #selector(minimizeTapped))
        configure(zoomButton, action: #selector(zoomTapped))

        closeButton.accessibilityID("pane.close")
        closeButton.setAccessibilityLabel("Close Pane")
        closeButton.toolTip = "Close Pane"
        closeButton.image = NSImage(systemSymbolName: "xmark", accessibilityDescription: "Close Pane")

        for button in [closeButton, minimizeButton, zoomButton] {
            addArrangedSubview(button)
        }

        applyState()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    private func configure(_ button: NSButton, action: Selector) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.bezelStyle = .accessoryBarAction
        button.isBordered = false
        button.imagePosition = .imageOnly
        button.target = self
        button.action = action
        button.observeTheme { button, palette in
            button.contentTintColor = palette.nsColor(.secondaryText)
        }
    }

    /// One place that turns the three flags into what the buttons look like.
    /// Spreading it across the three `didSet`s would make the middle button's
    /// appearance depend on the order the flags were assigned in.
    private func applyState() {
        if isMinimized {
            minimizeButton.accessibilityID("pane.restore")
            minimizeButton.setAccessibilityLabel("Restore Pane")
            minimizeButton.toolTip = "Restore Pane"
            minimizeButton.image = NSImage(systemSymbolName: "plus", accessibilityDescription: "Restore Pane")
            minimizeButton.isEnabled = true
        } else {
            minimizeButton.accessibilityID("pane.minimize")
            minimizeButton.setAccessibilityLabel("Minimize Pane")
            minimizeButton.toolTip = "Minimize Pane"
            minimizeButton.image = NSImage(systemSymbolName: "minus", accessibilityDescription: "Minimize Pane")
            minimizeButton.isEnabled = canMinimize
        }

        let zoomTitle = isZoomed ? "Unzoom Pane" : "Zoom Pane"
        let zoomSymbol = isZoomed
            ? "arrow.down.right.and.arrow.up.left"
            : "arrow.up.left.and.arrow.down.right"
        zoomButton.setAccessibilityLabel(zoomTitle)
        zoomButton.toolTip = zoomTitle
        zoomButton.image = NSImage(systemSymbolName: zoomSymbol, accessibilityDescription: zoomTitle)
        zoomButton.accessibilityID("pane.zoom")
    }

    @objc private func closeTapped() { onClose?() }
    @objc private func zoomTapped() { onZoom?() }

    @objc private func minimizeTapped() {
        if isMinimized {
            onRestore?()
        } else {
            onMinimize?(minimizeButton)
        }
    }
}
