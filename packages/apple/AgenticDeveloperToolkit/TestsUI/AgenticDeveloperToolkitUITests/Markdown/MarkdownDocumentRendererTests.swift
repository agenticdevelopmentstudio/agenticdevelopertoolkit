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

    @Test("a tilde fence protects its contents exactly as a backtick fence does")
    func tildeFencedContentIsNotRewritten() {
        #expect(render("~~~\n- [ ] literal\n~~~").string.contains("- [ ] literal"))
        #expect(MarkdownDocumentRenderer.fencedBlockContents(in: "~~~\n- [ ] literal\n~~~")
                == ["- [ ] literal"])
    }

    @Test("a fence marker inside a block of the other marker is content, not a close")
    func mixedFenceMarkersDoNotCloseEachOther() {
        let document = "```\n~~~\n- [ ] literal\n```\n\n- [ ] real"
        #expect(MarkdownDocumentRenderer.fencedBlockContents(in: document) == ["~~~\n- [ ] literal"])
        let rendered = render(document).string
        #expect(rendered.contains("- [ ] literal"))   // inside the block: untouched
        #expect(rendered.contains("☐"))               // outside it: a real checkbox
    }

    @Test("an alert tag documented inside a fenced block is not recoloured, but a real alert elsewhere still is")
    func alertSyntaxInsideFenceIsNotRecolored() {
        let document = """
        Here is how to write an alert:

        ```
        > [!NOTE]
        > Example only.
        ```

        > [!NOTE]
        > Real alert.
        """
        let rendered = render(document)
        #expect(rendered.string.contains("> [!NOTE]\n> Example only."))
        #expect(rendered.string.contains("NOTE\nReal alert."))

        let realAlertRange = (rendered.string as NSString).range(of: "NOTE\nReal alert.")
        #expect(realAlertRange.location != NSNotFound)
        #expect(rendered.attributes(at: realAlertRange.location, effectiveRange: nil)[.foregroundColor] as? NSColor
                == palette.nsColor(.info))
    }

    @Test("a CRLF-authored document renders identically to its LF twin")
    func crlfDocumentMatchesLFTwin() {
        let lf = "> [!WARNING]\n> mind the gap\n\n- [ ] todo\n- [x] done"
        let crlf = "> [!WARNING]\r\n> mind the gap\r\n\r\n- [ ] todo\r\n- [x] done"
        #expect(render(crlf).string == render(lf).string)
    }

    @Test("a quote line already ending in a backslash hard break is not corrupted")
    func backslashHardBreakIsPreserved() {
        let rendered = render("> line one\\\n> line two")
        #expect(rendered.string == "line one\nline two")
        #expect(!rendered.string.contains("\\"))
    }

    @Test("a nested task list item also renders a checkbox")
    func nestedTaskListUsesCheckboxes() {
        #expect(render("- [ ] todo\n  - [ ] nested").string.contains("☐\tnested"))
    }
}
