import { NativeStackScreenProps } from "@react-navigation/native-stack";
import { useEffect, useMemo, useState } from "react";
import { View } from "react-native";

import { CompactTimelineRow } from "../../components/navigation/CompactTimelineRow";
import { Button } from "../../components/ui/Button";
import { EmptyStateCard } from "../../components/ui/EmptyStateCard";
import { OptionChip } from "../../components/ui/OptionChip";
import { Pill } from "../../components/ui/Pill";
import { Screen } from "../../components/ui/Screen";
import { Surface } from "../../components/ui/Surface";
import { AppText } from "../../components/ui/Text";
import { GoalStatus } from "../../domain/models";
import { getGoalReviewDraft } from "../../services/goals/metadata";
import { useAppStore } from "../../state/useAppStore";
import { formatShortDate } from "../../utils/date";
import { PlanStackParamList } from "../../navigation/types";

function shiftDate(date: string | null, offsetDays: number) {
  const base = date ? Date.parse(`${date}T12:00:00.000Z`) : Date.now();
  return new Date(base + offsetDays * 86400000).toISOString().slice(0, 10);
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

export function PlanDetailScreen() {
  const dailyPlan = useAppStore((state) => state.dailyPlan);
  const today = useAppStore((state) => state.today);
  const calendarConnectionState = useAppStore((state) => state.calendarConnectionState);

  if (!dailyPlan) {
    return (
      <Screen>
        <EmptyStateCard title="No active plan" body="The current plan is not available." />
      </Screen>
    );
  }

  return (
    <Screen>
      <View className="gap-5">
        <Surface tone="accent" className="gap-3">
          <AppText variant="title">{dailyPlan.focus}</AppText>
          <AppText tone="secondary">
            Open the current day shape without mixing it with review tools or settings.
          </AppText>
        </Surface>

        <Surface className="gap-4">
          <AppText variant="section">Today's sessions</AppText>
          <View className="gap-3">
            {(today?.blocks ?? []).map((block) => (
              <CompactTimelineRow key={block.id} block={block} onPress={() => null} />
            ))}
          </View>
        </Surface>

        <Surface className="gap-3">
          <AppText variant="section">Planning context</AppText>
          <AppText tone="secondary">
            {calendarConnectionState?.permissionState === "granted"
              ? "Calendar access is available for live context."
              : "Calendar access is still off, so the planner is using saved defaults."}
          </AppText>
        </Surface>
      </View>
    </Screen>
  );
}

export function PlanStructureScreen({
  route,
}: NativeStackScreenProps<PlanStackParamList, "PlanStructure">) {
  const goals = useAppStore((state) => state.goals);
  const milestones = useAppStore((state) => state.milestones);
  const tasks = useAppStore((state) => state.allTasks);

  const activeGoals = goals.filter((goal) => goal.status === GoalStatus.Active);
  const filteredGoals = route.params?.goalId
    ? activeGoals.filter((goal) => goal.id === route.params.goalId)
    : activeGoals;

  return (
    <Screen>
      <View className="gap-4">
        <Surface tone="accent" className="gap-3">
          <AppText variant="title">Generated structure</AppText>
          <AppText tone="secondary">
            This is the current planning structure feeding the plan.
          </AppText>
        </Surface>
        <View className="gap-4">
          {filteredGoals.map((goal) => {
            const goalMilestones = milestones.filter((milestone) => milestone.goalId === goal.id);
            const goalTasks = tasks.filter((task) => task.goalId === goal.id).slice(0, 5);

            return (
              <Surface key={goal.id} className="gap-3">
                <AppText variant="section">{goal.title}</AppText>
                <MetaLine
                  items={[
                    `${goalMilestones.length} milestone${goalMilestones.length === 1 ? "" : "s"}`,
                    `${goalTasks.length} preview task${goalTasks.length === 1 ? "" : "s"}`,
                  ]}
                />
                {goalMilestones.slice(0, 3).map((milestone) => (
                  <View key={milestone.id} className="gap-1">
                    <AppText>{milestone.title}</AppText>
                    <AppText tone="secondary" variant="caption">
                      {milestone.targetDate
                        ? `Target ${formatShortDate(milestone.targetDate)}`
                        : "No target date"}
                    </AppText>
                  </View>
                ))}
              </Surface>
            );
          })}
        </View>
      </View>
    </Screen>
  );
}

export function PlanReviewScreen({
  route,
}: NativeStackScreenProps<PlanStackParamList, "PlanReview">) {
  const dailyPlan = useAppStore((state) => state.dailyPlan);
  const goals = useAppStore((state) => state.goals);
  const acceptGoalReview = useAppStore((state) => state.acceptGoalReview);
  const regenerateGoalReview = useAppStore((state) => state.regenerateGoalReview);
  const moveReviewTask = useAppStore((state) => state.moveReviewTask);
  const removeReviewTask = useAppStore((state) => state.removeReviewTask);
  const adjustReviewTask = useAppStore((state) => state.adjustReviewTask);
  const [selectedGoalId, setSelectedGoalId] = useState<string | null>(route.params?.goalId ?? null);
  const [busyAction, setBusyAction] = useState<string | null>(null);
  const [runtimeMessage, setRuntimeMessage] = useState<string | null>(null);

  const reviewGoals = useMemo(
    () => goals.filter((goal) => getGoalReviewDraft(goal) !== null),
    [goals],
  );

  useEffect(() => {
    if (!selectedGoalId || !reviewGoals.some((goal) => goal.id === selectedGoalId)) {
      setSelectedGoalId(reviewGoals[0]?.id ?? null);
    }
  }, [reviewGoals, selectedGoalId]);

  const selectedGoal = reviewGoals.find((goal) => goal.id === selectedGoalId) ?? null;
  const selectedReviewDraft = selectedGoal ? getGoalReviewDraft(selectedGoal) : null;

  async function runReviewAction(
    key: string,
    action: () => Promise<void>,
    fallbackError: string,
  ) {
    setBusyAction(key);
    setRuntimeMessage(null);

    try {
      await action();
    } catch (error) {
      setRuntimeMessage(error instanceof Error ? error.message : fallbackError);
    } finally {
      setBusyAction(null);
    }
  }

  if (reviewGoals.length === 0) {
    return (
      <Screen>
        <EmptyStateCard
          title="Nothing to review"
          body={dailyPlan ? "The active plan is current right now." : "No review queue is available."}
        />
      </Screen>
    );
  }

  return (
    <Screen>
      <View className="gap-5">
        <Surface tone="accent" className="gap-3">
          <AppText variant="title">Review changes</AppText>
          <AppText tone="secondary">
            Make the decision here so the main plan screen stays focused on summary.
          </AppText>
          <View className="flex-row flex-wrap gap-2">
            {reviewGoals.map((goal) => (
              <OptionChip
                key={goal.id}
                selected={selectedGoalId === goal.id}
                compact
                onPress={() => setSelectedGoalId(goal.id)}
              >
                {goal.title}
              </OptionChip>
            ))}
          </View>
        </Surface>

        {selectedGoal && selectedReviewDraft ? (
          <Surface className="gap-5">
            <View className="gap-3">
              <View className="flex-row flex-wrap items-center gap-2">
                <Pill label={selectedReviewDraft.mode.replaceAll("_", " ")} tone="accent" />
                <Pill
                  label={`${selectedReviewDraft.impactSummary.affectedTaskCount} task changes`}
                  tone="quiet"
                />
              </View>
              <AppText variant="title">{selectedReviewDraft.headline}</AppText>
              <AppText tone="secondary">{selectedReviewDraft.summary}</AppText>
              <MetaLine
                items={[
                  `${selectedReviewDraft.impactSummary.affectedMilestoneCount} milestone changes`,
                  `${selectedReviewDraft.impactSummary.protectedTaskCount} protected`,
                ]}
              />
            </View>

            <View className="gap-2">
              {selectedReviewDraft.rationale.map((item) => (
                <Surface key={item} tone="sunken" className="gap-2">
                  <AppText tone="secondary">{item}</AppText>
                </Surface>
              ))}
            </View>

            {selectedReviewDraft.tasks.slice(0, 8).map((task) => (
              <Surface key={task.id} className="gap-3" tone="sunken">
                <View className="gap-2">
                  <AppText variant="section">{task.title}</AppText>
                  <MetaLine
                    items={[
                      `${task.estimatedMinutes} min`,
                      task.targetDate ? `Target ${formatShortDate(task.targetDate)}` : "No target date",
                      task.protected ? "Preserved" : "Adjustable",
                    ]}
                  />
                </View>
                {!task.protected ? (
                  <View className="flex-row flex-wrap gap-2">
                    <Button
                      tone="tertiary"
                      size="compact"
                      onPress={() =>
                        void runReviewAction(
                          `move-up:${task.id}`,
                          () => moveReviewTask(selectedGoal.id, task.id, "up"),
                          "The task order could not be updated.",
                        )
                      }
                    >
                      Earlier
                    </Button>
                    <Button
                      tone="tertiary"
                      size="compact"
                      onPress={() =>
                        void runReviewAction(
                          `move-down:${task.id}`,
                          () => moveReviewTask(selectedGoal.id, task.id, "down"),
                          "The task order could not be updated.",
                        )
                      }
                    >
                      Later
                    </Button>
                    <Button
                      tone="tertiary"
                      size="compact"
                      onPress={() =>
                        void runReviewAction(
                          `plus:${task.id}`,
                          () =>
                            adjustReviewTask(selectedGoal.id, task.id, {
                              estimatedMinutes: task.estimatedMinutes + 15,
                            }),
                          "The task duration could not be adjusted.",
                        )
                      }
                    >
                      +15 min
                    </Button>
                    <Button
                      tone="tertiary"
                      size="compact"
                      onPress={() =>
                        void runReviewAction(
                          `date-later:${task.id}`,
                          () =>
                            adjustReviewTask(selectedGoal.id, task.id, {
                              targetDate: shiftDate(task.targetDate, 1),
                            }),
                          "The task timing could not be adjusted.",
                        )
                      }
                    >
                      Move later
                    </Button>
                    <Button
                      tone="inline"
                      size="compact"
                      onPress={() =>
                        void runReviewAction(
                          `remove:${task.id}`,
                          () => removeReviewTask(selectedGoal.id, task.id),
                          "The task could not be removed from review.",
                        )
                      }
                    >
                      Remove
                    </Button>
                  </View>
                ) : null}
              </Surface>
            ))}

            <View className="flex-row flex-wrap gap-3">
              <Button
                onPress={() =>
                  void runReviewAction(
                    `accept:${selectedGoal.id}`,
                    () => acceptGoalReview(selectedGoal.id),
                    "The recommended plan could not be accepted.",
                  )
                }
                busy={busyAction === `accept:${selectedGoal.id}`}
              >
                Approve changes
              </Button>
              <Button
                tone="secondary"
                onPress={() =>
                  void runReviewAction(
                    `refresh:${selectedGoal.id}`,
                    () => regenerateGoalReview(selectedGoal.id),
                    "The recommendation could not be refreshed.",
                  )
                }
                busy={busyAction === `refresh:${selectedGoal.id}`}
              >
                Refresh proposal
              </Button>
            </View>
          </Surface>
        ) : null}

        {runtimeMessage ? (
          <AppText tone="tertiary" variant="caption">
            {runtimeMessage}
          </AppText>
        ) : null}
      </View>
    </Screen>
  );
}
