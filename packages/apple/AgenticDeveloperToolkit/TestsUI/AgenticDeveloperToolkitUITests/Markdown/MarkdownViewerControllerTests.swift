import Testing
import AppKit
import Foundation
import AgenticDeveloperToolkit
@testable import AgenticDeveloperToolkitUI

@MainActor
@Suite("MarkdownViewerController")
struct MarkdownViewerControllerTests {

    private var palette: SemanticPalette { SemanticPalette(theme: BuiltInThemes.solarizedDark) }

    private func loadedViewer(_ content: String) -> MarkdownViewerController {
        let viewer = MarkdownViewerController(palette: palette)
        viewer.content = content
        _ = viewer.view              // force loadView
        return viewer
    }

    @Test("the viewer shows the rendered document, not its source")
    func showsRenderedText() {
        let viewer = loadedViewer("# Title\n\nbody")
        #expect(viewer.pane.text == "Title\n\nbody")
    }

    @Test("the viewer never lets the reader type into it")
    func viewerIsReadOnly() {
        #expect(loadedViewer("body").pane.isEditable == false)
    }

    @Test("setting content after load re-renders the pane")
    func contentUpdatesAfterLoad() {
        let viewer = loadedViewer("# One")
        viewer.content = "# Two"
        #expect(viewer.pane.text == "Two")
    }

    @Test("frontmatter never reaches the reader")
    func hidesFrontmatter() {
        #expect(loadedViewer("---\ntitle: x\n---\nbody").pane.text == "body")
    }

    @Test("changing the palette re-renders rather than leaving stale colors")
    func paletteChangeRerenders() {
        let viewer = loadedViewer("# Title")
        viewer.palette = SemanticPalette(theme: BuiltInThemes.dracula)
        let color = viewer.pane.attributedText.attributes(at: 0, effectiveRange: nil)[.foregroundColor]
        #expect(color as? NSColor == SemanticPalette(theme: BuiltInThemes.dracula).nsColor(.primaryText))
    }
}

@MainActor
@Suite("MarkdownTextPane")
struct MarkdownTextPaneTests {

    @Test("setting text programmatically never fires onTextChange")
    func settingTextDoesNotFireOnTextChange() {
        let pane = MarkdownTextPane(editable: true)
        var fired = false
        pane.onTextChange = { _ in fired = true }
        pane.text = "x"
        #expect(fired == false)
    }

    @Test("a simulated user edit fires onTextChange with the new text")
    func userEditFiresOnTextChange() {
        let pane = MarkdownTextPane(editable: true)
        var received: String?
        pane.onTextChange = { received = $0 }

        let textView = pane.subviews
            .compactMap { $0 as? NSScrollView }
            .first?.documentView as? NSTextView
        textView?.insertText("typed", replacementRange: NSRange(location: 0, length: 0))

        #expect(received == "typed")
    }
}
