import Foundation

let ambitionsOSLivingDreamCapacityBridgeSchemaVersion =
    "ambitionsos_living_dream_capacity_bridge.native.v1"

enum AmbitionsOSLivingDreamCapacityBridgeReadiness: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case readyForTodayBridge = "ready_for_today_bridge"
    case needsPathReview = "needs_path_review"
    case needsCapacityReview = "needs_capacity_review"
    case needsSourceReview = "needs_source_review"
    case needsUserReview = "needs_user_review"
    case needsRecoveryReview = "needs_recovery_review"
    case blocked
}

enum AmbitionsOSLivingDreamCapacityBridgeIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case malformedBridge = "malformed_bridge"
    case pathPortfolioNotReady = "path_portfolio_not_ready"
    case missingPrimaryPath = "missing_primary_path"
    case missingCommitmentForCandidate = "missing_commitment_for_candidate"
    case unknownCandidateID = "unknown_candidate_id"
    case commitmentProjectionNotReady = "commitment_projection_not_ready"
    case overCapacityFantasySchedule = "over_capacity_fantasy_schedule"
    case tightCapacityNeedsReview = "tight_capacity_needs_review"
    case sourceReviewRequired = "source_review_required"
    case staleDeadlineSource = "stale_deadline_source"
    case protectedTimeViolation = "protected_time_violation"
    case privateProjectionRisk = "private_projection_risk"
    case recoveryBufferMissing = "recovery_buffer_missing"
    case silentRescheduleRisk = "silent_reschedule_risk"
    case platformCalendarImplementation = "platform_calendar_implementation"
    case activationForbidden = "activation_forbidden"
    case hiddenMutationRisk = "hidden_mutation_risk"
    case userDataServerBoundaryBroken = "user_data_server_boundary_broken"
    case runtimeBoundaryBroken = "runtime_boundary_broken"
}

struct AmbitionsOSLivingDreamPathCapacityBridge: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let candidateID: String
    let commitmentIDs: [String]
    let proofCommitmentIDs: [String]
    let reviewCommitmentIDs: [String]
    let recoveryCommitmentIDs: [String]
    let minimumCapacityBufferMinutes: Int
    let allowsActivation: Bool
    let mutatesCommitments: Bool
    let writesScheduleAutomatically: Bool
    let usesUserDataServer: Bool
    let runtimeBoundary: SourceAtlasRuntimeBoundary
    let schemaVersion: String

    init(
        id: String,
        candidateID: String,
        commitmentIDs: [String],
        proofCommitmentIDs: [String] = [],
        reviewCommitmentIDs: [String] = [],
        recoveryCommitmentIDs: [String] = [],
        minimumCapacityBufferMinutes: Int,
        allowsActivation: Bool = false,
        mutatesCommitments: Bool = false,
        writesScheduleAutomatically: Bool = false,
        usesUserDataServer: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        schemaVersion: String = ambitionsOSLivingDreamCapacityBridgeSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.candidateID = candidateID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.commitmentIDs = Self.orderedUnique(commitmentIDs)
        self.proofCommitmentIDs = Self.orderedUnique(proofCommitmentIDs)
        self.reviewCommitmentIDs = Self.orderedUnique(reviewCommitmentIDs)
        self.recoveryCommitmentIDs = Self.orderedUnique(recoveryCommitmentIDs)
        self.minimumCapacityBufferMinutes = minimumCapacityBufferMinutes
        self.allowsActivation = allowsActivation
        self.mutatesCommitments = mutatesCommitments
        self.writesScheduleAutomatically = writesScheduleAutomatically
        self.usesUserDataServer = usesUserDataServer
        self.runtimeBoundary = runtimeBoundary
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            candidateID.isEmpty == false &&
            commitmentIDs.isEmpty == false &&
            minimumCapacityBufferMinutes >= 0 &&
            schemaVersion == ambitionsOSLivingDreamCapacityBridgeSchemaVersion
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct AmbitionsOSLivingDreamCapacityBridge: Codable, Sendable, Equatable, Hashable {
    let id: String
    let pathPortfolio: AmbitionsOSLivingDreamPathPortfolio
    let commitmentProjection: AmbitionsOSCommitmentTimeProjection
    let pathBridges: [AmbitionsOSLivingDreamPathCapacityBridge]
    let allowsActivation: Bool
    let mutatesCommitments: Bool
    let usesUserDataServer: Bool
    let runtimeBoundary: SourceAtlasRuntimeBoundary
    let schemaVersion: String

    init(
        id: String,
        pathPortfolio: AmbitionsOSLivingDreamPathPortfolio,
        commitmentProjection: AmbitionsOSCommitmentTimeProjection,
        pathBridges: [AmbitionsOSLivingDreamPathCapacityBridge],
        allowsActivation: Bool = false,
        mutatesCommitments: Bool = false,
        usesUserDataServer: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        schemaVersion: String = ambitionsOSLivingDreamCapacityBridgeSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.pathPortfolio = pathPortfolio
        self.commitmentProjection = commitmentProjection
        self.pathBridges = pathBridges.sorted { $0.id < $1.id }
        self.allowsActivation = allowsActivation
        self.mutatesCommitments = mutatesCommitments
        self.usesUserDataServer = usesUserDataServer
        self.runtimeBoundary = runtimeBoundary
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            pathBridges.isEmpty == false &&
            schemaVersion == ambitionsOSLivingDreamCapacityBridgeSchemaVersion
    }
}

struct AmbitionsOSLivingDreamCapacityBridgeEvaluation: Codable, Sendable, Equatable, Hashable {
    let bridgeID: String
    let candidateIDs: [String]
    let commitmentIDsByCandidateID: [String: [String]]
    let requestedMinutes: Int
    let availableMinutes: Int
    let capacityFit: AmbitionsOSCapacityFit
    let issues: [AmbitionsOSLivingDreamCapacityBridgeIssue]

    var readiness: AmbitionsOSLivingDreamCapacityBridgeReadiness {
        if issues.contains(.runtimeBoundaryBroken) ||
            issues.contains(.userDataServerBoundaryBroken) ||
            issues.contains(.hiddenMutationRisk) ||
            issues.contains(.activationForbidden) ||
            issues.contains(.silentRescheduleRisk) ||
            issues.contains(.platformCalendarImplementation) ||
            issues.contains(.overCapacityFantasySchedule) {
            return .blocked
        }
        if issues.contains(.pathPortfolioNotReady) ||
            issues.contains(.missingPrimaryPath) ||
            issues.contains(.unknownCandidateID) ||
            issues.contains(.missingCommitmentForCandidate) {
            return .needsPathReview
        }
        if issues.contains(.sourceReviewRequired) ||
            issues.contains(.staleDeadlineSource) {
            return .needsSourceReview
        }
        if issues.contains(.protectedTimeViolation) ||
            issues.contains(.commitmentProjectionNotReady) ||
            issues.contains(.tightCapacityNeedsReview) {
            return .needsCapacityReview
        }
        if issues.contains(.privateProjectionRisk) {
            return .needsUserReview
        }
        if issues.contains(.recoveryBufferMissing) {
            return .needsRecoveryReview
        }
        return .readyForTodayBridge
    }
}

struct AmbitionsOSLivingDreamCapacityBridgeValidator: Sendable, Equatable, Hashable {
    func validate(
        bridge: AmbitionsOSLivingDreamCapacityBridge
    ) -> [AmbitionsOSLivingDreamCapacityBridgeIssue] {
        var issues: Set<AmbitionsOSLivingDreamCapacityBridgeIssue> = []
        let pathEvaluation = AmbitionsOSLivingDreamPathPortfolioValidator()
            .evaluate(portfolio: bridge.pathPortfolio)
        let commitmentIssues = AmbitionsOSCommitmentTimeValidator()
            .validate(bridge.commitmentProjection)

        validateBridgeShape(bridge, issues: &issues)
        validatePathPortfolio(bridge.pathPortfolio, pathEvaluation: pathEvaluation, issues: &issues)
        validateCommitments(bridge.commitmentProjection, commitmentIssues: commitmentIssues, issues: &issues)
        validateRuntime(bridge, issues: &issues)
        validatePathBridges(bridge, issues: &issues)

        return issues.sorted { $0.rawValue < $1.rawValue }
    }

    func evaluate(
        bridge: AmbitionsOSLivingDreamCapacityBridge
    ) -> AmbitionsOSLivingDreamCapacityBridgeEvaluation {
        AmbitionsOSLivingDreamCapacityBridgeEvaluation(
            bridgeID: bridge.id,
            candidateIDs: bridge.pathBridges.map(\.candidateID),
            commitmentIDsByCandidateID: Dictionary(
                uniqueKeysWithValues: bridge.pathBridges.map { ($0.candidateID, $0.commitmentIDs) }
            ),
            requestedMinutes: bridge.commitmentProjection.requestedMinutes,
            availableMinutes: bridge.commitmentProjection.availableMinutes,
            capacityFit: bridge.commitmentProjection.capacityFit,
            issues: validate(bridge: bridge)
        )
    }

    private func validateBridgeShape(
        _ bridge: AmbitionsOSLivingDreamCapacityBridge,
        issues: inout Set<AmbitionsOSLivingDreamCapacityBridgeIssue>
    ) {
        if bridge.schemaVersion != ambitionsOSLivingDreamCapacityBridgeSchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if bridge.isWellFormed == false {
            issues.insert(.malformedBridge)
        }
    }

    private func validatePathPortfolio(
        _ portfolio: AmbitionsOSLivingDreamPathPortfolio,
        pathEvaluation: AmbitionsOSLivingDreamPathPortfolioEvaluation,
        issues: inout Set<AmbitionsOSLivingDreamCapacityBridgeIssue>
    ) {
        if pathEvaluation.readiness != .readyForCapacityBridge {
            issues.insert(.pathPortfolioNotReady)
        }
        if portfolio.candidates.contains(where: { $0.kind == .primary }) == false {
            issues.insert(.missingPrimaryPath)
        }
    }

    private func validateCommitments(
        _ projection: AmbitionsOSCommitmentTimeProjection,
        commitmentIssues: [AmbitionsOSCommitmentTimeIssue],
        issues: inout Set<AmbitionsOSLivingDreamCapacityBridgeIssue>
    ) {
        if commitmentIssues.isEmpty == false {
            issues.insert(.commitmentProjectionNotReady)
        }
        if commitmentIssues.contains(.overCapacity) {
            issues.insert(.overCapacityFantasySchedule)
        }
        if projection.capacityFit == .tight {
            issues.insert(.tightCapacityNeedsReview)
        }
        if commitmentIssues.contains(.sourceReviewRequired) {
            issues.insert(.sourceReviewRequired)
        }
        if commitmentIssues.contains(.staleDeadlineSource) {
            issues.insert(.staleDeadlineSource)
        }
        if commitmentIssues.contains(.protectedTimeViolation) {
            issues.insert(.protectedTimeViolation)
        }
        if commitmentIssues.contains(.privateExternalProjectionRisk) {
            issues.insert(.privateProjectionRisk)
        }
        if commitmentIssues.contains(.silentRescheduleRisk) {
            issues.insert(.silentRescheduleRisk)
        }
        if commitmentIssues.contains(.platformCalendarImplementation) {
            issues.insert(.platformCalendarImplementation)
        }
        if commitmentIssues.contains(.runtimeStoreBehavior) {
            issues.insert(.runtimeBoundaryBroken)
        }
    }

    private func validateRuntime(
        _ bridge: AmbitionsOSLivingDreamCapacityBridge,
        issues: inout Set<AmbitionsOSLivingDreamCapacityBridgeIssue>
    ) {
        if bridge.allowsActivation || bridge.pathPortfolio.allowsActivation {
            issues.insert(.activationForbidden)
        }
        if bridge.mutatesCommitments || bridge.pathPortfolio.mutatesCommitments {
            issues.insert(.hiddenMutationRisk)
        }
        if bridge.usesUserDataServer || bridge.pathPortfolio.usesUserDataServer {
            issues.insert(.userDataServerBoundaryBroken)
        }
        if bridge.runtimeBoundary.isValueModelOnly == false {
            issues.insert(.runtimeBoundaryBroken)
        }
    }

    private func validatePathBridges(
        _ bridge: AmbitionsOSLivingDreamCapacityBridge,
        issues: inout Set<AmbitionsOSLivingDreamCapacityBridgeIssue>
    ) {
        let candidateIDs = Set(bridge.pathPortfolio.candidates.map(\.id))
        let commitmentIDs = Set(bridge.commitmentProjection.commitments.map(\.id))

        for pathBridge in bridge.pathBridges {
            if pathBridge.schemaVersion != ambitionsOSLivingDreamCapacityBridgeSchemaVersion {
                issues.insert(.unsupportedSchema)
            }
            if pathBridge.isWellFormed == false {
                issues.insert(.malformedBridge)
            }
            if candidateIDs.contains(pathBridge.candidateID) == false {
                issues.insert(.unknownCandidateID)
            }
            if pathBridge.commitmentIDs.contains(where: { commitmentIDs.contains($0) == false }) {
                issues.insert(.missingCommitmentForCandidate)
            }
            if bridge.commitmentProjection.capacityFit == .tight &&
                pathBridge.recoveryCommitmentIDs.isEmpty &&
                pathBridge.minimumCapacityBufferMinutes == 0 {
                issues.insert(.recoveryBufferMissing)
            }
            if pathBridge.allowsActivation {
                issues.insert(.activationForbidden)
            }
            if pathBridge.mutatesCommitments || pathBridge.writesScheduleAutomatically {
                issues.insert(.hiddenMutationRisk)
            }
            if pathBridge.usesUserDataServer {
                issues.insert(.userDataServerBoundaryBroken)
            }
            if pathBridge.runtimeBoundary.isValueModelOnly == false {
                issues.insert(.runtimeBoundaryBroken)
            }
        }
    }
}
