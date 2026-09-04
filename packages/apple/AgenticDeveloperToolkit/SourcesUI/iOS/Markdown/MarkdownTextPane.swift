import UIKit
import AgenticDeveloperToolkit

/// The iOS half of the pane. Its API matches the macOS file exactly — that
/// equality is what lets `MarkdownViewerController` and
/// `MarkdownEditorController` live in `Shared/` with no branching.
@MainActor
public final class MarkdownTextPane: UIView {

    private let textView = UITextView()

    public var onTextChange: ((String) -> Void)?

    public init(editable: Bool) {
        super.init(frame: .zero)

        textView.isEditable = editable
        textView.isSelectable = true
        textView.alwaysBounceVertical = true
        textView.autocorrectionType = .no
        textView.smartQuotesType = .no
        textView.smartDashesType = .no
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textView.delegate = self

        textView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textView)
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor),
            textView.topAnchor.constraint(equalTo: topAnchor),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    public var isEditable: Bool {
        get { textView.isEditable }
        set { textView.isEditable = newValue }
    }

    public var text: String {
        get { textView.text ?? "" }
        set { textView.text = newValue }
    }

    public var attributedText: NSAttributedString {
        textView.attributedText ?? NSAttributedString()
    }

    public func setAttributedText(_ text: NSAttributedString) {
        textView.attributedText = text
    }

    public func applyTheme(_ palette: SemanticPalette) {
        let background = palette.uiColor(.windowBackground)
        backgroundColor = background
        textView.backgroundColor = background
        textView.textColor = palette.uiColor(.primaryText)
        textView.tintColor = palette.uiColor(.cursor)
        textView.font = palette.font(.code)
    }
}

extension MarkdownTextPane: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        onTextChange?(textView.text ?? "")
    }
}
