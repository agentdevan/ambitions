import { View } from "react-native";

import { GroupedActivityTimeline, MomentumBars } from "../../components/history/ActivityTimeline";
import {
  CompactExplanationCard,
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
import {
  buildMonthlyReviewDigest,
  describeMonthlyStrategy,
  summarizeMonthlyContinuity,
} from "../../services/history/monthly";
import { summarizeWeeklyContinuity } from "../../services/history/weekly";
import { useAppStore } from "../../state/useAppStore";
import { formatMonthLabel, formatShortDate } from "../../utils/date";

export function InsightMonthlyReviewScreen() {
  const goals = useAppStore((state) => state.goals);
  const milestones = useAppStore((state) => state.milestones);
  const tasks = useAppStore((state) => state.allTasks);
  const activityEvents = useAppStore((state) => state.activityEvents);
  const dailyRitualHistory = useAppStore((state) => state.dailyRitualHistory);
  const weeklyReviewHistory = useAppStore((state) => state.weeklyReviewHistory);
  const currentMonthReview = useAppStore((state) => state.currentMonthReview);
  const nextMonthReview = useAppStore((state) => state.nextMonthReview);
  const monthlyReviewHistory = useAppStore((state) => state.monthlyReviewHistory);
  const today = useAppStore((state) => state.today);

  const feed = buildActivityFeed(activityEvents, tasks, milestones);
  const digest = buildMonthlyReviewDigest({
    date: today?.date ?? new Date().toISOString().slice(0, 10),
    goals,
    tasks,
    rituals: dailyRitualHistory,
    weeklyReviews: weeklyReviewHistory,
    events: feed,
  });
  const continuity = summarizeMonthlyContinuity(monthlyReviewHistory);
  const strategyLabel = describeMonthlyStrategy({
    posture: nextMonthReview?.monthPosture ?? null,
    emphasis: nextMonthReview?.monthlyEmphasis ?? null,
    pressureLevel: nextMonthReview?.pressureLevel ?? null,
    carryoverStance: nextMonthReview?.carryoverStance ?? null,
  });

  return (
    <Screen>
      <View className="gap-6">
        <DetailHero
          eyebrow="Insights"
          title={formatMonthLabel(digest.monthStartDate)}
          description={digest.headline}
          meta={
            <DetailSummaryStrip
              items={[
                {
                  label: "Completed",
                  value: String(digest.summary.completedCount),
                  detail: "Completion events this month",
                },
                {
                  label: "Reviewed weeks",
                  value: String(digest.summary.reviewedWeeks),
                  detail: "Weeks read intentionally",
                },
                {
                  label: "Goal coverage",
                  value: String(digest.summary.goalCoverageCount),
                  detail: "Active goals with real execution",
                },
                {
                  label: "Underrepresented",
                  value: String(digest.summary.underrepresentedGoalCount),
                  detail: "Active goals left mostly aspirational",
                },
              ]}
            />
          }
        />

        <DetailSection
          title="Monthly read"
          description="What held, what drifted, and where pressure kept dragging."
        >
          <Surface className="gap-3 mb-0">
            {digest.reads.map((read) => (
              <AppText key={read} tone="secondary">
                {read}
              </AppText>
            ))}
            <CompactExplanationCard explanation={digest.explanation} />
          </Surface>
        </DetailSection>

        <DetailSection
          title="Goal coverage"
          description="Which goals received actual execution."
        >
          <View className="gap-3">
            {digest.goalCoverage.map((coverage) => (
              <Surface key={coverage.goalId} className="gap-3 mb-0">
                <View className="flex-row flex-wrap items-center gap-2">
                  <AppText variant="section">{coverage.goalTitle}</AppText>
                  {coverage.underrepresented ? <Pill label="Underrepresented" tone="quiet" /> : null}
                  {coverage.dragSignal ? <Pill label="Drag" tone="accent" /> : null}
                </View>
                <QuietMetaLine
                  items={[
                    `${coverage.executionCount} execution touches`,
                    `${coverage.completionCount} completions`,
                    `${coverage.carryoverCount} carryover`,
                    `${coverage.churnCount} churn`,
                  ]}
                />
              </Surface>
            ))}
          </View>
        </DetailSection>

        <DetailSection
          title="Continuity across months"
          description="A compact read on monthly steering."
        >
          <Surface className="gap-3 mb-0">
            <QuietMetaLine
              items={[
                `${continuity.reviewedMonths} reviewed months`,
                `${continuity.shapedMonths} shaped months`,
                `${Math.round(continuity.averageMonthlyChurn * 100)}% average churn`,
              ]}
            />
            <AppText tone="secondary">
              {nextMonthReview?.strategySetAt
                ? `Next month is currently set to ${strategyLabel}.`
                : "Next month does not have a saved strategy yet."}
            </AppText>
            {currentMonthReview?.reviewNote ? (
              <AppText tone="secondary">Note: {currentMonthReview.reviewNote}</AppText>
            ) : null}
            <CompactExplanationCard explanation={digest.directionExplanation} />
          </Surface>
        </DetailSection>
      </View>
    </Screen>
  );
}

export function InsightContinuityScreen() {
  const goals = useAppStore((state) => state.goals);
  const milestones = useAppStore((state) => state.milestones);
  const tasks = useAppStore((state) => state.allTasks);
  const activityEvents = useAppStore((state) => state.activityEvents);
  const adaptationProfile = useAppStore((state) => state.adaptationProfile);
  const productPreferences = useAppStore((state) => state.productPreferences);
  const weeklyReviewHistory = useAppStore((state) => state.weeklyReviewHistory);

  const feed = buildActivityFeed(activityEvents, tasks, milestones);
  const summary = summarizeInsights({
    goals,
    tasks,
    milestones,
    events: feed,
    profile: adaptationProfile,
    adaptiveEnabled: productPreferences?.adaptivePlanningEnabled !== false,
  });
  const weeklyContinuity = summarizeWeeklyContinuity(weeklyReviewHistory);
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
                  label: "Open / close",
                  value: `${Math.round(summary.openConsistency * 100)} / ${Math.round(summary.closeConsistency * 100)}%`,
                  detail: "Days opened and closed intentionally",
                },
                {
                  label: "Weeks reviewed",
                  value: String(weeklyContinuity.reviewedWeeks),
                  detail: "Intentional weekly review moments",
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
                summary.planStabilityCopy,
                summary.closingImpactCopy,
              ]}
            />
          </Surface>
        </DetailSection>

        <DetailSection
          title="Daily rituals"
          description="Opening, recovery, and closeout behavior."
        >
          <Surface className="gap-3 mb-0">
            <QuietMetaLine
              items={[
                `${summary.openedThisWeek} opened this week`,
                `${summary.closedThisWeek} closed this week`,
                `${summary.recoveryUsedThisWeek} recovery${summary.recoveryUsedThisWeek === 1 ? "" : "ies"} used`,
              ]}
            />
            <AppText tone="secondary">{summary.carryoverQualityCopy}</AppText>
          </Surface>
        </DetailSection>

        <DetailSection
          title="Weekly shaping"
          description="How weekly steering is affecting drift."
        >
          <Surface className="gap-3 mb-0">
            <QuietMetaLine
              items={[
                `${weeklyContinuity.shapedWeeks} shaped week${weeklyContinuity.shapedWeeks === 1 ? "" : "s"}`,
                `${Math.round(weeklyContinuity.averageWeeklyChurn * 100)}% average churn`,
                `${Math.round(weeklyContinuity.averageCarryoverQuality * 100)}% carryover quality`,
              ]}
            />
            <AppText tone="secondary">
              {weeklyContinuity.shapedWeekDriftDelta === null
                ? "There is not enough shaped-week history yet to compare next-week drift."
                : weeklyContinuity.shapedWeekDriftDelta < -0.05
                  ? "Shaped weeks have tended to drift less in the following week."
                  : weeklyContinuity.shapedWeekDriftDelta > 0.05
                    ? "Shaping is present, but it has not yet lowered next-week drift."
                    : "Shaped and unshaped weeks are still landing about the same."}
            </AppText>
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
  const goals = useAppStore((state) => state.goals);
  const milestones = useAppStore((state) => state.milestones);
  const tasks = useAppStore((state) => state.allTasks);
  const activityEvents = useAppStore((state) => state.activityEvents);
  const adaptationProfile = useAppStore((state) => state.adaptationProfile);

  const feed = buildActivityFeed(activityEvents, tasks, milestones);
  const groups = groupActivityByDate(feed);
  const summary = summarizeInsights({
    goals,
    tasks,
    milestones,
    events: feed,
    profile: adaptationProfile,
  });

  return (
    <Screen>
      <View className="gap-6">
        <DetailHero
          eyebrow="Insights"
          title="Activity timeline"
          description={summary.momentumCopy}
          meta={
            <DetailSummaryStrip
              items={[
                {
                  label: "Events",
                  value: String(feed.length),
                  detail: "Tracked activity events",
                },
                {
                  label: "Completed",
                  value: String(summary.completedThisWeek),
                  detail: "Completion events this week",
                },
                {
                  label: "Reshaped",
                  value: String(summary.reshapedThisWeek),
                  detail: "Adjustments this week",
                },
                {
                  label: "Moving goals",
                  value: String(summary.movingGoalCount),
                  detail: "Active goals with recent movement",
                },
              ]}
            />
          }
        />
        <Surface className="gap-3 mb-0">
          <QuietMetaLine
            items={[
              summary.momentumCopy,
              summary.planCopy,
              summary.closingImpactCopy,
            ]}
          />
        </Surface>
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
  const activeGoalCount = goals.filter((goal) => goal.status === GoalStatus.Active).length;

  return (
    <Screen>
      <View className="gap-6">
        <DetailHero
          eyebrow="Insights"
          title="Plan changes"
          description="What changed in the plan, without forcing you to read a wall of churn."
          meta={
            <DetailSummaryStrip
              items={[
                {
                  label: "Changes",
                  value: String(feed.length),
                  detail: "Recent plan and goal shifts",
                },
                {
                  label: "Goals",
                  value: String(activeGoalCount),
                  detail: "Active direction surfaces in play",
                },
                {
                  label: "Review",
                  value: String(
                    goals.filter((goal) => Boolean(getGoalReviewDraft(goal))).length,
                  ),
                  detail: "Goals currently waiting on review",
                },
                {
                  label: "Rescheduled",
                  value: String(
                    feed.filter((event) => event.kind === ActivityEventKind.TaskRescheduled).length,
                  ),
                  detail: "Task timing changes in this feed",
                },
              ]}
            />
          }
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
