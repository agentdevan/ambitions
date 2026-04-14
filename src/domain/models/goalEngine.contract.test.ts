import {
  ContractValueSource,
  GoalMode,
  GoalRelationshipKind,
  GoalTempo,
} from "./goalEngine";
import {
  getActiveMilestoneSummaries,
  getCompletionCounts,
  getPrimaryNextSteps,
  getProgressSummary,
  groupStepsBySection,
  groupStepsByTiming,
} from "./goalEngineSelectors";
import {
  goalModeFixtures,
  migratedLegacyGoalCases,
  migratedLegacyGoalDraftFixtures,
  migratedLegacyGoalFixtures,
  migratedLegacyPlanFixtures,
} from "./goalEngineFixtures";

function assert(condition: unknown, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}

export function runGoalEngineContractTests(): void {
  for (const [index, scenario] of migratedLegacyGoalCases.entries()) {
    const migratedDraft = migratedLegacyGoalDraftFixtures[index]?.draft;
    const migratedPlan = migratedLegacyPlanFixtures[index]?.plan;
    const migratedGoal = migratedLegacyGoalFixtures[index]?.goal;

    assert(migratedDraft, `${scenario.id}: expected a migrated draft fixture.`);
    assert(migratedGoal, `${scenario.id}: expected a migrated goal fixture.`);
    assert(migratedDraft.mode === scenario.expectations.mode, `${scenario.id}: migrated draft mode mismatch.`);
    assert(
      migratedDraft.contract?.mode?.source === scenario.expectations.modeSource,
      `${scenario.id}: mode provenance source mismatch.`,
    );
    assert(migratedDraft.timing.tempo === scenario.expectations.tempo, `${scenario.id}: tempo mismatch.`);
    assert(
      migratedDraft.contract?.timing?.tempo?.source === scenario.expectations.tempoSource,
      `${scenario.id}: tempo provenance source mismatch.`,
    );
    assert(
      migratedDraft.actor.ownership === scenario.expectations.ownership,
      `${scenario.id}: ownership mismatch.`,
    );
    assert(
      migratedDraft.actor.provenance?.ownership?.source === scenario.expectations.ownershipSource,
      `${scenario.id}: ownership provenance source mismatch.`,
    );
    assert(
      migratedDraft.relationshipKind === scenario.expectations.relationshipKind,
      `${scenario.id}: relationship mismatch.`,
    );
    assert(
      migratedDraft.contract?.relationshipKind?.source === scenario.expectations.relationshipSource,
      `${scenario.id}: relationship provenance source mismatch.`,
    );
    assert(migratedPlan, `${scenario.id}: expected a migrated plan fixture.`);
    assert(migratedPlan.sections.length > 0, `${scenario.id}: expected migrated sections.`);
    assert(
      migratedPlan.sections.some((section) =>
        section.steps.some((step) => step.contract?.timing?.timingType?.source === scenario.expectations.stepTimingSource),
      ),
      `${scenario.id}: expected migrated step timing provenance.`,
    );
    assert(migratedGoal.contract?.mode?.inferred !== undefined, `${scenario.id}: goal contract metadata missing.`);
  }

  const recoveryGoal = goalModeFixtures[GoalMode.Recovery];
  const recoveryPrimarySteps = getPrimaryNextSteps(recoveryGoal);
  assert(recoveryPrimarySteps.length > 0, "recovery fixture should expose primary next steps.");

  const recoveryTimingGroups = groupStepsByTiming(recoveryGoal);
  assert(recoveryTimingGroups.suggested.length > 0, "recovery fixture should expose suggested steps.");
  assert(recoveryTimingGroups.logWhenDone.length > 0, "recovery fixture should expose log-when-done steps.");

  const delegatedGoal = goalModeFixtures[GoalMode.DelegatedSupport];
  const delegatedMilestones = getActiveMilestoneSummaries(delegatedGoal);
  assert(Array.isArray(delegatedMilestones), "active milestone summaries should always be array-safe.");

  const completionCounts = getCompletionCounts(goalModeFixtures[GoalMode.Project]);
  assert(completionCounts.total >= 2, "project fixture should expose completion counts.");

  const progressSummary = getProgressSummary(goalModeFixtures[GoalMode.Habit]);
  assert(progressSummary.totalSteps > 0, "habit fixture should expose progress summary totals.");

  const sectionGroups = groupStepsBySection(goalModeFixtures[GoalMode.Learning]);
  assert(sectionGroups.length >= 2, "learning fixture should group steps by section.");

  const projectGoal = goalModeFixtures[GoalMode.Project];
  assert(projectGoal.mode === GoalMode.Project, "project fixture sanity check failed.");
  assert(projectGoal.timing.tempo === GoalTempo.TargetWindow, "project fixture tempo sanity check failed.");
  assert(
    goalModeFixtures[GoalMode.DelegatedSupport].relationshipKind === GoalRelationshipKind.Support,
    "delegated support fixture sanity check failed.",
  );
  assert(
    migratedLegacyGoalDraftFixtures.some(
      (fixture) => fixture.draft.contract?.mode?.source === ContractValueSource.LegacyGoalTags,
    ),
    "expected at least one migrated draft to capture tag-based mode provenance.",
  );
}

runGoalEngineContractTests();
