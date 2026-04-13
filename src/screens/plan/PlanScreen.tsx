import { useScrollToTop } from "@react-navigation/native";
import { NativeStackScreenProps } from "@react-navigation/native-stack";
import { Ionicons } from "@expo/vector-icons";
import { useMemo, useRef } from "react";
import { View } from "react-native";
import { useShallow } from "zustand/react/shallow";

import {
  DetailSection,
  DetailSummaryStrip,
  QuietMetaLine,
} from "../../components/detail/DetailPrimitives";
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
import { buildPlanWorkspaceViewModel, PlanDaySummary, PlanStructureItem } from "../../state/viewModels/plan";

type Props = NativeStackScreenProps<PlanStackParamList, "PlanHome">;

function WeekdayRow({ day }: { day: PlanDaySummary }) {
  return (
    <Surface tone="sunken" className="flex-row items-center gap-3 rounded-[20px] px-4 py-3 mb-0">
      <View className="min-w-[108px] gap-1">
        <AppText variant="caption">{day.label}</AppText>
        <AppText tone="tertiary" variant="micro">
          {day.fixedCount > 0 ? `${day.fixedCount} fixed` : "Open day"}
        </AppText>
      </View>
      <View className="flex-1 gap-1">
        <AppText tone="secondary" variant="caption">
          {day.focusMinutes > 0
            ? `${day.focusMinutes} min focus protected`
            : "No protected focus placed yet"}
        </AppText>
        <AppText tone="tertiary" variant="caption">
          {day.scheduledMinutes > 0
            ? `${day.scheduledMinutes} min already planned`
            : "Nothing placed yet"}
        </AppText>
      </View>
      <View className="items-end gap-1">
        <AppText variant="caption">{day.openMinutes} min open</AppText>
        <AppText tone={day.isTight ? "accent" : "tertiary"} variant="micro">
          {day.isTight ? "Tight" : `${day.meaningfulWindowCount} windows`}
        </AppText>
      </View>
    </Surface>
  );
}

function StructureList({
  title,
  empty,
  items,
}: {
  title: string;
  empty: string;
  items: PlanStructureItem[];
}) {
  return (
    <View className="gap-2.5">
      <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
        {title}
      </AppText>
      {items.length > 0 ? (
        <View className="gap-2">
          {items.map((item) => (
            <Surface
              tone="sunken"
              key={item.id}
              className="gap-1 rounded-[18px] px-4 py-3"
            >
              <AppText variant="caption">{item.title}</AppText>
              <AppText tone="secondary" variant="caption">
                {item.detail}
              </AppText>
              <AppText tone="tertiary" variant="micro">
                {item.supporting}
              </AppText>
            </Surface>
          ))}
        </View>
      ) : (
        <AppText tone="secondary" variant="caption">
          {empty}
        </AppText>
      )}
    </View>
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
  const returnItems = workspace
    ? [
        {
          label: "Open",
          value: `${workspace.capacitySummary.openCapacityMinutes} min`,
          detail: `${workspace.capacitySummary.meaningfulWindowCount} usable window${workspace.capacitySummary.meaningfulWindowCount === 1 ? "" : "s"} this week`,
        },
        {
          label: "Carryover",
          value: String(workspace.carryoverSummary.enteringCount),
          detail: workspace.carryoverSummary.detail,
        },
        {
          label: "Pressure",
          value: String(workspace.structureSummary.underPressureCount),
          detail:
            workspace.structureSummary.underPressureCount > 0
              ? "Needs a deliberate reshaping decision"
              : "No major pressure points are flashing right now",
        },
        {
          label: "Next move",
          value: workspace.shouldOpenWeeklyReview ? "Review week" : "Open week",
          detail: workspace.strategySummary.weeklyShape,
        },
      ]
    : [];
  const returnReads = workspace
    ? [
        workspace.heroDetail,
        workspace.capacitySummary.weeklyLoadDetail,
        reviewGoals.length > 0
          ? `${reviewGoals.length} goal review${reviewGoals.length === 1 ? "" : "s"} are still waiting outside the weekly structure.`
          : "No goal review backlog is waiting on the week.",
        workspace.structureSummary.carryoverCount > 0
          ? "Carryover is visible here so Today does not have to carry that reading burden."
          : "No meaningful carryover is obscuring the week.",
      ]
    : [];

  function openWeeklyExperience() {
    (navigation.getParent() as any)?.navigate("Insights", {
      screen: "InsightsHome",
    });
  }

  if (!workspace) {
    return (
      <Screen ref={scrollRef}>
        <EmptyStateCard
          eyebrow="Preparing"
          title="Plan is still loading"
          body="The weekly structure is still being composed."
        />
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
              <Button
                tone="secondary"
                style={{ flex: 1 }}
                onPress={() => navigation.navigate("PlanDetail")}
              >
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
      <View className="gap-6">
        <PageHeader
          eyebrow="Plan"
          title="Plan"
          description="This week at a glance."
          action={
            <Button
              size="compact"
              onPress={workspace.shouldOpenWeeklyReview ? openWeeklyExperience : () => navigation.navigate("PlanDetail")}
            >
              {workspace.shouldOpenWeeklyReview ? "Weekly review" : "Open week"}
            </Button>
          }
        />

        <Surface tone="hero" className="gap-4">
          <View className="gap-3">
            <View className="flex-row flex-wrap gap-2">
              <Pill label={workspace.weekLabel} tone="accent" />
              <Pill label={workspace.pressureLabel} tone={workspace.pressureTone} />
              <Pill label={workspace.strategySummary.sourceLabel} tone="quiet" />
              {reviewGoals.length > 0 ? <Pill label={`${reviewGoals.length} review`} tone="quiet" /> : null}
            </View>
            <View className="gap-1.5">
              <AppText variant="title">{workspace.heroTitle}</AppText>
              <AppText tone="secondary">{workspace.heroDetail}</AppText>
            </View>
          </View>

          <DetailSummaryStrip
            items={[
              {
                label: "Fixed",
                value: String(workspace.structureSummary.fixedCommitmentCount),
                detail: `${workspace.structureSummary.fixedCommitmentMinutes} min anchored`,
              },
              {
                label: "Flexible",
                value: String(workspace.structureSummary.flexibleWorkCount),
                detail: "Still shaping the week",
              },
              {
                label: "Focus",
                value: `${workspace.structureSummary.protectedFocusMinutes} min`,
                detail: `${workspace.structureSummary.protectedFocusBlockCount} protected blocks`,
              },
              {
                label: "Open",
                value: `${workspace.capacitySummary.openCapacityMinutes} min`,
                detail: `${workspace.capacitySummary.meaningfulWindowCount} usable windows`,
              },
            ]}
          />

          <QuietMetaLine items={workspace.structuralReads.slice(0, 2)} />
        </Surface>

        <Surface className="gap-5">
          <DetailSection
            title="Return line"
            description="What changed and what to do next."
          >
            <View className="gap-4">
              <DetailSummaryStrip items={returnItems} />
              <QuietMetaLine items={returnReads} />
            </View>
          </DetailSection>
        </Surface>

        {calendarConnectionState?.connectionStatus !== "ready" ? (
          <Surface tone="sunken" className="gap-3">
            <View className="gap-1">
              <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                Calendar fallback
              </AppText>
              <AppText variant="section">Plan is leaning on saved schedule defaults.</AppText>
            </View>
            <AppText tone="secondary" variant="caption">
              Fixed commitments may still be understated until live calendar context is available again.
            </AppText>
          </Surface>
        ) : null}

        <Surface className="gap-4">
          <DetailSection
            title="This week"
            description="Which days are anchored and where room is left."
            action={
              <Button size="compact" tone="tertiary" onPress={() => navigation.navigate("PlanDetail")}>
                Open week
              </Button>
            }
          >
            <View className="gap-2.5">
              {workspace.days.map((day) => (
                <WeekdayRow key={day.date} day={day} />
              ))}
            </View>
          </DetailSection>
        </Surface>

        <Surface className="gap-5">
          <DetailSection
            title="Structure"
            description="One glance should tell you what is locked, negotiable, and already under pressure."
          >
            <View className="gap-4">
              <StructureList
                title="Fixed commitments"
                empty="No fixed commitments are anchoring the week yet."
                items={workspace.fixedCommitments}
              />
              <StructureList
                title="Flexible work"
                empty="No meaningful work is waiting for placement right now."
                items={workspace.flexibleWork}
              />
              <StructureList
                title="Optional or stretch"
                empty="There is no visible stretch work crowding essentials."
                items={workspace.optionalWork}
              />
            </View>
          </DetailSection>

          <DetailSection
            title="Capacity"
            description="This is the real room left once calendar anchors and planned work are accounted for."
          >
            <Surface tone="sunken" className="gap-3 rounded-[22px] px-4 py-4 mb-0">
              <View className="flex-row flex-wrap gap-x-6 gap-y-3">
                <View className="min-w-[96px] gap-1">
                  <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                    Load
                  </AppText>
                  <AppText variant="section">{workspace.pressureLabel}</AppText>
                </View>
                <View className="min-w-[96px] gap-1">
                  <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                    Largest window
                  </AppText>
                  <AppText variant="section">
                    {workspace.capacitySummary.largestOpenWindowLabel ?? "No clear window"}
                  </AppText>
                </View>
                <View className="min-w-[96px] gap-1">
                  <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                    Fragmentation
                  </AppText>
                  <AppText variant="section">{workspace.capacitySummary.fragmentationLabel}</AppText>
                </View>
              </View>
              <AppText tone="secondary" variant="caption">
                {workspace.capacitySummary.weeklyLoadDetail}
              </AppText>
              <AppText tone="tertiary" variant="caption">
                {workspace.capacitySummary.fragmentationDetail}
              </AppText>
            </Surface>
          </DetailSection>
        </Surface>

        <Surface className="gap-5">
          <DetailSection
            title="Carryover and next decisions"
            description="Keep unfinished work explicit."
          >
            <View className="gap-4">
              <DetailSummaryStrip
                items={[
                  {
                    label: "Entering",
                    value: String(workspace.carryoverSummary.enteringCount),
                    detail: "Came in as carryover",
                  },
                  {
                    label: "Protected",
                    value: String(workspace.carryoverSummary.protectedCount),
                    detail: "Already held in the week",
                  },
                  {
                    label: "Review",
                    value: String(workspace.carryoverSummary.reviewCount),
                    detail: "Should go back through review",
                  },
                  {
                    label: "Pressure",
                    value: String(workspace.structureSummary.underPressureCount),
                    detail: "Likely to slip without intervention",
                  },
                ]}
              />
              <AppText tone="secondary" variant="caption">
                {workspace.carryoverSummary.detail}
              </AppText>
              {workspace.carryoverItems.length > 0 ? (
                <StructureList
                  title="Carryover in view"
                  empty=""
                  items={workspace.carryoverItems}
                />
              ) : null}
            </View>
          </DetailSection>

          <DetailSection
            title="Drill in"
            description="Open the connected planning views."
          >
            <View className="gap-3">
              <DrillInRow
                title="Weekly shaping"
                subtitle={workspace.strategySummary.detail}
                detail={workspace.strategySummary.weeklyShape}
                actionLabel="Open"
                leading={<Ionicons color={theme.colors.text.secondary} name="sparkles-outline" size={18} />}
                onPress={openWeeklyExperience}
              />
              <DrillInRow
                title="Generated structure"
                subtitle="Goals, milestones, and the current task shape."
                detail={`${activeGoals.length} active goals`}
                actionLabel="Open"
                leading={<Ionicons color={theme.colors.text.secondary} name="layers-outline" size={18} />}
                onPress={() => navigation.navigate("PlanStructure", {})}
              />
            </View>
          </DetailSection>
        </Surface>
      </View>
    </Screen>
  );
}
