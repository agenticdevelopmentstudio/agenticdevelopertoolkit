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
        let viewer = MarkdownViewerController(palette: palette)
        viewer.content = MarkdownSyntaxReference.markdown
        viewer.view.frame = NSRect(x: 0, y: 0, width: 420, height: 460)

        let popover = NSPopover()
        popover.behavior = .transient
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
        guard let index = availableModes.firstIndex(of: mode) else { return }
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
