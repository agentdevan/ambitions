import Foundation

struct TodayLens: Equatable, SurfaceLens {
    static let contract = SurfaceLensContract(
        surface: .today,
        surfaceTitle: "Today",
        primaryObjectTitle: "Reality Meridian",
        primaryActionTitle: "Start here",
        runtimeInputs: [
            "current day rail",
            "recommended step",
            "fixed points",
            "protected work",
            "proof receipts",
            "recovery state"
        ],
        firstViewportContract: "Reality Meridian owns one Start here object, one primary action, and supporting proof context without flattening the day into generic work rows.",
        accessibilityContract: [
            "VoiceOver names Reality Meridian before Start here and proof context.",
            "Dynamic Type keeps Start here ahead of supporting rows.",
            "Reduce Motion keeps the current-time relationship static."
        ],
        trustInspectionRequirements: ["source", "proof", "receipt", "privacy"],
        failureStateRequirements: ["empty day", "blocked step", "waiting state", "source unavailable", "recovery fallback"]
    )

    let generatedAt: Date
    let stageScene: TodayStageScene

    init(experience: TodayExperience, generatedAt: Date) {
        self.generatedAt = generatedAt
        self.stageScene = TodayStageScene(execution: experience.execution, generatedAt: generatedAt)
    }

    init(experience: TodayExperience, clock: any AmbitionsClock) {
        self.init(experience: experience, generatedAt: clock.now)
    }

    init(execution: TodayExecutionViewState, generatedAt: Date) {
        self.generatedAt = generatedAt
        self.stageScene = TodayStageScene(execution: execution, generatedAt: generatedAt)
    }

    init(execution: TodayExecutionViewState, clock: any AmbitionsClock) {
        self.init(execution: execution, generatedAt: clock.now)
    }

    static func project(_ lens: TodayLens) -> SurfaceLensReport {
        makeReport(from: lens.stageScene)
    }

    static func project(execution: TodayExecutionViewState, generatedAt: Date) -> SurfaceLensReport {
        makeReport(from: TodayStageScene(execution: execution, generatedAt: generatedAt))
    }

    static func project(execution: TodayExecutionViewState, clock: any AmbitionsClock) -> SurfaceLensReport {
        project(execution: execution, generatedAt: clock.now)
    }

    private static func makeReport(from scene: TodayStageScene) -> SurfaceLensReport {
        SurfaceLensReport(
            contract: contract,
            primaryObjectSummary: scene.meridian.primaryObjectTitle,
            primaryActionSummary: scene.primaryActionTitle ?? "Start here is calm when no step is required.",
            visibleStateSummary: scene.startHere?.title ?? scene.meridian.noStepSummary ?? "Reality Meridian has no required step right now.",
            accessibilitySummary: scene.meridian.voiceOverOrder.joined(separator: " -> "),
            trustSummary: [scene.startHere?.sourceRecordLabel, scene.startHere?.receiptLabel]
                .compactMap { $0 }
                .joined(separator: " / "),
            failureStateSummary: scene.showsBlockedOrWaitingState ? "Blocked or waiting state is visible." : "Recovery fallback remains available."
        )
    }

    static func recomputeAfterTimeMutation(
        mutationID: String,
        actionKind: TimeMutationActionKind,
        before: LifeShapeProjection,
        after: LifeShapeProjection,
        affectedBucketIDs: [String]
    ) -> TodayTimeCouplingRecompute {
        let beforeRecommendation = startHereCandidate(in: before)
        let afterRecommendation = startHereCandidate(in: after)
        let beforeAvoided = avoidedBucketIDs(in: before)
        let afterAvoided = avoidedBucketIDs(in: after)

        return TodayTimeCouplingRecompute(
            causeMutationID: mutationID,
            actionKind: actionKind,
            beforeStartHereBucketID: beforeRecommendation?.bucketID,
            afterStartHereBucketID: afterRecommendation?.bucketID,
            beforeStartHereStepID: beforeRecommendation?.stepID,
            afterStartHereStepID: afterRecommendation?.stepID,
            beforeAvoidedBucketIDs: beforeAvoided,
            afterAvoidedBucketIDs: afterAvoided,
            affectedBucketIDs: Array(Set(affectedBucketIDs.filter { $0.isEmpty == false })).sorted(),
            proofLabel: "Today recompute caused by \(mutationID)",
            summary: actionKind.todaySummary
        )
    }

    private static func startHereCandidate(in projection: LifeShapeProjection) -> (bucketID: String, stepID: String?)? {
        projection.todayBuckets.first { bucket in
            bucket.layer == .open && bucket.reading.kind == .open && bucket.recommendedStepID != nil
        }.map { ($0.id, $0.recommendedStepID) } ??
            projection.todayBuckets.first { bucket in
                bucket.layer == .open && bucket.reading.kind == .open && bucket.primaryAction != nil
            }.map { ($0.id, $0.recommendedStepID) }
    }

    private static func avoidedBucketIDs(in projection: LifeShapeProjection) -> [String] {
        projection.todayBuckets
            .filter { bucket in
                bucket.layer != .open || bucket.reading.kind == .unavailable || bucket.protectedBoundary != nil
            }
            .map(\.id)
            .sorted()
    }
}
