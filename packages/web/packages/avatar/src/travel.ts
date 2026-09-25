"use client";

export interface TravelOptions {
  /** How long the move takes, ms — match it to whatever the avatar is moving with. */
  duration: number;
  /** The move's timing function. Default: a quick start that eases into place. */
  easing?: string;
  /** How high the landing bounce goes, px. 0 (default) lands without one. */
  bounce?: number;
  /** How long the bounce takes after the landing, ms. */
  bounceDuration?: number;
}

const DEFAULT_EASING = "cubic-bezier(0.22, 1, 0.36, 1)";

// The travel each element is on, so a new one starts from where the last one had got
// to rather than both writing its transform at once.
const current = new WeakMap<Element, Animation>();

/**
 * Carry an avatar from one perch to another — FLIP: its layout has ALREADY moved to
 * the new perch, and `from` is where it was (a `getBoundingClientRect()` taken
 * before the move). It is drawn back at `from` and animated home, so it appears to
 * travel between two places that CSS positions in unrelated ways — in a flex column
 * at rest, absolutely on a chat's corner — and that no transition can join.
 *
 * Whatever transform the element's own CSS gives it at the new perch is kept: the
 * travel is layered in front of it, and it is where the travel ends. Its size is
 * carried by a scale about its own `transform-origin`, so an avatar laid out at a
 * different width at each perch grows or shrinks on the way.
 *
 * Returns the running animation, or `null` when there is nothing to animate: no
 * Web Animations API, a zero-size box, no distance to cover, or the reader asked
 * for reduced motion — which lands it at once, as a layout change always would.
 */
export function travelFrom(el: HTMLElement, from: DOMRect, options: TravelOptions): Animation | null {
  const { duration, easing = DEFAULT_EASING, bounce = 0, bounceDuration = 280 } = options;
  if (typeof el.animate !== "function") return null;
  if (typeof window !== "undefined" && window.matchMedia?.("(prefers-reduced-motion: reduce)").matches) {
    return null;
  }
  // Measure the new perch with no travel on it: a travel still running would be
  // measured as part of where the element lives.
  current.get(el)?.cancel();
  current.delete(el);

  const to = el.getBoundingClientRect();
  if (!to.width || !from.width) return null;
  const style = getComputedStyle(el);
  const base = style.transform && style.transform !== "none" ? style.transform : "";
  const [originX = 0, originY = 0] = style.transformOrigin.split(" ").map((v) => parseFloat(v) || 0);

  // The scale is about the origin, so the translate is what puts the origin back where
  // it was: a point P lands on O + s·(P − O) + d, and the box's top-left must land on
  // `from`'s.
  const s = from.width / to.width;
  const ox = to.left + originX;
  const oy = to.top + originY;
  const dx = from.left - ox - s * (to.left - ox);
  const dy = from.top - oy - s * (to.top - oy);
  const still = Math.abs(dx) < 0.5 && Math.abs(dy) < 0.5 && Math.abs(s - 1) < 0.001;
  if (still && !bounce) return null;

  const at = (extra: string): string => `${base} ${extra}`.trim();
  const home = base || "none";
  const total = duration + (bounce ? bounceDuration : 0);
  const landed = duration / total;
  const after = (share: number): number => landed + (1 - landed) * share;

  const frames: Keyframe[] = [
    { offset: 0, transform: at(`translate(${dx}px, ${dy}px) scale(${s})`), easing },
    { offset: landed, transform: home, easing: "ease-out" },
  ];
  if (bounce) {
    // One hop and a smaller one: enough to read as landing, not as a mood.
    frames.push(
      { offset: after(0.35), transform: at(`translateY(${-bounce}px)`), easing: "ease-in" },
      { offset: after(0.65), transform: home, easing: "ease-out" },
      { offset: after(0.83), transform: at(`translateY(${-bounce * 0.3}px)`), easing: "ease-in" },
      { offset: 1, transform: home },
    );
  }
  const travel = el.animate(frames, { duration: total });
  current.set(el, travel);
  const done = (): void => {
    if (current.get(el) === travel) current.delete(el);
  };
  travel.addEventListener?.("finish", done);
  travel.addEventListener?.("cancel", done);
  return travel;
}
