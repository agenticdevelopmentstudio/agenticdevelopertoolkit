import Testing
import Foundation
@testable import AgenticDeveloperToolkit

@Suite("MarkdownText")
struct MarkdownTextTests {

    @Test("the title is the first heading, without its hashes")
    func titleFromHeading() {
        #expect(MarkdownText.deriveTitle("# Release notes\n\nbody\n") == "Release notes")
    }

    @Test("a document with no heading uses its first line of prose")
    func titleFromProse() {
        #expect(MarkdownText.deriveTitle("just some prose\nand more\n") == "just some prose")
    }

    @Test("frontmatter is not a title")
    func titleSkipsFrontmatter() {
        #expect(MarkdownText.deriveTitle("---\ntitle: Meta\n---\n# Real\n") == "Real")
    }

    @Test("a fenced code block is not a title")
    func titleSkipsCodeFences() {
        #expect(MarkdownText.deriveTitle("```\nlet x = 1\n```\n\nReal title\n") == "Real title")
    }

    @Test("inline syntax is stripped out of the title")
    func titleStripsInlineSyntax() {
        #expect(MarkdownText.deriveTitle("## **Bold** and `code` and [a link](http://x)\n")
                == "Bold and code and a link")
    }

    @Test("an empty document has no title to derive")
    func titleFallsBack() {
        #expect(MarkdownText.deriveTitle("   \n\n") == MarkdownText.untitled)
        #expect(MarkdownText.deriveTitle("") == MarkdownText.untitled)
    }

    @Test("a very long first line is capped rather than stored whole")
    func titleIsCapped() {
        let title = MarkdownText.deriveTitle(String(repeating: "a", count: 900))
        #expect(title.count == MarkdownText.titleCharacterLimit)
    }

    @Test("the excerpt takes the lines after the title, capped in count and width")
    func excerptTakesFollowingLines() {
        let content = "# Title\n\nfirst\nsecond\nthird\nfourth\nfifth\n"
        #expect(MarkdownText.deriveExcerpt(content) == "first\nsecond\nthird\nfourth")
    }

    @Test("each excerpt line is truncated on its own")
    func excerptTruncatesEachLine() {
        let content = "# Title\n\n" + String(repeating: "b", count: 400) + "\n"
        let excerpt = MarkdownText.deriveExcerpt(content)
        #expect(excerpt.count == MarkdownText.excerptLineCharacters)
    }

    @Test("a title-only document has an empty excerpt")
    func excerptCanBeEmpty() {
        #expect(MarkdownText.deriveExcerpt("# Title\n") == "")
    }

    @Test("the content hash is a stable lowercase SHA-256 of the UTF-8 bytes")
    func contentHashIsStable() {
        // `printf 'abc' | shasum -a 256`
        #expect(MarkdownText.contentHash("abc")
                == "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad")
        #expect(MarkdownText.contentHash("") == MarkdownText.contentHash(""))
    }

    @Test("byteLength counts UTF-8 bytes, not characters")
    func byteLengthCountsBytes() {
        #expect(MarkdownText.byteLength("é") == 2)
        #expect(MarkdownText.byteLength("abc") == 3)
    }

    @Test("CRLF content does not leak a carriage return into the title or excerpt")
    func crlfLineEndings() {
        let content = "# Shopping list\r\n\r\nMilk\r\nBread\r\n"
        #expect(MarkdownText.deriveTitle(content) == "Shopping list")
        #expect(!MarkdownText.deriveExcerpt(content).contains("\r"))
    }

    @Test("a document that is only frontmatter has no title or excerpt of its own")
    func frontmatterOnly() {
        let content = "---\ntitle: Ignored\n---\n"
        #expect(MarkdownText.deriveTitle(content) == MarkdownText.untitled)
        #expect(MarkdownText.deriveExcerpt(content).isEmpty)
    }
}
