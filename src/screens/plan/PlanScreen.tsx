import { View } from "react-native";

import { EmptyStateCard } from "../../components/ui/EmptyStateCard";
import { Pill } from "../../components/ui/Pill";
import { Screen } from "../../components/ui/Screen";
import { Surface } from "../../components/ui/Surface";
import { AppText } from "../../components/ui/Text";
import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { GoalStatus } from "../../domain/models";
import { useAppStore } from "../../state/useAppStore";

export function PlanScreen() {
  const theme = useResolvedTheme();
  const dailyPlan = useAppStore((state) => state.dailyPlan);
  const timeBlocks = useAppStore((state) => state.timeBlocksForSelectedDate);
  const goals = useAppStore((state) => state.goals);
  const milestones = useAppStore((state) => state.milestones);
  const tasks = useAppStore((state) => state.allTasks);
  const calendarConnectionState = useAppStore((state) => state.calendarConnectionState);

  if (!dailyPlan) {
    return (
      <Screen>
        <EmptyStateCard
          eyebrow="Plan"
          title="No generated plan yet"
          body="Finish onboarding or add a goal first. The plan surface stays quiet until there is something real to show."
        />
      </Screen>
    );
  }

  const nextMilestones = milestones.slice(0, 5);

  return (
    <Screen>
      <View className="gap-6">
        <View className="gap-2 pt-2">
          <Pill label="Plan" />
          <AppText variant="hero">The current shape of the work.</AppText>
          <AppText tone="secondary">
            Enough structure to understand what was generated, without turning the app into a
            planner board.
          </AppText>
        </View>

        <Surface>
          <View className="gap-3">
            <AppText variant="section">Today&apos;s frame</AppText>
            <AppText>{dailyPlan.focus}</AppText>
            <AppText tone="secondary">
              {dailyPlan.planningNotes ?? "The planner created a compact, protective day shape."}
            </AppText>
            <View className="flex-row flex-wrap gap-2">
              <Pill label={`${timeBlocks.length} blocks`} tone="accent" />
              <Pill
                label={`${
                  tasks.filter((task) => task.scheduledDate === dailyPlan.date).length
                } scheduled tasks`}
              />
              <Pill label={dailyPlan.date} />
            </View>
          </View>
        </Surface>

        <Surface tone="sunken">
          <View className="gap-3">
            <AppText variant="section">Next milestones</AppText>
            {nextMilestones.length === 0 ? (
              <AppText tone="secondary">
                The current goals do not have future milestones yet. Add or refine a goal to give
                the planner more continuity.
              </AppText>
            ) : null}
            {nextMilestones.map((milestone) => {
              const goal = goals.find((entry) => entry.id === milestone.goalId);

              return (
                <View
                  key={milestone.id}
                  className="rounded-[22px] px-4 py-4"
                  style={{
                    borderWidth: 1,
                    borderColor: theme.colors.border.subtle,
                    backgroundColor: theme.colors.background.elevated,
                  }}
                >
                  <AppText>{milestone.title}</AppText>
                  <AppText tone="secondary" style={{ marginTop: 6 }}>
                    {goal?.title ?? "Goal no longer available"}
                  </AppText>
                  <AppText tone="tertiary" variant="caption" style={{ marginTop: 6 }}>
                    {milestone.targetDate ?? "No target date"}
                  </AppText>
                </View>
              );
            })}
          </View>
        </Surface>

        <Surface>
          <View className="gap-3">
            <AppText variant="section">Continuity</AppText>
            <AppText tone="secondary">
              {calendarConnectionState?.permissionState === "granted"
                ? "Calendar access is available for live context."
                : "Calendar access is still off, so the planner is using schedule defaults only."}
            </AppText>
            <AppText tone="secondary">
              {goals.some((goal) => goal.status === GoalStatus.Active)
                ? "Active goals are feeding future milestones and task generation."
                : "There are no active goals feeding future planning yet."}
            </AppText>
          </View>
        </Surface>
      </View>
    </Screen>
  );
}
