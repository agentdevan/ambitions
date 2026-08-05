export type Health = "onTrack" | "atRisk" | "offTrack";

export interface HealthInput {
  now: Date;
  lastSyncAt: Date;
  oldestBlockerBusinessDays: number;
  oldestReviewBusinessDays: number;
  wipViolation: boolean;
  proofFailed: boolean;
}

export function projectHealth(input: HealthInput): Health {
  const staleMinutes =
    (input.now.getTime() - input.lastSyncAt.getTime()) / 60_000;
  if (
    input.proofFailed ||
    input.oldestBlockerBusinessDays > 7 ||
    staleMinutes > 60
  )
    return "offTrack";
  if (
    input.wipViolation ||
    input.oldestBlockerBusinessDays > 3 ||
    input.oldestReviewBusinessDays > 2 ||
    staleMinutes > 15
  )
    return "atRisk";
  return "onTrack";
}
