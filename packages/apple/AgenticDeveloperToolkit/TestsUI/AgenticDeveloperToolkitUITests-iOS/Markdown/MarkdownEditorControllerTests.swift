import Testing
import UIKit
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
        editor.view.frame = CGRect(x: 0, y: 0, width: 900, height: 600)
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
        editor.view.frame = CGRect(x: 0, y: 0, width: 900, height: 600)
        editor.view.layoutIfNeeded()
        #expect(editor.mode == .split)
        #expect(editor.editorPane.superview != nil)
        #expect(editor.viewer.view.superview != nil)
    }

    @Test("a narrow editor falls back to one pane at a time")
    func narrowEditorTabs() {
        let editor = loadedEditor("# Hi")
        editor.view.frame = CGRect(x: 0, y: 0, width: 500, height: 600)
        editor.view.layoutIfNeeded()
        #expect(editor.mode == .edit)
        #expect(editor.viewer.view.superview == nil)
    }

    @Test("an edit-only editor never offers a preview, however wide it is")
    func previewCanBeDisabled() {
        let editor = MarkdownEditorController(palette: palette)
        editor.isPreviewAvailable = false
        editor.view.frame = CGRect(x: 0, y: 0, width: 1200, height: 600)
        editor.view.layoutIfNeeded()
        #expect(editor.mode == .edit)
        #expect(editor.availableModes == [.edit])
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
