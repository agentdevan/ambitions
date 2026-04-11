import { AdaptationProfile, ReplanSuggestion } from "../domain/models";

export interface AdaptationRepository {
  getLatestProfile(): Promise<AdaptationProfile | null>;
  listReplanSuggestions(planDate: string): Promise<ReplanSuggestion[]>;
  saveProfiles(profiles: AdaptationProfile[]): Promise<void>;
  saveReplanSuggestions(suggestions: ReplanSuggestion[]): Promise<void>;
}
