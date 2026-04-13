import { useScrollToTop } from "@react-navigation/native";
import { NativeStackScreenProps } from "@react-navigation/native-stack";
import { Ionicons } from "@expo/vector-icons";
import { useMemo, useRef, useState } from "react";
import { Modal, Pressable, View } from "react-native";
import { useShallow } from "zustand/react/shallow";

import { DrillInRow } from "../../components/navigation/DrillInRow";
import { PageHeader } from "../../components/navigation/PageHeader";
import { Button } from "../../components/ui/Button";
import { EmptyStateCard } from "../../components/ui/EmptyStateCard";
import { Pill } from "../../components/ui/Pill";
import { ProgressBar } from "../../components/ui/ProgressBar";
import { Screen } from "../../components/ui/Screen";
import { Surface } from "../../components/ui/Surface";
import { AppText } from "../../components/ui/Text";
import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { useAccessibilityPreferences } from "../../design/accessibility/useAccessibilityPreferences";
import { GoalMilestoneStatus, GoalStatus, TaskStatus } from "../../domain/models";
import { GoalsStackParamList } from "../../navigation/types";
import { describeGoalFeasibility } from "../../services/goals/goalIntelligence";
import { getGoalReviewDraft } from "../../services/goals/metadata";
import { canonicalizeAmbitions, canonicalizeGoals } from "../../services/goals/portfolioIntegrity";
import { buildGoalProgressTruth } from "../../services/goals/progress";
import { buildActivityFeed, summarizeGoalProgress } from "../../services/history/selectors";
import { useAppStore } from "../../state/useAppStore";
import { formatShortDate } from "../../utils/date";

type Props = NativeStackScreenProps<GoalsStackParamList, "GoalsHome">;

function paceTone(label: string) {
  if (label === "On pace" || label === "Recovered") return "accent" as const;
  if (label === "Slightly off pace") return "neutral" as const;
  return "quiet" as const;
}

function GoalCard({
  title,
  direction,
  progress,
  phase,
  nextMove,
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
  phase: string;
  nextMove: string;
  health: string;
  meta: string;
  selected: boolean;
  onOpen: () => void;
  onToggleSelect: () => void;
  selectionMode: boolean;
}) {
  const theme = useResolvedTheme();
  const { reduceMotionEnabled } = useAccessibilityPreferences();

  return (
    <Pressable accessibilityRole="button" onPress={selectionMode ? onToggleSelect : onOpen}>
      {({ pressed }) => (
        <Surface
          tone={selected ? "accent" : "default"}
          className="gap-4"
          style={{
            opacity: pressed ? 0.985 : 1,
            transform: [
              { scale: pressed && !reduceMotionEnabled ? 0.993 : 1 },
              { translateY: pressed && !reduceMotionEnabled ? 1 : 0 },
            ],
          }}
        >
          <View className="flex-row items-start justify-between gap-3">
            <View className="flex-1 gap-2">
              <View className="flex-row flex-wrap items-center gap-2">
                <Pill label={direction} tone="quiet" />
                <Pill label={health} tone={paceTone(health)} />
              </View>
              <AppText variant="title">{title}</AppText>
            </View>
            <View
              className="items-center justify-center rounded-full"
              style={{
                width: 42,
                height: 42,
                borderWidth: 1,
                borderColor: selected ? theme.colors.border.accent : theme.colors.border.subtle,
                backgroundColor: selected
                  ? theme.colors.background.accentWashStrong
                  : theme.colors.background.elevatedSecondary,
              }}
            >
              <Ionicons
                color={selected ? theme.colors.accent.primary : theme.colors.text.secondary}
                name={selectionMode ? (selected ? "checkmark-circle" : "ellipse-outline") : "chevron-forward"}
                size={selectionMode ? 22 : 18}
              />
            </View>
          </View>

          <View className="gap-2">
            <View className="flex-row items-center justify-between">
              <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                Progress
              </AppText>
              <AppText tone="secondary" variant="caption">
                {Math.round(progress * 100)}%
              </AppText>
            </View>
            <ProgressBar progress={progress} height={10} />
          </View>

          <View className="flex-row gap-3">
            <Surface tone="sunken" className="min-w-[46%] flex-1 gap-1.5 mb-0 px-4 py-4">
              <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                This week
              </AppText>
              <AppText variant="caption">{phase}</AppText>
            </Surface>
            <Surface tone="sunken" className="min-w-[46%] flex-1 gap-1.5 mb-0 px-4 py-4">
              <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                Next move
              </AppText>
              <AppText variant="caption">{nextMove}</AppText>
            </Surface>
          </View>

          <View className="flex-row items-center justify-between gap-3">
            <AppText tone="secondary" variant="caption" style={{ flex: 1 }}>
              {meta}
            </AppText>
            <View
              className="flex-row items-center gap-1.5 rounded-full px-3.5 py-2.5"
              style={{
                backgroundColor: selected
                  ? theme.colors.background.accentWashStrong
                  : theme.colors.background.elevatedSecondary,
                borderWidth: 1,
                borderColor: selected ? theme.colors.border.accent : theme.colors.border.strong,
                shadowColor: theme.colors.shadow.color,
                shadowOpacity: selected ? 0.12 : theme.mode === "dark" ? 0.08 : 0.04,
                shadowRadius: 8,
                shadowOffset: { width: 0, height: 3 },
              }}
            >
              <AppText tone="primary" variant="micro" style={{ textTransform: "uppercase" }}>
                {selectionMode ? (selected ? "Selected" : "Select") : "Open goal"}
              </AppText>
              <Ionicons
                color={selected ? theme.colors.accent.primary : theme.colors.text.secondary}
                name={selectionMode ? (selected ? "checkmark" : "add") : "arrow-forward"}
                size={14}
              />
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
  const [deleteError, setDeleteError] = useState<string | null>(null);
  const theme = useResolvedTheme();

  const portfolio = useMemo(() => {
    const uniqueAmbitions = canonicalizeAmbitions(ambitions);
    const uniqueGoals = canonicalizeGoals(goals);
    const activeGoals = uniqueGoals.filter((goal) => goal.status === GoalStatus.Active);
    const inactiveGoals = uniqueGoals.filter((goal) => goal.status !== GoalStatus.Active);
    const feed = buildActivityFeed(activityEvents, tasks, milestones);

    const cards = activeGoals.map((goal) => {
      const ambition = uniqueAmbitions.find((entry) => entry.id === goal.ambitionId) ?? null;
      const goalMilestones = milestones.filter((item) => item.goalId === goal.id);
      const goalTasks = tasks.filter((item) => item.goalId === goal.id && item.status !== TaskStatus.Cancelled);
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
        progress: Math.max(0.05, Math.min(1, completedUnits / totalUnits)),
        phase: currentMilestone?.title ?? "Set first phase",
        nextMove: reviewDraft ? "Review pending changes" : nextTask?.title ?? "Shape next step",
        health: progressTruth.paceLabel,
        meta:
          feasibility?.statusLabel ??
          (goal.targetDate ? `Target ${formatShortDate(goal.targetDate)}` : "No target date"),
      };
    });

    return {
      cards,
      activeCount: activeGoals.length,
      inactiveGoals,
      movingCount: cards.filter((card) => ["On pace", "Recovered", "Slightly off pace"].includes(card.health)).length,
      attentionCount: cards.filter((card) => ["Reset needed", "No longer realistic"].includes(card.health)).length,
      pendingReviews: activeGoals.filter((goal) => getGoalReviewDraft(goal) !== null).length,
    };
  }, [ambitions, goals, milestones, tasks, timeBlocks, activityEvents, currentWeekReview, currentMonthReview]);

  const selectedCount = selectedGoalIds.length;
  const selectedTitles = portfolio.cards
    .filter((card) => selectedGoalIds.includes(card.id))
    .map((card) => card.title)
    .slice(0, 3);

  function toggleSelection(goalId: string) {
    setDeleteError(null);
    setSelectedGoalIds((current) =>
      current.includes(goalId) ? current.filter((id) => id !== goalId) : [...current, goalId],
    );
  }

  function exitSelectionMode() {
    setSelectionMode(false);
    setSelectedGoalIds([]);
    setConfirmDeleteOpen(false);
    setDeleteError(null);
  }

  async function handleDeleteSelected() {
    if (selectedGoalIds.length === 0) return;
    setDeleteBusy(true);
    setDeleteError(null);
    try {
      await deleteGoals(selectedGoalIds);
      exitSelectionMode();
    } catch (error) {
      setDeleteError(error instanceof Error ? error.message : "The selected goals could not be deleted.");
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
                ? `${portfolio.activeCount} active goals with one clear tap path each.`
                : "Build one clear goal, then keep it moving."
            }
            action={
              <View className="flex-row gap-3">
                <Button
                  size="compact"
                  tone={selectionMode ? "secondary" : "tertiary"}
                  style={{ flex: 1 }}
                  onPress={() => (selectionMode ? exitSelectionMode() : setSelectionMode(true))}
                >
                  {selectionMode ? "Done cleaning" : "Clean up"}
                </Button>
                <Button size="compact" style={{ flex: 1 }} onPress={() => navigation.navigate("GoalEdit", {})}>
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
                <View className="flex-row flex-wrap items-center gap-2">
                  <Pill label={`${portfolio.activeCount} active`} tone="accent" />
                  <Pill label={`${portfolio.movingCount} moving`} tone="quiet" />
                  {portfolio.attentionCount > 0 ? (
                    <Pill label={`${portfolio.attentionCount} need attention`} tone="neutral" />
                  ) : null}
                  {portfolio.pendingReviews > 0 ? (
                    <Pill label={`${portfolio.pendingReviews} review`} tone="quiet" />
                  ) : null}
                </View>
                <View className="gap-2">
                  <AppText variant="title">
                    {portfolio.attentionCount > 0
                      ? "A few goals need a cleaner read."
                      : "Your active goals are easier to scan and act on."}
                  </AppText>
                  <AppText tone="secondary">
                    The strongest next move is now treated like a control, not a text hint.
                  </AppText>
                </View>
                <View className="flex-row gap-3">
                  <Button style={{ flex: 1 }} onPress={() => navigation.navigate("GoalEdit", {})}>
                    Add goal
                  </Button>
                  <Button
                    tone="secondary"
                    style={{ flex: 1 }}
                    onPress={() => (selectionMode ? setConfirmDeleteOpen(true) : setSelectionMode(true))}
                  >
                    {selectionMode ? "Delete selected" : "Manage goals"}
                  </Button>
                </View>
              </Surface>

              {selectionMode ? (
                <Surface tone="accent" className="gap-4">
                  <View className="flex-row items-start justify-between gap-3">
                    <View className="flex-1 gap-1">
                      <AppText variant="section">Bulk cleanup</AppText>
                      <AppText tone="secondary" variant="caption">
                        Select goals, then confirm one deliberate destructive action.
                      </AppText>
                    </View>
                    <Pill label={selectedCount > 0 ? `${selectedCount} selected` : "Select goals"} tone="accent" />
                  </View>
                  <View className="flex-row gap-3">
                    <Button
                      size="compact"
                      tone="secondary"
                      style={{ flex: 1 }}
                      onPress={() =>
                        setSelectedGoalIds(
                          selectedCount === portfolio.cards.length ? [] : portfolio.cards.map((card) => card.id),
                        )
                      }
                    >
                      {selectedCount === portfolio.cards.length ? "Clear selection" : "Select all"}
                    </Button>
                    <Button
                      size="compact"
                      tone="destructive"
                      style={{ flex: 1 }}
                      disabled={selectedCount === 0}
                      onPress={() => setConfirmDeleteOpen(true)}
                    >
                      Delete selected
                    </Button>
                  </View>
                  {deleteError ? (
                    <AppText tone="secondary" variant="caption">
                      {deleteError}
                    </AppText>
                  ) : null}
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
                      phase={card.phase}
                      nextMove={card.nextMove}
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
                    <DrillInRow
                      key={goal.id}
                      title={goal.title}
                      subtitle={goal.summary ?? goal.status}
                      detail="Open"
                      actionLabel="Open"
                      leading={<Ionicons color={theme.colors.text.secondary} name="flag-outline" size={18} />}
                      onPress={() => navigation.navigate("GoalDetail", { goalId: goal.id })}
                    />
                  ))}
                </Surface>
              ) : null}
            </>
          )}
        </View>
      </Screen>

      <Modal transparent animationType="fade" visible={confirmDeleteOpen} onRequestClose={() => setConfirmDeleteOpen(false)}>
        <View className="flex-1 items-center justify-center px-5" style={{ backgroundColor: "rgba(16, 18, 22, 0.38)" }}>
          <Surface style={{ width: "100%" }}>
            <View className="gap-4">
              <View className="gap-2">
                <Pill label={selectedCount > 0 ? `${selectedCount} selected` : "No goals selected"} tone="neutral" />
                <AppText variant="title">Delete selected goals?</AppText>
                <AppText tone="secondary">
                  This removes the goals and their generated work. The cleanup is immediate and cannot be undone.
                </AppText>
              </View>
              {selectedTitles.length > 0 ? (
                <Surface tone="sunken" className="gap-2 mb-0">
                  {selectedTitles.map((title) => (
                    <AppText key={title} variant="caption">
                      {title}
                    </AppText>
                  ))}
                  {selectedCount > selectedTitles.length ? (
                    <AppText tone="secondary" variant="caption">
                      +{selectedCount - selectedTitles.length} more
                    </AppText>
                  ) : null}
                </Surface>
              ) : null}
              {deleteError ? (
                <AppText tone="secondary" variant="caption">
                  {deleteError}
                </AppText>
              ) : null}
              <View className="flex-row gap-3">
                <Button tone="tertiary" style={{ flex: 1 }} onPress={() => setConfirmDeleteOpen(false)}>
                  Keep goals
                </Button>
                <Button tone="destructive" style={{ flex: 1 }} busy={deleteBusy} onPress={() => void handleDeleteSelected()}>
                  Delete goals
                </Button>
              </View>
            </View>
          </Surface>
        </View>
      </Modal>
    </>
  );
}
