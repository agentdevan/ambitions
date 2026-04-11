import { View } from "react-native";

import {
  CalendarConnectionState,
  CalendarPermissionState,
  CalendarSyncState,
} from "../../domain/models";
import { Button } from "../ui/Button";
import { Pill } from "../ui/Pill";
import { Surface } from "../ui/Surface";
import { AppText } from "../ui/Text";

interface IntegrationStatusCardProps {
  calendarConnectionState: CalendarConnectionState | null;
  notificationPermissionStatus: string;
  onRequestCalendarAccess: () => Promise<void>;
  onRequestNotificationAccess: () => Promise<void>;
  onRefreshIntegration: () => Promise<void>;
  usingLiveCalendar: boolean;
  calendarDetail: string;
  busyAction?: "calendar" | "notifications" | "refresh" | null;
}

export function IntegrationStatusCard({
  calendarConnectionState,
  notificationPermissionStatus,
  onRequestCalendarAccess,
  onRequestNotificationAccess,
  onRefreshIntegration,
  usingLiveCalendar,
  calendarDetail,
  busyAction = null,
}: IntegrationStatusCardProps) {
  const needsCalendarPermission =
    !calendarConnectionState ||
    calendarConnectionState.permissionState === CalendarPermissionState.NotAsked;
  const calendarDenied =
    calendarConnectionState?.permissionState === CalendarPermissionState.Denied;
  const canRetryCalendar =
    calendarConnectionState?.permissionState === CalendarPermissionState.Granted &&
    calendarConnectionState.connectionStatus !== CalendarSyncState.Ready;
  const notificationNeedsPermission = notificationPermissionStatus !== "granted";
  const syncFailure =
    calendarConnectionState?.connectionStatus === CalendarSyncState.Stale ||
    calendarConnectionState?.connectionStatus === CalendarSyncState.TemporaryFailure;

  return (
    <Surface tone={usingLiveCalendar ? "accent" : "default"} className="gap-4">
      <View className="gap-2">
        <View className="flex-row flex-wrap gap-2">
          <Pill label="Real-world context" />
          <Pill
            label={usingLiveCalendar ? "Calendar connected" : "Using saved schedule"}
            tone={usingLiveCalendar ? "accent" : "neutral"}
          />
        </View>
        <AppText tone="secondary" variant="caption">
          {usingLiveCalendar
            ? "Today is grounded in live calendar context."
            : "Today is using the saved schedule baseline."}
        </AppText>
        <AppText tone="secondary">{calendarDetail}</AppText>
        {syncFailure && calendarConnectionState?.metadata.lastError ? (
          <AppText tone="tertiary" variant="caption">
            Last read issue: {String(calendarConnectionState.metadata.lastError)}
          </AppText>
        ) : null}
      </View>

      <View className="flex-row flex-wrap gap-3">
        {needsCalendarPermission ? (
          <Button
            tone="secondary"
            size="compact"
            onPress={() => void onRequestCalendarAccess()}
            busy={busyAction === "calendar"}
          >
            Connect calendar
          </Button>
        ) : null}
        {calendarDenied ? (
          <Button
            tone="secondary"
            size="compact"
            onPress={() => void onRequestCalendarAccess()}
            busy={busyAction === "calendar"}
          >
            Retry calendar access
          </Button>
        ) : null}
        {canRetryCalendar ? (
          <Button
            tone="secondary"
            size="compact"
            onPress={() => void onRefreshIntegration()}
            busy={busyAction === "refresh"}
          >
            Refresh calendar
          </Button>
        ) : null}
        {notificationNeedsPermission ? (
          <Button
            tone="secondary"
            size="compact"
            onPress={() => void onRequestNotificationAccess()}
            busy={busyAction === "notifications"}
          >
            Allow reminders
          </Button>
        ) : null}
      </View>
    </Surface>
  );
}
