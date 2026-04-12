import { NativeStackScreenProps } from "@react-navigation/native-stack";
import { useEffect, useMemo, useState } from "react";
import { Modal, View } from "react-native";

import { DrillInRow } from "../../components/navigation/DrillInRow";
import { Button } from "../../components/ui/Button";
import { EmptyStateCard } from "../../components/ui/EmptyStateCard";
import { MetricCard } from "../../components/ui/MetricCard";
import { OptionChip } from "../../components/ui/OptionChip";
import { Pill } from "../../components/ui/Pill";
import { Screen } from "../../components/ui/Screen";
import { Surface } from "../../components/ui/Surface";
import { AppText } from "../../components/ui/Text";
import { TextField } from "../../components/ui/TextField";
import { Goal, GoalStatus, TaskStatus } from "../../domain/models";
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
import { GoalsStackParamList } from "../../navigation/types";

interface LifecycleDialogState {
  goal: Goal;
  status: GoalStatus.Paused | GoalStatus.Archived;
  handling: GoalLifecycleHandling;
}

function MetaLine({ items }: { items: string[] }) {
  return (
    <View className="flex-row flex-wrap gap-x-4 gap-y-2">
      {items.map((item) => (
        <AppText key={item} tone="secondary" variant="caption">
          {item}
        </AppText>
      ))}
    </View>
  );
}

function useGoalData(goalId: string) {
  const goals = useAppStore((state) => state.goals);
  const milestones = useAppStore((state) => state.milestones);
  const allTasks = useAppStore((state) => state.allTasks);

  const goal = goals.find((entry) => entry.id === goalId) ?? null;
  const goalMilestones = milestones.filter((milestone) => milestone.goalId === goalId);
  const visibleTasks = allTasks.filter(
    (task) => task.goalId === goalId && task.status !== TaskStatus.Cancelled,
  );

  return { goal, goalMilestones, visibleTasks };
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
        <View className="gap-5">
          <Surface tone="accent" className="gap-4">
            <View className="gap-2">
              <View className="flex-row flex-wrap items-center gap-2">
                <Pill label={resolvedGoal.status} tone="quiet" />
                {reviewDraft ? <Pill label="Needs review" tone="accent" /> : null}
              </View>
              <AppText variant="title">{resolvedGoal.title}</AppText>
              <AppText tone="secondary">
                {resolvedGoal.summary ?? "A structured goal with a clear planning spine."}
              </AppText>
            </View>
            <MetaLine
              items={[
                resolvedGoal.targetDate ? `Target ${formatShortDate(resolvedGoal.targetDate)}` : "No target date",
                `${goalMilestones.length} milestone${goalMilestones.length === 1 ? "" : "s"}`,
                `${visibleTasks.length} task${visibleTasks.length === 1 ? "" : "s"}`,
              ]}
            />
          </Surface>

          <View className="flex-row gap-3">
            <MetricCard label="Milestones" value={String(goalMilestones.length)} />
            <MetricCard label="Tasks" value={String(visibleTasks.length)} />
            <MetricCard label="Protected" value={String(protectedTasks.length)} />
          </View>

          <View className="gap-3">
            <DrillInRow
              title="Milestones"
              subtitle="Review the checkpoints shaping this goal."
              detail={`${goalMilestones.length}`}
              onPress={() => navigation.navigate("GoalMilestones", { goalId: resolvedGoal.id })}
            />
            <DrillInRow
              title="Progress breakdown"
              subtitle="See active tasks, preserved work, and what is waiting."
              detail={`${visibleTasks.length} tasks`}
              onPress={() => navigation.navigate("GoalProgress", { goalId: resolvedGoal.id })}
            />
            <DrillInRow
              title="Edit goal"
              subtitle="Adjust the goal definition without burying the change flow."
              onPress={() => navigation.navigate("GoalEdit", { goalId: resolvedGoal.id })}
            />
            {reviewDraft ? (
              <DrillInRow
                title="Review changes"
                subtitle={reviewDraft.summary}
                detail={reviewDraft.mode.replaceAll("_", " ")}
                onPress={() => navigation.getParent()?.navigate("Plan" as never)}
              />
            ) : null}
          </View>

          <Surface className="gap-4">
            <AppText variant="section">Snapshot</AppText>
            <MetaLine
              items={[
                resolvedGoal.successMetric ? `Success: ${resolvedGoal.successMetric}` : "No success metric yet",
                resolvedGoal.desiredWeeklyMinutes
                  ? `${resolvedGoal.desiredWeeklyMinutes} min per week`
                  : "No weekly pacing set",
                resolvedGoal.domainKey.replace("_", " "),
              ]}
            />
            {resolvedGoal.notes ? <AppText tone="secondary">{resolvedGoal.notes}</AppText> : null}
          </Surface>

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
            <Button
              tone="tertiary"
              onPress={() => openLifecycleDialog(GoalStatus.Archived)}
              busy={busyState === `status:${resolvedGoal.id}`}
            >
              Archive goal
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
        <View className="flex-1 items-center justify-center px-5" style={{ backgroundColor: "rgba(16, 18, 22, 0.22)" }}>
          <Surface style={{ width: "100%" }}>
            <View className="gap-4">
              <AppText variant="title">
                {lifecycleState?.status === GoalStatus.Paused ? "Pause goal" : "Archive goal"}
              </AppText>
              <AppText tone="secondary">
                Choose how downstream work should be handled instead of letting it disappear silently.
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
                  Confirm change
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
  const { goal, goalMilestones } = useGoalData(route.params.goalId);

  if (!goal) {
    return (
      <Screen>
        <EmptyStateCard title="Goal not found" body="That goal is no longer available." />
      </Screen>
    );
  }

  return (
    <Screen>
      <View className="gap-4">
        <Surface tone="accent" className="gap-3">
          <AppText variant="title">{goal.title}</AppText>
          <AppText tone="secondary">Milestones stay separate so the goal page can stay concise.</AppText>
        </Surface>
        <View className="gap-3">
          {goalMilestones.length === 0 ? (
            <EmptyStateCard
              title="No milestones yet"
              body="This goal is waiting on review before milestones become active."
            />
          ) : null}
          {goalMilestones.map((milestone) => (
            <Surface key={milestone.id} className="gap-2">
              <AppText variant="section">{milestone.title}</AppText>
              <AppText tone="secondary">
                {milestone.summary ?? "Generated from the current goal structure."}
              </AppText>
              <MetaLine
                items={[
                  milestone.targetDate ? `Target ${formatShortDate(milestone.targetDate)}` : "No target date",
                  hasUserAdjustedMetadata(milestone) ? "Preserved" : milestone.status.replaceAll("_", " "),
                ]}
              />
            </Surface>
          ))}
        </View>
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

  return (
    <Screen>
      <View className="gap-4">
        <Surface tone="accent" className="gap-3">
          <AppText variant="title">{goal.title}</AppText>
          <AppText tone="secondary">
            See the active task load without forcing all of it onto the main goal screen.
          </AppText>
        </Surface>
        <View className="gap-3">
          {visibleTasks.length === 0 ? (
            <EmptyStateCard
              title="No active tasks"
              body="This goal does not have active task detail yet."
            />
          ) : null}
          {visibleTasks.map((task) => (
            <Surface key={task.id} className="gap-2">
              <AppText variant="section">{task.title}</AppText>
              <MetaLine
                items={[
                  `${task.estimatedMinutes} min`,
                  task.targetDate ? `Target ${formatShortDate(task.targetDate)}` : "No target date",
                  task.status.replaceAll("_", " "),
                ]}
              />
              {task.summary ? <AppText tone="secondary">{task.summary}</AppText> : null}
            </Surface>
          ))}
        </View>
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
        <View className="gap-5">
          <Surface tone="accent" className="gap-3">
            <AppText variant="title">{goal ? "Refine the goal" : "Add a goal"}</AppText>
            <AppText tone="secondary">
              {goal
                ? "Edit the goal definition here, then decide how downstream work should respond."
                : "Write the goal in plain language first. Ambitions will turn it into a workable structure."}
            </AppText>
          </Surface>

          {!goal ? (
            <TextField
              multiline
              onChangeText={setDraftText}
              placeholder="Build a focused TypeScript systems study plan over the next six weeks."
              value={draftText}
            />
          ) : null}

          {inference && !goal ? (
            <MetaLine items={[inference.domainKey.replace("_", " "), inference.type, inference.horizon]} />
          ) : null}

          <TextField onChangeText={setManualTitle} placeholder="Goal title" label="Title" value={manualTitle} />
          <TextField onChangeText={setManualSummary} placeholder="Short goal summary" label="Summary" multiline value={manualSummary} />
          <TextField onChangeText={setManualSuccessMetric} placeholder="Success measure" label="Success metric" value={manualSuccessMetric} />
          <TextField onChangeText={setManualTargetDate} placeholder="YYYY-MM-DD" label="Target date" value={manualTargetDate} />
          <TextField onChangeText={setManualDesiredWeeklyMinutes} placeholder="120" label="Target minutes per week" keyboardType="numeric" value={manualDesiredWeeklyMinutes} />
          <TextField onChangeText={setManualNotes} placeholder="Notes that should shape the goal." label="Notes" multiline value={manualNotes} />
          <View className="gap-2">
            <AppText variant="caption" tone="secondary">
              Domain
            </AppText>
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
        <View className="flex-1 items-center justify-center px-5" style={{ backgroundColor: "rgba(16, 18, 22, 0.22)" }}>
          <Surface style={{ width: "100%" }}>
            <View className="gap-4">
              <AppText variant="title">This change affects downstream work</AppText>
              <AppText tone="secondary">{impactPreview?.summary}</AppText>
              <MetaLine
                items={[
                  `${impactPreview?.affectedMilestoneCount ?? 0} milestone areas`,
                  `${impactPreview?.affectedTaskCount ?? 0} tasks`,
                  `${impactPreview?.protectedTaskCount ?? 0} protected`,
                ]}
              />
              <View className="gap-2">
                <AppText variant="caption" tone="secondary">
                  Downstream handling
                </AppText>
                <OptionChip selected={downstreamChoice === "keep"} onPress={() => setDownstreamChoice("keep")}>
                  Keep downstream work
                </OptionChip>
                <OptionChip selected={downstreamChoice === "targeted_regeneration"} onPress={() => setDownstreamChoice("targeted_regeneration")}>
                  Refresh what changed
                </OptionChip>
                <OptionChip selected={downstreamChoice === "full_regeneration"} onPress={() => setDownstreamChoice("full_regeneration")}>
                  Rebuild downstream work
                </OptionChip>
              </View>
              <View className="flex-row gap-3">
                <Button tone="tertiary" style={{ flex: 1 }} onPress={() => setImpactPreview(null)}>
                  Back
                </Button>
                <Button style={{ flex: 1 }} onPress={() => void confirmGoalEdit()} busy={busyState === "impact"}>
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
