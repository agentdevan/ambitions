import { NativeStackScreenProps } from "@react-navigation/native-stack";
import { useEffect, useMemo, useState } from "react";
import { Modal, View } from "react-native";

import { ActivityTimelineRow, GroupedActivityTimeline, MomentumBars } from "../../components/history/ActivityTimeline";
import {
  CompactExplanationCard,
  DetailHero,
  DetailMetaGroup,
  DetailSection,
  DetailSummaryStrip,
  QuietMetaLine,
} from "../../components/detail/DetailPrimitives";
import { DrillInRow } from "../../components/navigation/DrillInRow";
import { Button } from "../../components/ui/Button";
import { EmptyStateCard } from "../../components/ui/EmptyStateCard";
import { MetricCard } from "../../components/ui/MetricCard";
import { OptionChip } from "../../components/ui/OptionChip";
import { Pill } from "../../components/ui/Pill";
import { Screen } from "../../components/ui/Screen";
import { SelectionCard } from "../../components/ui/SelectionCard";
import { Surface } from "../../components/ui/Surface";
import { AppText } from "../../components/ui/Text";
import { TextField } from "../../components/ui/TextField";
import { AmbitionStatus, Goal, GoalMilestoneStatus, GoalStatus, TaskStatus } from "../../domain/models";
import { GoalsStackParamList } from "../../navigation/types";
import { inferGoalDraft } from "../../product/goalIntake";
import { createGoalArtifacts } from "../../product/planOrchestrator";
import { GoalPaceMode, GoalStrategyComposer } from "../../product/types";
import { describeLifecycleOptions } from "../../services/goals/downstreamHandlingPolicies";
import { describeGoalFeasibility, describeGoalPaceMode, getGoalIntelligenceSnapshot } from "../../services/goals/goalIntelligence";
import { buildGoalProgressTruth } from "../../services/goals/progress";
import {
  GoalDownstreamChoice,
  GoalEditImpactPreview,
  GoalLifecycleHandling,
  getGoalReviewDraft,
  hasUserAdjustedMetadata,
} from "../../services/goals/metadata";
import { hasUndoAvailable } from "../../services/goals/regenerationCoordinator";
import {
  buildActivityFeed,
  buildMomentumSeries,
  groupActivityByDate,
  summarizeGoalProgress,
} from "../../services/history/selectors";
import { useAppStore } from "../../state/useAppStore";
import { formatShortDate } from "../../utils/date";

interface LifecycleDialogState {
  goal: Goal;
  status: GoalStatus.Paused | GoalStatus.Archived;
  handling: GoalLifecycleHandling;
}

function useGoalData(goalId: string) {
  const goals = useAppStore((state) => state.goals);
  const milestones = useAppStore((state) => state.milestones);
  const allTasks = useAppStore((state) => state.allTasks);

  const goal = goals.find((entry) => entry.id === goalId) ?? null;
  const goalMilestones = milestones
    .filter((milestone) => milestone.goalId === goalId)
    .sort((left, right) => left.sortOrder - right.sortOrder);
  const visibleTasks = allTasks
    .filter((task) => task.goalId === goalId && task.status !== TaskStatus.Cancelled)
    .sort((left, right) => left.createdAt.localeCompare(right.createdAt));

  return { goal, goalMilestones, visibleTasks };
}

function statusLabel(status: GoalStatus) {
  switch (status) {
    case GoalStatus.Active:
      return "Active";
    case GoalStatus.Paused:
      return "Paused";
    case GoalStatus.Completed:
      return "Completed";
    case GoalStatus.Archived:
      return "Archived";
    default:
      return "Draft";
  }
}

function milestoneStatusLabel(status: GoalMilestoneStatus) {
  switch (status) {
    case GoalMilestoneStatus.InProgress:
      return "In progress";
    case GoalMilestoneStatus.Completed:
      return "Completed";
    case GoalMilestoneStatus.Missed:
      return "Missed";
    case GoalMilestoneStatus.Archived:
      return "Archived";
    default:
      return "Pending";
  }
}

function paceChipTone(mode: GoalPaceMode) {
  if (mode === "aggressive") {
    return "accent" as const;
  }

  if (mode === "conservative") {
    return "quiet" as const;
  }

  return "neutral" as const;
}

function ambitionStatusLabel(status: AmbitionStatus) {
  switch (status) {
    case AmbitionStatus.Paused:
      return "Paused";
    case AmbitionStatus.Archived:
      return "Archived";
    default:
      return "Active";
  }
}

function paceTruthTone(
  paceState: "on_pace" | "slightly_off_pace" | "reset_needed" | "recovered" | "unrealistic",
) {
  if (paceState === "on_pace" || paceState === "recovered") {
    return "accent" as const;
  }

  if (paceState === "slightly_off_pace") {
    return "neutral" as const;
  }

  return "quiet" as const;
}

export function GoalDetailScreen({
  route,
  navigation,
}: NativeStackScreenProps<GoalsStackParamList, "GoalDetail">) {
  const { goal, goalMilestones, visibleTasks } = useGoalData(route.params.goalId);
  const ambitions = useAppStore((state) => state.ambitions);
  const activityEvents = useAppStore((state) => state.activityEvents);
  const timeBlocks = useAppStore((state) => state.allTimeBlocks);
  const currentWeekReview = useAppStore((state) => state.currentWeekReview);
  const currentMonthReview = useAppStore((state) => state.currentMonthReview);
  const updateGoal = useAppStore((state) => state.updateGoal);
  const setGoalStatusWithHandling = useAppStore((state) => state.setGoalStatusWithHandling);
  const undoGoalRegeneration = useAppStore((state) => state.undoGoalRegeneration);
  const [busyState, setBusyState] = useState<string | null>(null);
  const [runtimeMessage, setRuntimeMessage] = useState<string | null>(null);
  const [lifecycleState, setLifecycleState] = useState<LifecycleDialogState | null>(null);
  const resolvedGoal = goal;
  const reviewDraft = resolvedGoal ? getGoalReviewDraft(resolvedGoal) : null;
  const protectedTasks = visibleTasks.filter(
    (task) =>
      hasUserAdjustedMetadata(task) ||
      task.status === TaskStatus.Completed ||
      task.status === TaskStatus.InProgress,
  );
  const activeTasks = visibleTasks.filter((task) =>
    [TaskStatus.Ready, TaskStatus.Scheduled, TaskStatus.InProgress].includes(task.status),
  );
  const currentMilestone =
    goalMilestones.find((milestone) => milestone.status === GoalMilestoneStatus.InProgress) ??
    goalMilestones.find((milestone) => milestone.status === GoalMilestoneStatus.Pending) ??
    null;
  const intelligence = resolvedGoal ? getGoalIntelligenceSnapshot(resolvedGoal) : null;
  const feasibility = resolvedGoal ? describeGoalFeasibility(resolvedGoal) : null;
  const nextTask =
    activeTasks.find((task) => task.status === TaskStatus.InProgress) ??
    activeTasks.find((task) => task.status === TaskStatus.Scheduled) ??
    activeTasks[0] ??
    null;
  const ambition = resolvedGoal
    ? ambitions.find((entry) => entry.id === resolvedGoal.ambitionId) ?? null
    : null;

  if (!resolvedGoal) {
    return (
      <Screen>
        <EmptyStateCard title="Goal not found" body="That goal isn't available." />
      </Screen>
    );
  }
  const goalRecord: Goal = resolvedGoal;

  const activityFeed = buildActivityFeed(activityEvents, visibleTasks, goalMilestones).filter(
    (event) => event.goalId === goalRecord.id,
  );
  const progressSummary = summarizeGoalProgress({
    goal: goalRecord,
    milestones: goalMilestones,
    tasks: visibleTasks,
    events: activityFeed,
  });
  const progressTruth = buildGoalProgressTruth({
    goal: goalRecord,
    ambition,
    milestones: goalMilestones,
    tasks: visibleTasks,
    timeBlocks,
    activityFeed,
    currentWeekReview,
    currentMonthReview,
  });
  const momentumSeries = buildMomentumSeries(activityFeed, 7);
  const completedThisWeek = momentumSeries.reduce((sum, point) => sum + point.completed, 0);
  const reshapedThisWeek = momentumSeries.reduce((sum, point) => sum + point.reshaped, 0);
  const recentMovementLabel =
    progressSummary.recentEvents[0]?.outcomeLabel ??
    (progressTruth.stale ? "Quiet" : progressTruth.paceLabel);
  const nextMoveTitle = reviewDraft
    ? "Review pending changes"
    : nextTask?.title ?? currentMilestone?.title ?? "No next step shaped yet";
  const nextMoveDetail = reviewDraft
    ? reviewDraft.summary
    : nextTask
      ? currentMilestone
        ? `Current phase: ${currentMilestone.title}`
        : "Next scheduled task"
      : currentMilestone
        ? "Current milestone is defined, but the next task is not yet queued."
        : "The goal needs a clearer immediate move.";

  function openLifecycleDialog(status: GoalStatus.Paused | GoalStatus.Archived) {
    const options = describeLifecycleOptions(status === GoalStatus.Paused ? "pause" : "archive");
    setLifecycleState({
      goal: goalRecord,
      status,
      handling: options[0]?.key ?? "remove_from_active_plans",
    });
  }

  async function confirmLifecycleChange() {
    if (!lifecycleState) {
      return;
    }

    setBusyState(`status:${lifecycleState.goal.id}`);
    setRuntimeMessage(null);

    try {
      await setGoalStatusWithHandling(
        lifecycleState.goal.id,
        lifecycleState.status,
        lifecycleState.handling,
      );
      setLifecycleState(null);
    } catch (error) {
      setRuntimeMessage(
        error instanceof Error ? error.message : "The goal status could not be updated.",
      );
    } finally {
      setBusyState(null);
    }
  }

  async function handleUndo(goalId: string) {
    setBusyState(`undo:${goalId}`);
    setRuntimeMessage(null);

    try {
      await undoGoalRegeneration(goalId);
    } catch (error) {
      setRuntimeMessage(
        error instanceof Error ? error.message : "The previous regeneration could not be restored.",
      );
    } finally {
      setBusyState(null);
    }
  }

  return (
    <>
      <Screen>
        <View className="gap-6">
          <DetailHero
            eyebrow="Goal"
            title={resolvedGoal.title}
            description={nextMoveDetail}
            badges={
              <>
                <Pill label={statusLabel(resolvedGoal.status)} tone="quiet" />
                {reviewDraft ? <Pill label="Needs review" tone="accent" /> : null}
                <Pill label={progressTruth.paceLabel} tone={paceTruthTone(progressTruth.paceState)} />
                {intelligence ? (
                  <Pill
                    label={describeGoalPaceMode(intelligence.selectedPaceMode)}
                    tone={paceChipTone(intelligence.selectedPaceMode)}
                  />
                ) : null}
                {feasibility ? <Pill label={feasibility.statusLabel} tone="neutral" /> : null}
                {progressTruth.crowded ? <Pill label="Crowded" tone="quiet" /> : null}
                {progressTruth.stale ? <Pill label="Quiet" tone="quiet" /> : null}
              </>
            }
            meta={
              <DetailMetaGroup
                items={[
                  {
                    label: "Target",
                    value: resolvedGoal.targetDate ? formatShortDate(resolvedGoal.targetDate) : "No date",
                  },
                  {
                    label: "This week",
                    value: `${Math.round(progressTruth.currentWeekScheduledMinutes / 60)} hr`,
                  },
                  {
                    label: "Next move",
                    value: nextTask?.title ?? currentMilestone?.title ?? "Not shaped yet",
                  },
                  {
                    label: "Direction",
                    value: ambition?.title ?? "Not linked yet",
                  },
                  {
                    label: "Likelihood",
                    value: feasibility?.deadlineConfidence ?? "Not shaped yet",
                  },
                ]}
              />
            }
            action={
              <View className="flex-row gap-3">
                <Button style={{ flex: 1 }} onPress={() => navigation.navigate("GoalEdit", { goalId: resolvedGoal.id })}>
                  Edit goal
                </Button>
                <Button tone="secondary" style={{ flex: 1 }} onPress={() => navigation.navigate("GoalHistory", { goalId: resolvedGoal.id })}>
                  View history
                </Button>
              </View>
            }
          />

          <DetailSection
            title="This week"
            description="Pace, focus, and recent movement."
          >
            <View className="gap-4">
              <DetailSummaryStrip
                items={[
                  {
                    label: "Pace",
                    value: progressTruth.paceLabel,
                    detail:
                      progressTruth.crowded
                        ? "The work is crowding the room it has."
                        : progressTruth.stale
                          ? "The goal has gone quiet recently."
                          : progressTruth.representationSummary,
                  },
                  {
                    label: "Target",
                    value: resolvedGoal.targetDate ? formatShortDate(resolvedGoal.targetDate) : "No date",
                    detail:
                      progressTruth.deadlineSummary ??
                      feasibility?.detail ??
                      "Pace truth is grounded in recent execution.",
                  },
                  {
                    label: "This week",
                    value: `${Math.round(progressTruth.currentWeekScheduledMinutes / 60)} hr`,
                    detail: nextTask ? `Next: ${nextTask.title}` : "Nothing immediate is queued right now.",
                  },
                  {
                    label: "Recent",
                    value: recentMovementLabel,
                    detail:
                      progressSummary.recentEvents[0]?.title ??
                      "Movement will appear here as work gets completed or reshaped.",
                  },
                ]}
              />
              <Surface tone="sunken" className="gap-3 mb-0">
                <View className="flex-row items-center justify-between gap-3">
                  <View className="gap-1">
                    <AppText variant="section">Last 7 days</AppText>
                    <AppText tone="secondary" variant="caption">
                      {completedThisWeek > 0 || reshapedThisWeek > 0
                        ? `${completedThisWeek} completed, ${reshapedThisWeek} reshaped.`
                        : "No visible movement yet this week."}
                    </AppText>
                  </View>
                  <Pill label={`${progressTruth.activeTaskCount} in motion`} tone="quiet" />
                </View>
                <MomentumBars points={momentumSeries} />
              </Surface>
            </View>
          </DetailSection>

          <DetailSection
            title="Next meaningful move"
            description="The one thing to open next."
          >
            <Surface tone={reviewDraft || nextTask ? "accent" : "default"} className="gap-4 mb-0">
              <View className="gap-1.5">
                <AppText variant="section">{nextMoveTitle}</AppText>
                <AppText tone="secondary" variant="caption">
                  {nextMoveDetail}
                </AppText>
              </View>
              <View className="gap-3">
                {nextTask ? (
                  <DrillInRow
                    title={nextTask.title}
                    subtitle={
                      currentMilestone
                        ? `Inside ${currentMilestone.title}`
                        : "Current task at the front of the goal"
                    }
                    detail={`${nextTask.estimatedMinutes} min`}
                    onPress={() => navigation.navigate("GoalProgress", { goalId: resolvedGoal.id })}
                  />
                ) : null}
                <DrillInRow
                  title={currentMilestone?.title ?? "Shape the next phase"}
                  subtitle={
                    currentMilestone
                      ? "Current milestone"
                      : "Milestones help the direction feel tangible."
                  }
                  detail={`${goalMilestones.length} total`}
                  onPress={() => navigation.navigate("GoalMilestones", { goalId: resolvedGoal.id })}
                />
                {reviewDraft ? (
                  <DrillInRow
                    title="Review pending changes"
                    subtitle={reviewDraft.summary}
                    detail="Open review"
                    onPress={() =>
                      (navigation.getParent() as any)?.navigate("Plan", {
                        screen: "PlanReview",
                        params: { goalId: resolvedGoal.id },
                      })
                    }
                  />
                ) : null}
              </View>
            </Surface>
          </DetailSection>

          {intelligence ? (
            <DetailSection
              title="This month"
              description="Likelihood, workload, and pace health."
            >
              <View className="gap-4">
                <DetailSummaryStrip
                  items={[
                    {
                      label: "Pace",
                      value: describeGoalPaceMode(intelligence.selectedPaceMode),
                      detail: intelligence.paceOptions.find(
                        (option) => option.mode === intelligence.selectedPaceMode,
                      )?.summary,
                    },
                    {
                      label: "Deadline",
                      value: feasibility?.statusLabel ?? "Believable",
                      detail: intelligence.feasibility.detail,
                    },
                    {
                      label: "Capacity",
                      value: intelligence.availableCapacitySummary,
                      detail: intelligence.commitmentsSummary,
                    },
                    {
                      label: "Workload",
                      value: intelligence.workloadEstimateLabel,
                      detail: intelligence.interpretation.workPattern,
                    },
                  ]}
                />
                <Surface tone="sunken" className="gap-2 mb-0">
                  <AppText tone="secondary">{intelligence.feasibility.pacingTradeoff}</AppText>
                  {intelligence.feasibility.revisedDeadlineSuggestion ? (
                    <AppText tone="secondary">
                      A later target would be more believable:{" "}
                      {formatShortDate(intelligence.feasibility.revisedDeadlineSuggestion)}.
                    </AppText>
                  ) : null}
                  {intelligence.feasibility.lighterScopeSuggestion ? (
                    <AppText tone="secondary">
                      {intelligence.feasibility.lighterScopeSuggestion}
                    </AppText>
                  ) : null}
                </Surface>
              </View>
            </DetailSection>
          ) : null}

          <DetailSection
            title="Recent movement"
            description="Latest execution and plan changes."
            action={
              <Button
                tone="tertiary"
                size="compact"
                onPress={() => navigation.navigate("GoalHistory", { goalId: resolvedGoal.id })}
              >
                Full history
              </Button>
            }
          >
            {progressSummary.recentEvents.length === 0 ? (
              <Surface className="gap-2 mb-0">
                <AppText tone="secondary">
                  Recent history will start filling in as work is completed, moved, or reviewed.
                </AppText>
              </Surface>
            ) : (
              <Surface className="gap-0 mb-0">
                {progressSummary.recentEvents.slice(0, 3).map((event, index, array) => (
                  <ActivityTimelineRow
                    key={event.id}
                    item={event}
                    compact={index === array.length - 1}
                  />
                ))}
              </Surface>
            )}
          </DetailSection>

          <DetailSection
            title="Open more"
            description="Open the deeper views only when you need them."
          >
            <View className="gap-3">
              <DrillInRow
                title="Milestones"
                subtitle={
                  currentMilestone
                    ? `Current checkpoint: ${currentMilestone.title}`
                    : "Review the sequence shaping this goal."
                }
                detail={`${goalMilestones.length} total`}
                onPress={() => navigation.navigate("GoalMilestones", { goalId: resolvedGoal.id })}
              />
              <DrillInRow
                title="Progress"
                subtitle={progressTruth.paceSummary}
                detail={progressTruth.paceLabel}
                onPress={() => navigation.navigate("GoalProgress", { goalId: resolvedGoal.id })}
              />
              <DrillInRow
                title="History"
                subtitle="Completed, moved, reviewed"
                detail={`${activityFeed.length} events`}
                onPress={() => navigation.navigate("GoalHistory", { goalId: resolvedGoal.id })}
              />
              <DrillInRow
                title="Edit goal"
                subtitle="Update the goal definition"
                onPress={() => navigation.navigate("GoalEdit", { goalId: resolvedGoal.id })}
              />
              {reviewDraft ? (
                <DrillInRow
                  title="Review pending changes"
                  subtitle={reviewDraft.summary}
                  detail="Open review"
                  onPress={() =>
                    (navigation.getParent() as any)?.navigate("Plan", {
                      screen: "PlanReview",
                      params: { goalId: resolvedGoal.id },
                    })
                  }
                />
              ) : null}
            </View>
          </DetailSection>

          <Surface className="gap-4 mb-0">
            <View className="gap-1">
              <AppText variant="section">Goal definition</AppText>
            </View>
            <QuietMetaLine
              items={[
                resolvedGoal.successMetric
                  ? `Success: ${resolvedGoal.successMetric}`
                  : "No success metric",
                resolvedGoal.horizon,
                resolvedGoal.type,
                resolvedGoal.domainKey.replaceAll("_", " "),
              ]}
            />
            {resolvedGoal.notes ? <AppText tone="secondary">{resolvedGoal.notes}</AppText> : null}
          </Surface>

          <Surface className="gap-4 mb-0">
            <View className="gap-1">
              <AppText variant="section">Actions</AppText>
            </View>
            <Button onPress={() => navigation.navigate("GoalEdit", { goalId: resolvedGoal.id })}>
              Edit goal
            </Button>
            <View className="flex-row flex-wrap gap-3">
              {resolvedGoal.status === GoalStatus.Active ? (
                <Button
                  tone="secondary"
                  onPress={() => openLifecycleDialog(GoalStatus.Paused)}
                  busy={busyState === `status:${resolvedGoal.id}`}
                >
                  Pause goal
                </Button>
              ) : (
                <Button
                  tone="secondary"
                  onPress={() => void updateGoal(resolvedGoal.id, { status: GoalStatus.Active })}
                  busy={busyState === `status:${resolvedGoal.id}`}
                >
                  Resume goal
                </Button>
              )}
              {reviewDraft ? (
                <Button
                  tone="tertiary"
                  onPress={() =>
                    (navigation.getParent() as any)?.navigate("Plan", {
                      screen: "PlanReview",
                      params: { goalId: resolvedGoal.id },
                    })
                  }
                >
                  Review changes
                </Button>
              ) : null}
              <Button
                tone="tertiary"
                onPress={() => openLifecycleDialog(GoalStatus.Archived)}
                busy={busyState === `status:${resolvedGoal.id}`}
              >
                Archive
              </Button>
              {hasUndoAvailable(resolvedGoal) ? (
                <Button
                  tone="tertiary"
                  onPress={() => void handleUndo(resolvedGoal.id)}
                  busy={busyState === `undo:${resolvedGoal.id}`}
                >
                  Undo refresh
                </Button>
              ) : null}
            </View>
          </Surface>

          {runtimeMessage ? (
            <AppText tone="tertiary" variant="caption">
              {runtimeMessage}
            </AppText>
          ) : null}
        </View>
      </Screen>

      <Modal
        transparent
        animationType="fade"
        visible={lifecycleState !== null}
        onRequestClose={() => setLifecycleState(null)}
      >
        <View
          className="flex-1 items-center justify-center px-5"
          style={{ backgroundColor: "rgba(16, 18, 22, 0.22)" }}
        >
          <Surface style={{ width: "100%" }}>
            <View className="gap-4">
              <AppText variant="title">
                {lifecycleState?.status === GoalStatus.Paused ? "Pause goal" : "Archive goal"}
              </AppText>
              <AppText tone="secondary">
                Choose what happens to downstream work before this goal leaves the main rotation.
              </AppText>
              <View className="gap-2">
                {lifecycleState
                  ? describeLifecycleOptions(
                      lifecycleState.status === GoalStatus.Paused ? "pause" : "archive",
                    ).map((option) => (
                      <OptionChip
                        key={option.key}
                        selected={lifecycleState.handling === option.key}
                        onPress={() =>
                          setLifecycleState((current) =>
                            current ? { ...current, handling: option.key } : current,
                          )
                        }
                      >
                        {option.label}
                      </OptionChip>
                    ))
                  : null}
              </View>
              <View className="flex-row gap-3">
                <Button tone="tertiary" style={{ flex: 1 }} onPress={() => setLifecycleState(null)}>
                  Cancel
                </Button>
                <Button
                  style={{ flex: 1 }}
                  onPress={() => void confirmLifecycleChange()}
                  busy={lifecycleState ? busyState === `status:${lifecycleState.goal.id}` : false}
                >
                  Confirm
                </Button>
              </View>
            </View>
          </Surface>
        </View>
      </Modal>
    </>
  );
}

export function GoalMilestonesScreen({
  route,
}: NativeStackScreenProps<GoalsStackParamList, "GoalMilestones">) {
  const { goal, goalMilestones, visibleTasks } = useGoalData(route.params.goalId);

  if (!goal) {
    return (
      <Screen>
        <EmptyStateCard title="Goal not found" body="That goal isn't available." />
      </Screen>
    );
  }

  const completedCount = goalMilestones.filter(
    (milestone) => milestone.status === GoalMilestoneStatus.Completed,
  ).length;

  return (
    <Screen>
      <View className="gap-6">
        <DetailHero
          eyebrow="Goal"
          title="Milestones"
          description="Checkpoints shaping the goal."
          meta={
            <DetailSummaryStrip
              items={[
                {
                  label: "Completed",
                  value: `${completedCount}/${goalMilestones.length}`,
                  detail: "Milestones finished",
                },
                {
                  label: "Work items",
                  value: String(visibleTasks.length),
                  detail: "Tasks attached to this goal",
                },
              ]}
            />
          }
        />
        {goalMilestones.length === 0 ? (
          <EmptyStateCard
            title="No milestones yet"
            body="Milestones aren't active yet."
          />
        ) : (
          <View className="gap-3">
            {goalMilestones.map((milestone, index) => {
              const milestoneTasks = visibleTasks.filter(
                (task) => task.milestoneId === milestone.id,
              );

              return (
                <Surface key={milestone.id} className="gap-3 mb-0">
                  <View className="flex-row flex-wrap items-center gap-2">
                    <Pill label={milestoneStatusLabel(milestone.status)} tone="quiet" />
                    {hasUserAdjustedMetadata(milestone) ? (
                      <Pill label="Protected" tone="accent" />
                    ) : null}
                    <AppText tone="tertiary" variant="caption">
                      Step {index + 1}
                    </AppText>
                  </View>
                  <View className="gap-1">
                    <AppText variant="section">{milestone.title}</AppText>
                    <AppText tone="secondary">
                      {milestone.summary ?? "This milestone anchors a section of the goal."}
                    </AppText>
                  </View>
                  <QuietMetaLine
                    items={[
                      milestone.targetDate
                        ? `Target ${formatShortDate(milestone.targetDate)}`
                        : "No target date",
                      milestone.estimatedMinutes
                        ? `${milestone.estimatedMinutes} planned min`
                        : "No time estimate",
                      `${milestoneTasks.length} linked task${
                        milestoneTasks.length === 1 ? "" : "s"
                      }`,
                    ]}
                  />
                </Surface>
              );
            })}
          </View>
        )}
      </View>
    </Screen>
  );
}

export function GoalProgressScreen({
  route,
  navigation,
}: NativeStackScreenProps<GoalsStackParamList, "GoalProgress">) {
  const { goal, visibleTasks } = useGoalData(route.params.goalId);
  const ambitions = useAppStore((state) => state.ambitions);
  const milestones = useAppStore((state) => state.milestones.filter((entry) => entry.goalId === route.params.goalId));
  const activityEvents = useAppStore((state) => state.activityEvents);
  const timeBlocks = useAppStore((state) => state.allTimeBlocks);
  const currentWeekReview = useAppStore((state) => state.currentWeekReview);
  const currentMonthReview = useAppStore((state) => state.currentMonthReview);

  if (!goal) {
    return (
      <Screen>
        <EmptyStateCard title="Goal not found" body="That goal isn't available." />
      </Screen>
    );
  }

  const activeTasks = visibleTasks.filter((task) =>
    [TaskStatus.Ready, TaskStatus.Scheduled, TaskStatus.InProgress].includes(task.status),
  );
  const protectedTasks = visibleTasks.filter((task) => hasUserAdjustedMetadata(task));
  const activityFeed = buildActivityFeed(activityEvents, visibleTasks, milestones).filter(
    (event) => event.goalId === goal.id,
  );
  const groupedActivity = groupActivityByDate(activityFeed.slice(0, 10));
  const ambition = ambitions.find((entry) => entry.id === goal.ambitionId) ?? null;
  const progressSummary = summarizeGoalProgress({
    goal,
    milestones,
    tasks: visibleTasks,
    events: activityFeed,
  });
  const progressTruth = buildGoalProgressTruth({
    goal,
    ambition,
    milestones,
    tasks: visibleTasks,
    timeBlocks,
    activityFeed,
    currentWeekReview,
    currentMonthReview,
  });
  const momentum = buildMomentumSeries(activityFeed, 7);

  return (
    <Screen>
      <View className="gap-6">
        <DetailHero
          eyebrow="Goal"
          title="Progress"
          description={progressTruth.paceSummary}
          meta={
            <DetailSummaryStrip
              items={[
                {
                  label: "Pace",
                  value: progressTruth.paceLabel,
                  detail: progressTruth.deadlineSummary ?? "Grounded in deadline and execution truth.",
                },
                {
                  label: "This week",
                  value: `${Math.round(progressTruth.currentWeekScheduledMinutes / 60)} hr`,
                  detail: progressTruth.representationSummary,
                },
                {
                  label: "Protected",
                  value: String(protectedTasks.length),
                  detail: ambition ? `Serves ${ambition.title}` : "No ambition linked yet",
                },
              ]}
            />
          }
        />

        <DetailSection
          title="Truth read"
          description="Movement, realism, and representation in one path."
        >
          <Surface className="mb-0 gap-3">
            <AppText>{progressTruth.paceSummary}</AppText>
            <QuietMetaLine
              items={[
                `${Math.round(progressTruth.currentMonthScheduledMinutes / 60)} hr this month`,
                progressTruth.crowded ? "Crowded" : "Not crowded",
                progressTruth.stale ? "Recently stale" : "Still active",
              ]}
            />
            <AppText tone="secondary">{progressTruth.representationSummary}</AppText>
          </Surface>
        </DetailSection>

        <DetailSection
          title="Momentum"
          description="Last 7 days."
          action={
            <Button tone="tertiary" size="compact" onPress={() => navigation.navigate("GoalHistory", { goalId: goal.id })}>
              View history
            </Button>
          }
        >
          <Surface className="gap-4 mb-0">
            <MomentumBars points={momentum} />
            <QuietMetaLine
              items={[
                `${progressSummary.completedTasks} completed total`,
                `${progressSummary.carryTasks} carried or moved`,
                `${progressSummary.completedMilestones}/${progressSummary.milestoneCount} milestones completed`,
              ]}
            />
          </Surface>
        </DetailSection>

        {visibleTasks.length === 0 ? (
          <EmptyStateCard
            title="No active tasks"
            body="No task detail yet."
          />
        ) : (
          <>
            <DetailSection
              title="Current work"
              description="What matters now."
            >
              <View className="gap-3">
                {activeTasks.length === 0 ? (
                  <Surface className="gap-2 mb-0">
                    <AppText tone="secondary">
                      Nothing is currently in active rotation for this goal.
                    </AppText>
                  </Surface>
                ) : (
                  activeTasks.map((task) => (
                    <Surface key={task.id} className="gap-2 mb-0">
                      <AppText variant="section">{task.title}</AppText>
                      <QuietMetaLine
                        items={[
                          `${task.estimatedMinutes} min`,
                          task.targetDate
                            ? `Target ${formatShortDate(task.targetDate)}`
                            : "No target date",
                          task.status.replaceAll("_", " "),
                        ]}
                      />
                      {task.summary ? <AppText tone="secondary">{task.summary}</AppText> : null}
                    </Surface>
                  ))
                )}
              </View>
            </DetailSection>

            {protectedTasks.length > 0 ? (
              <DetailSection
                title="Protected work"
                description="Items you already shaped."
              >
                <View className="gap-3">
                  {protectedTasks.map((task) => (
                    <Surface key={task.id} className="gap-2 mb-0">
                      <View className="flex-row flex-wrap items-center gap-2">
                        <Pill label="Protected" tone="accent" />
                        <AppText variant="section">{task.title}</AppText>
                      </View>
                      <QuietMetaLine
                        items={[
                          `${task.estimatedMinutes} min`,
                          task.status.replaceAll("_", " "),
                        ]}
                      />
                    </Surface>
                  ))}
                </View>
              </DetailSection>
            ) : null}

            <DetailSection
              title="Recent movement"
              description="Latest execution and plan changes."
            >
              <GroupedActivityTimeline
                groups={groupedActivity}
                emptyTitle="No recent movement"
                emptyBody="No recent movement yet."
              />
            </DetailSection>
          </>
        )}
      </View>
    </Screen>
  );
}

export function GoalHistoryScreen({
  route,
}: NativeStackScreenProps<GoalsStackParamList, "GoalHistory">) {
  const { goal, goalMilestones, visibleTasks } = useGoalData(route.params.goalId);
  const activityEvents = useAppStore((state) => state.activityEvents);
  const adaptationProfile = useAppStore((state) => state.adaptationProfile);
  const productPreferences = useAppStore((state) => state.productPreferences);

  if (!goal) {
    return (
      <Screen>
        <EmptyStateCard title="Goal not found" body="That goal isn't available." />
      </Screen>
    );
  }

  const activityFeed = buildActivityFeed(activityEvents, visibleTasks, goalMilestones).filter(
    (event) => event.goalId === goal.id,
  );
  const groupedActivity = groupActivityByDate(activityFeed);
  const progressSummary = summarizeGoalProgress({
    goal,
    milestones: goalMilestones,
    tasks: visibleTasks,
    events: activityFeed,
    profile: adaptationProfile,
    adaptiveEnabled: productPreferences?.adaptivePlanningEnabled !== false,
  });

  return (
    <Screen>
      <View className="gap-6">
        <DetailHero
          eyebrow="Goal"
          title="History"
          description={progressSummary.reflection}
          meta={
            <DetailMetaGroup
              items={[
                { label: "Completed tasks", value: String(progressSummary.completedTasks) },
                { label: "Carryover", value: String(progressSummary.carryTasks) },
                {
                  label: "Milestones",
                  value: `${progressSummary.completedMilestones}/${progressSummary.milestoneCount}`,
                },
                { label: "Events", value: String(activityFeed.length) },
              ]}
            />
          }
        />

        <GroupedActivityTimeline
          groups={groupedActivity}
          emptyTitle="No goal history yet"
          emptyBody="History will appear here."
        />
      </View>
    </Screen>
  );
}

export function GoalEditScreen({
  route,
  navigation,
}: NativeStackScreenProps<GoalsStackParamList, "GoalEdit">) {
  const ambitions = useAppStore((state) => state.ambitions);
  const goals = useAppStore((state) => state.goals);
  const domains = useAppStore((state) => state.domains);
  const planDate = useAppStore((state) => state.planDate);
  const productPreferences = useAppStore((state) => state.productPreferences);
  const userPreferences = useAppStore((state) => state.userPreferences);
  const adaptationProfile = useAppStore((state) => state.adaptationProfile);
  const createAmbition = useAppStore((state) => state.createAmbition);
  const createGoal = useAppStore((state) => state.createGoal);
  const updateGoal = useAppStore((state) => state.updateGoal);
  const previewGoalEdit = useAppStore((state) => state.previewGoalEdit);
  const applyGoalEditDecision = useAppStore((state) => state.applyGoalEditDecision);
  const goal = goals.find((entry) => entry.id === route.params?.goalId) ?? null;
  const [draftText, setDraftText] = useState("");
  const [manualTitle, setManualTitle] = useState(goal?.title ?? "");
  const [manualSummary, setManualSummary] = useState(goal?.summary ?? "");
  const [manualTargetDate, setManualTargetDate] = useState(goal?.targetDate ?? "");
  const [manualDomainKey, setManualDomainKey] = useState<Goal["domainKey"] | null>(
    goal?.domainKey ?? null,
  );
  const [manualSuccessMetric, setManualSuccessMetric] = useState(goal?.successMetric ?? "");
  const [manualNotes, setManualNotes] = useState(goal?.notes ?? "");
  const [manualDesiredWeeklyMinutes, setManualDesiredWeeklyMinutes] = useState(
    goal?.desiredWeeklyMinutes ? String(goal.desiredWeeklyMinutes) : "",
  );
  const [selectedAmbitionId, setSelectedAmbitionId] = useState<string | null>(goal?.ambitionId ?? null);
  const [creatingAmbition, setCreatingAmbition] = useState(false);
  const [newAmbitionTitle, setNewAmbitionTitle] = useState("");
  const [newAmbitionThesis, setNewAmbitionThesis] = useState("");
  const [selectedPaceMode, setSelectedPaceMode] = useState<GoalPaceMode>("balanced");
  const [paceSelectionSource, setPaceSelectionSource] = useState<"auto" | "manual">("auto");
  const [strategyComposer, setStrategyComposer] = useState<GoalStrategyComposer | null>(null);
  const [strategyPreviewBusy, setStrategyPreviewBusy] = useState(false);
  const [busyState, setBusyState] = useState<string | null>(null);
  const [runtimeMessage, setRuntimeMessage] = useState<string | null>(null);
  const [pendingEditPatch, setPendingEditPatch] = useState<Partial<Goal> | null>(null);
  const [impactPreview, setImpactPreview] = useState<GoalEditImpactPreview | null>(null);
  const [downstreamChoice, setDownstreamChoice] =
    useState<GoalDownstreamChoice>("targeted_regeneration");

  useEffect(() => {
    if (!goal) {
      return;
    }

    setManualTitle(goal.title);
    setManualSummary(goal.summary ?? "");
    setManualTargetDate(goal.targetDate ?? "");
    setManualDomainKey(goal.domainKey);
    setManualSuccessMetric(goal.successMetric ?? "");
    setManualNotes(goal.notes ?? "");
    setManualDesiredWeeklyMinutes(goal.desiredWeeklyMinutes ? String(goal.desiredWeeklyMinutes) : "");
    setSelectedAmbitionId(goal.ambitionId ?? null);
    setCreatingAmbition(false);
  }, [goal]);

  const inference = useMemo(
    () => (draftText.trim().length > 0 ? inferGoalDraft(draftText, planDate) : null),
    [draftText, planDate],
  );

  useEffect(() => {
    if (!goal && inference) {
      setPaceSelectionSource("auto");
    }
  }, [goal, inference]);

  const composedInference = useMemo(() => {
    if (!inference) {
      return null;
    }

    return {
      ...inference,
      ambitionId: selectedAmbitionId,
      title: manualTitle.trim() || inference.title,
      summary: manualSummary.trim() || inference.summary,
      targetDate: manualTargetDate.trim() || inference.targetDate,
      domainKey: manualDomainKey ?? inference.domainKey,
      successMetric: manualSuccessMetric.trim() || inference.successMetric,
      notes: manualNotes.trim() || inference.notes,
      desiredWeeklyMinutes:
        manualDesiredWeeklyMinutes.trim().length > 0
          ? Number(manualDesiredWeeklyMinutes)
          : inference.desiredWeeklyMinutes,
      paceMode: selectedPaceMode,
    };
  }, [
    inference,
    manualDesiredWeeklyMinutes,
    manualDomainKey,
    manualNotes,
    manualSuccessMetric,
    manualSummary,
    manualTargetDate,
    manualTitle,
    selectedAmbitionId,
    selectedPaceMode,
  ]);

  useEffect(() => {
    let cancelled = false;

    if (goal || !composedInference || !userPreferences || !productPreferences) {
      setStrategyComposer(null);
      setStrategyPreviewBusy(false);
      return () => {
        cancelled = true;
      };
    }

    setStrategyPreviewBusy(true);
    createGoalArtifacts({
      inference: composedInference,
      productPreferences,
      currentPreferences: userPreferences,
      today: planDate,
      adaptationProfile,
    })
      .then((artifacts) => {
        if (!cancelled) {
          setStrategyComposer(artifacts.composer);
        }
      })
      .catch(() => {
        if (!cancelled) {
          setStrategyComposer(null);
        }
      })
      .finally(() => {
        if (!cancelled) {
          setStrategyPreviewBusy(false);
        }
      });

    return () => {
      cancelled = true;
    };
  }, [adaptationProfile, composedInference, goal, planDate, productPreferences, userPreferences]);

  useEffect(() => {
    if (!goal && strategyComposer && paceSelectionSource === "auto") {
      setSelectedPaceMode(strategyComposer.recommendedPaceMode);
    }
  }, [goal, paceSelectionSource, strategyComposer]);

  function buildGoalPatch(existingGoal: Goal | null) {
    if (!existingGoal) {
      return null;
    }

    return {
      title: manualTitle.trim() || existingGoal.title,
      ambitionId: selectedAmbitionId,
      summary: manualSummary.trim() || null,
      targetDate: manualTargetDate.trim() || null,
      domainKey: manualDomainKey ?? existingGoal.domainKey,
      successMetric: manualSuccessMetric.trim() || null,
      notes: manualNotes.trim() || null,
      desiredWeeklyMinutes:
        manualDesiredWeeklyMinutes.trim().length > 0
          ? Number(manualDesiredWeeklyMinutes)
          : null,
    } satisfies Partial<Goal>;
  }

  async function resolveAmbitionId() {
    if (!creatingAmbition) {
      return selectedAmbitionId;
    }

    const title = newAmbitionTitle.trim();
    if (!title) {
      throw new Error("A new ambition needs a title.");
    }

    const ambition = await createAmbition({
      title,
      thesis: newAmbitionThesis,
      status: AmbitionStatus.Active,
    });
    setSelectedAmbitionId(ambition.id);
    setCreatingAmbition(false);
    return ambition.id;
  }

  async function handleCreate() {
    if (!composedInference) {
      return;
    }

    setBusyState("create");
    setRuntimeMessage(null);

    try {
      const ambitionId = await resolveAmbitionId();
      await createGoal({ ...composedInference, ambitionId });
      const latestGoal = [...useAppStore.getState().goals].sort((left, right) =>
        right.createdAt.localeCompare(left.createdAt),
      )[0];
      if (latestGoal) {
        navigation.replace("GoalDetail", { goalId: latestGoal.id });
      } else {
        navigation.goBack();
      }
    } catch (error) {
      setRuntimeMessage(error instanceof Error ? error.message : "The goal could not be created.");
    } finally {
      setBusyState(null);
    }
  }

  async function handleUpdate() {
    if (!goal) {
      return;
    }

    const patch = buildGoalPatch(goal);
    if (!patch) {
      return;
    }

    setBusyState("update");
    setRuntimeMessage(null);

    try {
      patch.ambitionId = await resolveAmbitionId();
      const impact = await previewGoalEdit(goal.id, patch);
      if (!impact.hasDownstream || impact.changedFields.length === 0) {
        await updateGoal(goal.id, patch);
        navigation.goBack();
      } else {
        setPendingEditPatch(patch);
        setImpactPreview(impact);
        setDownstreamChoice(impact.recommendation);
      }
    } catch (error) {
      setRuntimeMessage(
        error instanceof Error ? error.message : "The goal changes could not be saved.",
      );
    } finally {
      setBusyState(null);
    }
  }

  async function confirmGoalEdit() {
    if (!goal || !pendingEditPatch) {
      return;
    }

    setBusyState("impact");
    setRuntimeMessage(null);

    try {
      await applyGoalEditDecision(goal.id, pendingEditPatch, downstreamChoice);
      setImpactPreview(null);
      setPendingEditPatch(null);
      navigation.goBack();
    } catch (error) {
      setRuntimeMessage(
        error instanceof Error ? error.message : "The goal changes could not be applied.",
      );
    } finally {
      setBusyState(null);
    }
  }

  return (
    <>
      <Screen>
        <View className="gap-6">
          <DetailHero
            eyebrow="Goal"
            title={goal ? "Refine the goal" : "Add a goal"}
            description={
              goal
                ? "Update the definition before it lands."
                : "Describe the outcome. Ambitions builds the first draft."
            }
          />

          {!goal ? (
            <Surface className="gap-3 mb-0">
              <AppText variant="section">Start with the goal</AppText>
              <TextField
                multiline
                onChangeText={setDraftText}
                placeholder="Build a focused TypeScript systems study plan over the next six weeks."
                value={draftText}
              />
              {inference ? (
                <QuietMetaLine
                  items={[
                    inference.domainKey.replace("_", " "),
                    inference.type,
                    inference.horizon,
                  ]}
                />
              ) : null}
            </Surface>
          ) : null}

          <DetailSection
            title="Core definition"
            description="What this goal is."
          >
            <Surface className="gap-4 mb-0">
              <TextField
                onChangeText={setManualTitle}
                placeholder="Goal title"
                label="Title"
                value={manualTitle}
              />
              <TextField
                onChangeText={setManualSummary}
                placeholder="Short goal summary"
                label="Summary"
                multiline
                value={manualSummary}
              />
              <TextField
                onChangeText={setManualSuccessMetric}
                placeholder="Success measure"
                label="Success metric"
                value={manualSuccessMetric}
              />
              <TextField
                onChangeText={setManualNotes}
                placeholder="Notes that should shape the goal."
                label="Notes"
                multiline
                value={manualNotes}
              />
            </Surface>
          </DetailSection>

          <DetailSection
            title="Ambition"
            description="What bigger direction this goal serves."
          >
            <Surface className="gap-4 mb-0">
              <View className="flex-row flex-wrap gap-2">
                <OptionChip
                  selected={!creatingAmbition && selectedAmbitionId === null}
                  onPress={() => {
                    setCreatingAmbition(false);
                    setSelectedAmbitionId(null);
                  }}
                >
                  None yet
                </OptionChip>
                {ambitions
                  .filter((ambition) => ambition.status !== AmbitionStatus.Archived)
                  .map((ambition) => (
                    <OptionChip
                      key={ambition.id}
                      selected={!creatingAmbition && selectedAmbitionId === ambition.id}
                      onPress={() => {
                        setCreatingAmbition(false);
                        setSelectedAmbitionId(ambition.id);
                      }}
                    >
                      {ambition.title}
                    </OptionChip>
                  ))}
                <OptionChip
                  selected={creatingAmbition}
                  onPress={() => {
                    setCreatingAmbition(true);
                    setSelectedAmbitionId(null);
                  }}
                >
                  New ambition
                </OptionChip>
              </View>

              {creatingAmbition ? (
                <View className="gap-4">
                  <TextField
                    label="Ambition title"
                    value={newAmbitionTitle}
                    onChangeText={setNewAmbitionTitle}
                    placeholder="Build a steadier creative season"
                  />
                  <TextField
                    label="Direction note"
                    value={newAmbitionThesis}
                    onChangeText={setNewAmbitionThesis}
                    multiline
                    placeholder="What this direction is trying to protect or build."
                  />
                </View>
              ) : null}
            </Surface>
          </DetailSection>

          <DetailSection
            title="Timing and pacing"
            description="Timing and pace."
          >
            <Surface className="gap-4 mb-0">
              <TextField
                onChangeText={setManualTargetDate}
                placeholder="YYYY-MM-DD"
                label="Target date"
                value={manualTargetDate}
              />
              <TextField
                onChangeText={setManualDesiredWeeklyMinutes}
                placeholder="120"
                label="Target minutes per week"
                keyboardType="numeric"
                value={manualDesiredWeeklyMinutes}
              />
            </Surface>
          </DetailSection>

          <DetailSection
            title="Domain"
            description="Choose the area."
          >
            <Surface className="gap-3 mb-0">
              <View className="flex-row flex-wrap gap-2">
                {domains.map((domain) => {
                  const key = manualDomainKey ?? inference?.domainKey ?? goal?.domainKey;
                  return (
                    <OptionChip
                      key={`domain-select-${domain.id}`}
                      selected={key === domain.key}
                      onPress={() => setManualDomainKey(domain.key)}
                    >
                      {domain.name}
                    </OptionChip>
                  );
                })}
              </View>
            </Surface>
          </DetailSection>

          {!goal && composedInference ? (
            <DetailSection
              title="Strategy read"
              description="One calm recommendation first."
            >
              <Surface className="gap-4 mb-0">
                {strategyPreviewBusy || !strategyComposer ? (
                  <AppText tone="secondary">
                    Building a believable first strategy.
                  </AppText>
                ) : (
                  <>
                    <View className="gap-2">
                      <View className="flex-row flex-wrap items-center gap-2">
                        <Pill label={strategyComposer.feasibility.deadlineConfidence} tone="quiet" />
                        <Pill
                          label={describeGoalPaceMode(strategyComposer.recommendedPaceMode)}
                          tone="neutral"
                        />
                      </View>
                      <AppText variant="section">{strategyComposer.feasibility.summary}</AppText>
                      <AppText tone="secondary">{strategyComposer.feasibility.detail}</AppText>
                    </View>

                    <View className="flex-row flex-wrap gap-3">
                      <MetricCard
                        label="Capacity"
                        value={strategyComposer.availableCapacitySummary}
                        detail={strategyComposer.commitmentsSummary}
                      />
                      <MetricCard
                        label="Workload"
                        value={strategyComposer.workloadEstimateLabel}
                        detail={strategyComposer.interpretation.workloadShape}
                      />
                    </View>

                    <Surface tone="sunken" className="gap-3 mb-0">
                      <AppText variant="section">Interpreted goal</AppText>
                      <QuietMetaLine
                        items={[
                          strategyComposer.interpretation.domainLabel,
                          strategyComposer.interpretation.categoryLabel,
                          strategyComposer.interpretation.workPattern,
                          strategyComposer.interpretation.timingLabel,
                        ]}
                      />
                      <AppText tone="secondary">
                        {strategyComposer.behaviorSummary}
                      </AppText>
                    </Surface>

                    <View className="gap-3">
                      <AppText variant="section">Choose the pace</AppText>
                      {strategyComposer.paceOptions.map((option) => (
                        <SelectionCard
                          key={option.mode}
                          selected={selectedPaceMode === option.mode}
                          eyebrow={option.recommended ? "Recommended" : undefined}
                          onPress={() => {
                            setPaceSelectionSource("manual");
                            setSelectedPaceMode(option.mode);
                          }}
                          trailing={<Pill label={option.deadlineConfidence} tone={paceChipTone(option.mode)} />}
                        >
                          <View className="gap-2">
                            <View className="flex-row flex-wrap items-center gap-2">
                              <AppText variant="section">{option.label}</AppText>
                              <Pill label={`${option.weeklyHours} hr/week`} tone="quiet" />
                              <Pill label={`${option.sessionCount} sessions`} tone="quiet" />
                            </View>
                            <AppText tone="secondary">{option.summary}</AppText>
                            <QuietMetaLine
                              items={[
                                option.taskSizing,
                                option.riskLevel,
                                option.adaptationBehavior,
                              ]}
                            />
                          </View>
                        </SelectionCard>
                      ))}
                    </View>

                    {strategyComposer.feasibility.revisedDeadlineSuggestion ? (
                      <Surface tone="sunken" className="gap-2 mb-0">
                        <AppText variant="section">More believable version</AppText>
                        <AppText tone="secondary">
                          {strategyComposer.feasibility.revisedDeadlineReason} Try {formatShortDate(
                            strategyComposer.feasibility.revisedDeadlineSuggestion,
                          )} instead.
                        </AppText>
                        {strategyComposer.feasibility.lighterScopeSuggestion ? (
                          <AppText tone="secondary">
                            {strategyComposer.feasibility.lighterScopeSuggestion}
                          </AppText>
                        ) : null}
                      </Surface>
                    ) : null}

                    <View className="gap-3">
                      <AppText variant="section">First path</AppText>
                      {strategyComposer.firstMilestonePath.map((milestone) => (
                        <Surface key={milestone.title} tone="sunken" className="gap-1.5 mb-0">
                          <AppText variant="section">{milestone.title}</AppText>
                          {milestone.summary ? (
                            <AppText tone="secondary">{milestone.summary}</AppText>
                          ) : null}
                          {milestone.targetDate ? (
                            <AppText tone="tertiary" variant="caption">
                              {formatShortDate(milestone.targetDate)}
                            </AppText>
                          ) : null}
                        </Surface>
                      ))}
                    </View>

                    <View className="gap-3">
                      <AppText variant="section">First week preview</AppText>
                      {strategyComposer.firstWeekActionPreview.map((task) => (
                        <Surface key={task.title} tone="sunken" className="gap-1.5 mb-0">
                          <AppText variant="section">{task.title}</AppText>
                          {task.summary ? <AppText tone="secondary">{task.summary}</AppText> : null}
                          <QuietMetaLine
                            items={[
                              `${task.estimatedMinutes} min`,
                              task.targetDate ? formatShortDate(task.targetDate) : "No date yet",
                            ]}
                          />
                        </Surface>
                      ))}
                    </View>
                  </>
                )}
              </Surface>
            </DetailSection>
          ) : null}

          <Surface className="gap-4 mb-0">
            <View className="gap-1">
              <AppText variant="section">{goal ? "Review the change" : "Create the goal"}</AppText>
              <AppText tone="secondary" variant="caption">
                {goal
                  ? "You’ll review downstream effects only if the edit changes the current structure."
                  : "Accepting this creates the goal, milestones, first tasks, and the initial daily placement."}
              </AppText>
            </View>
            <View className="flex-row gap-3">
              <Button tone="tertiary" style={{ flex: 1 }} onPress={() => navigation.goBack()}>
                Cancel
              </Button>
              <Button
                style={{ flex: 1 }}
                onPress={() => void (goal ? handleUpdate() : handleCreate())}
                disabled={!goal && (!composedInference || strategyPreviewBusy || !strategyComposer)}
                busy={busyState === "create" || busyState === "update"}
              >
                {goal ? "Review changes" : "Create goal"}
              </Button>
            </View>
          </Surface>

          {runtimeMessage ? (
            <AppText tone="tertiary" variant="caption">
              {runtimeMessage}
            </AppText>
          ) : null}
        </View>
      </Screen>

      <Modal
        transparent
        animationType="fade"
        visible={impactPreview !== null}
        onRequestClose={() => setImpactPreview(null)}
      >
        <View
          className="flex-1 items-center justify-center px-5"
          style={{ backgroundColor: "rgba(16, 18, 22, 0.22)" }}
        >
          <Surface style={{ width: "100%" }}>
            <View className="gap-4">
              <AppText variant="title">Review the downstream effect</AppText>
              <AppText tone="secondary">{impactPreview?.summary}</AppText>
              <DetailMetaGroup
                items={[
                  {
                    label: "Milestone areas",
                    value: String(impactPreview?.affectedMilestoneCount ?? 0),
                  },
                  {
                    label: "Tasks touched",
                    value: String(impactPreview?.affectedTaskCount ?? 0),
                  },
                  {
                    label: "Protected",
                    value: String(impactPreview?.protectedTaskCount ?? 0),
                  },
                ]}
              />
              <View className="gap-2">
                <AppText variant="caption" tone="secondary">
                  Choose what happens next
                </AppText>
                <OptionChip
                  selected={downstreamChoice === "keep"}
                  onPress={() => setDownstreamChoice("keep")}
                >
                  Keep current work
                </OptionChip>
                <OptionChip
                  selected={downstreamChoice === "targeted_regeneration"}
                  onPress={() => setDownstreamChoice("targeted_regeneration")}
                >
                  Refresh what changed
                </OptionChip>
                <OptionChip
                  selected={downstreamChoice === "full_regeneration"}
                  onPress={() => setDownstreamChoice("full_regeneration")}
                >
                  Rebuild the structure
                </OptionChip>
              </View>
              <View className="flex-row gap-3">
                <Button tone="tertiary" style={{ flex: 1 }} onPress={() => setImpactPreview(null)}>
                  Back
                </Button>
                <Button
                  style={{ flex: 1 }}
                  onPress={() => void confirmGoalEdit()}
                  busy={busyState === "impact"}
                >
                  Apply changes
                </Button>
              </View>
            </View>
          </Surface>
        </View>
      </Modal>
    </>
  );
}
