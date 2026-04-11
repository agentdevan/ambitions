import * as Notifications from "expo-notifications";

Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldPlaySound: false,
    shouldSetBadge: false,
    shouldShowBanner: true,
    shouldShowList: true,
  }),
});

export interface NotificationDraft {
  id: string;
  title: string;
  body: string;
  scheduledAt?: string;
  metadata?: Record<string, string>;
}

export interface NotificationServiceContract {
  configure(): Promise<void>;
  requestAccess(): Promise<Notifications.PermissionStatus>;
  scheduleReminder(notification: NotificationDraft): Promise<string | null>;
  sendContextualNudge(notification: NotificationDraft): Promise<string | null>;
}

export const NotificationsService: NotificationServiceContract = {
  async configure() {
    await Notifications.setNotificationChannelAsync("planning", {
      name: "Planning",
      importance: Notifications.AndroidImportance.DEFAULT,
      vibrationPattern: [0, 120],
      lightColor: "#6D7C6D",
    });
  },

  async requestAccess() {
    const { status } = await Notifications.requestPermissionsAsync();
    return status;
  },

  async scheduleReminder(notification) {
    if (!notification.scheduledAt) {
      return null;
    }

    return Notifications.scheduleNotificationAsync({
      content: {
        title: notification.title,
        body: notification.body,
        data: notification.metadata,
      },
      trigger: null,
    });
  },

  async sendContextualNudge(notification) {
    return Notifications.scheduleNotificationAsync({
      content: {
        title: notification.title,
        body: notification.body,
        data: notification.metadata,
      },
      trigger: null,
    });
  },
};
