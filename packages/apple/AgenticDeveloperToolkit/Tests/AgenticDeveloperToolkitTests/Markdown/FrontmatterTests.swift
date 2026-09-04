import Testing
import Foundation
@testable import AgenticDeveloperToolkit

@Suite("Frontmatter")
struct FrontmatterTests {

    @Test("splits a leading fenced block off the body")
    func splitsLeadingBlock() {
        let split = Frontmatter.split("---\ntitle: Hi\n---\nbody text\n")
        #expect(split.block == "title: Hi")
        #expect(split.body == "body text\n")
        #expect(split.prefix == "---\ntitle: Hi\n---\n")
    }

    @Test("prefix and body always recombine into the original, byte for byte")
    func roundTripsByteIdentically() {
        let samples = [
            "---\ntitle: Hi\n---\nbody\n",
            "---\r\ntitle: Hi\r\n---\r\nbody\r\n",
            "---\ntitle: Hi\n---   \nbody\n",     // trailing spaces on the closing fence
            "---\ntitle: Hi\n---",                 // no trailing newline, no body
            "no frontmatter at all\n",
            "",
            "---\nunclosed block\nstill going\n",  // never closed: not frontmatter
            "text\n---\ntitle: late\n---\n",       // not at position 0: not frontmatter
        ]
        for sample in samples {
            let split = Frontmatter.split(sample)
            #expect(split.prefix + split.body == sample, "round trip failed for \(sample.debugDescription)")
        }
    }

    @Test("a block that is not at the very start is not frontmatter")
    func requiresPositionZero() {
        let split = Frontmatter.split("text\n---\ntitle: late\n---\n")
        #expect(split.block == nil)
        #expect(split.prefix.isEmpty)
    }

    @Test("an unterminated block is not frontmatter")
    func requiresAClosingFence() {
        #expect(Frontmatter.split("---\ntitle: Hi\nbody\n").block == nil)
    }

    @Test("parses simple scalar pairs and trims surrounding quotes")
    func parsesScalars() {
        let parsed = Frontmatter.parse("title: Hi\npinned: true\nquoted: \"a: b\"\nsingle: 'x'")
        #expect(parsed["title"] == "Hi")
        #expect(parsed["pinned"] == "true")
        #expect(parsed["quoted"] == "a: b")
        #expect(parsed["single"] == "x")
    }

    @Test("fails soft: lines it cannot read are skipped, not thrown")
    func failsSoft() {
        let parsed = Frontmatter.parse("title: Hi\n  - a list item\n# a comment\nnot a pair\npinned: true")
        #expect(parsed == ["title": "Hi", "pinned": "true"])
    }

    @Test("setting a key rewrites its line and leaves every other line untouched")
    func settingRewritesOneLine() {
        let content = "---\ntitle: Hi\nweird: 'keep me'\n---\nbody\n"
        let updated = Frontmatter.setting("title", to: "Bye", in: content)
        #expect(updated == "---\ntitle: Bye\nweird: 'keep me'\n---\nbody\n")
    }

    @Test("setting an absent key appends it to the existing block")
    func settingAppendsToBlock() {
        let updated = Frontmatter.setting("pinned", to: "true", in: "---\ntitle: Hi\n---\nbody\n")
        #expect(updated == "---\ntitle: Hi\npinned: true\n---\nbody\n")
    }

    @Test("setting a key on a document with no block creates one")
    func settingCreatesBlock() {
        #expect(Frontmatter.setting("pinned", to: "true", in: "body\n") == "---\npinned: true\n---\nbody\n")
    }

    @Test("setting a key to nil removes its line")
    func settingNilRemovesLine() {
        let updated = Frontmatter.setting("pinned", to: nil, in: "---\ntitle: Hi\npinned: true\n---\nbody\n")
        #expect(updated == "---\ntitle: Hi\n---\nbody\n")
    }

    @Test("removing the last key removes the whole block")
    func removingLastKeyRemovesBlock() {
        #expect(Frontmatter.setting("pinned", to: nil, in: "---\npinned: true\n---\nbody\n") == "body\n")
    }

    @Test("removing an absent key changes nothing at all")
    func removingAbsentKeyIsIdentity() {
        let content = "---\ntitle: Hi\n---\nbody\n"
        #expect(Frontmatter.setting("pinned", to: nil, in: content) == content)
        #expect(Frontmatter.setting("pinned", to: nil, in: "plain\n") == "plain\n")
    }

    @Test("jsonText is stable, sorted, and nil when there is no block")
    func jsonTextIsSorted() {
        #expect(Frontmatter.jsonText(for: "---\nb: 2\na: 1\n---\nbody") == #"{"a":"1","b":"2"}"#)
        #expect(Frontmatter.jsonText(for: "body") == nil)
    }

    @Test("a value needing quotes survives a write/read round trip")
    func quotedValueRoundTrips() {
        let written = Frontmatter.setting("title", to: "Notes: part two", in: "Body\n")
        #expect(Frontmatter.value("title", in: written) == "Notes: part two")
        #expect(Frontmatter.split(written).body == "Body\n")
    }

    @Test("a CRLF frontmatter block parses into its separate keys")
    func parsesCRLFBlock() {
        let parsed = Frontmatter.parse("title: Hi\r\npinned: true")
        #expect(parsed == ["title": "Hi", "pinned": "true"])
    }

    @Test("setting a key on a CRLF document rewrites its line and leaves every other line untouched")
    func settingRewritesOneLineWithCRLF() {
        let content = "---\r\ntitle: Hi\r\nweird: 'keep me'\r\n---\r\nbody\r\n"
        let updated = Frontmatter.setting("title", to: "Bye", in: content)
        #expect(updated == "---\ntitle: Bye\nweird: 'keep me'\n---\nbody\r\n")
    }
}
