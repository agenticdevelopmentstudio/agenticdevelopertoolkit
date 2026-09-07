import Testing
import AppKit
import AgenticDeveloperToolkit
@testable import AgenticDeveloperToolkitUI

/// The drawer that slides out beside a window. It knows about tabs and about
/// NSDrawer's two sharp edges; it does not know what any tab contains.
@MainActor
@Suite("WindowDrawer")
struct WindowDrawerTests {

    private func makeWindow() -> NSWindow {
        NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false)
    }

    private func tab(_ id: String, _ title: String) -> DrawerTab {
        DrawerTab(id: id, title: title, symbolName: "questionmark.circle") {
            let view = NSView()
            view.accessibilityID("drawer.body.\(id)")
            return view
        }
    }

    @Test("a drawer starts closed and selects its first tab")
    func startsClosed() {
        let drawer = WindowDrawer(
            parentWindow: makeWindow(),
            accessibilityPrefix: "project.drawer",
            tabs: [tab("help", "Help")])
        #expect(drawer.isOpen == false)
        #expect(drawer.selectedTabID == "help")
    }

    @Test("opening while naming a tab selects it")
    func openSelects() {
        let drawer = WindowDrawer(
            parentWindow: makeWindow(),
            accessibilityPrefix: "project.drawer",
            tabs: [tab("help", "Help"), tab("outline", "Outline")])
        drawer.open(selecting: "outline")
        #expect(drawer.selectedTabID == "outline")
    }

    /// The help button's contract: clicking it discloses the drawer *and*
    /// lands on the help tab, whichever tab was showing last.
    @Test("toggling to a named tab opens on that tab even if another was showing")
    func toggleSwitchesTabs() {
        let drawer = WindowDrawer(
            parentWindow: makeWindow(),
            accessibilityPrefix: "project.drawer",
            tabs: [tab("help", "Help"), tab("outline", "Outline")])

        drawer.open(selecting: "outline")
        drawer.toggle(selecting: "help")
        #expect(drawer.selectedTabID == "help")

        // Already open on help — a second toggle closes it.
        drawer.toggle(selecting: "help")
        #expect(drawer.selectedTabID == "help")
    }

    @Test("an unknown tab id is ignored rather than blanking the drawer")
    func unknownTabIgnored() {
        let drawer = WindowDrawer(
            parentWindow: makeWindow(),
            accessibilityPrefix: "project.drawer",
            tabs: [tab("help", "Help")])
        drawer.open(selecting: "nonexistent")
        #expect(drawer.selectedTabID == "help")
    }

    /// A segmented control with one segment is a button that does nothing.
    @Test("the tab strip is hidden while there is only one tab")
    func singleTabHidesTheStrip() {
        let one = WindowDrawer(
            parentWindow: makeWindow(),
            accessibilityPrefix: "project.drawer",
            tabs: [tab("help", "Help")])
        #expect(one.tabStripIsHidden == true)

        let two = WindowDrawer(
            parentWindow: makeWindow(),
            accessibilityPrefix: "project.drawer",
            tabs: [tab("help", "Help"), tab("outline", "Outline")])
        #expect(two.tabStripIsHidden == false)
    }

    @Test("each tab's view is made once and kept")
    func viewsAreMadeOnceAndKept() {
        let drawer = WindowDrawer(
            parentWindow: makeWindow(),
            accessibilityPrefix: "project.drawer",
            tabs: [tab("help", "Help")])
        let first = drawer.view(forTab: "help")
        let second = drawer.view(forTab: "help")
        #expect(first != nil)
        #expect(first === second)
        #expect(drawer.view(forTab: "nope") == nil)
    }

    @Test("visibility changes are announced")
    func announcesVisibility() {
        let drawer = WindowDrawer(
            parentWindow: makeWindow(),
            accessibilityPrefix: "project.drawer",
            tabs: [tab("help", "Help")])
        var announcements = 0
        drawer.onVisibilityChange = { announcements += 1 }
        drawer.open(selecting: nil)
        drawer.close()
        #expect(announcements == 2)
    }

    @Test("the tab strip is addressable")
    func stripIsIdentified() {
        let drawer = WindowDrawer(
            parentWindow: makeWindow(),
            accessibilityPrefix: "project.drawer",
            tabs: [tab("help", "Help"), tab("outline", "Outline")])
        #expect(drawer.tabStrip.accessibilityIdentifier() == "project.drawer.tabs")
    }

    /// A UI test has to find the drawer itself, not only its tab strip — and
    /// with one tab the strip is hidden, so it is the only handle there is.
    @Test("the drawer's own content is addressable")
    func drawerIsIdentified() {
        let drawer = WindowDrawer(
            parentWindow: makeWindow(),
            accessibilityPrefix: "project.drawer",
            tabs: [tab("help", "Help")])
        #expect(drawer.contentView.accessibilityIdentifier() == "project.drawer")
    }

    /// Which tab is showing is a fact about the drawer, so the drawer states
    /// it — rather than leaving a UI test to infer it from whatever the tab's
    /// own view happened to tag itself.
    @Test("the body says which tab it is showing")
    func bodyNamesTheSelectedTab() {
        let drawer = WindowDrawer(
            parentWindow: makeWindow(),
            accessibilityPrefix: "project.drawer",
            tabs: [tab("help", "Help"), tab("outline", "Outline")])
        #expect(drawer.bodyView.accessibilityIdentifier() == "project.drawer.tab.help")

        drawer.open(selecting: "outline")
        #expect(drawer.bodyView.accessibilityIdentifier() == "project.drawer.tab.outline")
    }

    /// The owner persists the width, so the owner has to be able to read it
    /// back after the user has dragged the outer edge.
    @Test("content width round-trips, clamped to the draggable range")
    func contentWidthRoundTrips() {
        let drawer = WindowDrawer(
            parentWindow: makeWindow(),
            accessibilityPrefix: "project.drawer",
            tabs: [tab("help", "Help")])
        #expect(drawer.contentWidth == WindowDrawer.defaultContentWidth)

        drawer.contentWidth = 400
        #expect(drawer.contentWidth == 400)

        // Below the minimum the drawer cannot be dragged to, and above the
        // maximum, a remembered value is nonsense — clamp rather than obey.
        drawer.contentWidth = 10
        #expect(drawer.contentWidth == 220)
        drawer.contentWidth = 10_000
        #expect(drawer.contentWidth == 520)
    }
}
