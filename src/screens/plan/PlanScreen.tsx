import { useEffect, useMemo, useState } from "react";
import { ScrollView, View } from "react-native";

import { Button } from "../../components/ui/Button";
import { EmptyStateCard } from "../../components/ui/EmptyStateCard";
import { Pill } from "../../components/ui/Pill";
import { Screen } from "../../components/ui/Screen";
import { Surface } from "../../components/ui/Surface";
import { AppText } from "../../components/ui/Text";
import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { GoalStatus } from "../../domain/models";
import { getGoalReviewDraft } from "../../services/goals/metadata";
import { useAppStore } from "../../state/useAppStore";

function shiftDate(date: string | null, offsetDays: number) {
  const base = date ? Date.parse(`${date}T12:00:00.000Z`) : Date.now();
  return new Date(base + offsetDays * 86400000).toISOString().slice(0, 10);
}

export function PlanScreen() {
  const theme = useResolvedTheme();
  const dailyPlan = useAppStore((state) => state.dailyPlan);
  const timeBlocks = useAppStore((state) => state.timeBlocksForSelectedDate);
  const goals = useAppStore((state) => state.goals);
  const milestones = useAppStore((state) => state.milestones);
  const tasks = useAppStore((state) => state.allTasks);
  const calendarConnectionState = useAppStore((state) => state.calendarConnectionState);
  const acceptGoalReview = useAppStore((state) => state.acceptGoalReview);
  const regenerateGoalReview = useAppStore((state) => state.regenerateGoalReview);
  const moveReviewTask = useAppStore((state) => state.moveReviewTask);
  const removeReviewTask = useAppStore((state) => state.removeReviewTask);
  const adjustReviewTask = useAppStore((state) => state.adjustReviewTask);
  const [selectedGoalId, setSelectedGoalId] = useState<string | null>(null);
  const [busyAction, setBusyAction] = useState<string | null>(null);
  const [runtimeMessage, setRuntimeMessage] = useState<string | null>(null);

  const reviewGoals = useMemo(
    () => goals.filter((goal) => getGoalReviewDraft(goal) !== null),
    [goals],
  );

  useEffect(() => {
    if (
      !selectedGoalId ||
      !goals.some((goal) => goal.id === selectedGoalId)
    ) {
      setSelectedGoalId(reviewGoals[0]?.id ?? goals[0]?.id ?? null);
    }
  }, [goals, reviewGoals, selectedGoalId]);

  const selectedGoal = goals.find((goal) => goal.id === selectedGoalId) ?? null;
  const selectedReviewDraft = selectedGoal ? getGoalReviewDraft(selectedGoal) : null;
  const nextMilestones = milestones.slice(0, 5);

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

  if (!dailyPlan && reviewGoals.length === 0) {
    return (
      <Screen>
        <EmptyStateCard
          eyebrow="Plan"
          title="No generated plan yet"
          body="Finish onboarding, add a goal, or review a pending recommendation first."
        />
      </Screen>
    );
  }

  return (
    <Screen>
      <ScrollView showsVerticalScrollIndicator={false}>
        <View className="gap-6 pb-6">
          <View className="gap-2 pt-2">
            <Pill label="Plan" />
            <AppText variant="hero">The current shape of the work.</AppText>
            <AppText tone="secondary">
              Recommended structure, light rationale, and just enough editing power before a plan becomes active.
            </AppText>
          </View>

          {reviewGoals.length > 0 ? (
            <Surface tone="sunken">
              <View className="gap-4">
                <View className="flex-row flex-wrap gap-2">
                  <Pill label={`${reviewGoals.length} review${reviewGoals.length === 1 ? "" : "s"} pending`} tone="accent" />
                </View>
                <AppText tone="secondary">
                  Review stays inline when the recommendation is simple, and opens into a fuller surface here when it needs a little shaping.
                </AppText>
                <View className="flex-row flex-wrap gap-2">
                  {reviewGoals.map((goal) => (
                    <Button
                      key={goal.id}
                      tone={selectedGoalId === goal.id ? "primary" : "secondary"}
                      onPress={() => setSelectedGoalId(goal.id)}
                    >
                      {goal.title}
                    </Button>
                  ))}
                </View>
              </View>
            </Surface>
          ) : null}

          {selectedGoal && selectedReviewDraft ? (
            <Surface>
              <View className="gap-4">
                <View className="gap-2">
                  <AppText variant="section">{selectedReviewDraft.headline}</AppText>
                  <AppText tone="secondary">{selectedReviewDraft.summary}</AppText>
                </View>

                <View className="flex-row flex-wrap gap-2">
                  <Pill label={selectedReviewDraft.mode.replaceAll("_", " ")} />
                  <Pill
                    label={`${selectedReviewDraft.impactSummary.affectedMilestoneCount} milestone changes`}
                    tone="accent"
                  />
                  <Pill label={`${selectedReviewDraft.impactSummary.affectedTaskCount} task changes`} />
                  {selectedReviewDraft.impactSummary.protectedTaskCount > 0 ? (
                    <Pill label={`${selectedReviewDraft.impactSummary.protectedTaskCount} protected`} />
                  ) : null}
                </View>

                <View className="gap-2">
                  {selectedReviewDraft.rationale.map((item) => (
                    <AppText key={item} tone="secondary">
                      {item}
                    </AppText>
                  ))}
                </View>

                {selectedReviewDraft.milestones.map((milestone) => {
                  const milestoneTasks = selectedReviewDraft.tasks
                    .filter((task) => task.milestoneId === milestone.id && !task.removed)
                    .sort((left, right) => left.order - right.order);

                  return (
                    <View
                      key={milestone.id}
                      className="rounded-[22px] px-4 py-4"
                      style={{
                        borderWidth: 1,
                        borderColor: theme.colors.border.subtle,
                        backgroundColor: theme.colors.background.elevated,
                      }}
                    >
                      <View className="gap-2">
                        <AppText variant="section">{milestone.title}</AppText>
                        <AppText tone="secondary">
                          {milestone.summary ?? "Recommended milestone structure for the current goal."}
                        </AppText>
                        <View className="flex-row flex-wrap gap-2">
                          {milestone.targetDate ? <Pill label={milestone.targetDate} /> : null}
                          {milestone.protected ? <Pill label="Protected" tone="accent" /> : null}
                          <Pill label={milestone.changeLabel} />
                        </View>
                      </View>

                      <View className="mt-4 gap-3">
                        {milestoneTasks.map((task) => (
                          <View
                            key={task.id}
                            className="rounded-[18px] px-4 py-4"
                            style={{
                              borderWidth: 1,
                              borderColor: theme.colors.border.subtle,
                              backgroundColor: theme.colors.background.canvas,
                            }}
                          >
                            <View className="gap-2">
                              <AppText>{task.title}</AppText>
                              <AppText tone="tertiary" variant="caption">
                                {task.estimatedMinutes} min
                                {task.targetDate ? ` | ${task.targetDate}` : ""}
                                {task.protected ? " | protected" : ""}
                              </AppText>
                              {task.rationale ? (
                                <AppText tone="secondary">{task.rationale}</AppText>
                              ) : null}
                            </View>
                            {!task.protected ? (
                              <View className="mt-3 flex-row flex-wrap gap-2">
                                <Button
                                  tone="ghost"
                                  onPress={() =>
                                    runReviewAction(
                                      `move-up:${task.id}`,
                                      () => moveReviewTask(selectedGoal.id, task.id, "up"),
                                      "The task order could not be updated.",
                                    )
                                  }
                                >
                                  Earlier
                                </Button>
                                <Button
                                  tone="ghost"
                                  onPress={() =>
                                    runReviewAction(
                                      `move-down:${task.id}`,
                                      () => moveReviewTask(selectedGoal.id, task.id, "down"),
                                      "The task order could not be updated.",
                                    )
                                  }
                                >
                                  Later
                                </Button>
                                <Button
                                  tone="ghost"
                                  onPress={() =>
                                    runReviewAction(
                                      `minus:${task.id}`,
                                      () =>
                                        adjustReviewTask(selectedGoal.id, task.id, {
                                          estimatedMinutes: Math.max(10, task.estimatedMinutes - 15),
                                        }),
                                      "The task duration could not be adjusted.",
                                    )
                                  }
                                >
                                  -15 min
                                </Button>
                                <Button
                                  tone="ghost"
                                  onPress={() =>
                                    runReviewAction(
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
                                  tone="ghost"
                                  onPress={() =>
                                    runReviewAction(
                                      `date-earlier:${task.id}`,
                                      () =>
                                        adjustReviewTask(selectedGoal.id, task.id, {
                                          targetDate: shiftDate(task.targetDate, -1),
                                        }),
                                      "The task timing could not be adjusted.",
                                    )
                                  }
                                >
                                  Move earlier
                                </Button>
                                <Button
                                  tone="ghost"
                                  onPress={() =>
                                    runReviewAction(
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
                                  tone="ghost"
                                  onPress={() =>
                                    runReviewAction(
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
                          </View>
                        ))}
                      </View>
                    </View>
                  );
                })}

                <View className="flex-row flex-wrap gap-3">
                  <Button
                    onPress={() =>
                      runReviewAction(
                        `accept:${selectedGoal.id}`,
                        () => acceptGoalReview(selectedGoal.id),
                        "The recommended plan could not be accepted.",
                      )
                    }
                    busy={busyAction === `accept:${selectedGoal.id}`}
                  >
                    Accept recommendation
                  </Button>
                  <Button
                    tone="secondary"
                    onPress={() =>
                      runReviewAction(
                        `refresh:${selectedGoal.id}`,
                        () => regenerateGoalReview(selectedGoal.id),
                        "The recommendation could not be refreshed.",
                      )
                    }
                    busy={busyAction === `refresh:${selectedGoal.id}`}
                  >
                    Refresh recommendation
                  </Button>
                  <Button
                    tone="ghost"
                    onPress={() =>
                      runReviewAction(
                        `full:${selectedGoal.id}`,
                        () => regenerateGoalReview(selectedGoal.id, "full_regeneration"),
                        "The full refresh could not be prepared.",
                      )
                    }
                    busy={busyAction === `full:${selectedGoal.id}`}
                  >
                    Full refresh
                  </Button>
                </View>
              </View>
            </Surface>
          ) : null}

          {dailyPlan ? (
            <>
              <Surface>
                <View className="gap-3">
                  <AppText variant="section">Today&apos;s frame</AppText>
                  <AppText>{dailyPlan.focus}</AppText>
                  <AppText tone="secondary">
                    {dailyPlan.planningNotes ?? "The planner created a compact, protective day shape."}
                  </AppText>
                  <View className="flex-row flex-wrap gap-2">
                    <Pill label={`${timeBlocks.length} blocks`} tone="accent" />
                    <Pill
                      label={`${
                        tasks.filter((task) => task.scheduledDate === dailyPlan.date).length
                      } scheduled tasks`}
                    />
                    <Pill label={dailyPlan.date} />
                  </View>
                </View>
              </Surface>

              <Surface tone="sunken">
                <View className="gap-3">
                  <AppText variant="section">Next milestones</AppText>
                  {nextMilestones.length === 0 ? (
                    <AppText tone="secondary">
                      The current goals do not have future milestones yet.
                    </AppText>
                  ) : null}
                  {nextMilestones.map((milestone) => {
                    const goal = goals.find((entry) => entry.id === milestone.goalId);

                    return (
                      <View
                        key={milestone.id}
                        className="rounded-[22px] px-4 py-4"
                        style={{
                          borderWidth: 1,
                          borderColor: theme.colors.border.subtle,
                          backgroundColor: theme.colors.background.elevated,
                        }}
                      >
                        <AppText>{milestone.title}</AppText>
                        <AppText tone="secondary" style={{ marginTop: 6 }}>
                          {goal?.title ?? "Goal no longer available"}
                        </AppText>
                        <AppText tone="tertiary" variant="caption" style={{ marginTop: 6 }}>
                          {milestone.targetDate ?? "No target date"}
                        </AppText>
                      </View>
                    );
                  })}
                </View>
              </Surface>

              <Surface>
                <View className="gap-3">
                  <AppText variant="section">Continuity</AppText>
                  <AppText tone="secondary">
                    {calendarConnectionState?.permissionState === "granted"
                      ? "Calendar access is available for live context."
                      : "Calendar access is still off, so the planner is using schedule defaults only."}
                  </AppText>
                  <AppText tone="secondary">
                    {goals.some((goal) => goal.status === GoalStatus.Active)
                      ? "Active goals are feeding future milestones and task generation."
                      : "There are no active goals feeding future planning yet."}
                  </AppText>
                </View>
              </Surface>
            </>
          ) : null}

          {runtimeMessage ? (
            <AppText tone="tertiary" variant="caption">
              {runtimeMessage}
            </AppText>
          ) : null}
        </View>
      </ScrollView>
    </Screen>
  );
}
