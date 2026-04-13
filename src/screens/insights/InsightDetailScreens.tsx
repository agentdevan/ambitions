import { View } from "react-native";

import { GroupedActivityTimeline, MomentumBars } from "../../components/history/ActivityTimeline";
import {
  DetailHero,
  DetailSection,
  DetailSummaryStrip,
  QuietMetaLine,
} from "../../components/detail/DetailPrimitives";
import { EmptyStateCard } from "../../components/ui/EmptyStateCard";
import { Pill } from "../../components/ui/Pill";
import { Screen } from "../../components/ui/Screen";
import { Surface } from "../../components/ui/Surface";
import { AppText } from "../../components/ui/Text";
import { ActivityEventKind, GoalStatus, TaskStatus } from "../../domain/models";
import { getGoalReviewDraft } from "../../services/goals/metadata";
import {
  buildActivityFeed,
  groupActivityByDate,
  summarizeGoalProgress,
  summarizeInsights,
} from "../../services/history/selectors";
import { useAppStore } from "../../state/useAppStore";
import { formatShortDate } from "../../utils/date";

export function InsightContinuityScreen() {
  const goals = useAppStore((state) => state.goals);
  const milestones = useAppStore((state) => state.milestones);
  const tasks = useAppStore((state) => state.allTasks);
  const activityEvents = useAppStore((state) => state.activityEvents);
  const adaptationProfile = useAppStore((state) => state.adaptationProfile);
  const productPreferences = useAppStore((state) => state.productPreferences);

  const feed = buildActivityFeed(activityEvents, tasks, milestones);
  const summary = summarizeInsights({
    goals,
    tasks,
    milestones,
    events: feed,
    profile: adaptationProfile,
    adaptiveEnabled: productPreferences?.adaptivePlanningEnabled !== false,
  });
  const activeGoals = goals.filter((goal) => goal.status === GoalStatus.Active);

  if (activeGoals.length === 0) {
    return (
      <Screen>
        <EmptyStateCard title="No active goals" body="Add an active goal first." />
      </Screen>
    );
  }

  return (
    <Screen>
      <View className="gap-6">
        <DetailHero
          eyebrow="Insights"
          title="Continuity"
          description={summary.personalizedHighlights[0] ?? summary.momentumCopy}
          meta={
            <DetailSummaryStrip
              items={[
                {
                  label: "Moving goals",
                  value: String(summary.movingGoalCount),
                  detail: "Active goals with visible recent movement",
                },
                {
                  label: "Completed",
                  value: String(summary.completedThisWeek),
                  detail: "Completion events this week",
                },
                {
                  label: "Reshaped",
                  value: String(summary.reshapedThisWeek),
                  detail: "Deferred, moved, or revised",
                },
              ]}
            />
          }
        />

        <DetailSection
          title="Recent continuity"
          description="Finished vs reshaped."
        >
          <Surface className="gap-4 mb-0">
            <MomentumBars points={summary.momentum} />
            <QuietMetaLine
              items={[
                summary.personalizedHighlights[0] ?? summary.momentumCopy,
                summary.personalizedHighlights[1] ?? summary.planCopy,
              ]}
            />
          </Surface>
        </DetailSection>

        <DetailSection
          title="Goals in motion"
          description="Most active goals."
        >
          <View className="gap-3">
            {activeGoals.map((goal) => {
              const goalTasks = tasks.filter((task) => task.goalId === goal.id);
              const goalMilestones = milestones.filter((milestone) => milestone.goalId === goal.id);
              const goalEvents = feed.filter((event) => event.goalId === goal.id);
              const goalSummary = summarizeGoalProgress({
                goal,
                milestones: goalMilestones,
                tasks: goalTasks,
                events: goalEvents,
                profile: adaptationProfile,
                adaptiveEnabled: productPreferences?.adaptivePlanningEnabled !== false,
              });
              const pendingReview = getGoalReviewDraft(goal);

              return (
                <Surface key={goal.id} className="gap-3 mb-0">
                  <View className="flex-row flex-wrap items-center gap-2">
                    <AppText variant="section">{goal.title}</AppText>
                    {pendingReview ? <Pill label="Review waiting" tone="accent" /> : null}
                  </View>
                  <AppText tone="secondary">{goalSummary.reflection}</AppText>
                  <QuietMetaLine
                    items={[
                      `${goalSummary.completedTasks} completed tasks`,
                      `${goalSummary.carryTasks} carried or moved`,
                      `${goalSummary.completedMilestones}/${goalSummary.milestoneCount} milestones completed`,
                    ]}
                  />
                </Surface>
              );
            })}
          </View>
        </DetailSection>
      </View>
    </Screen>
  );
}

export function InsightActivityScreen() {
  const milestones = useAppStore((state) => state.milestones);
  const tasks = useAppStore((state) => state.allTasks);
  const activityEvents = useAppStore((state) => state.activityEvents);

  const feed = buildActivityFeed(activityEvents, tasks, milestones);
  const groups = groupActivityByDate(feed);

  return (
    <Screen>
      <View className="gap-6">
        <DetailHero
          eyebrow="Insights"
          title="Activity timeline"
          description="What happened."
        />
        <GroupedActivityTimeline
          groups={groups}
          emptyTitle="No activity yet"
          emptyBody="Activity will appear here."
        />
      </View>
    </Screen>
  );
}

export function InsightPlanChangesScreen() {
  const goals = useAppStore((state) => state.goals);
  const milestones = useAppStore((state) => state.milestones);
  const tasks = useAppStore((state) => state.allTasks);
  const activityEvents = useAppStore((state) => state.activityEvents);

  const feed = buildActivityFeed(activityEvents, tasks, milestones).filter((event) =>
    [
      ActivityEventKind.PlanReviewAccepted,
      ActivityEventKind.PlanReviewGenerated,
      ActivityEventKind.PlanReviewReverted,
      ActivityEventKind.GoalUpdated,
      ActivityEventKind.TaskRescheduled,
    ].includes(event.kind),
  );
  const groups = groupActivityByDate(feed);

  return (
    <Screen>
      <View className="gap-6">
        <DetailHero
          eyebrow="Insights"
          title="Plan changes"
          description="What changed in the plan."
        />

        <DetailSection
          title="Current plan pressure"
          description="Where revisions cluster."
        >
          <Surface className="gap-4 mb-0">
            {goals
              .filter((goal) => goal.status === GoalStatus.Active || getGoalReviewDraft(goal))
              .slice(0, 4)
              .map((goal) => {
                const goalTasks = tasks.filter((task) => task.goalId === goal.id);
                const movedTasks = goalTasks.filter((task) =>
                  [TaskStatus.Deferred, TaskStatus.Missed, TaskStatus.Skipped].includes(task.status),
                ).length;
                const nextTarget = goal.targetDate ? formatShortDate(goal.targetDate) : "No target date";

                return (
                  <Surface key={goal.id} tone="sunken" className="gap-2 mb-0">
                    <View className="flex-row flex-wrap items-center justify-between gap-2">
                      <AppText variant="section">{goal.title}</AppText>
                      <AppText tone="tertiary" variant="caption">
                        {nextTarget}
                      </AppText>
                    </View>
                    <AppText tone="secondary" variant="caption">
                      {movedTasks > 0
                        ? `${movedTasks} tasks currently sitting in carryover states.`
                        : "Recent changes stayed contained."}
                    </AppText>
                  </Surface>
                );
              })}
          </Surface>
        </DetailSection>

        <GroupedActivityTimeline
          groups={groups}
          emptyTitle="No plan changes yet"
          emptyBody="Plan changes will appear here."
        />
      </View>
    </Screen>
  );
}

export function InsightCapacityScreen() {
  const today = useAppStore((state) => state.today);

  if (!today) {
    return (
      <Screen>
        <EmptyStateCard title="No capacity read yet" body="Capacity isn't ready." />
      </Screen>
    );
  }

  return (
    <Screen>
      <View className="gap-4">
        <Surface tone="accent" className="gap-3">
          <AppText variant="title">Capacity and balance</AppText>
          <AppText tone="secondary">
            Capacity still stays compact. Reflection belongs to history, not to a dashboard wall.
          </AppText>
        </Surface>
        <Surface className="gap-3">
          <QuietMetaLine
            items={[
              `${today.capacity.focusBudgetMinutes} focus minutes`,
              `${today.capacity.meetingLoadMinutes} meeting minutes`,
              `${today.capacity.unusedCapacityMinutes} unused`,
            ]}
          />
          <AppText tone="secondary">
            Pressure is {today.capacity.planPressure}. Confidence is{" "}
            {Math.round(today.capacity.confidence * 100)}%.
          </AppText>
          {today.capacity.overloadWarning ? (
            <AppText tone="secondary">
              The planner is already holding work back to avoid overload.
            </AppText>
          ) : null}
        </Surface>
      </View>
    </Screen>
  );
}
