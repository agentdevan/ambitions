import { NativeStackScreenProps } from "@react-navigation/native-stack";
import { Ionicons } from "@expo/vector-icons";
import { View } from "react-native";

import { MomentumBars } from "../../components/history/ActivityTimeline";
import { DrillInRow } from "../../components/navigation/DrillInRow";
import { PageHeader } from "../../components/navigation/PageHeader";
import { Pill } from "../../components/ui/Pill";
import { Screen } from "../../components/ui/Screen";
import { Surface } from "../../components/ui/Surface";
import { AppText } from "../../components/ui/Text";
import { ActivityEventKind } from "../../domain/models";
import { InsightsStackParamList } from "../../navigation/types";
import { getGoalReviewDraft } from "../../services/goals/metadata";
import { buildActivityFeed, summarizeInsights } from "../../services/history/selectors";
import { useAppStore } from "../../state/useAppStore";

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
  const goals = useAppStore((state) => state.goals);
  const milestones = useAppStore((state) => state.milestones);
  const tasks = useAppStore((state) => state.allTasks);
  const activityEvents = useAppStore((state) => state.activityEvents);
  const today = useAppStore((state) => state.today);

  const pendingReviews = goals.filter((goal) => getGoalReviewDraft(goal) !== null).length;
  const feed = buildActivityFeed(activityEvents, tasks, milestones);
  const summary = summarizeInsights({
    goals,
    tasks,
    milestones,
    events: feed,
  });
  const planChangeEvents = feed.filter((event) =>
    [
      ActivityEventKind.PlanReviewAccepted,
      ActivityEventKind.PlanReviewGenerated,
      ActivityEventKind.PlanReviewReverted,
      ActivityEventKind.GoalUpdated,
      ActivityEventKind.TaskRescheduled,
    ].includes(event.kind),
  );

  return (
    <Screen>
      <View className="gap-6">
        <PageHeader
          eyebrow="Insights"
          title="Insights"
          description="Recent movement."
        />

        <Surface tone="accent" className="gap-5">
          <View className="gap-1.5">
            <View className="flex-row flex-wrap items-center gap-2">
              <Pill label={`${summary.movingGoalCount} goals moving`} tone="quiet" />
              {pendingReviews > 0 ? (
                <Pill label={`${pendingReviews} review waiting`} tone="accent" />
              ) : null}
            </View>
            <AppText variant="title">Recent momentum</AppText>
            <AppText tone="secondary">{summary.momentumCopy}</AppText>
          </View>

          <MomentumBars points={summary.momentum} />

          <View className="flex-row gap-2">
            <SummaryMetric
              label="Completed"
              value={String(summary.completedThisWeek)}
              detail="Finished this week"
            />
            <SummaryMetric
              label="Reshaped"
              value={String(summary.reshapedThisWeek)}
              detail="Moved, deferred, or revised"
            />
            <SummaryMetric
              label="Plan drift"
              value={String(summary.planChangeCount)}
              detail="Recent structural changes"
            />
          </View>
        </Surface>

        <View className="gap-3">
          <DrillInRow
            title="Continuity"
            subtitle="Momentum and consistency"
            detail={`${summary.movingGoalCount} moving`}
            leading={<Ionicons color="#6F6558" name="pulse-outline" size={18} />}
            onPress={() => navigation.navigate("InsightContinuity")}
          />
          <DrillInRow
            title="Activity"
            subtitle="Completed, moved, reviewed"
            detail={`${feed.length} events`}
            leading={<Ionicons color="#6F6558" name="time-outline" size={18} />}
            onPress={() => navigation.navigate("InsightActivity")}
          />
          <DrillInRow
            title="Plan changes"
            subtitle="What shifted"
            detail={`${planChangeEvents.length} changes`}
            leading={<Ionicons color="#6F6558" name="swap-horizontal-outline" size={18} />}
            onPress={() => navigation.navigate("InsightPlanChanges")}
          />
          <DrillInRow
            title="Capacity"
            subtitle={`${today?.capacity.unusedCapacityMinutes ?? 0} min open`}
            leading={<Ionicons color="#6F6558" name="speedometer-outline" size={18} />}
            onPress={() => navigation.navigate("InsightCapacity")}
          />
        </View>
      </View>
    </Screen>
  );
}
