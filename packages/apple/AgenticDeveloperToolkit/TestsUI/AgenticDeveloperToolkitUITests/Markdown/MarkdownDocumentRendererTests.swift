import Testing
import AppKit
import Foundation
import AgenticDeveloperToolkit
@testable import AgenticDeveloperToolkitUI

@MainActor
@Suite("MarkdownDocumentRenderer")
struct MarkdownDocumentRendererTests {

    private var palette: SemanticPalette { SemanticPalette(theme: BuiltInThemes.solarizedDark) }

    private func render(_ text: String) -> NSAttributedString {
        MarkdownDocumentRenderer()
            .render(text, palette: palette, textColor: palette.nsColor(.primaryText))
    }

    @Test("frontmatter is a header, not content, so it is not rendered")
    func frontmatterIsDropped() {
        #expect(render("---\ntitle: Hi\npinned: true\n---\n# Body\n").string == "Body")
    }

    @Test("a document with no frontmatter renders whole")
    func noFrontmatterRendersWhole() {
        #expect(render("# Body\n").string == "Body")
    }

    @Test("an alert callout is labelled and colored by its kind")
    func alertIsLabelled() {
        let rendered = render("> [!WARNING]\n> mind the gap")
        #expect(rendered.string == "WARNING\nmind the gap")
        #expect(rendered.attributes(at: 0, effectiveRange: nil)[.foregroundColor] as? NSColor
                == palette.nsColor(.warning))
    }

    @Test("every alert kind maps to a distinct role")
    func alertKindsMapToRoles() {
        #expect(MarkdownAlert.note.role == .info)
        #expect(MarkdownAlert.tip.role == .success)
        #expect(MarkdownAlert.important.role == .accent)
        #expect(MarkdownAlert.warning.role == .warning)
        #expect(MarkdownAlert.caution.role == .danger)
    }

    @Test("an unrecognised bracket tag stays an ordinary quote")
    func unknownTagIsNotAnAlert() {
        #expect(render("> [!SHOUT]\n> hello").string == "[!SHOUT]\nhello")
    }

    @Test("a task list renders checkboxes rather than brackets")
    func taskListUsesCheckboxes() {
        #expect(render("- [ ] todo\n- [x] done").string == "☐\ttodo\n☑\tdone")
    }

    @Test("an ordinary list is untouched by the task-list rewrite")
    func ordinaryListIsUnchanged() {
        #expect(render("- plain").string == "•\tplain")
    }

    @Test("a checkbox inside a fenced block stays literal text")
    func fencedContentIsNotRewritten() {
        #expect(render("```\n- [ ] literal\n```").string.contains("- [ ] literal"))
    }
}
