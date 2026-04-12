import { NativeStackScreenProps } from "@react-navigation/native-stack";
import { View } from "react-native";

import { DrillInRow } from "../../components/navigation/DrillInRow";
import { PageHeader } from "../../components/navigation/PageHeader";
import { Button } from "../../components/ui/Button";
import { EmptyStateCard } from "../../components/ui/EmptyStateCard";
import { Pill } from "../../components/ui/Pill";
import { Screen } from "../../components/ui/Screen";
import { Surface } from "../../components/ui/Surface";
import { AppText } from "../../components/ui/Text";
import { GoalStatus } from "../../domain/models";
import { getGoalReviewDraft } from "../../services/goals/metadata";
import { useAppStore } from "../../state/useAppStore";
import { formatShortDate } from "../../utils/date";
import { GoalsStackParamList } from "../../navigation/types";

type Props = NativeStackScreenProps<GoalsStackParamList, "GoalsHome">;

function SummaryMetric({ label, value }: { label: string; value: string }) {
  return (
    <View className="flex-1 gap-1 rounded-[18px] px-4 py-4">
      <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
        {label}
      </AppText>
      <AppText variant="section">{value}</AppText>
    </View>
  );
}

export function GoalsScreen({ navigation }: Props) {
  const goals = useAppStore((state) => state.goals);
  const milestones = useAppStore((state) => state.milestones);
  const tasks = useAppStore((state) => state.allTasks);

  const activeGoals = goals.filter((goal) => goal.status === GoalStatus.Active);
  const pausedGoals = goals.filter((goal) => goal.status === GoalStatus.Paused);
  const archivedGoals = goals.filter((goal) => goal.status === GoalStatus.Archived);
  const reviewGoals = goals.filter((goal) => getGoalReviewDraft(goal) !== null);

  return (
    <Screen>
      <View className="gap-6">
        <PageHeader
          eyebrow="Goals"
          title="Keep goals clear and in motion."
          description="This is the active goals index. Open a goal to review structure, progress, or edits without crowding the page."
          action={<Button onPress={() => navigation.navigate("GoalEdit", {})}>New goal</Button>}
        />

        {goals.length === 0 ? (
          <EmptyStateCard
            title="No goals yet"
            body="Write one goal in plain language. Ambitions will shape the structure before it goes live."
            action={
              <View className="pt-1">
                <Button tone="secondary" onPress={() => navigation.navigate("GoalEdit", {})}>
                  Create a goal
                </Button>
              </View>
            }
          />
        ) : (
          <>
            <Surface tone="accent" className="gap-4">
              <View className="gap-2">
                <View className="flex-row flex-wrap items-center gap-2">
                  {reviewGoals.length > 0 ? (
                    <Pill
                      label={`${reviewGoals.length} review${reviewGoals.length === 1 ? "" : "s"} waiting`}
                      tone="accent"
                    />
                  ) : null}
                  <Pill label={`${activeGoals.length} active`} tone="quiet" />
                </View>
                <AppText variant="title">Active goals stay easy to scan.</AppText>
                <AppText tone="secondary">
                  Focus on the goals that are actually driving the plan right now.
                </AppText>
              </View>
              <View className="flex-row gap-2">
                <SummaryMetric label="Milestones" value={String(milestones.length)} />
                <SummaryMetric label="Tasks" value={String(tasks.length)} />
                <SummaryMetric
                  label="Inactive"
                  value={String(pausedGoals.length + archivedGoals.length)}
                />
              </View>
            </Surface>

            <Surface className="gap-4">
              <View className="flex-row items-end justify-between gap-3">
                <View className="gap-2">
                  <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                    Active goals
                  </AppText>
                  <AppText variant="title">Open a goal</AppText>
                </View>
                {reviewGoals.length > 0 ? (
                  <Button
                    tone="secondary"
                    onPress={() => navigation.getParent()?.navigate("Plan" as never)}
                  >
                    Review changes
                  </Button>
                ) : null}
              </View>

              <View className="gap-3">
                {activeGoals.map((goal) => {
                  const reviewDraft = getGoalReviewDraft(goal);

                  return (
                    <DrillInRow
                      key={goal.id}
                      title={goal.title}
                      subtitle={
                        goal.summary ??
                        "Open the goal to see the current structure and next checkpoints."
                      }
                      detail={
                        goal.targetDate ? `Target ${formatShortDate(goal.targetDate)}` : goal.horizon
                      }
                      badge={
                        reviewDraft ? <Pill label="Needs review" tone="accent" /> : undefined
                      }
                      onPress={() => navigation.navigate("GoalDetail", { goalId: goal.id })}
                    />
                  );
                })}
              </View>
            </Surface>

            {pausedGoals.length > 0 || archivedGoals.length > 0 ? (
              <Surface className="gap-3">
                <AppText variant="section">Inactive goals</AppText>
                <View className="gap-3">
                  {[...pausedGoals, ...archivedGoals].slice(0, 4).map((goal) => (
                    <DrillInRow
                      key={goal.id}
                      title={goal.title}
                      subtitle={goal.summary ?? "This goal is out of rotation but still available."}
                      detail={goal.status}
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
