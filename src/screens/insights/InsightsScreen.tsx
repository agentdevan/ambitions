import { useScrollToTop } from "@react-navigation/native";
import { NativeStackScreenProps } from "@react-navigation/native-stack";
import { Ionicons } from "@expo/vector-icons";
import { useMemo, useRef } from "react";
import { View } from "react-native";
import { useShallow } from "zustand/react/shallow";

import { MomentumBars } from "../../components/history/ActivityTimeline";
import { DetailSummaryStrip } from "../../components/detail/DetailPrimitives";
import { DrillInRow } from "../../components/navigation/DrillInRow";
import { PageHeader } from "../../components/navigation/PageHeader";
import { Button } from "../../components/ui/Button";
import { EmptyStateCard } from "../../components/ui/EmptyStateCard";
import { Pill } from "../../components/ui/Pill";
import { Screen } from "../../components/ui/Screen";
import { Surface } from "../../components/ui/Surface";
import { AppText } from "../../components/ui/Text";
import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { ActivityEventKind } from "../../domain/models";
import { InsightsStackParamList } from "../../navigation/types";
import { getGoalReviewDraft } from "../../services/goals/metadata";
import { buildMonthlyReviewDigest } from "../../services/history/monthly";
import { buildActivityFeed, summarizeInsights } from "../../services/history/selectors";
import { buildWeeklyReviewDigest, summarizeWeeklyContinuity } from "../../services/history/weekly";
import { useAppStore } from "../../state/useAppStore";
import { formatMonthLabel } from "../../utils/date";

type Props = NativeStackScreenProps<InsightsStackParamList, "InsightsHome">;

export function InsightsScreen({ navigation }: Props) {
  const scrollRef = useRef<any>(null);
  useScrollToTop(scrollRef);
  const {
    goals,
    milestones,
    tasks,
    activityEvents,
    today,
    adaptationProfile,
    productPreferences,
    userPreferences,
    dailyRitualHistory,
    weeklyReviewHistory,
  } = useAppStore(
    useShallow((state) => ({
      goals: state.goals,
      milestones: state.milestones,
      tasks: state.allTasks,
      activityEvents: state.activityEvents,
      today: state.today,
      adaptationProfile: state.adaptationProfile,
      productPreferences: state.productPreferences,
      userPreferences: state.userPreferences,
      dailyRitualHistory: state.dailyRitualHistory,
      weeklyReviewHistory: state.weeklyReviewHistory,
    })),
  );
  const theme = useResolvedTheme();

  const pendingReviews = goals.filter((goal) => getGoalReviewDraft(goal) !== null).length;
  const feed = useMemo(() => buildActivityFeed(activityEvents, tasks, milestones), [activityEvents, milestones, tasks]);
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
  const weeklyContinuity = useMemo(() => summarizeWeeklyContinuity(weeklyReviewHistory), [weeklyReviewHistory]);
  const planChangeEvents = feed.filter((event) =>
    [ActivityEventKind.PlanReviewAccepted, ActivityEventKind.PlanReviewGenerated, ActivityEventKind.PlanReviewReverted, ActivityEventKind.GoalUpdated, ActivityEventKind.TaskRescheduled].includes(event.kind),
  );

  if (goals.length === 0 && feed.length === 0) {
    return (
      <Screen ref={scrollRef}>
        <View className="gap-5">
          <PageHeader eyebrow="Insights" title="Insights" description="Weekly read and next-week shape." />
          <EmptyStateCard
            eyebrow="Nothing to read yet"
            title="Insights will become useful once work starts moving."
            body="Finish a few tasks, review a week, or shape a plan and this screen will turn that movement into a calmer read."
            tone="sunken"
            action={
              <View className="flex-row gap-3 pt-1">
                <Button style={{ flex: 1 }} onPress={() => navigation.getParent()?.navigate("Goals")}>
                  Goals
                </Button>
                <Button tone="secondary" style={{ flex: 1 }} onPress={() => navigation.getParent()?.navigate("Plan")}>
                  Plan
                </Button>
              </View>
            }
          />
        </View>
      </Screen>
    );
  }

  return (
    <Screen ref={scrollRef}>
      <View className="gap-5">
        <PageHeader
          eyebrow="Insights"
          title="Insights"
          description="The short version of what moved and what needs your next read."
          action={
            <View className="flex-row gap-3">
              <Button size="compact" style={{ flex: 1 }} onPress={() => navigation.navigate("InsightMonthlyReview")}>
                Monthly review
              </Button>
              <Button size="compact" tone="secondary" style={{ flex: 1 }} onPress={() => navigation.navigate("InsightActivity")}>
                Activity
              </Button>
            </View>
          }
        />

        <Surface tone="hero" className="gap-4">
          <View className="flex-row flex-wrap items-center gap-2">
            <Pill label={`${summary.completedThisWeek} completed`} tone="accent" />
            <Pill label={`${summary.reshapedThisWeek} reshaped`} tone="quiet" />
            {pendingReviews > 0 ? <Pill label={`${pendingReviews} review`} tone="neutral" /> : null}
          </View>
          <View className="gap-1">
            <AppText variant="title">{summary.personalizedHighlights[0] ?? summary.momentumCopy}</AppText>
            <AppText tone="secondary">{summary.personalizedHighlights[1] ?? summary.planCopy}</AppText>
          </View>
          <DetailSummaryStrip
            items={[
              { label: "This week", value: weeklyDigest.summary.heldSteady ? "Holding" : "Needs reset", detail: weeklyDigest.reads[0] },
              {
                label: "Continuity",
                value: `${weeklyContinuity.reviewedWeeks} reviewed`,
                detail:
                  weeklyContinuity.reviewedWeeks > 0
                    ? `${weeklyContinuity.shapedWeeks} shaped with an average churn score of ${weeklyContinuity.averageWeeklyChurn.toFixed(1)}.`
                    : "No reviewed weeks yet.",
              },
              { label: "Month", value: formatMonthLabel(monthlyDigest.monthStartDate), detail: monthlyDigest.headline },
              { label: "Plan shifts", value: String(planChangeEvents.length), detail: "Recent changes worth opening" },
            ]}
          />
          <View className="flex-row gap-3">
            <Button style={{ flex: 1 }} onPress={() => navigation.navigate("InsightMonthlyReview")}>
              Open monthly review
            </Button>
            <Button tone="secondary" style={{ flex: 1 }} onPress={() => navigation.navigate("InsightContinuity")}>
              Open continuity
            </Button>
          </View>
        </Surface>

        <Surface className="gap-4">
          <View className="gap-1">
            <AppText variant="section">Trend</AppText>
            <AppText tone="secondary">The last 7 days, without the extra explanation.</AppText>
          </View>
          <MomentumBars points={summary.momentum} />
        </Surface>

        <Surface className="gap-3">
          <View className="flex-row items-center justify-between gap-3">
            <AppText variant="section">Recent movement</AppText>
            <Button size="compact" tone="secondary" onPress={() => navigation.navigate("InsightActivity")}>
              View all
            </Button>
          </View>
          {feed.slice(0, 3).map((event) => (
            <Surface key={event.id} tone="sunken" className="gap-1.5 mb-0">
              <AppText variant="caption">{event.title}</AppText>
              <AppText tone="secondary" variant="caption">
                {event.outcomeLabel}
              </AppText>
            </Surface>
          ))}
        </Surface>

        <Surface className="gap-3">
          <AppText variant="section">Open more</AppText>
          <DrillInRow
            title="Monthly review"
            subtitle="Direction, coverage, and drag"
            detail={formatMonthLabel(monthlyDigest.monthStartDate)}
            actionLabel="Open"
            leading={<Ionicons color={theme.colors.accent.primary} name="calendar-outline" size={18} />}
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
            title="Plan movement"
            subtitle="What shifted"
            detail={`${planChangeEvents.length} changes`}
            actionLabel="Open"
            leading={<Ionicons color={theme.colors.text.secondary} name="swap-horizontal-outline" size={18} />}
            onPress={() => navigation.navigate("InsightPlanChanges")}
          />
          <DrillInRow
            title="Capacity"
            subtitle={`${today?.capacity.unusedCapacityMinutes ?? 0} min open`}
            detail={today?.capacity.overloadWarning ? "Tight day" : "Balanced"}
            actionLabel="Open"
            leading={<Ionicons color={theme.colors.text.secondary} name="speedometer-outline" size={18} />}
            onPress={() => navigation.navigate("InsightCapacity")}
          />
        </Surface>
      </View>
    </Screen>
  );
}
