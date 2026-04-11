import * as Notifications from "expo-notifications";

import { buildNotificationDrafts } from "./nudgePolicy";
import { cancelManagedNotifications, scheduleDrafts } from "./notificationScheduler";
import { NotificationPlanContext, NotificationSyncResult } from "./types";

Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldPlaySound: false,
    shouldSetBadge: false,
    shouldShowBanner: true,
    shouldShowList: true,
  }),
});

export interface NotificationServiceContract {
  configure(): Promise<void>;
  getPermissionStatus(): Promise<Notifications.PermissionStatus>;
  requestAccess(): Promise<Notifications.PermissionStatus>;
  syncPlanNotifications(context: NotificationPlanContext): Promise<NotificationSyncResult>;
  clearManagedNotifications(): Promise<void>;
}

export const NotificationsService: NotificationServiceContract = {
  async configure() {
    await Notifications.setNotificationChannelAsync("planning", {
      name: "Planning",
      importance: Notifications.AndroidImportance.DEFAULT,
      vibrationPattern: [0, 120],
      lightColor: "#6D7C6D",
      sound: null,
    });
  },

  async getPermissionStatus() {
    const { status } = await Notifications.getPermissionsAsync();
    return status;
  },

  async requestAccess() {
    const { status } = await Notifications.requestPermissionsAsync();
    return status;
  },

  async syncPlanNotifications(context) {
    const status = await this.getPermissionStatus();

    if (status !== "granted") {
      await cancelManagedNotifications();
      return { scheduledIds: [], drafts: [] };
    }

    const drafts = buildNotificationDrafts(context);
    return scheduleDrafts(drafts);
  },

  async clearManagedNotifications() {
    await cancelManagedNotifications();
  },
};
