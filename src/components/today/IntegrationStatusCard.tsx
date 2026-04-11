import { Pressable, View } from "react-native";

import { CalendarConnectionState, CalendarPermissionState, CalendarSyncState } from "../../domain/models";
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
}

function ActionButton(props: { label: string; onPress: () => Promise<void> }) {
  return (
    <Pressable
      className="rounded-full bg-[#E6EDE4] px-4 py-2"
      onPress={() => {
        void props.onPress();
      }}
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

  return (
    <Surface tone={usingLiveCalendar ? "accent" : "default"} className="gap-4">
      <View className="gap-2">
        <AppText tone="secondary" variant="caption">
          Real-world context
        </AppText>
        <AppText variant="section">
          {usingLiveCalendar ? "Today is grounded in live calendar context." : "Today is staying on fallback context."}
        </AppText>
        <AppText tone="secondary">{calendarDetail}</AppText>
      </View>

      <View className="flex-row flex-wrap gap-3">
        {needsCalendarPermission ? (
          <ActionButton label="Connect calendar" onPress={onRequestCalendarAccess} />
        ) : null}
        {calendarDenied ? (
          <ActionButton label="Retry calendar access" onPress={onRequestCalendarAccess} />
        ) : null}
        {canRetryCalendar ? (
          <ActionButton label="Refresh calendar" onPress={onRefreshIntegration} />
        ) : null}
        {notificationNeedsPermission ? (
          <ActionButton label="Allow reminders" onPress={onRequestNotificationAccess} />
        ) : null}
      </View>
    </Surface>
  );
}
