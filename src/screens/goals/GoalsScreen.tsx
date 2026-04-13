import { NativeStackScreenProps } from "@react-navigation/native-stack";
import { useMemo } from "react";
import { Ionicons } from "@expo/vector-icons";
import { View } from "react-native";
import { useShallow } from "zustand/react/shallow";

import { PageHeader } from "../../components/navigation/PageHeader";
import { Button } from "../../components/ui/Button";
import { EmptyStateCard } from "../../components/ui/EmptyStateCard";
import { Pill } from "../../components/ui/Pill";
import { Screen } from "../../components/ui/Screen";
import { Surface } from "../../components/ui/Surface";
import { AppText } from "../../components/ui/Text";
import { CompactExplanationCard } from "../../components/detail/DetailPrimitives";
import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { GoalMilestoneStatus, GoalStatus, TaskStatus } from "../../domain/models";
import { GoalsStackParamList } from "../../navigation/types";
import { describeGoalFeasibility } from "../../services/goals/goalIntelligence";
import {
  AmbitionProgressTruth,
  GoalProgressTruth,
  buildDirectionPortfolioSnapshot,
  buildGoalProgressTruth,
} from "../../services/goals/progress";
import { getGoalReviewDraft } from "../../services/goals/metadata";
import { canonicalizeAmbitions, canonicalizeGoals } from "../../services/goals/portfolioIntegrity";
import { buildActivityFeed } from "../../services/history/selectors";
import { useAppStore } from "../../state/useAppStore";
import { formatShortDate } from "../../utils/date";

type Props = NativeStackScreenProps<GoalsStackParamList, "GoalsHome">;

function goalTruthTone(truth: GoalProgressTruth | null | undefined) {
  if (!truth) {
    return "quiet" as const;
  }

  if (truth.paceState === "on_pace" || truth.paceState === "recovered") {
    return "accent" as const;
  }

  if (truth.paceState === "slightly_off_pace") {
    return "neutral" as const;
  }

  return "quiet" as const;
}

function ambitionTruthTone(truth: AmbitionProgressTruth) {
  if (truth.representationState === "well_represented") {
    return "accent" as const;
  }

  if (truth.representationState === "lightly_represented") {
    return "neutral" as const;
  }

  return "quiet" as const;
}

function SummaryTile({
  label,
  value,
  detail,
}: {
  label: string;
  value: string;
  detail: string;
}) {
  return (
    <Surface tone="sunken" className="min-w-[31%] flex-1 gap-1.5 mb-0 px-4 py-4">
      <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
        {label}
      </AppText>
      <AppText variant="section">{value}</AppText>
      <AppText tone="secondary" variant="caption">
        {detail}
      </AppText>
    </Surface>
  );
}

function DirectionCard({
  title,
  thesis,
  truth,
  onPress,
}: {
  title: string;
  thesis: string | null | undefined;
  truth: AmbitionProgressTruth;
  onPress: () => void;
}) {
  const weekHours = Math.max(0, Math.round(truth.currentWeekScheduledMinutes / 60));

  return (
    <Surface tone={truth.representationState === "underrepresented" ? "accent" : "default"} className="gap-4 mb-0">
      <View className="flex-row flex-wrap items-center justify-between gap-2">
        <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
          Direction
        </AppText>
        <View className="flex-row flex-wrap gap-2">
          <Pill label={truth.representationLabel} tone={ambitionTruthTone(truth)} />
          <Pill label={`${truth.activeGoalCount} goals`} tone="quiet" />
        </View>
      </View>
      <View className="gap-2">
        <AppText variant="section">{title}</AppText>
        <AppText tone="secondary" variant="caption">
          {thesis ?? truth.portfolioSummary}
        </AppText>
      </View>
      <View className="flex-row flex-wrap gap-3">
        <SummaryTile
          label="This week"
          value={`${weekHours} hr`}
          detail={truth.representationSummary}
        />
        <SummaryTile
          label="Moving"
          value={String(truth.movingGoalCount)}
          detail={`${truth.representedGoalCount} goals currently visible`}
        />
      </View>
      <View className="flex-row items-center justify-between gap-3">
        <AppText tone="secondary" variant="caption" style={{ flex: 1 }}>
          {truth.portfolioSummary}
        </AppText>
        <Button tone="tertiary" size="compact" onPress={onPress}>
          Open ambition
        </Button>
      </View>
      <CompactExplanationCard explanation={truth.explanation} />
    </Surface>
  );
}

function GoalSignalCard({
  title,
  detail,
  iconName,
  highlighted = false,
}: {
  title: string;
  detail: string;
  iconName: keyof typeof Ionicons.glyphMap;
  highlighted?: boolean;
}) {
  const theme = useResolvedTheme();

  return (
    <Surface tone="sunken" className="min-w-[31%] flex-1 gap-2 mb-0 px-4 py-4">
      <View className="flex-row items-center gap-2">
        <View
          className="rounded-[14px] px-2.5 py-2.5"
          style={{
            backgroundColor: highlighted
              ? theme.colors.background.accentWashStrong
              : theme.colors.background.elevatedSecondary,
          }}
        >
          <Ionicons
            color={highlighted ? theme.colors.accent.primary : theme.colors.text.secondary}
            name={iconName}
            size={16}
          />
        </View>
        <AppText variant="caption">{title}</AppText>
      </View>
      <AppText tone="secondary" variant="caption">
        {detail}
      </AppText>
    </Surface>
  );
}

export function GoalsScreen({ navigation }: Props) {
  const {
    ambitions,
    goals,
    milestones,
    tasks,
    timeBlocks,
    activityEvents,
    currentWeekReview,
    currentMonthReview,
  } = useAppStore(
    useShallow((state) => ({
      ambitions: state.ambitions,
      goals: state.goals,
      milestones: state.milestones,
      tasks: state.allTasks,
      timeBlocks: state.allTimeBlocks,
      activityEvents: state.activityEvents,
      currentWeekReview: state.currentWeekReview,
      currentMonthReview: state.currentMonthReview,
    })),
  );

  const {
    uniqueAmbitions,
    activeGoals,
    inactiveGoals,
    reviewGoalIds,
    directionPortfolio,
    linkedActiveGoalCount,
    unlinkedActiveGoals,
    goalTruthById,
    currentMilestoneByGoalId,
    nextTaskByGoalId,
    recentEventByGoalId,
    movingGoalCount,
    attentionGoalCount,
  } = useMemo(() => {
    const uniqueAmbitions = canonicalizeAmbitions(ambitions);
    const uniqueGoals = canonicalizeGoals(goals);
    const activeGoals = uniqueGoals
      .filter((goal) => goal.status === GoalStatus.Active)
      .sort((left, right) => {
        if (!!left.ambitionId !== !!right.ambitionId) {
          return left.ambitionId ? -1 : 1;
        }
        return left.sortOrder - right.sortOrder;
      });
    const inactiveGoals = uniqueGoals.filter((goal) =>
      [GoalStatus.Paused, GoalStatus.Archived, GoalStatus.Completed].includes(goal.status),
    );
    const reviewGoalIds = new Set(
      uniqueGoals.filter((goal) => getGoalReviewDraft(goal) !== null).map((goal) => goal.id),
    );
    const feed = buildActivityFeed(activityEvents, tasks, milestones);
    const currentMilestoneByGoalId = new Map(
      activeGoals.map((goal) => [
        goal.id,
        milestones
          .filter((item) => item.goalId === goal.id)
          .sort((left, right) => left.sortOrder - right.sortOrder)
          .find((item) =>
            [GoalMilestoneStatus.InProgress, GoalMilestoneStatus.Pending].includes(item.status),
          ) ?? null,
      ]),
    );
    const nextTaskByGoalId = new Map(
      activeGoals.map((goal) => [
        goal.id,
        tasks
          .filter((item) => item.goalId === goal.id && item.status !== TaskStatus.Cancelled)
          .sort((left, right) => left.createdAt.localeCompare(right.createdAt))
          .find((item) =>
            [TaskStatus.InProgress, TaskStatus.Scheduled, TaskStatus.Ready].includes(item.status),
          ) ?? null,
      ]),
    );
    const recentEventByGoalId = new Map(
      activeGoals.map((goal) => [goal.id, feed.find((event) => event.goalId === goal.id) ?? null]),
    );
    const goalTruths = activeGoals.map((goal) =>
      buildGoalProgressTruth({
        goal,
        ambition: uniqueAmbitions.find((entry) => entry.id === goal.ambitionId) ?? null,
        milestones: milestones.filter((item) => item.goalId === goal.id),
        tasks: tasks.filter((item) => item.goalId === goal.id),
        timeBlocks,
        activityFeed: feed,
        currentWeekReview,
        currentMonthReview,
      }),
    );
    const directionPortfolio = buildDirectionPortfolioSnapshot({
      ambitions: uniqueAmbitions,
      goals: activeGoals,
      goalTruths,
    });
    const goalTruthById = new Map(goalTruths.map((truth) => [truth.goalId, truth]));
    const movingGoalCount = goalTruths.filter((truth) =>
      ["on_pace", "slightly_off_pace", "recovered"].includes(truth.paceState),
    ).length;
    const attentionGoalCount = goalTruths.filter(
      (truth) =>
        truth.crowded ||
        truth.stale ||
        truth.paceState === "reset_needed" ||
        truth.paceState === "unrealistic",
    ).length;

    return {
      uniqueAmbitions,
      activeGoals,
      inactiveGoals,
      reviewGoalIds,
      directionPortfolio,
      linkedActiveGoalCount: activeGoals.filter((goal) => goal.ambitionId).length,
      unlinkedActiveGoals: activeGoals.filter((goal) => !goal.ambitionId),
      goalTruthById,
      currentMilestoneByGoalId,
      nextTaskByGoalId,
      recentEventByGoalId,
      movingGoalCount,
      attentionGoalCount,
    };
  }, [
    ambitions,
    goals,
    milestones,
    tasks,
    timeBlocks,
    activityEvents,
    currentWeekReview,
    currentMonthReview,
  ]);

  return (
    <Screen>
      <View className="gap-5">
        <PageHeader
          eyebrow="Goals"
          title="Goals"
          description="Direction and active work."
          action={
            <View className="flex-row gap-2">
              <Button size="compact" tone="secondary" onPress={() => navigation.navigate("AmbitionEdit", {})}>
                New ambition
              </Button>
              <Button size="compact" onPress={() => navigation.navigate("GoalEdit", {})}>
                New goal
              </Button>
            </View>
          }
        />

        {goals.length === 0 ? (
          <EmptyStateCard
            eyebrow="Start here"
            title="No goals yet"
            body="Start with one clear goal. Direction, pace, and believable work will build outward from there."
            action={
              <View className="pt-1">
                <Button tone="secondary" onPress={() => navigation.navigate("GoalEdit", {})}>
                  Create goal
                </Button>
              </View>
            }
          />
        ) : (
          <>
            {activeGoals.length === 0 ? (
              <EmptyStateCard
                eyebrow="Quiet portfolio"
                title="Nothing is active right now"
                body="Your history and archived work are still here, but Goals will feel most useful once one active goal is back in motion."
                tone="sunken"
                action={
                  <View className="pt-1">
                    <Button onPress={() => navigation.navigate("GoalEdit", {})}>Start a goal</Button>
                  </View>
                }
              />
            ) : null}

            <Surface tone="hero" className="gap-4">
              <View className="flex-row flex-wrap gap-2">
                <Pill label={`${directionPortfolio.ambitions.length} ambitions`} tone="quiet" />
                <Pill label={`${activeGoals.length} active`} tone="accent" />
                {directionPortfolio.underrepresentedAmbitionIds.length > 0 ? (
                  <Pill
                    label={`${directionPortfolio.underrepresentedAmbitionIds.length} underrepresented`}
                    tone="neutral"
                  />
                ) : null}
                {unlinkedActiveGoals.length > 0 ? (
                  <Pill label={`${unlinkedActiveGoals.length} need direction`} tone="neutral" />
                ) : null}
              </View>
              <View className="gap-2.5">
                <AppText variant="title">Direction stays visible here.</AppText>
                <AppText tone="secondary" variant="caption">
                  {activeGoals.length === 0
                    ? "The direction layer is in place, but nothing active is moving yet."
                    : `${movingGoalCount} of ${activeGoals.length} active goals still show live movement. ${
                        linkedActiveGoalCount > 0
                          ? `${linkedActiveGoalCount} already serve a named ambition.`
                          : "Link the active goals to a bigger direction."
                      }`}
                </AppText>
              </View>
              <View className="flex-row flex-wrap gap-3">
                <SummaryTile
                  label="Direction"
                  value={`${linkedActiveGoalCount}/${Math.max(activeGoals.length, 1)}`}
                  detail="active goals already linked to a named ambition"
                />
                <SummaryTile
                  label="Moving"
                  value={String(movingGoalCount)}
                  detail="goals still carrying real momentum"
                />
                <SummaryTile
                  label="Attention"
                  value={String(attentionGoalCount + reviewGoalIds.size)}
                  detail="goals asking for a review, reset, or calmer room"
                />
              </View>
            </Surface>

            {directionPortfolio.ambitions.length > 0 ? (
              <View className="gap-3">
                <View className="gap-1">
                  <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                    Direction
                  </AppText>
                  <AppText variant="title">Direction portfolio</AppText>
                </View>
                <View className="gap-3">
                  {directionPortfolio.ambitions.map((ambitionTruth) => {
                    const ambition = uniqueAmbitions.find((entry) => entry.id === ambitionTruth.ambitionId);
                    if (!ambition) {
                      return null;
                    }

                    return (
                      <DirectionCard
                        key={ambition.id}
                        title={ambition.title}
                        thesis={ambition.thesis}
                        truth={ambitionTruth}
                        onPress={() => navigation.navigate("AmbitionDetail", { ambitionId: ambition.id })}
                      />
                    );
                  })}
                </View>
              </View>
            ) : null}

            <View className="gap-3">
              <View className="gap-1">
                <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                  Active goals
                </AppText>
                <AppText variant="title">Active portfolio</AppText>
              </View>
              {activeGoals.map((goal) => {
                const goalTruth = goalTruthById.get(goal.id);
                const reviewDraft = reviewGoalIds.has(goal.id) ? getGoalReviewDraft(goal) : null;
                const feasibility = describeGoalFeasibility(goal);
                const ambition = uniqueAmbitions.find((entry) => entry.id === goal.ambitionId) ?? null;
                const currentMilestone = currentMilestoneByGoalId.get(goal.id) ?? null;
                const nextTask = nextTaskByGoalId.get(goal.id) ?? null;
                const recentEvent = recentEventByGoalId.get(goal.id) ?? null;
                const timelineValue = goal.targetDate ? formatShortDate(goal.targetDate) : "No date";
                const phaseValue = currentMilestone?.title ?? "No phase yet";
                const phaseDetail = nextTask
                  ? `Next step: ${nextTask.title}`
                  : recentEvent
                    ? `Latest move: ${recentEvent.title}`
                    : "No immediate step is shaped yet";
                const currentWeekHours = goalTruth
                  ? Math.max(0, Math.round(goalTruth.currentWeekScheduledMinutes / 60))
                  : 0;
                const paceDetail = goalTruth?.crowded
                  ? "The work is crowding the room it has."
                  : goalTruth?.stale
                    ? "The goal has gone quiet recently."
                    : goalTruth?.representationSummary ?? "Open the current pace read.";
                const authoredRead = nextTask
                  ? `Next step: ${nextTask.title}`
                  : currentMilestone
                    ? `Current phase: ${currentMilestone.title}`
                    : goalTruth?.paceSummary ?? goal.summary ?? "Open the live read.";

                return (
                  <Surface key={goal.id} className="gap-4">
                    <View className="gap-2">
                      <View className="flex-row flex-wrap items-center justify-between gap-2">
                        <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                          {ambition ? ambition.title : "Direction not linked yet"}
                        </AppText>
                        <View className="flex-row flex-wrap gap-2">
                          {goalTruth ? (
                            <Pill label={goalTruth.paceLabel} tone={goalTruthTone(goalTruth)} />
                          ) : null}
                          {reviewDraft ? <Pill label="Review" tone="accent" /> : null}
                          {goalTruth?.crowded ? <Pill label="Crowded" tone="quiet" /> : null}
                          {goalTruth?.stale ? <Pill label="Quiet" tone="quiet" /> : null}
                          {!ambition ? <Pill label="Needs direction" tone="neutral" /> : null}
                        </View>
                      </View>
                      <View className="gap-1">
                        <AppText variant="section">{goal.title}</AppText>
                        <AppText tone="secondary" variant="caption">
                          {authoredRead}
                        </AppText>
                      </View>
                    </View>

                    <View className="flex-row flex-wrap gap-3">
                      <SummaryTile
                        label="Pace"
                        value={goalTruth?.paceLabel ?? "Open"}
                        detail={paceDetail}
                      />
                      <SummaryTile
                        label="Timeline"
                        value={timelineValue}
                        detail={
                          goalTruth?.deadlineSummary ??
                          feasibility?.summary ??
                          `${goal.horizon} horizon`
                        }
                      />
                      <SummaryTile
                        label="Phase"
                        value={phaseValue}
                        detail={phaseDetail}
                      />
                    </View>

                    <View className="flex-row flex-wrap gap-3">
                      <GoalSignalCard
                        title="This week"
                        detail={
                          goalTruth
                            ? `${currentWeekHours} hr planned. ${goalTruth.representationSummary}`
                            : "Open the current week read."
                        }
                        iconName="calendar-outline"
                      />
                      <GoalSignalCard
                        title="Deadline"
                        detail={
                          feasibility
                            ? `${feasibility.statusLabel}. ${feasibility.detail}`
                            : goal.targetDate
                              ? `Target ${formatShortDate(goal.targetDate)}`
                              : "Set a target when the goal is ready."
                        }
                        iconName="flag-outline"
                      />
                      <GoalSignalCard
                        title="Movement"
                        detail={
                          recentEvent
                            ? `${recentEvent.outcomeLabel ?? "Latest"}: ${recentEvent.title}`
                            : "Recent movement will appear here as work shifts."
                        }
                        iconName="pulse-outline"
                        highlighted={!!reviewDraft}
                      />
                    </View>

                    {goalTruth ? <CompactExplanationCard explanation={goalTruth.paceExplanation} /> : null}

                    <View className="flex-row items-center justify-between gap-3">
                      <Button
                        tone="inline"
                        size="compact"
                        onPress={() =>
                          ambition
                            ? navigation.navigate("AmbitionDetail", { ambitionId: ambition.id })
                            : navigation.navigate("GoalEdit", { goalId: goal.id })
                        }
                      >
                        {ambition ? "Open direction" : "Link direction"}
                      </Button>
                      <Button
                        tone="tertiary"
                        size="compact"
                        onPress={() => navigation.navigate("GoalDetail", { goalId: goal.id })}
                      >
                        Open goal
                      </Button>
                    </View>
                  </Surface>
                );
              })}
            </View>

            {unlinkedActiveGoals.length > 0 ? (
              <Surface className="gap-4">
                <View className="gap-1">
                  <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                    Follow-up
                  </AppText>
                  <AppText variant="title">Needs direction</AppText>
                </View>
                <AppText tone="secondary" variant="caption">
                  These goals are active already. This section only keeps the missing direction links obvious.
                </AppText>
                <View className="gap-3">
                  {unlinkedActiveGoals.map((goal) => (
                    <Surface key={goal.id} tone="sunken" className="gap-3 mb-0">
                      <View className="flex-row items-center justify-between gap-3">
                        <View className="flex-1 gap-1">
                          <AppText variant="section">{goal.title}</AppText>
                          <AppText tone="secondary" variant="caption">
                            Active, but still not tied to a bigger direction.
                          </AppText>
                        </View>
                        <Button
                          tone="tertiary"
                          size="compact"
                          onPress={() => navigation.navigate("GoalEdit", { goalId: goal.id })}
                        >
                          Link ambition
                        </Button>
                      </View>
                    </Surface>
                  ))}
                </View>
              </Surface>
            ) : null}

            {inactiveGoals.length > 0 ? (
              <Surface className="gap-4">
                <View className="gap-1">
                  <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                    Lower in rotation
                  </AppText>
                  <AppText variant="title">Inactive and archive context</AppText>
                </View>
                <View className="gap-3">
                  {inactiveGoals.slice(0, 4).map((goal) => (
                    <Surface key={goal.id} tone="sunken" className="gap-3 mb-0">
                      <View className="flex-row items-center justify-between gap-3">
                        <View className="flex-1 gap-1">
                          <AppText variant="section">{goal.title}</AppText>
                          <AppText tone="secondary" variant="caption">
                            {goal.summary ?? "Out of the active rotation"}
                          </AppText>
                        </View>
                        <View className="items-end gap-2">
                          <Pill label={goal.status} tone="quiet" />
                          <Button
                            tone="inline"
                            size="compact"
                            onPress={() => navigation.navigate("GoalDetail", { goalId: goal.id })}
                          >
                            Open
                          </Button>
                        </View>
                      </View>
                    </Surface>
                  ))}
                </View>
              </Surface>
            ) : null}
          </>
        )}
      </View>
    </Screen>
  );
}
