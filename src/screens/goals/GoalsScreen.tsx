import { useEffect, useMemo, useState } from "react";
import { Modal, ScrollView, View } from "react-native";
import { useNavigation } from "@react-navigation/native";

import { Button } from "../../components/ui/Button";
import { EmptyStateCard } from "../../components/ui/EmptyStateCard";
import { MetricCard } from "../../components/ui/MetricCard";
import { OptionChip } from "../../components/ui/OptionChip";
import { Screen } from "../../components/ui/Screen";
import { SelectionCard } from "../../components/ui/SelectionCard";
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

export function GoalsScreen() {
  const navigation = useNavigation();
  const goals = useAppStore((state) => state.goals);
  const milestones = useAppStore((state) => state.milestones);
  const allTasks = useAppStore((state) => state.allTasks);
  const domains = useAppStore((state) => state.domains);
  const createGoal = useAppStore((state) => state.createGoal);
  const updateGoal = useAppStore((state) => state.updateGoal);
  const previewGoalEdit = useAppStore((state) => state.previewGoalEdit);
  const applyGoalEditDecision = useAppStore((state) => state.applyGoalEditDecision);
  const setGoalStatusWithHandling = useAppStore((state) => state.setGoalStatusWithHandling);
  const undoGoalRegeneration = useAppStore((state) => state.undoGoalRegeneration);
  const planDate = useAppStore((state) => state.planDate);
  const [composerOpen, setComposerOpen] = useState(false);
  const [selectedGoalId, setSelectedGoalId] = useState<string | null>(goals[0]?.id ?? null);
  const [draftText, setDraftText] = useState("");
  const [editingGoal, setEditingGoal] = useState<Goal | null>(null);
  const [manualTitle, setManualTitle] = useState("");
  const [manualSummary, setManualSummary] = useState("");
  const [manualTargetDate, setManualTargetDate] = useState("");
  const [manualDomainKey, setManualDomainKey] = useState<Goal["domainKey"] | null>(null);
  const [manualSuccessMetric, setManualSuccessMetric] = useState("");
  const [manualNotes, setManualNotes] = useState("");
  const [manualDesiredWeeklyMinutes, setManualDesiredWeeklyMinutes] = useState("");
  const [busyState, setBusyState] = useState<string | null>(null);
  const [runtimeMessage, setRuntimeMessage] = useState<string | null>(null);
  const [pendingEditPatch, setPendingEditPatch] = useState<Partial<Goal> | null>(null);
  const [impactPreview, setImpactPreview] = useState<GoalEditImpactPreview | null>(null);
  const [downstreamChoice, setDownstreamChoice] =
    useState<GoalDownstreamChoice>("targeted_regeneration");
  const [lifecycleState, setLifecycleState] = useState<LifecycleDialogState | null>(null);

  const selectedGoal = goals.find((goal) => goal.id === selectedGoalId) ?? goals[0] ?? null;
  const selectedMilestones = selectedGoal
    ? milestones.filter((milestone) => milestone.goalId === selectedGoal.id)
    : [];
  const selectedTasks = selectedGoal ? allTasks.filter((task) => task.goalId === selectedGoal.id) : [];
  const visibleTasks = selectedTasks.filter((task) => task.status !== TaskStatus.Cancelled);
  const protectedTasks = visibleTasks.filter(
    (task) =>
      hasUserAdjustedMetadata(task) ||
      task.status === TaskStatus.Completed ||
      task.status === TaskStatus.InProgress,
  );
  const activeGoals = goals.filter((goal) => goal.status === GoalStatus.Active);
  const pausedGoals = goals.filter((goal) => goal.status === GoalStatus.Paused);
  const archivedGoals = goals.filter((goal) => goal.status === GoalStatus.Archived);
  const selectedReviewDraft = selectedGoal ? getGoalReviewDraft(selectedGoal) : null;
  const inference = useMemo(
    () => (draftText.trim().length > 0 ? inferGoalDraft(draftText, planDate) : null),
    [draftText, planDate],
  );

  useEffect(() => {
    if (!selectedGoalId || !goals.some((goal) => goal.id === selectedGoalId)) {
      setSelectedGoalId(goals[0]?.id ?? null);
    }
  }, [goals, selectedGoalId]);

  function resetComposer() {
    setComposerOpen(false);
    setEditingGoal(null);
    setDraftText("");
    setManualTitle("");
    setManualSummary("");
    setManualTargetDate("");
    setManualDomainKey(null);
    setManualSuccessMetric("");
    setManualNotes("");
    setManualDesiredWeeklyMinutes("");
    setPendingEditPatch(null);
    setImpactPreview(null);
  }

  function openCreateComposer() {
    setRuntimeMessage(null);
    setEditingGoal(null);
    setDraftText("");
    setManualTitle("");
    setManualSummary("");
    setManualTargetDate("");
    setManualDomainKey(null);
    setManualSuccessMetric("");
    setManualNotes("");
    setManualDesiredWeeklyMinutes("");
    setComposerOpen(true);
  }

  function beginEdit(goal: Goal) {
    setRuntimeMessage(null);
    setEditingGoal(goal);
    setManualTitle(goal.title);
    setManualSummary(goal.summary ?? "");
    setManualTargetDate(goal.targetDate ?? "");
    setManualDomainKey(goal.domainKey);
    setManualSuccessMetric(goal.successMetric ?? "");
    setManualNotes(goal.notes ?? "");
    setManualDesiredWeeklyMinutes(
      goal.desiredWeeklyMinutes ? String(goal.desiredWeeklyMinutes) : "",
    );
    setComposerOpen(true);
  }

  function buildGoalPatch(goal: Goal | null) {
    if (!goal) {
      return null;
    }

    return {
      title: manualTitle.trim() || goal.title,
      summary: manualSummary.trim() || null,
      targetDate: manualTargetDate.trim() || null,
      domainKey: manualDomainKey ?? goal.domainKey,
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
      resetComposer();
      navigation.navigate("Plan" as never);
    } catch (error) {
      setRuntimeMessage(error instanceof Error ? error.message : "The goal could not be created.");
    } finally {
      setBusyState(null);
    }
  }

  async function handleUpdate() {
    if (!editingGoal) {
      return;
    }

    const patch = buildGoalPatch(editingGoal);
    if (!patch) {
      return;
    }

    setBusyState("update");
    setRuntimeMessage(null);

    try {
      const impact = await previewGoalEdit(editingGoal.id, patch);
      if (!impact.hasDownstream || impact.changedFields.length === 0) {
        await updateGoal(editingGoal.id, patch);
        resetComposer();
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
    if (!editingGoal || !pendingEditPatch) {
      return;
    }

    setBusyState("impact");
    setRuntimeMessage(null);

    try {
      await applyGoalEditDecision(editingGoal.id, pendingEditPatch, downstreamChoice);
      setImpactPreview(null);
      setPendingEditPatch(null);
      resetComposer();
      if (downstreamChoice !== "keep") {
        navigation.navigate("Plan" as never);
      }
    } catch (error) {
      setRuntimeMessage(
        error instanceof Error ? error.message : "The goal changes could not be applied.",
      );
    } finally {
      setBusyState(null);
    }
  }

  function openLifecycleDialog(goal: Goal, status: GoalStatus.Paused | GoalStatus.Archived) {
    const options = describeLifecycleOptions(status === GoalStatus.Paused ? "pause" : "archive");
    setLifecycleState({
      goal,
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
          <View className="gap-3 pt-2">
            <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
              Goals
            </AppText>
            <View className="flex-row items-end justify-between gap-4">
              <View className="flex-1 gap-2">
                <AppText variant="hero">Keep goals clear, focused, and current.</AppText>
                <AppText tone="secondary">
                  Pick a goal, review its structure, and make changes without turning the page into
                  admin clutter.
                </AppText>
              </View>
              <Button onPress={openCreateComposer}>
                New goal
              </Button>
            </View>
          </View>

          {goals.length === 0 ? (
            <EmptyStateCard
              title="No goals yet"
              body="Write one goal in plain language. Ambitions will turn it into a workable structure before it goes live."
              action={
                <View className="pt-1">
                  <Button tone="secondary" onPress={openCreateComposer}>
                    Create a goal
                  </Button>
                </View>
              }
            />
          ) : (
            <>
              <Surface className="gap-4">
                <View className="gap-2">
                  <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                    Active goals
                  </AppText>
                  <AppText variant="section">Choose a goal to review</AppText>
                  <AppText tone="secondary">
                    Active goals stay easy to compare. Open one to review what matters now.
                  </AppText>
                </View>
                <View className="gap-3">
                  {activeGoals.map((goal) => {
                    const selected = selectedGoal?.id === goal.id;
                    const reviewDraft = getGoalReviewDraft(goal);

                    return (
                      <SelectionCard
                        key={goal.id}
                        selected={selected}
                        eyebrow={selected ? "Current goal" : "Goal"}
                        onPress={() => setSelectedGoalId(goal.id)}
                        trailing={
                          <AppText tone="secondary" variant="caption">
                            {goal.horizon}
                          </AppText>
                        }
                      >
                        <View className="gap-3">
                          <AppText variant="section">{goal.title}</AppText>
                          <AppText tone="secondary">
                            {goal.summary ?? "No summary yet."}
                          </AppText>
                          <MetaLine
                            items={[
                              goal.domainKey.replace("_", " "),
                              goal.targetDate
                                ? `Target ${formatShortDate(goal.targetDate)}`
                                : "No target date",
                              reviewDraft ? "Review pending" : "Plan current",
                            ]}
                          />
                        </View>
                      </SelectionCard>
                    );
                  })}
                </View>
              </Surface>

              {selectedGoal ? (
                <Surface tone="sunken" className="gap-5">
                  <View className="gap-3">
                    <View className="flex-row items-start justify-between gap-3">
                      <View className="flex-1 gap-2">
                        <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                          Current goal
                        </AppText>
                        <AppText variant="title">{selectedGoal.title}</AppText>
                        <AppText tone="secondary">
                          {selectedGoal.summary ?? "A structured goal with a clear planning spine."}
                        </AppText>
                      </View>
                      <Button tone="tertiary" onPress={() => beginEdit(selectedGoal)}>
                        Edit goal
                      </Button>
                    </View>

                    <MetaLine
                      items={[
                        selectedGoal.status,
                        `${selectedMilestones.length} milestone${selectedMilestones.length === 1 ? "" : "s"}`,
                        `${visibleTasks.length} task${visibleTasks.length === 1 ? "" : "s"}`,
                        protectedTasks.length > 0
                          ? `${protectedTasks.length} preserved`
                          : "No preserved work",
                      ]}
                    />
                  </View>

                  <View className="flex-row gap-3">
                    <MetricCard label="Milestones" value={String(selectedMilestones.length)} />
                    <MetricCard label="Tasks" value={String(visibleTasks.length)} />
                    <MetricCard label="Protected" value={String(protectedTasks.length)} />
                  </View>

                  {selectedReviewDraft ? (
                    <Surface className="gap-3">
                      <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                        Review ready
                      </AppText>
                      <AppText variant="section">{selectedReviewDraft.headline}</AppText>
                      <AppText tone="secondary">{selectedReviewDraft.summary}</AppText>
                      <MetaLine items={["Recommended plan", "Needs review"]} />
                      <Button onPress={() => navigation.navigate("Plan" as never)}>
                        Review changes
                      </Button>
                    </Surface>
                  ) : null}

                  <Surface className="gap-3">
                    <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                      Snapshot
                    </AppText>
                    <MetaLine
                      items={[
                        selectedGoal.successMetric
                          ? `Success: ${selectedGoal.successMetric}`
                          : "No success metric yet",
                        selectedGoal.desiredWeeklyMinutes
                          ? `${selectedGoal.desiredWeeklyMinutes} min per week`
                          : "No weekly pacing set",
                        selectedGoal.targetDate
                          ? `Target date ${formatShortDate(selectedGoal.targetDate)}`
                          : "No target date",
                      ]}
                    />
                    {selectedGoal.notes ? (
                      <AppText tone="secondary">{selectedGoal.notes}</AppText>
                    ) : null}
                  </Surface>

                  <View className="gap-3">
                    <View className="gap-1">
                      <AppText variant="section">Milestones</AppText>
                      <AppText tone="secondary" variant="caption">
                        The next structural checkpoints for this goal.
                      </AppText>
                    </View>
                    {selectedMilestones.length === 0 ? (
                      <AppText tone="secondary">
                        This goal is waiting on review before milestones become active.
                      </AppText>
                    ) : null}
                    {selectedMilestones.map((milestone) => (
                      <Surface key={milestone.id} className="gap-2">
                        <AppText variant="section">{milestone.title}</AppText>
                        <AppText tone="secondary">
                          {milestone.summary ?? "Generated from the current goal structure."}
                        </AppText>
                        <MetaLine
                          items={[
                            milestone.targetDate
                              ? `Target ${formatShortDate(milestone.targetDate)}`
                              : "No target date",
                            hasUserAdjustedMetadata(milestone) ? "Preserved" : "Generated",
                          ]}
                        />
                      </Surface>
                    ))}
                  </View>

                  <View className="gap-3">
                    <View className="gap-1">
                      <AppText variant="section">Task preview</AppText>
                      <AppText tone="secondary" variant="caption">
                        A quick scan of the first active tasks under this goal.
                      </AppText>
                    </View>
                    {visibleTasks.length === 0 ? (
                      <AppText tone="secondary">
                        This goal does not have active task detail yet.
                      </AppText>
                    ) : null}
                    {visibleTasks.slice(0, 6).map((task) => (
                      <Surface key={task.id} className="gap-2">
                        <AppText>{task.title}</AppText>
                        <MetaLine
                          items={[
                            `${task.estimatedMinutes} min`,
                            task.targetDate
                              ? `Target ${formatShortDate(task.targetDate)}`
                              : "No target date",
                            hasUserAdjustedMetadata(task) ||
                            task.status === TaskStatus.Completed ||
                            task.status === TaskStatus.InProgress
                              ? "Preserved"
                              : task.status.replaceAll("_", " "),
                          ]}
                        />
                      </Surface>
                    ))}
                  </View>

                  <View className="flex-row flex-wrap gap-3">
                    {selectedGoal.status === GoalStatus.Active ? (
                      <Button
                        tone="secondary"
                        onPress={() => openLifecycleDialog(selectedGoal, GoalStatus.Paused)}
                        busy={busyState === `status:${selectedGoal.id}`}
                      >
                        Pause goal
                      </Button>
                    ) : (
                      <Button
                        tone="secondary"
                        onPress={() => updateGoal(selectedGoal.id, { status: GoalStatus.Active })}
                        busy={busyState === `status:${selectedGoal.id}`}
                      >
                        Resume goal
                      </Button>
                    )}
                    <Button
                      tone="tertiary"
                      onPress={() => openLifecycleDialog(selectedGoal, GoalStatus.Archived)}
                      busy={busyState === `status:${selectedGoal.id}`}
                    >
                      Archive goal
                    </Button>
                    {hasUndoAvailable(selectedGoal) ? (
                      <Button
                        tone="inline"
                        onPress={() => handleUndo(selectedGoal.id)}
                        busy={busyState === `undo:${selectedGoal.id}`}
                      >
                        Undo refresh
                      </Button>
                    ) : null}
                  </View>
                </Surface>
              ) : null}

              {pausedGoals.length > 0 || archivedGoals.length > 0 ? (
                <Surface className="gap-3">
                  <View className="gap-2">
                    <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                      Inactive goals
                    </AppText>
                    <AppText variant="section">Paused and archived</AppText>
                    <AppText tone="secondary">
                      Goals that are out of rotation stay available without taking over the page.
                    </AppText>
                  </View>
                  {[...pausedGoals, ...archivedGoals].map((goal) => (
                    <SelectionCard
                      key={goal.id}
                      selected={false}
                      eyebrow={goal.status}
                      onPress={() => setSelectedGoalId(goal.id)}
                    >
                      <View className="gap-2">
                        <AppText>{goal.title}</AppText>
                        <MetaLine
                          items={[
                            goal.targetDate
                              ? `Target ${formatShortDate(goal.targetDate)}`
                              : "No target date",
                          ]}
                        />
                      </View>
                    </SelectionCard>
                  ))}
                </Surface>
              ) : null}
            </>
          )}

          {runtimeMessage ? (
            <AppText tone="tertiary" variant="caption">
              {runtimeMessage}
            </AppText>
          ) : null}
        </View>
      </Screen>

      <Modal transparent animationType="slide" visible={composerOpen} onRequestClose={resetComposer}>
        <View className="flex-1 justify-end" style={{ backgroundColor: "rgba(16, 18, 22, 0.18)" }}>
          <Surface style={{ borderBottomLeftRadius: 0, borderBottomRightRadius: 0 }}>
            <ScrollView showsVerticalScrollIndicator={false}>
              <View className="gap-4 pb-6">
                <View className="gap-2">
                  <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                    {editingGoal ? "Edit goal" : "New goal"}
                  </AppText>
                  <AppText variant="title">{editingGoal ? "Refine the goal" : "Add a goal"}</AppText>
                </View>
                {!editingGoal ? (
                  <TextField
                    multiline
                    onChangeText={setDraftText}
                    placeholder="Build a focused TypeScript systems study plan over the next six weeks."
                    value={draftText}
                  />
                ) : null}
                {inference && !editingGoal ? (
                  <MetaLine
                    items={[
                      inference.domainKey.replace("_", " "),
                      inference.type,
                      inference.horizon,
                    ]}
                  />
                ) : null}
                <TextField onChangeText={setManualTitle} placeholder="Goal title" label="Title" value={manualTitle} />
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
                <TextField
                  onChangeText={setManualNotes}
                  placeholder="Notes that should shape the goal."
                  label="Notes"
                  multiline
                  value={manualNotes}
                />
                <View className="gap-2">
                  <AppText variant="caption" tone="secondary">
                    Domain
                  </AppText>
                  <View className="flex-row flex-wrap gap-2">
                    {domains.map((domain) => {
                      const key = manualDomainKey ?? inference?.domainKey ?? editingGoal?.domainKey;
                      const selected = key === domain.key;

                      return (
                        <OptionChip
                          key={`domain-select-${domain.id}`}
                          selected={selected}
                          onPress={() => setManualDomainKey(domain.key)}
                        >
                          {domain.name}
                        </OptionChip>
                      );
                    })}
                  </View>
                </View>
                <View className="flex-row gap-3">
                  <Button tone="tertiary" style={{ flex: 1 }} onPress={resetComposer}>
                    Cancel
                  </Button>
                  <Button
                    style={{ flex: 1 }}
                    onPress={editingGoal ? handleUpdate : handleCreate}
                    disabled={!editingGoal && !inference}
                    busy={busyState === "create" || busyState === "update"}
                  >
                    {editingGoal ? "Review changes" : "Create goal"}
                  </Button>
                </View>
              </View>
            </ScrollView>
          </Surface>
        </View>
      </Modal>

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
                  Rebuild downstream work
                </OptionChip>
              </View>
              <View className="flex-row gap-3">
                <Button tone="tertiary" style={{ flex: 1 }} onPress={() => setImpactPreview(null)}>
                  Back
                </Button>
                <Button style={{ flex: 1 }} onPress={confirmGoalEdit} busy={busyState === "impact"}>
                  Apply changes
                </Button>
              </View>
            </View>
          </Surface>
        </View>
      </Modal>

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
              {lifecycleState ? (
                <AppText tone="secondary">
                  {
                    describeLifecycleOptions(
                      lifecycleState.status === GoalStatus.Paused ? "pause" : "archive",
                    ).find((option) => option.key === lifecycleState.handling)?.description
                  }
                </AppText>
              ) : null}
              <View className="flex-row gap-3">
                <Button tone="tertiary" style={{ flex: 1 }} onPress={() => setLifecycleState(null)}>
                  Cancel
                </Button>
                <Button
                  style={{ flex: 1 }}
                  onPress={confirmLifecycleChange}
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
