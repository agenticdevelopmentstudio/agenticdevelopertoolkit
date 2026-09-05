import Testing
import AppKit
import Foundation
@testable import AgenticDeveloperToolkitUI

/// The one genuinely platform-specific pane test: driving the real `NSTextView`
/// so this exercises the pane's `delegate = self` wiring rather than only the
/// delegate method's body in isolation. Everything else about the pane is
/// asserted once, for both platforms, in `TestsUI/Shared`.
@MainActor
@Suite("MarkdownTextPane input (AppKit)")
struct MarkdownTextPaneInputTests {

    @Test("a simulated user edit fires onTextChange with the new text")
    func userEditFiresOnTextChange() {
        let pane = MarkdownTextPane(editable: true)
        var received: String?
        pane.onTextChange = { received = $0 }

        let textView = pane.subviews
            .compactMap { $0 as? NSScrollView }
            .first?.documentView as? NSTextView
        textView?.insertText("typed", replacementRange: NSRange(location: 0, length: 0))

        #expect(received == "typed")
    }
}
