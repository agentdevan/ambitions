import { NativeStackScreenProps } from "@react-navigation/native-stack";
import { View } from "react-native";

import { DrillInRow } from "../../components/navigation/DrillInRow";
import { PageHeader } from "../../components/navigation/PageHeader";
import { Pill } from "../../components/ui/Pill";
import { Screen } from "../../components/ui/Screen";
import { Surface } from "../../components/ui/Surface";
import { AppText } from "../../components/ui/Text";
import { getGoalReviewDraft } from "../../services/goals/metadata";
import { useAppStore } from "../../state/useAppStore";
import { InsightsStackParamList } from "../../navigation/types";

type Props = NativeStackScreenProps<InsightsStackParamList, "InsightsHome">;

function SummaryMetric({ label, value, detail }: { label: string; value: string; detail: string }) {
  return (
    <View className="flex-1 gap-1 rounded-[18px] px-4 py-4">
      <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
        {label}
      </AppText>
      <AppText variant="section">{value}</AppText>
      <AppText tone="secondary" variant="caption">
        {detail}
      </AppText>
    </View>
  );
}

export function InsightsScreen({ navigation }: Props) {
  const today = useAppStore((state) => state.today);
  const goals = useAppStore((state) => state.goals);
  const replanSuggestions = useAppStore((state) => state.replanSuggestions);

  const pendingReviews = goals.filter((goal) => getGoalReviewDraft(goal) !== null).length;
  const activeGoals = goals.filter((goal) => goal.status === "active").length;

  return (
    <Screen>
      <View className="gap-6">
        <PageHeader
          eyebrow="Insights"
          title="See what is shaping the plan."
          description="Reflection, continuity, and planning signals live here. Controls moved out."
        />

        <Surface tone="accent" className="gap-4">
          <View className="gap-2">
            <View className="flex-row flex-wrap items-center gap-2">
              <Pill label={`${activeGoals} active goals`} tone="quiet" />
              {pendingReviews > 0 ? (
                <Pill label={`${pendingReviews} review waiting`} tone="accent" />
              ) : null}
            </View>
            <AppText variant="title">A calm read on the current planning state.</AppText>
            <AppText tone="secondary">
              Open the deeper views when you want more than a snapshot.
            </AppText>
          </View>
          <View className="flex-row gap-2">
            <SummaryMetric
              label="Continuity"
              value={`${today?.progress.completed ?? 0} done`}
              detail="Completed sessions today"
            />
            <SummaryMetric
              label="Signals"
              value={`${replanSuggestions.length}`}
              detail="Current replan signals"
            />
            <SummaryMetric
              label="Open room"
              value={`${today?.capacity.unusedCapacityMinutes ?? 0} min`}
              detail="Unused capacity"
            />
          </View>
        </Surface>

        <View className="gap-3">
          <DrillInRow
            title="Continuity"
            subtitle="Review active goals, completed work, and pending review pressure."
            detail={`${pendingReviews} waiting`}
            onPress={() => navigation.navigate("InsightContinuity")}
          />
          <DrillInRow
            title="Planning signals"
            subtitle={
              today?.adaptiveGuidance[0] ?? "See what is nudging the plan toward rework or recovery."
            }
            detail={`${replanSuggestions.length} signals`}
            onPress={() => navigation.navigate("InsightSignals")}
          />
          <DrillInRow
            title="Capacity and balance"
            subtitle={`Pressure is ${today?.capacity.planPressure ?? "low"} with ${today?.capacity.unusedCapacityMinutes ?? 0} minutes still open.`}
            onPress={() => navigation.navigate("InsightCapacity")}
          />
        </View>
      </View>
    </Screen>
  );
}
