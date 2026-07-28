import Foundation

enum RuntimeGoalIntelligenceError: Error, Equatable {
    case notFound
    case notActionable
}

struct RuntimeGoalIntelligenceRequest: Sendable, Equatable {
    let target: GoalRouteTarget
    let primaryStepID: String?
    let includeWhyNow: Bool

    init(
        target: GoalRouteTarget,
        primaryStepID: String? = nil,
        includeWhyNow: Bool = false
    ) {
        self.target = target
        self.primaryStepID = primaryStepID
        self.includeWhyNow = includeWhyNow
    }
}

struct RuntimeGoalIntelligenceContext: Sendable {
    let goalID: String?
    let draftID: String?
    let primaryStepID: String?
    let metadata: GoalOrchestrationMetadata
    let applicableSignals: GoalTeachingApplicableSet?
    let explainability: GoalExplainabilityState
    let whyNow: WhyNowExplanationMetadata?
    let quarantine: RuntimeIntelligenceQuarantineAssessment
}

enum RuntimeIntelligenceQuarantineIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case missingSourceAudit = "missing_source_audit"
    case staleOrUnavailableFreshness = "stale_or_unavailable_freshness"
    case lowConfidence = "low_confidence"
    case unresolvedContradiction = "unresolved_contradiction"
    case missingCorrectionControl = "missing_correction_control"
    case remoteIntelligenceBackend = "remote_intelligence_backend"
}

struct RuntimeIntelligenceQuarantineAssessment: Codable, Sendable, Equatable, Hashable {
    let issues: [RuntimeIntelligenceQuarantineIssue]
    let canDriveRecommendation: Bool
    let disclosureSummary: String

    static let clear = RuntimeIntelligenceQuarantineAssessment(
        issues: [],
        canDriveRecommendation: true,
        disclosureSummary: "Runtime intelligence is local, source-audited, and reviewable."
    )

    init(
        issues: [RuntimeIntelligenceQuarantineIssue],
        canDriveRecommendation: Bool? = nil,
        disclosureSummary: String? = nil
    ) {
        let stableIssues = Self.stableUnique(issues)
        self.issues = stableIssues
        self.canDriveRecommendation = canDriveRecommendation ?? stableIssues.isEmpty
        self.disclosureSummary = disclosureSummary ?? (
            stableIssues.isEmpty
                ? "Runtime intelligence is local, source-audited, and reviewable."
                : "Runtime intelligence is quarantined for review before it can drive recommendations."
        )
    }

    var isQuarantined: Bool {
        issues.isEmpty == false || canDriveRecommendation == false
    }

    private static func stableUnique<T: Hashable>(_ values: [T]) -> [T] {
        var seen: Set<T> = []
        var result: [T] = []
        for value in values where seen.insert(value).inserted {
            result.append(value)
        }
        return result
    }
}

struct RuntimeIntelligenceQuarantinePolicy: Sendable {
    func assess(
        explainability: GoalExplainabilityState,
        capabilities: AmbitionsRuntimeCapabilities = .currentLocalRuntime
    ) -> RuntimeIntelligenceQuarantineAssessment {
        var issues: [RuntimeIntelligenceQuarantineIssue] = []

        let freshnessBlocksCurrentUse = [
            GoalFreshnessPosture.stale,
            .expired,
            .blockedMissingEvidence,
            .providerUnavailable
        ].contains(explainability.freshness.posture)

        if explainability.sourceAudit.rows.isEmpty && freshnessBlocksCurrentUse {
            issues.append(.missingSourceAudit)
        }
        if freshnessBlocksCurrentUse {
            issues.append(.staleOrUnavailableFreshness)
        }
        if explainability.confidence.understandingConfidence == .low || explainability.confidence.pathConfidence == .low {
            issues.append(.lowConfidence)
        }
        if explainability.contradictions.isEmpty == false {
            issues.append(.unresolvedContradiction)
        }
        if explainability.correctionControls.isEmpty {
            issues.append(.missingCorrectionControl)
        }
        if capabilities.hasRemoteIntelligenceBackend {
            issues.append(.remoteIntelligenceBackend)
        }

        return RuntimeIntelligenceQuarantineAssessment(issues: issues)
    }
}

protocol RuntimeGoalIntelligenceServicing: Sendable {
    func loadContext(_ request: RuntimeGoalIntelligenceRequest, now: Date) async throws -> RuntimeGoalIntelligenceContext?
    func loadContexts(_ requests: [RuntimeGoalIntelligenceRequest], now: Date) async throws -> [RuntimeGoalIntelligenceContext?]
    func proposeCorrection(
        target: GoalRouteTarget,
        control: GoalCorrectionControlState,
        now: Date
    ) async throws -> GoalTeachingCorrectionProposal
}

struct RepositoryBackedRuntimeGoalIntelligenceService: RuntimeGoalIntelligenceServicing {
    let repositories: AppRepositories
    let explainabilityProjector: any GoalExplainabilityProjecting
    let teachingReader: any GoalTeachingSignalReading
    let teachingProposalService: any GoalTeachingSignalProposing
    let learningService: LearningAnticipationService
    let quarantinePolicy: RuntimeIntelligenceQuarantinePolicy

    init(
        repositories: AppRepositories,
        explainabilityProjector: any GoalExplainabilityProjecting = DefaultGoalExplainabilityProjector(),
        teachingReader: (any GoalTeachingSignalReading)? = nil,
        teachingProposalService: (any GoalTeachingSignalProposing)? = nil,
        learningService: LearningAnticipationService = LearningAnticipationService(),
        quarantinePolicy: RuntimeIntelligenceQuarantinePolicy = RuntimeIntelligenceQuarantinePolicy()
    ) {
        let sharedTeachingService = DefaultGoalTeachingSignalService(repository: repositories.teaching)
        self.repositories = repositories
        self.explainabilityProjector = explainabilityProjector
        self.teachingReader = teachingReader ?? sharedTeachingService
        self.teachingProposalService = teachingProposalService ?? sharedTeachingService
        self.learningService = learningService
        self.quarantinePolicy = quarantinePolicy
    }

    func loadContext(_ request: RuntimeGoalIntelligenceRequest, now: Date) async throws -> RuntimeGoalIntelligenceContext? {
        guard let resolved = try await resolve(target: request.target) else {
            return nil
        }
        guard let metadata = resolved.draft?.metadata else {
            return nil
        }

        let goalID = resolved.goal?.id ?? resolved.draft?.plannedGoalID ?? metadata.context.goalID
        let whyNow = request.includeWhyNow
            ? buildWhyNow(goal: resolved.goal, stepID: request.primaryStepID, evidence: resolved.evidence, feedback: resolved.feedback, now: now)
            : nil
        let applicableSignals: GoalTeachingApplicableSet?
        if let goalID {
            applicableSignals = try await teachingReader.applicableSignals(goalID: goalID, metadata: metadata)
        } else {
            applicableSignals = nil
        }
        let explainability = explainabilityProjector.makeState(
            metadata: metadata,
            applicableSignals: applicableSignals,
            primaryStepID: request.primaryStepID,
            whyNow: whyNow
        )
        let quarantine = quarantinePolicy.assess(explainability: explainability)

        return RuntimeGoalIntelligenceContext(
            goalID: goalID,
            draftID: resolved.draft?.id,
            primaryStepID: request.primaryStepID,
            metadata: metadata,
            applicableSignals: applicableSignals,
            explainability: explainability,
            whyNow: whyNow,
            quarantine: quarantine
        )
    }

    func loadContexts(_ requests: [RuntimeGoalIntelligenceRequest], now: Date) async throws -> [RuntimeGoalIntelligenceContext?] {
        var contexts: [RuntimeGoalIntelligenceContext?] = []
        contexts.reserveCapacity(requests.count)

        for request in requests {
            contexts.append(try await loadContext(request, now: now))
        }

        return contexts
    }

    func proposeCorrection(
        target: GoalRouteTarget,
        control: GoalCorrectionControlState,
        now: Date
    ) async throws -> GoalTeachingCorrectionProposal {
        guard let context = try await loadContext(
            RuntimeGoalIntelligenceRequest(
                target: target,
                primaryStepID: nil,
                includeWhyNow: false
            ),
            now: now
        ) else {
            throw RuntimeGoalIntelligenceError.notFound
        }
        guard let goalID = context.goalID else {
            throw RuntimeGoalIntelligenceError.notActionable
        }

        return try teachingProposalService.propose(
            GoalTeachingCaptureRequest(
                goalID: goalID,
                capturedAt: DomainTimestamp.string(from: now),
                kind: control.teachingSignalKind,
                payload: control.payload,
                target: control.target,
                userNote: control.subtitle
            ),
            metadata: context.metadata
        )
    }
}

private extension RepositoryBackedRuntimeGoalIntelligenceService {
    struct ResolvedGoalContext {
        let goal: Goal?
        let draft: PersistedGoalDraft?
        let evidence: [ProgressEvidence]
        let feedback: [GoalFeedbackEvent]
    }

    func resolve(target: GoalRouteTarget) async throws -> ResolvedGoalContext? {
        let explicitDraft: PersistedGoalDraft?
        if let draftID = target.draftID {
            explicitDraft = try await repositories.drafts.draft(id: draftID)
        } else {
            explicitDraft = nil
        }

        let explicitGoal: Goal?
        if let goalID = target.goalID {
            explicitGoal = try await repositories.goals.goal(id: goalID)
        } else {
            explicitGoal = nil
        }

        let draft: PersistedGoalDraft?
        if let explicitDraft {
            draft = explicitDraft
        } else if let goalID = target.goalID {
            draft = try await repositories.drafts.listDrafts().first(where: { $0.plannedGoalID == goalID })
        } else {
            draft = nil
        }

        let resolvedGoalID = explicitGoal?.id ?? target.goalID ?? draft?.plannedGoalID
        let goal: Goal?
        if let explicitGoal {
            goal = explicitGoal
        } else if let resolvedGoalID {
            goal = try await repositories.goals.goal(id: resolvedGoalID)
        } else {
            goal = nil
        }
        guard goal != nil || draft != nil else {
            return nil
        }

        let evidence = try await repositories.evidence.listEvidence(goalID: resolvedGoalID)
        let feedback = try await repositories.feedback.listEvents(goalID: resolvedGoalID)
        return ResolvedGoalContext(goal: goal, draft: draft, evidence: evidence, feedback: feedback)
    }

    func buildWhyNow(
        goal: Goal?,
        stepID: String?,
        evidence: [ProgressEvidence],
        feedback: [GoalFeedbackEvent],
        now: Date
    ) -> WhyNowExplanationMetadata? {
        guard let goal, let stepID else { return nil }
        guard let step = goal.plan?.sections.flatMap(\.steps).first(where: { $0.id == stepID }) else {
            return nil
        }
        let snapshot = learningService.buildSnapshot(
            goals: [goal],
            evidence: evidence,
            feedback: feedback,
            now: now
        )
        return learningService.learnedStepInsight(
            goal: goal,
            step: step,
            snapshot: snapshot,
            now: now
        ).whyNow
    }
}
