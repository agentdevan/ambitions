import {
  MonthlyCarryoverStance,
  MonthlyEmphasis,
  MonthlyPosture,
  MonthlyPressureLevel,
  MonthlyReviewState,
  WeeklyCarryoverPosture,
  WeeklyEmphasis,
  WeeklyIntensity,
} from "../../domain/models";

export interface MonthlyWeeklyDefaults {
  weeklyEmphasis: WeeklyEmphasis;
  targetWeekIntensity: WeeklyIntensity;
  carryoverPosture: WeeklyCarryoverPosture;
}

export function deriveWeeklyDefaultsFromMonthlyStrategy(
  state: MonthlyReviewState | null | undefined,
): MonthlyWeeklyDefaults | null {
  if (!state) {
    return null;
  }

  return {
    weeklyEmphasis: mapMonthlyEmphasis(state.monthlyEmphasis, state.monthPosture),
    targetWeekIntensity: mapMonthlyPressure(state.pressureLevel, state.monthPosture),
    carryoverPosture: mapMonthlyCarryover(state.carryoverStance, state.monthPosture),
  };
}

function mapMonthlyEmphasis(
  emphasis: MonthlyEmphasis | null,
  posture: MonthlyPosture | null,
) {
  switch (emphasis) {
    case MonthlyEmphasis.ProtectEssentials:
      return WeeklyEmphasis.ProtectEssentials;
    case MonthlyEmphasis.DeepenPriorityArea:
      return WeeklyEmphasis.PushMeaningfulArea;
    case MonthlyEmphasis.RebalanceNeglectedAreas:
      return WeeklyEmphasis.SteadyProgress;
    default:
      return posture === MonthlyPosture.PushOutput
        ? WeeklyEmphasis.PushMeaningfulArea
        : WeeklyEmphasis.ProtectEssentials;
  }
}

function mapMonthlyPressure(
  pressure: MonthlyPressureLevel | null,
  posture: MonthlyPosture | null,
) {
  switch (pressure) {
    case MonthlyPressureLevel.Lighter:
      return WeeklyIntensity.Lighter;
    case MonthlyPressureLevel.Fuller:
      return WeeklyIntensity.Fuller;
    case MonthlyPressureLevel.Balanced:
      return WeeklyIntensity.Balanced;
    default:
      if (posture === MonthlyPosture.Stabilize) {
        return WeeklyIntensity.Lighter;
      }

      if (posture === MonthlyPosture.PushOutput) {
        return WeeklyIntensity.Fuller;
      }

      return WeeklyIntensity.Balanced;
  }
}

function mapMonthlyCarryover(
  carryoverStance: MonthlyCarryoverStance | null,
  posture: MonthlyPosture | null,
) {
  switch (carryoverStance) {
    case MonthlyCarryoverStance.PruneAggressively:
      return WeeklyCarryoverPosture.EssentialsOnly;
    case MonthlyCarryoverStance.ReviewBeforeCarrying:
      return WeeklyCarryoverPosture.ReviewFirst;
    case MonthlyCarryoverStance.TolerateMoreCarryover:
      return WeeklyCarryoverPosture.Aggressive;
    default:
      return posture === MonthlyPosture.Stabilize
        ? WeeklyCarryoverPosture.ReviewFirst
        : WeeklyCarryoverPosture.EssentialsOnly;
  }
}
