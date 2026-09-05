import Foundation
import CryptoKit

/// The derivations adh applies to a markdown document's source: its title, its
/// excerpt, its hash and its size.
///
/// These are ports of adh's `lib/markdown.ts`, and they must stay ports. The
/// server recomputes all four on every write, so a local rule that disagreed
/// would make `title` flip on every sync round trip. Where adh's rule is
/// cruder than CommonMark's, this file is crude in exactly the same way — see
/// `titleSearchBody`.
public enum MarkdownText {

    public static let excerptLines = 4
    public static let excerptLineCharacters = 160
    /// How much of a document adh's LIST endpoint looks at when it cuts an
    /// excerpt (`EXCERPT_SOURCE_CHARS`). The title is derived from the *whole*
    /// content on write; only the excerpt is windowed, so a document whose
    /// first 2 KB is all frontmatter or one code fence simply has no excerpt.
    /// `deriveExcerpt` itself takes the whole string — adh's does too — so the
    /// window is applied by the caller that stands in for adh's list row.
    public static let excerptSourceCharacters = 2000
    public static let titleCharacterLimit = 500
    public static let untitled = "Untitled"

    // MARK: - adh's regexes

    // Transcribed character-for-character from `lib/markdown.ts`, with one
    // deliberate substitution: JavaScript's non-multiline `$` matches only at
    // the very end of the string, where ICU's `$` also matches before a final
    // line terminator. `\z` is ICU's spelling of JavaScript's `$` here, so a
    // CRLF-authored line ending in `\r` is treated exactly as the server
    // treats it.

    private static let pairedBacktickFence = expression("```[\\s\\S]*?```")
    private static let pairedTildeFence = expression("~~~[\\s\\S]*?~~~")
    private static let unterminatedFence = expression("(?:^|\\n)(?:```|~~~)[\\s\\S]*\\z")

    private static let quoteMarkers = expression("^[ \\t]*(?:>[ \\t]?)+")
    private static let headingHashes = expression("^[ \\t]*#{1,6}(?=[ \\t]|\\z)[ \\t]*")
    private static let listMarker = expression("^[ \\t]*(?:[-*+]|\\d+[.)])(?=[ \\t]|\\z)[ \\t]*")

    private static func expression(_ pattern: String) -> NSRegularExpression {
        // The patterns are literals, so a throw here is a programmer error.
        // swiftlint:disable:next force_try
        try! NSRegularExpression(pattern: pattern, options: [])
    }

    private static func removing(_ expression: NSRegularExpression, from text: String) -> String {
        expression.stringByReplacingMatches(
            in: text,
            options: [],
            range: NSRange(text.startIndex..<text.endIndex, in: text),
            withTemplate: "")
    }

    /// adh splits on the `"\n"` code unit. Swift's `String` groups a `"\r\n"`
    /// pair into one extended grapheme cluster, so splitting the `Character`
    /// view on `"\n"` would not split a CRLF-authored document at all; the
    /// scalar view splits exactly where JavaScript does.
    private static func lines(of text: String) -> [String] {
        text.unicodeScalars
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { String(String.UnicodeScalarView($0)) }
    }

    // MARK: - Derivation

    /// The document with its frontmatter and its fenced code blocks removed —
    /// the text a title or excerpt may be drawn from.
    ///
    /// **This deliberately does not use `FenceScanner`, and must not.**
    /// `FenceScanner` is the *renderer's* scanner: it implements CommonMark, so
    /// a closing fence must use the opener's marker and be at least as long,
    /// and it knows nothing of a fence marker that starts mid-line. adh has
    /// none of those rules — it runs three plain regexes over the whole string,
    /// lazily pairing any three backticks with the next three. The two
    /// functions answer different questions (what does this render as? versus
    /// what does the server call this document?) and the duplication is the
    /// point: making this one "correct" would give a document a different
    /// title here than the title column adh recomputes on every write, and the
    /// two would then flip back and forth on each sync round trip.
    ///
    /// Three replacements, in adh's order; the first two are global, the third
    /// matches at most once because it runs to the end of the string. Only the
    /// third requires a line start — the paired patterns are not line-anchored,
    /// so a fence marker mid-line opens a match.
    public static func titleSearchBody(_ content: String) -> String {
        var body = Frontmatter.split(content).body
        body = removing(pairedBacktickFence, from: body)
        body = removing(pairedTildeFence, from: body)
        // An UNTERMINATED fence leaves the rest of the file inside a code
        // block, so strip from a line-starting opener to EOF.
        return removing(unterminatedFence, from: body)
    }

    /// The markdown syntax a line OPENS with, removed: blockquote arrows, ATX
    /// heading hashes, list markers. `# Hello`, `- Hello` and `> Hello` all
    /// title as `Hello`; a line that is nothing but syntax reduces to `""` and
    /// the caller keeps scanning.
    ///
    /// Three regexes, once each, in adh's order — **not** to a fixed point.
    /// `> - # Title` loses its `>`, then the heading pattern fails because the
    /// line now opens with `-`, then the list pattern strips `- `, leaving
    /// `# Title`. Nothing inline is touched: emphasis, code spans, links and
    /// GFM task markers all survive into the title, because they survive into
    /// adh's.
    public static func stripLineSyntax(_ line: String) -> String {
        var text = removing(quoteMarkers, from: line)
        text = removing(headingHashes, from: text)
        text = removing(listMarker, from: text)
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// The title, and whether the body supplied it.
    ///
    /// `deriveTitle` and `deriveExcerpt` share this one decision rather than
    /// each answering "which line was the title?" for itself — that is what
    /// keeps the two from disagreeing, and it is what tells the excerpt
    /// whether there is a body line to skip.
    static func resolvedTitle(_ content: String) -> (title: String, cameFromBody: Bool) {
        if let named = frontmatterTitle(content) { return (named, false) }
        for line in lines(of: titleSearchBody(content)) {
            let stripped = stripLineSyntax(line)
            guard !stripped.isEmpty else { continue }
            return (stripped, true)
        }
        return (untitled, false)
    }

    /// Frontmatter `title`, else frontmatter `name` — each taken only when YAML
    /// would type it as a string and it is non-empty after trimming, which is
    /// how adh's `firstNonEmpty` takes them (`typeof v === 'string'`).
    private static func frontmatterTitle(_ content: String) -> String? {
        for key in ["title", "name"] {
            guard let raw = Frontmatter.stringValue(key, in: content) else { continue }
            let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty { return trimmed }
        }
        return nil
    }

    /// Frontmatter `title`, else frontmatter `name`, else the first non-empty
    /// stripped body line, else `untitled` — capped at `titleCharacterLimit`
    /// whichever branch supplied it, because that is the column's width.
    ///
    /// Derived from the **whole** content, never a window: adh recomputes the
    /// title on every write and sees the whole document. Only the excerpt is
    /// windowed — see `excerptSourceCharacters`.
    public static func deriveTitle(_ content: String) -> String {
        String(resolvedTitle(content).title.prefix(titleCharacterLimit))
    }

    /// The next `excerptLines` stripped non-empty body lines, each capped at
    /// `excerptLineCharacters`.
    ///
    /// Exactly one line is skipped when the title came from the body, and none
    /// when frontmatter named it — otherwise a document whose frontmatter
    /// carries its title would lose its first body line from the preview.
    ///
    /// Takes the whole content, as adh's does. The list projection's 2000-
    /// character window is applied by the caller (`MarkdownDocument.excerpt`),
    /// which is where adh applies it.
    public static func deriveExcerpt(_ content: String) -> String {
        var collected: [String] = []
        var linesToSkip = resolvedTitle(content).cameFromBody ? 1 : 0
        for line in lines(of: titleSearchBody(content)) {
            let stripped = stripLineSyntax(line)
            guard !stripped.isEmpty else { continue }
            guard linesToSkip == 0 else { linesToSkip -= 1; continue }
            collected.append(String(stripped.prefix(excerptLineCharacters)))
            if collected.count == excerptLines { break }
        }
        return collected.joined(separator: "\n")
    }

    public static func contentHash(_ content: String) -> String {
        SHA256.hash(data: Data(content.utf8))
            .map { String(format: "%02x", $0) }
            .joined()
    }

    public static func byteLength(_ content: String) -> Int {
        content.utf8.count
    }
}
