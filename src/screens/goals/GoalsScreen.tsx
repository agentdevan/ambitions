import { NativeStackScreenProps } from "@react-navigation/native-stack";
import { useMemo } from "react";
import { Ionicons } from "@expo/vector-icons";
import { View } from "react-native";

import { DrillInRow } from "../../components/navigation/DrillInRow";
import { PageHeader } from "../../components/navigation/PageHeader";
import { Button } from "../../components/ui/Button";
import { EmptyStateCard } from "../../components/ui/EmptyStateCard";
import { Pill } from "../../components/ui/Pill";
import { Screen } from "../../components/ui/Screen";
import { Surface } from "../../components/ui/Surface";
import { AppText } from "../../components/ui/Text";
import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { GoalStatus } from "../../domain/models";
import { GoalsStackParamList } from "../../navigation/types";
import { describeGoalFeasibility, describeGoalPaceMode, getGoalIntelligenceSnapshot } from "../../services/goals/goalIntelligence";
import { buildDirectionPortfolioSnapshot, buildGoalProgressTruth } from "../../services/goals/progress";
import { getGoalReviewDraft } from "../../services/goals/metadata";
import { canonicalizeAmbitions, canonicalizeGoals } from "../../services/goals/portfolioIntegrity";
import { buildActivityFeed } from "../../services/history/selectors";
import { useAppStore } from "../../state/useAppStore";
import { formatShortDate } from "../../utils/date";

type Props = NativeStackScreenProps<GoalsStackParamList, "GoalsHome">;

function GoalCard({
  title,
  subtitle,
  detail,
  actionLabel = "Open",
  iconName,
  highlighted,
  onPress,
}: {
  title: string;
  subtitle: string;
  detail: string;
  actionLabel?: string;
  iconName: keyof typeof Ionicons.glyphMap;
  highlighted?: boolean;
  onPress: () => void;
}) {
  const theme = useResolvedTheme();

  return (
    <DrillInRow
      title={title}
      subtitle={subtitle}
      detail={detail}
      actionLabel={actionLabel}
      badge={highlighted ? <Pill label="Review" tone="accent" /> : undefined}
      leading={
        <View
          className="rounded-[16px] px-3 py-3"
          style={{
            backgroundColor: highlighted
              ? theme.colors.background.accentWashStrong
              : theme.colors.background.elevatedSecondary,
          }}
        >
          <Ionicons
            color={highlighted ? theme.colors.accent.primary : theme.colors.text.secondary}
            name={iconName}
            size={18}
          />
        </View>
      }
      onPress={onPress}
    />
  );
}

export function GoalsScreen({ navigation }: Props) {
  const ambitions = useAppStore((state) => state.ambitions);
  const goals = useAppStore((state) => state.goals);
  const milestones = useAppStore((state) => state.milestones);
  const tasks = useAppStore((state) => state.allTasks);
  const timeBlocks = useAppStore((state) => state.allTimeBlocks);
  const activityEvents = useAppStore((state) => state.activityEvents);
  const currentWeekReview = useAppStore((state) => state.currentWeekReview);
  const currentMonthReview = useAppStore((state) => state.currentMonthReview);

  const {
    uniqueAmbitions,
    activeGoals,
    inactiveGoals,
    reviewGoalIds,
    directionPortfolio,
    linkedActiveGoalCount,
    unlinkedActiveGoals,
    goalTruthById,
  } = useMemo(() => {
    const uniqueAmbitions = canonicalizeAmbitions(ambitions);
    const uniqueGoals = canonicalizeGoals(goals);
    const activeGoals = uniqueGoals
      .filter((goal) => goal.status === GoalStatus.Active)
      .sort((left, right) => {
        if (!!left.ambitionId !== !!right.ambitionId) {
          return left.ambitionId ? -1 : 1;
        }
        return left.sortOrder - right.sortOrder;
      });
    const inactiveGoals = uniqueGoals.filter((goal) =>
      [GoalStatus.Paused, GoalStatus.Archived, GoalStatus.Completed].includes(goal.status),
    );
    const reviewGoalIds = new Set(
      uniqueGoals.filter((goal) => getGoalReviewDraft(goal) !== null).map((goal) => goal.id),
    );
    const feed = buildActivityFeed(activityEvents, tasks, milestones);
    const goalTruths = activeGoals.map((goal) =>
      buildGoalProgressTruth({
        goal,
        ambition: uniqueAmbitions.find((entry) => entry.id === goal.ambitionId) ?? null,
        milestones: milestones.filter((item) => item.goalId === goal.id),
        tasks: tasks.filter((item) => item.goalId === goal.id),
        timeBlocks,
        activityFeed: feed,
        currentWeekReview,
        currentMonthReview,
      }),
    );
    const directionPortfolio = buildDirectionPortfolioSnapshot({
      ambitions: uniqueAmbitions,
      goals: activeGoals,
      goalTruths,
    });
    const goalTruthById = new Map(goalTruths.map((truth) => [truth.goalId, truth]));

    return {
      uniqueAmbitions,
      activeGoals,
      inactiveGoals,
      reviewGoalIds,
      directionPortfolio,
      linkedActiveGoalCount: activeGoals.filter((goal) => goal.ambitionId).length,
      unlinkedActiveGoals: activeGoals.filter((goal) => !goal.ambitionId),
      goalTruthById,
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

  return (
    <Screen>
      <View className="gap-5">
        <PageHeader
          eyebrow="Goals"
          title="Goals"
          description="Direction and active work."
          action={
            <View className="flex-row gap-2">
              <Button size="compact" tone="secondary" onPress={() => navigation.navigate("AmbitionEdit", {})}>
                New ambition
              </Button>
              <Button size="compact" onPress={() => navigation.navigate("GoalEdit", {})}>
                New goal
              </Button>
            </View>
          }
        />

        {goals.length === 0 ? (
          <EmptyStateCard
            title="No goals yet"
            body="Start with one clear goal."
            action={
              <View className="pt-1">
                <Button tone="secondary" onPress={() => navigation.navigate("GoalEdit", {})}>
                  Create goal
                </Button>
              </View>
            }
          />
        ) : (
          <>
            <Surface tone="hero" className="gap-4">
              <View className="flex-row flex-wrap gap-2">
                <Pill label={`${directionPortfolio.ambitions.length} ambitions`} tone="quiet" />
                <Pill label={`${activeGoals.length} active`} tone="accent" />
                {reviewGoalIds.size > 0 ? (
                  <Pill label={`${reviewGoalIds.size} review`} tone="quiet" />
                ) : null}
                {unlinkedActiveGoals.length > 0 ? (
                  <Pill label={`${unlinkedActiveGoals.length} need direction`} tone="neutral" />
                ) : null}
              </View>
              <View className="gap-2">
                <AppText variant="title">Keep direction visible.</AppText>
                <AppText tone="secondary" variant="caption">
                  {linkedActiveGoalCount > 0
                    ? `${linkedActiveGoalCount} active goals already serve a named ambition.`
                    : "Active goals need a clearer direction layer."}
                </AppText>
              </View>
              {directionPortfolio.underrepresentedAmbitionIds.length > 0 ? (
                <AppText tone="secondary" variant="caption">
                  Some active ambitions are not getting enough room in the current week.
                </AppText>
              ) : null}
            </Surface>

            {directionPortfolio.ambitions.length > 0 ? (
              <Surface className="gap-4">
                <View className="gap-1">
                  <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                    Ambitions
                  </AppText>
                  <AppText variant="title">Direction portfolio</AppText>
                </View>
                <View className="gap-3">
                  {directionPortfolio.ambitions.map((ambitionTruth) => {
                    const ambition = uniqueAmbitions.find((entry) => entry.id === ambitionTruth.ambitionId);
                    if (!ambition) {
                      return null;
                    }

                    return (
                      <DrillInRow
                        key={ambition.id}
                        title={ambition.title}
                        subtitle={ambitionTruth.portfolioSummary}
                        detail={ambitionTruth.representationLabel}
                        leading={<Pill label={`${ambitionTruth.activeGoalCount} goals`} tone="quiet" />}
                        onPress={() => navigation.navigate("AmbitionDetail", { ambitionId: ambition.id })}
                      />
                    );
                  })}
                </View>
              </Surface>
            ) : null}

            <View className="gap-3">
              <View className="gap-1">
                <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                  Active goals
                </AppText>
                <AppText variant="title">Active portfolio</AppText>
              </View>
              {activeGoals.map((goal) => {
                const goalTruth = goalTruthById.get(goal.id);
                const reviewDraft = reviewGoalIds.has(goal.id) ? getGoalReviewDraft(goal) : null;
                const intelligence = getGoalIntelligenceSnapshot(goal);
                const feasibility = describeGoalFeasibility(goal);
                const ambition = uniqueAmbitions.find((entry) => entry.id === goal.ambitionId) ?? null;

                return (
                  <Surface key={goal.id} className="gap-4">
                    <View className="flex-row items-start justify-between gap-3">
                      <View className="flex-1 gap-2">
                        <View className="flex-row flex-wrap items-center gap-2">
                          <AppText variant="section">{goal.title}</AppText>
                          {reviewDraft ? <Pill label="Review" tone="accent" /> : null}
                          {!ambition ? <Pill label="Needs direction" tone="neutral" /> : null}
                          {goalTruth?.crowded ? <Pill label="Crowded" tone="quiet" /> : null}
                          {goalTruth?.stale ? <Pill label="Quiet" tone="quiet" /> : null}
                          {intelligence ? (
                            <Pill
                              label={describeGoalPaceMode(intelligence.selectedPaceMode)}
                              tone="quiet"
                            />
                          ) : null}
                          {feasibility ? (
                            <Pill label={feasibility.statusLabel} tone="neutral" />
                          ) : null}
                        </View>
                        <AppText tone="secondary" variant="caption">
                          {goal.targetDate
                            ? `Target ${formatShortDate(goal.targetDate)}`
                            : goal.horizon}
                        </AppText>
                        <AppText tone="secondary" variant="caption">
                          {ambition ? `Serves ${ambition.title}` : "No ambition linked yet"}
                        </AppText>
                      </View>
                      <Button
                        tone="tertiary"
                        size="compact"
                        onPress={() => navigation.navigate("GoalDetail", { goalId: goal.id })}
                      >
                        Open goal
                      </Button>
                    </View>

                    {goalTruth ? (
                      <Surface tone="sunken" className="gap-2 mb-0">
                        <AppText variant="caption">{goalTruth.paceSummary}</AppText>
                        <AppText tone="secondary" variant="caption">
                          {goalTruth.representationSummary}
                        </AppText>
                      </Surface>
                    ) : null}

                    {feasibility ? (
                      <Surface tone="sunken" className="gap-2 mb-0">
                        <AppText variant="caption">{feasibility.summary}</AppText>
                        <AppText tone="secondary" variant="caption">
                          {feasibility.detail}
                        </AppText>
                      </Surface>
                    ) : null}

                    <View className="gap-3">
                      <GoalCard
                        title="Direction"
                        subtitle={ambition ? ambition.title : "Link a bigger direction"}
                        detail={goalTruth?.paceLabel ?? "Open"}
                        actionLabel="Review"
                        iconName="sparkles-outline"
                        highlighted={!!reviewDraft}
                        onPress={() =>
                          ambition
                            ? navigation.navigate("AmbitionDetail", { ambitionId: ambition.id })
                            : navigation.navigate("GoalEdit", { goalId: goal.id })
                        }
                      />
                      <GoalCard
                        title="Progress"
                        subtitle={goalTruth?.representationSummary ?? "Open the progress read"}
                        detail={
                          goalTruth
                            ? `${Math.round(goalTruth.currentWeekScheduledMinutes / 60)} hr this week`
                            : "Open"
                        }
                        actionLabel="Open"
                        iconName="stats-chart-outline"
                        onPress={() => navigation.navigate("GoalProgress", { goalId: goal.id })}
                      />
                    </View>
                  </Surface>
                );
              })}
            </View>

            {unlinkedActiveGoals.length > 0 ? (
              <Surface className="gap-4">
                <View className="gap-1">
                  <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                    Needs direction
                  </AppText>
                  <AppText variant="title">Compact follow-up</AppText>
                </View>
                <AppText tone="secondary" variant="caption">
                  These goals are already in the active portfolio above. This is only the quick link pass.
                </AppText>
                <View className="gap-3">
                  {unlinkedActiveGoals.map((goal) => (
                    <DrillInRow
                      key={goal.id}
                      title={goal.title}
                      subtitle="Active, but still not tied to a bigger direction."
                      detail="Link ambition"
                      onPress={() => navigation.navigate("GoalEdit", { goalId: goal.id })}
                    />
                  ))}
                </View>
              </Surface>
            ) : null}

            {inactiveGoals.length > 0 ? (
              <Surface className="gap-4">
                <View className="gap-1">
                  <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                    Inactive
                  </AppText>
                  <AppText variant="title">On hold</AppText>
                </View>
                <View className="gap-3">
                  {inactiveGoals.slice(0, 4).map((goal) => (
                    <DrillInRow
                      key={goal.id}
                      title={goal.title}
                      subtitle={goal.summary ?? "Out of the active rotation"}
                      detail={goal.status}
                      leading={
                        <Ionicons
                          color="#8B7F71"
                          name={goal.status === GoalStatus.Paused ? "pause-outline" : "archive-outline"}
                          size={18}
                        />
                      }
                      onPress={() => navigation.navigate("GoalDetail", { goalId: goal.id })}
                    />
                  ))}
                </View>
              </Surface>
            ) : null}
          </>
        )}
      </View>
    </Screen>
  );
}
