import Foundation

let ambitionsOSControlPlaneSchemaVersion = "ambitionsos_control_plane.native.v1"

enum AmbitionsOSControlPlaneSurface: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case today
    case goals
    case capture
    case plan
    case you
    case externalProjection = "external_projection"
    case runtimeContract = "runtime_contract"
}

enum AmbitionsOSWorkClass: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case instant
    case interactive
    case deferred
    case background
    case blocked
}

enum AmbitionsOSControlPlaneGate: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case sourceVerification = "source_verification"
    case userApproval = "user_approval"
    case graphDeltaReview = "graph_delta_review"
    case trustReview = "trust_review"
    case safetyReview = "safety_review"
    case privacyProjection = "privacy_projection"
    case performanceBudget = "performance_budget"
    case compatibilityReview = "compatibility_review"
    case maintainabilityReview = "maintainability_review"
    case releaseEvidenceReview = "release_evidence_review"
    case deterministicFallback = "deterministic_fallback"
}

enum AmbitionsOSControlPlaneSignal: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case localOnly = "local_only"
    case sourceSensitive = "source_sensitive"
    case regulatedDomain = "regulated_domain"
    case crisisOrSafety = "crisis_or_safety"
    case dreamIntake = "dream_intake"
    case graphDeltaProposal = "graph_delta_proposal"
    case externalSurface = "external_surface"
    case requiresInternet = "requires_internet"
    case backgroundExecution = "background_execution"
    case largeFileOwner = "large_file_owner"
    case compatibilitySurface = "compatibility_surface"
    case releaseClaim = "release_claim"
    case modelAssisted = "model_assisted"
}

enum AmbitionsOSRuntimeOutputKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case graphDelta = "graph_delta"
    case projection
    case recommendation
    case question
    case receipt
    case reviewRequest = "review_request"
    case sourceRequest = "source_request"
    case impactReport = "impact_report"
    case privacyProjection = "privacy_projection"
    case capabilityFallback = "capability_fallback"
    case testPlan = "test_plan"
}

enum AmbitionsOSControlPlaneDisposition: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case allowLocalWork = "allow_local_work"
    case requireReview = "require_review"
    case blocked
}

struct AmbitionsOSControlPlaneWorkRequest: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let surface: AmbitionsOSControlPlaneSurface
    let signals: [AmbitionsOSControlPlaneSignal]
    let sourceState: HumanProgressSourceState
    let freshnessState: HumanProgressFreshnessState
    let reviewState: HumanProgressReviewState
    let privacyClass: HumanProgressPrivacyClass
    let deltaReviewRecord: LifeGraphDeltaReviewRecord?
    let requestedAt: String
    let schemaVersion: String

    init(
        id: String,
        title: String,
        surface: AmbitionsOSControlPlaneSurface,
        signals: [AmbitionsOSControlPlaneSignal] = [.localOnly],
        sourceState: HumanProgressSourceState = .userStated,
        freshnessState: HumanProgressFreshnessState = .notApplicable,
        reviewState: HumanProgressReviewState = .ready,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        deltaReviewRecord: LifeGraphDeltaReviewRecord? = nil,
        requestedAt: String,
        schemaVersion: String = ambitionsOSControlPlaneSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.surface = surface
        self.signals = Self.orderedUnique(signals)
        self.sourceState = sourceState
        self.freshnessState = freshnessState
        self.reviewState = reviewState
        self.privacyClass = privacyClass
        self.deltaReviewRecord = deltaReviewRecord
        self.requestedAt = requestedAt
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false && title.isEmpty == false
    }

    var sourceCanDriveWork: Bool {
        sourceState.canDriveSourceSensitiveRecommendation &&
            freshnessState.blocksHighRiskUse == false &&
            reviewState.blocksAutomaticMutation == false
    }

    func contains(_ signal: AmbitionsOSControlPlaneSignal) -> Bool {
        signals.contains(signal)
    }

    private static func orderedUnique(_ values: [AmbitionsOSControlPlaneSignal]) -> [AmbitionsOSControlPlaneSignal] {
        Array(Set(values)).sorted { $0.rawValue < $1.rawValue }
    }
}

struct AmbitionsOSControlPlaneClassification: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let requestID: String
    let workClass: AmbitionsOSWorkClass
    let disposition: AmbitionsOSControlPlaneDisposition
    let requiredGates: [AmbitionsOSControlPlaneGate]
    let allowedOutputs: [AmbitionsOSRuntimeOutputKind]
    let rationaleIDs: [String]
    let schemaVersion: String

    init(
        id: String,
        requestID: String,
        workClass: AmbitionsOSWorkClass,
        disposition: AmbitionsOSControlPlaneDisposition,
        requiredGates: [AmbitionsOSControlPlaneGate],
        allowedOutputs: [AmbitionsOSRuntimeOutputKind],
        rationaleIDs: [String],
        schemaVersion: String = ambitionsOSControlPlaneSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.requestID = requestID
        self.workClass = workClass
        self.disposition = disposition
        self.requiredGates = Self.orderedUnique(requiredGates)
        self.allowedOutputs = Self.orderedUnique(allowedOutputs)
        self.rationaleIDs = Self.orderedUniqueStrings(rationaleIDs)
        self.schemaVersion = schemaVersion
    }

    var canReachEventLog: Bool {
        disposition == .allowLocalWork && requiredGates.isEmpty
    }

    var blocksRecommendation: Bool {
        disposition == .blocked ||
            requiredGates.contains(.sourceVerification) ||
            requiredGates.contains(.safetyReview) ||
            requiredGates.contains(.graphDeltaReview)
    }

    private static func orderedUnique(_ values: [AmbitionsOSControlPlaneGate]) -> [AmbitionsOSControlPlaneGate] {
        Array(Set(values)).sorted { $0.rawValue < $1.rawValue }
    }

    private static func orderedUnique(_ values: [AmbitionsOSRuntimeOutputKind]) -> [AmbitionsOSRuntimeOutputKind] {
        Array(Set(values)).sorted { $0.rawValue < $1.rawValue }
    }

    private static func orderedUniqueStrings(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct AmbitionsOSControlPlaneClassifier: Sendable, Equatable, Hashable {
    func classify(_ request: AmbitionsOSControlPlaneWorkRequest) -> AmbitionsOSControlPlaneClassification {
        guard request.isWellFormed else {
            return classification(
                for: request,
                workClass: .blocked,
                disposition: .blocked,
                gates: [.trustReview],
                outputs: [.reviewRequest, .capabilityFallback],
                rationaleIDs: ["malformed_request"]
            )
        }

        if request.contains(.crisisOrSafety) {
            return classification(
                for: request,
                workClass: .blocked,
                disposition: .blocked,
                gates: [.safetyReview, .trustReview, .userApproval],
                outputs: [.capabilityFallback, .reviewRequest],
                rationaleIDs: ["safety_first_block"]
            )
        }

        if request.contains(.releaseClaim) {
            return classification(
                for: request,
                workClass: .blocked,
                disposition: .blocked,
                gates: [.releaseEvidenceReview, .trustReview],
                outputs: [.impactReport, .testPlan],
                rationaleIDs: ["release_claim_requires_evidence"]
            )
        }

        var gates: Set<AmbitionsOSControlPlaneGate> = []
        var outputs: Set<AmbitionsOSRuntimeOutputKind> = [.reviewRequest]
        var rationaleIDs: Set<String> = []
        var workClass: AmbitionsOSWorkClass = .instant

        if request.contains(.sourceSensitive) || request.contains(.regulatedDomain) || request.contains(.dreamIntake) {
            workClass = .interactive
            if request.sourceCanDriveWork == false {
                gates.insert(.sourceVerification)
                gates.insert(.userApproval)
                outputs.insert(.sourceRequest)
                rationaleIDs.insert("source_review_required")
            }
            if request.contains(.regulatedDomain) || request.contains(.dreamIntake) {
                gates.insert(.safetyReview)
                gates.insert(.userApproval)
                rationaleIDs.insert("professional_boundary_review")
            }
        }

        if request.contains(.graphDeltaProposal) {
            let canProject = request.deltaReviewRecord?.canProject == true
            outputs.insert(.graphDelta)
            outputs.insert(.projection)
            if canProject == false {
                gates.insert(.graphDeltaReview)
                gates.insert(.trustReview)
                gates.insert(.userApproval)
                outputs.insert(.receipt)
                rationaleIDs.insert("graph_delta_review_required")
            } else {
                outputs.insert(.receipt)
                rationaleIDs.insert("graph_delta_review_record_ready")
            }
        }

        if request.contains(.externalSurface) {
            gates.insert(.privacyProjection)
            gates.insert(.compatibilityReview)
            outputs.insert(.privacyProjection)
            rationaleIDs.insert("external_surface_projection_review")
        }

        if request.contains(.backgroundExecution) || request.contains(.modelAssisted) {
            workClass = max(workClass, .background)
            gates.insert(.performanceBudget)
            gates.insert(.deterministicFallback)
            outputs.insert(.capabilityFallback)
            rationaleIDs.insert("runtime_budget_required")
        }

        if request.contains(.requiresInternet) {
            workClass = max(workClass, .deferred)
            gates.insert(.deterministicFallback)
            outputs.insert(.capabilityFallback)
            rationaleIDs.insert("offline_fallback_required")
        }

        if request.contains(.largeFileOwner) {
            gates.insert(.maintainabilityReview)
            outputs.insert(.impactReport)
            rationaleIDs.insert("large_file_owner_review")
        }

        if request.contains(.compatibilitySurface) {
            gates.insert(.compatibilityReview)
            outputs.insert(.impactReport)
            rationaleIDs.insert("compatibility_review_required")
        }

        if gates.isEmpty {
            outputs.insert(.recommendation)
            rationaleIDs.insert("local_work_allowed")
        }

        let disposition: AmbitionsOSControlPlaneDisposition = gates.isEmpty ? .allowLocalWork : .requireReview
        return classification(
            for: request,
            workClass: gates.isEmpty ? workClass : max(workClass, .interactive),
            disposition: disposition,
            gates: Array(gates),
            outputs: Array(outputs),
            rationaleIDs: Array(rationaleIDs)
        )
    }

    private func classification(
        for request: AmbitionsOSControlPlaneWorkRequest,
        workClass: AmbitionsOSWorkClass,
        disposition: AmbitionsOSControlPlaneDisposition,
        gates: [AmbitionsOSControlPlaneGate],
        outputs: [AmbitionsOSRuntimeOutputKind],
        rationaleIDs: [String]
    ) -> AmbitionsOSControlPlaneClassification {
        AmbitionsOSControlPlaneClassification(
            id: "classification:\(request.id)",
            requestID: request.id,
            workClass: workClass,
            disposition: disposition,
            requiredGates: gates,
            allowedOutputs: outputs,
            rationaleIDs: rationaleIDs
        )
    }
}

private func max(_ lhs: AmbitionsOSWorkClass, _ rhs: AmbitionsOSWorkClass) -> AmbitionsOSWorkClass {
    AmbitionsOSWorkClass.order[lhs, default: 0] >= AmbitionsOSWorkClass.order[rhs, default: 0] ? lhs : rhs
}

private extension AmbitionsOSWorkClass {
    static let order: [AmbitionsOSWorkClass: Int] = [
        .instant: 0,
        .interactive: 1,
        .deferred: 2,
        .background: 3,
        .blocked: 4
    ]
}
