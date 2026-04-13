import { useScrollToTop } from "@react-navigation/native";
import { NativeStackScreenProps } from "@react-navigation/native-stack";
import { Ionicons } from "@expo/vector-icons";
import { useMemo, useRef, useState } from "react";
import { Modal, Pressable, View } from "react-native";
import { useShallow } from "zustand/react/shallow";

import { PageHeader } from "../../components/navigation/PageHeader";
import { Button } from "../../components/ui/Button";
import { EmptyStateCard } from "../../components/ui/EmptyStateCard";
import { Pill } from "../../components/ui/Pill";
import { ProgressBar } from "../../components/ui/ProgressBar";
import { Screen } from "../../components/ui/Screen";
import { Surface } from "../../components/ui/Surface";
import { AppText } from "../../components/ui/Text";
import { GoalMilestoneStatus, GoalStatus, TaskStatus } from "../../domain/models";
import { GoalsStackParamList } from "../../navigation/types";
import { describeGoalFeasibility } from "../../services/goals/goalIntelligence";
import { buildGoalProgressTruth } from "../../services/goals/progress";
import { getGoalReviewDraft } from "../../services/goals/metadata";
import { canonicalizeAmbitions, canonicalizeGoals } from "../../services/goals/portfolioIntegrity";
import { buildActivityFeed, summarizeGoalProgress } from "../../services/history/selectors";
import { useAppStore } from "../../state/useAppStore";
import { formatShortDate } from "../../utils/date";

type Props = NativeStackScreenProps<GoalsStackParamList, "GoalsHome">;

function paceTone(label: string) {
  if (label === "On pace" || label === "Recovered") {
    return "accent" as const;
  }

  if (label === "Slightly off pace") {
    return "neutral" as const;
  }

  return "quiet" as const;
}

function GoalCard({
  title,
  direction,
  progress,
  progressLabel,
  phase,
  nextMove,
  thisWeek,
  health,
  meta,
  selected,
  onOpen,
  onToggleSelect,
  selectionMode,
}: {
  title: string;
  direction: string;
  progress: number;
  progressLabel: string;
  phase: string;
  nextMove: string;
  thisWeek: string;
  health: string;
  meta: string;
  selected: boolean;
  onOpen: () => void;
  onToggleSelect: () => void;
  selectionMode: boolean;
}) {
  return (
    <Pressable onPress={selectionMode ? onToggleSelect : onOpen}>
      {({ pressed }) => (
        <Surface
          tone={selected ? "accent" : "default"}
          className="gap-4"
          style={{ opacity: pressed ? 0.96 : 1 }}
        >
          <View className="flex-row items-start justify-between gap-3">
            <View className="flex-1 gap-2">
              <View className="flex-row flex-wrap items-center gap-2">
                <Pill label={direction} tone="quiet" />
                <Pill label={health} tone={paceTone(health)} />
              </View>
              <AppText variant="section">{title}</AppText>
            </View>
            {selectionMode ? (
              <View
                className="items-center justify-center rounded-full"
                style={{
                  width: 28,
                  height: 28,
                  borderWidth: 1,
                }}
              >
                <Ionicons name={selected ? "checkmark-circle" : "ellipse-outline"} size={18} />
              </View>
            ) : (
              <Ionicons name="chevron-forward" size={18} />
            )}
          </View>

          <View className="gap-2">
            <View className="flex-row items-center justify-between gap-3">
              <AppText tone="secondary" variant="caption">
                {progressLabel}
              </AppText>
              <AppText tone="secondary" variant="caption">
                {meta}
              </AppText>
            </View>
            <ProgressBar progress={progress} />
          </View>

          <View className="flex-row flex-wrap gap-3">
            <View className="min-w-[31%] flex-1 gap-1">
              <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                Phase
              </AppText>
              <AppText variant="caption">{phase}</AppText>
            </View>
            <View className="min-w-[31%] flex-1 gap-1">
              <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                This week
              </AppText>
              <AppText variant="caption">{thisWeek}</AppText>
            </View>
            <View className="min-w-[31%] flex-1 gap-1">
              <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                Next move
              </AppText>
              <AppText variant="caption">{nextMove}</AppText>
            </View>
          </View>
        </Surface>
      )}
    </Pressable>
  );
}

export function GoalsScreen({ navigation }: Props) {
  const scrollRef = useRef<any>(null);
  useScrollToTop(scrollRef);
  const {
    ambitions,
    goals,
    milestones,
    tasks,
    timeBlocks,
    activityEvents,
    currentWeekReview,
    currentMonthReview,
    deleteGoals,
  } = useAppStore(
    useShallow((state) => ({
      ambitions: state.ambitions,
      goals: state.goals,
      milestones: state.milestones,
      tasks: state.allTasks,
      timeBlocks: state.allTimeBlocks,
      activityEvents: state.activityEvents,
      currentWeekReview: state.currentWeekReview,
      currentMonthReview: state.currentMonthReview,
      deleteGoals: state.deleteGoals,
    })),
  );
  const [selectionMode, setSelectionMode] = useState(false);
  const [selectedGoalIds, setSelectedGoalIds] = useState<string[]>([]);
  const [confirmDeleteOpen, setConfirmDeleteOpen] = useState(false);
  const [deleteBusy, setDeleteBusy] = useState(false);

  const portfolio = useMemo(() => {
    const uniqueAmbitions = canonicalizeAmbitions(ambitions);
    const uniqueGoals = canonicalizeGoals(goals);
    const activeGoals = uniqueGoals.filter((goal) => goal.status === GoalStatus.Active);
    const inactiveGoals = uniqueGoals.filter((goal) => goal.status !== GoalStatus.Active);
    const feed = buildActivityFeed(activityEvents, tasks, milestones);

    const cards = activeGoals.map((goal) => {
      const ambition = uniqueAmbitions.find((entry) => entry.id === goal.ambitionId) ?? null;
      const goalMilestones = milestones.filter((item) => item.goalId === goal.id);
      const goalTasks = tasks.filter(
        (item) => item.goalId === goal.id && item.status !== TaskStatus.Cancelled,
      );
      const progressTruth = buildGoalProgressTruth({
        goal,
        ambition,
        milestones: goalMilestones,
        tasks: goalTasks,
        timeBlocks,
        activityFeed: feed,
        currentWeekReview,
        currentMonthReview,
      });
      const progressSummary = summarizeGoalProgress({
        goal,
        milestones: goalMilestones,
        tasks: goalTasks,
        events: feed,
      });
      const totalUnits = Math.max(goalTasks.length + goalMilestones.length, 1);
      const completedUnits = progressSummary.completedTasks + progressSummary.completedMilestones;
      const progress = Math.max(0.05, Math.min(1, completedUnits / totalUnits));
      const currentMilestone =
        goalMilestones.find((item) => item.status === GoalMilestoneStatus.InProgress) ??
        goalMilestones.find((item) => item.status === GoalMilestoneStatus.Pending) ??
        null;
      const nextTask =
        goalTasks.find((item) => item.status === TaskStatus.InProgress) ??
        goalTasks.find((item) => item.status === TaskStatus.Scheduled) ??
        goalTasks.find((item) => item.status === TaskStatus.Ready) ??
        null;
      const feasibility = describeGoalFeasibility(goal);
      const reviewDraft = getGoalReviewDraft(goal);

      return {
        id: goal.id,
        title: goal.title,
        direction: ambition?.title ?? "Unlinked",
        progress,
        progressLabel: `${completedUnits}/${totalUnits} steps complete`,
        phase: currentMilestone?.title ?? "Set first phase",
        thisWeek:
          progressTruth.currentWeekScheduledMinutes > 0
            ? `${Math.round(progressTruth.currentWeekScheduledMinutes / 60)} hr planned`
            : "Not protected yet",
        nextMove: reviewDraft ? "Review pending changes" : nextTask?.title ?? "Shape next step",
        health: progressTruth.paceLabel,
        meta:
          feasibility?.statusLabel ??
          (goal.targetDate ? formatShortDate(goal.targetDate) : "No target date"),
      };
    });

    return {
      activeGoals,
      inactiveGoals,
      cards,
      activeCount: activeGoals.length,
      movingCount: cards.filter((card) => ["On pace", "Recovered", "Slightly off pace"].includes(card.health))
        .length,
      attentionCount: cards.filter((card) => ["Reset needed", "No longer realistic"].includes(card.health))
        .length,
    };
  }, [
    ambitions,
    goals,
    milestones,
    tasks,
    timeBlocks,
    activityEvents,
    currentWeekReview,
    currentMonthReview,
  ]);

  const selectedCount = selectedGoalIds.length;

  function toggleSelection(goalId: string) {
    setSelectedGoalIds((current) =>
      current.includes(goalId)
        ? current.filter((id) => id !== goalId)
        : [...current, goalId],
    );
  }

  function exitSelectionMode() {
    setSelectionMode(false);
    setSelectedGoalIds([]);
    setConfirmDeleteOpen(false);
  }

  async function handleDeleteSelected() {
    if (selectedGoalIds.length === 0) {
      return;
    }

    setDeleteBusy(true);
    try {
      await deleteGoals(selectedGoalIds);
      exitSelectionMode();
    } finally {
      setDeleteBusy(false);
    }
  }

  return (
    <>
      <Screen ref={scrollRef}>
        <View className="gap-5">
          <PageHeader
            eyebrow="Goals"
            title="Goals"
            description={
              portfolio.activeCount > 0
                ? `${portfolio.activeCount} active goals. ${portfolio.movingCount} still moving.`
                : "Build one clear goal, then keep it moving."
            }
            action={
              <View className="gap-2">
                <Button
                  size="compact"
                  tone={selectionMode ? "secondary" : "tertiary"}
                  onPress={() => {
                    if (selectionMode) {
                      exitSelectionMode();
                    } else {
                      setSelectionMode(true);
                    }
                  }}
                >
                  {selectionMode ? "Done" : "Clean up"}
                </Button>
                <Button size="compact" onPress={() => navigation.navigate("GoalEdit", {})}>
                  New goal
                </Button>
              </View>
            }
          />

          {goals.length === 0 ? (
            <EmptyStateCard
              eyebrow="Start here"
              title="Add your first goal"
              body="A title, a target, a pace, and the first next step."
              action={
                <View className="pt-1">
                  <Button onPress={() => navigation.navigate("GoalEdit", {})}>Create goal</Button>
                </View>
              }
            />
          ) : (
            <>
              <Surface tone="hero" className="gap-4">
                <View className="flex-row flex-wrap gap-2">
                  <Pill label={`${portfolio.activeCount} active`} tone="accent" />
                  <Pill label={`${portfolio.movingCount} moving`} tone="quiet" />
                  {portfolio.attentionCount > 0 ? (
                    <Pill label={`${portfolio.attentionCount} need attention`} tone="neutral" />
                  ) : null}
                  {portfolio.inactiveGoals.length > 0 ? (
                    <Pill label={`${portfolio.inactiveGoals.length} inactive`} tone="quiet" />
                  ) : null}
                </View>
                <View className="flex-row flex-wrap gap-3">
                  <View className="min-w-[31%] flex-1 gap-1">
                    <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                      Active
                    </AppText>
                    <AppText variant="section">{String(portfolio.activeCount)}</AppText>
                  </View>
                  <View className="min-w-[31%] flex-1 gap-1">
                    <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                      Moving
                    </AppText>
                    <AppText variant="section">{String(portfolio.movingCount)}</AppText>
                  </View>
                  <View className="min-w-[31%] flex-1 gap-1">
                    <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                      Attention
                    </AppText>
                    <AppText variant="section">{String(portfolio.attentionCount)}</AppText>
                  </View>
                </View>
              </Surface>

              {selectionMode ? (
                <Surface className="gap-4">
                  <View className="flex-row items-center justify-between gap-3">
                    <View className="gap-1">
                      <AppText variant="section">Bulk cleanup</AppText>
                      <AppText tone="secondary" variant="caption">
                        Select the goals you want to remove.
                      </AppText>
                    </View>
                    <Button
                      size="compact"
                      tone="tertiary"
                      onPress={() =>
                        setSelectedGoalIds(
                          selectedCount === portfolio.cards.length
                            ? []
                            : portfolio.cards.map((card) => card.id),
                        )
                      }
                    >
                      {selectedCount === portfolio.cards.length ? "Clear" : "Select all"}
                    </Button>
                  </View>
                  <View className="flex-row items-center justify-between gap-3">
                    <AppText tone="secondary" variant="caption">
                      {selectedCount === 0
                        ? "Nothing selected yet."
                        : `${selectedCount} goal${selectedCount === 1 ? "" : "s"} selected.`}
                    </AppText>
                    <Button
                      size="compact"
                      tone="secondary"
                      disabled={selectedCount === 0}
                      onPress={() => setConfirmDeleteOpen(true)}
                    >
                      Delete selected
                    </Button>
                  </View>
                </Surface>
              ) : null}

              {portfolio.cards.length === 0 ? (
                <EmptyStateCard
                  eyebrow="Quiet portfolio"
                  title="No active goals"
                  body="Bring one goal back into rotation."
                  tone="sunken"
                  action={
                    <View className="pt-1">
                      <Button onPress={() => navigation.navigate("GoalEdit", {})}>Start goal</Button>
                    </View>
                  }
                />
              ) : (
                <View className="gap-3">
                  {portfolio.cards.map((card) => (
                    <GoalCard
                      key={card.id}
                      title={card.title}
                      direction={card.direction}
                      progress={card.progress}
                      progressLabel={card.progressLabel}
                      phase={card.phase}
                      nextMove={card.nextMove}
                      thisWeek={card.thisWeek}
                      health={card.health}
                      meta={card.meta}
                      selected={selectedGoalIds.includes(card.id)}
                      selectionMode={selectionMode}
                      onToggleSelect={() => toggleSelection(card.id)}
                      onOpen={() => navigation.navigate("GoalDetail", { goalId: card.id })}
                    />
                  ))}
                </View>
              )}

              {portfolio.inactiveGoals.length > 0 ? (
                <Surface className="gap-3">
                  <AppText variant="section">Lower in rotation</AppText>
                  {portfolio.inactiveGoals.slice(0, 3).map((goal) => (
                    <View
                      key={goal.id}
                      className="flex-row items-center justify-between gap-3 rounded-[20px] px-4 py-3"
                      style={{ minHeight: 64 }}
                    >
                      <View className="flex-1 gap-1">
                        <AppText variant="caption">{goal.title}</AppText>
                        <AppText tone="secondary" variant="caption">
                          {goal.summary ?? goal.status}
                        </AppText>
                      </View>
                      <Button
                        size="compact"
                        tone="tertiary"
                        onPress={() => navigation.navigate("GoalDetail", { goalId: goal.id })}
                      >
                        Open
                      </Button>
                    </View>
                  ))}
                </Surface>
              ) : null}
            </>
          )}
        </View>
      </Screen>

      <Modal
        transparent
        animationType="fade"
        visible={confirmDeleteOpen}
        onRequestClose={() => setConfirmDeleteOpen(false)}
      >
        <View
          className="flex-1 items-center justify-center px-5"
          style={{ backgroundColor: "rgba(16, 18, 22, 0.34)" }}
        >
          <Surface style={{ width: "100%" }}>
            <View className="gap-4">
              <View className="gap-1">
                <AppText variant="title">Delete selected goals?</AppText>
                <AppText tone="secondary" variant="caption">
                  This removes the selected goals and their generated work. This cannot be undone.
                </AppText>
              </View>
              <View className="flex-row gap-3">
                <Button
                  tone="tertiary"
                  style={{ flex: 1 }}
                  onPress={() => setConfirmDeleteOpen(false)}
                >
                  Cancel
                </Button>
                <Button
                  tone="secondary"
                  style={{ flex: 1 }}
                  busy={deleteBusy}
                  onPress={() => void handleDeleteSelected()}
                >
                  Delete
                </Button>
              </View>
            </View>
          </Surface>
        </View>
      </Modal>
    </>
  );
}
