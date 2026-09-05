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

    /// The value of `key`, but **only when a YAML parser would type it as a
    /// string** — otherwise `nil`, exactly as adh's `firstNonEmpty` drops a
    /// value that fails `typeof v === 'string'`.
    ///
    /// `value(_:in:)` returns the same key stringified, which is what every
    /// other caller wants; the title derivation cannot use it, because it
    /// cannot tell `title: 42` (a number, which adh ignores) from
    /// `title: "42"` (a string, which adh takes), and a document whose
    /// frontmatter carries `title: >-` above a folded block would otherwise be
    /// titled with the literal indicator `>-`.
    ///
    /// **This is an approximation of a YAML parser, not one.** Adding a YAML
    /// dependency to a foundation-tier package that compiles into five
    /// platforms is not a trade this reader gets to make. The residual
    /// divergence from adh: a real parser returns *null for the whole block*
    /// when it is malformed — an undefined alias, a top-level sequence — and
    /// this reader still reads keys out of such a block.
    ///
    /// The last occurrence of a duplicated key wins, as it does in `parse`.
    public static func stringValue(_ key: String, in content: String) -> String? {
        guard let block = split(content).block else { return nil }
        var found: String?
        for line in block.split(omittingEmptySubsequences: false, whereSeparator: { $0.isNewline }) {
            guard let pair = rawScalarPair(in: String(line)), pair.key == key else { continue }
            found = YAMLScalar.isString(pair.value) ? unquote(pair.value) : nil
        }
        return found
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
        guard let raw = rawScalarPair(in: line) else { return nil }
        return (raw.key, unquote(raw.value))
    }

    /// The same pair, with the value left exactly as it was written — quotes
    /// and all. `stringValue` needs the raw text, because whether a scalar was
    /// quoted is what decides its YAML type.
    private static func rawScalarPair(in line: String) -> (key: String, value: String)? {
        // A leading space means a nested mapping or a list item — adh's reader
        // does not descend, so neither does this one.
        guard let first = line.first, !first.isWhitespace, first != "#" else { return nil }
        guard let colon = line.firstIndex(of: ":") else { return nil }
        let key = String(line[line.startIndex..<colon]).trimmingCharacters(in: .whitespaces)
        guard !key.isEmpty else { return nil }
        let raw = String(line[line.index(after: colon)...]).trimmingCharacters(in: .whitespaces)
        return (key, raw)
    }

    /// The exact inverse of `serialize`.
    ///
    /// A double-quoted scalar carries YAML's backslash escapes. Exactly five
    /// are recognised — `\"` → `"`, `\\` → `\`, `\n` → newline, `\r` →
    /// carriage return, `\t` → tab — which is precisely the set `serialize`
    /// can produce. **Any other escape is preserved verbatim, backslash
    /// included**: a sequence this file did not write is a sequence it does not
    /// understand, and dropping the backslash silently rewrites the document
    /// (`title: "C:\Users\me"` used to read back as `C:Usersme`, and that
    /// mangled value then synced as a genuine edit).
    ///
    /// Without the `\"`/`\\` cases a title like `Re: the "big" rewrite` gained
    /// a backslash layer on every save/load cycle. A single-quoted scalar has
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
                switch character {
                case "\"": result.append("\"")
                case "\\": result.append("\\")
                case "n": result.append("\n")
                case "r": result.append("\r")
                case "t": result.append("\t")
                default: result.append("\\"); result.append(character)
                }
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
        guard YAMLScalar.needsQuoting(value) else { return value }
        // Backslash first: escaping the quotes first would then escape the
        // backslashes this step just wrote. CRLF before LF and CR, because
        // Swift groups `"\r\n"` into one grapheme cluster and neither
        // single-character replacement would find it.
        let escaped = value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\r\n", with: "\\r\\n")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
            .replacingOccurrences(of: "\t", with: "\\t")
        return "\"" + escaped + "\""
    }
}

/// What YAML would make of a bare (unquoted) scalar.
///
/// One predicate with two call sites, so the reader and the writer cannot
/// drift apart: `Frontmatter.stringValue` uses `isString` to drop a value adh
/// would drop (`typeof v === 'string'` is load-bearing in its `firstNonEmpty`),
/// and `Frontmatter.serialize` uses `needsQuoting` so a value we write is a
/// value adh reads back as the same string. An unquoted `title: 42` is a
/// *number* to adh: it falls through to the body heading, and the title column
/// then flips on every sync round trip.
///
/// This approximates YAML 1.2's core schema; it is not a parser. `needsQuoting`
/// is deliberately the more conservative of the two — it also quotes YAML 1.1's
/// `yes`/`no`/`on`/`off` booleans and anything opening with an indicator
/// character, because a writer that over-quotes only costs two bytes while a
/// writer that under-quotes changes a document's meaning.
enum YAMLScalar {

    /// `true` when a parser would type this scalar, exactly as written, as a
    /// string. A quoted scalar always is; a bare one is unless it reads as a
    /// number, a boolean, a null, a flow collection or a block-scalar header.
    static func isString(_ raw: String) -> Bool {
        if raw.hasPrefix("\"") || raw.hasPrefix("'") { return true }
        if raw.isEmpty { return false }
        if isNull(raw) || isBoolean(raw) || isNumber(raw) { return false }
        if raw.hasPrefix("[") || raw.hasPrefix("{") { return false }
        if isBlockScalarHeader(raw) { return false }
        return true
    }

    /// `true` when emitting `value` bare would not read back as the same
    /// string — because the line would not parse, because a reader would type
    /// it as something other than a string, or because it opens with a
    /// character YAML reserves.
    static func needsQuoting(_ value: String) -> Bool {
        if value.isEmpty { return true }
        // A raw newline would end the line: at best the tail is dropped, at
        // worst it injects a key or closes the `---` fence and promotes the
        // rest into the body.
        if value.contains(where: \.isNewline) { return true }
        if value.contains("\t") || value.contains(":") || value.contains("#") { return true }
        if value.first?.isWhitespace == true || value.last?.isWhitespace == true { return true }
        if let first = value.first, indicators.contains(first) { return true }
        if !isString(value) { return true }
        return isExtendedBoolean(value)
    }

    /// YAML's indicator characters, which may not open a plain scalar. A value
    /// that itself begins with a quote is in here too: without it, `unquote`
    /// would read `"Hamlet"` back as `Hamlet` and the document would lose the
    /// author's own quotation marks on first read.
    private static let indicators: Set<Character> = [
        "-", "?", ":", ",", "[", "]", "{", "}", "#", "&", "*", "!",
        "|", ">", "'", "\"", "%", "@", "`"
    ]

    private static func isNull(_ raw: String) -> Bool {
        raw == "~" || raw.lowercased() == "null"
    }

    /// YAML 1.2's core schema: `true`/`false` in any case a reader accepts.
    private static func isBoolean(_ raw: String) -> Bool {
        let lowered = raw.lowercased()
        return lowered == "true" || lowered == "false"
    }

    /// YAML 1.1's extra booleans. Readers disagree about these, so the writer
    /// quotes them and the reader does not reject them.
    private static func isExtendedBoolean(_ raw: String) -> Bool {
        ["yes", "no", "on", "off"].contains(raw.lowercased())
    }

    private static let numberPattern = [
        "[-+]?[0-9]+",                                        // decimal int
        "0o[0-7]+",                                           // octal
        "0x[0-9a-fA-F]+",                                     // hex
        "[-+]?(?:\\.[0-9]+|[0-9]+(?:\\.[0-9]*)?)(?:[eE][-+]?[0-9]+)?",  // float
        "[-+]?\\.(?:inf|Inf|INF)",
        "\\.(?:nan|NaN|NAN)"
    ].joined(separator: "|")

    private static let number: NSRegularExpression = {
        // The pattern is a literal, so a throw here is a programmer error.
        // swiftlint:disable:next force_try
        try! NSRegularExpression(pattern: "\\A(?:" + numberPattern + ")\\z", options: [])
    }()

    private static func isNumber(_ raw: String) -> Bool {
        let range = NSRange(raw.startIndex..<raw.endIndex, in: raw)
        return number.firstMatch(in: raw, options: [], range: range) != nil
    }

    /// `>` or `|`, alone or carrying a chomping indicator and/or an explicit
    /// indent — `>-`, `|+`, `>2`, `|2-`. A document whose frontmatter opens a
    /// folded block used to be titled with the literal indicator.
    private static func isBlockScalarHeader(_ raw: String) -> Bool {
        guard let first = raw.first, first == ">" || first == "|" else { return false }
        var sawIndent = false
        var sawChomping = false
        for character in raw.dropFirst() {
            if character.isNumber, !sawIndent {
                sawIndent = true
            } else if character == "-" || character == "+", !sawChomping {
                sawChomping = true
            } else {
                return false
            }
        }
        return true
    }
}
