import { useEffect, useMemo, useState } from "react";
import { View } from "react-native";

import { Button } from "../../components/ui/Button";
import { EmptyStateCard } from "../../components/ui/EmptyStateCard";
import { MetricCard } from "../../components/ui/MetricCard";
import { OptionChip } from "../../components/ui/OptionChip";
import { Pill } from "../../components/ui/Pill";
import { Screen } from "../../components/ui/Screen";
import { Surface } from "../../components/ui/Surface";
import { AppText } from "../../components/ui/Text";
import { GoalStatus } from "../../domain/models";
import { getGoalReviewDraft } from "../../services/goals/metadata";
import { useAppStore } from "../../state/useAppStore";

function shiftDate(date: string | null, offsetDays: number) {
  const base = date ? Date.parse(`${date}T12:00:00.000Z`) : Date.now();
  return new Date(base + offsetDays * 86400000).toISOString().slice(0, 10);
}

export function PlanScreen() {
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
        <View className="gap-6 pb-6">
          <View className="gap-2 pt-2">
            <Pill label="Plan" />
            <AppText variant="hero">The current shape of the work.</AppText>
            <AppText tone="secondary">
              Recommended structure, light rationale, and only the editing controls that need to
              exist before a plan becomes active.
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
              </View>
            </Surface>
          ) : null}

          {selectedGoal && selectedReviewDraft ? (
            <Surface>
              <View className="gap-4">
                <View className="gap-3">
                  <View className="flex-row flex-wrap gap-2">
                    <Pill label="Review surface" tone="accent" />
                    <Pill label={selectedReviewDraft.mode.replaceAll("_", " ")} />
                  </View>
                  <AppText variant="section">{selectedReviewDraft.headline}</AppText>
                  <AppText tone="secondary">{selectedReviewDraft.summary}</AppText>
                </View>

                <View className="flex-row flex-wrap gap-2">
                  <Pill
                    label={`${selectedReviewDraft.impactSummary.affectedMilestoneCount} milestone changes`}
                    tone="accent"
                  />
                  <Pill label={`${selectedReviewDraft.impactSummary.affectedTaskCount} task changes`} />
                  {selectedReviewDraft.impactSummary.protectedTaskCount > 0 ? (
                    <Pill label={`${selectedReviewDraft.impactSummary.protectedTaskCount} protected`} />
                  ) : null}
                </View>

                <View className="gap-3">
                  {selectedReviewDraft.rationale.map((item) => (
                    <Surface key={item} tone="sunken" className="gap-1">
                      <Pill label="Rationale" tone="quiet" />
                      <AppText tone="secondary">{item}</AppText>
                    </Surface>
                  ))}
                </View>

                {selectedReviewDraft.milestones.map((milestone) => {
                  const milestoneTasks = selectedReviewDraft.tasks
                    .filter((task) => task.milestoneId === milestone.id && !task.removed)
                    .sort((left, right) => left.order - right.order);

                  return (
                    <Surface
                      key={milestone.id}
                      className="gap-4"
                      tone="default"
                    >
                      <View className="gap-2">
                        <View className="flex-row flex-wrap gap-2">
                          {milestone.targetDate ? <Pill label={milestone.targetDate} /> : null}
                          {milestone.protected ? <Pill label="Protected" tone="accent" /> : null}
                          <Pill label={milestone.changeLabel} />
                        </View>
                        <AppText variant="section">{milestone.title}</AppText>
                        <AppText tone="secondary">
                          {milestone.summary ?? "Recommended milestone structure for the current goal."}
                        </AppText>
                      </View>

                      <View className="gap-3">
                        {milestoneTasks.map((task) => (
                          <Surface
                            key={task.id}
                            className="gap-3"
                            tone="sunken"
                          >
                            <View className="gap-2">
                              <View className="flex-row flex-wrap gap-2">
                                <Pill label={`${task.estimatedMinutes} min`} tone="quiet" />
                                {task.targetDate ? <Pill label={task.targetDate} /> : null}
                                {task.protected ? <Pill label="Preserved" tone="accent" /> : null}
                              </View>
                              <AppText>{task.title}</AppText>
                              {task.rationale ? (
                                <AppText tone="secondary">{task.rationale}</AppText>
                              ) : null}
                            </View>
                            {!task.protected ? (
                              <View className="mt-3 flex-row flex-wrap gap-2">
                                <Button
                                  tone="ghost"
                                  size="compact"
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
                                  size="compact"
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
                                  size="compact"
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
                                  size="compact"
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
                                  size="compact"
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
                                  size="compact"
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
                                  size="compact"
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
                          </Surface>
                        ))}
                      </View>
                    </Surface>
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
                  <View className="gap-4">
                    <View className="flex-row flex-wrap gap-2">
                      <Pill label="Today&apos;s frame" tone="accent" />
                      <Pill label={dailyPlan.date} tone="quiet" />
                    </View>
                    <AppText variant="title">{dailyPlan.focus}</AppText>
                  <AppText tone="secondary">
                    {dailyPlan.planningNotes ?? "The planner created a compact, protective day shape."}
                  </AppText>
                  <View className="flex-row gap-3">
                    <MetricCard label="Sessions" value={String(timeBlocks.length)} />
                    <MetricCard
                      label="Tasks"
                      value={String(tasks.filter((task) => task.scheduledDate === dailyPlan.date).length)}
                    />
                    <MetricCard label="Date" value={dailyPlan.date} />
                  </View>
                </View>
              </Surface>

              <Surface tone="sunken">
                <View className="gap-3">
                  <View className="flex-row flex-wrap gap-2">
                    <Pill label="Milestones" tone="accent" />
                  </View>
                  <AppText variant="section">Next milestones</AppText>
                  {nextMilestones.length === 0 ? (
                    <AppText tone="secondary">
                      The current goals do not have future milestones yet.
                    </AppText>
                  ) : null}
                  {nextMilestones.map((milestone) => {
                    const goal = goals.find((entry) => entry.id === milestone.goalId);

                    return (
                      <Surface
                        key={milestone.id}
                        className="gap-3"
                        tone="default"
                      >
                        <View className="flex-row flex-wrap gap-2">
                          <Pill label={milestone.targetDate ?? "No target date"} tone="quiet" />
                        </View>
                        <AppText>{milestone.title}</AppText>
                        <AppText tone="secondary">
                          {goal?.title ?? "Goal no longer available"}
                        </AppText>
                      </Surface>
                    );
                  })}
                </View>
              </Surface>

              <Surface>
                <View className="gap-4">
                  <View className="flex-row flex-wrap gap-2">
                    <Pill label="Continuity" tone="accent" />
                  </View>
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
                  <View className="flex-row flex-wrap gap-2">
                    <Pill
                      label={
                        calendarConnectionState?.permissionState === "granted"
                          ? "Calendar continuity on"
                          : "Calendar continuity off"
                      }
                      tone={
                        calendarConnectionState?.permissionState === "granted"
                          ? "accent"
                          : "neutral"
                      }
                    />
                    <Pill
                      label={
                        goals.some((goal) => goal.status === GoalStatus.Active)
                          ? "Active goals feeding plan"
                          : "No active goals"
                      }
                      tone="quiet"
                    />
                  </View>
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
    </Screen>
  );
}
