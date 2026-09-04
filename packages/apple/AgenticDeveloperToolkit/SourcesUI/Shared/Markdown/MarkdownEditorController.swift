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
            guard content != oldValue else { return }
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

    /// The last mode chosen deliberately — via this setter or the toolbar's
    /// mode control — as distinct from a layout-driven fallback. A resize
    /// that narrows the window and then widens it again restores this,
    /// rather than whatever mode the narrow layout happened to fall back to.
    private var preferredMode: MarkdownEditorMode = .split
    private var modeStorage: MarkdownEditorMode = .split

    public var mode: MarkdownEditorMode {
        get { modeStorage }
        set {
            // The *requested* mode is recorded, not the clamped one that
            // `applyMode` may substitute. A caller asking for a mode the
            // current layout can't offer has still stated a preference, and
            // it is honoured the moment the layout can offer it — the same
            // rule that restores Split when a narrowed window widens again.
            preferredMode = newValue
            applyMode(newValue)
        }
    }

    /// Applies a mode, clamping it to `availableModes` if it isn't currently
    /// offered. Unlike the public setter, this does not touch
    /// `preferredMode` — it's also used by the layout pass to restore a
    /// previously-preferred mode without that restoration itself counting
    /// as a new deliberate choice.
    private func applyMode(_ requested: MarkdownEditorMode) {
        let resolved = availableModes.contains(requested) ? requested : layoutDefaultMode
        guard resolved != modeStorage else { return }
        modeStorage = resolved
        toolbar.mode = resolved
        applyPanes()
    }

    private var layoutDefaultMode: MarkdownEditorMode {
        let canSplit = isViewLoaded && isPreviewAvailable && view.bounds.width >= Self.splitWidthThreshold
        return canSplit ? .split : .edit
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
            MarkdownFileImporter.present(from: self) { [weak self] imported in
                guard let self, let imported else { return }
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
        // Sync the toolbar's mode explicitly rather than relying on the
        // first layout pass to push it — that pass runs at the view's
        // as-yet-unset (zero) width and may itself change `mode`, but the
        // toolbar should never be out of sync with the controller even for
        // the instant before that happens.
        toolbar.mode = mode
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
        // Restore the user's last deliberately-chosen mode if the new set
        // still offers it (e.g. an explicit Preview survives narrowing,
        // since `.preview` stays valid down to the two-mode set); otherwise
        // fall back to this size class's canonical mode. Unlike the general
        // `applyMode(_:)` path, this never updates `preferredMode` itself —
        // a layout-driven fallback is not a deliberate choice.
        let resolved = modes.contains(preferredMode) ? preferredMode : (canSplit ? .split : .edit)
        if resolved != modeStorage {
            modeStorage = resolved
            toolbar.mode = resolved
        }
        applyPanes()
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

    /// Counts every render that actually runs. Exposed at internal (not
    /// private) access so tests — which link against this module via
    /// `@testable import` — can distinguish "the debounce fired once" from
    /// "the debounce fired twice but happened to render the same string
    /// both times," which black-box text comparisons alone cannot tell
    /// apart.
    private(set) var renderCount = 0

    private func renderPreview() {
        guard isViewLoaded else { return }
        renderCount += 1
        viewer.content = content
    }

    private func applyTheme() {
        guard isViewLoaded else { return }
        editorPane.applyTheme(palette)
        toolbar.applyTheme(palette)
    }
}
