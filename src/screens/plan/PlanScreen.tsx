import { useScrollToTop } from "@react-navigation/native";
import { NativeStackScreenProps } from "@react-navigation/native-stack";
import { Ionicons } from "@expo/vector-icons";
import { useMemo, useRef } from "react";
import { View } from "react-native";
import { useShallow } from "zustand/react/shallow";

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
import { GoalStatus } from "../../domain/models";
import { PlanStackParamList } from "../../navigation/types";
import { getGoalReviewDraft } from "../../services/goals/metadata";
import { useAppStore } from "../../state/useAppStore";
import { buildPlanWorkspaceViewModel, PlanDaySummary } from "../../state/viewModels/plan";

type Props = NativeStackScreenProps<PlanStackParamList, "PlanHome">;

function WeekdayRow({ day }: { day: PlanDaySummary }) {
  return (
    <Surface tone="sunken" className="flex-row items-center gap-3 rounded-[20px] px-4 py-3 mb-0">
      <View className="min-w-[104px] gap-1">
        <AppText variant="caption">{day.label}</AppText>
        <AppText tone="secondary" variant="caption">
          {day.fixedCount > 0 ? `${day.fixedCount} fixed` : "Open day"}
        </AppText>
      </View>
      <View className="flex-1 gap-1">
        <AppText tone="secondary" variant="caption">
          {day.focusMinutes > 0 ? `${day.focusMinutes} min protected` : "No focus protected yet"}
        </AppText>
        <AppText tone="secondary" variant="caption">
          {day.openMinutes} min open
        </AppText>
      </View>
      <Pill label={day.isTight ? "Tight" : `${day.meaningfulWindowCount} windows`} tone={day.isTight ? "neutral" : "quiet"} />
    </Surface>
  );
}

export function PlanScreen({ navigation }: Props) {
  const theme = useResolvedTheme();
  const scrollRef = useRef<any>(null);
  useScrollToTop(scrollRef);
  const {
    planDate,
    goals,
    dailyPlans,
    timeBlocks,
    tasks,
    preferences,
    adaptationProfile,
    currentWeekReview,
    currentMonthReview,
    calendarConnectionState,
    weekScheduleConstraints,
  } = useAppStore(
    useShallow((state) => ({
      planDate: state.planDate,
      goals: state.goals,
      dailyPlans: state.dailyPlans,
      timeBlocks: state.allTimeBlocks,
      tasks: state.allTasks,
      preferences: state.userPreferences,
      adaptationProfile: state.adaptationProfile,
      currentWeekReview: state.currentWeekReview,
      currentMonthReview: state.currentMonthReview,
      calendarConnectionState: state.calendarConnectionState,
      weekScheduleConstraints: state.weekScheduleConstraints,
    })),
  );

  const reviewGoals = goals.filter((goal) => getGoalReviewDraft(goal) !== null);
  const activeGoals = goals.filter((goal) => goal.status === GoalStatus.Active);
  const workspace = useMemo(
    () =>
      buildPlanWorkspaceViewModel({
        date: planDate,
        goals,
        preferences,
        adaptationProfile,
        dailyPlans,
        timeBlocks,
        tasks,
        weekScheduleConstraints,
        currentWeekReview,
        currentMonthReview,
        calendarConnectionState,
      }),
    [
      adaptationProfile,
      calendarConnectionState,
      currentMonthReview,
      currentWeekReview,
      dailyPlans,
      goals,
      planDate,
      preferences,
      tasks,
      timeBlocks,
      weekScheduleConstraints,
    ],
  );

  function openWeeklyExperience() {
    (navigation.getParent() as any)?.navigate("Insights", { screen: "InsightsHome" });
  }

  if (!workspace) {
    return (
      <Screen ref={scrollRef}>
        <EmptyStateCard eyebrow="Preparing" title="Plan is still loading" body="The weekly structure is still being composed." />
      </Screen>
    );
  }

  if (activeGoals.length === 0 && workspace.structureSummary.fixedCommitmentCount === 0) {
    return (
      <Screen ref={scrollRef}>
        <EmptyStateCard
          eyebrow="Sparse week"
          title="No week to shape yet"
          body="Add a goal or connect calendar context, then Plan can show the real shape of the week instead of an empty shell."
          action={
            <View className="flex-row gap-3 pt-1">
              <Button style={{ flex: 1 }} onPress={() => navigation.getParent()?.navigate("Goals")}>
                Goals
              </Button>
              <Button tone="secondary" style={{ flex: 1 }} onPress={() => navigation.navigate("PlanDetail")}>
                Open week
              </Button>
            </View>
          }
        />
      </Screen>
    );
  }

  return (
    <Screen ref={scrollRef}>
      <View className="gap-5">
        <PageHeader
          eyebrow="Plan"
          title="Plan"
          description="This week at a glance."
          action={
            <View className="flex-row gap-3">
              <Button
                size="compact"
                style={{ flex: 1 }}
                onPress={workspace.shouldOpenWeeklyReview ? openWeeklyExperience : () => navigation.navigate("PlanDetail")}
              >
                {workspace.shouldOpenWeeklyReview ? "Weekly review" : "Open week"}
              </Button>
              <Button size="compact" tone="secondary" style={{ flex: 1 }} onPress={() => navigation.navigate("PlanStructure", {})}>
                Structure
              </Button>
            </View>
          }
        />

        <Surface tone="hero" className="gap-4">
          <View className="flex-row flex-wrap items-center gap-2">
            <Pill label={workspace.weekLabel} tone="accent" />
            <Pill label={workspace.pressureLabel} tone={workspace.pressureTone} />
            <Pill label={workspace.strategySummary.sourceLabel} tone="quiet" />
            {reviewGoals.length > 0 ? <Pill label={`${reviewGoals.length} review`} tone="quiet" /> : null}
          </View>
          <View className="gap-1">
            <AppText variant="title">{workspace.heroTitle}</AppText>
            <AppText tone="secondary">{workspace.heroDetail}</AppText>
          </View>
          <DetailSummaryStrip
            items={[
              { label: "Open", value: `${workspace.capacitySummary.openCapacityMinutes} min`, detail: `${workspace.capacitySummary.meaningfulWindowCount} usable windows` },
              { label: "Focus", value: `${workspace.structureSummary.protectedFocusMinutes} min`, detail: `${workspace.structureSummary.protectedFocusBlockCount} protected blocks` },
              { label: "Carryover", value: String(workspace.carryoverSummary.enteringCount), detail: workspace.carryoverSummary.detail },
              { label: "Pressure", value: String(workspace.structureSummary.underPressureCount), detail: workspace.pressureDetail },
            ]}
          />
          <View className="flex-row gap-3">
            <Button style={{ flex: 1 }} onPress={workspace.shouldOpenWeeklyReview ? openWeeklyExperience : () => navigation.navigate("PlanDetail")}>
              {workspace.shouldOpenWeeklyReview ? "Open weekly review" : "Open week plan"}
            </Button>
            <Button tone="secondary" style={{ flex: 1 }} onPress={() => navigation.navigate("PlanStructure", {})}>
              Open structure
            </Button>
          </View>
        </Surface>

        <Surface className="gap-4">
          <View className="flex-row items-center justify-between gap-3">
            <View className="gap-1">
              <AppText variant="section">Week at a glance</AppText>
              <AppText tone="secondary">Anchors first, open room second.</AppText>
            </View>
            <Button size="compact" tone="secondary" onPress={() => navigation.navigate("PlanDetail")}>
              Open week
            </Button>
          </View>
          <View className="gap-2.5">
            {workspace.days.slice(0, 4).map((day) => (
              <WeekdayRow key={day.date} day={day} />
            ))}
          </View>
        </Surface>

        <Surface className="gap-3">
          <AppText variant="section">Open more</AppText>
          <DrillInRow
            title="Weekly shaping"
            subtitle={workspace.strategySummary.detail}
            detail={workspace.strategySummary.weeklyShape}
            actionLabel="Open"
            leading={<Ionicons color={theme.colors.accent.primary} name="sparkles-outline" size={18} />}
            onPress={openWeeklyExperience}
          />
          <DrillInRow
            title="Week detail"
            subtitle="See every day, block, and pressure point"
            detail={`${workspace.days.length} days`}
            actionLabel="Open"
            leading={<Ionicons color={theme.colors.text.secondary} name="calendar-outline" size={18} />}
            onPress={() => navigation.navigate("PlanDetail")}
          />
          <DrillInRow
            title="Generated structure"
            subtitle="Goals, milestones, and the current task shape"
            detail={`${activeGoals.length} active goals`}
            actionLabel="Open"
            leading={<Ionicons color={theme.colors.text.secondary} name="layers-outline" size={18} />}
            onPress={() => navigation.navigate("PlanStructure", {})}
          />
        </Surface>

        {calendarConnectionState?.connectionStatus !== "ready" ? (
          <Surface tone="sunken" className="gap-2">
            <AppText variant="caption">Using saved schedule defaults right now.</AppText>
            <AppText tone="secondary" variant="caption">
              Fixed commitments may still be understated until live calendar context is available again.
            </AppText>
          </Surface>
        ) : null}
      </View>
    </Screen>
  );
}
