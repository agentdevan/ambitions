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
import { buildPlanWorkspaceViewModel, PlanDaySummary, PlanStructureItem } from "../../state/viewModels/plan";
import { formatShortDate } from "../../utils/date";

function shiftDate(date: string | null, offsetDays: number) {
  const base = date ? Date.parse(`${date}T12:00:00.000Z`) : Date.now();
  return new Date(base + offsetDays * 86400000).toISOString().slice(0, 10);
}

export function PlanDetailScreen({
  navigation,
}: NativeStackScreenProps<PlanStackParamList, "PlanDetail">) {
  const planDate = useAppStore((state) => state.planDate);
  const goals = useAppStore((state) => state.goals);
  const preferences = useAppStore((state) => state.userPreferences);
  const adaptationProfile = useAppStore((state) => state.adaptationProfile);
  const dailyPlans = useAppStore((state) => state.dailyPlans);
  const allTimeBlocks = useAppStore((state) => state.allTimeBlocks);
  const allTasks = useAppStore((state) => state.allTasks);
  const currentWeekReview = useAppStore((state) => state.currentWeekReview);
  const currentMonthReview = useAppStore((state) => state.currentMonthReview);
  const calendarConnectionState = useAppStore((state) => state.calendarConnectionState);
  const weekScheduleConstraints = useAppStore((state) => state.weekScheduleConstraints);

  const workspace = useMemo(
    () =>
      buildPlanWorkspaceViewModel({
        date: planDate,
        goals,
        preferences,
        adaptationProfile,
        dailyPlans,
        timeBlocks: allTimeBlocks,
        tasks: allTasks,
        weekScheduleConstraints,
        currentWeekReview,
        currentMonthReview,
        calendarConnectionState,
      }),
    [
      adaptationProfile,
      allTasks,
      allTimeBlocks,
      calendarConnectionState,
      currentMonthReview,
      currentWeekReview,
      dailyPlans,
      goals,
      planDate,
      preferences,
      weekScheduleConstraints,
    ],
  );

  if (!workspace) {
    return (
      <Screen>
        <EmptyStateCard title="No active plan" body="The weekly structure is not available." />
      </Screen>
    );
  }

  return (
    <Screen>
      <View className="gap-6">
        <DetailHero
          eyebrow="Plan"
          title={workspace.heroTitle}
          description={workspace.heroDetail}
          badges={
            <>
              <Pill label={workspace.weekLabel} tone="accent" />
              <Pill label={workspace.pressureLabel} tone={workspace.pressureTone} />
              <Pill label={workspace.strategySummary.sourceLabel} tone="quiet" />
            </>
          }
          meta={
            <DetailMetaGroup
              items={[
                { label: "Week", value: workspace.weekLabel },
                {
                  label: "Fixed",
                  value: String(workspace.structureSummary.fixedCommitmentCount),
                },
                {
                  label: "Placed",
                  value: `${workspace.capacitySummary.scheduledWorkMinutes} min`,
                },
                {
                  label: "Open",
                  value: `${workspace.capacitySummary.openCapacityMinutes} min`,
                },
              ]}
            />
          }
        />

        <DetailSection
          title="Week line"
          description="See where the week is anchored, protected, or already getting tight."
        >
          <View className="gap-3">
            {workspace.days.map((day) => (
              <WeekShapeCard key={day.date} day={day} />
            ))}
          </View>
        </DetailSection>

        <DetailSection
          title="Fixed vs flexible"
          description="This is the structural split between what the week owes and what the week is still negotiating."
        >
          <View className="gap-4">
            <DetailSummaryStrip
              items={[
                {
                  label: "Flexible work",
                  value: String(workspace.structureSummary.flexibleWorkCount),
                  detail: "Important work still shaping the week",
                },
                {
                  label: "Optional work",
                  value: String(workspace.structureSummary.optionalWorkCount),
                  detail: "Should stay negotiable",
                },
                {
                  label: "Carryover",
                  value: String(workspace.structureSummary.carryoverCount),
                  detail: "Entered from prior weeks",
                },
                {
                  label: "Pressure",
                  value: String(workspace.structureSummary.underPressureCount),
                  detail: "Needs a cleaner decision",
                },
              ]}
            />
            <PlanStructureList
              title="Fixed commitments"
              empty="No fixed commitments are anchoring the week yet."
              items={workspace.fixedCommitments}
            />
            <PlanStructureList
              title="Flexible work"
              empty="No meaningful work is waiting for placement right now."
              items={workspace.flexibleWork}
            />
            <PlanStructureList
              title="Optional or stretch"
              empty="Stretch work is not taking room in the week."
              items={workspace.optionalWork}
            />
          </View>
        </DetailSection>

        <DetailSection
          title="Carryover and pressure"
          description="Unfinished work should either be protected on purpose or sent back through review."
        >
          <View className="gap-4">
            <AppText tone="secondary" variant="caption">
              {workspace.carryoverSummary.detail}
            </AppText>
            <PlanStructureList
              title="Carryover in play"
              empty="No carryover is actively pressuring this week."
              items={workspace.carryoverItems}
            />
            <PlanStructureList
              title="Work under pressure"
              empty="Nothing is currently flashing as likely to slip."
              items={workspace.pressureItems}
            />
          </View>
        </DetailSection>

        <DetailSection
          title="Protected focus"
          description="Protected depth should be visible, not assumed."
        >
          <View className="gap-4">
            <DetailSummaryStrip
              items={[
                {
                  label: "Focus blocks",
                  value: String(workspace.structureSummary.protectedFocusBlockCount),
                  detail: `${workspace.structureSummary.protectedFocusMinutes} min protected`,
                },
                {
                  label: "Largest window",
                  value: workspace.capacitySummary.largestOpenWindowLabel ?? "No clear window",
                  detail: workspace.capacitySummary.fragmentationLabel,
                },
              ]}
            />
            <PlanStructureList
              title="Protected sessions"
              empty="No meaningful focus blocks are protected yet."
              items={workspace.protectedFocusItems}
            />
          </View>
        </DetailSection>

        <Surface className="gap-3 mb-0">
          <AppText variant="section">Planning context</AppText>
          <QuietMetaLine items={workspace.structuralReads} />
          <AppText tone="secondary">
            {workspace.strategySummary.detail}{" "}
            {calendarConnectionState?.permissionState === "granted"
              ? "Calendar access is available for live context."
              : "Calendar access is still off, so fixed commitments may be understated."}
          </AppText>
          <DrillInRow
            title="Weekly shaping"
            subtitle={workspace.strategySummary.sourceLabel}
            detail={workspace.strategySummary.weeklyShape}
            actionLabel="Open"
            onPress={() =>
              (navigation.getParent() as any)?.navigate("Insights", {
                screen: "InsightsHome",
              })
            }
          />
        </Surface>
      </View>
    </Screen>
  );
}

function WeekShapeCard({ day }: { day: PlanDaySummary }) {
  return (
    <Surface tone="sunken" className="gap-2 mb-0">
      <View className="flex-row items-start justify-between gap-3">
        <View className="flex-1 gap-1">
          <AppText variant="section">{day.label}</AppText>
          <AppText tone="secondary" variant="caption">
            {day.fixedCount > 0 ? `${day.fixedCount} fixed commitments` : "No fixed commitments"}
          </AppText>
        </View>
        <View className="items-end gap-1">
          <AppText variant="caption">{day.openMinutes} min open</AppText>
          <AppText tone={day.isTight ? "accent" : "tertiary"} variant="micro">
            {day.isTight ? "Tight" : `${day.meaningfulWindowCount} windows`}
          </AppText>
        </View>
      </View>
      <QuietMetaLine
        items={[
          day.scheduledMinutes > 0 ? `${day.scheduledMinutes} min placed` : "Nothing placed yet",
          day.focusMinutes > 0 ? `${day.focusMinutes} min focus protected` : "No focus protected yet",
        ]}
      />
    </Surface>
  );
}

function PlanStructureList({
  title,
  empty,
  items,
}: {
  title: string;
  empty: string;
  items: PlanStructureItem[];
}) {
  return (
    <View className="gap-2.5">
      <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
        {title}
      </AppText>
      {items.length > 0 ? (
        <View className="gap-2">
          {items.map((item) => (
            <View key={item.id} className="gap-1">
              <AppText>{item.title}</AppText>
              <AppText tone="secondary" variant="caption">
                {item.detail}
              </AppText>
              <AppText tone="tertiary" variant="micro">
                {item.supporting}
              </AppText>
            </View>
          ))}
        </View>
      ) : (
        <AppText tone="secondary" variant="caption">
          {empty}
        </AppText>
      )}
    </View>
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
          description="Goals, milestones, tasks."
        />

        {filteredGoals.length === 0 ? (
          <EmptyStateCard
            title="No active structure"
            body="No active structure."
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
          body={dailyPlan ? "The plan is current." : "No review queue."}
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
          description="What changed and why."
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
              description="Short version."
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
              description="Why it shifted."
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
              description="Adjust the draft."
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
                          tone="destructive"
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
