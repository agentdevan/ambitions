import { View } from "react-native";

import {
  CalendarConnectionState,
  CalendarPermissionState,
  CalendarSyncState,
} from "../../domain/models";
import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { Button } from "../ui/Button";
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
  const theme = useResolvedTheme();
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
    <Surface tone="sunken" className="gap-4">
      <View className="gap-2">
        <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
          Integrations
        </AppText>
        <AppText variant="section">Context</AppText>
        <AppText tone="secondary" variant="caption">
          {usingLiveCalendar ? "Live calendar" : "Saved schedule"}
        </AppText>
        <View
          className="rounded-[18px] px-4 py-4"
          style={{
            backgroundColor: theme.colors.background.elevated,
            borderWidth: 1,
            borderColor: theme.colors.border.strong,
          }}
        >
          <AppText tone="secondary">{calendarDetail}</AppText>
          {syncFailure && calendarConnectionState?.metadata.lastError ? (
            <AppText tone="tertiary" variant="caption" style={{ marginTop: 8 }}>
              Last issue: {String(calendarConnectionState.metadata.lastError)}
            </AppText>
          ) : null}
        </View>
        <View className="flex-row flex-wrap gap-x-5 gap-y-2">
          <AppText tone="secondary" variant="caption">
            Calendar: {usingLiveCalendar ? "Connected" : "Offline"}
          </AppText>
          <AppText tone="secondary" variant="caption">
            Reminders: {notificationNeedsPermission ? "Needs access" : "Ready"}
          </AppText>
        </View>
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
            tone="tertiary"
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
            Refresh context
          </Button>
        ) : null}
        {notificationNeedsPermission ? (
          <Button
            tone="tertiary"
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
