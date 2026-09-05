import Foundation

public enum MoodSource: String, Equatable, Sendable {
    case app, idle, poke, waking
}

public struct SpeechState: Equatable, Sendable {
    public var text: String
    public var until: Double

    public init(text: String, until: Double) {
        self.text = text
        self.until = until
    }
}

public struct ArbiterState: Equatable, Sendable {
    public var mood: String
    public var source: MoodSource
    public var speech: SpeechState?
    /// 0 = active, 1 = bored, 2 = asleep — an index into the three rungs.
    public var idleRung: Int
    public var lastInteraction: Double
}

/// Decides which mood is current, every poll, from a strict priority. It owns no
/// clock: every entry point takes the host's absolute monotonic time.
public final class Arbiter {
    private struct Rung {
        let after: Double
        let mood: String
    }

    private let ctx: AnimContext
    private let rungs: [Rung]
    private let poll: Double
    private let speechLife: Double

    private var appMood: String?
    private var pokeMood: String
    private var pokeUntil = -Double.infinity
    private var wakeUntil = -Double.infinity
    private var alertUntil = -Double.infinity
    private var lastInteraction: Double = 0
    private var speech: SpeechState?

    private var current: String
    private var source: MoodSource = .idle
    private var rung = 0
    private var applied = false
    private var pollId: Int?
    private var choreo: TimelineHandle?
    private var spinReset: Int?

    public init(_ ctx: AnimContext) {
        self.ctx = ctx
        let ladder = ctx.config.behavior.ladder
        // `ladder.moods` is a dictionary because the JSON reads better that way,
        // and Task 28's sixth rule forbids iterating one. Nothing here iterates:
        // a rung IS an index, so the three names are read BY NAME, in the order
        // the ladder climbs. The loader (Task 29) refuses a ladder missing any
        // of the three, which is what these three `!`s are standing on.
        self.rungs = [
            Rung(after: 0, mood: ladder.moods["active"]!),
            Rung(after: ladder.boredAfterMs / 1000, mood: ladder.moods["bored"]!),
            Rung(after: ladder.asleepAfterMs / 1000, mood: ladder.moods["asleep"]!),
        ]
        self.poll = ladder.pollMs / 1000
        let bubble = ctx.config.behavior.speech.bubble
        self.speechLife = bubble.`in`.duration
            + (bubble.out.delay ?? 0)
            + bubble.out.duration
        self.current = rungs[0].mood
        self.pokeMood = rungs[0].mood
    }

    public var state: ArbiterState {
        ArbiterState(mood: current, source: source, speech: speech,
                     idleRung: rung, lastInteraction: lastInteraction)
    }

    // MARK: - the clock

    public func start(_ now: Double) {
        // Evaluate once so the opening mood is painted on frame 1, then hand the
        // cadence to the scheduler — that, and not the poll interval itself, is
        // what makes the evaluation instants frame-rate independent.
        //
        // `first` is absolute and MUST be anchored on `now`. Omitting it sets
        // the first instant to the INTERVAL on the engine's clock, which is the
        // same instant only when `start` runs at zero. It does today — Ruling 48
        // normalises the clock to the first frame — but `start` is public and
        // re-callable, and the identical spelling in the reflexes re-arms mid-run
        // where an unanchored deadline is one already gone by. One rule, both.
        evaluate(now)
        if let pollId { ctx.scheduler.cancel(pollId) }
        pollId = ctx.scheduler.every(poll, first: now + poll) { [weak self] at in
            // Weak: this class holds the scheduler, so a strong capture here is a
            // retain cycle that outlives the view the character was drawn in.
            self?.evaluate(at)
        }
    }

    public func tick(_ now: Double) {
        // The ladder is not evaluated here — `start` gave that to the scheduler.
        // What is left are the three hard deadlines, checked every frame because
        // letting a poke outlive its window by up to a poll reads as a stuck
        // expression. They are releases, so a frame of jitter is the cheap side
        // of that trade.
        let speechDue = speech.map { now >= $0.until } ?? false
        if (source == .poke && now >= pokeUntil)
            || (source == .waking && now >= wakeUntil)
            || speechDue {
            evaluate(now)
        }
    }

    // MARK: - inputs

    public func setMood(_ mood: String?, now: Double) throws {
        // The only unvalidated string that reaches this class. Refusing it HERE
        // is what lets `evaluate` — which runs where nothing can be thrown — use
        // `try!` honestly. The message is byte-identical to `applyPose`'s, so the
        // two doors fail the same way.
        if let mood, ctx.config.poses.poses[mood] == nil {
            throw AnimError("unknown mood: \(mood)")
        }
        appMood = mood
        evaluate(now)
    }

    public func notice(_ now: Double) {
        // Waking is a transition, and the config names what it wakes FROM.
        // Waking from any other mood would animate a return for someone who
        // never left.
        //
        // Opening the window is all this does: `evaluate` below resolves to
        // `waking.play` and, if it is choreographed, plays its timeline the
        // same way it would for a mood reached any other route. Calling
        // `playTimeline` here too — as this function once did — would race
        // that branch: `evaluate`'s own choreography check would see `current`
        // already equal to `waking.play` from THIS call's resolve, skip past
        // its `!= current` guard, and never even try to start it, leaving the
        // handle this function opened as the only one the arbiter tracks, with
        // no `choreo` field aware it exists to cancel it on the next poke.
        if current == ctx.config.behavior.waking.from {
            wakeUntil = now + ctx.config.behavior.waking.ms / 1000
        }
        lastInteraction = now
        evaluate(now)
    }

    public func poke(_ now: Double) {
        // First matching rule wins; `"*"` is a rule like any other and sits last
        // in the JSON, so the specific `from` cases are reached first. `poke` is
        // an ARRAY, so no sorting rule applies and there is no branch here.
        let rules = ctx.config.behavior.poke
        if let rule = rules.first(where: { $0.from == current })
            ?? rules.first(where: { $0.from == "*" }) {
            pokeMood = rule.expression
            pokeUntil = now + rule.ms / 1000
        }
        lastInteraction = now
        evaluate(now)
    }

    public func say(_ text: String, now: Double) {
        speech = SpeechState(text: text, until: now + speechLife)
        alertUntil = now + ctx.config.behavior.ladder.alertAfterTypingMs / 1000
    }

    /// Play a timeline by name, on the engine's ONE timeline slot.
    ///
    /// The slot is the same field a choreographed mood uses, and sharing it is
    /// the point rather than a saving. A timeline is not a private animation: it
    /// snaps engine-managed `.family` channels and rewrites the shapes beside
    /// them, and only its own handle knows how to hand either back. Two of them
    /// standing at once means the second reads channels the first has already
    /// moved — `play("yawn")` twice half a second apart, or `play("yawn")`
    /// followed by `setMood("yawning")`, both landed a second promote on an
    /// already-promoted mouth.
    ///
    /// Cancelling first is therefore the whole fix, and putting the handle where
    /// `evaluate` already looks is what extends it across the two doors: a mood
    /// change cancels a hand-played timeline exactly as it cancels a
    /// choreographed one, which is also the behaviour a caller wants — leaving
    /// the mood a timeline was performing should not leave the timeline running.
    public func play(_ name: String, now: Double) throws {
        if let running = choreo { running.cancel(); choreo = nil }
        choreo = try playTimeline(ctx, name, now: now)
    }

    // MARK: - arbitration

    private func rungFor(_ now: Double) -> Int {
        // The typing pin holds the rung down WITHOUT touching lastInteraction, so
        // when it lapses the ladder resumes from the real last interaction.
        if now < alertUntil { return 0 }
        let idle = now - lastInteraction
        var found = 0
        for i in rungs.indices where idle >= rungs[i].after { found = i }
        return found
    }

    private func resolve(_ now: Double) -> (mood: String, source: MoodSource, rung: Int) {
        let r = rungFor(now)
        if now < pokeUntil { return (pokeMood, .poke, r) }
        if let appMood { return (appMood, .app, r) }
        // `waking.play`, NOT `waking.to`. The wake transition IS a mood for its
        // whole window — that is what lets blink suppression, the pinpricks and
        // every other mood-keyed reflex see the yawn. `waking.to` is where the
        // ladder lands once the window lapses, and it gets there on its own.
        if now < wakeUntil { return (ctx.config.behavior.waking.play, .waking, r) }
        return (rungs[r].mood, .idle, r)
    }

    private func evaluate(_ now: Double) {
        let next = resolve(now)
        rung = next.rung
        source = next.source
        // `!applied` is the startup case and it matters: rest comes from the rig,
        // not from a pose, so without it the opening mood would never be painted.
        if !applied || next.mood != current {
            applied = true
            current = next.mood
            // Leaving a choreographed mood cancels whatever of its timeline has
            // not fired yet, so a poke mid-yawn does not get the yawn's
            // remaining steps dropped on top of the pose it just asked for.
            // Unfired one-shots are the only state a timeline holds; the tweens
            // it already started are cancelled the ordinary way, by the next
            // tween on the same channel.
            if let running = choreo { running.cancel(); choreo = nil }
            // The pending spin normalisation belongs to the pose that scheduled
            // it, and leaving that pose gives the channel away. Left armed, it
            // fires under the NEW pose and slams the channel to the old pose's
            // wound-back angle — a mood cleared part-way through a spin leaves
            // the avatar stuck at it for good, because nothing tweens after.
            // The original has no equivalent to cancel: GSAP's `overwrite`
            // kills the spin tween outright, taking its landing with it, so
            // cancelling here is what makes the two engines agree.
            if let pending = spinReset { ctx.scheduler.cancel(pending); spinReset = nil }
            if let timeline = ctx.config.behavior.choreography?[current] {
                // A choreographed mood skips its pose entirely. The timeline is
                // the whole performance — it opens the mouth, holds it, and
                // walks every channel it touched back to rest — so applying the
                // pose as well would fight it for the same channels from the
                // first frame.
                //
                // Same guarantee as the plain-pose branch's: `playTimeline`
                // throws only on an unknown timeline, and the loader checked
                // every `choreography` entry against `timelines.timelines`.
                choreo = try! playTimeline(ctx, timeline, now: now)
            } else {
                // `try!` is a claim, not a shortcut: `applyPose` throws exactly
                // one error — unknown mood — the ladder, poke and waking moods
                // were all checked by the loader, and the app's was checked by
                // `setMood`.
                let result = try! applyPose(ctx, current, now: now)
                if let reset = result.resetAt {
                    // A zero-duration tween, NOT channels.set. The one-shot
                    // fires inside scheduler.tick, which runs before
                    // tweens.tick on the same frame, so a raw write would be
                    // overwritten by the spin tween's own final value. Going
                    // through `add` cancels that tween (newest wins) and
                    // writes the normalised value verbatim (rule 4) — two
                    // rules the engine already has, and no new one.
                    //
                    // Capturing `tweens` strongly and `self` weakly keeps the
                    // scheduler from retaining this object, while still letting
                    // the fired one-shot drop the handle it was reached by.
                    spinReset = ctx.scheduler.once(at: reset.at) {
                        [weak self, tweens = ctx.tweens] fired in
                        self?.spinReset = nil
                        tweens.add(TweenSpec(channel: reset.channel,
                                             to: .number(reset.value),
                                             duration: 0),
                                   now: fired)
                    }
                }
            }
        }
        if let s = speech, now >= s.until { speech = nil }
    }
}
