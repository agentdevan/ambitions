import { NativeStackScreenProps } from "@react-navigation/native-stack";
import { useEffect, useMemo, useState } from "react";
import { Modal, View } from "react-native";

import {
  DetailHero,
  DetailMetaGroup,
  DetailSection,
  DetailSummaryStrip,
  QuietMetaLine,
} from "../../components/detail/DetailPrimitives";
import { DrillInRow } from "../../components/navigation/DrillInRow";
import { Button } from "../../components/ui/Button";
import { EmptyStateCard } from "../../components/ui/EmptyStateCard";
import { OptionChip } from "../../components/ui/OptionChip";
import { Pill } from "../../components/ui/Pill";
import { Screen } from "../../components/ui/Screen";
import { Surface } from "../../components/ui/Surface";
import { AppText } from "../../components/ui/Text";
import { TextField } from "../../components/ui/TextField";
import { Goal, GoalMilestoneStatus, GoalStatus, TaskStatus } from "../../domain/models";
import { GoalsStackParamList } from "../../navigation/types";
import { inferGoalDraft } from "../../product/goalIntake";
import { describeLifecycleOptions } from "../../services/goals/downstreamHandlingPolicies";
import {
  GoalDownstreamChoice,
  GoalEditImpactPreview,
  GoalLifecycleHandling,
  getGoalReviewDraft,
  hasUserAdjustedMetadata,
} from "../../services/goals/metadata";
import { hasUndoAvailable } from "../../services/goals/regenerationCoordinator";
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

export function GoalDetailScreen({
  route,
  navigation,
}: NativeStackScreenProps<GoalsStackParamList, "GoalDetail">) {
  const { goal, goalMilestones, visibleTasks } = useGoalData(route.params.goalId);
  const updateGoal = useAppStore((state) => state.updateGoal);
  const setGoalStatusWithHandling = useAppStore((state) => state.setGoalStatusWithHandling);
  const undoGoalRegeneration = useAppStore((state) => state.undoGoalRegeneration);
  const [busyState, setBusyState] = useState<string | null>(null);
  const [runtimeMessage, setRuntimeMessage] = useState<string | null>(null);
  const [lifecycleState, setLifecycleState] = useState<LifecycleDialogState | null>(null);

  if (!goal) {
    return (
      <Screen>
        <EmptyStateCard title="Goal not found" body="That goal is no longer available." />
      </Screen>
    );
  }

  const resolvedGoal = goal;

  const reviewDraft = getGoalReviewDraft(resolvedGoal);
  const protectedTasks = visibleTasks.filter(
    (task) =>
      hasUserAdjustedMetadata(task) ||
      task.status === TaskStatus.Completed ||
      task.status === TaskStatus.InProgress,
  );
  const activeTasks = visibleTasks.filter((task) =>
    [TaskStatus.Ready, TaskStatus.Scheduled, TaskStatus.InProgress].includes(task.status),
  );
  const completedTasks = visibleTasks.filter((task) => task.status === TaskStatus.Completed);
  const completedMilestones = goalMilestones.filter(
    (milestone) => milestone.status === GoalMilestoneStatus.Completed,
  );
  const currentMilestone =
    goalMilestones.find((milestone) => milestone.status === GoalMilestoneStatus.InProgress) ??
    goalMilestones.find((milestone) => milestone.status === GoalMilestoneStatus.Pending) ??
    null;
  const nextTask =
    activeTasks.find((task) => task.status === TaskStatus.InProgress) ??
    activeTasks.find((task) => task.status === TaskStatus.Scheduled) ??
    activeTasks[0] ??
    null;

  function openLifecycleDialog(status: GoalStatus.Paused | GoalStatus.Archived) {
    const options = describeLifecycleOptions(status === GoalStatus.Paused ? "pause" : "archive");
    setLifecycleState({
      goal: resolvedGoal,
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
            description={resolvedGoal.summary ?? "This goal is active and ready for deeper inspection."}
            badges={
              <>
                <Pill label={statusLabel(resolvedGoal.status)} tone="quiet" />
                {reviewDraft ? <Pill label="Needs review" tone="accent" /> : null}
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
                    label: "Current milestone",
                    value: currentMilestone?.title ?? "No active milestone",
                  },
                  {
                    label: "Protected work",
                    value: `${protectedTasks.length} tasks`,
                  },
                  {
                    label: "Pacing",
                    value: resolvedGoal.desiredWeeklyMinutes
                      ? `${resolvedGoal.desiredWeeklyMinutes} min per week`
                      : "No weekly pacing",
                  },
                ]}
              />
            }
          />

          <DetailSection
            title="Progress"
            description="A clean read on movement without turning this into a dashboard wall."
          >
            <DetailSummaryStrip
              items={[
                {
                  label: "Milestones",
                  value: `${completedMilestones.length}/${goalMilestones.length}`,
                  detail: completedMilestones.length > 0 ? "Completed" : "Not started yet",
                },
                {
                  label: "Active work",
                  value: String(activeTasks.length),
                  detail: nextTask ? `Next: ${nextTask.title}` : "Nothing queued right now",
                },
                {
                  label: "Completed tasks",
                  value: String(completedTasks.length),
                  detail: "Finished inside this goal",
                },
                {
                  label: "Plan review",
                  value: reviewDraft ? "Waiting" : "Clear",
                  detail: reviewDraft ? "Structure needs a decision" : "No pending changes",
                },
              ]}
            />
          </DetailSection>

          <DetailSection
            title="Open this goal"
            description="Go deeper where it matters."
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
                subtitle="See active tasks, protected work, and completed movement."
                detail={`${visibleTasks.length} tasks`}
                onPress={() => navigation.navigate("GoalProgress", { goalId: resolvedGoal.id })}
              />
              <DrillInRow
                title="Edit goal"
                subtitle="Refine the goal definition, then decide how downstream work should respond."
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
              <AppText tone="secondary" variant="caption">
                What this goal is, separate from what you can do next.
              </AppText>
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
              <AppText tone="secondary" variant="caption">
                Keep the primary move obvious. Everything else stays quieter.
              </AppText>
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
                  tone="inline"
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
                tone="inline"
                onPress={() => openLifecycleDialog(GoalStatus.Archived)}
                busy={busyState === `status:${resolvedGoal.id}`}
              >
                Archive
              </Button>
              {hasUndoAvailable(resolvedGoal) ? (
                <Button
                  tone="inline"
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
        <EmptyStateCard title="Goal not found" body="That goal is no longer available." />
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
          description="See the checkpoints shaping this goal."
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
            body="This goal is waiting on review before milestones become active."
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
}: NativeStackScreenProps<GoalsStackParamList, "GoalProgress">) {
  const { goal, visibleTasks } = useGoalData(route.params.goalId);

  if (!goal) {
    return (
      <Screen>
        <EmptyStateCard title="Goal not found" body="That goal is no longer available." />
      </Screen>
    );
  }

  const activeTasks = visibleTasks.filter((task) =>
    [TaskStatus.Ready, TaskStatus.Scheduled, TaskStatus.InProgress].includes(task.status),
  );
  const protectedTasks = visibleTasks.filter((task) => hasUserAdjustedMetadata(task));
  const completedTasks = visibleTasks.filter((task) => task.status === TaskStatus.Completed);

  return (
    <Screen>
      <View className="gap-6">
        <DetailHero
          eyebrow="Goal"
          title="Progress"
          description="See how this goal is moving."
          meta={
            <DetailSummaryStrip
              items={[
                {
                  label: "Active",
                  value: String(activeTasks.length),
                  detail: "Currently in rotation",
                },
                {
                  label: "Protected",
                  value: String(protectedTasks.length),
                  detail: "Held steady through changes",
                },
                {
                  label: "Completed",
                  value: String(completedTasks.length),
                  detail: "Finished work",
                },
              ]}
            />
          }
        />

        {visibleTasks.length === 0 ? (
          <EmptyStateCard
            title="No active tasks"
            body="This goal does not have task detail yet."
          />
        ) : (
          <>
            <DetailSection
              title="Current work"
              description="The task load that still matters right now."
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
                description="Items preserved because you already shaped them."
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
          </>
        )}
      </View>
    </Screen>
  );
}

export function GoalEditScreen({
  route,
  navigation,
}: NativeStackScreenProps<GoalsStackParamList, "GoalEdit">) {
  const goals = useAppStore((state) => state.goals);
  const domains = useAppStore((state) => state.domains);
  const planDate = useAppStore((state) => state.planDate);
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
  }, [goal]);

  const inference = useMemo(
    () => (draftText.trim().length > 0 ? inferGoalDraft(draftText, planDate) : null),
    [draftText, planDate],
  );

  function buildGoalPatch(existingGoal: Goal | null) {
    if (!existingGoal) {
      return null;
    }

    return {
      title: manualTitle.trim() || existingGoal.title,
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

  async function handleCreate() {
    if (!inference) {
      return;
    }

    setBusyState("create");
    setRuntimeMessage(null);

    try {
      await createGoal({
        ...inference,
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
      });
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
                ? "Tighten the definition here. If the change affects downstream work, review the impact before it lands."
                : "Describe the outcome in plain language. Ambitions will shape the first structure from it."
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
            description="Set what this goal is trying to do."
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
            title="Timing and pacing"
            description="Keep the plan grounded in time."
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
            description="Choose the area this goal belongs to."
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

          <Surface className="gap-4 mb-0">
            <View className="gap-1">
              <AppText variant="section">{goal ? "Review the change" : "Create the goal"}</AppText>
              <AppText tone="secondary" variant="caption">
                {goal
                  ? "You’ll review downstream effects only if the edit changes the current structure."
                  : "The goal will open in detail after creation so you can inspect the structure there."}
              </AppText>
            </View>
            <View className="flex-row gap-3">
              <Button tone="tertiary" style={{ flex: 1 }} onPress={() => navigation.goBack()}>
                Cancel
              </Button>
              <Button
                style={{ flex: 1 }}
                onPress={() => void (goal ? handleUpdate() : handleCreate())}
                disabled={!goal && !inference}
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
