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
        // `.bool` means the YAML boolean, so it is emitted bare. The string
        // `"true"` would be quoted instead — `nonStringLookingValuesAreQuoted`
        // pins that half, and `settingKeepsTheCallersType` pins the pair.
        let updated = Frontmatter.setting("pinned", to: .bool(true), in: "---\ntitle: Hi\n---\nbody\n")
        #expect(updated == "---\ntitle: Hi\npinned: true\n---\nbody\n")
    }

    @Test("setting a key on a document with no block creates one")
    func settingCreatesBlock() {
        #expect(Frontmatter.setting("pinned", to: .bool(true), in: "body\n") == "---\npinned: true\n---\nbody\n")
    }

    @Test("the caller's type decides the bytes: a boolean is bare, its spelling is quoted")
    func settingKeepsTheCallersType() {
        // The one fact fix wave 3 could not express. Same characters, two
        // meanings, and adh's reader tells them apart: `stringValue` returns a
        // value only when a YAML parser would type it as a string.
        let asBool = Frontmatter.setting("k", to: .bool(true), in: "body\n")
        #expect(asBool == "---\nk: true\n---\nbody\n")
        #expect(Frontmatter.stringValue("k", in: asBool) == nil)

        let asString = Frontmatter.setting("k", to: "true", in: "body\n")
        #expect(asString == "---\nk: \"true\"\n---\nbody\n")
        #expect(Frontmatter.stringValue("k", in: asString) == "true")

        // Both still read back as the same text through `value`, which
        // stringifies — that is what keeps `isPinned` reading a legacy
        // `pinned: "true"` written before this distinction existed.
        #expect(Frontmatter.value("k", in: asBool) == "true")
        #expect(Frontmatter.value("k", in: asString) == "true")
    }

    @Test("a yaml scalar that cannot be written bare falls back to quoting")
    func yamlScalarWithNewlineFallsBackToQuoting() {
        // A caller error, and the document must survive it: a bare newline
        // would close the fence and promote the rest of the value into the
        // body. One wrong key beats a mangled document.
        let content = Frontmatter.setting("k", to: .yaml("true\nevil: yes"), in: "body\n")
        #expect(Frontmatter.split(content).body == "body\n")
        #expect(Frontmatter.value("evil", in: content) == nil)
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

    @Test("every value survives a write/read round trip unchanged")
    func valuesRoundTripThroughQuoting() {
        // `unquote` must be the exact inverse of `serialize`, or a save/load
        // cycle changes the document's bytes — and every such change syncs.
        let values = [
            "plain",
            "true",
            "Notes: part two",
            #"Re: the "big" rewrite"#,
            #"a "quoted" word"#,
            #""Hamlet""#,
            "'single'",
            "a # hash",
            "  leading spaces",
            "trailing spaces  ",
            "",
            #"back\slash"#,
            #"back\slash with "quotes" and: a colon"#,
            "\\",
            "多字节: ok"
        ]
        for value in values {
            let written = Frontmatter.setting("title", to: .string(value), in: "Body\n")
            #expect(Frontmatter.value("title", in: written) == value,
                    "round trip failed for \(value.debugDescription): wrote \(written.debugDescription)")
            #expect(Frontmatter.split(written).body == "Body\n")
        }
    }

    @Test("a round trip is idempotent — a second save changes nothing")
    func roundTripIsStable() {
        let once = Frontmatter.setting("title", to: #"Re: the "big" rewrite"#, in: "Body\n")
        let twice = Frontmatter.setting(
            "title", to: .string(Frontmatter.value("title", in: once) ?? ""), in: once)
        #expect(twice == once)
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

    // MARK: - Escapes

    @Test("an unrecognised escape keeps its backslash rather than losing it")
    func unrecognisedEscapesKeepTheirBackslash() {
        // YAML says `\U` is not an escape at all; deleting the backslash turned
        // a Windows path into `C:Usersme`, silently, on read.
        #expect(Frontmatter.value("title", in: #"---\#ntitle: "C:\Users\me"\#n---\#nbody\#n"#)
                == #"C:\Users\me"#)
        #expect(Frontmatter.value("title", in: #"---\#ntitle: "50\% done"\#n---\#nbody\#n"#)
                == #"50\% done"#)
    }

    @Test("the escapes YAML does define are still decoded")
    func recognisedEscapesAreDecoded() {
        #expect(Frontmatter.value("title", in: "---\ntitle: \"a\\nb\"\n---\nbody\n") == "a\nb")
        #expect(Frontmatter.value("title", in: "---\ntitle: \"a\\rb\"\n---\nbody\n") == "a\rb")
        #expect(Frontmatter.value("title", in: "---\ntitle: \"a\\tb\"\n---\nbody\n") == "a\tb")
        #expect(Frontmatter.value("title", in: #"---\#ntitle: "a\\b"\#n---\#nbody\#n"#) == #"a\b"#)
        #expect(Frontmatter.value("title", in: #"---\#ntitle: "a\"b"\#n---\#nbody\#n"#) == #"a"b"#)
    }

    // MARK: - Quoting on write

    @Test("a value containing a newline is quoted, so it cannot forge a second key")
    func newlineInAValueIsQuoted() {
        // Unquoted, `Meeting\nvisibility: public` would have written a second
        // line into the block and invented a key the caller never set.
        let content = Frontmatter.setting("title", to: "Meeting\nvisibility: public", in: "body\n")
        #expect(Frontmatter.value("title", in: content) == "Meeting\nvisibility: public")
        #expect(Frontmatter.parse(Frontmatter.split(content).block ?? "").keys.sorted() == ["title"])
        #expect(Frontmatter.split(content).body == "body\n")
    }

    @Test("a value containing the closing fence cannot end the block early")
    func fenceInAValueIsQuoted() {
        let content = Frontmatter.setting("title", to: "A\n---\nSECRET", in: "body\n")
        #expect(Frontmatter.value("title", in: content) == "A\n---\nSECRET")
        #expect(Frontmatter.split(content).body == "body\n")
    }

    @Test("carriage returns and tabs are quoted and escaped, not written raw")
    func controlCharactersAreQuoted() {
        let content = Frontmatter.setting("title", to: "Line1\r\nLine2\tTabbed", in: "body\n")
        #expect(content.contains(#"title: "Line1\r\nLine2\tTabbed""#))
        #expect(Frontmatter.value("title", in: content) == "Line1\r\nLine2\tTabbed")
        #expect(Frontmatter.split(content).body == "body\n")
    }

    @Test("a value YAML would type as something other than a string is quoted")
    func nonStringLookingValuesAreQuoted() {
        // Without quotes these round-trip as a bool, a number and a null — so
        // `stringValue` would refuse to read back what `setting` just wrote.
        for value in ["true", "false", "yes", "no", "null", "~", "42", "0x1f", "1e3", "-.inf"] {
            let content = Frontmatter.setting("k", to: .string(value), in: "body\n")
            #expect(content.contains("k: \"\(value)\""), "\(value) was written unquoted")
            #expect(Frontmatter.stringValue("k", in: content) == value)
        }
    }

    @Test("an ordinary word is still written bare")
    func plainValuesAreNotQuoted() {
        #expect(Frontmatter.setting("title", to: "Hello", in: "body\n") == "---\ntitle: Hello\n---\nbody\n")
    }

    // MARK: - stringValue

    @Test("stringValue reads only what YAML would type as a string")
    func stringValueRefusesNonStrings() {
        #expect(Frontmatter.stringValue("k", in: "---\nk: hello\n---\nb\n") == "hello")
        #expect(Frontmatter.stringValue("k", in: "---\nk: \"42\"\n---\nb\n") == "42")
        #expect(Frontmatter.stringValue("k", in: "---\nk: 42\n---\nb\n") == nil)
        #expect(Frontmatter.stringValue("k", in: "---\nk: true\n---\nb\n") == nil)
        #expect(Frontmatter.stringValue("k", in: "---\nk: ~\n---\nb\n") == nil)
        #expect(Frontmatter.stringValue("k", in: "---\nk: [a, b]\n---\nb\n") == nil)
        #expect(Frontmatter.stringValue("k", in: "---\nk: >-\n---\nb\n") == nil)
        // `value` is the untyped reader and keeps returning all of them.
        #expect(Frontmatter.value("k", in: "---\nk: 42\n---\nb\n") == "42")
    }
}
