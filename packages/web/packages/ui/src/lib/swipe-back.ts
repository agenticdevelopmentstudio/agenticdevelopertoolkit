// The seam between a page-wide "flick right = Back" gesture and an in-page Back.
//
// A host may map a horizontal touch flick to `history.back()` for the whole page
// (adh's SwipeHistory does). That is only the SAME action as a visible Back
// chevron while every in-page Back is itself a history entry. It is not always:
// HTDV's narrow stack reveals a `persistentSelection` level's list through local
// state, with no history entry, so on hub /settings the chevron showed the section
// list while the flick left Settings for whatever page came before it. Two answers
// to one gesture, and nothing on screen said which one a flick would get.
//
// So the flick ASKS first. The gesture's owner dispatches this event at the
// element the touch began on; it bubbles, and whichever in-page Back contains that
// element (and is currently showing a Back) answers it by running its own Back and
// calling `preventDefault()`. Only an unanswered flick falls through to history.
// The event carries no detail: the answer is "I went back", never a destination,
// so neither side needs to know the other's routing.
//
// An Event, not a registry of callbacks: containment is the DOM's to decide, and a
// nested stack under the finger must win over an outer one — bubbling order gives
// exactly that, where a registry would need its own notion of "innermost".
//
// This file is the ASKING half. The answering half is `useSwipeBackClaim`
// (hooks/useSwipeBackClaim.ts), and an in-page Back answers through it rather than
// with a listener of its own: HTDV's and HMD's narrow stacks each wrote the same
// listener, and an answer kept in two copies is how two stacks come to answer one
// gesture differently — the claim has three rules (subscribe once, run the Back the
// COMMIT showed, leave an offer a nested stack already claimed), each easy to drop
// alone. The hook lives in hooks/ rather than here because lib/ stays React-free, so
// the gesture's owner can ask without importing React's side of the seam.

/** Name of the cancelable, bubbling event a page-wide swipe-Back offers to in-page Backs. */
export const SWIPE_BACK_EVENT = "awt:swipe-back"

/**
 * Offer a swipe-Back to whatever in-page Back contains `target`.
 *
 * Returns `true` when one claimed it — it ran its own Back and called
 * `preventDefault()` — in which case the caller must NOT also go back in history.
 * Returns `false` when nothing answered, and the caller falls back to its default
 * (`history.back()`).
 */
export function offerSwipeBack(target: EventTarget): boolean {
  const event = new Event(SWIPE_BACK_EVENT, { bubbles: true, cancelable: true })
  // dispatchEvent returns false exactly when a listener called preventDefault().
  return !target.dispatchEvent(event)
}
