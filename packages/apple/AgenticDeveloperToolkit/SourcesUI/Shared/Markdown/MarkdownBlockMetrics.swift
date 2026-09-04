import Foundation

/// The numbers the block renderer lays out with, in one place so a document
/// viewer and a chat bubble indent the same list by the same amount.
public enum MarkdownBlockMetrics {

    /// One level of list or quote nesting.
    public static let indentStep: CGFloat = 20

    /// Tables are laid out on fixed tab stops rather than measured columns:
    /// `NSAttributedString` has no table primitive, and a measured layout would
    /// need a second pass over content the renderer streams in one.
    public static let tableColumnWidth: CGFloat = 140
    public static let tableColumnCount = 12

    /// A horizontal rule, drawn with box-drawing characters because an
    /// attributed string cannot carry a border.
    public static let thematicBreakRule = String(repeating: "─", count: 32)
}
