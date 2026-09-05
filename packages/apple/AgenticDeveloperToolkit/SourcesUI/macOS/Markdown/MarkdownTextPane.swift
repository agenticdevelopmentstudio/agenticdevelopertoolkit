import AppKit
import AgenticDeveloperToolkit

/// A scrolling text pane with the same API on both platforms, so the markdown
/// controllers above it never branch.
@MainActor
public final class MarkdownTextPane: NSView {

    private let scrollView = NSScrollView()
    private let textView = NSTextView()

    public var onTextChange: ((String) -> Void)?

    public init(editable: Bool) {
        super.init(frame: .zero)

        textView.isEditable = editable
        textView.isSelectable = true
        textView.isRichText = false
        textView.allowsUndo = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.textContainer?.widthTracksTextView = true
        textView.textContainerInset = NSSize(width: 8, height: 8)
        textView.delegate = self

        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    public var isEditable: Bool {
        get { textView.isEditable }
        set { textView.isEditable = newValue }
    }

    /// The pane's plain-text contents.
    ///
    /// Setting this does **not** fire `onTextChange` — `NSTextViewDelegate.textDidChange`
    /// only fires from user editing, never from a programmatic assignment to
    /// `NSTextView.string`. This is load-bearing: a caller (such as an editor
    /// controller) that re-renders from `onTextChange` and writes the result
    /// back via this setter must not re-enter its own callback, or it loops.
    public var text: String {
        get { textView.string }
        set { textView.string = newValue }
    }

    public var attributedText: NSAttributedString {
        textView.attributedString()
    }

    public func setAttributedText(_ text: NSAttributedString) {
        textView.textStorage?.setAttributedString(text)
    }

    public func applyTheme(_ palette: SemanticPalette) {
        let background = palette.nsColor(.windowBackground)
        scrollView.backgroundColor = background
        textView.backgroundColor = background
        textView.textColor = palette.nsColor(.primaryText)
        textView.insertionPointColor = palette.nsColor(.cursor)
        textView.font = palette.font(.code)
        textView.selectedTextAttributes = [
            .backgroundColor: palette.nsColor(.selection),
            .foregroundColor: palette.nsColor(.selectionText)
        ]
    }
}

extension MarkdownTextPane: NSTextViewDelegate {
    public func textDidChange(_ notification: Notification) {
        onTextChange?(textView.string)
    }
}
