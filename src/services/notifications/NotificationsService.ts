import { buildNotificationDrafts } from "./nudgePolicy";
import { cancelManagedNotifications, scheduleDrafts } from "./notificationScheduler";
import { NotificationPlanContext, NotificationSyncResult } from "./types";
import {
  supportsNotifications,
  unsupportedNotificationPermissionStatus,
} from "../../bootstrap/runtime/runtimeSupport";

export interface NotificationServiceContract {
  configure(): Promise<void>;
  getPermissionStatus(): Promise<string>;
  requestAccess(): Promise<string>;
  syncPlanNotifications(context: NotificationPlanContext): Promise<NotificationSyncResult>;
  clearManagedNotifications(): Promise<void>;
}

let notificationsModulePromise: Promise<typeof import("expo-notifications")> | null = null;
let notificationHandlerConfigured = false;

async function getNotificationsModule() {
  if (!supportsNotifications()) {
    return null;
  }

  if (!notificationsModulePromise) {
    notificationsModulePromise = import("expo-notifications").catch((error) => {
      notificationsModulePromise = null;
      throw error;
    });
  }

  const Notifications = await notificationsModulePromise;

  if (!notificationHandlerConfigured) {
    Notifications.setNotificationHandler({
      handleNotification: async () => ({
        shouldPlaySound: false,
        shouldSetBadge: false,
        shouldShowBanner: true,
        shouldShowList: true,
      }),
    });
    notificationHandlerConfigured = true;
  }

  return Notifications;
}

export const NotificationsService: NotificationServiceContract = {
  async configure() {
    const Notifications = await getNotificationsModule();
    if (!Notifications) {
      return;
    }

    await Notifications.setNotificationChannelAsync("planning", {
      name: "Planning",
      importance: Notifications.AndroidImportance.DEFAULT,
      vibrationPattern: [0, 120],
      lightColor: "#6D7C6D",
      sound: null,
    });
  },

  async getPermissionStatus() {
    const Notifications = await getNotificationsModule();
    if (!Notifications) {
      return unsupportedNotificationPermissionStatus;
    }

    const { status } = await Notifications.getPermissionsAsync();
    return status;
  },

  async requestAccess() {
    const Notifications = await getNotificationsModule();
    if (!Notifications) {
      return unsupportedNotificationPermissionStatus;
    }

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
