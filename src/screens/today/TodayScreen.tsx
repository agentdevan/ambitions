import { View } from "react-native";

import { CapacityInsight } from "../../components/today/CapacityInsight";
import { GuidancePanel } from "../../components/today/GuidancePanel";
import { ProgressPanel } from "../../components/today/ProgressPanel";
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

  if (!today) {
    return (
      <Screen>
        <View className="gap-4">
          <TodayHeader
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
        <TodayHeader dateLabel={formatLongDate(today.date)} />
        <CapacityInsight capacity={today.capacity} focus={today.focus} />
        <TimelinePlan blocks={today.blocks} />
        <UnscheduledTasksPanel tasks={today.unscheduled} />
        <GuidancePanel items={today.adaptiveGuidance} />
        <ScheduleContext items={today.scheduleContext} />
        <ProgressPanel
          completed={today.progress.completed}
          scheduled={today.progress.scheduled}
          rolled={today.progress.rolled}
        />

        <View className="pb-2 pt-1">
          <AppText tone="tertiary" variant="caption">
            The planning brain is now deterministic and protective-first. Live calendar ingestion, adaptive learning, and deeper replanning remain intentionally deferred.
          </AppText>
        </View>
      </View>
    </Screen>
  );
}
