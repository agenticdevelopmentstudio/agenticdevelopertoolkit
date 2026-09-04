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
    public static func titleSearchBody(_ content: String) -> String {
        let body = Frontmatter.split(content).body
        var kept: [Substring] = []
        var insideFence = false
        for line in body.split(separator: "\n", omittingEmptySubsequences: false) {
            if line.trimmingCharacters(in: .whitespaces).hasPrefix("```") {
                insideFence.toggle()
                continue
            }
            if !insideFence { kept.append(line) }
        }
        return kept.joined(separator: "\n")
    }

    /// One line with its block and inline markers removed: heading hashes,
    /// quote and list markers, emphasis, code spans, and link syntax.
    public static func stripLineSyntax(_ line: String) -> String {
        var text = line.trimmingCharacters(in: .whitespaces)

        // Block markers, outermost first, repeatedly: "> - # Title".
        var changed = true
        while changed {
            changed = false
            for marker in ["#", ">"] where text.hasPrefix(marker) {
                text = String(text.drop { String($0) == marker })
                    .trimmingCharacters(in: .whitespaces)
                changed = true
            }
            for marker in ["- ", "* ", "+ "] where text.hasPrefix(marker) {
                text = String(text.dropFirst(marker.count)).trimmingCharacters(in: .whitespaces)
                changed = true
            }
            if let match = text.range(of: "^[0-9]+[.)]\\s+", options: .regularExpression) {
                text = String(text[match.upperBound...])
                changed = true
            }
            if text.hasPrefix("[ ] ") || text.hasPrefix("[x] ") || text.hasPrefix("[X] ") {
                text = String(text.dropFirst(4)).trimmingCharacters(in: .whitespaces)
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
        return text.trimmingCharacters(in: .whitespaces)
    }

    public static func deriveTitle(_ content: String) -> String {
        for line in titleSearchBody(content).split(separator: "\n", omittingEmptySubsequences: false) {
            let stripped = stripLineSyntax(String(line))
            guard !stripped.isEmpty else { continue }
            return String(stripped.prefix(titleCharacterLimit))
        }
        return untitled
    }

    public static func deriveExcerpt(_ content: String) -> String {
        var lines: [String] = []
        var sawTitle = false
        for line in titleSearchBody(content).split(separator: "\n", omittingEmptySubsequences: false) {
            let stripped = stripLineSyntax(String(line))
            guard !stripped.isEmpty else { continue }
            guard sawTitle else { sawTitle = true; continue }
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
