import * as Notifications from "expo-notifications";

import { NotificationDraft, NotificationSyncResult } from "./types";

const managedFlag = "ambitionsManaged";

function isManagedRequest(request: Notifications.NotificationRequest) {
  return request.content.data?.[managedFlag] === true;
}

export async function cancelManagedNotifications() {
  const requests = await Notifications.getAllScheduledNotificationsAsync();

  await Promise.all(
    requests
      .filter(isManagedRequest)
      .map((request) => Notifications.cancelScheduledNotificationAsync(request.identifier)),
  );
}

export async function scheduleDrafts(drafts: NotificationDraft[]): Promise<NotificationSyncResult> {
  await cancelManagedNotifications();

  const scheduledIds: string[] = [];

  for (const draft of drafts) {
    const scheduledId = await Notifications.scheduleNotificationAsync({
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
        type: Notifications.SchedulableTriggerInputTypes.DATE,
        date: new Date(draft.scheduledAt),
      },
    });

    scheduledIds.push(scheduledId);
  }

  return { scheduledIds, drafts };
}
