import { NativeStackScreenProps } from "@react-navigation/native-stack";
import { Ionicons } from "@expo/vector-icons";
import { View } from "react-native";

import { MomentumBars } from "../../components/history/ActivityTimeline";
import { DrillInRow } from "../../components/navigation/DrillInRow";
import { PageHeader } from "../../components/navigation/PageHeader";
import { Button } from "../../components/ui/Button";
import { Pill } from "../../components/ui/Pill";
import { ProgressBar } from "../../components/ui/ProgressBar";
import { Screen } from "../../components/ui/Screen";
import { Surface } from "../../components/ui/Surface";
import { AppText } from "../../components/ui/Text";
import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { ActivityEventKind } from "../../domain/models";
import { InsightsStackParamList } from "../../navigation/types";
import { getGoalReviewDraft } from "../../services/goals/metadata";
import { buildActivityFeed, summarizeInsights } from "../../services/history/selectors";
import { useAppStore } from "../../state/useAppStore";

type Props = NativeStackScreenProps<InsightsStackParamList, "InsightsHome">;

function StatCard({ label, value, detail }: { label: string; value: string; detail: string }) {
  return (
    <View className="flex-1 gap-1 rounded-[20px] px-4 py-4">
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
  const adaptationProfile = useAppStore((state) => state.adaptationProfile);
  const productPreferences = useAppStore((state) => state.productPreferences);
  const theme = useResolvedTheme();

  const pendingReviews = goals.filter((goal) => getGoalReviewDraft(goal) !== null).length;
  const feed = buildActivityFeed(activityEvents, tasks, milestones);
  const summary = summarizeInsights({
    goals,
    tasks,
    milestones,
    events: feed,
    profile: adaptationProfile,
    adaptiveEnabled: productPreferences?.adaptivePlanningEnabled !== false,
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
  const completionShare =
    summary.completedThisWeek + summary.reshapedThisWeek > 0
      ? summary.completedThisWeek / (summary.completedThisWeek + summary.reshapedThisWeek)
      : 0;

  return (
    <Screen>
      <View className="gap-5">
        <PageHeader
          eyebrow="Insights"
          title="Insights"
          description="Recent movement."
          action={
            <Button size="compact" tone="tertiary" onPress={() => navigation.navigate("InsightActivity")}>
              Open activity
            </Button>
          }
        />

        <Surface tone="hero" className="gap-5">
          <View className="flex-row flex-wrap gap-2">
            <Pill label={`${summary.movingGoalCount} moving`} tone="accent" />
            {pendingReviews > 0 ? <Pill label={`${pendingReviews} review`} tone="quiet" /> : null}
          </View>

          <View className="gap-2">
            <AppText variant="title">Consistent focus</AppText>
            <AppText tone="secondary" variant="caption">
              {summary.personalizedHighlights[0] ?? summary.momentumCopy}
            </AppText>
          </View>

          <View className="flex-row gap-3">
            <StatCard
              label="This month"
              value={`${Math.round(completionShare * 100)}%`}
              detail="Completion share"
            />
            <StatCard
              label="Open / close"
              value={`${Math.round(summary.openConsistency * 100)} / ${Math.round(summary.closeConsistency * 100)}%`}
              detail="Weekly ritual consistency"
            />
          </View>

          <View className="gap-2">
            <View className="flex-row items-center justify-between">
              <AppText tone="secondary" variant="caption">
                Weekly balance
              </AppText>
              <AppText tone="secondary" variant="caption">
                {summary.completedThisWeek} done
              </AppText>
            </View>
            <ProgressBar progress={completionShare} />
          </View>
        </Surface>

        <Surface className="gap-4">
          <View className="gap-1">
            <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
              Weekly review
            </AppText>
            <AppText variant="title">Momentum</AppText>
          </View>
          <MomentumBars points={summary.momentum} />
          <View className="flex-row flex-wrap gap-2">
            <Pill label={`${summary.openedThisWeek} opened`} tone="quiet" />
            <Pill label={`${summary.closedThisWeek} closed`} tone="quiet" />
            <Pill label={`${summary.recoveryUsedThisWeek} recoveries`} tone="quiet" />
          </View>
        </Surface>

        <View className="gap-3">
          <DrillInRow
            title="Continuity"
            subtitle="Momentum and consistency"
            detail={`${summary.openedThisWeek} opens · ${summary.closedThisWeek} closes`}
            actionLabel="Open"
            leading={<Ionicons color={theme.colors.text.secondary} name="pulse-outline" size={18} />}
            onPress={() => navigation.navigate("InsightContinuity")}
          />
          <DrillInRow
            title="Activity"
            subtitle="Completed and reshaped work"
            detail={`${feed.length} events`}
            actionLabel="Open"
            leading={<Ionicons color={theme.colors.text.secondary} name="time-outline" size={18} />}
            onPress={() => navigation.navigate("InsightActivity")}
          />
          <DrillInRow
            title="Plan changes"
            subtitle="What shifted"
            detail={`${planChangeEvents.length} changes`}
            actionLabel="Open"
            leading={
              <Ionicons color={theme.colors.text.secondary} name="swap-horizontal-outline" size={18} />
            }
            onPress={() => navigation.navigate("InsightPlanChanges")}
          />
          <DrillInRow
            title="Ritual effects"
            subtitle={summary.planStabilityCopy}
            detail={summary.closingImpactCopy}
            actionLabel="Open"
            leading={<Ionicons color={theme.colors.text.secondary} name="repeat-outline" size={18} />}
            onPress={() => navigation.navigate("InsightContinuity")}
          />
          <DrillInRow
            title="Capacity"
            subtitle={`${today?.capacity.unusedCapacityMinutes ?? 0} min open`}
            detail={today?.capacity.overloadWarning ? "Tight day" : "Balanced"}
            actionLabel="Open"
            leading={
              <Ionicons color={theme.colors.text.secondary} name="speedometer-outline" size={18} />
            }
            onPress={() => navigation.navigate("InsightCapacity")}
          />
        </View>
      </View>
    </Screen>
  );
}
