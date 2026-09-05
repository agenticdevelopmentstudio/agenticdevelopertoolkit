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

    /// Lines are split on `Character.isNewline` rather than on the `"\n"`
    /// scalar: Swift's `String` groups a `"\r\n"` pair into a single
    /// extended grapheme cluster, so splitting on the `"\n"` `Character`
    /// alone silently fails to split a CRLF-authored block at all — every
    /// key but the first would be lost. (`split(_:)` above is unaffected;
    /// its fence match runs over UTF-16 code units, not `Character`s.)
    public static func parse(_ block: String) -> [String: String] {
        var values: [String: String] = [:]
        for line in block.split(omittingEmptySubsequences: false, whereSeparator: { $0.isNewline }) {
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
    ///
    /// **The rewritten block is re-emitted with LF line endings even when the
    /// document was authored with CRLF**, and the body after the closing fence
    /// keeps whatever endings it had. That is deliberate: the block is rebuilt
    /// from parsed lines, so it has to be joined with *something*, and adh
    /// writes LF. Normalising only the block keeps the change to the bytes this
    /// call already had to rewrite instead of touching the whole document.
    /// (`settingRewritesOneLineWithCRLF` pins it.)
    public static func setting(_ key: String, to value: String?, in content: String) -> String {
        let parts = split(content)

        guard let block = parts.block else {
            guard let value else { return content }
            return "---\n\(key): \(serialize(value))\n---\n" + content
        }

        // Same CRLF-grapheme-cluster hazard as `parse` above — split on
        // newline characters, not the `"\n"` scalar.
        var lines = block.split(omittingEmptySubsequences: false, whereSeparator: { $0.isNewline }).map(String.init)
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

    /// The exact inverse of `serialize`.
    ///
    /// A double-quoted scalar carries YAML's backslash escapes, so `\"` and
    /// `\\` are undone here — without that, a title like `Re: the "big"
    /// rewrite` gained a backslash layer on every save/load cycle, and each
    /// layer was a real content change that synced. A single-quoted scalar has
    /// no backslash escapes in YAML, so its contents are taken literally.
    private static func unquote(_ value: String) -> String {
        guard value.count >= 2, let first = value.first, let last = value.last,
              first == last, first == "\"" || first == "'" else { return value }
        let inner = String(value.dropFirst().dropLast())
        guard first == "\"" else { return inner }

        var result = ""
        var isEscaped = false
        for character in inner {
            if isEscaped {
                result.append(character)
                isEscaped = false
            } else if character == "\\" {
                isEscaped = true
            } else {
                result.append(character)
            }
        }
        // A trailing lone backslash is malformed; keep it rather than drop it,
        // in the same fail-soft spirit as the rest of this reader.
        if isEscaped { result.append("\\") }
        return result
    }

    private static func serialize(_ value: String) -> String {
        // Quote only when a bare scalar would be ambiguous — so `pinned: true`
        // stays `pinned: true` and a title with a colon survives the round trip.
        //
        // A value that itself begins with a quote character has to be quoted
        // too, or `unquote` would read `"Hamlet"` back as `Hamlet` and the
        // document would lose the author's own quotation marks on first read.
        let needsQuotes = value.isEmpty
            || value.contains(":")
            || value.contains("#")
            || value.first?.isWhitespace == true
            || value.last?.isWhitespace == true
            || value.first == "\""
            || value.first == "'"
        guard needsQuotes else { return value }
        // Backslash first: escaping the quotes first would then escape the
        // backslashes this step just wrote.
        let escaped = value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
        return "\"" + escaped + "\""
    }
}
