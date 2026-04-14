import { FeedbackAnalyzer } from "./FeedbackAnalyzer";
import { AdaptationService } from "./AdaptationService";
import {
  feedbackFixtureDelegatedToneInput,
  feedbackFixtureExplorationRigidInput,
  feedbackFixtureLearningConfusionInput,
  feedbackFixtureRecoveryGentleInput,
  feedbackFixtureTimedAchievementInput,
  feedbackFixtureUntimedTimingPressureInput,
} from "./goalEngineFeedbackFixtures";

function assert(condition: unknown, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}

export function runGoalEngineFeedbackTests(): void {
  const analyzer = new FeedbackAnalyzer();
  const adaptation = new AdaptationService(analyzer);

  const avoidance = adaptation.recommendPlanAdjustment(feedbackFixtureTimedAchievementInput);
  assert(
    avoidance.recommendation.kind === "shrink_step",
    "repeated avoidance on an achievement goal should shrink the step.",
  );

  const confusion = adaptation.recommendPlanAdjustment(feedbackFixtureLearningConfusionInput);
  assert(
    confusion.recommendation.kind === "revise_step",
    "repeated confusion on a learning goal should revise the step.",
  );
  assert(
    confusion.recommendation.kind !== "revise_step" ||
      confusion.recommendation.evidenceAdjustments.length > 0,
    "learning confusion revisions should strengthen evidence expectations.",
  );

  const untimedTiming = adaptation.recommendPlanAdjustment(feedbackFixtureUntimedTimingPressureInput);
  assert(
    untimedTiming.recommendation.kind === "relax_timing",
    "delayed feedback on an untimed goal should relax timing instead of adding urgency.",
  );
  assert(
    untimedTiming.recommendation.kind !== "relax_timing" ||
      untimedTiming.recommendation.removeDeadline,
    "untimed timing adjustments should remove deadline pressure.",
  );

  const tone = adaptation.recommendPlanAdjustment(feedbackFixtureDelegatedToneInput);
  assert(
    tone.recommendation.kind === "adjust_plan_tone",
    "delegated child/support goals should correct punitive tone drift.",
  );

  const exploration = adaptation.recommendPlanAdjustment(feedbackFixtureExplorationRigidInput);
  assert(
    exploration.recommendation.kind === "relax_timing",
    "exploration goals that get rigid should reduce timing pressure.",
  );

  const recovery = adaptation.recommendPlanAdjustment(feedbackFixtureRecoveryGentleInput);
  assert(
    recovery.recommendation.kind === "suggest_micro_step",
    "recovery friction should produce a gentler micro-step suggestion.",
  );

  const learningSignals = analyzer.analyze(feedbackFixtureLearningConfusionInput);
  assert(
    learningSignals.repeatedConfusion,
    "analyzer should detect repeated confusion on the learning fixture.",
  );
  assert(
    learningSignals.signals.confidenceTrend !== "improving",
    "confusion should not register as an improving confidence trend.",
  );
}

runGoalEngineFeedbackTests();
