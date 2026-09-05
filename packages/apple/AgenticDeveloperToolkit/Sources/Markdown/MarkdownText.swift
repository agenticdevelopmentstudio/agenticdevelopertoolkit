import Foundation
import CryptoKit

/// The derivations adh applies to a markdown document's source: its title, its
/// excerpt, its hash and its size.
///
/// These are ports of adh's `lib/markdown.ts`, and they must stay ports. The
/// server recomputes all four on every write, so a local rule that disagreed
/// would make `title` flip on every sync round trip.
public enum MarkdownText {

    public static let excerptLines = 4
    public static let excerptLineCharacters = 160
    public static let titleCharacterLimit = 500
    public static let untitled = "Untitled"

    /// The document with its frontmatter and its fenced code blocks removed —
    /// the text a title or excerpt may be drawn from.
    ///
    /// Both fence markers are stripped, and an unterminated fence swallows
    /// everything from its opener to the end of the document: `FenceScanner`
    /// owns that rule on behalf of every call site that needs it, including
    /// the CRLF-safe line split it does internally.
    public static func titleSearchBody(_ content: String) -> String {
        FenceScanner.classify(Frontmatter.split(content).body)
            .filter { $0.role == .text }
            .map(\.text)
            .joined(separator: "\n")
    }

    /// One line with its block and inline markers removed: heading hashes,
    /// quote and list markers, emphasis, code spans, and link syntax.
    public static func stripLineSyntax(_ line: String) -> String {
        var text = line.trimmingCharacters(in: .whitespacesAndNewlines)

        // Block markers, outermost first, repeatedly: "> - # Title".
        var changed = true
        while changed {
            changed = false
            for marker in ["#", ">"] where text.hasPrefix(marker) {
                text = String(text.drop { String($0) == marker })
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                changed = true
            }
            for marker in ["- ", "* ", "+ "] where text.hasPrefix(marker) {
                text = String(text.dropFirst(marker.count)).trimmingCharacters(in: .whitespacesAndNewlines)
                changed = true
            }
            if let match = text.range(of: "^[0-9]+[.)]\\s+", options: .regularExpression) {
                text = String(text[match.upperBound...])
                changed = true
            }
            if text.hasPrefix("[ ] ") || text.hasPrefix("[x] ") || text.hasPrefix("[X] ") {
                text = String(text.dropFirst(4)).trimmingCharacters(in: .whitespacesAndNewlines)
                changed = true
            }
        }

        // Links and images: keep the label, drop the target.
        text = text.replacingOccurrences(
            of: "!?\\[([^\\]]*)\\]\\([^)]*\\)",
            with: "$1",
            options: .regularExpression
        )
        // Inline emphasis and code markers.
        text = text.replacingOccurrences(of: "[*_`~]", with: "", options: .regularExpression)
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
        for line in titleSearchBody(content).split(omittingEmptySubsequences: false, whereSeparator: { $0.isNewline }) {
            let stripped = stripLineSyntax(String(line))
            guard !stripped.isEmpty else { continue }
            return (stripped, true)
        }
        return (untitled, false)
    }

    /// Frontmatter `title`, else frontmatter `name` — each taken only when it
    /// is non-empty after trimming, which is how adh's reader takes them.
    private static func frontmatterTitle(_ content: String) -> String? {
        for key in ["title", "name"] {
            guard let raw = Frontmatter.value(key, in: content) else { continue }
            let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty { return trimmed }
        }
        return nil
    }

    /// Frontmatter `title`, else frontmatter `name`, else the first non-empty
    /// stripped body line, else `untitled` — capped at `titleCharacterLimit`
    /// whichever branch supplied it, because that is the column's width.
    public static func deriveTitle(_ content: String) -> String {
        String(resolvedTitle(content).title.prefix(titleCharacterLimit))
    }

    /// The next `excerptLines` stripped non-empty body lines, each capped at
    /// `excerptLineCharacters`.
    ///
    /// Exactly one line is skipped when the title came from the body, and none
    /// when frontmatter named it — otherwise a document whose frontmatter
    /// carries its title would lose its first body line from the preview.
    public static func deriveExcerpt(_ content: String) -> String {
        var lines: [String] = []
        var linesToSkip = resolvedTitle(content).cameFromBody ? 1 : 0
        for line in titleSearchBody(content).split(omittingEmptySubsequences: false, whereSeparator: { $0.isNewline }) {
            let stripped = stripLineSyntax(String(line))
            guard !stripped.isEmpty else { continue }
            guard linesToSkip == 0 else { linesToSkip -= 1; continue }
            lines.append(String(stripped.prefix(excerptLineCharacters)))
            if lines.count == excerptLines { break }
        }
        return lines.joined(separator: "\n")
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
