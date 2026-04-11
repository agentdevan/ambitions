import { Goal, GoalMilestone, Task } from "../../domain/models";
import {
  GoalEditImpactPreview,
  GoalReviewDraft,
  GoalReviewMilestoneDraft,
  GoalReviewMode,
  GoalReviewTaskDraft,
  getMilestoneContinuityKey,
  getTaskContinuityKey,
} from "./metadata";
import { selectProtectedItems } from "./protectedItemSelector";

function createId(prefix: string) {
  return `${prefix}-${Math.random().toString(36).slice(2, 10)}`;
}

function nowIso() {
  return new Date().toISOString();
}

function milestoneChanged(left: GoalMilestone, right: GoalMilestone) {
  return (
    left.title !== right.title ||
    left.summary !== right.summary ||
    left.targetDate !== right.targetDate ||
    left.estimatedMinutes !== right.estimatedMinutes
  );
}

function taskChanged(left: Task, right: Task) {
  return (
    left.title !== right.title ||
    left.summary !== right.summary ||
    left.targetDate !== right.targetDate ||
    left.estimatedMinutes !== right.estimatedMinutes ||
    left.milestoneId !== right.milestoneId
  );
}

function milestoneRationale(goal: Goal, milestone: GoalMilestone) {
  const templateLabel = String(milestone.metadata.planningStrategyKey ?? "")
    .replaceAll("_", " ")
    .trim();

  if (templateLabel.length > 0) {
    return `Keeps the ${templateLabel} path visible for ${goal.title.toLowerCase()}.`;
  }

  return milestone.summary ?? null;
}

function taskRationale(task: Task) {
  const workType = String(task.metadata.planningWorkType ?? "").replaceAll("_", " ").trim();
  if (workType.length > 0) {
    return `Recommended as a ${workType} step that keeps momentum without overbuilding the plan.`;
  }

  return task.summary ?? null;
}

function buildTaskDraft(
  task: Task,
  milestoneId: string,
  order: number,
  options: {
    sourceTaskId: string | null;
    protected: boolean;
    removed?: boolean;
    userAdjusted?: boolean;
    changeLabel: GoalReviewTaskDraft["changeLabel"];
  },
): GoalReviewTaskDraft {
  return {
    id: options.sourceTaskId ?? task.id,
    sourceTaskId: options.sourceTaskId,
    continuityKey: getTaskContinuityKey(task),
    milestoneId,
    title: task.title,
    summary: task.summary,
    targetDate: task.targetDate,
    estimatedMinutes: task.estimatedMinutes,
    protected: options.protected,
    removed: options.removed ?? false,
    userAdjusted: options.userAdjusted ?? false,
    rationale: taskRationale(task),
    order,
    changeLabel: options.changeLabel,
  };
}

function draftHeadline(mode: GoalReviewMode, goal: Goal) {
  if (mode === "new_goal") {
    return `Recommended plan for ${goal.title}`;
  }

  if (mode === "full_regeneration") {
    return `Recommended full refresh for ${goal.title}`;
  }

  return `Recommended targeted refresh for ${goal.title}`;
}

function draftSummary(mode: GoalReviewMode, impact: GoalEditImpactPreview | null) {
  if (mode === "new_goal") {
    return "Ambitions shaped this as a recommended plan. You can keep it as-is or make a few light adjustments before it becomes active.";
  }

  if (!impact) {
    return "Ambitions prepared a refreshed recommendation with continuity protection where possible.";
  }

  return impact.summary;
}

function impactRationale(mode: GoalReviewMode, impact: GoalEditImpactPreview | null) {
  if (mode === "new_goal") {
    return [
      "The structure is recommended, not fixed.",
      "You can reorder, trim, or slightly retime work before acceptance.",
    ];
  }

  const rationale = ["Protected downstream work stays in place whenever possible."];
  if (impact?.recommendedRegeneration) {
    rationale.push(
      impact.recommendation === "targeted_regeneration"
        ? "A targeted refresh is recommended because the change looks local enough to preserve continuity."
        : "A fuller refresh is recommended because the goal shape changed materially.",
    );
  }

  return rationale;
}

export function buildGoalReviewDraft(params: {
  goal: Goal;
  mode: GoalReviewMode;
  existingMilestones: GoalMilestone[];
  existingTasks: Task[];
  generatedMilestones: GoalMilestone[];
  generatedTasks: Task[];
  impact: GoalEditImpactPreview | null;
}): GoalReviewDraft {
  const protectedItems = selectProtectedItems({
    milestones: params.existingMilestones,
    tasks: params.existingTasks,
  });
  const existingMilestonesByKey = new Map(
    params.existingMilestones.map((milestone) => [getMilestoneContinuityKey(milestone), milestone]),
  );
  const existingTasksByKey = new Map(
    params.existingTasks.map((task) => [getTaskContinuityKey(task), task]),
  );
  const milestonesById = new Map(params.existingMilestones.map((milestone) => [milestone.id, milestone]));
  const milestoneDrafts: GoalReviewMilestoneDraft[] = [];
  const taskDrafts: GoalReviewTaskDraft[] = [];
  const generatedMilestoneIdToDraftId = new Map<string, string>();
  const usedMilestoneIds = new Set<string>();
  const usedTaskIds = new Set<string>();
  let affectedMilestoneCount = 0;
  let affectedTaskCount = 0;

  for (const generatedMilestone of params.generatedMilestones) {
    const continuityKey = getMilestoneContinuityKey(generatedMilestone);
    const existingMilestone = existingMilestonesByKey.get(continuityKey);
    const protectedMilestone =
      !!existingMilestone &&
      protectedItems.milestoneIds.has(existingMilestone.id);
    const changed = existingMilestone ? milestoneChanged(existingMilestone, generatedMilestone) : true;
    const shouldRefresh = params.mode === "full_regeneration" ? true : changed;

    let draft: GoalReviewMilestoneDraft;
    if (existingMilestone && (!shouldRefresh || protectedMilestone)) {
      draft = {
        id: existingMilestone.id,
        sourceMilestoneId: existingMilestone.id,
        continuityKey,
        title: existingMilestone.title,
        summary: existingMilestone.summary,
        targetDate: existingMilestone.targetDate,
        estimatedMinutes: existingMilestone.estimatedMinutes,
        sortOrder: generatedMilestone.sortOrder,
        protected: protectedMilestone,
        rationale: milestoneRationale(params.goal, existingMilestone),
        changeLabel: protectedMilestone ? "preserved" : "recommended",
      };
    } else {
      draft = {
        id: existingMilestone?.id ?? generatedMilestone.id,
        sourceMilestoneId: existingMilestone?.id ?? null,
        continuityKey,
        title: generatedMilestone.title,
        summary: generatedMilestone.summary,
        targetDate: generatedMilestone.targetDate,
        estimatedMinutes: generatedMilestone.estimatedMinutes,
        sortOrder: generatedMilestone.sortOrder,
        protected: false,
        rationale: milestoneRationale(params.goal, generatedMilestone),
        changeLabel: existingMilestone ? "updated" : "new",
      };
      affectedMilestoneCount += 1;
    }

    milestoneDrafts.push(draft);
    generatedMilestoneIdToDraftId.set(generatedMilestone.id, draft.id);
    if (existingMilestone) {
      usedMilestoneIds.add(existingMilestone.id);
    }
  }

  for (const milestone of params.existingMilestones) {
    if (usedMilestoneIds.has(milestone.id)) {
      continue;
    }

    if (
      protectedItems.milestoneIds.has(milestone.id) ||
      params.existingTasks.some((task) => task.milestoneId === milestone.id && protectedItems.taskIds.has(task.id))
    ) {
      milestoneDrafts.push({
        id: milestone.id,
        sourceMilestoneId: milestone.id,
        continuityKey: getMilestoneContinuityKey(milestone),
        title: milestone.title,
        summary: milestone.summary,
        targetDate: milestone.targetDate,
        estimatedMinutes: milestone.estimatedMinutes,
        sortOrder: milestoneDrafts.length + 1,
        protected: true,
        rationale: milestoneRationale(params.goal, milestone),
        changeLabel: "preserved",
      });
    } else {
      affectedMilestoneCount += 1;
    }
  }

  milestoneDrafts.sort((left, right) => left.sortOrder - right.sortOrder);
  milestoneDrafts.forEach((draft, index) => {
    draft.sortOrder = index + 1;
  });

  const ensureMilestoneDraftId = (task: Task) => {
    const generatedDraftId =
      task.milestoneId && generatedMilestoneIdToDraftId.has(task.milestoneId)
        ? generatedMilestoneIdToDraftId.get(task.milestoneId)
        : null;
    if (generatedDraftId) {
      return generatedDraftId;
    }

    const existingMilestone =
      task.milestoneId ? milestonesById.get(task.milestoneId) ?? null : null;
    if (!existingMilestone) {
      return milestoneDrafts[0]?.id ?? createId("review-milestone");
    }

    const existingDraft = milestoneDrafts.find((draft) => draft.id === existingMilestone.id);
    if (existingDraft) {
      return existingDraft.id;
    }

    const draft: GoalReviewMilestoneDraft = {
      id: existingMilestone.id,
      sourceMilestoneId: existingMilestone.id,
      continuityKey: getMilestoneContinuityKey(existingMilestone),
      title: existingMilestone.title,
      summary: existingMilestone.summary,
      targetDate: existingMilestone.targetDate,
      estimatedMinutes: existingMilestone.estimatedMinutes,
      sortOrder: milestoneDrafts.length + 1,
      protected: true,
      rationale: milestoneRationale(params.goal, existingMilestone),
      changeLabel: "preserved",
    };
    milestoneDrafts.push(draft);
    return draft.id;
  };

  let taskOrder = 1;
  for (const generatedTask of params.generatedTasks) {
    const continuityKey = getTaskContinuityKey(generatedTask);
    const existingTask = existingTasksByKey.get(continuityKey);
    const protectedTask = !!existingTask && protectedItems.taskIds.has(existingTask.id);
    const changed = existingTask ? taskChanged(existingTask, generatedTask) : true;
    const shouldRefresh = params.mode === "full_regeneration" ? true : changed;
    const milestoneId = ensureMilestoneDraftId(generatedTask);

    let draft: GoalReviewTaskDraft;
    if (existingTask && (!shouldRefresh || protectedTask)) {
      draft = buildTaskDraft(existingTask, milestoneId, taskOrder, {
        sourceTaskId: existingTask.id,
        protected: protectedTask,
        userAdjusted: protectedTask,
        changeLabel: protectedTask ? "preserved" : "recommended",
      });
    } else {
      draft = buildTaskDraft(
        {
          ...generatedTask,
          milestoneId,
        },
        milestoneId,
        taskOrder,
        {
          sourceTaskId: existingTask?.id ?? null,
          protected: false,
          changeLabel: existingTask ? "updated" : "new",
        },
      );
      affectedTaskCount += 1;
    }

    taskDrafts.push(draft);
    if (existingTask) {
      usedTaskIds.add(existingTask.id);
    }
    taskOrder += 1;
  }

  for (const task of params.existingTasks) {
    if (usedTaskIds.has(task.id)) {
      continue;
    }

    if (protectedItems.taskIds.has(task.id)) {
      taskDrafts.push(
        buildTaskDraft(task, ensureMilestoneDraftId(task), taskOrder, {
          sourceTaskId: task.id,
          protected: true,
          userAdjusted: true,
          changeLabel: "preserved",
        }),
      );
    } else {
      affectedTaskCount += 1;
    }

    taskOrder += 1;
  }

  taskDrafts.sort((left, right) => left.order - right.order);
  taskDrafts.forEach((draft, index) => {
    draft.order = index + 1;
  });

  return {
    mode: params.mode,
    createdAt: nowIso(),
    headline: draftHeadline(params.mode, params.goal),
    summary: draftSummary(params.mode, params.impact),
    rationale: impactRationale(params.mode, params.impact),
    recommendedAction:
      params.mode === "new_goal"
        ? "targeted_regeneration"
        : params.impact?.recommendation ?? "targeted_regeneration",
    milestones: milestoneDrafts,
    tasks: taskDrafts,
    impactSummary: {
      changedFields: params.impact?.changedFields ?? [],
      affectedMilestoneCount,
      affectedTaskCount,
      protectedTaskCount: protectedItems.taskIds.size,
      recommendedRegeneration:
        params.mode === "new_goal" ? false : params.impact?.recommendedRegeneration ?? true,
    },
  };
}
