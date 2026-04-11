import { Domain, NotificationPreference, UserPreferences } from "../domain/models";

export interface PreferencesRepository {
  listDomains(): Promise<Domain[]>;
  getUserPreferences(): Promise<UserPreferences | null>;
  listNotificationPreferences(): Promise<NotificationPreference[]>;
  saveDomains(domains: Domain[]): Promise<void>;
  saveUserPreferences(preferences: UserPreferences): Promise<void>;
  saveNotificationPreferences(preferences: NotificationPreference[]): Promise<void>;
}
