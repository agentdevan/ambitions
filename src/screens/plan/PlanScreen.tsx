import { useEffect, useMemo, useState } from "react";
import { View } from "react-native";

import { Button } from "../../components/ui/Button";
import { EmptyStateCard } from "../../components/ui/EmptyStateCard";
import { MetricCard } from "../../components/ui/MetricCard";
import { OptionChip } from "../../components/ui/OptionChip";
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
    if (!selectedGoalId || !goals.some((goal) => goal.id === selectedGoalId)) {
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
        <View className="gap-3 pt-2">
          <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
            Plan
          </AppText>
          <AppText variant="hero">The current shape of the work.</AppText>
          <AppText tone="secondary">
            Review what is changing, then scan the active day and what it feeds next.
          </AppText>
        </View>

        {reviewGoals.length > 0 ? (
          <Surface tone="sunken" className="gap-4">
            <View className="gap-2">
              <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                Review queue
              </AppText>
              <AppText variant="section">Recommended changes</AppText>
              <AppText tone="secondary">
                Review stays close to the work. Open the goal that needs a decision.
              </AppText>
            </View>
            <MetaLine
              items={[
                `${reviewGoals.length} review${reviewGoals.length === 1 ? "" : "s"} pending`,
              ]}
            />
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
        ) : null}

        {selectedGoal && selectedReviewDraft ? (
          <Surface className="gap-5">
            <View className="gap-3">
              <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                Review detail
              </AppText>
              <AppText variant="title">{selectedReviewDraft.headline}</AppText>
              <AppText tone="secondary">{selectedReviewDraft.summary}</AppText>
              <MetaLine
                items={[
                  selectedReviewDraft.mode.replaceAll("_", " "),
                  `${selectedReviewDraft.impactSummary.affectedMilestoneCount} milestone changes`,
                  `${selectedReviewDraft.impactSummary.affectedTaskCount} task changes`,
                  `${selectedReviewDraft.impactSummary.protectedTaskCount} protected`,
                ]}
              />
            </View>

            <View className="gap-2">
              {selectedReviewDraft.rationale.map((item) => (
                <Surface key={item} tone="sunken" className="gap-2">
                  <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                    Why
                  </AppText>
                  <AppText tone="secondary">{item}</AppText>
                </Surface>
              ))}
            </View>

            {selectedReviewDraft.milestones.map((milestone) => {
              const milestoneTasks = selectedReviewDraft.tasks
                .filter((task) => task.milestoneId === milestone.id && !task.removed)
                .sort((left, right) => left.order - right.order);

              return (
                <Surface key={milestone.id} className="gap-4" tone="default">
                  <View className="gap-2">
                    <AppText variant="section">{milestone.title}</AppText>
                    <AppText tone="secondary">
                      {milestone.summary ?? "Recommended milestone structure for this goal."}
                    </AppText>
                    <MetaLine
                      items={[
                        milestone.targetDate ? `Target ${milestone.targetDate}` : "No target date",
                        milestone.protected ? "Protected" : milestone.changeLabel,
                      ]}
                    />
                  </View>

                  <View className="gap-3">
                    {milestoneTasks.map((task) => (
                      <Surface key={task.id} className="gap-3" tone="sunken">
                        <View className="gap-2">
                          <AppText>{task.title}</AppText>
                          <MetaLine
                            items={[
                              `${task.estimatedMinutes} min`,
                              task.targetDate ? `Target ${task.targetDate}` : "No target date",
                              task.protected ? "Preserved" : "Adjustable",
                            ]}
                          />
                          {task.rationale ? (
                            <AppText tone="secondary" variant="caption">
                              {task.rationale}
                            </AppText>
                          ) : null}
                        </View>
                        {!task.protected ? (
                          <View className="flex-row flex-wrap gap-2">
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
                              tone="tertiary"
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
                Refresh
              </Button>
              <Button
                tone="tertiary"
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
          </Surface>
        ) : null}

        {dailyPlan ? (
          <>
            <Surface className="gap-4">
              <View className="gap-2">
                <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                  Today's frame
                </AppText>
                <AppText variant="title">{dailyPlan.focus}</AppText>
                <AppText tone="secondary">
                  {dailyPlan.planningNotes ?? "The planner built a compact day with room to recover."}
                </AppText>
                <MetaLine items={[dailyPlan.date, `${timeBlocks.length} sessions`]} />
              </View>
              <View className="flex-row gap-3">
                <MetricCard label="Sessions" value={String(timeBlocks.length)} />
                <MetricCard
                  label="Tasks"
                  value={String(tasks.filter((task) => task.scheduledDate === dailyPlan.date).length)}
                />
                <MetricCard label="Date" value={dailyPlan.date} />
              </View>
            </Surface>

            <Surface tone="sunken" className="gap-3">
              <View className="gap-2">
                <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                  Next up
                </AppText>
                <AppText variant="section">Upcoming milestones</AppText>
              </View>
              {nextMilestones.length === 0 ? (
                <AppText tone="secondary">
                  The current goals do not have future milestones yet.
                </AppText>
              ) : null}
              {nextMilestones.map((milestone) => {
                const goal = goals.find((entry) => entry.id === milestone.goalId);

                return (
                  <Surface key={milestone.id} className="gap-2">
                    <AppText>{milestone.title}</AppText>
                    <MetaLine
                      items={[
                        milestone.targetDate ? `Target ${milestone.targetDate}` : "No target date",
                        goal?.title ?? "Goal no longer available",
                      ]}
                    />
                  </Surface>
                );
              })}
            </Surface>

            <Surface className="gap-3">
              <View className="gap-2">
                <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                  Continuity
                </AppText>
                <AppText variant="section">What keeps the plan stable</AppText>
                <AppText tone="secondary">
                  {calendarConnectionState?.permissionState === "granted"
                    ? "Calendar access is available for live context."
                    : "Calendar access is still off, so the planner is using saved defaults."}
                </AppText>
              </View>
              <MetaLine
                items={[
                  calendarConnectionState?.permissionState === "granted"
                    ? "Calendar continuity on"
                    : "Calendar continuity off",
                  goals.some((goal) => goal.status === GoalStatus.Active)
                    ? "Active goals feeding the plan"
                    : "No active goals yet",
                ]}
              />
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
