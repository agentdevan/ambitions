import { GoalLifecycleAction, GoalLifecycleHandling } from "./metadata";
import { GoalMilestone, GoalMilestoneStatus, Task, TaskSchedulingState, TaskStatus } from "../../domain/models";

function preserveTask(task: Task) {
  return (
    task.status === TaskStatus.Completed ||
    task.status === TaskStatus.InProgress
  );
}

export function describeLifecycleOptions(action: GoalLifecycleAction) {
  if (action === "pause") {
    return [
      {
        key: "remove_from_active_plans" as GoalLifecycleHandling,
        label: "Remove from active plans",
        description: "Keep the goal quiet and clear unscheduled downstream pressure.",
      },
      {
        key: "keep_scheduled" as GoalLifecycleHandling,
        label: "Keep scheduled work",
        description: "Pause future generation while leaving already scheduled items alone.",
      },
      {
        key: "defer_downstream" as GoalLifecycleHandling,
        label: "Defer downstream work",
        description: "Preserve continuity, but push unfinished work out of the active lane.",
      },
    ];
  }

  return [
    {
      key: "keep_scheduled" as GoalLifecycleHandling,
      label: "Keep scheduled work",
      description: "Archive the goal while letting already committed work finish cleanly.",
    },
    {
      key: "defer_downstream" as GoalLifecycleHandling,
      label: "Defer downstream work",
      description: "Archive the goal and move unfinished work out of the current plan.",
    },
    {
      key: "archive_downstream" as GoalLifecycleHandling,
      label: "Archive downstream work",
      description: "Quietly archive unfinished downstream structure without deleting history.",
    },
  ];
}

export function applyDownstreamHandling(params: {
  action: GoalLifecycleAction;
  handling: GoalLifecycleHandling;
  milestones: GoalMilestone[];
  tasks: Task[];
}) {
  const timestamp = new Date().toISOString();

  const milestones = params.milestones.map((milestone) => {
    if (milestone.status === GoalMilestoneStatus.Completed || milestone.status === GoalMilestoneStatus.InProgress) {
      return milestone;
    }

    if (params.handling === "archive_downstream") {
      return {
        ...milestone,
        status: GoalMilestoneStatus.Archived,
        updatedAt: timestamp,
        version: milestone.version + 1,
      };
    }

    return milestone;
  });

  const tasks = params.tasks.map((task) => {
    if (preserveTask(task)) {
      return task;
    }

    if (params.handling === "keep_scheduled" && task.status === TaskStatus.Scheduled) {
      return task;
    }

    if (params.handling === "archive_downstream") {
      return {
        ...task,
        status: TaskStatus.Cancelled,
        schedulingState: TaskSchedulingState.Unscheduled,
        scheduledDate: null,
        earliestStartAt: null,
        latestFinishAt: null,
        updatedAt: timestamp,
        version: task.version + 1,
      };
    }

    return {
      ...task,
      status: TaskStatus.Deferred,
      schedulingState: TaskSchedulingState.Unscheduled,
      scheduledDate: null,
      earliestStartAt: null,
      latestFinishAt: null,
      updatedAt: timestamp,
      version: task.version + 1,
      metadata: {
        ...task.metadata,
        phase11LifecycleAction: params.action,
        phase11LifecycleHandling: params.handling,
      },
    };
  });

  return { milestones, tasks };
}
