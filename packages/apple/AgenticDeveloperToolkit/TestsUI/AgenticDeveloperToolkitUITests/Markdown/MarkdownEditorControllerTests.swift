import Testing
import AppKit
import Foundation
import AgenticDeveloperToolkit
@testable import AgenticDeveloperToolkitUI

@MainActor
@Suite("MarkdownEditorController")
struct MarkdownEditorControllerTests {

    private var palette: SemanticPalette { SemanticPalette(theme: BuiltInThemes.solarizedDark) }

    private func loadedEditor(_ content: String = "") -> MarkdownEditorController {
        let editor = MarkdownEditorController(palette: palette)
        editor.content = content
        editor.view.frame = NSRect(x: 0, y: 0, width: 900, height: 600)
        _ = editor.view
        return editor
    }

    @Test("the editor pane shows the document source, frontmatter and all")
    func editorShowsSource() {
        let editor = loadedEditor("---\ntitle: x\n---\n# Body\n")
        #expect(editor.editorPane.text == "---\ntitle: x\n---\n# Body\n")
    }

    @Test("the preview shows the rendered document, without the frontmatter")
    func previewShowsRendered() {
        let editor = loadedEditor("---\ntitle: x\n---\n# Body\n")
        editor.flushPendingRender()
        #expect(editor.viewer.pane.text == "Body")
    }

    @Test("typing reports the new content to the host")
    func typingReportsContent() {
        let editor = loadedEditor("a")
        var reported: [String] = []
        editor.onContentChange = { reported.append($0) }
        editor.editorPane.text = "ab"
        editor.editorPane.onTextChange?("ab")
        #expect(reported == ["ab"])
        #expect(editor.content == "ab")
    }

    @Test("setting content programmatically does not echo back as an edit")
    func programmaticSetDoesNotEcho() {
        let editor = loadedEditor("a")
        var reported: [String] = []
        editor.onContentChange = { reported.append($0) }
        editor.content = "b"
        #expect(reported.isEmpty)
        #expect(editor.editorPane.text == "b")
    }

    @Test("the preview lags behind typing until the debounce is flushed")
    func previewIsDebounced() {
        let editor = loadedEditor("# One")
        editor.flushPendingRender()
        editor.editorPane.onTextChange?("# Two")
        #expect(editor.viewer.pane.text == "One")   // not yet
        editor.flushPendingRender()
        #expect(editor.viewer.pane.text == "Two")
    }

    @Test("a wide editor shows source and preview side by side")
    func wideEditorSplits() {
        let editor = loadedEditor("# Hi")
        editor.view.frame = NSRect(x: 0, y: 0, width: 900, height: 600)
        editor.view.layoutSubtreeIfNeeded()
        #expect(editor.mode == .split)
        #expect(editor.editorPane.superview != nil)
        #expect(editor.viewer.view.superview != nil)
    }

    @Test("a narrow editor falls back to one pane at a time")
    func narrowEditorTabs() {
        let editor = loadedEditor("# Hi")
        editor.view.frame = NSRect(x: 0, y: 0, width: 500, height: 600)
        editor.view.layoutSubtreeIfNeeded()
        #expect(editor.mode == .edit)
        #expect(editor.viewer.view.superview == nil)
    }

    @Test("an edit-only editor never offers a preview, however wide it is")
    func previewCanBeDisabled() {
        let editor = MarkdownEditorController(palette: palette)
        editor.isPreviewAvailable = false
        editor.view.frame = NSRect(x: 0, y: 0, width: 1200, height: 600)
        editor.view.layoutSubtreeIfNeeded()
        #expect(editor.mode == .edit)
        #expect(editor.availableModes == [.edit])
    }

    @Test("setting a mode the current layout doesn't offer does not stick")
    func modeSetterClampsToAvailableModes() {
        let editor = MarkdownEditorController(palette: palette)
        editor.isPreviewAvailable = false
        editor.view.frame = NSRect(x: 0, y: 0, width: 1200, height: 600)
        editor.view.layoutSubtreeIfNeeded()
        #expect(editor.availableModes == [.edit])

        editor.mode = .split
        #expect(editor.mode == .edit)
        #expect(editor.viewer.view.superview == nil)
    }

    @Test("cancelling a pending render means it never fires, not just that flushing is idempotent")
    func previewDebounceIsActuallyCancelled() async throws {
        let editor = loadedEditor("# One")
        editor.flushPendingRender()
        let countAfterFirstFlush = editor.renderCount

        // Schedules a debounced render ~0.3s out, then flushes it early —
        // this should both render now and cancel that pending work item.
        editor.editorPane.onTextChange?("# Two")
        editor.flushPendingRender()
        let countAfterSecondFlush = editor.renderCount
        #expect(countAfterSecondFlush == countAfterFirstFlush + 1)

        // If the original debounced work item had merely been left to fire
        // later rather than actually cancelled, it would still land around
        // now and bump the count again — even though it would render the
        // same (already-current) text, which is why a text comparison alone
        // can't tell the two cases apart.
        try await Task.sleep(nanoseconds: UInt64((MarkdownEditorController.renderDebounce + 0.2) * 1_000_000_000))
        #expect(editor.renderCount == countAfterSecondFlush)
    }

    @Test("the syntax reference covers the syntax the editor claims to support")
    func syntaxReferenceIsComplete() {
        let syntaxes = Set(MarkdownSyntaxReference.rows.map(\.syntax))
        for expected in ["# Heading", "**bold**", "- item", "1. item", "> quote", "`code`",
                         "```lang", "[text](url)", "| a | b |", "---", "- [ ] task"] {
            #expect(syntaxes.contains(expected), "missing reference row for \(expected)")
        }
        #expect(MarkdownSyntaxReference.markdown.contains("| Syntax | Means |"))
    }
}
