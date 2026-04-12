import { NativeStackScreenProps } from "@react-navigation/native-stack";
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
import { GoalStatus } from "../../domain/models";
import { getGoalReviewDraft } from "../../services/goals/metadata";
import { useAppStore } from "../../state/useAppStore";
import { formatShortDate } from "../../utils/date";
import { PlanStackParamList } from "../../navigation/types";

type Props = NativeStackScreenProps<PlanStackParamList, "PlanHome">;

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

export function PlanScreen({ navigation }: Props) {
  const dailyPlan = useAppStore((state) => state.dailyPlan);
  const timeBlocks = useAppStore((state) => state.timeBlocksForSelectedDate);
  const goals = useAppStore((state) => state.goals);
  const milestones = useAppStore((state) => state.milestones);

  const reviewGoals = goals.filter((goal) => getGoalReviewDraft(goal) !== null);
  const activeGoals = goals.filter((goal) => goal.status === GoalStatus.Active);

  if (!dailyPlan && reviewGoals.length === 0) {
    return (
      <Screen>
        <EmptyStateCard
          title="No generated plan yet"
          body="Finish onboarding, add a goal, or review a pending recommendation first."
        />
      </Screen>
    );
  }

  return (
    <Screen>
      <View className="gap-6">
        <PageHeader
          eyebrow="Plan"
          title="Plan"
          description="Review, decide, move."
        />

        {reviewGoals.length > 0 ? (
          <Surface tone="accent" className="gap-4">
            <View className="gap-1.5">
              <View className="flex-row flex-wrap items-center gap-2">
                <Pill
                  label={`${reviewGoals.length} review${reviewGoals.length === 1 ? "" : "s"} waiting`}
                  tone="accent"
                />
              </View>
              <AppText variant="title">Changes need a call.</AppText>
            </View>
            <Button onPress={() => navigation.navigate("PlanReview", {})}>Review changes</Button>
          </Surface>
        ) : null}

        {dailyPlan ? (
          <>
            <Surface className="gap-4">
              <View className="gap-1.5">
                <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                  Active plan
                </AppText>
                <AppText variant="title">{dailyPlan.focus}</AppText>
                {dailyPlan.planningNotes ? (
                  <AppText tone="secondary">{dailyPlan.planningNotes}</AppText>
                ) : null}
              </View>
              <View className="flex-row gap-2">
                <SummaryMetric label="Date" value={formatShortDate(dailyPlan.date)} />
                <SummaryMetric label="Sessions" value={String(timeBlocks.length)} />
                <SummaryMetric label="Goals" value={String(activeGoals.length)} />
              </View>
            </Surface>

            <View className="gap-3">
              <DrillInRow
                title="Day shape"
                subtitle="Sessions and timing"
                detail={`${timeBlocks.length} sessions`}
                leading={<Ionicons color="#6F6558" name="calendar-outline" size={18} />}
                onPress={() => navigation.navigate("PlanDetail")}
              />
              <DrillInRow
                title="Structure"
                subtitle="Goals, milestones, tasks"
                detail={`${milestones.length} milestones`}
                leading={<Ionicons color="#6F6558" name="layers-outline" size={18} />}
                onPress={() => navigation.navigate("PlanStructure", {})}
              />
            </View>
          </>
        ) : null}
      </View>
    </Screen>
  );
}
