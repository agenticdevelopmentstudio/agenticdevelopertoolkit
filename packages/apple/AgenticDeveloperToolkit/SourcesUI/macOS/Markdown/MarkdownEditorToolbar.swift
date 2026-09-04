import AppKit
import AgenticDeveloperToolkit

/// The editor's chrome: which pane is showing, where to get help, and how to
/// bring a file in.
@MainActor
public final class MarkdownEditorToolbar: NSView {

    public static let height: CGFloat = 32

    private let modeControl = NSSegmentedControl()
    private let helpButton = NSButton()
    private let importButton = NSButton()
    private var popover: NSPopover?

    public var onModeChange: ((MarkdownEditorMode) -> Void)?
    public var onImport: (() -> Void)?

    public var availableModes: [MarkdownEditorMode] = MarkdownEditorMode.allCases {
        didSet { rebuildModeControl() }
    }

    public var mode: MarkdownEditorMode = .split {
        didSet { syncSelection() }
    }

    public init() {
        super.init(frame: .zero)

        modeControl.segmentStyle = .texturedRounded
        modeControl.trackingMode = .selectOne
        modeControl.target = self
        modeControl.action = #selector(modeChanged)

        helpButton.title = "?"
        helpButton.bezelStyle = .rounded
        helpButton.target = self
        helpButton.action = #selector(helpTapped)

        importButton.title = "Open…"
        importButton.bezelStyle = .rounded
        importButton.target = self
        importButton.action = #selector(importTapped)

        let stack = NSStackView(views: [modeControl, NSView(), helpButton, importButton])
        stack.orientation = .horizontal
        stack.spacing = 8
        stack.edgeInsets = NSEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        rebuildModeControl()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    public func applyTheme(_ palette: SemanticPalette) {
        wantsLayer = true
        layer?.backgroundColor = palette.nsColor(.elevatedSurface).cgColor
    }

    public func presentSyntaxHelp(from presenter: PlatformViewController, palette: SemanticPalette) {
        // `presenter` exists only so this method's signature matches the iOS
        // implementation, which must present a view controller and so needs
        // one; AppKit shows the popover relative to the help button itself
        // and has no use for it.
        _ = presenter

        // `NSPopover.show(relativeTo:of:)` throws if `of:` has no window —
        // e.g. the toolbar was asked to present before it's ever been added
        // to a window.
        guard helpButton.window != nil else { return }

        let viewer = MarkdownViewerController(palette: palette)
        viewer.content = MarkdownSyntaxReference.markdown
        viewer.view.frame = NSRect(x: 0, y: 0, width: 420, height: 460)

        let popover = NSPopover()
        popover.behavior = .transient
        popover.delegate = self
        popover.contentViewController = viewer
        popover.contentSize = viewer.view.frame.size
        popover.show(relativeTo: helpButton.bounds, of: helpButton, preferredEdge: .maxY)
        self.popover = popover
    }

    private func rebuildModeControl() {
        modeControl.segmentCount = availableModes.count
        for (index, mode) in availableModes.enumerated() {
            modeControl.setLabel(mode.label, forSegment: index)
        }
        modeControl.isHidden = availableModes.count < 2
        syncSelection()
    }

    private func syncSelection() {
        guard let index = availableModes.firstIndex(of: mode) else {
            modeControl.selectedSegment = -1
            return
        }
        modeControl.selectedSegment = index
    }

    @objc private func modeChanged() {
        let index = modeControl.selectedSegment
        guard availableModes.indices.contains(index) else { return }
        mode = availableModes[index]
        onModeChange?(mode)
    }

    @objc private func helpTapped() { onSyntaxHelpRequested?() }
    @objc private func importTapped() { onImport?() }

    /// Set by the controller, which owns the presenter the popover needs.
    var onSyntaxHelpRequested: (() -> Void)?
}

extension MarkdownEditorToolbar: NSPopoverDelegate {
    public func popoverDidClose(_ notification: Notification) {
        popover = nil
    }
}
