import {
  ExecutionHistorySummary,
  RegressionSeverity,
  RegressionState,
} from "../../domain/models";

export function detectRegression(summary: ExecutionHistorySummary): RegressionState {
  const triggers = [];

  if (
    summary.recentWindowSize >= 6 &&
    summary.recentCompletionRate <= 0.5 &&
    summary.baselineCompletionRate - summary.recentCompletionRate >= 0.15
  ) {
    triggers.push({
      severity: "active" as RegressionSeverity,
      isRegressing: true,
      trigger: "miss_rate_spike" as const,
      metric: summary.recentCompletionRate,
      threshold: summary.baselineCompletionRate - 0.15,
      explanation:
        "Recent completion has dropped meaningfully below the baseline, so planning should get lighter.",
    });
  }

  if (summary.recoveryRelianceRate >= 0.28) {
    triggers.push({
      severity: "watch" as RegressionSeverity,
      isRegressing: true,
      trigger: "recovery_reliance" as const,
      metric: summary.recoveryRelianceRate,
      threshold: 0.28,
      explanation:
        "Recent execution is leaning on split or substitute recovery often enough to warrant more protection.",
    });
  }

  if (
    summary.recentWindowSize >= 6 &&
    summary.baselineCompletionRate - summary.recentCompletionRate >= 0.2
  ) {
    triggers.push({
      severity: "active" as RegressionSeverity,
      isRegressing: true,
      trigger: "completion_slide" as const,
      metric: summary.baselineCompletionRate - summary.recentCompletionRate,
      threshold: 0.2,
      explanation:
        "Completion consistency is sliding enough that ambition should yield to momentum preservation.",
    });
  }

  if (summary.overloadedDayRate >= 0.34) {
    triggers.push({
      severity: "watch" as RegressionSeverity,
      isRegressing: true,
      trigger: "overpacked_days" as const,
      metric: summary.overloadedDayRate,
      threshold: 0.34,
      explanation:
        "A notable share of recent days look overpacked, so the plan should keep more slack.",
    });
  }

  if (summary.missedStartCollapseRate >= 0.3) {
    triggers.push({
      severity: "watch" as RegressionSeverity,
      isRegressing: true,
      trigger: "missed_start_collapse" as const,
      metric: summary.missedStartCollapseRate,
      threshold: 0.3,
      explanation:
        "Missing the first planned start has been collapsing too many days, so early wins should be protected.",
    });
  }

  const severity: RegressionSeverity =
    triggers.filter((trigger) => trigger.severity === "active").length > 0 ||
    triggers.length >= 2
      ? "active"
      : triggers.length === 1
        ? "watch"
        : "none";

  return {
    severity,
    isRegressing: severity !== "none",
    triggers,
    explanation:
      severity === "active"
        ? "Recent execution has regressed enough that the system should return to more protective behavior."
        : severity === "watch"
          ? "Recent execution shows early regression signals, so planning should stay conservative."
          : "Recent execution does not currently require regression protection beyond the normal protective baseline.",
  };
}
