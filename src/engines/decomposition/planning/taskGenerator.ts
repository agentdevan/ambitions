import {
  AdaptationProfile,
  EntitySyncState,
  Goal,
  GoalMilestone,
  Task,
  TaskDifficulty,
  TaskSchedulingState,
  TaskStatus,
} from "../../../domain/models";
import {
  GoalPlanningAnalysis,
  PlanningWorkType,
  TaskFlexibility,
} from "../../../domain/models/planningBrain";
import { estimateTaskDuration } from "./durationEstimator";
import { TaskGenerationBlueprint } from "./types";

function createTaskRecord(goal: Goal, milestone: GoalMilestone, id: string): Task {
  const timestamp = new Date().toISOString();

  return {
    id,
    ownerUserId: null,
    remoteId: null,
    syncState: EntitySyncState.LocalOnly,
    version: 1,
    lastSyncedAt: null,
    createdAt: timestamp,
    updatedAt: timestamp,
    goalId: goal.id,
    milestoneId: milestone.id,
    parentTaskId: null,
    title: "",
    summary: null,
    status: TaskStatus.Ready,
    schedulingState: TaskSchedulingState.Unscheduled,
    difficulty: TaskDifficulty.Light,
    estimatedMinutes: 15,
    actualMinutes: null,
    effortPoints: 1,
    targetDate: milestone.targetDate,
    scheduledDate: null,
    earliestStartAt: null,
    latestFinishAt: null,
    completedAt: null,
    isRecurringTemplate: false,
    tags: [goal.domainKey],
    metadata: {},
  };
}

function blueprint(title: string, summary: string, workType: PlanningWorkType, config?: Partial<{
  novelty: "low" | "medium" | "high";
  flexibility: TaskFlexibility;
  splitEligible: boolean;
  fallbackTitle: string;
}>): TaskGenerationBlueprint {
  return {
    title,
    summary,
    workType,
    novelty: config?.novelty ?? "medium",
    flexibility: config?.flexibility ?? "high",
    splitEligible: config?.splitEligible ?? true,
    fallbackTitle: config?.fallbackTitle ?? `Start ${title.toLowerCase()}`,
  };
}

function milestoneTaskBlueprints(
  goal: Goal,
  milestone: GoalMilestone,
  analysis: GoalPlanningAnalysis,
) {
  const phaseKey = String(milestone.metadata.planningPhaseKey ?? "");
  const strategyKey = String(milestone.metadata.planningStrategyKey ?? "");
  const lowerGoal = goal.title.toLowerCase();
  const protective = analysis.policy.prefersSmallerEntryTasks;

  const generic: Record<string, TaskGenerationBlueprint[]> = {
    audit: [
      blueprint(
        `Pull the current baseline for ${lowerGoal}`,
        `Create a factual baseline for "${milestone.title.toLowerCase()}".`,
        PlanningWorkType.Research,
        { novelty: "medium", fallbackTitle: "Capture the baseline in a short note" },
      ),
      blueprint(
        `List the top friction points blocking ${lowerGoal}`,
        "Turn the milestone into visible constraints before acting.",
        PlanningWorkType.Admin,
        { novelty: "low", fallbackTitle: "Write down the single biggest blocker" },
      ),
    ],
    entry: [
      blueprint(
        `Choose the easiest starting session for ${lowerGoal}`,
        "Protective mode prefers a low-friction first repetition.",
        PlanningWorkType.Admin,
        { novelty: "low", splitEligible: false, fallbackTitle: "Pick one starter session" },
      ),
      blueprint(
        `Set out what you need for the first ${goal.domainKey} session`,
        "Remove setup friction before asking for consistency.",
        PlanningWorkType.RoutineAction,
        { novelty: "low", flexibility: "medium", splitEligible: false },
      ),
    ],
    schedule: [
      blueprint(
        "Place the next two realistic sessions on the calendar",
        "Convert intent into concrete time windows without overloading the week.",
        PlanningWorkType.Admin,
        { novelty: "low", flexibility: "medium", fallbackTitle: "Schedule one session instead of two" },
      ),
      blueprint(
        "Define the minimum version of each planned session",
        "Smaller definitions preserve continuity when the week tightens.",
        PlanningWorkType.Admin,
        { novelty: "medium", fallbackTitle: "Define the minimum version of one session" },
      ),
    ],
    target: [
      blueprint(
        `Choose the highest-leverage target inside ${milestone.title.toLowerCase()}`,
        "Pick one concrete focus rather than spreading effort thinly.",
        PlanningWorkType.Admin,
        { novelty: "medium", fallbackTitle: "Pick one obvious target" },
      ),
      blueprint(
        "Write the next threshold you need to hit",
        "A smaller threshold makes the milestone executable.",
        PlanningWorkType.Admin,
        { novelty: "low", splitEligible: false, fallbackTitle: "Write one short target" },
      ),
    ],
    produce: [
      blueprint(
        `Draft one focused work block for ${lowerGoal}`,
        "Use a bounded session to create visible output.",
        PlanningWorkType.DeepWork,
        { novelty: "medium", flexibility: "medium", fallbackTitle: "Draft the outline instead of the full block" },
      ),
      blueprint(
        "Capture the next visible artifact from this milestone",
        "Keep progress inspectable rather than purely internal.",
        PlanningWorkType.DeepWork,
        { novelty: "high", flexibility: "medium", fallbackTitle: "Create a rough first pass" },
      ),
    ],
    customize: [
      blueprint(
        "Tailor one application or artifact to a strong-fit target",
        "Quality-first customization fits the protective planning mode.",
        PlanningWorkType.DeepWork,
        { novelty: "medium", flexibility: "low", fallbackTitle: "Tailor one section instead of the full packet" },
      ),
      blueprint(
        "Review the role or target brief before editing",
        "Ground customization in the actual opportunity.",
        PlanningWorkType.Research,
        { novelty: "low", splitEligible: false, fallbackTitle: "Review the top requirements only" },
      ),
    ],
    reach: [
      blueprint(
        "Draft one outreach message with a clear ask",
        "Keep outreach specific enough to send today.",
        PlanningWorkType.Communication,
        { novelty: "medium", flexibility: "medium", fallbackTitle: "Write a short first draft" },
      ),
      blueprint(
        "Send the message to the best-fit contact",
        "Protective mode prefers one strong send over a batch blast.",
        PlanningWorkType.Communication,
        { novelty: "low", flexibility: "low", splitEligible: false, fallbackTitle: "Queue the draft for tomorrow" },
      ),
    ],
    repeat: [
      blueprint(
        `Do one minimum-viable repetition for ${lowerGoal}`,
        "A small repeat keeps continuity stronger than a skipped ideal session.",
        PlanningWorkType.RoutineAction,
        {
          novelty: protective ? "low" : "medium",
          splitEligible: false,
          fallbackTitle: "Do a five-minute version",
        },
      ),
      blueprint(
        "Log what made the repetition easy or hard",
        "Later replanning can use this friction signal without pretending to learn yet.",
        PlanningWorkType.Admin,
        { novelty: "low", splitEligible: false, fallbackTitle: "Write one quick friction note" },
      ),
    ],
    review: [
      blueprint(
        `Review the current signal for ${lowerGoal}`,
        "Use the milestone to keep the plan reality-based.",
        PlanningWorkType.Admin,
        { novelty: "low", splitEligible: false, fallbackTitle: "Check one leading signal" },
      ),
      blueprint(
        "Choose the next lower-friction adjustment",
        "Prefer the next realistic step over a full plan rewrite.",
        PlanningWorkType.Admin,
        { novelty: "medium", fallbackTitle: "Write one adjustment idea" },
      ),
    ],
  };

  if (strategyKey.includes("career_applications") && phaseKey === "submit") {
    return [
      blueprint(
        "Submit one strong-fit application",
        "Close one application loop instead of spreading across many tabs.",
        PlanningWorkType.Admin,
        { novelty: "low", flexibility: "low", splitEligible: false, fallbackTitle: "Finish one remaining application section" },
      ),
      blueprint(
        "Log the submission and next follow-up date",
        "Preserve continuity for future follow-through.",
        PlanningWorkType.Admin,
        { novelty: "low", splitEligible: false, fallbackTitle: "Write down the application status" },
      ),
    ];
  }

  return generic[phaseKey] ?? generic.review;
}

export function generateTasks(
  goal: Goal,
  milestone: GoalMilestone,
  analysis: GoalPlanningAnalysis,
  adaptationProfile: AdaptationProfile | null = null,
) {
  const drafts = milestoneTaskBlueprints(goal, milestone, analysis).slice(
    0,
    analysis.policy.maxTasksPerMilestone,
  );

  return drafts.map((draft, index) => {
    const task = createTaskRecord(goal, milestone, `${milestone.id}-task-${index + 1}`);
    const estimate = estimateTaskDuration({
      domainKey: analysis.selectedDomain.domainKey,
      workType: draft.workType,
      novelty: draft.novelty,
      analysis,
      policy: analysis.policy,
      adaptationProfile,
    });

    task.title = draft.title;
    task.summary = draft.summary;
    task.difficulty = estimate.difficulty;
    task.estimatedMinutes = estimate.minutes;
    task.effortPoints = estimate.effortPoints;
    task.metadata = {
      planningStrategyKey: String(milestone.metadata.planningStrategyKey ?? ""),
      planningSourceMilestoneId: milestone.id,
      planningWorkType: draft.workType,
      planningFlexibility: draft.flexibility,
      planningSplitEligible: draft.splitEligible,
      planningFallbackTitle: draft.fallbackTitle,
      planningContinuityToken: `${goal.id}:${milestone.id}:${index + 1}`,
      planningProtectiveMode: analysis.policy.mode === "protective",
      planningNovelty: draft.novelty,
    };

    return task;
  });
}
