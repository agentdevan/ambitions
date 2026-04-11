import * as Notifications from "expo-notifications";

Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldPlaySound: false,
    shouldSetBadge: false,
    shouldShowBanner: true,
    shouldShowList: true,
  }),
});

export const NotificationsService = {
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
};
