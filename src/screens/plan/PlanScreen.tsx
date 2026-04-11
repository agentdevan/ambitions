import { View } from "react-native";

import { Pill } from "../../components/ui/Pill";
import { Screen } from "../../components/ui/Screen";
import { Surface } from "../../components/ui/Surface";
import { AppText } from "../../components/ui/Text";
import { GoalStatus } from "../../domain/models";
import { useAppStore } from "../../state/useAppStore";

export function PlanScreen() {
  const dailyPlan = useAppStore((state) => state.dailyPlan);
  const timeBlocks = useAppStore((state) => state.timeBlocksForSelectedDate);
  const goals = useAppStore((state) => state.goals);
  const milestones = useAppStore((state) => state.milestones);
  const tasks = useAppStore((state) => state.allTasks);
  const calendarConnectionState = useAppStore((state) => state.calendarConnectionState);

  if (!dailyPlan) {
    return (
      <Screen>
        <Surface>
          <View className="gap-3">
            <Pill label="Plan" />
            <AppText variant="title">No generated plan yet</AppText>
            <AppText tone="secondary">
              Finish onboarding or add a goal first. The plan surface stays quiet until there is something real to show.
            </AppText>
          </View>
        </Surface>
      </Screen>
    );
  }

  return (
    <Screen>
      <View className="gap-6">
        <View className="gap-2 pt-2">
          <Pill label="Plan" />
          <AppText variant="hero">The current shape of the work.</AppText>
          <AppText tone="secondary">
            Enough structure to understand what was generated, without turning the app into a planner board.
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
              <Pill label={`${tasks.filter((task) => task.scheduledDate === dailyPlan.date).length} scheduled tasks`} />
              <Pill label={dailyPlan.date} />
            </View>
          </View>
        </Surface>

        <Surface tone="sunken">
          <View className="gap-3">
            <AppText variant="section">Next milestones</AppText>
            {milestones.slice(0, 5).map((milestone) => {
              const goal = goals.find((entry) => entry.id === milestone.goalId);

              return (
                <View
                  key={milestone.id}
                  className="rounded-[22px] border border-[#DED7CB] bg-[#F8F6F1] px-4 py-4"
                >
                  <AppText>{milestone.title}</AppText>
                  <AppText tone="secondary" style={{ marginTop: 6 }}>
                    {goal?.title ?? "Goal"}
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
