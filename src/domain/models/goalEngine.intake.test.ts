import {
  ExecutionOwnership,
  GoalMode,
  GoalRelationshipKind,
  GoalTempo,
} from "./goalEngine";
import { goalEngineIntakeFixtures } from "./goalEngineIntakeFixtures";
import {
  ClarificationQuestionGenerator,
  IntakeClassificationService,
  buildGoalDraftFromIntake,
} from "./goalEngineIntake";

function assert(condition: unknown, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}

export function runGoalEngineIntakeTests(): void {
  const classificationService = new IntakeClassificationService();
  const clarificationGenerator = new ClarificationQuestionGenerator();

  for (const fixture of goalEngineIntakeFixtures) {
    const classification = fixture.result.classification;
    const clarification = fixture.result.clarification;

    assert(classification.mode.value === fixture.expectations.mode, `${fixture.id}: mode mismatch.`);
    assert(classification.tempo.value === fixture.expectations.tempo, `${fixture.id}: tempo mismatch.`);
    assert(
      classification.executionOwnership.value === fixture.expectations.ownership,
      `${fixture.id}: ownership mismatch.`,
    );
    assert(
      classification.relationshipKind.value === fixture.expectations.relationshipKind,
      `${fixture.id}: relationship mismatch.`,
    );
    assert(classification.readiness === fixture.expectations.readiness, `${fixture.id}: readiness mismatch.`);
    assert(
      classification.starterPlanSafe === fixture.expectations.starterPlanSafe,
      `${fixture.id}: starter-plan safety mismatch.`,
    );
    assert(
      clarification.questions.length === fixture.expectations.clarificationQuestionCount,
      `${fixture.id}: clarification question count mismatch.`,
    );
    assert(clarification.questions.length <= 3, `${fixture.id}: clarification generator asked too many questions.`);
    assert(classification.draft.mode === classification.mode.value, `${fixture.id}: draft mode mismatch.`);
    assert(classification.draft.timing.tempo === classification.tempo.value, `${fixture.id}: draft tempo mismatch.`);
    assert(
      classification.draft.actor.ownership === classification.executionOwnership.value,
      `${fixture.id}: draft ownership mismatch.`,
    );
  }

  const learning = classificationService.classify("I just want to understand how to do this");
  assert(learning.mode.value === GoalMode.Learning, "understand-how input should classify as learning.");
  assert(
    learning.readiness === "needs_clarification",
    "understand-how input should block planning when the subject is still vague.",
  );

  const flexibleRecurring = classificationService.classify("This is recurring but flexible");
  assert(
    flexibleRecurring.strictDeadlinesAppropriate.value === false,
    "flexible recurring work should not receive strict deadlines.",
  );

  const delegated = buildGoalDraftFromIntake("Help my daughter read better");
  assert(
    delegated.draft.mode === GoalMode.DelegatedSupport,
    "delegated support input should build a delegated-support draft.",
  );
  assert(
    delegated.draft.relationshipKind === GoalRelationshipKind.Support,
    "support phrasing should keep the relationship kind in support.",
  );
  assert(
    delegated.draft.actor.ownership === ExecutionOwnership.Child,
    "child-support input should assign the child as executor.",
  );
  assert(
    delegated.draft.actor.displayName !== "You",
    "delegated drafts should avoid self-execution display names.",
  );

  const noDeadlinePreference = buildGoalDraftFromIntake("I don't want deadlines");
  assert(
    noDeadlinePreference.classification.tempo.value === GoalTempo.Untimed,
    "deadline-averse input should stay untimed.",
  );
  assert(
    noDeadlinePreference.classification.readiness === "needs_clarification",
    "deadline preference without a goal subject should require clarification.",
  );

  const clarification = clarificationGenerator.generate(
    classificationService.classify("Launch my business"),
  );
  assert(
    clarification.readiness === "can_plan_with_defaults",
    "broad project inputs should allow starter plans with defaults.",
  );
  assert(
    clarification.questions.every((question) => !/deadline/i.test(question.prompt)),
    "clarification should not force deadline questions onto untimed starter drafts.",
  );
}

runGoalEngineIntakeTests();
