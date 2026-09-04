import Foundation

public struct MarkdownSyntaxRow: Equatable, Sendable {
    public let syntax: String
    public let meaning: String

    public init(syntax: String, meaning: String) {
        self.syntax = syntax
        self.meaning = meaning
    }
}

/// The syntax the editor's renderer actually handles, in the order a writer
/// meets it. Anything absent here is a gap in the renderer, not in the help.
public enum MarkdownSyntaxReference {

    public static let rows: [MarkdownSyntaxRow] = [
        MarkdownSyntaxRow(syntax: "# Heading", meaning: "Heading, one to six hashes"),
        MarkdownSyntaxRow(syntax: "**bold**", meaning: "Bold"),
        MarkdownSyntaxRow(syntax: "*italic*", meaning: "Italic"),
        MarkdownSyntaxRow(syntax: "~~struck~~", meaning: "Strikethrough"),
        MarkdownSyntaxRow(syntax: "- item", meaning: "Bulleted list"),
        MarkdownSyntaxRow(syntax: "1. item", meaning: "Numbered list"),
        MarkdownSyntaxRow(syntax: "- [ ] task", meaning: "Task list; use [x] when done"),
        MarkdownSyntaxRow(syntax: "> quote", meaning: "Blockquote"),
        MarkdownSyntaxRow(syntax: "> [!NOTE]", meaning: "Callout: NOTE, TIP, IMPORTANT, WARNING, CAUTION"),
        MarkdownSyntaxRow(syntax: "`code`", meaning: "Inline code"),
        MarkdownSyntaxRow(syntax: "```lang", meaning: "Fenced code block"),
        MarkdownSyntaxRow(syntax: "[text](url)", meaning: "Link"),
        MarkdownSyntaxRow(syntax: "| a | b |", meaning: "Table row; follow the header with | --- |"),
        MarkdownSyntaxRow(syntax: "---", meaning: "Horizontal rule; at the very top, frontmatter")
    ]

    /// The reference as a markdown table, so the help sheet is rendered by the
    /// same code it documents.
    public static var markdown: String {
        var lines = ["## Markdown syntax", "", "| Syntax | Means |", "| --- | --- |"]
        for row in rows {
            lines.append("| `\(row.syntax)` | \(row.meaning) |")
        }
        return lines.joined(separator: "\n")
    }
}
