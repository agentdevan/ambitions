import { View } from "react-native";

import { CapacityInsight } from "../../components/today/CapacityInsight";
import { GuidancePanel } from "../../components/today/GuidancePanel";
import { ProgressPanel } from "../../components/today/ProgressPanel";
import { ScheduleContext } from "../../components/today/ScheduleContext";
import { TimelinePlan } from "../../components/today/TimelinePlan";
import { TodayHeader } from "../../components/today/TodayHeader";
import { Screen } from "../../components/ui/Screen";
import { AppText } from "../../components/ui/Text";
import { useAppStore } from "../../state/useAppStore";
import { formatLongDate } from "../../utils/date";

export function TodayScreen() {
  const today = useAppStore((state) => state.today);

  return (
    <Screen>
      <View className="gap-5">
        <TodayHeader dateLabel={formatLongDate(today.plan.date)} />
        <CapacityInsight capacity={today.capacity} focus={today.plan.focus} />
        <TimelinePlan blocks={today.plan.blocks} />
        <GuidancePanel items={today.adaptiveGuidance} />
        <ScheduleContext items={today.scheduleContext} />
        <ProgressPanel
          completed={today.progress.completed}
          scheduled={today.progress.scheduled}
          rolled={today.progress.rolled}
        />

        <View className="pb-2 pt-1">
          <AppText tone="tertiary" variant="caption">
            Mock data is intentional in this phase. The surface quality is being validated before the
            execution engines and integrations start writing real state.
          </AppText>
        </View>
      </View>
    </Screen>
  );
}
