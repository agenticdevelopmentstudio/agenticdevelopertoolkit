import XCTest
import QuartzCore
import AppKit
@testable import AvatarAnimationEngine

// `AvatarLayerView` inherits `PlatformView`'s main-actor isolation, and the
// package's one `#if` (`Platform`, in `Sources/Render/PlatformShims.swift`)
// is isolated the same way — every AppKit/UIKit member it wraps is. Under
// `SWIFT_STRICT_CONCURRENCY: complete` a test that touches either from a
// plain, nonisolated XCTestCase method cannot compile; isolating the whole
// suite to the main actor is what a real host does too, since a
// `CADisplayLink`-driven view only ever runs there.
@MainActor
final class RenderTests: XCTestCase {
    private var config: CharacterConfig!

    override func setUpWithError() throws {
        let d = try Fixture.all()
        config = try CharacterConfig.load(RawFiles(
            character: d["character"]!, rig: d["rig"]!, poses: d["poses"]!,
            timelines: d["timelines"]!, behavior: d["behavior"]!, sayings: d["sayings"]!))
    }

    /// `dot`'s canvas is 100x100, so a 200x200 view is a clean 2x with no
    /// letterboxing — every expected number below is a doubling.
    private func view(_ w: CGFloat = 200, _ h: CGFloat = 200) throws -> AvatarLayerView {
        AvatarLayerView(engine: try Engine(EngineOptions(config: config)),
                        frame: CGRect(x: 0, y: 0, width: w, height: h))
    }

    /// An `Engine` built from `dot`, the same fixture `view(_:_:)` uses — the
    /// lifecycle tests below construct their own `AvatarLayerView` directly
    /// (some deliberately at the zero frame, before ever touching a window),
    /// so they need the engine alone rather than a pre-sized view.
    private func makeEngine() throws -> Engine {
        try Engine(EngineOptions(config: config))
    }

    /// Orders `window` in and pumps AppKit until the WindowServer reports it
    /// visible. `NSWindow.occlusionState` is only refreshed when `NSApplication`
    /// dispatches the WindowServer's occlusion event, and `xctest` never calls
    /// `NSApplication.run()` -- so without draining NSApp's own queue the state
    /// stays at its initial value forever and `.visible` is never set, on every
    /// host, display session or not. `RunLoop.run(until:)` is not enough: it
    /// spins the CFRunLoop but never dequeues an NSEvent.
    @discardableResult
    private func showAndWaitForVisible(_ window: NSWindow,
                                       timeout: TimeInterval = 2) -> Bool {
        let app = NSApplication.shared
        window.orderFrontRegardless()
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if window.occlusionState.contains(.visible) { return true }
            while let e = app.nextEvent(matching: .any,
                                        until: Date().addingTimeInterval(0.01),
                                        inMode: .default, dequeue: true) {
                app.sendEvent(e)
            }
        }
        return window.occlusionState.contains(.visible)
    }

    private func layer(_ v: AvatarLayerView, _ id: String) throws -> CAShapeLayer {
        try XCTUnwrap(v.shapeLayers.first { $0.name == id }, "no layer named \(id)")
    }

    // MARK: - the bridges

    func testTheCGAffineTransformBridgeMapsAPointExactlyAsMatDoes() {
        // Six distinct values, so a transposed or rotated field ordering cannot
        // coincidentally agree. This is the whole risk in the bridge.
        let m = Mat(a: 1.5, b: -0.25, c: 0.75, d: 2, e: 30, f: -12)
        let expected = m.apply(x: 7, y: -3)
        let got = CGPoint(x: 7, y: -3).applying(CGAffineTransform(m))
        XCTAssertEqual(Double(got.x), expected.x, accuracy: 1e-12)
        XCTAssertEqual(Double(got.y), expected.y, accuracy: 1e-12)
    }

    func testACubicIsBuiltWithItsControlPointsBeforeItsEndPoint() throws {
        let path = AvatarLayerView.cgPath(try parsePath("M0,0C10,0 20,10 20,20"))
        // `currentPoint` is the endpoint. Read the three points in the wrong
        // order and it is (10, 0) — the first control point — instead.
        XCTAssertEqual(path.currentPoint.x, 20, accuracy: 1e-9)
        XCTAssertEqual(path.currentPoint.y, 20, accuracy: 1e-9)

        let expected = CGMutablePath()
        expected.move(to: CGPoint(x: 0, y: 0))
        expected.addCurve(to: CGPoint(x: 20, y: 20),
                          control1: CGPoint(x: 10, y: 0),
                          control2: CGPoint(x: 20, y: 10))
        XCTAssertEqual(path.boundingBoxOfPath, expected.boundingBoxOfPath)
    }

    // MARK: - the fit

    func testFitCentresTheCanvasAndKeepsItSquareInAnOblongBox() {
        // 100x100 into 300x200: scale 2 (the smaller ratio), 50 points of
        // letterbox on each side, none top or bottom.
        let t = AvatarLayerView.fit(canvas: Canvas(w: 100, h: 100),
                                    into: CGSize(width: 300, height: 200),
                                    flipY: false)
        XCTAssertEqual(CGPoint(x: 0, y: 0).applying(t), CGPoint(x: 50, y: 0))
        XCTAssertEqual(CGPoint(x: 100, y: 100).applying(t), CGPoint(x: 250, y: 200))
        XCTAssertEqual(CGPoint(x: 50, y: 50).applying(t), CGPoint(x: 150, y: 100))
    }

    func testFitFlipsYWhenTheHostViewSpaceIsBottomLeft() {
        let t = AvatarLayerView.fit(canvas: Canvas(w: 100, h: 100),
                                    into: CGSize(width: 300, height: 200),
                                    flipY: true)
        // The design origin is the TOP-left, which in a bottom-left space is
        // y = height. The centre is unmoved, which is what makes this a flip
        // and not a translation.
        XCTAssertEqual(CGPoint(x: 0, y: 0).applying(t), CGPoint(x: 50, y: 200))
        XCTAssertEqual(CGPoint(x: 100, y: 100).applying(t), CGPoint(x: 250, y: 0))
        XCTAssertEqual(CGPoint(x: 50, y: 50).applying(t), CGPoint(x: 150, y: 100))
    }

    func testOverscanShrinksTheCanvasBoxWithoutMovingItsCentre() {
        // 100x100 into 300x200 at half scale: the canvas occupies 100x100
        // instead of 200x200, leaving 50 points above and below for motion
        // that leaves the box — the layer-tree stand-in for the original's
        // `overflow: visible`.
        let t = AvatarLayerView.fit(canvas: Canvas(w: 100, h: 100),
                                    into: CGSize(width: 300, height: 200),
                                    flipY: false, overscan: 0.5)
        XCTAssertEqual(CGPoint(x: 0, y: 0).applying(t), CGPoint(x: 100, y: 50))
        XCTAssertEqual(CGPoint(x: 100, y: 100).applying(t), CGPoint(x: 200, y: 150))
        // Unmoved centre is what makes this a shrink rather than a nudge.
        XCTAssertEqual(CGPoint(x: 50, y: 50).applying(t), CGPoint(x: 150, y: 100))
    }

    func testOverscanDefaultsToFillingTheBoxSoExistingHostsAreUnmoved() {
        let canvas = Canvas(w: 350, h: 195)
        let size = CGSize(width: 774, height: 394)
        let plain = AvatarLayerView.fit(canvas: canvas, into: size, flipY: false)
        let explicit = AvatarLayerView.fit(canvas: canvas, into: size,
                                           flipY: false, overscan: 1)
        XCTAssertEqual(plain, explicit)
    }

    // MARK: - the layer tree

    func testTheFirstRenderBuildsOneLayerPerItemAndLaterRendersReuseThem() throws {
        let v = try view()
        let first = try v.engine.tick(0)
        v.render(first)
        let built = v.shapeLayers
        XCTAssertEqual(built.count, first.count)
        XCTAssertEqual(Platform.hostLayer(of: v).sublayers?.count, first.count)

        v.render(try v.engine.tick(1.0 / 60))
        XCTAssertEqual(v.shapeLayers.count, built.count)
        // Identity, not equality: a renderer that rebuilt the tree every frame would
        // still pass a count check and would still draw correctly, and would
        // still be wrong.
        for (a, b) in zip(built, v.shapeLayers) { XCTAssertTrue(a === b) }
    }

    func testLayerOrderIsDisplayListOrder() throws {
        let v = try view()
        let list = try v.engine.tick(0)
        v.render(list)
        XCTAssertEqual(v.shapeLayers.map(\.name), list.map(\.id))
        XCTAssertEqual(v.shapeLayers.map(\.name), ["eye", "pupil", "limb", "line", "spark"])
    }

    // MARK: - paint

    func testAFilledItemPaintsFillAndAStrokedItemPaintsStroke() throws {
        let v = try view()
        v.render(try v.engine.tick(0))

        let eye = try layer(v, "eye")            // ink `ring`, kind stroke
        XCTAssertNil(eye.fillColor)
        XCTAssertNotNil(eye.strokeColor)
        XCTAssertEqual(eye.lineWidth, 4)
        XCTAssertEqual(eye.fillRule, .nonZero)

        let pupil = try layer(v, "pupil")        // ink `hole`, kind fill
        XCTAssertNotNil(pupil.fillColor)
        XCTAssertNil(pupil.strokeColor)
    }

    func testAStrokeWithNoInkWidthFallsBackToTheCharacterStrokeWidth() throws {
        // A synthetic one-item list, on its own view so the invariant that the
        // list length never changes still holds. `dot`'s every stroke ink
        // declares width 4, so only `strokeStyle.width` can produce this 4.
        let v = try view()
        v.render([DisplayItem(id: "solo", m: .identity, d: "M0,0L10,0", kind: "ML",
                              paint: .init(ink: "#112233", alpha: 1,
                                           fill: false, width: nil))])
        XCTAssertEqual(try layer(v, "solo").lineWidth, 4)
    }

    func testCapAndJoinComeFromTheConfigAndNotFromCoreAnimationsDefaults() throws {
        let v = try view()
        v.render(try v.engine.tick(0))
        // CAShapeLayer defaults to `.butt` and `.miter`. `dot` says round and
        // round, so both assertions fail on a renderer that never wrote them.
        XCTAssertEqual(try layer(v, "eye").lineCap, .round)
        XCTAssertEqual(try layer(v, "eye").lineJoin, .round)
    }

    func testOpacityFollowsPaintAlphaSoTheSparkRestsInvisible() throws {
        let v = try view()
        v.render(try v.engine.tick(0))
        XCTAssertEqual(try layer(v, "spark").opacity, 0, accuracy: 1e-6)
        XCTAssertEqual(try layer(v, "eye").opacity, 1, accuracy: 1e-6)
    }

    // MARK: - the shim

    func testTheLiveEnvironmentReadsTheHostAccessibilitySetting() {
        let env = AvatarEnvironment.live()
        // The VALUE is the user's, so it cannot be asserted — that it can be
        // read at all on this platform is the claim. There is nothing else in
        // `AvatarEnvironment` to check: it has no clock (Ruling 48).
        _ = env.reducedMotion()
        // Which branch of the one `#if` this bundle compiled. The test bundle is
        // macOS-only by design, so this records the coverage claim rather than
        // leaving it implied.
        XCTAssertTrue(Platform.viewSpaceIsBottomLeft)
    }

    // MARK: - the public bridges

    func testThePublicPathDoorBuildsTheSamePathAsTheInternalBuilder() throws {
        // The first renderer outside this package (a host static renderer).
        // Without this door it would need `parsePath`, `ParsedPath` and
        // `cgPath` all made public — or, far likelier, its own copy of the cubic
        // argument order the test above exists to protect.
        let d = "M0,0C10,0 20,10 20,20L30,20Z"
        XCTAssertEqual(try CGPath.avatarItem(d),
                       AvatarLayerView.cgPath(try parsePath(d)))
        XCTAssertThrowsError(try CGPath.avatarItem("Q0,0 1,1"))
    }

    func testTheStrokeStyleVocabularyMapsOntoCoreGraphicsCapsAndJoins() throws {
        func style(_ cap: String, _ join: String) throws -> StrokeStyle {
            try JSONDecoder().decode(StrokeStyle.self, from: Data(
                #"{"width":4,"linecap":"\#(cap)","linejoin":"\#(join)"}"#.utf8))
        }
        XCTAssertEqual(try style("round", "round").cgLineCap, .round)
        XCTAssertEqual(try style("round", "round").cgLineJoin, .round)
        XCTAssertEqual(try style("butt", "miter").cgLineCap, .butt)
        XCTAssertEqual(try style("butt", "miter").cgLineJoin, .miter)
        XCTAssertEqual(try style("square", "bevel").cgLineCap, .square)
        XCTAssertEqual(try style("square", "bevel").cgLineJoin, .bevel)
        // Core Graphics' own defaults for a vocabulary neither side knows. The
        // loader is where a bad value is caught; a renderer that threw would
        // report it in the least useful place.
        XCTAssertEqual(try style("wobbly", "wobbly").cgLineCap, .butt)
        XCTAssertEqual(try style("wobbly", "wobbly").cgLineJoin, .miter)
        // And the fixture's own, through the loader rather than a literal.
        XCTAssertEqual(config.character.strokeStyle.cgLineCap, .round)
    }

    // MARK: - the pointer

    @MainActor
    func testPointerMovedAimsTheGazeAtTheCursorAsAUnitVector() throws {
        // 400x400, so the design canvas and the view space agree and the arithmetic
        // is readable. The engine clamps to [-1,1] and multiplies by gazeMax
        // itself, so what the view owes it is a UNIT vector -- exactly what
        // `$GSAP/src/gaze.ts:104-109` computes before its own clamp.
        let view = AvatarLayerView(engine: try Engine(EngineOptions(config: config)),
                                   frame: CGRect(x: 0, y: 0, width: 400, height: 400))

        // Straight right of centre, in DESIGN space (y down).
        view.pointerMoved(to: view.designPoint(x: 400, y: 200))
        XCTAssertEqual(view.lastLook.x, 1, accuracy: 1e-9)
        XCTAssertEqual(view.lastLook.y, 0, accuracy: 1e-9)

        // Directly below centre in design space -- the engine's y is DOWN.
        view.pointerMoved(to: view.designPoint(x: 200, y: 400))
        XCTAssertEqual(view.lastLook.x, 0, accuracy: 1e-9)
        XCTAssertEqual(view.lastLook.y, 1, accuracy: 1e-9)

        // Dead centre: `$GSAP`'s `|| 1` guard, so this is (0,0) and not a divide by zero.
        view.pointerMoved(to: view.designPoint(x: 200, y: 200))
        XCTAssertEqual(view.lastLook.x, 0, accuracy: 1e-9)
        XCTAssertEqual(view.lastLook.y, 0, accuracy: 1e-9)
    }

    @MainActor
    func testPointerPressedPokesAndWakes() throws {
        // Drive the engine's own clock past `ladder.asleepAfterMs` (90s in the
        // `dot` fixture) so the arbiter's periodic poll actually resolves to
        // the asleep mood ("out") before the poke lands -- the same clock the
        // view drives from `CADisplayLink.targetTimestamp`.
        let v = try view()
        _ = try v.engine.tick(0)
        _ = try v.engine.tick(v.engine.config.behavior.ladder.asleepAfterMs / 1000 + 1)
        XCTAssertEqual(v.engine.state.mood, v.engine.config.behavior.ladder.moods["asleep"])

        // A poke from asleep ("out") resolves to `dot`'s poke[0] ("eager"), not
        // the wildcard poke[1] ("calm") -- which is only true if `poke()` sees
        // the mood while it is STILL "out", i.e. `pointerPressed` calls
        // `engine.poke()` before `engine.notice()` (notice would open the
        // waking window and move `current` off "out" first).
        v.pointerPressed()
        let rule = v.engine.config.behavior.poke.first { $0.from == "out" }!
        XCTAssertEqual(v.engine.state.mood, rule.expression)
        XCTAssertEqual(v.engine.state.source, .poke)
        // Awake: the idle ladder was reset, not merely overridden for the
        // poke's own window.
        XCTAssertEqual(v.engine.state.idleRung, 0)
    }

    @MainActor
    func testPointerPressedDoesNothingWhenTracksPointerIsOff() throws {
        // `tracksPointer`'s own doc comment promises a decorative,
        // non-reacting olylo when it is off -- "the host's pointer AND
        // clicks". `pointerMoved` already guards on it; this is the same
        // promise for `pointerPressed`.
        let v = try view()
        v.tracksPointer = false
        _ = try v.engine.tick(0)
        _ = try v.engine.tick(v.engine.config.behavior.ladder.asleepAfterMs / 1000 + 1)
        let before = v.engine.state

        v.pointerPressed()

        XCTAssertEqual(v.engine.state.mood, before.mood)
        XCTAssertEqual(v.engine.state.source, before.source)
        XCTAssertEqual(v.engine.state.idleRung, before.idleRung)
    }

    @MainActor
    func testPointerSampledRelaxesTheGazeOnceOnTheNonNilToNilEdge() throws {
        // `$GSAP/src/gaze.ts:120`: `document.addEventListener("mouseleave",
        // () => look(0, 0))`. `pointerLocation` reports the macOS analogue --
        // the cursor leaving the WINDOW, not merely the view's bounds -- as
        // `nil`; `pointerSampled` is where that edge is caught, since it is
        // extracted from `step(_:)` for exactly this test.
        let view = AvatarLayerView(engine: try Engine(EngineOptions(config: config)),
                                   frame: CGRect(x: 0, y: 0, width: 400, height: 400))

        view.pointerSampled(view.designPoint(x: 400, y: 200))
        XCTAssertEqual(view.lastLook.x, 1, accuracy: 1e-9)
        XCTAssertEqual(view.lastLook.y, 0, accuracy: 1e-9)

        // The cursor leaves: the gaze relaxes to centre.
        view.pointerSampled(nil)
        XCTAssertEqual(view.lastLook.x, 0, accuracy: 1e-9)
        XCTAssertEqual(view.lastLook.y, 0, accuracy: 1e-9)

        // Fires ONCE, not every frame the cursor stays away: plant a sentinel
        // no real gaze value could produce, sample `nil` again, and confirm
        // it is untouched.
        view.lastLook = (x: 0.42, y: 0.42)
        view.pointerSampled(nil)
        XCTAssertEqual(view.lastLook.x, 0.42, accuracy: 1e-9)
        XCTAssertEqual(view.lastLook.y, 0.42, accuracy: 1e-9)

        // Re-entry re-arms: a fresh non-nil sample looks again, and a
        // following leave relaxes again.
        view.pointerSampled(view.designPoint(x: 200, y: 400))
        XCTAssertEqual(view.lastLook.y, 1, accuracy: 1e-9)
        view.pointerSampled(nil)
        XCTAssertEqual(view.lastLook.x, 0, accuracy: 1e-9)
        XCTAssertEqual(view.lastLook.y, 0, accuracy: 1e-9)
    }

    // MARK: - lifecycle: the view ticks only while it can be seen

    func testStartWithoutAWindowArmsButDoesNotTick() throws {
        let view = AvatarLayerView(engine: try makeEngine())
        view.start()
        XCTAssertTrue(view.isStarted)
        XCTAssertFalse(view.isTicking, "no window, nobody can see it, no display link")
    }

    func testAttachingAStartedViewToAVisibleWindowStartsTheLinkAndDetachingStopsIt() throws {
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 200, height: 200),
                              styleMask: [.titled], backing: .buffered, defer: false)
        try XCTSkipUnless(showAndWaitForVisible(window),
                          "this host has no display session; the window is never visible")
        let view = AvatarLayerView(engine: try makeEngine())
        view.start()
        window.contentView?.addSubview(view)
        XCTAssertTrue(view.isTicking)
        view.removeFromSuperview()
        XCTAssertFalse(view.isTicking)
        window.contentView?.addSubview(view)
        XCTAssertTrue(view.isTicking, "re-attaching resumes without another start()")
        window.orderOut(nil)
    }

    func testHidingAStartedViewStopsTheLinkAndUnhidingResumesIt() throws {
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 200, height: 200),
                              styleMask: [.titled], backing: .buffered, defer: false)
        try XCTSkipUnless(showAndWaitForVisible(window),
                          "this host has no display session; the window is never visible")
        let view = AvatarLayerView(engine: try makeEngine())
        window.contentView?.addSubview(view)
        view.start()
        XCTAssertTrue(view.isTicking)
        view.isHidden = true
        XCTAssertFalse(view.isTicking)
        view.isHidden = false
        XCTAssertTrue(view.isTicking)
        window.orderOut(nil)
    }

    func testStopDisarmsEvenWhileVisible() throws {
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 200, height: 200),
                              styleMask: [.titled], backing: .buffered, defer: false)
        try XCTSkipUnless(showAndWaitForVisible(window),
                          "this host has no display session; the window is never visible")
        let view = AvatarLayerView(engine: try makeEngine())
        window.contentView?.addSubview(view)
        view.start()
        view.stop()
        XCTAssertFalse(view.isStarted)
        XCTAssertFalse(view.isTicking)
        view.removeFromSuperview()
        window.contentView?.addSubview(view)
        XCTAssertFalse(view.isTicking, "a stopped view stays stopped through window changes")
        window.orderOut(nil)
    }

    func testThePlateColourIsPaintedOnTheHostLayer() throws {
        let view = AvatarLayerView(engine: try makeEngine())
        XCTAssertNil(view.plateColor)
        let ink = CGColor(srgbRed: 6 / 255, green: 20 / 255, blue: 13 / 255, alpha: 1)
        view.plateColor = ink
        XCTAssertEqual(view.layer?.backgroundColor, ink)
        view.plateColor = nil
        XCTAssertNil(view.layer?.backgroundColor)
    }
}

private extension AvatarLayerView {
    /// A point in DESIGN space (y down, origin top-left) converted to this
    /// view's own space, using the same `Platform.viewSpaceIsBottomLeft` flip
    /// `fit` uses -- so one test body covers both platforms. Test-only: a host
    /// never needs this, since `pointerMoved` already receives points in its
    /// own space.
    func designPoint(x: CGFloat, y: CGFloat) -> CGPoint {
        Platform.viewSpaceIsBottomLeft
            ? CGPoint(x: x, y: bounds.height - y)
            : CGPoint(x: x, y: y)
    }
}
