import Foundation

/// A document split at its frontmatter fence.
///
/// `prefix + body` always reproduces the original content byte for byte, so a
/// document can be opened, re-serialised and stored without being rewritten.
public struct FrontmatterSplit: Equatable, Sendable {
    /// The fenced block including both `---` lines and the newline that ends
    /// the closing fence, exactly as written. Empty when there is no block.
    public let prefix: String
    /// The text between the fences, with no trailing newline. `nil` when there
    /// is no block — which is not the same as an empty block.
    public let block: String?
    /// Everything after `prefix`.
    public let body: String

    public init(prefix: String, block: String?, body: String) {
        self.prefix = prefix
        self.block = block
        self.body = body
    }
}

/// The `---`-fenced YAML-ish header that adh writes at the top of a markdown
/// document.
///
/// This is deliberately not a YAML parser. adh's own reader takes flat
/// `key: value` scalars and ignores everything else, and a local reader that
/// understood more would disagree with the server about what a document says.
/// Anything unreadable is skipped, never thrown — a malformed header must not
/// make a document unopenable.
public enum Frontmatter {

    /// `^---\r?\n([\s\S]*?)\r?\n---[ \t]*\r?\n?` — adh's `FRONTMATTER_RE`.
    private static let pattern = "^---\\r?\\n([\\s\\S]*?)\\r?\\n---[ \\t]*\\r?\\n?"

    private static let regex: NSRegularExpression = {
        // The pattern is a literal, so a throw here is a programmer error.
        // swiftlint:disable:next force_try
        try! NSRegularExpression(pattern: pattern, options: [])
    }()

    public static func split(_ content: String) -> FrontmatterSplit {
        let full = NSRange(content.startIndex..<content.endIndex, in: content)
        guard let match = regex.firstMatch(in: content, options: [.anchored], range: full),
              let matchRange = Range(match.range, in: content),
              let blockRange = Range(match.range(at: 1), in: content) else {
            return FrontmatterSplit(prefix: "", block: nil, body: content)
        }
        return FrontmatterSplit(
            prefix: String(content[matchRange]),
            block: String(content[blockRange]),
            body: String(content[matchRange.upperBound...])
        )
    }

    public static func parse(_ block: String) -> [String: String] {
        var values: [String: String] = [:]
        for line in block.split(separator: "\n", omittingEmptySubsequences: false) {
            guard let pair = scalarPair(in: String(line)) else { continue }
            values[pair.key] = pair.value
        }
        return values
    }

    public static func value(_ key: String, in content: String) -> String? {
        guard let block = split(content).block else { return nil }
        return parse(block)[key]
    }

    /// Rewrites one key, preserving every other line verbatim.
    ///
    /// Passing `nil` removes the key; removing the last key removes the whole
    /// block, so a document never carries an empty fence.
    public static func setting(_ key: String, to value: String?, in content: String) -> String {
        let parts = split(content)

        guard let block = parts.block else {
            guard let value else { return content }
            return "---\n\(key): \(serialize(value))\n---\n" + content
        }

        var lines = block.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let index = lines.firstIndex { scalarPair(in: $0)?.key == key }

        switch (index, value) {
        case let (index?, value?):
            lines[index] = "\(key): \(serialize(value))"
        case let (index?, nil):
            lines.remove(at: index)
        case let (nil, value?):
            lines.append("\(key): \(serialize(value))")
        case (nil, nil):
            return content
        }

        let remaining = lines.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        guard !remaining.isEmpty else { return parts.body }
        return "---\n" + lines.joined(separator: "\n") + "\n---\n" + parts.body
    }

    /// The parsed block as canonical JSON — sorted keys, no whitespace — ready
    /// for the `frontmatter` column. `nil` when the document has no block.
    public static func jsonText(for content: String) -> String? {
        guard let block = split(content).block else { return nil }
        let values = parse(block)
        guard let data = try? JSONSerialization.data(
            withJSONObject: values,
            options: [.sortedKeys, .withoutEscapingSlashes]
        ) else { return nil }
        return String(decoding: data, as: UTF8.self)
    }

    // MARK: - Lines

    private static func scalarPair(in line: String) -> (key: String, value: String)? {
        // A leading space means a nested mapping or a list item — adh's reader
        // does not descend, so neither does this one.
        guard let first = line.first, !first.isWhitespace, first != "#" else { return nil }
        guard let colon = line.firstIndex(of: ":") else { return nil }
        let key = String(line[line.startIndex..<colon]).trimmingCharacters(in: .whitespaces)
        guard !key.isEmpty else { return nil }
        let raw = String(line[line.index(after: colon)...]).trimmingCharacters(in: .whitespaces)
        return (key, unquote(raw))
    }

    private static func unquote(_ value: String) -> String {
        guard value.count >= 2, let first = value.first, let last = value.last,
              first == last, first == "\"" || first == "'" else { return value }
        return String(value.dropFirst().dropLast())
    }

    private static func serialize(_ value: String) -> String {
        // Quote only when a bare scalar would be ambiguous — so `pinned: true`
        // stays `pinned: true` and a title with a colon survives the round trip.
        let needsQuotes = value.isEmpty
            || value.contains(":")
            || value.contains("#")
            || value.first?.isWhitespace == true
            || value.last?.isWhitespace == true
        guard needsQuotes else { return value }
        return "\"" + value.replacingOccurrences(of: "\"", with: "\\\"") + "\""
    }
}
