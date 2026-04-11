import { useMemo, useState } from "react";
import { Modal, Pressable, ScrollView, TextInput, View } from "react-native";

import { Button } from "../../components/ui/Button";
import { Pill } from "../../components/ui/Pill";
import { Screen } from "../../components/ui/Screen";
import { Surface } from "../../components/ui/Surface";
import { AppText } from "../../components/ui/Text";
import { Goal, GoalStatus } from "../../domain/models";
import { inferGoalDraft } from "../../product/goalIntake";
import { useAppStore } from "../../state/useAppStore";

export function GoalsScreen() {
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

  const selectedGoal = goals.find((goal) => goal.id === selectedGoalId) ?? goals[0] ?? null;
  const selectedMilestones = selectedGoal
    ? milestones.filter((milestone) => milestone.goalId === selectedGoal.id)
    : [];
  const selectedTasks = selectedGoal
    ? allTasks.filter((task) => task.goalId === selectedGoal.id)
    : [];
  const activeGoals = goals.filter((goal) => goal.status === GoalStatus.Active);
  const pausedGoals = goals.filter((goal) => goal.status === GoalStatus.Paused);
  const archivedGoals = goals.filter((goal) => goal.status === GoalStatus.Archived);
  const inference = useMemo(
    () => (draftText.trim().length > 0 ? inferGoalDraft(draftText, planDate) : null),
    [draftText, planDate],
  );

  const handleCreate = async () => {
    if (!inference) {
      return;
    }

    await createGoal({
      ...inference,
      title: manualTitle.trim() || inference.title,
      targetDate: manualTargetDate.trim() || inference.targetDate,
      domainKey: manualDomainKey ?? inference.domainKey,
    });
    setDraftText("");
    setManualTitle("");
    setManualTargetDate("");
    setManualDomainKey(null);
    setComposerOpen(false);
  };

  const beginEdit = (goal: Goal) => {
    setEditingGoal(goal);
    setManualTitle(goal.title);
    setManualTargetDate(goal.targetDate ?? "");
    setManualDomainKey(goal.domainKey);
    setComposerOpen(true);
  };

  const handleUpdate = async () => {
    if (!editingGoal) {
      return;
    }

    await updateGoal(editingGoal.id, {
      title: manualTitle.trim() || editingGoal.title,
      targetDate: manualTargetDate.trim() || null,
      domainKey: manualDomainKey ?? editingGoal.domainKey,
    });
    setEditingGoal(null);
    setManualDomainKey(null);
    setComposerOpen(false);
  };

  return (
    <>
      <Screen>
        <View className="gap-6">
          <View className="flex-row items-end justify-between gap-4 pt-2">
            <View className="flex-1 gap-2">
              <Pill label="Goals" />
              <AppText variant="hero">The active ambitions, without turning into CRUD.</AppText>
            </View>
            <Button tone="secondary" onPress={() => setComposerOpen(true)}>
              New goal
            </Button>
          </View>

          {goals.length === 0 ? (
            <Surface>
              <View className="gap-3">
                <AppText variant="section">No goals yet</AppText>
                <AppText tone="secondary">
                  Add one goal in plain language. Ambitions will keep the structure compact.
                </AppText>
                <Button tone="secondary" onPress={() => setComposerOpen(true)}>
                  Create a goal
                </Button>
              </View>
            </Surface>
          ) : (
            <>
              <Surface>
                <View className="gap-4">
                  <AppText variant="section">Active</AppText>
                  {activeGoals.map((goal) => (
                    <Pressable
                      key={goal.id}
                      className="rounded-[24px] border px-4 py-4"
                      onPress={() => setSelectedGoalId(goal.id)}
                      style={{
                        borderColor: selectedGoal?.id === goal.id ? "#18181A" : "#DDD8D0",
                        backgroundColor: "#F8F6F1",
                      }}
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
                  ))}
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
                      {selectedMilestones.map((milestone) => (
                        <View
                          key={milestone.id}
                          className="rounded-[22px] border border-[#DED7CB] bg-[#F8F6F1] px-4 py-4"
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
                      {selectedTasks.slice(0, 6).map((task) => (
                        <View
                          key={task.id}
                          className="rounded-[22px] border border-[#DED7CB] bg-[#F8F6F1] px-4 py-4"
                        >
                          <AppText>{task.title}</AppText>
                          <AppText tone="tertiary" variant="caption" style={{ marginTop: 6 }}>
                            {task.estimatedMinutes} min
                            {task.targetDate ? ` · ${task.targetDate}` : ""}
                          </AppText>
                        </View>
                      ))}
                    </View>
                    <View className="flex-row flex-wrap gap-3">
                      {selectedGoal.status === GoalStatus.Active ? (
                        <Button
                          tone="secondary"
                          onPress={() => setGoalStatus(selectedGoal.id, GoalStatus.Paused)}
                        >
                          Pause
                        </Button>
                      ) : (
                        <Button
                          tone="secondary"
                          onPress={() => setGoalStatus(selectedGoal.id, GoalStatus.Active)}
                        >
                          Resume
                        </Button>
                      )}
                      <Button
                        tone="ghost"
                        onPress={() => setGoalStatus(selectedGoal.id, GoalStatus.Archived)}
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
                        className="rounded-[22px] border border-[#DED7CB] bg-[#F8F6F1] px-4 py-4"
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
        </View>
      </Screen>

      <Modal
        transparent
        animationType="slide"
        visible={composerOpen}
        onRequestClose={() => setComposerOpen(false)}
      >
        <View className="flex-1 justify-end bg-[#00000033]">
          <Surface style={{ borderBottomLeftRadius: 0, borderBottomRightRadius: 0 }}>
            <ScrollView showsVerticalScrollIndicator={false}>
              <View className="gap-4 pb-6">
                <AppText variant="title">{editingGoal ? "Edit goal" : "Add a goal"}</AppText>
                {!editingGoal ? (
                  <TextInput
                    multiline
                    onChangeText={setDraftText}
                    placeholder="Build a focused TypeScript systems study plan over the next six weeks."
                    placeholderTextColor="#8A8680"
                    style={multilineFieldStyle}
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
                <TextInput
                  onChangeText={setManualTitle}
                  placeholder="Goal title"
                  placeholderTextColor="#8A8680"
                  style={fieldStyle}
                  value={manualTitle}
                />
                <TextInput
                  onChangeText={setManualTargetDate}
                  placeholder="Target date (optional)"
                  placeholderTextColor="#8A8680"
                  style={fieldStyle}
                  value={manualTargetDate}
                />
                <View className="flex-row flex-wrap gap-2">
                  {domains.map((domain) => {
                    const key = manualDomainKey ?? inference?.domainKey ?? editingGoal?.domainKey;
                    const selected = key === domain.key;

                    return (
                      <Pressable
                        key={`domain-select-${domain.id}`}
                        className="rounded-full border px-4 py-3"
                        onPress={() => setManualDomainKey(domain.key)}
                        style={{
                          backgroundColor: selected ? "#18181A" : "#F8F6F1",
                          borderColor: selected ? "#18181A" : "#DDD8D0",
                        }}
                      >
                        <AppText
                          tone={selected ? "inverse" : "secondary"}
                          variant="caption"
                        >
                          {domain.name}
                        </AppText>
                      </Pressable>
                    );
                  })}
                </View>
                <View className="flex-row gap-3">
                  <Button tone="ghost" style={{ flex: 1 }} onPress={() => setComposerOpen(false)}>
                    Cancel
                  </Button>
                  <Button
                    style={{ flex: 1 }}
                    onPress={editingGoal ? handleUpdate : handleCreate}
                    disabled={!editingGoal && !inference}
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

const fieldStyle = {
  minHeight: 52,
  borderRadius: 22,
  borderWidth: 1,
  borderColor: "#DDD8D0",
  backgroundColor: "#F8F6F1",
  paddingHorizontal: 16,
  paddingVertical: 14,
  color: "#18181A",
  fontSize: 15,
} as const;

const multilineFieldStyle = {
  ...fieldStyle,
  minHeight: 110,
  paddingVertical: 16,
  textAlignVertical: "top" as const,
} as const;
