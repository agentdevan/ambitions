import { View } from "react-native";

import { CapacityInsight } from "../../components/today/CapacityInsight";
import { GuidancePanel } from "../../components/today/GuidancePanel";
import { IntegrationStatusCard } from "../../components/today/IntegrationStatusCard";
import { ProgressPanel } from "../../components/today/ProgressPanel";
import { ReplanSuggestionsPanel } from "../../components/today/ReplanSuggestionsPanel";
import { ScheduleContext } from "../../components/today/ScheduleContext";
import { TimelinePlan } from "../../components/today/TimelinePlan";
import { TodayHeader } from "../../components/today/TodayHeader";
import { UnscheduledTasksPanel } from "../../components/today/UnscheduledTasksPanel";
import { Screen } from "../../components/ui/Screen";
import { AppText } from "../../components/ui/Text";
import { useAppStore } from "../../state/useAppStore";
import { formatLongDate } from "../../utils/date";

export function TodayScreen() {
  const today = useAppStore((state) => state.today);
  const bootStatus = useAppStore((state) => state.bootStatus);
  const applyTaskAction = useAppStore((state) => state.applyTaskAction);
  const calendarConnectionState = useAppStore((state) => state.calendarConnectionState);
  const notificationPermissionStatus = useAppStore(
    (state) => state.notificationPermissionStatus,
  );
  const requestCalendarAccess = useAppStore((state) => state.requestCalendarAccess);
  const requestNotificationAccess = useAppStore((state) => state.requestNotificationAccess);
  const refreshIntegration = useAppStore((state) => state.refreshIntegration);

  if (!today) {
    return (
      <Screen>
        <View className="gap-4">
          <TodayHeader
            liveContext={false}
            dateLabel={bootStatus === "error" ? "Unable to load plan" : formatLongDate("2026-04-11")}
          />
          <AppText tone="secondary">
            {bootStatus === "loading"
              ? "Loading the local planning foundation..."
              : "The local planning snapshot is not ready yet."}
          </AppText>
        </View>
      </Screen>
    );
  }

  return (
    <Screen>
      <View className="gap-6">
        <TodayHeader dateLabel={formatLongDate(today.date)} liveContext={today.integration.usingLiveCalendar} />
        <IntegrationStatusCard
          calendarConnectionState={calendarConnectionState}
          notificationPermissionStatus={notificationPermissionStatus}
          onRequestCalendarAccess={requestCalendarAccess}
          onRequestNotificationAccess={requestNotificationAccess}
          onRefreshIntegration={() => refreshIntegration(today.date)}
          usingLiveCalendar={today.integration.usingLiveCalendar}
          calendarDetail={today.integration.calendarDetail}
        />
        <CapacityInsight capacity={today.capacity} focus={today.focus} />
        <TimelinePlan blocks={today.blocks} onTaskAction={applyTaskAction} />
        <UnscheduledTasksPanel tasks={today.unscheduled} />
        <ReplanSuggestionsPanel suggestions={today.replanSuggestions} />
        <GuidancePanel items={today.adaptiveGuidance} />
        <ScheduleContext items={today.scheduleContext} />
        <ProgressPanel
          completed={today.progress.completed}
          scheduled={today.progress.scheduled}
          recovery={today.progress.recovery}
        />

        <View className="pb-2 pt-1">
          <AppText tone="tertiary" variant="caption">
            Calendar writes, account sync, and broader automation remain deferred. This phase only reads live context and keeps reminders intentionally sparse.
          </AppText>
        </View>
      </View>
    </Screen>
  );
}
