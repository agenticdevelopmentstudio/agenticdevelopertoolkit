import Testing
import AppKit
import AgenticDeveloperToolkit
@testable import AgenticDeveloperToolkitUI

/// The strip across the top of a pane. It arranges four things and holds no
/// opinions about any of them.
@MainActor
@Suite("PaneTitleBarView")
struct PaneTitleBarViewTests {

    @Test("it holds a control cluster and a tagged title")
    func partsArePresent() {
        let bar = PaneTitleBarView()
        #expect(bar.subviews.contains { $0 === bar.controls })
        #expect(bar.subviews.contains { $0 === bar.titleLabel })
        #expect(bar.titleLabel.accessibilityIdentifier() == "pane.title")
    }

    /// The title truncates in the middle rather than pushing the gear off the
    /// end: the gear's *position* is the convention, and a long pane title is
    /// not a reason to move it.
    @Test("the title yields horizontally and truncates in the middle")
    func titleYields() {
        let bar = PaneTitleBarView()
        #expect(bar.titleLabel.cell?.lineBreakMode == .byTruncatingMiddle)
        #expect(bar.titleLabel.contentCompressionResistancePriority(for: .horizontal) == .defaultLow)
    }

    @Test("setting the title updates the label and its tooltip")
    func titleRoundTrips() {
        let bar = PaneTitleBarView()
        bar.title = "src/main.swift"
        #expect(bar.title == "src/main.swift")
        #expect(bar.titleLabel.stringValue == "src/main.swift")
        #expect(bar.titleLabel.toolTip == "src/main.swift")
    }

    /// The middle of the bar is the pane's to fill — a file browser's filter,
    /// a terminal's shell name. Replacing the array replaces what is shown, so
    /// content whose controls change does not leak the old ones.
    @Test("accessory views are installed and fully replaced")
    func accessoriesAreReplaceable() {
        let bar = PaneTitleBarView()
        let first = NSButton()
        bar.accessoryViews = [first]
        #expect(bar.accessoryViews == [first])
        #expect(first.superview != nil)

        let second = NSButton()
        bar.accessoryViews = [second]
        #expect(bar.accessoryViews == [second])
        #expect(first.superview == nil, "the replaced accessory is off the view tree, not just unlisted")
    }

    @Test("the gear slot takes a view and swaps it")
    func gearSlotSwaps() {
        let bar = PaneTitleBarView()
        #expect(bar.gearView == nil)

        let gear = NSButton()
        bar.gearView = gear
        #expect(bar.gearView === gear)
        #expect(gear.superview != nil)

        bar.gearView = nil
        #expect(gear.superview == nil)
    }

    /// Trailing-most, always. Everything else in the bar is variable; this is
    /// the one thing a reader can rely on finding in the same place.
    @Test("the gear sits trailing of the accessory area")
    func gearIsTrailingMost() {
        let bar = PaneTitleBarView()
        let gear = NSButton()
        let accessory = NSButton()
        bar.gearView = gear
        bar.accessoryViews = [accessory]
        bar.frame = NSRect(x: 0, y: 0, width: 400, height: PaneTitleBarView.height)
        bar.layoutSubtreeIfNeeded()

        let accessoryFrame = accessory.convert(accessory.bounds, to: bar)
        #expect(gear.frame.minX > accessoryFrame.maxX)
        #expect(accessoryFrame.minX > bar.titleLabel.frame.minX)
        #expect(bar.titleLabel.frame.minX > bar.controls.frame.maxX - 1)
    }

    @Test("it is a fixed-height strip with a hairline under it")
    func heightAndHairline() {
        let bar = PaneTitleBarView()
        #expect(PaneTitleBarView.height == 26)
        #expect(bar.subviews.contains { $0 is ThemedSeparatorView })
    }
}
