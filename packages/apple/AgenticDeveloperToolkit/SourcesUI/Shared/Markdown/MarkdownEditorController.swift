import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif
import AgenticDeveloperToolkit

/// A markdown source pane with an optional live preview.
///
/// Preview rendering is debounced rather than run per keystroke: rendering is
/// cheap but not free, and a preview that repaints on every character is the
/// thing that makes a document editor feel slow.
///
/// The split/tab decision is made from the view's own width instead of a
/// platform check, so a narrow window on the Mac behaves like a phone and a
/// wide iPad behaves like a Mac.
@MainActor
public final class MarkdownEditorController: PlatformViewController {

    public static let renderDebounce: TimeInterval = 0.3
    public static let splitWidthThreshold: CGFloat = 700

    let editorPane: MarkdownTextPane
    let viewer: MarkdownViewerController
    let toolbar: MarkdownEditorToolbar

    private var pendingRender: DispatchWorkItem?
    private var isApplyingProgrammaticContent = false
    private var activeConstraints: [NSLayoutConstraint] = []

    public var onContentChange: ((String) -> Void)?

    public var palette: SemanticPalette {
        didSet {
            viewer.palette = palette
            applyTheme()
        }
    }

    public var content: String = "" {
        didSet {
            guard !isApplyingProgrammaticContent else { return }
            isApplyingProgrammaticContent = true
            defer { isApplyingProgrammaticContent = false }
            if editorPane.text != content { editorPane.text = content }
            scheduleRender()
        }
    }

    public var isPreviewAvailable: Bool = true {
        didSet { applyLayoutForCurrentSize() }
    }

    public private(set) var availableModes: [MarkdownEditorMode] = MarkdownEditorMode.allCases

    public var mode: MarkdownEditorMode = .split {
        didSet {
            guard mode != oldValue else { return }
            toolbar.mode = mode
            applyPanes()
        }
    }

    public init(palette: SemanticPalette, highlighter: (any CodeHighlighter)? = nil) {
        self.palette = palette
        self.editorPane = MarkdownTextPane(editable: true)
        self.viewer = MarkdownViewerController(palette: palette, highlighter: highlighter)
        self.toolbar = MarkdownEditorToolbar()
        super.init(nibName: nil, bundle: nil)

        editorPane.onTextChange = { [weak self] text in
            guard let self, !self.isApplyingProgrammaticContent else { return }
            self.isApplyingProgrammaticContent = true
            self.content = text
            self.isApplyingProgrammaticContent = false
            self.scheduleRender()
            self.onContentChange?(text)
        }

        toolbar.onModeChange = { [weak self] mode in self?.mode = mode }
        toolbar.onSyntaxHelpRequested = { [weak self] in
            guard let self else { return }
            self.toolbar.presentSyntaxHelp(from: self, palette: self.palette)
        }
        toolbar.onImport = { [weak self] in
            guard let self else { return }
            MarkdownFileImporter.present(from: self) { imported in
                guard let imported else { return }
                self.content = imported
                self.onContentChange?(imported)
            }
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    public override func loadView() {
        let container = PlatformView()
        view = container

        for child in [toolbar, editorPane] {
            child.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(child)
        }
        addChild(viewer)
        viewer.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            toolbar.topAnchor.constraint(equalTo: container.topAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: MarkdownEditorToolbar.height)
        ])

        editorPane.text = content
        applyTheme()
        applyLayoutForCurrentSize()
        renderPreview()
    }

    /// Renders the preview now instead of waiting out the debounce. Tests call
    /// it; so does anything that needs the preview correct before a screenshot.
    public func flushPendingRender() {
        pendingRender?.cancel()
        pendingRender = nil
        renderPreview()
    }

    // MARK: - Layout

    // The only platform branch in this file: AppKit and UIKit name the same
    // hook differently and neither declares the other's, so both forward to one
    // shared method rather than duplicating any logic.
    #if os(macOS)
    public override func viewDidLayout() {
        super.viewDidLayout()
        applyLayoutForCurrentSize()
    }
    #else
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyLayoutForCurrentSize()
    }
    #endif

    private func applyLayoutForCurrentSize() {
        guard isViewLoaded else { return }
        let canSplit = isPreviewAvailable && view.bounds.width >= Self.splitWidthThreshold

        let modes: [MarkdownEditorMode]
        if !isPreviewAvailable {
            modes = [.edit]
        } else if canSplit {
            modes = MarkdownEditorMode.allCases
        } else {
            modes = [.edit, .preview]
        }

        guard modes != availableModes || activeConstraints.isEmpty else { return }
        availableModes = modes
        toolbar.availableModes = modes

        // This block only runs when the available-modes set itself just
        // changed (the guard above filters out same-class layout passes), so
        // it represents a genuine narrow<->wide crossing, not every resize.
        // Snapping to the class's canonical mode — rather than merely
        // checking whether the *current* mode still happens to be a member
        // of the new set — is what lets a widened editor regain `.split`
        // even though `.edit` (its narrow fallback) remains valid.
        let defaultMode: MarkdownEditorMode = canSplit ? .split : .edit
        if mode != defaultMode {
            mode = defaultMode
        } else {
            applyPanes()
        }
    }

    private func applyPanes() {
        guard isViewLoaded else { return }
        NSLayoutConstraint.deactivate(activeConstraints)
        activeConstraints = []

        let showsEditor = mode == .edit || mode == .split
        let showsPreview = mode == .preview || mode == .split

        if showsEditor, editorPane.superview == nil { view.addSubview(editorPane) }
        if !showsEditor { editorPane.removeFromSuperview() }
        if showsPreview, viewer.view.superview == nil { view.addSubview(viewer.view) }
        if !showsPreview { viewer.view.removeFromSuperview() }

        var constraints: [NSLayoutConstraint] = []
        let top = toolbar.bottomAnchor

        switch (showsEditor, showsPreview) {
        case (true, true):
            constraints += [
                editorPane.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                editorPane.topAnchor.constraint(equalTo: top),
                editorPane.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                editorPane.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
                viewer.view.leadingAnchor.constraint(equalTo: editorPane.trailingAnchor),
                viewer.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                viewer.view.topAnchor.constraint(equalTo: top),
                viewer.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ]
        case (true, false):
            constraints += fill(editorPane, below: top)
        case (false, true):
            constraints += fill(viewer.view, below: top)
        case (false, false):
            break
        }

        activeConstraints = constraints
        NSLayoutConstraint.activate(constraints)
        if showsPreview { flushPendingRender() }
    }

    private func fill(_ subview: PlatformView, below top: NSLayoutYAxisAnchor) -> [NSLayoutConstraint] {
        [
            subview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            subview.topAnchor.constraint(equalTo: top),
            subview.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
    }

    // MARK: - Rendering

    private func scheduleRender() {
        pendingRender?.cancel()
        let work = DispatchWorkItem { [weak self] in
            self?.pendingRender = nil
            self?.renderPreview()
        }
        pendingRender = work
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.renderDebounce, execute: work)
    }

    private func renderPreview() {
        guard isViewLoaded else { return }
        viewer.content = content
    }

    private func applyTheme() {
        guard isViewLoaded else { return }
        editorPane.applyTheme(palette)
        toolbar.applyTheme(palette)
    }
}
