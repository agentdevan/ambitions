import Foundation

let ambitionsOSLivingDreamRequirementGraphSchemaVersion = "ambitionsos_living_dream_requirement_graph.native.v1"

enum AmbitionsOSLivingDreamRequirementKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case hard
    case soft
    case blocker
    case dependency
    case proofNeeded = "proof_needed"
    case sourceNeeded = "source_needed"
    case review
}

enum AmbitionsOSLivingDreamRequirementState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unknown
    case satisfied
    case missing
    case blocked
    case needsProof = "needs_proof"
    case needsSourceReview = "needs_source_review"
    case stale
    case conflict

    var isSatisfiedForPlanning: Bool {
        switch self {
        case .satisfied:
            return true
        case .unknown, .missing, .blocked, .needsProof, .needsSourceReview, .stale, .conflict:
            return false
        }
    }
}

enum AmbitionsOSLivingDreamRequirementGraphIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case malformedRequirement = "malformed_requirement"
    case duplicateRequirementID = "duplicate_requirement_id"
    case missingDependency = "missing_dependency"
    case dependencyUnsatisfied = "dependency_unsatisfied"
    case missingSourceClaim = "missing_source_claim"
    case sourceClaimGraphNotReady = "source_claim_graph_not_ready"
    case packSecurityNotTrusted = "pack_security_not_trusted"
    case hardRequirementUnsatisfied = "hard_requirement_unsatisfied"
    case blockerOpen = "blocker_open"
    case proofMissing = "proof_missing"
    case professionalBoundaryNeedsReview = "professional_boundary_needs_review"
    case runtimeBoundaryBroken = "runtime_boundary_broken"
    case userDataServerBoundaryBroken = "user_data_server_boundary_broken"
    case activationForbidden = "activation_forbidden"
}

struct AmbitionsOSLivingDreamRequirementNode: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let kind: AmbitionsOSLivingDreamRequirementKind
    let state: AmbitionsOSLivingDreamRequirementState
    let sourceClaimIDs: [String]
    let dependencyIDs: [String]
    let proofIDs: [String]
    let professionalBoundary: Bool
    let reviewState: HumanProgressReviewState

    init(
        id: String,
        title: String,
        kind: AmbitionsOSLivingDreamRequirementKind,
        state: AmbitionsOSLivingDreamRequirementState,
        sourceClaimIDs: [String] = [],
        dependencyIDs: [String] = [],
        proofIDs: [String] = [],
        professionalBoundary: Bool = false,
        reviewState: HumanProgressReviewState
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.kind = kind
        self.state = state
        self.sourceClaimIDs = Self.orderedUnique(sourceClaimIDs)
        self.dependencyIDs = Self.orderedUnique(dependencyIDs)
        self.proofIDs = Self.orderedUnique(proofIDs)
        self.professionalBoundary = professionalBoundary
        self.reviewState = reviewState
    }

    var isWellFormed: Bool {
        id.isEmpty == false && title.isEmpty == false
    }

    var needsProofButHasNone: Bool {
        kind == .proofNeeded && proofIDs.isEmpty
    }

    var blocksConsequentialPlanning: Bool {
        switch kind {
        case .hard:
            return state.isSatisfiedForPlanning == false
        case .blocker:
            return state != .satisfied
        case .proofNeeded:
            return needsProofButHasNone || state.isSatisfiedForPlanning == false
        case .dependency, .sourceNeeded, .review:
            return state == .blocked || state == .conflict || state == .stale
        case .soft:
            return false
        }
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct AmbitionsOSLivingDreamRequirementGraph: Codable, Sendable, Equatable, Hashable {
    let id: String
    let schemaVersion: String
    let requirements: [AmbitionsOSLivingDreamRequirementNode]
    let sourceClaimGraph: AmbitionsOSLivingDreamSourceClaimGraph
    let packSecurityEnvelope: AmbitionsOSLivingDreamPackSupplyChainEnvelope
    let runtimeBoundary: SourceAtlasRuntimeBoundary
    let allowsActivation: Bool
    let usesUserDataServer: Bool

    init(
        id: String,
        schemaVersion: String = ambitionsOSLivingDreamRequirementGraphSchemaVersion,
        requirements: [AmbitionsOSLivingDreamRequirementNode],
        sourceClaimGraph: AmbitionsOSLivingDreamSourceClaimGraph,
        packSecurityEnvelope: AmbitionsOSLivingDreamPackSupplyChainEnvelope,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        allowsActivation: Bool = false,
        usesUserDataServer: Bool = false
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.schemaVersion = schemaVersion
        self.requirements = requirements
        self.sourceClaimGraph = sourceClaimGraph
        self.packSecurityEnvelope = packSecurityEnvelope
        self.runtimeBoundary = runtimeBoundary
        self.allowsActivation = allowsActivation
        self.usesUserDataServer = usesUserDataServer
    }

    var validationIssues: [AmbitionsOSLivingDreamRequirementGraphIssue] {
        AmbitionsOSLivingDreamRequirementGraphValidator().validate(graph: self)
    }
}

struct AmbitionsOSLivingDreamRequirementGraphEvaluation: Codable, Sendable, Equatable, Hashable {
    let graphID: String
    let readyRequirementIDs: [String]
    let blockerRequirementIDs: [String]
    let proofNeededRequirementIDs: [String]
    let issues: [AmbitionsOSLivingDreamRequirementGraphIssue]
    let activatesPlans: Bool
    let mutatesCommitments: Bool

    var canRecommendConsequentialNextStep: Bool {
        issues.isEmpty && blockerRequirementIDs.isEmpty
    }
}

struct AmbitionsOSLivingDreamRequirementGraphValidator: Sendable, Equatable, Hashable {
    func validate(
        graph: AmbitionsOSLivingDreamRequirementGraph
    ) -> [AmbitionsOSLivingDreamRequirementGraphIssue] {
        var issues: Set<AmbitionsOSLivingDreamRequirementGraphIssue> = []
        let requirementIDs = graph.requirements.map(\.id)
        let availableClaimIDs = Set(graph.sourceClaimGraph.claims.map(\.id))

        if graph.schemaVersion != ambitionsOSLivingDreamRequirementGraphSchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if graph.id.isEmpty || graph.requirements.isEmpty || graph.requirements.contains(where: { $0.isWellFormed == false }) {
            issues.insert(.malformedRequirement)
        }
        if Set(requirementIDs).count != requirementIDs.count {
            issues.insert(.duplicateRequirementID)
        }
        if graph.sourceClaimGraph.validationIssues.isEmpty == false ||
            graph.sourceClaimGraph.claimsReadyForConsequentialRecommendation.isEmpty {
            issues.insert(.sourceClaimGraphNotReady)
        }
        if graph.packSecurityEnvelope.isTrustedForRegistry == false {
            issues.insert(.packSecurityNotTrusted)
        }
        if graph.runtimeBoundary.isValueModelOnly == false {
            issues.insert(.runtimeBoundaryBroken)
        }
        if graph.usesUserDataServer {
            issues.insert(.userDataServerBoundaryBroken)
        }
        if graph.allowsActivation {
            issues.insert(.activationForbidden)
        }

        for requirement in graph.requirements {
            let missingClaims = requirement.sourceClaimIDs.contains { availableClaimIDs.contains($0) == false }
            if missingClaims {
                issues.insert(.missingSourceClaim)
            }

            for dependencyID in requirement.dependencyIDs where requirementIDs.contains(dependencyID) == false {
                issues.insert(.missingDependency)
            }

            let dependencies = graph.requirements.filter { requirement.dependencyIDs.contains($0.id) }
            if dependencies.contains(where: { $0.state.isSatisfiedForPlanning == false }) {
                issues.insert(.dependencyUnsatisfied)
            }

            if requirement.kind == .hard && requirement.state.isSatisfiedForPlanning == false {
                issues.insert(.hardRequirementUnsatisfied)
            }
            if requirement.kind == .blocker && requirement.state != .satisfied {
                issues.insert(.blockerOpen)
            }
            if requirement.needsProofButHasNone {
                issues.insert(.proofMissing)
            }
            if requirement.professionalBoundary && requirement.reviewState != .ready {
                issues.insert(.professionalBoundaryNeedsReview)
            }
        }

        return issues.sorted { $0.rawValue < $1.rawValue }
    }

    func evaluate(
        graph: AmbitionsOSLivingDreamRequirementGraph
    ) -> AmbitionsOSLivingDreamRequirementGraphEvaluation {
        let issues = validate(graph: graph)
        return AmbitionsOSLivingDreamRequirementGraphEvaluation(
            graphID: graph.id,
            readyRequirementIDs: graph.requirements.filter { $0.state.isSatisfiedForPlanning }.map(\.id).sorted(),
            blockerRequirementIDs: graph.requirements.filter(\.blocksConsequentialPlanning).map(\.id).sorted(),
            proofNeededRequirementIDs: graph.requirements.filter { $0.kind == .proofNeeded && $0.proofIDs.isEmpty }.map(\.id).sorted(),
            issues: issues,
            activatesPlans: false,
            mutatesCommitments: false
        )
    }
}
