import { NativeStackScreenProps } from "@react-navigation/native-stack";
import { useEffect, useMemo, useState } from "react";
import { View } from "react-native";

import {
  DetailHero,
  DetailMetaGroup,
  DetailSection,
  DetailSummaryStrip,
  QuietMetaLine,
} from "../../components/detail/DetailPrimitives";
import { CompactTimelineRow } from "../../components/navigation/CompactTimelineRow";
import { DrillInRow } from "../../components/navigation/DrillInRow";
import { Button } from "../../components/ui/Button";
import { EmptyStateCard } from "../../components/ui/EmptyStateCard";
import { OptionChip } from "../../components/ui/OptionChip";
import { Pill } from "../../components/ui/Pill";
import { Screen } from "../../components/ui/Screen";
import { Surface } from "../../components/ui/Surface";
import { AppText } from "../../components/ui/Text";
import { GoalStatus } from "../../domain/models";
import { PlanStackParamList } from "../../navigation/types";
import { getGoalReviewDraft } from "../../services/goals/metadata";
import { useAppStore } from "../../state/useAppStore";
import { formatShortDate } from "../../utils/date";

function shiftDate(date: string | null, offsetDays: number) {
  const base = date ? Date.parse(`${date}T12:00:00.000Z`) : Date.now();
  return new Date(base + offsetDays * 86400000).toISOString().slice(0, 10);
}

export function PlanDetailScreen({
  navigation,
}: NativeStackScreenProps<PlanStackParamList, "PlanDetail">) {
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
      <View className="gap-6">
        <DetailHero
          eyebrow="Plan"
          title={dailyPlan.focus}
          description={
            dailyPlan.planningNotes ?? "This is the current day shape that Ambitions is protecting."
          }
          meta={
            <DetailMetaGroup
              items={[
                { label: "Date", value: formatShortDate(dailyPlan.date) },
                {
                  label: "Sessions",
                  value: String(today?.blocks.length ?? 0),
                },
                {
                  label: "Committed",
                  value: `${dailyPlan.totalCommittedMinutes} min`,
                },
                {
                  label: "Planned",
                  value: `${dailyPlan.totalPlannedMinutes} min`,
                },
              ]}
            />
          }
        />

        <DetailSection
          title="Today’s shape"
          description="The sessions carrying the current plan."
        >
          <View className="gap-3">
            {(today?.blocks ?? []).map((block) => (
              <CompactTimelineRow
                key={block.id}
                block={block}
                onPress={() =>
                  (navigation.getParent() as any)?.navigate("Today", {
                    screen: "TodaySessionDetail",
                    params: { blockId: block.id },
                  })
                }
              />
            ))}
          </View>
        </DetailSection>

        <Surface className="gap-3 mb-0">
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
  navigation,
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
      <View className="gap-6">
        <DetailHero
          eyebrow="Plan"
          title="Generated structure"
          description="See the goal and milestone structure feeding the current plan."
        />

        {filteredGoals.length === 0 ? (
          <EmptyStateCard
            title="No active structure"
            body="There is no active goal structure to inspect right now."
          />
        ) : (
          <View className="gap-4">
            {filteredGoals.map((goal) => {
              const goalMilestones = milestones.filter((milestone) => milestone.goalId === goal.id);
              const goalTasks = tasks.filter((task) => task.goalId === goal.id);
              const upcomingMilestone =
                goalMilestones.find((milestone) => milestone.status === "in_progress") ??
                goalMilestones.find((milestone) => milestone.status === "pending") ??
                null;

              return (
                <Surface key={goal.id} className="gap-4 mb-0">
                  <View className="gap-1">
                    <AppText variant="section">{goal.title}</AppText>
                    <AppText tone="secondary">
                      {goal.summary ?? "Open the goal if you need the full milestone and task detail."}
                    </AppText>
                  </View>
                  <DetailSummaryStrip
                    items={[
                      {
                        label: "Milestones",
                        value: String(goalMilestones.length),
                        detail: upcomingMilestone
                          ? `Next: ${upcomingMilestone.title}`
                          : "No milestone queued",
                      },
                      {
                        label: "Tasks",
                        value: String(goalTasks.length),
                        detail: "Current task depth",
                      },
                    ]}
                  />
                  <View className="gap-2">
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
                  </View>
                  <Button
                    tone="inline"
                    onPress={() =>
                      (navigation.getParent() as any)?.navigate("Goals", {
                        screen: "GoalDetail",
                        params: { goalId: goal.id },
                      })
                    }
                  >
                    Open goal
                  </Button>
                </Surface>
              );
            })}
          </View>
        )}
      </View>
    </Screen>
  );
}

export function PlanReviewScreen({
  route,
  navigation,
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

  const visibleTasks = selectedReviewDraft?.tasks.filter((task) => !task.removed) ?? [];

  return (
    <Screen>
      <View className="gap-6">
        <DetailHero
          eyebrow="Plan"
          title="Review changes"
          description="See what changed, why it changed, then decide what happens next."
          badges={
            selectedReviewDraft ? (
              <>
                <Pill label={selectedReviewDraft.mode.replaceAll("_", " ")} tone="accent" />
                <Pill
                  label={`${selectedReviewDraft.impactSummary.affectedTaskCount} task changes`}
                  tone="quiet"
                />
              </>
            ) : null
          }
          action={
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
          }
        />

        {selectedGoal && selectedReviewDraft ? (
          <>
            <DetailSection
              title="Summary"
              description="The short version before you inspect details."
            >
              <Surface className="gap-4 mb-0">
                <View className="gap-2">
                  <AppText variant="title">{selectedReviewDraft.headline}</AppText>
                  <AppText tone="secondary">{selectedReviewDraft.summary}</AppText>
                </View>
                <DetailSummaryStrip
                  items={[
                    {
                      label: "Milestones affected",
                      value: String(selectedReviewDraft.impactSummary.affectedMilestoneCount),
                      detail: "Parts of the structure touched",
                    },
                    {
                      label: "Tasks affected",
                      value: String(selectedReviewDraft.impactSummary.affectedTaskCount),
                      detail: "Recommended edits",
                    },
                    {
                      label: "Protected",
                      value: String(selectedReviewDraft.impactSummary.protectedTaskCount),
                      detail: "Held steady",
                    },
                  ]}
                />
              </Surface>
            </DetailSection>

            <DetailSection
              title="Why this changed"
              description="Reasoning first, before you act."
            >
              <View className="gap-3">
                {selectedReviewDraft.rationale.map((item) => (
                  <Surface key={item} tone="sunken" className="gap-2 mb-0">
                    <AppText tone="secondary">{item}</AppText>
                  </Surface>
                ))}
              </View>
            </DetailSection>

            <DetailSection
              title="Inspect proposed work"
              description="Refine the draft without dumping the whole system onto one page."
              action={
                <Button
                  tone="inline"
                  onPress={() => navigation.navigate("PlanStructure", { goalId: selectedGoal.id })}
                >
                  Open structure
                </Button>
              }
            >
              <View className="gap-3">
                {visibleTasks.slice(0, 8).map((task) => (
                  <Surface key={task.id} className="gap-3 mb-0" tone="sunken">
                    <View className="gap-2">
                      <View className="flex-row flex-wrap items-center gap-2">
                        <Pill
                          label={task.protected ? "Protected" : task.changeLabel.replaceAll("_", " ")}
                          tone={task.protected ? "quiet" : "accent"}
                        />
                        {task.userAdjusted ? <Pill label="Adjusted" tone="quiet" /> : null}
                      </View>
                      <AppText variant="section">{task.title}</AppText>
                      <QuietMetaLine
                        items={[
                          `${task.estimatedMinutes} min`,
                          task.targetDate
                            ? `Target ${formatShortDate(task.targetDate)}`
                            : "No target date",
                        ]}
                      />
                      {task.summary ? <AppText tone="secondary">{task.summary}</AppText> : null}
                    </View>
                    {!task.protected ? (
                      <View className="flex-row flex-wrap gap-2">
                        <Button
                          tone="secondary"
                          size="compact"
                          onPress={() =>
                            void runReviewAction(
                              `move-up:${task.id}`,
                              () => moveReviewTask(selectedGoal.id, task.id, "up"),
                              "The task order could not be updated.",
                            )
                          }
                          busy={busyAction === `move-up:${task.id}`}
                        >
                          Earlier
                        </Button>
                        <Button
                          tone="secondary"
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
                          busy={busyAction === `plus:${task.id}`}
                        >
                          +15 min
                        </Button>
                        <Button
                          tone="inline"
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
                          busy={busyAction === `date-later:${task.id}`}
                        >
                          Defer a day
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
                          busy={busyAction === `remove:${task.id}`}
                        >
                          Remove
                        </Button>
                      </View>
                    ) : null}
                  </Surface>
                ))}
              </View>
            </DetailSection>

            <Surface className="gap-4 mb-0">
              <View className="gap-1">
                <AppText variant="section">Decide what happens next</AppText>
                <AppText tone="secondary" variant="caption">
                  Accept the recommendation, refine it again, or leave it for later.
                </AppText>
              </View>
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
                Accept changes
              </Button>
              <View className="flex-row flex-wrap gap-3">
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
                  Refine proposal
                </Button>
                <Button
                  tone="inline"
                  onPress={() => navigation.goBack()}
                >
                  Decide later
                </Button>
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
