// The avatar behavior + animation engine. The headline is `useAvatarEngine`; the
// individual reflex/pose pieces are exported too, so a custom avatar can compose
// them differently if it needs to.

export { useAvatarEngine } from "./engine";
export type {
  AvatarEngine,
  AvatarEngineConfig,
  Choreography,
  ExpressionEffect,
} from "./engine";

export { useBlink, useIdleLadder, useSpeech } from "./reflexes";
export { useArbitration } from "./arbitration";
export type { MoodMap, WakingConfig, ArbitrationConfig, Arbitration } from "./arbitration";
export { useGaze } from "./gaze";
export type { GazeOptions } from "./gaze";
export { useIdleFidget } from "./idleLife";
export type { IdleFidgetOptions } from "./idleLife";
export { useSpeechBubble } from "./speechBubble";
export { applyPose } from "./pose";
export { travelFrom } from "./travel";
export type { TravelOptions } from "./travel";

export { DEFAULT_TUNING } from "./types";
export type {
  AvatarDriverProps,
  Pose,
  AvatarRig,
  Ref,
  EyesChannel,
  IrisChannel,
  AntennaeChannel,
  BrowsChannel,
  MouthChannel,
  DescenderChannel,
  FaceChannel,
  Tuning,
  Ladder,
} from "./types";
