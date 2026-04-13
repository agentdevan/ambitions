import { NativeStackScreenProps } from "@react-navigation/native-stack";
import { Ionicons } from "@expo/vector-icons";
import { useMemo, useState } from "react";
import { View } from "react-native";

import { DrillInRow } from "../../components/navigation/DrillInRow";
import { PageHeader } from "../../components/navigation/PageHeader";
import { Button } from "../../components/ui/Button";
import { EmptyStateCard } from "../../components/ui/EmptyStateCard";
import { Pill } from "../../components/ui/Pill";
import { ProgressBar } from "../../components/ui/ProgressBar";
import { Screen } from "../../components/ui/Screen";
import { SegmentedControl } from "../../components/ui/SegmentedControl";
import { Surface } from "../../components/ui/Surface";
import { AppText } from "../../components/ui/Text";
import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { GoalStatus } from "../../domain/models";
import { PlanStackParamList } from "../../navigation/types";
import { getGoalReviewDraft } from "../../services/goals/metadata";
import { describeWeeklyShape } from "../../services/history/weekly";
import { useAppStore } from "../../state/useAppStore";
import { formatShortDate, formatTimeRangeLabel } from "../../utils/date";

type Props = NativeStackScreenProps<PlanStackParamList, "PlanHome">;
type PlanView = "week" | "day";

function SessionRow({
  title,
  time,
  detail,
  accent,
  onPress,
}: {
  title: string;
  time: string;
  detail: string;
  accent: string;
  onPress: () => void;
}) {
  return (
    <DrillInRow
      title={title}
      subtitle={detail}
      detail={time}
      actionLabel="Open"
      leading={<View style={{ width: 8, height: 32, borderRadius: 999, backgroundColor: accent }} />}
      onPress={onPress}
    />
  );
}

export function PlanScreen({ navigation }: Props) {
  const dailyPlan = useAppStore((state) => state.dailyPlan);
  const timeBlocks = useAppStore((state) => state.timeBlocksForSelectedDate);
  const goals = useAppStore((state) => state.goals);
  const milestones = useAppStore((state) => state.milestones);
  const nextWeekReview = useAppStore((state) => state.nextWeekReview);
  const [planView, setPlanView] = useState<PlanView>("week");
  const theme = useResolvedTheme();

  const reviewGoals = goals.filter((goal) => getGoalReviewDraft(goal) !== null);
  const activeGoals = goals.filter((goal) => goal.status === GoalStatus.Active);
  const scheduledMinutes = timeBlocks.reduce((sum, block) => {
    const start = Date.parse(block.startsAtDateTime);
    const end = Date.parse(block.endsAtDateTime);
    return sum + Math.max(0, Math.round((end - start) / 60000));
  }, 0);
  const completionRatio = activeGoals.length > 0 ? Math.min(1, milestones.length / (activeGoals.length * 4)) : 0;
  const visibleBlocks = useMemo(() => timeBlocks.slice(0, planView === "week" ? 4 : 6), [planView, timeBlocks]);
  const weeklyShapeSummary = describeWeeklyShape({
    intensity: nextWeekReview?.targetWeekIntensity ?? null,
    emphasis: nextWeekReview?.weeklyEmphasis ?? null,
    carryoverPosture: nextWeekReview?.carryoverPosture ?? null,
  });

  function openWeeklyExperience() {
    (navigation.getParent() as any)?.navigate("Insights", {
      screen: "InsightsHome",
    });
  }

  if (!dailyPlan && reviewGoals.length === 0) {
    return (
      <Screen>
        <EmptyStateCard title="No plan yet" body="Add a goal, then build the week." />
      </Screen>
    );
  }

  return (
    <Screen>
      <View className="gap-5">
        <PageHeader
          eyebrow="Plan"
          title="Plan"
          description="Review, decide, move."
          action={
            <Button
              size="compact"
              onPress={() =>
                reviewGoals.length > 0
                  ? navigation.navigate("PlanReview", {})
                  : navigation.navigate("PlanDetail")
              }
            >
              {reviewGoals.length > 0 ? "Review plan" : "Open plan"}
            </Button>
          }
        />

        <Surface tone="hero" className="gap-4">
          <View className="flex-row items-start justify-between gap-3">
            <View className="flex-1 gap-2">
              <View className="flex-row flex-wrap gap-2">
                <Pill label={formatShortDate(dailyPlan?.date ?? new Date().toISOString())} tone="accent" />
                {reviewGoals.length > 0 ? <Pill label={`${reviewGoals.length} review`} tone="quiet" /> : null}
              </View>
              <AppText variant="title">{dailyPlan?.focus ?? "Current plan"}</AppText>
              <AppText tone="secondary" variant="caption">
                {dailyPlan?.planningNotes ?? "Keep the week intentional."}
              </AppText>
            </View>
            {reviewGoals.length > 0 ? (
              <Button onPress={() => navigation.navigate("PlanReview", {})}>Review</Button>
            ) : null}
          </View>

          <SegmentedControl
            value={planView}
            options={[
              { value: "week", label: "Week" },
              { value: "day", label: "Day" },
            ]}
            onChange={setPlanView}
          />

          <View className="gap-2">
            <View className="flex-row items-center justify-between">
              <AppText tone="secondary" variant="caption">
                This week&apos;s focus
              </AppText>
              <AppText tone="secondary" variant="caption">
                {scheduledMinutes} min scheduled
              </AppText>
            </View>
            <ProgressBar progress={completionRatio} muted />
          </View>
        </Surface>

        <Surface className="gap-4">
          <View className="flex-row items-end justify-between gap-3">
            <View className="gap-1">
              <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                Sessions
              </AppText>
              <AppText variant="title">{planView === "week" ? "Upcoming" : "Day shape"}</AppText>
            </View>
            <Button size="compact" tone="tertiary" onPress={() => navigation.navigate("PlanDetail")}>
              Open plan
            </Button>
          </View>

          <View className="gap-3">
            {visibleBlocks.map((block, index) => (
              <SessionRow
                key={block.id}
                title={block.title}
                time={formatTimeRangeLabel(block.startsAt, block.endsAt, { compact: true })}
                detail={block.note ?? (block.energyLabel ? `${block.energyLabel} energy` : "Scheduled")}
                accent={index === 0 ? theme.colors.accent.primary : theme.colors.accent.secondary}
                onPress={() => navigation.navigate("PlanDetail")}
              />
            ))}
          </View>
        </Surface>

        <View className="gap-3">
          <DrillInRow
            title="This week"
            subtitle={`${activeGoals.length} active goals`}
            detail={`${milestones.length} milestones`}
            actionLabel="Open"
            leading={<Ionicons color={theme.colors.text.secondary} name="calendar-outline" size={18} />}
            onPress={() => navigation.navigate("PlanDetail")}
          />
          <DrillInRow
            title="Next week"
            subtitle={nextWeekReview?.nextWeekShapedAt ? "Weekly shape saved in Insights" : "Finish weekly shaping in Insights"}
            detail={nextWeekReview?.nextWeekShapedAt ? weeklyShapeSummary : "Open the weekly review to set next week"}
            actionLabel="Open"
            leading={<Ionicons color={theme.colors.text.secondary} name="sparkles-outline" size={18} />}
            onPress={openWeeklyExperience}
          />
          <DrillInRow
            title="Structure"
            subtitle="Goals, milestones, tasks"
            detail={`${timeBlocks.length} sessions`}
            actionLabel="Open"
            leading={<Ionicons color={theme.colors.text.secondary} name="layers-outline" size={18} />}
            onPress={() => navigation.navigate("PlanStructure", {})}
          />
        </View>
      </View>
    </Screen>
  );
}
