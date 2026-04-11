import { View } from "react-native";
import { useNavigation } from "@react-navigation/native";

import { Button } from "../../components/ui/Button";
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
  const navigation = useNavigation();
  const today = useAppStore((state) => state.today);
  const bootStatus = useAppStore((state) => state.bootStatus);
  const goals = useAppStore((state) => state.goals);
  const planDate = useAppStore((state) => state.planDate);
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
            dateLabel={
              bootStatus === "error" ? "Unable to load plan" : formatLongDate(planDate)
            }
          />
          <View className="gap-3 rounded-[30px] border border-[#DED7CB] bg-[#F8F6F1] px-5 py-5">
            <AppText variant="section">
              {bootStatus === "loading" ? "Loading the planning layer" : "No plan yet"}
            </AppText>
            <AppText tone="secondary">
              {bootStatus === "loading"
                ? "Loading the local planning foundation..."
                : goals.length === 0
                  ? "Create a goal first. Ambitions will generate a compact first day from it."
                  : "There is not a saved day plan yet. The current goals exist, but today has not been generated."}
            </AppText>
            {bootStatus !== "loading" ? (
              <View className="flex-row gap-3">
                <Button
                  tone="secondary"
                  style={{ flex: 1 }}
                  onPress={() => navigation.navigate("Goals" as never)}
                >
                  Open goals
                </Button>
                <Button
                  tone="secondary"
                  style={{ flex: 1 }}
                  onPress={() => navigation.navigate("Plan" as never)}
                >
                  Open plan
                </Button>
              </View>
            ) : null}
          </View>
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
