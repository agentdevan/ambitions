import type { AdaptationProfile } from "../../domain/models";

export {
  CapacityLoad,
  ReplanningStyle,
  StrategyStrictness,
} from "../../domain/models";
export type { AdaptationProfile } from "../../domain/models";
export type CapacityProfile = AdaptationProfile["capacity"];
export type CompletionProfile = AdaptationProfile["completion"];
export type FrictionProfile = AdaptationProfile["friction"];
export type MomentumProfile = AdaptationProfile["momentum"];
export type StrategyProfile = AdaptationProfile["strategy"];
