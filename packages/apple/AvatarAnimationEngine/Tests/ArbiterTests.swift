import XCTest
@testable import AvatarAnimationEngine

private func near(_ a: Double, _ b: Double, _ tol: Double = 1e-12,
                  file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertLessThan(abs(a - b), tol, "\(a) !≈ \(b)", file: file, line: line)
}

/// The fixture, a seeded channel store, live tweens, a scheduler and a started
/// arbiter — rebuilt per test so no test can inherit another's mood.
private struct Harness {
    let ctx: AnimContext
    let arbiter: Arbiter

    init(files: [String: Data]? = nil) throws {
        let d = try files ?? Fixture.all()
        let config = try CharacterConfig.load(RawFiles(
            character: d["character"]!, rig: d["rig"]!, poses: d["poses"]!,
            timelines: d["timelines"]!, behavior: d["behavior"]!, sayings: d["sayings"]!))
        let channels = Channels()
        config.seed(into: channels)
        ctx = AnimContext(config: config, channels: channels,
                          tweens: Tweens(channels: channels), scheduler: Scheduler())
        arbiter = Arbiter(ctx)
        // The engine (Task 34) calls this once before the first tick. Every test
        // needs it, both for the opening pose and because it arms the ladder poll.
        arbiter.start(0)
    }

    // Every number below comes from the config. Nothing in this file is a
    // literal the fixture could drift away from.
    var ladder: LadderDef { ctx.config.behavior.ladder }
    var bored: Double { ladder.boredAfterMs / 1000 }
    var asleep: Double { ladder.asleepAfterMs / 1000 }
    var alert: Double { ladder.alertAfterTypingMs / 1000 }

    /// The fixed tick order minus compose: scheduler, arbiter, tweens.
    ///
    /// The trailing triple is not redundant — the accumulating loop stops just
    /// short of `to`, and several assertions pin a state at an exact instant.
    func run(from: Double, to: Double) {
        var t = from
        while t <= to + 1e-12 {
            ctx.scheduler.tick(t)
            arbiter.tick(t)
            ctx.tweens.tick(t)
            t += 1.0 / 60.0
        }
        ctx.scheduler.tick(to)
        arbiter.tick(to)
        ctx.tweens.tick(to)
    }
}

final class ArbiterTests: XCTestCase {
    func testStartsOnRungZeroAndActuallyAppliesTheActivePose() throws {
        // Rest comes from the rig, not from a pose, so `eager`'s limb.bend of 6
        // is only there if the very first evaluation applied a pose rather than
        // short-circuiting on "the mood already equals the mood I would pick".
        let h = try Harness()
        h.run(from: 0, to: 1)
        XCTAssertEqual(h.arbiter.state.idleRung, 0)
        XCTAssertEqual(h.arbiter.state.source, .idle)
        XCTAssertEqual(h.arbiter.state.mood, h.ladder.moods["active"])
        near(h.ctx.channels.get("limb.bend")!.number!, 6)
    }

    func testClimbsToBoredAndThenAsleepWithNoInteraction() throws {
        let h = try Harness()
        h.run(from: 0, to: h.bored - 1)
        XCTAssertEqual(h.arbiter.state.idleRung, 0)
        h.run(from: h.bored - 1, to: h.bored + 1)
        XCTAssertEqual(h.arbiter.state.idleRung, 1)
        XCTAssertEqual(h.arbiter.state.mood, h.ladder.moods["bored"])
        h.run(from: h.bored + 1, to: h.asleep + 1)
        XCTAssertEqual(h.arbiter.state.idleRung, 2)
        XCTAssertEqual(h.arbiter.state.mood, h.ladder.moods["asleep"])
    }

    func testResetsTheLadderOnNotice() throws {
        let h = try Harness()
        h.run(from: 0, to: h.bored + 1)
        XCTAssertEqual(h.arbiter.state.idleRung, 1)
        h.arbiter.notice(h.bored + 1)
        h.run(from: h.bored + 1, to: h.bored + 2)
        XCTAssertEqual(h.arbiter.state.idleRung, 0)
    }

    func testLetsAnAppMoodOutrankTheLadderAndReleasesItOnNil() throws {
        let h = try Harness()
        try h.arbiter.setMood(h.ladder.moods["bored"], now: 0)
        h.run(from: 0, to: h.asleep + 1)
        XCTAssertEqual(h.arbiter.state.source, .app)
        XCTAssertEqual(h.arbiter.state.mood, h.ladder.moods["bored"])
        // The ladder kept climbing underneath — releasing the app mood drops
        // straight to the rung the clock says we are on, with no catch-up.
        XCTAssertEqual(h.arbiter.state.idleRung, 2)
        try h.arbiter.setMood(nil, now: h.asleep + 1)
        XCTAssertEqual(h.arbiter.state.mood, h.ladder.moods["asleep"])
        XCTAssertEqual(h.arbiter.state.source, .idle)
    }

    func testRefusesAnAppMoodNoPoseDefines() throws {
        // The one throwing door. `evaluate` runs inside a scheduler closure and
        // inside `tick`, neither of which can propagate, so the unvalidated
        // string has to be refused here or it traps there instead.
        let h = try Harness()
        XCTAssertThrowsError(try h.arbiter.setMood("smug", now: 0)) { error in
            XCTAssertEqual(error as? AnimError, AnimError("unknown mood: smug"))
        }
        // It threw before storing anything, so the ladder still owns the mood.
        XCTAssertEqual(h.arbiter.state.mood, h.ladder.moods["active"])
        XCTAssertEqual(h.arbiter.state.source, .idle)
    }

    func testPicksThePokeReactionFromTheMoodItInterrupts() throws {
        let sleeping = try Harness()
        let rules = sleeping.ctx.config.behavior.poke
        let asleepRule = rules.first { $0.from == sleeping.ladder.moods["asleep"] }!
        let anyRule = rules.first { $0.from == "*" }!
        // The fixture's two rules name different expressions, and neither names
        // the mood it interrupts, so a no-op would fail both halves.
        XCTAssertNotEqual(asleepRule.expression, anyRule.expression)

        sleeping.run(from: 0, to: sleeping.asleep + 1)
        sleeping.arbiter.poke(sleeping.asleep + 1)
        XCTAssertEqual(sleeping.arbiter.state.mood, asleepRule.expression)
        XCTAssertEqual(sleeping.arbiter.state.source, .poke)

        let awake = try Harness()
        awake.run(from: 0, to: 1)
        awake.arbiter.poke(1)
        XCTAssertEqual(awake.arbiter.state.mood, anyRule.expression)
    }

    func testHoldsThePokeForItsRulesWindowThenFallsBack() throws {
        let h = try Harness()
        // The app mood doubles as the poke's `from`, so this exercises the
        // specific rule rather than the `"*"` fallback the test above covers.
        let app = h.ctx.config.behavior.waking.from
        try h.arbiter.setMood(app, now: 0)
        let rule = h.ctx.config.behavior.poke.first { $0.from == app }!
        let window = rule.ms / 1000
        h.arbiter.poke(1)
        h.run(from: 1, to: 1 + window - 0.2)
        XCTAssertEqual(h.arbiter.state.source, .poke)
        XCTAssertEqual(h.arbiter.state.mood, rule.expression)
        h.run(from: 1 + window - 0.2, to: 1 + window + 0.2)
        // The app mood is still set, so the poke falls back to it, not the ladder.
        XCTAssertEqual(h.arbiter.state.source, .app)
        XCTAssertEqual(h.arbiter.state.mood, app)
    }

    func testWakesIntoWakingPlayAsAMoodAndOnlyThenLandsOnWakingTo() throws {
        // The mood matters more than the animation here. Everything keyed on
        // the current mood — blink suppression above all — reads
        // `state.mood`, so a wake window that reported `idle` while the flip
        // played would blink the character mid-flip, which the engine never
        // does.
        let h = try Harness()
        let waking = h.ctx.config.behavior.waking
        h.run(from: 0, to: h.asleep + 1)
        XCTAssertEqual(h.arbiter.state.mood, waking.from)
        h.arbiter.notice(h.asleep + 1)
        XCTAssertEqual(h.arbiter.state.source, .waking)
        // `waking.play`, NOT `waking.to` — the wake transition IS a mood for
        // its whole window.
        XCTAssertEqual(h.arbiter.state.mood, waking.play)
        // The pose alone cannot prove the timeline ran — `calm` writes
        // `line.shape` too. The FAMILY channel can: only `flip`'s duration-0
        // steps ever touch it, so seeing "arcLine" at all is the timeline and
        // nothing else. It is also what a ladder delay on a timeline step would
        // break: the family snap would miss rule 4 and never write "arcLine".
        var crossed = false
        var t = h.asleep + 1
        while t <= h.asleep + 3 {
            h.ctx.scheduler.tick(t)
            h.arbiter.tick(t)
            h.ctx.tweens.tick(t)
            if h.ctx.channels.get("line.family") == .text("arcLine") { crossed = true }
            t += 1.0 / 60.0
        }
        XCTAssertTrue(crossed)
        // …and it snapped back, so the character is left in its own family.
        XCTAssertEqual(h.ctx.channels.get("line.family"), .text("line"))
        // Past the window, the ladder has it back — but "has it back" means the
        // ladder's OWN computation from the real elapsed idle time, not a
        // hard-coded jump to `waking.to`. `notice()` reset `lastInteraction` to
        // `h.asleep + 1`, and the run below only reaches `+0.8`s past that, far
        // short of `dot`'s 20s `boredAfterMs` — so the ladder is still on rung 0,
        // `moods.active`. (A config where `waking.to` equals the rung the ladder
        // would land on anyway — as `dot`'s sibling fixtures do — would make this
        // assertion and one against `waking.to` agree; `dot`'s `waking.to`
        // ("calm", `moods.bored`) does not have that property, so asserting
        // `waking.to` here would be asserting a number this fixture never
        // reaches.)
        h.run(from: h.asleep + 1, to: h.asleep + 1 + waking.ms / 1000 + 0.2)
        XCTAssertEqual(h.arbiter.state.mood, h.ladder.moods["active"])
    }

    func testPlaysAChoreographedMoodsTimelineInsteadOfItsPose() throws {
        // `flipping` is choreographed, and `flip` snaps `line.family` at t=0.
        // A pose can never do that — the loader holds every pose of a node to
        // the one family the rig declares — so the family channel is proof
        // that the timeline ran and the pose did not.
        let h = try Harness()
        let mood = "flipping"
        let timeline = try XCTUnwrap(h.ctx.config.behavior.choreography?[mood])
        XCTAssertEqual(timeline, "flip")
        try h.arbiter.setMood(mood, now: 0)
        XCTAssertEqual(h.ctx.channels.get("line.family"), .text("line"))
        h.run(from: 0, to: 0.1)
        XCTAssertEqual(h.ctx.channels.get("line.family"), .text("arcLine"))
    }

    func testCancelsAChoreographedTimelineWhenTheMoodChangesOutFromUnderIt() throws {
        // The arbiter kills the choreography timeline on every mood change; the
        // Swift port must too, or the flip's later steps land on top of
        // whatever pose replaced it. The closing snap at t=0.3 is the one to
        // watch: if it were still scheduled it would re-write `line.family`
        // long after the mood left.
        let h = try Harness()
        try h.arbiter.setMood("flipping", now: 0)
        h.run(from: 0, to: 0.1)
        XCTAssertEqual(h.ctx.channels.get("line.family"), .text("arcLine"))
        try h.arbiter.setMood(h.ladder.moods["active"], now: 0.1)
        // Cancelling hands the channel back to the pose system, so the family
        // channel goes back to the family a pose is allowed to draw —
        // immediately, not at the timeline's own 0.3.
        XCTAssertEqual(h.ctx.channels.get("line.family"), .text("line"))
        h.run(from: 0.1, to: 0.5)
        // The flip's closing snap would have re-written `line.family` at 0.3
        // had it survived.
        XCTAssertEqual(h.ctx.channels.get("line.family"), .text("line"))
    }

    func testSurvivesAMoodChangeWhileTheTimelineHoldsTheLine() throws {
        // The mirror of Plan A's `survives a poke that lands while the yawn holds
        // the mouth open`, asserted end-to-end rather than at the tween layer.
        // `waking` plays `flip`, which snaps `line.shape` into family `arcLine`
        // ("MC") at t=0 and does not snap back until t=0.3; every one of the
        // three poses drives that same channel with an "MLL" polyline. So a mood
        // change inside that window asks for MC -> MLL, which `morphPath`
        // refuses.
        //
        // There is no XCTAssertNoThrow to write here, and that is the point:
        // `lerpValue` uses `try!`, so a refused morph TRAPS — it kills the test
        // runner, it does not fail one assertion. Reaching the last line of this
        // test at all is therefore part of the assertion; the value check below
        // is what proves it reached it by running rather than by freezing.
        //
        // The trigger is `setMood` and not `poke` because this fixture's `poke`
        // cannot reach the crossing: `waking.to` is `calm`, and the `"*"` rule's
        // expression is also `calm`, so a poke here resolves to the mood already
        // in force and `evaluate` never re-applies a pose. Plan A's config makes
        // `poke` the reachable path; the rule under test is the same one.
        let h = try Harness()
        h.run(from: 0, to: h.asleep + 1)
        h.arbiter.notice(h.asleep + 1)
        let t0 = h.asleep + 1
        h.run(from: t0, to: t0 + 0.1)
        XCTAssertEqual(h.ctx.channels.get("line.family"), .text("arcLine"))
        // App mood outranks `waking` in `resolve`, and "eager" != "calm", so
        // this really does apply a pose rather than short-circuit.
        try h.arbiter.setMood(h.ladder.moods["active"], now: t0 + 0.1)
        XCTAssertEqual(h.arbiter.state.mood, h.ladder.moods["active"])
        // `setMood` at t0+0.1 leaves the `flipping` mood, so `evaluate` cancels
        // its `choreo` handle — the sibling test above pins that cancellation
        // down for `line.family`, and it is the same cancellation here: `flip`'s
        // closing snap at t0+0.3 is an unfired one-shot at the moment of the
        // cancel and never runs. What is left on `line.shape` is `eager`'s own
        // tween: `line.shape` carries a 0.08 channel delay, so it starts at
        // 0.18 — still inside `flip`'s arcLine window — and its `from` resolves
        // lazily, against whatever `flip`'s now-cancelled arc tween last wrote
        // to the channel. That `from` is family "MC"; `eager`'s own target is
        // family "MLL"; `lerpValue` refuses to morph between the two and snaps
        // straight to the target instead of interpolating (rule 4) — the same
        // rule `TweenTests.testSnapsAPathAcrossShapeFamiliesInsteadOfTrapping`
        // covers in isolation. So the value that survives to t0+1 is `eager`'s
        // own `line.shape`, not `flip`'s closing literal — matching the TS
        // reference test's own note that "the pose's own cross-family tween is
        // what is left" once the poke (there) or the mood change (here) cancels
        // the rest of the timeline.
        h.run(from: t0 + 0.1, to: t0 + 1)
        XCTAssertEqual(h.ctx.channels.get("line.shape"), .text("M40,68L50,78L60,68"))
        XCTAssertEqual(h.ctx.channels.get("line.family"), .text("line"))
    }

    func testHoldsSpeechForTheBubblesOwnLifeWithoutTouchingTheMood() throws {
        let h = try Harness()
        let bubble = h.ctx.config.behavior.speech.bubble
        // Computed, never pinned: this sum is 0.7500000000000001.
        let life = bubble.`in`.duration + (bubble.out.delay ?? 0) + bubble.out.duration
        let app = h.ladder.moods["bored"]!
        try h.arbiter.setMood(app, now: 0)
        h.arbiter.say("hi", now: 0)
        h.arbiter.tick(0)
        XCTAssertEqual(h.arbiter.state.speech?.text, "hi")
        near(h.arbiter.state.speech!.until, life)
        // A much longer line lives exactly as long — the bubble is not scaled.
        h.arbiter.say("a considerably longer line than the previous one", now: 0)
        h.arbiter.tick(0)
        near(h.arbiter.state.speech!.until, life)
        XCTAssertEqual(h.arbiter.state.mood, app)
        h.run(from: 0, to: life + 0.5)
        XCTAssertNil(h.arbiter.state.speech)
    }

    func testPinsTheLadderToRungZeroForAlertAfterTypingMsAfterASay() throws {
        let h = try Harness()
        h.arbiter.say("still here", now: 0)
        h.run(from: 0, to: h.bored + 1)
        XCTAssertEqual(h.arbiter.state.idleRung, 0)
        // The pin does not touch lastInteraction, so when it lapses the ladder
        // resumes from the real last interaction rather than restarting from
        // zero: at `alert + 1` the idle time is 31 s, not 1 s, so the rung is 1.
        h.run(from: h.bored + 1, to: h.alert + 1)
        XCTAssertEqual(h.arbiter.state.idleRung, 1)
    }

    func testNormalisesTheSpinInsteadOfLeavingTheChannelWoundUp() throws {
        // Rung 0 spins, so `start` alone sets this up. applyPose deliberately
        // does NOT schedule its own reset — a second tween on the channel would
        // cancel the spin — so the arbiter owns it, and owns it as a
        // zero-duration tween rather than a channels.set. The distinction is not
        // stylistic: the reset fires inside scheduler.tick, which runs BEFORE
        // tweens.tick on the same frame, so a raw write is overwritten by the
        // spin tween's own final 560 and the normalisation never happens at all.
        let h = try Harness()
        let spin = h.ctx.config.poses.poses[h.ladder.moods["active"]!]!.spin!
        h.run(from: 0, to: spin.duration + 0.5)
        XCTAssertEqual(h.ctx.channels.get(spin.channel), .number(-160))
    }

    func testAMoodChangeMidSpinDropsTheNormalisationTheOldPoseLeftPending() throws {
        // The report: bitbag was sent `silly`, the mood was cleared before the
        // whirl finished, and he stayed upside-down for good. The spinning pose
        // arms a one-shot to wind its channel back to the landing angle; left
        // armed across a mood change it fires under the REPLACEMENT pose, tramples
        // the value that pose was tweening to, and sticks — nothing tweens the
        // channel afterwards, so there is no second chance.
        //
        // `calm` is given the spun channel so the assertion is about the new
        // pose's own target rather than about the absence of a value: the
        // pre-fix run lands on `eager`'s -160 here, not on 0.
        var files = try Fixture.all()
        var poses = try XCTUnwrap(JSONSerialization.jsonObject(with: files["poses"]!)
                                  as? [String: Any])
        var table = try XCTUnwrap(poses["poses"] as? [String: Any])
        var calm = try XCTUnwrap(table["calm"] as? [String: Any])
        var channels = try XCTUnwrap(calm["channels"] as? [String: Any])
        channels["spark.rotation"] = 0
        calm["channels"] = channels
        table["calm"] = calm
        poses["poses"] = table
        files["poses"] = try JSONSerialization.data(withJSONObject: poses)

        let h = try Harness(files: files)
        let spin = h.ctx.config.poses.poses[h.ladder.moods["active"]!]!.spin!
        let clear = spin.duration / 2
        h.run(from: 0, to: clear)
        try h.arbiter.setMood("calm", now: clear)
        h.run(from: clear, to: spin.duration + 2)
        XCTAssertEqual(h.ctx.channels.get(spin.channel), .number(0))
    }

    func testEvaluatesTheLadderOnSchedulerInstantsIdenticalAtEveryRate() throws {
        // Not "roughly agrees" — the instants are the scheduler's own
        // accumulation, so the whole sequence is identical. The offsets straddle
        // the boredom boundary in both directions, so a test that passed by
        // never climbing would fail on the two negative probes.
        //
        // The loop here is deliberately raw rather than `Harness.run`: that
        // helper lands a final tick exactly on `to`, which every rate shares, and
        // that alone would make any two rates agree.
        let offsets = [-0.3, -0.1, 0.05, 0.1, 0.15, 0.2, 0.3]
        func sweep(_ fps: Double) throws -> [Int] {
            try offsets.map { offset in
                let h = try Harness()
                let target = h.bored + offset
                var t = 0.0
                while t <= target {
                    h.ctx.scheduler.tick(t)
                    h.arbiter.tick(t)
                    h.ctx.tweens.tick(t)
                    t += 1.0 / fps
                }
                return h.arbiter.state.idleRung
            }
        }
        // The last poll at or before `bored + 0.2` is 19.99999999999996 — four
        // parts in 10^14 short of the boundary, by the same accumulation the web
        // does — so the ladder climbs one poll later than the arithmetic reads.
        let expected = [0, 0, 0, 0, 0, 0, 1]
        for fps in [30.0, 60.0, 90.0, 120.0, 144.0, 240.0] {
            XCTAssertEqual(try sweep(fps), expected, "at \(fps) Hz")
        }
    }
}
