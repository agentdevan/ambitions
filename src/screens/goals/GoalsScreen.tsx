import { NativeStackScreenProps } from "@react-navigation/native-stack";
import { Ionicons } from "@expo/vector-icons";
import { View } from "react-native";

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
import { GoalStatus } from "../../domain/models";
import { GoalsStackParamList } from "../../navigation/types";
import { getGoalReviewDraft } from "../../services/goals/metadata";
import { buildActivityFeed, summarizeGoalProgress } from "../../services/history/selectors";
import { useAppStore } from "../../state/useAppStore";
import { formatShortDate } from "../../utils/date";

type Props = NativeStackScreenProps<GoalsStackParamList, "GoalsHome">;

function GoalCard({
  title,
  subtitle,
  detail,
  iconName,
  highlighted,
  onPress,
}: {
  title: string;
  subtitle: string;
  detail: string;
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
  const goals = useAppStore((state) => state.goals);
  const milestones = useAppStore((state) => state.milestones);
  const tasks = useAppStore((state) => state.allTasks);
  const activityEvents = useAppStore((state) => state.activityEvents);

  const activeGoals = goals.filter((goal) => goal.status === GoalStatus.Active);
  const inactiveGoals = goals.filter((goal) =>
    [GoalStatus.Paused, GoalStatus.Archived, GoalStatus.Completed].includes(goal.status),
  );
  const reviewGoals = goals.filter((goal) => getGoalReviewDraft(goal) !== null);
  const feed = buildActivityFeed(activityEvents, tasks, milestones);
  const totalMilestones = milestones.length;
  const totalTasks = tasks.length;

  return (
    <Screen>
      <View className="gap-5">
        <PageHeader
          eyebrow="Goals"
          title="Goals"
          description="Active work first."
          action={<Button onPress={() => navigation.navigate("GoalEdit", {})}>New</Button>}
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
                <Pill label={`${activeGoals.length} active`} tone="accent" />
                {reviewGoals.length > 0 ? (
                  <Pill label={`${reviewGoals.length} review`} tone="quiet" />
                ) : null}
              </View>
              <View className="gap-2">
                <AppText variant="title">Keep the set small.</AppText>
                <AppText tone="secondary" variant="caption">
                  {totalMilestones} milestones across {totalTasks} tasks.
                </AppText>
              </View>
            </Surface>

            <View className="gap-3">
              {activeGoals.map((goal) => {
                const goalSummary = summarizeGoalProgress({
                  goal,
                  milestones: milestones.filter((item) => item.goalId === goal.id),
                  tasks: tasks.filter((item) => item.goalId === goal.id),
                  events: feed,
                });
                const completionRatio =
                  goalSummary.milestoneCount > 0
                    ? goalSummary.completedMilestones / goalSummary.milestoneCount
                    : goalSummary.taskCount > 0
                      ? goalSummary.completedTasks / goalSummary.taskCount
                      : 0;
                const reviewDraft = getGoalReviewDraft(goal);

                return (
                  <Surface key={goal.id} className="gap-4">
                    <View className="flex-row items-start justify-between gap-3">
                      <View className="flex-1 gap-2">
                        <View className="flex-row flex-wrap items-center gap-2">
                          <AppText variant="section">{goal.title}</AppText>
                          {reviewDraft ? <Pill label="Review" tone="accent" /> : null}
                        </View>
                        <AppText tone="secondary" variant="caption">
                          {goal.targetDate
                            ? `Target ${formatShortDate(goal.targetDate)}`
                            : goal.horizon}
                        </AppText>
                      </View>
                      <Button
                        tone="inline"
                        onPress={() => navigation.navigate("GoalDetail", { goalId: goal.id })}
                      >
                        Open
                      </Button>
                    </View>

                    <ProgressBar progress={completionRatio} />

                    <View className="flex-row items-center justify-between">
                      <AppText tone="secondary" variant="caption">
                        {goalSummary.completedMilestones}/{goalSummary.milestoneCount || goalSummary.taskCount} complete
                      </AppText>
                      <AppText tone="secondary" variant="caption">
                        {Math.round(completionRatio * 100)}%
                      </AppText>
                    </View>

                    <View className="gap-3">
                      <GoalCard
                        title="Milestones"
                        subtitle={`${goalSummary.activeTasks} active tasks`}
                        detail={`${goalSummary.completedMilestones}/${goalSummary.milestoneCount || 0}`}
                        iconName="git-branch-outline"
                        highlighted={!!reviewDraft}
                        onPress={() => navigation.navigate("GoalMilestones", { goalId: goal.id })}
                      />
                      <GoalCard
                        title="Progress"
                        subtitle={goalSummary.reflection}
                        detail={`${goalSummary.completedTasks} done`}
                        iconName="stats-chart-outline"
                        onPress={() => navigation.navigate("GoalProgress", { goalId: goal.id })}
                      />
                    </View>
                  </Surface>
                );
              })}
            </View>

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
