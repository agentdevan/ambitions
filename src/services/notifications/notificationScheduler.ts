import type * as Notifications from "expo-notifications";

import { NotificationDraft, NotificationSyncResult } from "./types";
import { supportsNotifications } from "../../bootstrap/runtime/runtimeSupport";

const managedFlag = "ambitionsManaged";

let notificationsModulePromise: Promise<typeof import("expo-notifications")> | null = null;

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

  return notificationsModulePromise;
}

function isManagedRequest(request: Notifications.NotificationRequest) {
  return request.content.data?.[managedFlag] === true;
}

export async function cancelManagedNotifications() {
  const NotificationsModule = await getNotificationsModule();
  if (!NotificationsModule) {
    return;
  }

  const requests = await NotificationsModule.getAllScheduledNotificationsAsync();

  await Promise.all(
    requests
      .filter(isManagedRequest)
      .map((request) =>
        NotificationsModule.cancelScheduledNotificationAsync(request.identifier),
      ),
  );
}

export async function scheduleDrafts(drafts: NotificationDraft[]): Promise<NotificationSyncResult> {
  const NotificationsModule = await getNotificationsModule();
  if (!NotificationsModule) {
    return { scheduledIds: [], drafts: [] };
  }

  await cancelManagedNotifications();

  const scheduledIds: string[] = [];

  for (const draft of drafts) {
    const scheduledId = await NotificationsModule.scheduleNotificationAsync({
      identifier: draft.id,
      content: {
        title: draft.title,
        body: draft.body,
        data: {
          ...draft.metadata,
          [managedFlag]: true,
          kind: draft.kind,
        },
      },
      trigger: {
        type: NotificationsModule.SchedulableTriggerInputTypes.DATE,
        date: new Date(draft.scheduledAt),
      },
    });

    scheduledIds.push(scheduledId);
  }

  return { scheduledIds, drafts };
}
