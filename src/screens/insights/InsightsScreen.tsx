import { NativeStackScreenProps } from "@react-navigation/native-stack";
import { Ionicons } from "@expo/vector-icons";
import { useEffect, useMemo, useState } from "react";
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
import { TextField } from "../../components/ui/TextField";
import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import {
  ActivityEventKind,
  MonthlyCarryoverStance,
  MonthlyEmphasis,
  MonthlyPosture,
  MonthlyPressureLevel,
  ReminderType,
  WeeklyCarryoverPosture,
  WeeklyEmphasis,
  WeeklyIntensity,
} from "../../domain/models";
import { InsightsStackParamList } from "../../navigation/types";
import { getGoalReviewDraft } from "../../services/goals/metadata";
import { buildActivityFeed, summarizeInsights } from "../../services/history/selectors";
import { buildMonthlyReviewDigest, describeMonthlyStrategy } from "../../services/history/monthly";
import {
  buildWeeklyReviewDigest,
  describeWeeklyShape,
  summarizeWeeklyContinuity,
} from "../../services/history/weekly";
import { useAppStore } from "../../state/useAppStore";
import { formatMonthLabel, formatShortDate, formatTimeLabel } from "../../utils/date";
import { OptionChip } from "../../components/ui/OptionChip";
import { summarizeMonthlyReviewControl } from "../../services/profile/controlSummaries";

type Props = NativeStackScreenProps<InsightsStackParamList, "InsightsHome">;
type CarryDecision = "carry" | "review" | "release";

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

function CarryoverTaskCard({
  title,
  value,
  decision,
  onChange,
}: {
  title: string;
  value: string;
  decision: CarryDecision;
  onChange: (value: CarryDecision) => void;
}) {
  return (
    <Surface tone="sunken" className="gap-3 mb-0">
      <View className="gap-1">
        <AppText variant="section">{title}</AppText>
        <AppText tone="secondary" variant="caption">
          {value}
        </AppText>
      </View>
      <View className="flex-row flex-wrap gap-2">
        <OptionChip compact selected={decision === "carry"} onPress={() => onChange("carry")}>
          Carry
        </OptionChip>
        <OptionChip compact selected={decision === "review"} onPress={() => onChange("review")}>
          Review
        </OptionChip>
        <OptionChip compact selected={decision === "release"} onPress={() => onChange("release")}>
          Release
        </OptionChip>
      </View>
    </Surface>
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
  const userPreferences = useAppStore((state) => state.userPreferences);
  const notificationPreferences = useAppStore((state) => state.notificationPreferences);
  const dailyRitualHistory = useAppStore((state) => state.dailyRitualHistory);
  const currentWeekReview = useAppStore((state) => state.currentWeekReview);
  const nextWeekReview = useAppStore((state) => state.nextWeekReview);
  const weeklyReviewHistory = useAppStore((state) => state.weeklyReviewHistory);
  const currentMonthReview = useAppStore((state) => state.currentMonthReview);
  const nextMonthReview = useAppStore((state) => state.nextMonthReview);
  const reviewWeek = useAppStore((state) => state.reviewWeek);
  const reviewWeeklyCarryover = useAppStore((state) => state.reviewWeeklyCarryover);
  const shapeNextWeek = useAppStore((state) => state.shapeNextWeek);
  const reviewMonth = useAppStore((state) => state.reviewMonth);
  const shapeNextMonth = useAppStore((state) => state.shapeNextMonth);
  const theme = useResolvedTheme();
  const [busyAction, setBusyAction] = useState<string | null>(null);
  const [runtimeMessage, setRuntimeMessage] = useState<string | null>(null);
  const [reviewNote, setReviewNote] = useState(currentWeekReview?.note ?? "");
  const [shapeNote, setShapeNote] = useState(nextWeekReview?.note ?? "");
  const [monthReviewNote, setMonthReviewNote] = useState(currentMonthReview?.reviewNote ?? "");
  const [monthStrategyNote, setMonthStrategyNote] = useState(nextMonthReview?.strategyNote ?? "");
  const [intensity, setIntensity] = useState<WeeklyIntensity>(
    nextWeekReview?.targetWeekIntensity ?? WeeklyIntensity.Balanced,
  );
  const [emphasis, setEmphasis] = useState<WeeklyEmphasis>(
    nextWeekReview?.weeklyEmphasis ?? WeeklyEmphasis.SteadyProgress,
  );
  const [carryoverPosture, setCarryoverPosture] = useState<WeeklyCarryoverPosture>(
    nextWeekReview?.carryoverPosture ??
      (productPreferences?.defaultWeeklyCarryoverBehavior === "essentials_only"
        ? WeeklyCarryoverPosture.EssentialsOnly
        : productPreferences?.defaultWeeklyCarryoverBehavior === "aggressive"
          ? WeeklyCarryoverPosture.Aggressive
          : WeeklyCarryoverPosture.ReviewFirst),
  );
  const [monthPosture, setMonthPosture] = useState<MonthlyPosture>(
    nextMonthReview?.monthPosture ??
      (productPreferences?.defaultMonthlyPosture === "build_momentum"
        ? MonthlyPosture.BuildMomentum
        : productPreferences?.defaultMonthlyPosture === "push_output"
          ? MonthlyPosture.PushOutput
          : MonthlyPosture.Stabilize),
  );
  const [monthEmphasis, setMonthEmphasis] = useState<MonthlyEmphasis>(
    nextMonthReview?.monthlyEmphasis ??
      (productPreferences?.defaultMonthlyEmphasis === "deepen_one_priority_area"
        ? MonthlyEmphasis.DeepenPriorityArea
        : productPreferences?.defaultMonthlyEmphasis === "rebalance_neglected_areas"
          ? MonthlyEmphasis.RebalanceNeglectedAreas
          : MonthlyEmphasis.ProtectEssentials),
  );
  const [monthPressure, setMonthPressure] = useState<MonthlyPressureLevel>(
    nextMonthReview?.pressureLevel ??
      (productPreferences?.defaultMonthlyPressure === "lighter"
        ? MonthlyPressureLevel.Lighter
        : productPreferences?.defaultMonthlyPressure === "fuller"
          ? MonthlyPressureLevel.Fuller
          : MonthlyPressureLevel.Balanced),
  );
  const [monthCarryoverStance, setMonthCarryoverStance] = useState<MonthlyCarryoverStance>(
    nextMonthReview?.carryoverStance ??
      (productPreferences?.defaultMonthlyCarryoverStance === "prune_aggressively"
        ? MonthlyCarryoverStance.PruneAggressively
        : productPreferences?.defaultMonthlyCarryoverStance === "tolerate_more_carryover"
          ? MonthlyCarryoverStance.TolerateMoreCarryover
          : MonthlyCarryoverStance.ReviewBeforeCarrying),
  );

  const pendingReviews = goals.filter((goal) => getGoalReviewDraft(goal) !== null).length;
  const feed = useMemo(
    () => buildActivityFeed(activityEvents, tasks, milestones),
    [activityEvents, milestones, tasks],
  );
  const summary = useMemo(
    () =>
      summarizeInsights({
        goals,
        tasks,
        milestones,
        events: feed,
        profile: adaptationProfile,
        adaptiveEnabled: productPreferences?.adaptivePlanningEnabled !== false,
      }),
    [adaptationProfile, feed, goals, milestones, productPreferences?.adaptivePlanningEnabled, tasks],
  );
  const weeklyDigest = useMemo(
    () =>
      buildWeeklyReviewDigest({
        date: today?.date ?? new Date().toISOString().slice(0, 10),
        weekStartsOn: userPreferences?.weekStartsOn ?? 1,
        tasks,
        rituals: dailyRitualHistory,
        events: feed,
      }),
    [dailyRitualHistory, feed, tasks, today?.date, userPreferences?.weekStartsOn],
  );
  const monthlyDigest = useMemo(
    () =>
      buildMonthlyReviewDigest({
        date: today?.date ?? new Date().toISOString().slice(0, 10),
        goals,
        tasks,
        rituals: dailyRitualHistory,
        weeklyReviews: weeklyReviewHistory,
        events: feed,
      }),
    [dailyRitualHistory, feed, goals, tasks, today?.date, weeklyReviewHistory],
  );
  const weeklyContinuity = useMemo(
    () => summarizeWeeklyContinuity(weeklyReviewHistory),
    [weeklyReviewHistory],
  );
  const planChangeEvents = feed.filter((event) =>
    [
      ActivityEventKind.PlanReviewAccepted,
      ActivityEventKind.PlanReviewGenerated,
      ActivityEventKind.PlanReviewReverted,
      ActivityEventKind.GoalUpdated,
      ActivityEventKind.TaskRescheduled,
    ].includes(event.kind),
  );
  const weeklySummary = weeklyDigest.summary;
  const weeklyCompletionShare =
    weeklySummary.completedCount + weeklySummary.reshapedCount > 0
      ? weeklySummary.completedCount / (weeklySummary.completedCount + weeklySummary.reshapedCount)
      : 0;
  const weeklyReviewPreference = notificationPreferences.find(
    (preference) => preference.reminderType === ReminderType.WeeklyReview,
  );
  const carryoverDefaults = useMemo(() => {
    const base = new Map<string, CarryDecision>();
    currentWeekReview?.carryoverTaskIds.forEach((id) => base.set(id, "carry"));
    currentWeekReview?.reviewTaskIds.forEach((id) => base.set(id, "review"));
    currentWeekReview?.releasedTaskIds.forEach((id) => base.set(id, "release"));
    weeklyDigest.carryCandidateTasks.forEach((task) => {
      if (!base.has(task.id)) {
        base.set(
          task.id,
          task.metadata.weeklyCarryoverDisposition === "released"
            ? "release"
            : task.metadata.weeklyCarryoverDisposition === "review"
              ? "review"
              : "carry",
        );
      }
    });
    return base;
  }, [
    currentWeekReview?.carryoverTaskIds,
    currentWeekReview?.releasedTaskIds,
    currentWeekReview?.reviewTaskIds,
    weeklyDigest.carryCandidateTasks,
  ]);
  const [carryoverSelections, setCarryoverSelections] = useState<Record<string, CarryDecision>>({});

  useEffect(() => {
    setReviewNote(currentWeekReview?.note ?? "");
  }, [currentWeekReview?.note]);

  useEffect(() => {
    setMonthReviewNote(currentMonthReview?.reviewNote ?? "");
  }, [currentMonthReview?.reviewNote]);

  useEffect(() => {
    setShapeNote(nextWeekReview?.note ?? "");
    setIntensity(nextWeekReview?.targetWeekIntensity ?? WeeklyIntensity.Balanced);
    setEmphasis(nextWeekReview?.weeklyEmphasis ?? WeeklyEmphasis.SteadyProgress);
    setCarryoverPosture(
      nextWeekReview?.carryoverPosture ??
        (productPreferences?.defaultWeeklyCarryoverBehavior === "essentials_only"
          ? WeeklyCarryoverPosture.EssentialsOnly
          : productPreferences?.defaultWeeklyCarryoverBehavior === "aggressive"
            ? WeeklyCarryoverPosture.Aggressive
            : WeeklyCarryoverPosture.ReviewFirst),
    );
  }, [
    nextWeekReview?.carryoverPosture,
    nextWeekReview?.note,
    nextWeekReview?.targetWeekIntensity,
    nextWeekReview?.weeklyEmphasis,
    productPreferences?.defaultWeeklyCarryoverBehavior,
  ]);

  useEffect(() => {
    setMonthStrategyNote(nextMonthReview?.strategyNote ?? "");
    setMonthPosture(
      nextMonthReview?.monthPosture ??
        (productPreferences?.defaultMonthlyPosture === "build_momentum"
          ? MonthlyPosture.BuildMomentum
          : productPreferences?.defaultMonthlyPosture === "push_output"
            ? MonthlyPosture.PushOutput
            : MonthlyPosture.Stabilize),
    );
    setMonthEmphasis(
      nextMonthReview?.monthlyEmphasis ??
        (productPreferences?.defaultMonthlyEmphasis === "deepen_one_priority_area"
          ? MonthlyEmphasis.DeepenPriorityArea
          : productPreferences?.defaultMonthlyEmphasis === "rebalance_neglected_areas"
            ? MonthlyEmphasis.RebalanceNeglectedAreas
            : MonthlyEmphasis.ProtectEssentials),
    );
    setMonthPressure(
      nextMonthReview?.pressureLevel ??
        (productPreferences?.defaultMonthlyPressure === "lighter"
          ? MonthlyPressureLevel.Lighter
          : productPreferences?.defaultMonthlyPressure === "fuller"
            ? MonthlyPressureLevel.Fuller
            : MonthlyPressureLevel.Balanced),
    );
    setMonthCarryoverStance(
      nextMonthReview?.carryoverStance ??
        (productPreferences?.defaultMonthlyCarryoverStance === "prune_aggressively"
          ? MonthlyCarryoverStance.PruneAggressively
          : productPreferences?.defaultMonthlyCarryoverStance === "tolerate_more_carryover"
            ? MonthlyCarryoverStance.TolerateMoreCarryover
            : MonthlyCarryoverStance.ReviewBeforeCarrying),
    );
  }, [
    nextMonthReview?.carryoverStance,
    nextMonthReview?.monthPosture,
    nextMonthReview?.monthlyEmphasis,
    nextMonthReview?.pressureLevel,
    nextMonthReview?.strategyNote,
    productPreferences?.defaultMonthlyCarryoverStance,
    productPreferences?.defaultMonthlyEmphasis,
    productPreferences?.defaultMonthlyPosture,
    productPreferences?.defaultMonthlyPressure,
  ]);

  useEffect(() => {
    const next: Record<string, CarryDecision> = {};
    carryoverDefaults.forEach((value, key) => {
      next[key] = value;
    });
    setCarryoverSelections(next);
  }, [carryoverDefaults]);

  async function runAction(key: string, action: () => Promise<void>, fallbackError: string) {
    setBusyAction(key);
    setRuntimeMessage(null);

    try {
      await action();
    } catch (error) {
      setRuntimeMessage(error instanceof Error ? error.message : fallbackError);
    } finally {
      setBusyAction(null);
    }
  }

  const carryoverTasks = weeklyDigest.carryCandidateTasks.slice(0, 6);
  const needsCarryoverReview = carryoverTasks.length > 0;
  const nextWeekShapeLabel = describeWeeklyShape({
    intensity: nextWeekReview?.targetWeekIntensity ?? intensity,
    emphasis: nextWeekReview?.weeklyEmphasis ?? emphasis,
    carryoverPosture: nextWeekReview?.carryoverPosture ?? carryoverPosture,
  });
  const weeklyReviewDayLabel =
    ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"][
      productPreferences?.weeklyReviewDay ?? 0
    ];
  const monthReviewPreference = notificationPreferences.find(
    (preference) => preference.reminderType === ReminderType.MonthlyReview,
  );
  const monthlyReviewSummary = productPreferences
    ? summarizeMonthlyReviewControl({
        day: productPreferences.monthlyReviewDay,
        time: productPreferences.monthlyReviewTime,
        autoPrompt: productPreferences.autoPromptNextMonthShaping,
      })
    : null;
  const monthRecommitDefaults = useMemo(
    () => ({
      recommit: new Set(currentMonthReview?.recommitGoalIds ?? []),
      reduce: new Set(currentMonthReview?.reduceGoalIds ?? []),
      pause: new Set(currentMonthReview?.pauseGoalIds ?? []),
    }),
    [currentMonthReview?.pauseGoalIds, currentMonthReview?.recommitGoalIds, currentMonthReview?.reduceGoalIds],
  );
  const [goalDecisions, setGoalDecisions] = useState<Record<string, "recommit" | "reduce" | "pause">>({});

  useEffect(() => {
    const next: Record<string, "recommit" | "reduce" | "pause"> = {};
    monthlyDigest.goalCoverage.forEach((coverage) => {
      next[coverage.goalId] = monthRecommitDefaults.pause.has(coverage.goalId)
        ? "pause"
        : monthRecommitDefaults.reduce.has(coverage.goalId)
          ? "reduce"
          : "recommit";
    });
    setGoalDecisions(next);
  }, [monthRecommitDefaults, monthlyDigest.goalCoverage]);

  const nextMonthShapeLabel = describeMonthlyStrategy({
    posture: nextMonthReview?.monthPosture ?? monthPosture,
    emphasis: nextMonthReview?.monthlyEmphasis ?? monthEmphasis,
    pressureLevel: nextMonthReview?.pressureLevel ?? monthPressure,
    carryoverStance: nextMonthReview?.carryoverStance ?? monthCarryoverStance,
  });

  return (
    <Screen>
      <View className="gap-5">
        <PageHeader
          eyebrow="Insights"
          title="Insights"
          description="Weekly read and next-week shape."
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
            {currentWeekReview?.reviewedAt ? <Pill label="Week reviewed" tone="quiet" /> : null}
            {nextWeekReview?.nextWeekShapedAt ? <Pill label="Next week shaped" tone="quiet" /> : null}
          </View>

          <View className="gap-2">
            <AppText variant="title">Weekly continuity</AppText>
            <AppText tone="secondary" variant="caption">
              {weeklyDigest.reads[0]}
            </AppText>
          </View>

          <View className="flex-row gap-3">
            <StatCard
              label="Reviewed"
              value={String(weeklyContinuity.reviewedWeeks)}
              detail="Intentional weeks"
            />
            <StatCard
              label="Shaped"
              value={String(weeklyContinuity.shapedWeeks)}
              detail="Weeks started deliberately"
            />
          </View>

          <View className="gap-2">
            <View className="flex-row items-center justify-between">
              <AppText tone="secondary" variant="caption">
                This week
              </AppText>
              <AppText tone="secondary" variant="caption">
                {weeklySummary.completedCount} completed · {weeklySummary.reshapedCount} reshaped
              </AppText>
            </View>
            <ProgressBar progress={weeklyCompletionShare} />
          </View>
        </Surface>

        <Surface className="gap-4">
          <View className="gap-1">
            <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
              Monthly review
            </AppText>
            <AppText variant="title">{formatMonthLabel(monthlyDigest.monthStartDate)}</AppText>
          </View>
          <AppText tone="secondary" variant="caption">
            {monthlyDigest.headline}
          </AppText>
          <View className="flex-row flex-wrap gap-2">
            <Pill label={`${monthlyDigest.summary.goalCoverageCount} goals represented`} tone="quiet" />
            <Pill label={`${monthlyDigest.summary.underrepresentedGoalCount} underrepresented`} tone="quiet" />
            <Pill label={`${monthlyDigest.summary.reviewedWeeks} weeks reviewed`} tone="quiet" />
            <Pill label={`${Math.round(monthlyDigest.summary.churnRate * 100)}% churn`} tone="quiet" />
          </View>
          <View className="gap-2">
            {monthlyDigest.reads.slice(0, 3).map((read) => (
              <AppText key={read} tone="secondary" variant="caption">
                {read}
              </AppText>
            ))}
          </View>
          <Button size="compact" tone="tertiary" onPress={() => navigation.navigate("InsightMonthlyReview")}>
            Open monthly review
          </Button>
        </Surface>

        <Surface className="gap-4">
          <View className="gap-1">
            <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
              Weekly review
            </AppText>
            <AppText variant="title">
              {formatShortDate(weeklyDigest.weekStartDate)} - {formatShortDate(weeklyDigest.weekEndDate)}
            </AppText>
          </View>
          <MomentumBars points={summary.momentum} />
          <View className="flex-row flex-wrap gap-2">
            <Pill label={`${weeklyDigest.summary.daysOpened} opened`} tone="quiet" />
            <Pill label={`${weeklyDigest.summary.daysClosed} closed`} tone="quiet" />
            <Pill label={`${weeklyDigest.summary.recoveryCount} recoveries`} tone="quiet" />
            <Pill label={`${Math.round(weeklyDigest.summary.churnRate * 100)}% churn`} tone="quiet" />
          </View>
          <View className="gap-2">
            {weeklyDigest.reads.map((read) => (
              <AppText key={read} tone="secondary" variant="caption">
                {read}
              </AppText>
            ))}
          </View>
          <TextField
            label="Weekly note"
            multiline
            onChangeText={setReviewNote}
            supportingText="Optional and short."
            value={reviewNote}
          />
          <Button
            busy={busyAction === "review-week"}
            onPress={() =>
              void runAction(
                "review-week",
                () => reviewWeek({ note: reviewNote }),
                "Weekly review could not be saved.",
              )
            }
          >
            {currentWeekReview?.reviewedAt ? "Update review" : "Review week"}
          </Button>
        </Surface>

        <Surface className="gap-4">
          <View className="gap-1">
            <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
              Goal truth
            </AppText>
            <AppText variant="title">What the month actually represented</AppText>
          </View>
          <AppText tone="secondary" variant="caption">
            Review which goals received real execution, which dragged, and what should change next month.
          </AppText>
          <View className="gap-3">
            {monthlyDigest.goalCoverage.slice(0, 4).map((coverage) => (
              <Surface key={coverage.goalId} tone="sunken" className="gap-3 mb-0">
                <View className="gap-1">
                  <AppText variant="section">{coverage.goalTitle}</AppText>
                  <AppText tone="secondary" variant="caption">
                    {coverage.represented
                      ? `${coverage.executionCount} execution touches, ${coverage.completionCount} completions.`
                      : "Stayed mostly aspirational this month."}
                  </AppText>
                </View>
                <View className="flex-row flex-wrap gap-2">
                  <OptionChip
                    compact
                    selected={(goalDecisions[coverage.goalId] ?? "recommit") === "recommit"}
                    onPress={() =>
                      setGoalDecisions((current) => ({ ...current, [coverage.goalId]: "recommit" }))
                    }
                  >
                    Recommit
                  </OptionChip>
                  <OptionChip
                    compact
                    selected={(goalDecisions[coverage.goalId] ?? "recommit") === "reduce"}
                    onPress={() =>
                      setGoalDecisions((current) => ({ ...current, [coverage.goalId]: "reduce" }))
                    }
                  >
                    Reduce
                  </OptionChip>
                  <OptionChip
                    compact
                    selected={(goalDecisions[coverage.goalId] ?? "recommit") === "pause"}
                    onPress={() =>
                      setGoalDecisions((current) => ({ ...current, [coverage.goalId]: "pause" }))
                    }
                  >
                    Pause
                  </OptionChip>
                </View>
              </Surface>
            ))}
          </View>
          <TextField
            label="Monthly note"
            multiline
            onChangeText={setMonthReviewNote}
            supportingText="Optional. Keep it short and factual."
            value={monthReviewNote}
          />
          <Button
            busy={busyAction === "review-month"}
            onPress={() =>
              void runAction(
                "review-month",
                () =>
                  reviewMonth({
                    reviewNote: monthReviewNote,
                    recommitGoalIds: Object.entries(goalDecisions)
                      .filter(([, decision]) => decision === "recommit")
                      .map(([goalId]) => goalId),
                    reduceGoalIds: Object.entries(goalDecisions)
                      .filter(([, decision]) => decision === "reduce")
                      .map(([goalId]) => goalId),
                    pauseGoalIds: Object.entries(goalDecisions)
                      .filter(([, decision]) => decision === "pause")
                      .map(([goalId]) => goalId),
                  }),
                "Monthly review could not be saved.",
              )
            }
          >
            {currentMonthReview?.reviewedAt ? "Update month" : "Review month"}
          </Button>
        </Surface>

        <Surface className="gap-4">
          <View className="gap-1">
            <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
              Next month
            </AppText>
            <AppText variant="title">Shape the next month</AppText>
          </View>
          <AppText tone="secondary" variant="caption">
            Set the month above the week. Weekly shaping still decides the actual week-by-week tradeoffs.
          </AppText>
          <View className="gap-2">
            <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
              Posture
            </AppText>
            <View className="flex-row flex-wrap gap-2">
              <OptionChip selected={monthPosture === MonthlyPosture.Stabilize} onPress={() => setMonthPosture(MonthlyPosture.Stabilize)}>
                Stabilize
              </OptionChip>
              <OptionChip selected={monthPosture === MonthlyPosture.BuildMomentum} onPress={() => setMonthPosture(MonthlyPosture.BuildMomentum)}>
                Build momentum
              </OptionChip>
              <OptionChip selected={monthPosture === MonthlyPosture.PushOutput} onPress={() => setMonthPosture(MonthlyPosture.PushOutput)}>
                Push output
              </OptionChip>
            </View>
          </View>
          <View className="gap-2">
            <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
              Emphasis
            </AppText>
            <View className="flex-row flex-wrap gap-2">
              <OptionChip selected={monthEmphasis === MonthlyEmphasis.ProtectEssentials} onPress={() => setMonthEmphasis(MonthlyEmphasis.ProtectEssentials)}>
                Protect essentials
              </OptionChip>
              <OptionChip selected={monthEmphasis === MonthlyEmphasis.DeepenPriorityArea} onPress={() => setMonthEmphasis(MonthlyEmphasis.DeepenPriorityArea)}>
                Deepen one area
              </OptionChip>
              <OptionChip selected={monthEmphasis === MonthlyEmphasis.RebalanceNeglectedAreas} onPress={() => setMonthEmphasis(MonthlyEmphasis.RebalanceNeglectedAreas)}>
                Rebalance neglected areas
              </OptionChip>
            </View>
          </View>
          <View className="gap-2">
            <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
              Pressure
            </AppText>
            <View className="flex-row flex-wrap gap-2">
              <OptionChip selected={monthPressure === MonthlyPressureLevel.Lighter} onPress={() => setMonthPressure(MonthlyPressureLevel.Lighter)}>
                Lighter
              </OptionChip>
              <OptionChip selected={monthPressure === MonthlyPressureLevel.Balanced} onPress={() => setMonthPressure(MonthlyPressureLevel.Balanced)}>
                Balanced
              </OptionChip>
              <OptionChip selected={monthPressure === MonthlyPressureLevel.Fuller} onPress={() => setMonthPressure(MonthlyPressureLevel.Fuller)}>
                Fuller
              </OptionChip>
            </View>
          </View>
          <View className="gap-2">
            <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
              Carryover stance
            </AppText>
            <View className="flex-row flex-wrap gap-2">
              <OptionChip selected={monthCarryoverStance === MonthlyCarryoverStance.PruneAggressively} onPress={() => setMonthCarryoverStance(MonthlyCarryoverStance.PruneAggressively)}>
                Prune aggressively
              </OptionChip>
              <OptionChip selected={monthCarryoverStance === MonthlyCarryoverStance.ReviewBeforeCarrying} onPress={() => setMonthCarryoverStance(MonthlyCarryoverStance.ReviewBeforeCarrying)}>
                Review before carrying
              </OptionChip>
              <OptionChip selected={monthCarryoverStance === MonthlyCarryoverStance.TolerateMoreCarryover} onPress={() => setMonthCarryoverStance(MonthlyCarryoverStance.TolerateMoreCarryover)}>
                Tolerate more carryover
              </OptionChip>
            </View>
          </View>
          <TextField
            label="Monthly thesis"
            multiline
            onChangeText={setMonthStrategyNote}
            supportingText="Optional. A short sentence is enough."
            value={monthStrategyNote}
          />
          <AppText tone="secondary" variant="caption">
            {nextMonthReview?.strategySetAt ? `Saved ${nextMonthShapeLabel}.` : "No next-month strategy saved yet."}
          </AppText>
          <Button
            busy={busyAction === "shape-month"}
            onPress={() =>
              void runAction(
                "shape-month",
                () =>
                  shapeNextMonth({
                    posture: monthPosture,
                    emphasis: monthEmphasis,
                    pressureLevel: monthPressure,
                    carryoverStance: monthCarryoverStance,
                    note: monthStrategyNote,
                  }),
                "Next-month strategy could not be saved.",
              )
            }
          >
            {nextMonthReview?.strategySetAt ? "Update next month" : "Shape next month"}
          </Button>
        </Surface>

        <Surface className="gap-4">
          <View className="gap-1">
            <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
              Carryover review
            </AppText>
            <AppText variant="title">What should survive next week?</AppText>
          </View>
          <AppText tone="secondary" variant="caption">
            Reuse the current task flow. Keep what still matters, send some work back to review, and stop quiet carryover when needed.
          </AppText>
          <View className="gap-3">
            {carryoverTasks.length > 0 ? (
              carryoverTasks.map((task) => (
                <CarryoverTaskCard
                  key={task.id}
                  title={task.title}
                  value={
                    task.targetDate
                      ? `Last targeted for ${formatShortDate(task.targetDate)}`
                      : "No longer holding a date"
                  }
                  decision={carryoverSelections[task.id] ?? "carry"}
                  onChange={(value) =>
                    setCarryoverSelections((current) => ({
                      ...current,
                      [task.id]: value,
                    }))
                  }
                />
              ))
            ) : (
              <AppText tone="secondary" variant="caption">
                Nothing is quietly rolling into next week right now.
              </AppText>
            )}
          </View>
          {needsCarryoverReview ? (
            <Button
              busy={busyAction === "carryover-review"}
              onPress={() =>
                void runAction(
                  "carryover-review",
                  () =>
                    reviewWeeklyCarryover({
                      carryTaskIds: carryoverTasks
                        .filter((task) => (carryoverSelections[task.id] ?? "carry") === "carry")
                        .map((task) => task.id),
                      reviewTaskIds: carryoverTasks
                        .filter((task) => (carryoverSelections[task.id] ?? "carry") === "review")
                        .map((task) => task.id),
                      releasedTaskIds: carryoverTasks
                        .filter((task) => (carryoverSelections[task.id] ?? "carry") === "release")
                        .map((task) => task.id),
                    }),
                  "Weekly carryover decisions could not be saved.",
                )
              }
            >
              Save carryover review
            </Button>
          ) : null}
        </Surface>

        <Surface className="gap-4">
          <View className="gap-1">
            <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
              Next week
            </AppText>
            <AppText variant="title">Shape the next week</AppText>
          </View>
          <AppText tone="secondary" variant="caption">
            Set the pressure and tradeoff posture. The planner will use this shape when it decides what to fill and what to hold back.
          </AppText>
          <View className="gap-2">
            <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
              Intensity
            </AppText>
            <View className="flex-row flex-wrap gap-2">
              <OptionChip selected={intensity === WeeklyIntensity.Lighter} onPress={() => setIntensity(WeeklyIntensity.Lighter)}>
                Lighter
              </OptionChip>
              <OptionChip selected={intensity === WeeklyIntensity.Balanced} onPress={() => setIntensity(WeeklyIntensity.Balanced)}>
                Balanced
              </OptionChip>
              <OptionChip selected={intensity === WeeklyIntensity.Fuller} onPress={() => setIntensity(WeeklyIntensity.Fuller)}>
                Fuller
              </OptionChip>
            </View>
          </View>
          <View className="gap-2">
            <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
              Emphasis
            </AppText>
            <View className="flex-row flex-wrap gap-2">
              <OptionChip
                selected={emphasis === WeeklyEmphasis.ProtectEssentials}
                onPress={() => setEmphasis(WeeklyEmphasis.ProtectEssentials)}
              >
                Protect essentials
              </OptionChip>
              <OptionChip
                selected={emphasis === WeeklyEmphasis.SteadyProgress}
                onPress={() => setEmphasis(WeeklyEmphasis.SteadyProgress)}
              >
                Steady progress
              </OptionChip>
              <OptionChip
                selected={emphasis === WeeklyEmphasis.PushMeaningfulArea}
                onPress={() => setEmphasis(WeeklyEmphasis.PushMeaningfulArea)}
              >
                Push one area
              </OptionChip>
            </View>
          </View>
          <View className="gap-2">
            <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
              Carryover
            </AppText>
            <View className="flex-row flex-wrap gap-2">
              <OptionChip
                selected={carryoverPosture === WeeklyCarryoverPosture.EssentialsOnly}
                onPress={() => setCarryoverPosture(WeeklyCarryoverPosture.EssentialsOnly)}
              >
                Carry only essentials
              </OptionChip>
              <OptionChip
                selected={carryoverPosture === WeeklyCarryoverPosture.ReviewFirst}
                onPress={() => setCarryoverPosture(WeeklyCarryoverPosture.ReviewFirst)}
              >
                Review first
              </OptionChip>
              <OptionChip
                selected={carryoverPosture === WeeklyCarryoverPosture.Aggressive}
                onPress={() => setCarryoverPosture(WeeklyCarryoverPosture.Aggressive)}
              >
                Carry more forward
              </OptionChip>
            </View>
          </View>
          <TextField
            label="Next-week note"
            multiline
            onChangeText={setShapeNote}
            supportingText="Optional. Keep it short."
            value={shapeNote}
          />
          <View className="gap-1">
            <AppText tone="secondary" variant="caption">
              {nextWeekReview?.nextWeekShapedAt
                ? `Saved ${nextWeekShapeLabel}.`
                : "No next-week shape saved yet."}
            </AppText>
          </View>
          <Button
            busy={busyAction === "shape-week"}
            onPress={() =>
              void runAction(
                "shape-week",
                () =>
                  shapeNextWeek({
                    intensity,
                    emphasis,
                    carryoverPosture,
                    note: shapeNote,
                  }),
                "Next-week shaping could not be saved.",
              )
            }
          >
            {nextWeekReview?.nextWeekShapedAt ? "Update next week" : "Shape next week"}
          </Button>
        </Surface>

        <View className="gap-3">
          <DrillInRow
            title="Monthly review"
            subtitle="Direction, coverage, and drag"
            detail={formatMonthLabel(monthlyDigest.monthStartDate)}
            actionLabel="Open"
            leading={<Ionicons color={theme.colors.text.secondary} name="calendar-outline" size={18} />}
            onPress={() => navigation.navigate("InsightMonthlyReview")}
          />
          <DrillInRow
            title="Continuity"
            subtitle="Weekly rhythm and stability"
            detail={`${weeklyContinuity.reviewedWeeks} reviewed`}
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

        <Surface className="gap-3">
          <AppText variant="section">Weekly controls</AppText>
          <AppText tone="secondary" variant="caption">
            Review day {weeklyReviewDayLabel} at{" "}
            {productPreferences ? formatTimeLabel(productPreferences.weeklyReviewTime, { compact: true }) : "4:30p"}.
            {weeklyReviewPreference?.enabled
              ? ` Reminder speaks up ${weeklyReviewPreference.leadTimeMinutes} min early.`
              : " Weekly reminder is muted."}
            {productPreferences?.autoPromptNextWeekShaping
              ? " Next-week shaping stays prompted automatically."
              : " Next-week shaping is manual."}
          </AppText>
        </Surface>

        <Surface className="gap-3">
          <AppText variant="section">Monthly controls</AppText>
          <AppText tone="secondary" variant="caption">
            {monthlyReviewSummary?.scheduleLabel ?? `Monthly review at ${productPreferences ? formatTimeLabel(productPreferences.monthlyReviewTime, { compact: true }) : "9:30a"}`}.
            {monthReviewPreference?.enabled
              ? ` Reminder speaks up ${monthReviewPreference.leadTimeMinutes} min early.`
              : " Monthly reminder is muted."}
            {monthlyReviewSummary ? ` ${monthlyReviewSummary.promptLabel}.` : ""}
          </AppText>
        </Surface>

        {runtimeMessage ? (
          <Surface tone="sunken" className="gap-2">
            <AppText variant="caption">Couldn&apos;t save that change</AppText>
            <AppText tone="secondary" variant="caption">
              {runtimeMessage}
            </AppText>
          </Surface>
        ) : null}
      </View>
    </Screen>
  );
}
