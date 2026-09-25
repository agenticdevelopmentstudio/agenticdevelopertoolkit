import { useCallback, useEffect, useMemo, useReducer, useRef, useState } from 'react'
import type { Backend } from '../contract/backend/Backend'
import type { ChatStateObserver } from '../contract/chat/ChatStateObserver'
import type { Message } from '../contract/messages/Message'
import type { Participant } from '../contract/participants/Participant'
import { ChatBackendAdapter } from '../backends/ChatBackendAdapter'
import type { ChatBackend } from '../backends/types'
import { draftMessageID, projectMessages } from '../projection/toChatMessages'
import { DefaultOrchestrator } from '../runtime/DefaultOrchestrator'
import { InMemoryPermissionStore } from '../runtime/InMemoryPermissionStore'
import type { ChatMessage, ChatParticipant } from '../types'

export interface UseChatSessionOptions {
  /**
   * Either transport. A contract `Backend` — the portable one, which
   * `PersonaChatBackend` implements — is driven directly. A `ChatBackend`,
   * this package's original web-only interface, is adapted onto the same
   * events by `ChatBackendAdapter`. The hook itself speaks neither: it reads
   * an orchestrator and calls `submitMessage`.
   */
  backend?: ChatBackend | Backend
  /**
   * An orchestrator to render, instead of one built from `backend`. Pass the
   * same instance to two surfaces and they show one conversation — a phone
   * pane and a desktop pane, say — with `inboundEvents` still consumed exactly
   * once, by the orchestrator rather than by either surface.
   *
   * Its lifetime belongs to whoever created it: the hook neither starts a
   * conversation on it nor tears its backend down, and `welcomeMessage` is
   * ignored, since the second surface to mount would otherwise say hello again
   * into a conversation already underway.
   */
  orchestrator?: DefaultOrchestrator
  persona: ChatParticipant
  user?: ChatParticipant
  welcomeMessage?: string
  /**
   * Identifies the persona in the transcript. Only worth setting alongside a
   * contract backend that stamps its events with a particular id — a persona
   * slug, say — so scripted lines from `say` are attributed to the same
   * participant the backend's replies are.
   */
  personaID?: string
}

export interface ChatSession {
  messages: ChatMessage[]
  isTyping: boolean
  sendMessage: (text: string) => void
  /**
   * Make the persona "speak" a line unprompted, typed in letter-by-letter.
   * Resolves once the whole line has landed. Useful for scripted intros.
   */
  say: (text: string) => Promise<void>
  /**
   * The same thing, for a line whose text arrives in pieces.
   *
   * `say` owns both the words and their timing: it takes a finished string and
   * types it at a cadence baked into this hook. That is right for a scripted
   * intro and wrong for anything whose pacing is the point — a caller imitating
   * a token stream, or one genuinely reading from a socket, wants the timing to
   * be its own and the transcript plumbing to be ours.
   *
   * Each chunk appends to a draft; the message commits when the iterable is
   * done. Resolves then, and — like `say` — teardown mid-line commits what has
   * arrived rather than dropping it, so an awaiting caller is never left
   * hanging. Unlike `say` that partial line really is partial: there is no
   * finished string to substitute, which is the honest outcome for a stream
   * that stopped.
   */
  sayStream: (chunks: AsyncIterable<string>) => Promise<void>
  selectedIndex: number
  selectMessage: (index: number) => void
}

const LOCAL_PARTICIPANT_ID = 'local'
const DEFAULT_PERSONA_ID = 'persona'
const DEFAULT_USER: ChatParticipant = { name: 'You', avatar: 'Y' }

function isContractBackend(backend: ChatBackend | Backend): backend is Backend {
  return 'inboundEvents' in backend
}

function toParticipant(
  id: string,
  display: ChatParticipant,
  kind: 'user' | 'persona',
): Participant {
  return {
    id,
    displayName: display.name,
    address: id,
    kinds: new Set([kind]),
    conversationState: 'joined',
  }
}

/**
 * Everything one mounted chat owns: the orchestrator, the backend behind it,
 * and the first-seen clock the projection needs.
 */
interface Session {
  readonly orchestrator: DefaultOrchestrator
  readonly personaID: string
  /** False when the orchestrator was handed in, and its lifetime is not ours. */
  readonly owned: boolean
  project(): ChatMessage[]
  destroyBackend(): void
  /**
   * This session on a fresh transport, carrying its transcript, once
   * `destroyBackend` has torn the old one down — or null when nothing was torn
   * down, or when the transport is not ours to rebuild. See the session effect.
   */
  revive(): Session | null
}

interface SessionOptions {
  backend?: ChatBackend | Backend
  orchestrator?: DefaultOrchestrator
  persona: ChatParticipant
  user: ChatParticipant
  personaID: string
  welcomeMessage?: string
  /** What an earlier session had already said, for `revive`. Replaces the welcome. */
  transcript?: ReadonlyArray<Message>
}

function createSession(options: SessionOptions): Session {
  const { personaID } = options
  if (options.orchestrator) return adoptSession(options.orchestrator, options, personaID)
  const raw = options.backend
  if (!raw) {
    throw new Error('useChatSession needs either a backend or an orchestrator.')
  }
  const parts = {
    persona: options.persona,
    user: options.user,
    localParticipantID: LOCAL_PARTICIPANT_ID,
  }

  // A clock for what the contract does not date: an unacknowledged message,
  // and every draft. First sight wins and is then held, because projection
  // runs on every render and a fresh `new Date()` would walk the displayed
  // times forward across the whole transcript on each pass.
  const stamps = new Map<string, Date>()
  const stampFor = (key: string): Date => {
    const existing = stamps.get(key)
    if (existing) return existing
    const now = new Date()
    stamps.set(key, now)
    return now
  }

  // Assigned immediately below. The adapter only reads it from inside a
  // callback the orchestrator itself triggers, so it is always set by then.
  let orchestrator: DefaultOrchestrator
  // Set by `destroyBackend`; what `revive` checks before building a successor.
  let tornDown = false

  const backend: Backend = isContractBackend(raw)
    ? raw
    : new ChatBackendAdapter(raw, {
        personaID,
        history: () => project(),
      })

  orchestrator = new DefaultOrchestrator({
    conversationID: crypto.randomUUID(),
    localParticipantID: LOCAL_PARTICIPANT_ID,
    initialParticipants: [
      toParticipant(LOCAL_PARTICIPANT_ID, options.user, 'user'),
      toParticipant(personaID, options.persona, 'persona'),
    ],
    commands: [],
    observingHooks: [],
    gatingHooks: [],
    permissionStore: new InMemoryPermissionStore(),
    backend,
    display: {
      showAvatars: true,
      showReadReceipts: false,
      showTypingIndicators: true,
      allowJoining: false,
      allowDeparting: false,
      reducedMotion: false,
    },
  })

  function project(): ChatMessage[] {
    // A draft's clock starts when the draft does. Dropping the entry once the
    // draft is gone is what keeps the next reply from inheriting the previous
    // one's timestamp.
    for (const key of [...stamps.keys()]) {
      if (!key.startsWith('draft:')) continue
      if (orchestrator.activeDrafts.some((d) => draftMessageID(d.participantID) === key)) continue
      stamps.delete(key)
    }
    return projectMessages(orchestrator, parts, stampFor)
  }

  if (options.transcript) {
    // A revived session picks up where the torn-down one stopped. Everything in
    // it has landed — the teardown lands a line mid-type and closes any draft —
    // so it is settled messages only, and the welcome is among them already.
    orchestrator.messages = options.transcript
  } else if (options.welcomeMessage) {
    // A welcome is a line the persona says, so it enters the transcript the
    // way every other persona line does. Delivered before `start()`, which
    // means it is already there on the first render rather than arriving as an
    // update the frame after.
    orchestrator.deliver({
      kind: 'messageReceived',
      message: {
        localID: crypto.randomUUID(),
        senderID: personaID,
        text: options.welcomeMessage,
        timestamp: new Date(),
        attachments: [],
        deliveryStatus: { kind: 'delivered' },
      },
    })
  }

  return {
    orchestrator,
    personaID,
    owned: true,
    project,
    destroyBackend(): void {
      // Closing the backend ends the orchestrator's event loop on its own —
      // the inbound stream completes — so there is no separate `stop()` here.
      //
      // `backend`, NOT `raw`. When `raw` is already a contract backend the two are
      // the same object and this is unchanged; when it is not, `backend` is the
      // `ChatBackendAdapter` built above and the adapter is what the orchestrator
      // has been driving. Destroying `raw` directly skipped the adapter's own
      // teardown — its shared AbortController, and the EventQueue whose closure is
      // what actually ends `runEventLoop`'s pending `iterator.next()` — so every
      // mount/unmount cycle leaked an adapter, a controller, and an event loop that
      // could never complete. The adapter's `destroy()` calls `raw.destroy?.()`
      // itself, so nothing is lost by going through it.
      ;(backend as { destroy?: () => void }).destroy?.()
      tornDown = true
    },
    revive(): Session | null {
      // Only an adapter this session built is ours to build again. A contract
      // backend handed in is the caller's, and it refuses reuse after destroy by
      // design (PersonaChatBackend: ci-destroy-authoritative) — reconnecting it
      // behind the caller's back is exactly what that refusal is there to stop.
      if (!tornDown || backend === raw) return null
      return createSession({ ...options, transcript: orchestrator.messages })
    },
  }
}

/**
 * A session over an orchestrator someone else owns. The projection state — the
 * first-seen clock — is still per-surface, because it describes what THIS
 * surface has drawn, not what the conversation contains.
 */
function adoptSession(
  orchestrator: DefaultOrchestrator,
  options: { persona: ChatParticipant; user: ChatParticipant },
  personaID: string,
): Session {
  const parts = {
    persona: options.persona,
    user: options.user,
    localParticipantID: LOCAL_PARTICIPANT_ID,
  }
  const stamps = new Map<string, Date>()
  const stampFor = (key: string): Date => {
    const existing = stamps.get(key)
    if (existing) return existing
    const now = new Date()
    stamps.set(key, now)
    return now
  }
  return {
    orchestrator,
    personaID,
    owned: false,
    project(): ChatMessage[] {
      for (const key of [...stamps.keys()]) {
        if (!key.startsWith('draft:')) continue
        if (orchestrator.activeDrafts.some((d) => draftMessageID(d.participantID) === key)) continue
        stamps.delete(key)
      }
      return projectMessages(orchestrator, parts, stampFor)
    },
    destroyBackend(): void {
      // Not ours to close.
    },
    revive(): null {
      // Never torn down, so there is nothing to revive.
      return null
    },
  }
}

export function useChatSession(options: UseChatSessionOptions): ChatSession {
  const {
    backend,
    orchestrator,
    persona,
    user = DEFAULT_USER,
    welcomeMessage,
    personaID = DEFAULT_PERSONA_ID,
  } = options

  const [version, bump] = useReducer((n: number): number => n + 1, 0)

  // Built once and kept. A session rebuilt when `backend` changes identity would
  // look reasonable and be a trap: `backend={new MockBackend()}` written inline in
  // a render — which is how the modes are demoed — hands back a new object every
  // pass, and the conversation would reset on each one. A backend swapped
  // mid-conversation is not a thing the modes do; a re-rendered parent is. The one
  // replacement is the session effect's own revive, below.
  const [session, setSession] = useState(() =>
    createSession({
      backend,
      orchestrator,
      persona,
      user,
      personaID,
      welcomeMessage,
    }),
  )

  const [selectedIndex, setSelectedIndex] = useState(-1)

  // Every line `say` or `sayStream` has in flight, held as the function that LANDS it: stop the timer,
  // put the whole line in the message, resolve. A line types at one character per ~40ms and the
  // promise resolves on the last one, so a caller that leaves mid-line — a route change, or a
  // test returning — otherwise leaves the rest of the chain scheduled against a component that
  // is gone. Landing rather than merely cancelling is what makes teardown survivable for a
  // caller that AWAITS the line; see the cleanup at the bottom of this hook.
  const pendingLinesRef = useRef<Set<() => void>>(new Set())

  // The session outlives this effect, so Strict Mode's mount → cleanup → mount
  // finds the same orchestrator and the same transcript on the second pass —
  // which is the point. Only the subscription and the backend are torn down,
  // exactly as they were when the hook owned transport directly.
  //
  // But a torn-down backend stays torn down, and the second pass used to carry on
  // over it: every send threw "has been destroyed", `sendMessage` swallowed it, and
  // in a dev build nothing the reader typed ever reached the transcript. So a pass
  // that finds its session torn down swaps in its revival — the same transcript on
  // a fresh transport — and subscribes to that one when it renders.
  useEffect(() => {
    const revived = session.revive()
    if (revived) {
      setSession(revived)
      return
    }
    const observer: ChatStateObserver = { chatDidUpdate: (): void => bump() }
    session.orchestrator.addObserver(observer)
    if (session.owned) session.orchestrator.start()
    return () => {
      session.orchestrator.removeObserver(observer)
      session.destroyBackend()
    }
  }, [session])

  const messages = useMemo(
    () => session.project(),
    // `version` is the subscription: it ticks on every `ChatUpdate`, which is
    // the only thing that can change what a projection returns.
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [session, version],
  )

  /**
   * Derived, not tracked. The persona is "typing" exactly when the last thing
   * said was ours and nothing has started coming back — no draft open, no
   * reply committed. A flag set on send and cleared on first token says the
   * same thing while being able to disagree with the transcript; this cannot.
   */
  const isTyping = useMemo(() => {
    if (session.orchestrator.activeDrafts.length > 0) return false
    const last = session.orchestrator.messages[session.orchestrator.messages.length - 1]
    return last !== undefined && last.senderID === LOCAL_PARTICIPANT_ID
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [session, version])

  const sendMessage = useCallback(
    (text: string) => {
      const trimmed = text.trim()
      if (!trimmed) return
      // The orchestrator reports a failed submit as an `error` update and
      // rethrows for callers that await it. This one does not await, so the
      // rejection is caught here rather than left to surface as an unhandled
      // one.
      void session.orchestrator.submitMessage(trimmed, []).catch(() => {})
    },
    [session],
  )

  // The persona speaks a line unprompted, typed in letter-by-letter (a scripted
  // message, not a reply). Resolves when the whole line has landed.
  //
  // Expressed as the events a streamed reply would produce — a draft that
  // grows, then an immutable message — so nothing downstream has to know the
  // difference. `messageReceived` clears the sender's draft on arrival, which
  // is why no `draftCleared` follows.
  const say = useCallback(
    (text: string): Promise<void> => {
      const { orchestrator, personaID: speakerID } = session
      const localID = crypto.randomUUID()
      const startedAt = new Date()
      const pending = pendingLinesRef.current
      return new Promise<void>((resolve) => {
        let i = 0
        let timer: ReturnType<typeof setTimeout> | undefined
        // The end of the line, however it is reached: typed to the last character, or cut short
        // by teardown with no time left to type. Both want the same three things, and committing
        // the full `text` rather than the slice reached so far is what keeps a cut-short line a
        // whole sentence instead of a fragment frozen mid-word.
        const land = (): void => {
          if (timer !== undefined) clearTimeout(timer)
          pending.delete(land)
          orchestrator.deliver({
            kind: 'messageReceived',
            message: {
              localID,
              senderID: speakerID,
              text,
              timestamp: startedAt,
              attachments: [],
              deliveryStatus: { kind: 'delivered' },
            },
          })
          resolve()
        }
        const step = (): void => {
          i += 1
          if (i >= text.length) {
            land()
            return
          }
          orchestrator.deliver({
            kind: 'draftUpdated',
            participantID: speakerID,
            text: text.slice(0, i),
            attachments: [],
          })
          timer = setTimeout(step, 26 + Math.random() * 28)
        }
        pending.add(land)
        timer = setTimeout(step, 0)
      })
    },
    [session],
  )

  // The streaming sibling of `say`. Same two events in the same order — a draft
  // that grows, then an immutable message — with the caller driving the clock.
  //
  // The `landed` flag, rather than reusing `say`'s pattern of clearing a timer:
  // there is no timer here to cancel. The only thing teardown can do to a
  // for-await loop is let it discover on its next tick that the line is already
  // committed, so the loop checks and returns instead of delivering a draft
  // update into a torn-down orchestrator.
  const sayStream = useCallback(
    (chunks: AsyncIterable<string>): Promise<void> => {
      const { orchestrator, personaID: speakerID } = session
      const localID = crypto.randomUUID()
      const startedAt = new Date()
      const pending = pendingLinesRef.current
      let text = ''
      let landed = false

      const land = (): void => {
        if (landed) return
        landed = true
        pending.delete(land)
        orchestrator.deliver({
          kind: 'messageReceived',
          message: {
            localID,
            senderID: speakerID,
            text,
            timestamp: startedAt,
            attachments: [],
            deliveryStatus: { kind: 'delivered' },
          },
        })
      }
      pending.add(land)

      return (async () => {
        try {
          for await (const chunk of chunks) {
            if (landed) return
            text += chunk
            orchestrator.deliver({
              kind: 'draftUpdated',
              participantID: speakerID,
              text,
              attachments: [],
            })
          }
        } finally {
          land()
        }
      })()
    },
    [session],
  )

  const selectMessage = useCallback(
    (index: number) => {
      if (index >= -1 && index < messages.length) {
        setSelectedIndex(index)
      }
    },
    [messages.length],
  )

  // Unmount only — an empty dependency list, unlike the effect above, because a new `backend`
  // is no reason to cut a line off mid-word.
  //
  // Each in-flight line is LANDED rather than abandoned: its timer is cleared, its text is
  // written whole, and its promise resolves. The promises were left hanging here once, on the
  // argument that resolving means "the line landed" and it had not — which is true of the
  // animation and false of everything a caller does with it. React's Strict Mode runs every
  // effect mount → cleanup → mount in development, so that argument cost the intro ritual its
  // whole chain on the first render of every dev session: `await say(welcome)` never settled,
  // and bitbag sat behind a disabled composer with one empty bubble streaming forever. A
  // promise nothing can ever settle is not a truthful "it did not happen" — it is a caller
  // stuck at an await with no way to find out.
  //
  // Landing is the honest version of the same intent. Nothing is scheduled past teardown (the
  // timers are still cleared, which is what the test below pins), a real unmount's delivery
  // reaches an orchestrator no one is reading, and a caller that is still there — Strict Mode's
  // second mount — finds its line whole and carries on.
  useEffect(() => {
    const pending = pendingLinesRef.current
    return () => {
      // A copy: `land` deletes itself from this set as it runs.
      for (const land of [...pending]) land()
      pending.clear()
    }
  }, [])

  return useMemo(
    () => ({
      messages,
      isTyping,
      sendMessage,
      say,
      sayStream,
      selectedIndex,
      selectMessage,
    }),
    [messages, isTyping, sendMessage, say, sayStream, selectedIndex, selectMessage],
  )
}
