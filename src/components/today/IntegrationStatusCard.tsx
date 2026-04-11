import { Pressable, View } from "react-native";

import {
  CalendarConnectionState,
  CalendarPermissionState,
  CalendarSyncState,
} from "../../domain/models";
import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
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

function ActionButton(props: { label: string; onPress: () => Promise<void>; busy?: boolean }) {
  const theme = useResolvedTheme();

  return (
    <Pressable
      className="rounded-full px-4 py-2.5"
      onPress={() => {
        void props.onPress();
      }}
      disabled={props.busy}
      style={({ pressed }) => ({
        backgroundColor: theme.colors.background.accentWash,
        borderColor: theme.colors.border.subtle,
        borderWidth: 1,
        opacity: props.busy ? 0.5 : pressed ? 0.82 : 1,
      })}
    >
      <AppText variant="caption">{props.label}</AppText>
    </Pressable>
  );
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
        <AppText tone="secondary" variant="caption">
          Real-world context
        </AppText>
        <AppText variant="section">
          {usingLiveCalendar
            ? "Today is grounded in live calendar context."
            : "Today is staying on fallback context."}
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
          <ActionButton
            label="Connect calendar"
            onPress={onRequestCalendarAccess}
            busy={busyAction === "calendar"}
          />
        ) : null}
        {calendarDenied ? (
          <ActionButton
            label="Retry calendar access"
            onPress={onRequestCalendarAccess}
            busy={busyAction === "calendar"}
          />
        ) : null}
        {canRetryCalendar ? (
          <ActionButton
            label="Refresh calendar"
            onPress={onRefreshIntegration}
            busy={busyAction === "refresh"}
          />
        ) : null}
        {notificationNeedsPermission ? (
          <ActionButton
            label="Allow reminders"
            onPress={onRequestNotificationAccess}
            busy={busyAction === "notifications"}
          />
        ) : null}
      </View>
    </Surface>
  );
}
