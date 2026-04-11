import { useEffect, useMemo, useState } from "react";
import { Modal, Pressable, ScrollView, View } from "react-native";
import { useNavigation } from "@react-navigation/native";

import { Button } from "../../components/ui/Button";
import { EmptyStateCard } from "../../components/ui/EmptyStateCard";
import { OptionChip } from "../../components/ui/OptionChip";
import { Pill } from "../../components/ui/Pill";
import { Screen } from "../../components/ui/Screen";
import { Surface } from "../../components/ui/Surface";
import { AppText } from "../../components/ui/Text";
import { TextField } from "../../components/ui/TextField";
import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
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

interface LifecycleDialogState {
  goal: Goal;
  status: GoalStatus.Paused | GoalStatus.Archived;
  handling: GoalLifecycleHandling;
}

export function GoalsScreen() {
  const theme = useResolvedTheme();
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
          <View className="flex-row items-end justify-between gap-4 pt-2">
            <View className="flex-1 gap-2">
              <Pill label="Goals" />
              <AppText variant="hero">Editable goals with calm downstream control.</AppText>
            </View>
            <Button tone="secondary" onPress={openCreateComposer}>
              New goal
            </Button>
          </View>

          {goals.length === 0 ? (
            <EmptyStateCard
              title="No goals yet"
              body="Add one goal in plain language. Ambitions will recommend a compact structure before it becomes active."
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
              <Surface>
                <View className="gap-4">
                  <AppText variant="section">Active</AppText>
                  {activeGoals.map((goal) => {
                    const selected = selectedGoal?.id === goal.id;
                    const reviewDraft = getGoalReviewDraft(goal);

                    return (
                      <Pressable
                        key={goal.id}
                        className="rounded-[24px] px-4 py-4"
                        onPress={() => setSelectedGoalId(goal.id)}
                        style={({ pressed }) => ({
                          borderWidth: 1,
                          borderColor: selected
                            ? theme.colors.text.primary
                            : theme.colors.border.subtle,
                          backgroundColor: theme.colors.background.elevated,
                          opacity: pressed ? 0.86 : 1,
                        })}
                      >
                        <AppText variant="section">{goal.title}</AppText>
                        <AppText tone="secondary" style={{ marginTop: 6 }}>
                          {goal.summary ?? "No summary yet."}
                        </AppText>
                        <View className="mt-3 flex-row flex-wrap gap-2">
                          <Pill label={goal.domainKey.replace("_", " ")} />
                          <Pill label={goal.horizon} tone="accent" />
                          {goal.targetDate ? <Pill label={goal.targetDate} /> : null}
                          {reviewDraft ? <Pill label="Review pending" tone="accent" /> : null}
                        </View>
                      </Pressable>
                    );
                  })}
                </View>
              </Surface>

              {selectedGoal ? (
                <Surface tone="sunken">
                  <View className="gap-4">
                    <View className="flex-row items-start justify-between gap-3">
                      <View className="flex-1 gap-2">
                        <AppText variant="title">{selectedGoal.title}</AppText>
                        <AppText tone="secondary">
                          {selectedGoal.summary ?? "A structured goal with a calm planning spine."}
                        </AppText>
                      </View>
                      <Button tone="secondary" onPress={() => beginEdit(selectedGoal)}>
                        Edit
                      </Button>
                    </View>

                    <View className="flex-row flex-wrap gap-2">
                      <Pill label={selectedGoal.status} />
                      <Pill label={`${selectedMilestones.length} milestones`} tone="accent" />
                      <Pill label={`${visibleTasks.length} tasks`} />
                      {protectedTasks.length > 0 ? (
                        <Pill label={`${protectedTasks.length} protected`} />
                      ) : null}
                      {selectedReviewDraft ? (
                        <Pill label="Recommended review pending" tone="accent" />
                      ) : null}
                    </View>

                    {selectedReviewDraft ? (
                      <View
                        className="rounded-[22px] px-4 py-4"
                        style={{
                          borderWidth: 1,
                          borderColor: theme.colors.border.strong,
                          backgroundColor: theme.colors.background.elevated,
                        }}
                      >
                        <AppText variant="section">{selectedReviewDraft.headline}</AppText>
                        <AppText tone="secondary" style={{ marginTop: 6 }}>
                          {selectedReviewDraft.summary}
                        </AppText>
                        <View className="mt-3 flex-row gap-3">
                          <Button
                            tone="secondary"
                            style={{ flex: 1 }}
                            onPress={() => navigation.navigate("Plan" as never)}
                          >
                            Review plan
                          </Button>
                        </View>
                      </View>
                    ) : null}

                    <View className="gap-3">
                      <AppText variant="caption" tone="secondary">
                        Current goal state
                      </AppText>
                      <AppText tone="secondary">
                        {selectedGoal.successMetric
                          ? `Success measure: ${selectedGoal.successMetric}`
                          : "No success measure is set yet."}
                      </AppText>
                      <AppText tone="secondary">
                        {selectedGoal.desiredWeeklyMinutes
                          ? `${selectedGoal.desiredWeeklyMinutes} target minutes per week.`
                          : "No weekly pacing has been set."}
                      </AppText>
                      {selectedGoal.notes ? (
                        <AppText tone="secondary">{selectedGoal.notes}</AppText>
                      ) : null}
                    </View>

                    <View className="gap-3">
                      <AppText variant="caption" tone="secondary">
                        Milestones
                      </AppText>
                      {selectedMilestones.length === 0 ? (
                        <AppText tone="secondary">
                          This goal is waiting on review before milestone structure becomes active.
                        </AppText>
                      ) : null}
                      {selectedMilestones.map((milestone) => (
                        <View
                          key={milestone.id}
                          className="rounded-[22px] px-4 py-4"
                          style={{
                            borderWidth: 1,
                            borderColor: theme.colors.border.subtle,
                            backgroundColor: theme.colors.background.elevated,
                          }}
                        >
                          <AppText variant="section">{milestone.title}</AppText>
                          <AppText tone="secondary" style={{ marginTop: 6 }}>
                            {milestone.summary ?? "Generated from the current goal structure."}
                          </AppText>
                          <View className="mt-3 flex-row flex-wrap gap-2">
                            {milestone.targetDate ? <Pill label={milestone.targetDate} /> : null}
                            {hasUserAdjustedMetadata(milestone) ? (
                              <Pill label="Protected" tone="accent" />
                            ) : null}
                          </View>
                        </View>
                      ))}
                    </View>

                    <View className="gap-3">
                      <AppText variant="caption" tone="secondary">
                        Generated tasks
                      </AppText>
                      {visibleTasks.length === 0 ? (
                        <AppText tone="secondary">
                          This goal does not have active task detail yet.
                        </AppText>
                      ) : null}
                      {visibleTasks.slice(0, 6).map((task) => (
                        <View
                          key={task.id}
                          className="rounded-[22px] px-4 py-4"
                          style={{
                            borderWidth: 1,
                            borderColor: theme.colors.border.subtle,
                            backgroundColor: theme.colors.background.elevated,
                          }}
                        >
                          <AppText>{task.title}</AppText>
                          <AppText tone="tertiary" variant="caption" style={{ marginTop: 6 }}>
                            {task.estimatedMinutes} min
                            {task.targetDate ? ` | ${task.targetDate}` : ""}
                          </AppText>
                          {hasUserAdjustedMetadata(task) ||
                          task.status === TaskStatus.Completed ||
                          task.status === TaskStatus.InProgress ? (
                            <View className="mt-3 flex-row gap-2">
                              <Pill label="Protected" tone="accent" />
                            </View>
                          ) : null}
                        </View>
                      ))}
                    </View>

                    <View className="flex-row flex-wrap gap-3">
                      {selectedGoal.status === GoalStatus.Active ? (
                        <Button
                          tone="secondary"
                          onPress={() => openLifecycleDialog(selectedGoal, GoalStatus.Paused)}
                          busy={busyState === `status:${selectedGoal.id}`}
                        >
                          Pause
                        </Button>
                      ) : (
                        <Button
                          tone="secondary"
                          onPress={() => updateGoal(selectedGoal.id, { status: GoalStatus.Active })}
                          busy={busyState === `status:${selectedGoal.id}`}
                        >
                          Resume
                        </Button>
                      )}
                      <Button
                        tone="ghost"
                        onPress={() => openLifecycleDialog(selectedGoal, GoalStatus.Archived)}
                        busy={busyState === `status:${selectedGoal.id}`}
                      >
                        Archive
                      </Button>
                      {hasUndoAvailable(selectedGoal) ? (
                        <Button
                          tone="ghost"
                          onPress={() => handleUndo(selectedGoal.id)}
                          busy={busyState === `undo:${selectedGoal.id}`}
                        >
                          Undo last refresh
                        </Button>
                      ) : null}
                    </View>
                  </View>
                </Surface>
              ) : null}

              {pausedGoals.length > 0 || archivedGoals.length > 0 ? (
                <Surface>
                  <View className="gap-3">
                    <AppText variant="section">Quiet storage</AppText>
                    {[...pausedGoals, ...archivedGoals].map((goal) => (
                      <View
                        key={goal.id}
                        className="rounded-[22px] px-4 py-4"
                        style={{
                          borderWidth: 1,
                          borderColor: theme.colors.border.subtle,
                          backgroundColor: theme.colors.background.elevated,
                        }}
                      >
                        <AppText>{goal.title}</AppText>
                        <AppText tone="tertiary" variant="caption" style={{ marginTop: 6 }}>
                          {goal.status}
                        </AppText>
                      </View>
                    ))}
                  </View>
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
                <AppText variant="title">{editingGoal ? "Edit goal" : "Add a goal"}</AppText>
                {!editingGoal ? (
                  <TextField
                    multiline
                    onChangeText={setDraftText}
                    placeholder="Build a focused TypeScript systems study plan over the next six weeks."
                    value={draftText}
                  />
                ) : null}
                {inference && !editingGoal ? (
                  <View className="flex-row flex-wrap gap-2">
                    <Pill label={inference.domainKey.replace("_", " ")} tone="accent" />
                    <Pill label={inference.type} />
                    <Pill label={inference.horizon} />
                  </View>
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
                  <Button tone="ghost" style={{ flex: 1 }} onPress={resetComposer}>
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
              <AppText variant="title">Goal changes may reshape downstream work</AppText>
              <AppText tone="secondary">{impactPreview?.summary}</AppText>
              <View className="flex-row flex-wrap gap-2">
                <Pill label={`${impactPreview?.affectedMilestoneCount ?? 0} milestone areas`} />
                <Pill label={`${impactPreview?.affectedTaskCount ?? 0} tasks`} tone="accent" />
                {(impactPreview?.protectedTaskCount ?? 0) > 0 ? (
                  <Pill label={`${impactPreview?.protectedTaskCount ?? 0} protected`} />
                ) : null}
              </View>
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
                  Targeted regeneration (Recommended)
                </OptionChip>
                <OptionChip
                  selected={downstreamChoice === "full_regeneration"}
                  onPress={() => setDownstreamChoice("full_regeneration")}
                >
                  Full downstream regeneration
                </OptionChip>
              </View>
              <View className="flex-row gap-3">
                <Button tone="ghost" style={{ flex: 1 }} onPress={() => setImpactPreview(null)}>
                  Back
                </Button>
                <Button style={{ flex: 1 }} onPress={confirmGoalEdit} busy={busyState === "impact"}>
                  Confirm
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
                Keep the change calm. Choose how downstream work should be handled instead of wiping it silently.
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
                <Button tone="ghost" style={{ flex: 1 }} onPress={() => setLifecycleState(null)}>
                  Cancel
                </Button>
                <Button
                  style={{ flex: 1 }}
                  onPress={confirmLifecycleChange}
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
