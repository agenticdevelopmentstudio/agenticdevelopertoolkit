import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif
import AgenticDeveloperToolkit

/// GitHub's alert callouts, which adh's markdown authors use.
///
/// Each maps onto a semantic role the theme already defines, so an alert is
/// coloured by the same rule that colours a warning banner anywhere else.
public enum MarkdownAlert: String, Sendable, CaseIterable {
    case note
    case tip
    case important
    case warning
    case caution

    public var role: ThemeRole {
        switch self {
        case .note: return .info
        case .tip: return .success
        case .important: return .accent
        case .warning: return .warning
        case .caution: return .danger
        }
    }

    public var label: String { rawValue.uppercased() }
}

/// Renders a whole markdown *document*, as opposed to the message fragment
/// `MarkdownRenderer` handles.
///
/// The three differences are all document-only, which is why they are here and
/// not in the renderer: a chat bubble has no frontmatter to hide, and a message
/// that says `> [!NOTE]` means to show those characters.
public struct MarkdownDocumentRenderer: Sendable {

    private let renderer: MarkdownRenderer

    public init(highlighter: (any CodeHighlighter)? = nil) {
        self.renderer = MarkdownRenderer(highlighter: highlighter)
    }

    public func render(
        _ content: String,
        palette: SemanticPalette,
        textColor: PlatformColor
    ) -> NSAttributedString {
        let body = Frontmatter.split(content).body
        let prepared = Self.rewriteTaskListMarkers(in: Self.hardenQuoteLineBreaks(in: body))
        let rendered = NSMutableAttributedString(
            attributedString: renderer.render(prepared, palette: palette, textColor: textColor))
        Self.collapseTaskListMarkers(in: rendered)
        Self.colorAlertLabels(in: rendered, palette: palette)
        return rendered
    }

    // MARK: - Blockquote line breaks

    /// `AttributedString(markdown:)` treats a single newline inside a block as
    /// a soft break and collapses it to a space, so a two-line `> [!WARNING]` /
    /// `> mind the gap` quote would otherwise render as one run-on line. A
    /// trailing hard-break (two spaces before the newline) is CommonMark for
    /// "keep this line break", which the parser honours as a literal `\n` —
    /// so every quote line that is followed by another quote line gets one.
    /// Only quote lines outside a fence are touched.
    static func hardenQuoteLineBreaks(in source: String) -> String {
        let lines = source.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        var result: [String] = []
        var insideFence = false
        for (index, text) in lines.enumerated() {
            if text.trimmingCharacters(in: .whitespaces).hasPrefix("```") {
                insideFence.toggle()
                result.append(text)
                continue
            }
            guard !insideFence else { result.append(text); continue }
            let isQuoteLine = text.trimmingCharacters(in: .whitespaces).hasPrefix(">")
            let nextIsQuoteLine = index + 1 < lines.count
                && lines[index + 1].trimmingCharacters(in: .whitespaces).hasPrefix(">")
            result.append(isQuoteLine && nextIsQuoteLine ? text + "  " : text)
        }
        return result.joined(separator: "\n")
    }

    // MARK: - Task lists

    /// `AttributedString(markdown:)` leaves GFM's `[ ]` / `[x]` as literal text
    /// inside the list item, so the substitution happens on the source. Only
    /// list-item lines outside a fence are touched.
    static func rewriteTaskListMarkers(in source: String) -> String {
        var lines: [String] = []
        var insideFence = false
        for line in source.split(separator: "\n", omittingEmptySubsequences: false) {
            let text = String(line)
            if text.trimmingCharacters(in: .whitespaces).hasPrefix("```") {
                insideFence.toggle()
                lines.append(text)
                continue
            }
            guard !insideFence else { lines.append(text); continue }
            lines.append(
                text.replacingOccurrences(
                    of: "^(\\s*[-*+]\\s+)\\[ \\]\\s+",
                    with: "$1☐\u{00A0}",
                    options: .regularExpression
                ).replacingOccurrences(
                    of: "^(\\s*[-*+]\\s+)\\[[xX]\\]\\s+",
                    with: "$1☑\u{00A0}",
                    options: .regularExpression
                ))
        }
        return lines.joined(separator: "\n")
    }

    /// The renderer has no notion of a task list, so a rewritten item still
    /// renders through the ordinary bullet path: `"•\t☐\u{00A0}todo"`. A task
    /// item shows only its checkbox where an ordinary item shows a bullet, so
    /// the bullet, its tab, and the marker's non-breaking space collapse into
    /// the checkbox followed by a plain tab — the same shape
    /// `MarkdownRenderer` gives every other list marker.
    static func collapseTaskListMarkers(in rendered: NSMutableAttributedString) {
        for checkbox in ["☐", "☑"] {
            let target = "•\t\(checkbox)\u{00A0}"
            let replacement = "\(checkbox)\t"
            var searchStart = 0
            while searchStart < rendered.length {
                let searchRange = NSRange(location: searchStart, length: rendered.length - searchStart)
                let found = (rendered.string as NSString).range(of: target, range: searchRange)
                guard found.location != NSNotFound else { break }
                rendered.replaceCharacters(
                    in: found,
                    with: NSAttributedString(
                        string: replacement,
                        attributes: rendered.attributes(at: found.location, effectiveRange: nil)))
                searchStart = found.location + (replacement as NSString).length
            }
        }
    }

    // MARK: - Alerts

    /// A rendered blockquote whose first line is exactly an alert tag: recolour
    /// the whole quote and replace the tag with its label.
    static func colorAlertLabels(in rendered: NSMutableAttributedString, palette: SemanticPalette) {
        for alert in MarkdownAlert.allCases {
            let tag = "[!\(alert.label)]"
            var searchStart = 0
            while searchStart < rendered.length {
                let searchRange = NSRange(location: searchStart, length: rendered.length - searchStart)
                let found = (rendered.string as NSString).range(of: tag, range: searchRange)
                guard found.location != NSNotFound else { break }

                // Only a tag that opens its own line is an alert; one in the
                // middle of a sentence is just text.
                let opensLine = found.location == 0
                    || (rendered.string as NSString).substring(
                        with: NSRange(location: found.location - 1, length: 1)) == "\n"
                guard opensLine else {
                    searchStart = found.location + found.length
                    continue
                }

                rendered.replaceCharacters(
                    in: found,
                    with: NSAttributedString(
                        string: alert.label,
                        attributes: rendered.attributes(at: found.location, effectiveRange: nil)))

                let quoteRange = Self.paragraphRange(in: rendered, from: found.location)
                rendered.addAttribute(
                    .foregroundColor,
                    value: palette.platformColor(alert.role),
                    range: quoteRange)
                searchStart = quoteRange.location + quoteRange.length
            }
        }
    }

    /// From `location` to the end of the block — the run of text before the
    /// next blank line, which is what the renderer puts between blocks.
    private static func paragraphRange(in rendered: NSAttributedString, from location: Int) -> NSRange {
        let text = rendered.string as NSString
        let tail = NSRange(location: location, length: text.length - location)
        let blankLine = text.range(of: "\n\n", range: tail)
        let end = blankLine.location == NSNotFound ? text.length : blankLine.location
        return NSRange(location: location, length: end - location)
    }
}
