import Testing
import AppKit
@testable import AgenticDeveloperToolkitUI

/// The punctuation, and the box the result is shown in. Neither knows what a
/// pane is.
@MainActor
@Suite("Display path and footer host")
struct PaneDisplayPathTests {

    @Test("segments are joined with a chevron")
    func joinsSegments() {
        #expect(PaneDisplayPath.format(["api-server", "Backend", "Files"])
            == "api-server › Backend › Files")
    }

    /// A pane that describes no selection ends the path at its own name — it
    /// does not end it with a dangling separator.
    @Test("a missing segment is dropped, not rendered empty")
    func dropsMissingSegments() {
        #expect(PaneDisplayPath.format(["api-server", "Backend", "Files", nil])
            == "api-server › Backend › Files")
        #expect(PaneDisplayPath.format(["api-server", nil, "Files"])
            == "api-server › Files")
        #expect(PaneDisplayPath.format(["api-server", "", "Files"])
            == "api-server › Files")
    }

    @Test("a segment that is only whitespace is also nothing")
    func dropsBlankSegments() {
        #expect(PaneDisplayPath.format(["api-server", "   ", "Files"])
            == "api-server › Files")
    }

    @Test("segments keep the spacing inside them")
    func keepsInnerSpacing() {
        #expect(PaneDisplayPath.format(["My Project", "Tab 1"]) == "My Project › Tab 1")
    }

    @Test("nothing to say is an empty string, not a separator")
    func emptyIsEmpty() {
        #expect(PaneDisplayPath.format([]).isEmpty)
        #expect(PaneDisplayPath.format([nil, nil]).isEmpty)
    }

    @Test("the host adopts the content controller and puts the footer under it")
    func hostAdoptsContent() {
        let content = NSViewController()
        content.view = NSView()
        let host = WindowFooterContentViewController(
            contentViewController: content,
            accessibilityPrefix: "project.footer"
        )
        host.loadViewIfNeeded()

        #expect(host.children.contains { $0 === content })
        #expect(content.view.superview === host.view)
        #expect(host.footer.superview === host.view)
        #expect(host.footer.frame.minY <= content.view.frame.minY)
    }

    @Test("the host's status is the footer's status")
    func statusProxies() {
        let host = WindowFooterContentViewController(
            contentViewController: NSViewController(),
            accessibilityPrefix: "project.footer"
        )
        host.status = "api-server › Backend"
        #expect(host.footer.status == "api-server › Backend")
    }

    /// The host does not name the bar's controls itself; it hands the bar the
    /// namespace its own host chose, so one window's footer is addressable
    /// without colliding with another's.
    @Test("the host forwards its accessibility namespace to the bar")
    func forwardsAccessibilityPrefix() {
        let host = WindowFooterContentViewController(
            contentViewController: NSViewController(),
            accessibilityPrefix: "drawer.footer"
        )
        #expect(host.footer.statusLabel.accessibilityIdentifier() == "drawer.footer.status")
    }
}
