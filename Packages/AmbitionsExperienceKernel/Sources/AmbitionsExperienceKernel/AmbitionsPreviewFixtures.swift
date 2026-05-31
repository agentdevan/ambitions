import Foundation

public enum AmbitionsPreviewFixtures {
    public static let normalTodayInput = AmbitionsRuntimeSnapshotInput(
        surface: .today,
        hardContext: .open,
        availability: .free,
        cognitiveContext: .neutral,
        availableMinutes: 52,
        recommendedMinutes: 25,
        protectedMinutesAhead: 0,
        unclosedStepCount: 0,
        proofCount: 3,
        sourceAgeMinutes: 24,
        sourceQuality: .directUserCommitment,
        goalPull: 0.72,
        recoveryNeed: 0.10,
        privacyBoundaryActive: true
    )

    public static let recoveryTodayInput = AmbitionsRuntimeSnapshotInput(
        surface: .today,
        hardContext: .open,
        availability: .constrained,
        cognitiveContext: .recovery,
        availableMinutes: 18,
        recommendedMinutes: 30,
        protectedMinutesAhead: 20,
        unclosedStepCount: 3,
        proofCount: 1,
        sourceAgeMinutes: 210,
        sourceQuality: .recentClosure,
        goalPull: 0.48,
        recoveryNeed: 0.78,
        privacyBoundaryActive: true
    )

    public static let protectedTodayInput = AmbitionsRuntimeSnapshotInput(
        surface: .today,
        hardContext: .protected,
        availability: .unavailable,
        cognitiveContext: .neutral,
        availableMinutes: 0,
        recommendedMinutes: 25,
        protectedMinutesAhead: 90,
        unclosedStepCount: 1,
        proofCount: 2,
        sourceAgeMinutes: 42,
        sourceQuality: .calendarEvent,
        goalPull: 0.30,
        recoveryNeed: 0.20,
        privacyBoundaryActive: true
    )

    public static let sampleReceipts: [AmbitionsProofReceipt] = [
        .init(title: "Accepted duration", sourceQuality: .acceptedSchedule, summary: "Duration was user accepted."),
        .init(title: "Goal thread", sourceQuality: .directUserCommitment, summary: "Step is linked to an active goal."),
        .init(title: "Time fit", sourceQuality: .calendarEvent, summary: "Current free time supports the step.")
    ]

    public static let sampleNodes: [MeridianNode] = [
        .init(title: "Closed morning setup", detail: "Completed", state: .closed, isCurrent: false),
        .init(title: "Recommended step", detail: "Fits now", state: .now, isCurrent: true),
        .init(title: "Protected block", detail: "Later", state: .protected, isCurrent: false)
    ]
}
