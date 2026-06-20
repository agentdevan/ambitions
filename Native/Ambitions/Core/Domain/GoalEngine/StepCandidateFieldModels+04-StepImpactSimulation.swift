import Foundation

extension StepImpactSimulation {
    static func make(
        goalID: String?,
        kind: StepCandidateKind,
        sourceStepID: String,
        sourceCandidateID: String?,
        candidateID: String,
        generatedAt: String? = nil,
        deadlineTargetDate: String?,
        estimatedMinutes: Int,
        goalContribution: Double,
        deadlineContribution: Double,
        futurePressureImpact: Double,
        opportunityCost: Double,
        openCapacityWindowCount: Int,
        protectedCapacityWindowCount: Int,
        sourceStepIsOptional: Bool,
        sourceStepIsExecutable: Bool,
        rejectionHistoryCount: Int,
        approvalRequired: Bool,
        validity: CandidateValidity
    ) -> StepImpactSimulation {
        let deadlineDaysRemaining = deadlineTargetDate.flatMap { deadlineDateString -> Int? in
            guard
                let deadlineDate = DomainTimestamp.date(from: deadlineDateString),
                let generatedAt,
                let generatedAtDate = DomainTimestamp.date(from: generatedAt)
            else {
                return nil
            }
            return deadlineDays(from: generatedAtDate, to: deadlineDate)
        }
        let protectedTimeThreat = Self.protectedTimeThreat(
            sourceStepIsOptional: sourceStepIsOptional,
            sourceStepIsExecutable: sourceStepIsExecutable,
            openCapacityWindowCount: openCapacityWindowCount,
            protectedCapacityWindowCount: protectedCapacityWindowCount,
            estimatedMinutes: estimatedMinutes,
            validity: validity
        )
        let requiresDeadlineReview = Self.requiresDeadlineReview(
            deadlineDaysRemaining: deadlineDaysRemaining,
            estimatedMinutes: estimatedMinutes,
            deadlineContribution: deadlineContribution,
            futurePressureImpact: futurePressureImpact,
            protectedTimeThreat: protectedTimeThreat,
            sourceStepIsExecutable: sourceStepIsExecutable
        )
        let requiresScopeReview = Self.requiresScopeReview(
            kind: kind,
            goalContribution: goalContribution,
            opportunityCost: opportunityCost,
            rejectionHistoryCount: rejectionHistoryCount,
            sourceStepIsOptional: sourceStepIsOptional,
            approvalRequired: approvalRequired,
            validity: validity
        )
        let feasibilityBand = Self.feasibilityBand(
            sourceStepIsExecutable: sourceStepIsExecutable,
            deadlineDaysRemaining: deadlineDaysRemaining,
            estimatedMinutes: estimatedMinutes,
            goalContribution: goalContribution,
            deadlineContribution: deadlineContribution,
            futurePressureImpact: futurePressureImpact,
            opportunityCost: opportunityCost,
            openCapacityWindowCount: openCapacityWindowCount,
            protectedCapacityWindowCount: protectedCapacityWindowCount,
            rejectionHistoryCount: rejectionHistoryCount,
            protectedTimeThreat: protectedTimeThreat,
            requiresDeadlineReview: requiresDeadlineReview,
            requiresScopeReview: requiresScopeReview
        )
        let deadlinePressureDelta = Self.deadlinePressureDelta(
            kind: kind,
            feasibilityBand: feasibilityBand,
            sourceStepIsExecutable: sourceStepIsExecutable,
            protectedTimeThreat: protectedTimeThreat,
            requiresDeadlineReview: requiresDeadlineReview,
            requiresScopeReview: requiresScopeReview,
            futurePressureImpact: futurePressureImpact,
            deadlineContribution: deadlineContribution,
            estimatedMinutes: estimatedMinutes
        )

        let onTrackSummary: String
        if protectedTimeThreat {
            onTrackSummary = "This threatens protected time."
        } else if feasibilityBand == .tightButPossible {
            onTrackSummary = "This keeps you on track, but it is tight."
        } else if feasibilityBand == .comfortablyOnTrack || feasibilityBand == .onTrack {
            onTrackSummary = "This keeps you on track."
        } else if feasibilityBand == .unrealisticWithoutChangingScopeTimeCapacity {
            onTrackSummary = "This makes the deadline tighter."
        } else {
            onTrackSummary = "This likely delays the goal."
        }

        let delaySummary: String
        if deadlinePressureDelta == .delayed || feasibilityBand == .atRisk || feasibilityBand == .unrealisticWithoutChangingScopeTimeCapacity {
            delaySummary = "This likely delays the goal."
        } else {
            delaySummary = "This does not visibly delay the goal."
        }

        let compressionSummary: String
        if deadlinePressureDelta == .compressed {
            compressionSummary = "This makes the deadline tighter."
        } else {
            compressionSummary = "This does not materially compress the timeline."
        }

        let recoverySummary: String
        if kind == .recoverySafe || sourceStepIsOptional || futurePressureImpact >= 0.72 {
            recoverySummary = protectedTimeThreat ? "This protects recovery, but not protected time." : "This protects recovery time."
        } else {
            recoverySummary = "This does not materially change recovery pressure."
        }

        let planRiskSummary: String
        switch deadlinePressureDelta {
        case .preserved:
            planRiskSummary = feasibilityBand == .comfortablyOnTrack ? "This keeps you on track." : onTrackSummary
        case .compressed:
            planRiskSummary = "This makes the deadline tighter."
        case .delayed:
            planRiskSummary = "This likely delays the goal."
        case .threatensProtectedTime:
            planRiskSummary = "This threatens protected time."
        case .requiresDeadlineReview:
            planRiskSummary = "This needs deadline review."
        case .requiresScopeReview:
            planRiskSummary = "This needs scope review."
        case .impossible:
            planRiskSummary = "This is impossible under current constraints."
        }

        let planRisk = PlanRiskProjection(
            feasibilityBand: feasibilityBand,
            deadlinePressureDelta: deadlinePressureDelta,
            threatensProtectedTime: protectedTimeThreat,
            requiresDeadlineReview: requiresDeadlineReview,
            requiresScopeReview: requiresScopeReview,
            isImpossible: feasibilityBand == .impossibleUnderCurrentConstraints,
            summary: planRiskSummary
        )
        let goalTimeline = GoalTimelineSimulation(
            deadlineTargetDate: deadlineTargetDate,
            deadlineDaysRemaining: deadlineDaysRemaining,
            estimatedMinutes: estimatedMinutes,
            goalContribution: goalContribution,
            deadlineContribution: deadlineContribution,
            futurePressureImpact: futurePressureImpact,
            opportunityCost: opportunityCost,
            openCapacityWindowCount: openCapacityWindowCount,
            protectedCapacityWindowCount: protectedCapacityWindowCount,
            sourceStepIsOptional: sourceStepIsOptional,
            sourceStepIsExecutable: sourceStepIsExecutable,
            rejectionHistoryCount: rejectionHistoryCount,
            planRisk: planRisk,
            onTrack: OnTrackProjection(
                isOnTrack: feasibilityBand == .comfortablyOnTrack || feasibilityBand == .onTrack || feasibilityBand == .tightButPossible,
                summary: onTrackSummary
            ),
            delay: DelayProjection(
                isDelayed: deadlinePressureDelta == .delayed || feasibilityBand == .atRisk || feasibilityBand == .unrealisticWithoutChangingScopeTimeCapacity || feasibilityBand == .impossibleUnderCurrentConstraints,
                summary: delaySummary,
                estimatedDelayDays: Self.estimatedDelayDays(
                    deadlineDaysRemaining: deadlineDaysRemaining,
                    feasibilityBand: feasibilityBand,
                    deadlinePressureDelta: deadlinePressureDelta
                )
            ),
            compression: CompressionProjection(
                isCompressed: deadlinePressureDelta == .compressed,
                summary: compressionSummary,
                estimatedMinutesSaved: Self.estimatedMinutesSaved(
                    kind: kind,
                    estimatedMinutes: estimatedMinutes,
                    deadlinePressureDelta: deadlinePressureDelta
                )
            ),
            recovery: RecoveryProjection(
                isRecoverySafe: kind == .recoverySafe || sourceStepIsOptional,
                summary: recoverySummary,
                protectsProtectedTime: protectedTimeThreat == false
            ),
            summary: planRiskSummary
        )

        let summaryKindLabel = kind == .lighter ? "lighter" : kind.semanticLabel
        return StepImpactSimulation(
            goalTimeline: goalTimeline,
            kindRawValue: kind.rawValue,
            sourceStepID: sourceStepID,
            candidateID: candidateID,
            sourceCandidateID: sourceCandidateID,
            summary: "\(summaryKindLabel): \(planRiskSummary)"
        )
    }


    static func protectedTimeThreat(
        sourceStepIsOptional: Bool,
        sourceStepIsExecutable: Bool,
        openCapacityWindowCount: Int,
        protectedCapacityWindowCount: Int,
        estimatedMinutes: Int,
        validity: CandidateValidity
    ) -> Bool {
        guard sourceStepIsExecutable, validity != .blocked else { return false }
        guard protectedCapacityWindowCount > 0 else { return false }
        if openCapacityWindowCount == 0 {
            return estimatedMinutes > 0 && sourceStepIsOptional == false
        }
        return openCapacityWindowCount <= protectedCapacityWindowCount && estimatedMinutes > 20 && sourceStepIsOptional == false
    }


    static func requiresDeadlineReview(
        deadlineDaysRemaining: Int?,
        estimatedMinutes: Int,
        deadlineContribution: Double,
        futurePressureImpact: Double,
        protectedTimeThreat: Bool,
        sourceStepIsExecutable: Bool
    ) -> Bool {
        guard sourceStepIsExecutable, protectedTimeThreat == false else { return false }
        guard let deadlineDaysRemaining else { return estimatedMinutes >= 25 && deadlineContribution < 0.7 && futurePressureImpact < 0.8 }
        if deadlineDaysRemaining <= 1 {
            return true
        }
        if deadlineDaysRemaining <= 3 {
            return estimatedMinutes >= 15 || deadlineContribution < 0.75 || futurePressureImpact < 0.72
        }
        return false
    }


    static func requiresScopeReview(
        kind: StepCandidateKind,
        goalContribution: Double,
        opportunityCost: Double,
        rejectionHistoryCount: Int,
        sourceStepIsOptional: Bool,
        approvalRequired: Bool,
        validity: CandidateValidity
    ) -> Bool {
        if validity == .blocked {
            return true
        }
        if kind == .fallback {
            return true
        }
        if approvalRequired {
            return sourceStepIsOptional || goalContribution < 0.8
        }
        if rejectionHistoryCount > 0 && goalContribution < 0.85 {
            return true
        }
        return sourceStepIsOptional && (goalContribution < 0.9 || opportunityCost > 0.55)
    }
}
