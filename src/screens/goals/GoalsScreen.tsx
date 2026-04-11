import { useEffect, useMemo, useState } from "react";
import { Modal, Pressable, ScrollView, View } from "react-native";

import { Button } from "../../components/ui/Button";
import { EmptyStateCard } from "../../components/ui/EmptyStateCard";
import { OptionChip } from "../../components/ui/OptionChip";
import { Pill } from "../../components/ui/Pill";
import { Screen } from "../../components/ui/Screen";
import { Surface } from "../../components/ui/Surface";
import { TextField } from "../../components/ui/TextField";
import { AppText } from "../../components/ui/Text";
import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { Goal, GoalStatus } from "../../domain/models";
import { inferGoalDraft } from "../../product/goalIntake";
import { useAppStore } from "../../state/useAppStore";

export function GoalsScreen() {
  const theme = useResolvedTheme();
  const goals = useAppStore((state) => state.goals);
  const milestones = useAppStore((state) => state.milestones);
  const allTasks = useAppStore((state) => state.allTasks);
  const domains = useAppStore((state) => state.domains);
  const createGoal = useAppStore((state) => state.createGoal);
  const updateGoal = useAppStore((state) => state.updateGoal);
  const setGoalStatus = useAppStore((state) => state.setGoalStatus);
  const planDate = useAppStore((state) => state.planDate);
  const [composerOpen, setComposerOpen] = useState(false);
  const [selectedGoalId, setSelectedGoalId] = useState<string | null>(goals[0]?.id ?? null);
  const [draftText, setDraftText] = useState("");
  const [editingGoal, setEditingGoal] = useState<Goal | null>(null);
  const [manualTitle, setManualTitle] = useState("");
  const [manualTargetDate, setManualTargetDate] = useState("");
  const [manualDomainKey, setManualDomainKey] = useState<Goal["domainKey"] | null>(null);
  const [busyState, setBusyState] = useState<string | null>(null);
  const [runtimeMessage, setRuntimeMessage] = useState<string | null>(null);

  const selectedGoal = goals.find((goal) => goal.id === selectedGoalId) ?? goals[0] ?? null;
  const selectedMilestones = selectedGoal
    ? milestones.filter((milestone) => milestone.goalId === selectedGoal.id)
    : [];
  const selectedTasks = selectedGoal ? allTasks.filter((task) => task.goalId === selectedGoal.id) : [];
  const activeGoals = goals.filter((goal) => goal.status === GoalStatus.Active);
  const pausedGoals = goals.filter((goal) => goal.status === GoalStatus.Paused);
  const archivedGoals = goals.filter((goal) => goal.status === GoalStatus.Archived);
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
    setManualTargetDate("");
    setManualDomainKey(null);
  }

  function openCreateComposer() {
    setRuntimeMessage(null);
    setEditingGoal(null);
    setDraftText("");
    setManualTitle("");
    setManualTargetDate("");
    setManualDomainKey(null);
    setComposerOpen(true);
  }

  function beginEdit(goal: Goal) {
    setRuntimeMessage(null);
    setEditingGoal(goal);
    setManualTitle(goal.title);
    setManualTargetDate(goal.targetDate ?? "");
    setManualDomainKey(goal.domainKey);
    setComposerOpen(true);
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
        targetDate: manualTargetDate.trim() || inference.targetDate,
        domainKey: manualDomainKey ?? inference.domainKey,
      });
      resetComposer();
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

    setBusyState("update");
    setRuntimeMessage(null);

    try {
      await updateGoal(editingGoal.id, {
        title: manualTitle.trim() || editingGoal.title,
        targetDate: manualTargetDate.trim() || null,
        domainKey: manualDomainKey ?? editingGoal.domainKey,
      });
      resetComposer();
    } catch (error) {
      setRuntimeMessage(
        error instanceof Error ? error.message : "The goal changes could not be saved.",
      );
    } finally {
      setBusyState(null);
    }
  }

  async function handleGoalStatus(goalId: string, status: GoalStatus) {
    setBusyState(`status:${goalId}`);
    setRuntimeMessage(null);

    try {
      await setGoalStatus(goalId, status);
    } catch (error) {
      setRuntimeMessage(
        error instanceof Error ? error.message : "The goal status could not be updated.",
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
              <AppText variant="hero">The active ambitions, without turning into CRUD.</AppText>
            </View>
            <Button tone="secondary" onPress={openCreateComposer}>
              New goal
            </Button>
          </View>

          {goals.length === 0 ? (
            <EmptyStateCard
              title="No goals yet"
              body="Add one goal in plain language. Ambitions will keep the structure compact and generate the next useful steps."
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
                      <Pill label={`${selectedTasks.length} tasks`} />
                    </View>

                    <View className="gap-3">
                      <AppText variant="caption" tone="secondary">
                        Milestones
                      </AppText>
                      {selectedMilestones.length === 0 ? (
                        <AppText tone="secondary">
                          This goal has not generated milestone structure yet.
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
                        </View>
                      ))}
                    </View>

                    <View className="gap-3">
                      <AppText variant="caption" tone="secondary">
                        Generated tasks
                      </AppText>
                      {selectedTasks.length === 0 ? (
                        <AppText tone="secondary">
                          This goal does not have task detail yet.
                        </AppText>
                      ) : null}
                      {selectedTasks.slice(0, 6).map((task) => (
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
                        </View>
                      ))}
                    </View>

                    <View className="flex-row flex-wrap gap-3">
                      {selectedGoal.status === GoalStatus.Active ? (
                        <Button
                          tone="secondary"
                          onPress={() => handleGoalStatus(selectedGoal.id, GoalStatus.Paused)}
                          busy={busyState === `status:${selectedGoal.id}`}
                        >
                          Pause
                        </Button>
                      ) : (
                        <Button
                          tone="secondary"
                          onPress={() => handleGoalStatus(selectedGoal.id, GoalStatus.Active)}
                          busy={busyState === `status:${selectedGoal.id}`}
                        >
                          Resume
                        </Button>
                      )}
                      <Button
                        tone="ghost"
                        onPress={() => handleGoalStatus(selectedGoal.id, GoalStatus.Archived)}
                        busy={busyState === `status:${selectedGoal.id}`}
                      >
                        Archive
                      </Button>
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

      <Modal
        transparent
        animationType="slide"
        visible={composerOpen}
        onRequestClose={resetComposer}
      >
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
                <TextField
                  onChangeText={setManualTitle}
                  placeholder="Goal title"
                  label="Title"
                  value={manualTitle}
                />
                <TextField
                  onChangeText={setManualTargetDate}
                  placeholder="YYYY-MM-DD"
                  label="Target date"
                  value={manualTargetDate}
                />
                <View className="gap-2">
                  <AppText variant="caption" tone="secondary">
                    Domain
                  </AppText>
                  <View className="flex-row flex-wrap gap-2">
                    {domains.map((domain) => {
                      const key =
                        manualDomainKey ?? inference?.domainKey ?? editingGoal?.domainKey;
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
                    {editingGoal ? "Save changes" : "Create goal"}
                  </Button>
                </View>
              </View>
            </ScrollView>
          </Surface>
        </View>
      </Modal>
    </>
  );
}
