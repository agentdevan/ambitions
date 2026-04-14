import { Goal as LegacyGoal, GoalMilestone, GoalType } from "./goal";
import { Task, TaskStatus } from "./planning";
import { ISODateTimeString } from "./shared";
import {
  ContractValueProvenance,
  ContractValueSource,
  createContractProvenance,
  createDefaultGoalActor,
  createGoalActorProvenance,
  createGoalContractMetadata,
  createDefaultPlanningStrategy,
  createDefaultProgressStrategy,
  createGoalTiming,
  createGoalTimingProvenance,
  createStepContractMetadata,
  EvidenceSource,
  ExecutionOwnership,
  Goal as EngineGoal,
  GoalActor,
  GoalDraft as EngineGoalDraft,
  GoalLifecycleState,
  GoalMode,
  GoalRelationshipKind,
  GoalPlan as EngineGoalPlan,
  GoalTempo,
  GoalTiming,
  GOAL_ENGINE_SCHEMA_VERSION,
  lintGoal,
  lintGoalPlan,
  PlanSection as EnginePlanSection,
  PlanSectionKind,
  Step as EngineStep,
  StepLifecycleState,
  StepType,
  TimingType,
} from "./goalEngine";

function normalizeOwnership(raw: unknown): ExecutionOwnership | null {
  const candidate = typeof raw === "string" ? raw.trim() : "";
  const values = new Set<string>(Object.values(ExecutionOwnership));
  return values.has(candidate) ? (candidate as ExecutionOwnership) : null;
}

function inferGoalMode(goal: LegacyGoal): { value: GoalMode; provenance: ContractValueProvenance } {
  const explicit = typeof goal.metadata.goalMode === "string" ? goal.metadata.goalMode : null;
  if (explicit && Object.values(GoalMode).includes(explicit as GoalMode)) {
    return {
      value: explicit as GoalMode,
      provenance: createContractProvenance({
        source: ContractValueSource.LegacyGoalMetadata,
        inferred: false,
        confidence: 1,
        reason: "The migrated goal mode came directly from legacy goal metadata.goalMode.",
      }),
    };
  }

  const normalizedTags = new Set(goal.tags.map((tag) => tag.toLowerCase()));
  if (normalizedTags.has("learning")) {
    return {
      value: GoalMode.Learning,
      provenance: createContractProvenance({
        source: ContractValueSource.LegacyGoalTags,
        inferred: true,
        confidence: 0.88,
        reason: "The migrated goal tags explicitly signal a learning-oriented mode.",
      }),
    };
  }
  if (normalizedTags.has("exploration") || normalizedTags.has("research")) {
    return {
      value: GoalMode.Exploration,
      provenance: createContractProvenance({
        source: ContractValueSource.LegacyGoalTags,
        inferred: true,
        confidence: 0.84,
        reason: "The migrated goal tags emphasize exploration or research work.",
      }),
    };
  }
  if (normalizedTags.has("recovery")) {
    return {
      value: GoalMode.Recovery,
      provenance: createContractProvenance({
        source: ContractValueSource.LegacyGoalTags,
        inferred: true,
        confidence: 0.82,
        reason: "The migrated goal tags indicate recovery-oriented work.",
      }),
    };
  }
  if (normalizedTags.has("maintenance")) {
    return {
      value: GoalMode.Maintenance,
      provenance: createContractProvenance({
        source: ContractValueSource.LegacyGoalTags,
        inferred: true,
        confidence: 0.8,
        reason: "The migrated goal tags describe ongoing maintenance work.",
      }),
    };
  }
  if (normalizedTags.has("delegated") || normalizedTags.has("support")) {
    return {
      value: GoalMode.DelegatedSupport,
      provenance: createContractProvenance({
        source: ContractValueSource.LegacyGoalTags,
        inferred: true,
        confidence: 0.86,
        reason: "The migrated goal tags indicate support or delegated work.",
      }),
    };
  }

  switch (goal.type) {
    case GoalType.Habit:
      return {
        value: GoalMode.Habit,
        provenance: createContractProvenance({
          source: ContractValueSource.LegacyGoalType,
          inferred: true,
          confidence: 0.9,
          reason: "The legacy goal type maps directly to an ongoing habit mode.",
        }),
      };
    case GoalType.System:
      return {
        value: GoalMode.Maintenance,
        provenance: createContractProvenance({
          source: ContractValueSource.LegacyGoalType,
          inferred: true,
          confidence: 0.84,
          reason: "The legacy goal type signals systems maintenance rather than a terminal outcome.",
        }),
      };
    case GoalType.Project:
      return {
        value: GoalMode.Project,
        provenance: createContractProvenance({
          source: ContractValueSource.LegacyGoalType,
          inferred: true,
          confidence: 0.92,
          reason: "The legacy goal type maps cleanly to a project mode.",
        }),
      };
    case GoalType.Outcome:
    default:
      return {
        value: GoalMode.Achievement,
        provenance: createContractProvenance({
          source: ContractValueSource.LegacyGoalType,
          inferred: true,
          confidence: 0.82,
          reason: "The legacy goal type reads as an achievement-oriented outcome goal.",
        }),
      };
  }
}

function inferGoalTempo(goal: LegacyGoal, mode: GoalMode): { value: GoalTempo; provenance: ContractValueProvenance } {
  const explicit = typeof goal.metadata.goalTempo === "string" ? goal.metadata.goalTempo : null;
  if (explicit && Object.values(GoalTempo).includes(explicit as GoalTempo)) {
    return {
      value: explicit as GoalTempo,
      provenance: createContractProvenance({
        source: ContractValueSource.LegacyGoalMetadata,
        inferred: false,
        confidence: 1,
        reason: "The migrated goal tempo came directly from legacy goal metadata.goalTempo.",
      }),
    };
  }

  if (goal.targetDate) {
    return {
      value: GoalTempo.DeadlineBased,
      provenance: createContractProvenance({
        source: ContractValueSource.LegacyGoalDates,
        inferred: true,
        confidence: 0.94,
        reason: "A legacy target date is treated as a hard deadline in the engine contract.",
      }),
    };
  }

  if ([GoalMode.Habit, GoalMode.Maintenance, GoalMode.Recovery, GoalMode.DelegatedSupport].includes(mode)) {
    return {
      value: GoalTempo.Ongoing,
      provenance: createContractProvenance({
        source: ContractValueSource.DerivedContract,
        inferred: true,
        confidence: 0.8,
        reason: "The inferred mode implies ongoing work rather than a terminal date.",
      }),
    };
  }

  return {
    value: GoalTempo.Untimed,
    provenance: createContractProvenance({
      source: ContractValueSource.DerivedContract,
      inferred: true,
      confidence: 0.68,
      reason: "No legacy deadline or recurring signal was present, so the contract stays untimed.",
    }),
  };
}

function buildActor(goal: LegacyGoal): GoalActor {
  const ownership =
    normalizeOwnership(goal.metadata.executionOwnership) ??
    normalizeOwnership(goal.metadata.goalOwnership) ??
    ExecutionOwnership.Self;
  const displayName = typeof goal.metadata.actorDisplayName === "string" ? goal.metadata.actorDisplayName : "You";
  const actor = createDefaultGoalActor(ownership, displayName);
  return {
    ...actor,
    provenance: createGoalActorProvenance({
      ownership: createContractProvenance({
        source:
          normalizeOwnership(goal.metadata.executionOwnership) || normalizeOwnership(goal.metadata.goalOwnership)
            ? ContractValueSource.LegacyActorMetadata
            : ContractValueSource.Migration,
        inferred:
          !(normalizeOwnership(goal.metadata.executionOwnership) || normalizeOwnership(goal.metadata.goalOwnership)),
        confidence:
          normalizeOwnership(goal.metadata.executionOwnership) || normalizeOwnership(goal.metadata.goalOwnership)
            ? 0.95
            : 0.6,
        reason:
          normalizeOwnership(goal.metadata.executionOwnership) || normalizeOwnership(goal.metadata.goalOwnership)
            ? "Execution ownership came from legacy actor metadata."
            : "Execution ownership defaulted to self because the legacy goal did not specify an owner.",
      }),
      displayName: createContractProvenance({
        source: typeof goal.metadata.actorDisplayName === "string"
          ? ContractValueSource.LegacyActorMetadata
          : ContractValueSource.Migration,
        inferred: typeof goal.metadata.actorDisplayName !== "string",
        confidence: typeof goal.metadata.actorDisplayName === "string" ? 0.95 : 0.6,
        reason:
          typeof goal.metadata.actorDisplayName === "string"
            ? "Actor display name came from legacy actor metadata."
            : "Actor display name defaulted to 'You' for migration continuity.",
      }),
    }),
  };
}

function inferRelationship(
  goal: LegacyGoal,
  actor: GoalActor,
  mode: GoalMode,
): { value: GoalRelationshipKind; provenance: ContractValueProvenance } {
  const explicit =
    typeof goal.metadata.goalRelationshipKind === "string" ? goal.metadata.goalRelationshipKind : null;
  if (explicit && Object.values(GoalRelationshipKind).includes(explicit as GoalRelationshipKind)) {
    return {
      value: explicit as GoalRelationshipKind,
      provenance: createContractProvenance({
        source: ContractValueSource.LegacyGoalMetadata,
        inferred: false,
        confidence: 1,
        reason: "The relationship kind came directly from legacy goal metadata.goalRelationshipKind.",
      }),
    };
  }

  if (mode === GoalMode.DelegatedSupport) {
    return {
      value: GoalRelationshipKind.Support,
      provenance: createContractProvenance({
        source: ContractValueSource.DerivedContract,
        inferred: true,
        confidence: 0.88,
        reason: "Delegated support mode implies a support relationship in the engine contract.",
      }),
    };
  }
  if (goal.parentGoalId) {
    return {
      value: actor.ownership === ExecutionOwnership.Self
        ? GoalRelationshipKind.Child
        : GoalRelationshipKind.Delegated,
      provenance: createContractProvenance({
        source: ContractValueSource.LegacyGoalParent,
        inferred: true,
        confidence: 0.86,
        reason:
          actor.ownership === ExecutionOwnership.Self
            ? "A legacy parent goal with self ownership implies a child relationship."
            : "A legacy parent goal with non-self ownership implies delegated work.",
      }),
    };
  }
  return {
    value: GoalRelationshipKind.Independent,
    provenance: createContractProvenance({
      source: ContractValueSource.Migration,
      inferred: true,
      confidence: 0.72,
      reason: "The migrated goal has no parent or support signal, so it remains independent.",
    }),
  };
}

function buildGoalTiming(goal: LegacyGoal, mode: GoalMode): GoalTiming {
  const tempo = inferGoalTempo(goal, mode);
  if (tempo.value === GoalTempo.DeadlineBased) {
    return createGoalTiming({
      tempo: tempo.value,
      timingType: TimingType.DueAt,
      startsOn: goal.startDate,
      dueAt: goal.targetDate ? `${goal.targetDate}T23:59:59.000Z` : null,
      progressReviewCadenceDays: 7,
      provenance: createGoalTimingProvenance({
        tempo: tempo.provenance,
        timingType: createContractProvenance({
          source: ContractValueSource.LegacyGoalDates,
          inferred: true,
          confidence: 0.94,
          reason: "A goal target date is migrated into a due_at timing type.",
        }),
        startsOn: goal.startDate
          ? createContractProvenance({
              source: ContractValueSource.LegacyGoalDates,
              inferred: false,
              confidence: 0.98,
              reason: "The goal start date came directly from the legacy goal record.",
            })
          : null,
        dueAt: goal.targetDate
          ? createContractProvenance({
              source: ContractValueSource.LegacyGoalDates,
              inferred: true,
              confidence: 0.9,
              reason: "The legacy target date was normalized to an end-of-day due timestamp.",
            })
          : null,
        progressReviewCadenceDays: createContractProvenance({
          source: ContractValueSource.DefaultStrategy,
          inferred: true,
          confidence: 0.72,
          reason: "The review cadence defaults to 7 days during migration.",
        }),
      }),
    });
  }

  if (tempo.value === GoalTempo.Ongoing) {
    return createGoalTiming({
      tempo: tempo.value,
      timingType: TimingType.RepeatWithinWindow,
      startsOn: goal.startDate,
      repeatEveryDays: 7,
      progressReviewCadenceDays: 7,
      provenance: createGoalTimingProvenance({
        tempo: tempo.provenance,
        timingType: createContractProvenance({
          source: ContractValueSource.DerivedContract,
          inferred: true,
          confidence: 0.86,
          reason: "Ongoing tempo maps to repeat_within_window timing for migrated plans.",
        }),
        startsOn: goal.startDate
          ? createContractProvenance({
              source: ContractValueSource.LegacyGoalDates,
              inferred: false,
              confidence: 0.98,
              reason: "The goal start date came directly from the legacy goal record.",
            })
          : null,
        repeatEveryDays: createContractProvenance({
          source: ContractValueSource.DefaultStrategy,
          inferred: true,
          confidence: 0.64,
          reason: "The migration layer applies a weekly repeat cadence when no stronger recurrence data exists.",
        }),
        progressReviewCadenceDays: createContractProvenance({
          source: ContractValueSource.DefaultStrategy,
          inferred: true,
          confidence: 0.72,
          reason: "The review cadence defaults to 7 days during migration.",
        }),
      }),
    });
  }

  return createGoalTiming({
    tempo: tempo.value,
    timingType: TimingType.LogWhenDone,
    startsOn: goal.startDate,
    progressReviewCadenceDays: mode === GoalMode.Exploration ? 5 : 7,
    provenance: createGoalTimingProvenance({
      tempo: tempo.provenance,
      timingType: createContractProvenance({
        source: ContractValueSource.DerivedContract,
        inferred: true,
        confidence: 0.7,
        reason: "Untimed migrated goals default to log_when_done timing.",
      }),
      startsOn: goal.startDate
        ? createContractProvenance({
            source: ContractValueSource.LegacyGoalDates,
            inferred: false,
            confidence: 0.98,
            reason: "The goal start date came directly from the legacy goal record.",
          })
        : null,
      progressReviewCadenceDays: createContractProvenance({
        source: ContractValueSource.DefaultStrategy,
        inferred: true,
        confidence: 0.7,
        reason: "The review cadence defaults by mode during migration.",
      }),
    }),
  });
}

function mapTaskState(task: Task): StepLifecycleState {
  switch (task.status) {
    case TaskStatus.InProgress:
      return StepLifecycleState.Active;
    case TaskStatus.Completed:
      return StepLifecycleState.Completed;
    case TaskStatus.Cancelled:
      return StepLifecycleState.Cancelled;
    case TaskStatus.Missed:
    case TaskStatus.Deferred:
      return StepLifecycleState.Blocked;
    default:
      return StepLifecycleState.Planned;
  }
}

function mapStepType(mode: GoalMode, taskTitle: string): StepType {
  switch (mode) {
    case GoalMode.Habit:
    case GoalMode.Maintenance:
      return StepType.RecurringRoutine;
    case GoalMode.Learning:
      return taskTitle.toLowerCase().includes("reflect")
        ? StepType.ReflectionPrompt
        : StepType.LearningCheckpoint;
    case GoalMode.Exploration:
      return StepType.ExplorationExperiment;
    case GoalMode.DelegatedSupport:
      return StepType.SupportAction;
    case GoalMode.Recovery:
      return taskTitle.toLowerCase().includes("log") ? StepType.ObservationPrompt : StepType.ActionUnit;
    default:
      return StepType.ActionUnit;
  }
}

function taskTiming(task: Task, baseTiming: GoalTiming): GoalTiming {
  if (task.latestFinishAt) {
    return createGoalTiming({
      tempo: baseTiming.tempo,
      timingType: TimingType.DueAt,
      startsOn: task.scheduledDate ?? baseTiming.startsOn,
      dueAt: task.latestFinishAt,
      progressReviewCadenceDays: baseTiming.progressReviewCadenceDays,
      provenance: createGoalTimingProvenance({
        tempo: baseTiming.provenance?.tempo ?? null,
        timingType: createContractProvenance({
          source: ContractValueSource.LegacyTaskDates,
          inferred: true,
          confidence: 0.96,
          reason: "Task latestFinishAt maps directly to a due_at step timing.",
        }),
        startsOn: task.scheduledDate
          ? createContractProvenance({
              source: ContractValueSource.LegacyTaskDates,
              inferred: false,
              confidence: 0.95,
              reason: "Task scheduledDate came directly from the legacy task.",
            })
          : baseTiming.provenance?.startsOn ?? null,
        dueAt: createContractProvenance({
          source: ContractValueSource.LegacyTaskDates,
          inferred: false,
          confidence: 0.98,
          reason: "Task latestFinishAt came directly from the legacy task.",
        }),
        progressReviewCadenceDays: baseTiming.provenance?.progressReviewCadenceDays ?? null,
      }),
    });
  }

  if (task.targetDate) {
    return createGoalTiming({
      tempo: baseTiming.tempo === GoalTempo.Untimed ? GoalTempo.TargetWindow : baseTiming.tempo,
      timingType: TimingType.TargetBy,
      startsOn: task.scheduledDate ?? baseTiming.startsOn,
      targetBy: task.targetDate,
      progressReviewCadenceDays: baseTiming.progressReviewCadenceDays,
      provenance: createGoalTimingProvenance({
        tempo:
          baseTiming.tempo === GoalTempo.Untimed
            ? createContractProvenance({
                source: ContractValueSource.LegacyTaskDates,
                inferred: true,
                confidence: 0.84,
                reason: "A task target date upgrades untimed base timing to a target window.",
              })
            : baseTiming.provenance?.tempo ?? null,
        timingType: createContractProvenance({
          source: ContractValueSource.LegacyTaskDates,
          inferred: true,
          confidence: 0.94,
          reason: "Task targetDate maps directly to a target_by step timing.",
        }),
        startsOn: task.scheduledDate
          ? createContractProvenance({
              source: ContractValueSource.LegacyTaskDates,
              inferred: false,
              confidence: 0.95,
              reason: "Task scheduledDate came directly from the legacy task.",
            })
          : baseTiming.provenance?.startsOn ?? null,
        targetBy: createContractProvenance({
          source: ContractValueSource.LegacyTaskDates,
          inferred: false,
          confidence: 0.98,
          reason: "Task targetDate came directly from the legacy task.",
        }),
        progressReviewCadenceDays: baseTiming.provenance?.progressReviewCadenceDays ?? null,
      }),
    });
  }

  if (task.isRecurringTemplate) {
    return createGoalTiming({
      tempo: GoalTempo.Ongoing,
      timingType: TimingType.RepeatWithinWindow,
      startsOn: task.scheduledDate ?? baseTiming.startsOn,
      repeatEveryDays: 7,
      progressReviewCadenceDays: 7,
      provenance: createGoalTimingProvenance({
        tempo: createContractProvenance({
          source: ContractValueSource.LegacyTaskRecurrence,
          inferred: true,
          confidence: 0.9,
          reason: "Recurring template tasks always migrate to ongoing tempo.",
        }),
        timingType: createContractProvenance({
          source: ContractValueSource.LegacyTaskRecurrence,
          inferred: true,
          confidence: 0.9,
          reason: "Recurring template tasks always migrate to repeat_within_window timing.",
        }),
        startsOn: task.scheduledDate
          ? createContractProvenance({
              source: ContractValueSource.LegacyTaskDates,
              inferred: false,
              confidence: 0.95,
              reason: "Task scheduledDate came directly from the legacy task.",
            })
          : baseTiming.provenance?.startsOn ?? null,
        repeatEveryDays: createContractProvenance({
          source: ContractValueSource.DefaultStrategy,
          inferred: true,
          confidence: 0.64,
          reason: "Recurring migrated tasks default to a weekly repeat cadence until native recurrence lands.",
        }),
        progressReviewCadenceDays: createContractProvenance({
          source: ContractValueSource.DefaultStrategy,
          inferred: true,
          confidence: 0.72,
          reason: "The review cadence defaults to 7 days during migration.",
        }),
      }),
    });
  }

  return createGoalTiming({
    tempo: baseTiming.tempo,
    timingType: baseTiming.tempo === GoalTempo.Untimed ? TimingType.LogWhenDone : TimingType.SuggestedNext,
    startsOn: task.scheduledDate ?? baseTiming.startsOn,
    suggestedNextAt: task.earliestStartAt,
    progressReviewCadenceDays: baseTiming.progressReviewCadenceDays,
    provenance: createGoalTimingProvenance({
      tempo: baseTiming.provenance?.tempo ?? null,
      timingType: createContractProvenance({
        source: task.earliestStartAt ? ContractValueSource.LegacyTaskDates : ContractValueSource.DerivedContract,
        inferred: true,
        confidence: task.earliestStartAt ? 0.82 : 0.66,
        reason: task.earliestStartAt
          ? "An earliestStartAt hint becomes a suggested_next timing."
          : "Without an explicit task date, the migration layer keeps the step as the next suggested move.",
      }),
      startsOn: task.scheduledDate
        ? createContractProvenance({
            source: ContractValueSource.LegacyTaskDates,
            inferred: false,
            confidence: 0.95,
            reason: "Task scheduledDate came directly from the legacy task.",
          })
        : baseTiming.provenance?.startsOn ?? null,
      suggestedNextAt: task.earliestStartAt
        ? createContractProvenance({
            source: ContractValueSource.LegacyTaskDates,
            inferred: false,
            confidence: 0.95,
            reason: "Task earliestStartAt came directly from the legacy task.",
          })
        : null,
      progressReviewCadenceDays: baseTiming.provenance?.progressReviewCadenceDays ?? null,
    }),
  });
}

function milestoneStep(goal: LegacyGoal, milestone: GoalMilestone, sectionId: string, mode: GoalMode): EngineStep {
  const actor = buildActor(goal);
  return {
    id: `migrated-step-${milestone.id}`,
    sectionId,
    title: milestone.title,
    summary: milestone.summary,
    type: mode === GoalMode.Learning ? StepType.LearningCheckpoint : StepType.ActionUnit,
    state: milestone.status === "completed" ? StepLifecycleState.Completed : StepLifecycleState.Planned,
    owner: actor,
    timing: createGoalTiming({
      tempo: milestone.targetDate ? GoalTempo.TargetWindow : GoalTempo.Untimed,
      timingType: milestone.targetDate ? TimingType.TargetBy : TimingType.LogWhenDone,
      targetBy: milestone.targetDate,
      progressReviewCadenceDays: 7,
    }),
    dependencyStepIds: [],
    isOptional: false,
    isRepeatable: false,
    evidenceRequired: true,
    successSignals: milestone.summary ? [milestone.summary] : [],
    actionability: {
      action: milestone.title,
      completionDefinition: milestone.summary ?? `${milestone.title} is complete.`,
      evidenceOfCompletion: [milestone.summary ?? `${milestone.title} is complete.`],
      fallbackMicroStep: `Capture the smallest visible milestone sign for "${milestone.title}".`,
      contextRequirements: [],
    },
    contract: createStepContractMetadata({
      legacySourceKind: "milestone",
      legacySourceId: milestone.id,
      actor: actor.provenance ?? null,
      timing: createGoalTimingProvenance({
        tempo: createContractProvenance({
          source: ContractValueSource.LegacyMilestone,
          inferred: true,
          confidence: milestone.targetDate ? 0.86 : 0.7,
          reason: milestone.targetDate
            ? "Milestones with target dates migrate to a target-window tempo."
            : "Milestones without dates stay untimed during migration.",
        }),
        timingType: createContractProvenance({
          source: ContractValueSource.LegacyMilestone,
          inferred: true,
          confidence: milestone.targetDate ? 0.86 : 0.7,
          reason: milestone.targetDate
            ? "Milestones with target dates migrate to target_by timing."
            : "Milestones without dates migrate to log_when_done timing.",
        }),
        targetBy: milestone.targetDate
          ? createContractProvenance({
              source: ContractValueSource.LegacyMilestone,
              inferred: false,
              confidence: 0.98,
              reason: "Milestone targetDate came directly from the legacy milestone.",
            })
          : null,
        progressReviewCadenceDays: createContractProvenance({
          source: ContractValueSource.DefaultStrategy,
          inferred: true,
          confidence: 0.72,
          reason: "Migrated milestones use the default 7-day review cadence.",
        }),
      }),
    }),
  };
}

function taskToStep(
  goal: LegacyGoal,
  task: Task,
  sectionId: string,
  mode: GoalMode,
  baseTiming: GoalTiming,
): EngineStep {
  const actor = buildActor(goal);
  const timing = taskTiming(task, baseTiming);
  return {
    id: `migrated-step-${task.id}`,
    sectionId,
    title: task.title,
    summary: task.summary,
    type: mapStepType(mode, task.title),
    state: mapTaskState(task),
    owner: actor,
    timing,
    dependencyStepIds: task.parentTaskId ? [`migrated-step-${task.parentTaskId}`] : [],
    isOptional: task.status === TaskStatus.Skipped,
    isRepeatable: task.isRecurringTemplate,
    evidenceRequired: task.status !== TaskStatus.Cancelled,
    successSignals: [task.summary ?? `${task.title} is complete.`],
    actionability: {
      action: task.title,
      completionDefinition: task.summary ?? `${task.title} is complete.`,
      evidenceOfCompletion: [task.summary ?? `${task.title} is complete.`],
      fallbackMicroStep: `Set up the smallest next piece of "${task.title}".`,
      contextRequirements: [],
    },
    contract: createStepContractMetadata({
      legacySourceKind: "task",
      legacySourceId: task.id,
      actor: actor.provenance ?? null,
      timing: timing.provenance ?? null,
    }),
  };
}

export function migrateLegacyPlan(params: {
  goal: LegacyGoal;
  milestones?: GoalMilestone[];
  tasks?: Task[];
  now?: ISODateTimeString;
}): EngineGoalPlan | null {
  const mode = inferGoalMode(params.goal);
  const timing = buildGoalTiming(params.goal, mode.value);
  const now = params.now ?? params.goal.updatedAt;
  const sections: EnginePlanSection[] = [];
  const milestoneSteps = (params.milestones ?? []).map((milestone) =>
    milestoneStep(params.goal, milestone, `section-overview-${params.goal.id}`, mode.value),
  );
  const activeTasks = (params.tasks ?? [])
    .filter((task) => [TaskStatus.Ready, TaskStatus.Scheduled, TaskStatus.InProgress].includes(task.status))
    .map((task) => taskToStep(params.goal, task, `section-active-${params.goal.id}`, mode.value, timing));
  const upcomingTasks = (params.tasks ?? [])
    .filter((task) =>
      ![TaskStatus.Ready, TaskStatus.Scheduled, TaskStatus.InProgress, TaskStatus.Completed, TaskStatus.Cancelled].includes(
        task.status,
      ),
    )
    .map((task) => taskToStep(params.goal, task, `section-upcoming-${params.goal.id}`, mode.value, timing));
  const completedTasks = (params.tasks ?? [])
    .filter((task) => task.status === TaskStatus.Completed)
    .map((task) => taskToStep(params.goal, task, `section-completed-${params.goal.id}`, mode.value, timing));

  if (milestoneSteps.length > 0) {
    sections.push({
      id: `section-overview-${params.goal.id}`,
      goalId: params.goal.id,
      title: "Milestones",
      summary: "Migrated from the existing milestone structure.",
      kind: PlanSectionKind.Overview,
      orderIndex: sections.length,
      steps: milestoneSteps,
    });
  }

  if (activeTasks.length > 0) {
    sections.push({
      id: `section-active-${params.goal.id}`,
      goalId: params.goal.id,
      title: "Current steps",
      summary: "Open work carried forward from the current task model.",
      kind: PlanSectionKind.ActiveSteps,
      orderIndex: sections.length,
      steps: activeTasks,
    });
  }

  if (upcomingTasks.length > 0) {
    sections.push({
      id: `section-upcoming-${params.goal.id}`,
      goalId: params.goal.id,
      title: "Queued work",
      summary: "Deferred or unscheduled work still linked to the goal.",
      kind: PlanSectionKind.Upcoming,
      orderIndex: sections.length,
      steps: upcomingTasks,
    });
  }

  if (completedTasks.length > 0) {
    sections.push({
      id: `section-completed-${params.goal.id}`,
      goalId: params.goal.id,
      title: "Completed",
      summary: "Completed work preserved for continuity and analytics.",
      kind: PlanSectionKind.Completed,
      orderIndex: sections.length,
      steps: completedTasks,
    });
  }

  if (sections.length === 0) {
    return null;
  }

  const plan: EngineGoalPlan = {
    id: `migrated-plan-${params.goal.id}`,
    goalId: params.goal.id,
    version: 1,
    generatedAt: now,
    summary: "Auto-generated from the legacy goal, milestone, and task records.",
    strategy: createDefaultPlanningStrategy(mode.value),
    sections,
    lint: {
      goalId: params.goal.id,
      planVersion: 1,
      isValid: true,
      issueCount: 0,
      issues: [],
    },
  };
  plan.lint = lintGoalPlan(plan);
  return plan;
}

export function migrateLegacyGoalDraft(params: { goal: LegacyGoal }): EngineGoalDraft {
  const mode = inferGoalMode(params.goal);
  const actor = buildActor(params.goal);
  const relationshipKind = inferRelationship(params.goal, actor, mode.value);
  const timing = buildGoalTiming(params.goal, mode.value);

  return {
    schemaVersion: GOAL_ENGINE_SCHEMA_VERSION,
    source: EvidenceSource.Migration,
    title: params.goal.title,
    summary: params.goal.summary,
    mode: mode.value,
    relationshipKind: relationshipKind.value,
    actor,
    parentGoalId: params.goal.parentGoalId,
    tags: [...params.goal.tags],
    timing,
    planningStrategy: createDefaultPlanningStrategy(mode.value),
    progressStrategy: createDefaultProgressStrategy(mode.value, timing.tempo),
    contract: createGoalContractMetadata({
      mode: mode.provenance,
      relationshipKind: relationshipKind.provenance,
      actor: actor.provenance ?? null,
      timing: timing.provenance ?? null,
    }),
  };
}

export function migrateLegacyGoal(params: {
  goal: LegacyGoal;
  milestones?: GoalMilestone[];
  tasks?: Task[];
}): EngineGoal {
  const draft = migrateLegacyGoalDraft({ goal: params.goal });
  const plan = migrateLegacyPlan({
    goal: params.goal,
    milestones: params.milestones,
    tasks: params.tasks,
    now: params.goal.updatedAt,
  });

  const migrated: EngineGoal = {
    schemaVersion: GOAL_ENGINE_SCHEMA_VERSION,
    id: params.goal.id,
    revision: params.goal.version,
    createdAt: params.goal.createdAt,
    updatedAt: params.goal.updatedAt,
    state:
      params.goal.status === "draft"
        ? GoalLifecycleState.Draft
        : params.goal.status === "paused"
          ? GoalLifecycleState.Paused
          : params.goal.status === "completed"
            ? GoalLifecycleState.Completed
            : params.goal.status === "archived"
              ? GoalLifecycleState.Archived
              : GoalLifecycleState.Active,
    title: draft.title,
    summary: draft.summary,
    mode: draft.mode,
    relationshipKind: draft.relationshipKind,
    actor: draft.actor,
    parentGoalId: draft.parentGoalId,
    childGoalIds: [],
    supportGoalIds: [],
    tags: draft.tags,
    timing: draft.timing,
    planningStrategy: draft.planningStrategy,
    progressStrategy: draft.progressStrategy,
    plan,
    contract: draft.contract ?? null,
  };

  const lint = lintGoal(migrated);
  if (migrated.plan) {
    migrated.plan = { ...migrated.plan, lint: lintGoalPlan(migrated.plan) };
  }
  if (!lint.isValid) {
    migrated.tags = [...migrated.tags, "needs_contract_review"];
  }
  return migrated;
}
