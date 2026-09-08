import Testing
import AppKit
import AgenticDeveloperToolkit
@testable import AgenticDeveloperToolkitUI

/// The gear a window puts at the trailing edge of its title bar, and the two
/// controls it hangs underneath.
@MainActor
@Suite("WindowConfigPopover")
struct WindowConfigPopoverTests {

    private func slider(in view: NSView) -> NSSlider? {
        if let slider = view as? NSSlider { return slider }
        for subview in view.subviews {
            if let found = slider(in: subview) { return found }
        }
        return nil
    }

    private func button(in view: NSView) -> NSButton? {
        if let button = view as? NSButton { return button }
        for subview in view.subviews {
            if let found = button(in: subview) { return found }
        }
        return nil
    }

    private func labels(in view: NSView) -> [String] {
        var found: [String] = []
        if let field = view as? NSTextField { found.append(field.stringValue) }
        for subview in view.subviews { found += labels(in: subview) }
        return found
    }

    // MARK: The gear

    @Test("the gear carries an icon and its own action, and starts closed")
    func gearIsWired() {
        var built = false
        let popover = WindowConfigPopover(title: "Olylo Window") {
            built = true
            return []
        }
        #expect(popover.gearButton.image != nil)
        #expect(popover.gearButton.target != nil)
        #expect(popover.gearButton.action != nil)
        #expect(popover.isShown == false)
        // The controls are a host's closure over live state, so they are built
        // when the panel first opens rather than at construction.
        #expect(built == false)
    }

    /// `NSTitlebarAccessoryViewController` lays its view out by frame, not by
    /// auto layout: a purely constraint-driven container reports zero width and
    /// never appears, which is a bug you can only see by looking at the window.
    @Test("the titlebar accessory has a real frame and holds the gear")
    func accessoryHasAFrame() {
        let popover = WindowConfigPopover(title: "Olylo Window") { [] }
        let controller = popover.makeTitlebarAccessory()
        #expect(controller.view.frame.width > 0)
        #expect(controller.view.frame.height > 0)
        #expect(controller.layoutAttribute == .right)

        var contains = false
        func walk(_ view: NSView) {
            if view === popover.gearButton { contains = true }
            view.subviews.forEach(walk)
        }
        walk(controller.view)
        #expect(contains)
    }

    @Test("leading chrome sits alongside the gear rather than replacing it")
    func accessoryKeepsLeadingViews() {
        let popover = WindowConfigPopover(title: "Olylo Window") { [] }
        let extra = NSButton(title: "x", target: nil, action: nil)
        let controller = popover.makeTitlebarAccessory(leading: [extra], width: 160)
        var seen: [NSView] = []
        func walk(_ view: NSView) {
            seen.append(view)
            view.subviews.forEach(walk)
        }
        walk(controller.view)
        #expect(seen.contains { $0 === extra })
        #expect(seen.contains { $0 === popover.gearButton })
        #expect(controller.view.frame.width == 160)
    }

    /// `install(leading:)` is the documented way for a host to put its own
    /// chrome next to the gear and it passes no width, so the *default* is the
    /// number every one of those hosts actually gets. Halving it cramps them
    /// all, and no test that passes a width explicitly would notice.
    @Test("the default accessory is wide enough for leading chrome beside the gear")
    func accessoryDefaultWidthLeavesRoom() {
        let popover = WindowConfigPopover(title: "Olylo Window") { [] }
        let controller = popover.makeTitlebarAccessory(leading: [
            NSButton(title: "Connect", target: nil, action: nil)
        ])
        #expect(controller.view.frame.width == 240)
    }

    // MARK: The panel

    @Test("the panel captions itself and lays every control out at one width")
    func panelHoldsItsControls() {
        let first = WindowConfigToggle(title: "Float", isOn: false) { _ in }
        let second = WindowConfigToggle(title: "Blink caret", isOn: true) { _ in }
        let controller = WindowConfigPopover.ContentViewController(
            title: "Olylo Window", controls: [first, second])
        // A popover sizes itself from its content's fitting size, so that —
        // not a frame nobody has set — is what the width constraint governs.
        controller.view.frame = NSRect(origin: .zero, size: controller.view.fittingSize)
        controller.view.layoutSubtreeIfNeeded()

        #expect(labels(in: controller.view).contains("Olylo Window"))
        #expect(controller.view.fittingSize.width == WindowConfigPopover.ContentViewController.popoverWidth)
        // A slider that sized to its own content would start and end somewhere
        // different in each row; every control spans the same width instead.
        #expect(first.frame.width == second.frame.width)
        #expect(first.frame.width > 0)
    }

    // MARK: The controls

    @Test("a slider reports its title and a caption of where it is")
    func sliderCaptionsItself() {
        let control = WindowConfigSlider(
            title: "Text Size", value: 1.25, range: 0.85...1.75,
            caption: { "\(Int(($0 * 100).rounded()))%" },
            onChange: { _ in })
        let text = labels(in: control)
        #expect(text.contains("Text Size"))
        // A slider between two unlabelled ends tells a reader only that they
        // have moved it; the caption is what lets them put it back.
        #expect(text.contains("125%"))
    }

    @Test("a slider clamps a stored value that has drifted outside its range")
    func sliderClampsItsStartingValue() {
        let control = WindowConfigSlider(
            title: "Text Size", value: 9, range: 0.85...1.75,
            caption: { "\($0)" }, onChange: { _ in })
        #expect(control.value == 1.75)
    }

    @Test("moving a slider reports the new value as it goes")
    func sliderReportsChanges() throws {
        var reported: [Double] = []
        let control = WindowConfigSlider(
            title: "Transparency", value: 1, range: 0.3...1.0,
            caption: { "\($0)" }, onChange: { reported.append($0) })
        let inner = try #require(slider(in: control))
        #expect(inner.isContinuous)

        inner.doubleValue = 0.5
        _ = inner.target?.perform(inner.action, with: inner)
        #expect(reported.last == 0.5)
        #expect(control.value == 0.5)
    }

    @Test("a toggle starts where it was told to and reports each flip")
    func toggleReportsChanges() throws {
        var reported: [Bool] = []
        let control = WindowConfigToggle(title: "Blink caret", isOn: true) { reported.append($0) }
        #expect(control.isOn)
        #expect(labels(in: control).isEmpty)  // the title lives on the checkbox itself

        let inner = try #require(button(in: control))
        #expect(inner.title == "Blink caret")
        inner.state = .off
        _ = inner.target?.perform(inner.action, with: inner)
        #expect(reported == [false])
        #expect(control.isOn == false)
    }

    // MARK: Opening and closing

    // Presenting for real needs a window on screen, so these drive the
    // delegate methods directly. That is the seam windows actually depend on:
    // the same two calls freeze and thaw a host's content refit.

    @Test("opening and closing report themselves to the host, in that order")
    func openCloseHooksFire() {
        let popover = WindowConfigPopover(title: "Test Window") { [NSSlider()] }
        var events: [String] = []
        popover.onWillShow = { events.append("show") }
        popover.onDidClose = { events.append("close") }

        popover.popoverWillShow(Notification(name: NSPopover.willShowNotification))
        popover.popoverDidClose(Notification(name: NSPopover.didCloseNotification))

        #expect(events == ["show", "close"])
    }

    @Test("a gear with no host window opens and closes without one")
    func hooksAreOptional() {
        let popover = WindowConfigPopover(title: "Test Window") { [NSSlider()] }
        // No hooks, and a button in no window — both the callbacks and the
        // refit lookup must be safe no-ops, or a popover in a plain panel
        // would crash on open.
        popover.popoverWillShow(Notification(name: NSPopover.willShowNotification))
        popover.popoverDidClose(Notification(name: NSPopover.didCloseNotification))
    }

    // MARK: Rebuilding

    /// A control can be moved by something other than itself — ⌘+ moves the
    /// text-size slider — and the panel is built from a closure over live
    /// state, so the fix is to build it again rather than to reach in and set
    /// a value on a control the popover owns.
    @Test("rebuilding an open panel picks up the new state")
    func rebuildRereadsTheState() throws {
        var scale = 1.0
        let popover = WindowConfigPopover(title: "Olylo Window") {
            [WindowConfigSlider(
                title: "Text Size", value: scale, range: 0.85...1.75,
                caption: { "\(Int(($0 * 100).rounded()))%" },
                onChange: { _ in })]
        }
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 300),
            styleMask: [.titled], backing: .buffered, defer: false)
        popover.gearButton.frame = NSRect(x: 0, y: 0, width: 40, height: 40)
        window.contentView?.addSubview(popover.gearButton)
        window.makeKeyAndOrderFront(nil)
        popover.toggle()
        try #require(popover.isShown)

        let firstPanel = try #require(popover.popover.contentViewController)
        let before = try #require(slider(in: firstPanel.view))
        #expect(before.doubleValue == 1.0)

        scale = 1.5
        popover.rebuildControls()
        let secondPanel = try #require(popover.popover.contentViewController)
        let after = try #require(slider(in: secondPanel.view))
        #expect(after.doubleValue == 1.5)

        popover.toggle()
        window.orderOut(nil)
    }

    /// Rebuilding a *closed* panel would build controls nobody is looking at,
    /// and would do it every time a key was pressed.
    @Test("rebuilding a closed panel does nothing")
    func rebuildOfAClosedPanelIsFree() {
        var builds = 0
        let popover = WindowConfigPopover(title: "Olylo Window") {
            builds += 1
            return []
        }
        popover.rebuildControls()
        #expect(builds == 0)
    }

    /// A host whose title can change — a pane named by whatever its content is
    /// showing — would otherwise keep the name it had at construction at the
    /// head of an otherwise live panel.
    @Test("renaming an open panel changes the heading on screen")
    func titleChangeRebuildsTheOpenPanel() throws {
        let popover = WindowConfigPopover(title: "Olylo Window") { [] }
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 300),
            styleMask: [.titled], backing: .buffered, defer: false)
        popover.gearButton.frame = NSRect(x: 0, y: 0, width: 40, height: 40)
        window.contentView?.addSubview(popover.gearButton)
        window.makeKeyAndOrderFront(nil)
        popover.toggle()
        try #require(popover.isShown)

        let before = try #require(popover.popover.contentViewController)
        #expect(labels(in: before.view).contains("Olylo Window"))

        popover.title = "Files"

        let after = try #require(popover.popover.contentViewController)
        #expect(labels(in: after.view).contains("Files"))
        #expect(!labels(in: after.view).contains("Olylo Window"))

        popover.toggle()
        window.orderOut(nil)
    }

    /// Assigning the name it already has must not throw the panel away — the
    /// pane republishes its title on every `refreshTitle()`, most of which
    /// change nothing.
    @Test("assigning the same title leaves the panel alone")
    func sameTitleDoesNotRebuild() throws {
        var builds = 0
        let popover = WindowConfigPopover(title: "Olylo Window") {
            builds += 1
            return []
        }
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 300),
            styleMask: [.titled], backing: .buffered, defer: false)
        popover.gearButton.frame = NSRect(x: 0, y: 0, width: 40, height: 40)
        window.contentView?.addSubview(popover.gearButton)
        window.makeKeyAndOrderFront(nil)
        popover.toggle()
        try #require(popover.isShown)
        #expect(builds == 1)
        let panel = try #require(popover.popover.contentViewController)

        popover.title = "Olylo Window"

        #expect(builds == 1)
        #expect(popover.popover.contentViewController === panel)

        popover.toggle()
        window.orderOut(nil)
    }
}
