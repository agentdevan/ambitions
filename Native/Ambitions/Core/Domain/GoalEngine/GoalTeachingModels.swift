import Foundation

let goalTeachingSchemaVersion = "goal_teaching.native.v1"

enum GoalTeachingSignalKind: String, Codable, Sendable, Equatable, Hashable {
    case interpretationCorrection = "interpretation_correction"
    case goalSubjectCorrection = "goal_subject_correction"
    case classificationCorrection = "classification_correction"
    case requirementRelevanceCorrection = "requirement_relevance_correction"
    case contradictionDispositionCorrection = "contradiction_disposition_correction"
    case energyFitCorrection = "energy_fit_correction"
}

enum GoalTeachingSignalSource: String, Codable, Sendable, Equatable, Hashable {
    case explicitManualCorrection = "explicit_manual_correction"
}

enum GoalTeachingDisposition: String, Codable, Sendable, Equatable, Hashable {
    case active
    case revoked
}

enum GoalTeachingArtifactKind: String, Codable, Sendable, Equatable, Hashable {
    case understandingInterpretation = "understanding_interpretation"
    case goalSubjectField = "goal_subject_field"
    case classificationField = "classification_field"
    case requirementHint = "requirement_hint"
    case readinessCriterion = "readiness_criterion"
    case resourceHook = "resource_hook"
    case contradictionShape = "contradiction_shape"
    case energyEvaluation = "energy_evaluation"
}

enum GoalTeachingCanonicalField: String, Codable, Sendable, Equatable, Hashable {
    case goalSubject = "goal_subject"
    case mode
    case domain
    case ownership
    case timeline = "timeline"
}

enum GoalTeachingRequirementDispositionValue: String, Codable, Sendable, Equatable, Hashable {
    case relevant
    case notRelevant = "not_relevant"
    case required
    case notRequired = "not_required"
}

enum GoalTeachingContradictionDispositionValue: String, Codable, Sendable, Equatable, Hashable {
    case confirmed
    case dismissed
}

enum GoalTeachingEnergyDispositionValue: String, Codable, Sendable, Equatable, Hashable {
    case supportive
    case strained
    case lighterVersionNeeded = "lighter_version_needed"
}

struct GoalTeachingContradictionArtifactRef: Codable, Sendable, Equatable, Hashable {
    let kind: GoalContradictionArtifactKind
    let id: String
    let candidateID: String?
    let stageID: String?

    init(
        kind: GoalContradictionArtifactKind,
        id: String,
        candidateID: String? = nil,
        stageID: String? = nil
    ) {
        self.kind = kind
        self.id = id
        self.candidateID = candidateID
        self.stageID = stageID
    }

    var normalizedIdentity: String {
        [
            kind.rawValue,
            id,
            candidateID ?? "",
            stageID ?? ""
        ].joined(separator: "::")
    }
}

struct GoalTeachingStableAnchor: Codable, Sendable, Equatable, Hashable {
    let artifactKind: GoalTeachingArtifactKind
    let canonicalField: GoalTeachingCanonicalField?
    let candidateID: String?
    let stageID: String?
    let stepID: String?
    let targetFingerprint: String
    let contradictionCode: GoalContradictionCode?
    let contradictionArtifactRefs: [GoalTeachingContradictionArtifactRef]

    var normalizedIdentity: String {
        [
            artifactKind.rawValue,
            canonicalField?.rawValue ?? "",
            candidateID ?? "",
            stageID ?? "",
            stepID ?? "",
            contradictionCode?.rawValue ?? "",
            targetFingerprint,
            normalizedContradictionArtifactRefs.map(\.normalizedIdentity).joined(separator: "|")
        ].joined(separator: "##")
    }

    var normalizedContradictionArtifactRefs: [GoalTeachingContradictionArtifactRef] {
        contradictionArtifactRefs.sorted { lhs, rhs in
            lhs.normalizedIdentity < rhs.normalizedIdentity
        }
    }

    static func contradiction(
        code: GoalContradictionCode,
        candidateID: String?,
        stageID: String?,
        artifactRefs: [GoalTeachingContradictionArtifactRef]
    ) -> GoalTeachingStableAnchor {
        GoalTeachingStableAnchor(
            artifactKind: .contradictionShape,
            canonicalField: nil,
            candidateID: candidateID,
            stageID: stageID,
            stepID: nil,
            targetFingerprint: normalizedContradictionFingerprint(code: code, artifactRefs: artifactRefs),
            contradictionCode: code,
            contradictionArtifactRefs: artifactRefs.sorted { $0.normalizedIdentity < $1.normalizedIdentity }
        )
    }

    static func normalizedContradictionFingerprint(
        code: GoalContradictionCode,
        artifactRefs: [GoalTeachingContradictionArtifactRef]
    ) -> String {
        let refs = artifactRefs
            .sorted { $0.normalizedIdentity < $1.normalizedIdentity }
            .map(\.normalizedIdentity)
            .joined(separator: "|")
        return [code.rawValue, refs].joined(separator: "##")
    }
}

struct GoalTeachingInterpretationCorrection: Codable, Sendable, Equatable, Hashable {
    let preferredInterpretationSummary: String
    let preferredModeHint: GoalMode?
    let preferredDomainHints: [LifeDomainKey]
}

struct GoalTeachingGoalSubjectCorrection: Codable, Sendable, Equatable, Hashable {
    let correctedCanonicalIntent: String
}

enum GoalTeachingClassificationCorrectedValue: Sendable, Equatable, Hashable {
    case mode(GoalMode)
    case domain(LifeDomainKey)
    case ownership(ExecutionOwnership)
    case timelinePosture(GoalUnderstandingTimelinePosture)
}

extension GoalTeachingClassificationCorrectedValue: Codable {
    private enum CodingKeys: String, CodingKey {
        case type
        case mode
        case domain
        case ownership
        case timelinePosture
    }

    private enum ValueType: String, Codable {
        case mode
        case domain
        case ownership
        case timelinePosture
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .mode(value):
            try container.encode(ValueType.mode, forKey: .type)
            try container.encode(value, forKey: .mode)
        case let .domain(value):
            try container.encode(ValueType.domain, forKey: .type)
            try container.encode(value, forKey: .domain)
        case let .ownership(value):
            try container.encode(ValueType.ownership, forKey: .type)
            try container.encode(value, forKey: .ownership)
        case let .timelinePosture(value):
            try container.encode(ValueType.timelinePosture, forKey: .type)
            try container.encode(value, forKey: .timelinePosture)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(ValueType.self, forKey: .type) {
        case .mode:
            self = .mode(try container.decode(GoalMode.self, forKey: .mode))
        case .domain:
            self = .domain(try container.decode(LifeDomainKey.self, forKey: .domain))
        case .ownership:
            self = .ownership(try container.decode(ExecutionOwnership.self, forKey: .ownership))
        case .timelinePosture:
            self = .timelinePosture(try container.decode(GoalUnderstandingTimelinePosture.self, forKey: .timelinePosture))
        }
    }
}

struct GoalTeachingClassificationCorrection: Codable, Sendable, Equatable, Hashable {
    let field: GoalTeachingCanonicalField
    let correctedValue: GoalTeachingClassificationCorrectedValue

    var normalizedTargetValue: String {
        switch correctedValue {
        case let .mode(mode):
            return [field.rawValue, mode.rawValue].joined(separator: "::")
        case let .domain(domain):
            return [field.rawValue, domain.rawValue].joined(separator: "::")
        case let .ownership(ownership):
            return [field.rawValue, ownership.rawValue].joined(separator: "::")
        case let .timelinePosture(posture):
            return [field.rawValue, posture.rawValue].joined(separator: "::")
        }
    }
}

struct GoalTeachingRequirementRelevanceCorrection: Codable, Sendable, Equatable, Hashable {
    let correctedDisposition: GoalTeachingRequirementDispositionValue
}

struct GoalTeachingContradictionDispositionCorrection: Codable, Sendable, Equatable, Hashable {
    let correctedDisposition: GoalTeachingContradictionDispositionValue
}

struct GoalTeachingEnergyFitCorrection: Codable, Sendable, Equatable, Hashable {
    let correctedDisposition: GoalTeachingEnergyDispositionValue
}

enum GoalTeachingPayload: Sendable, Equatable, Hashable {
    case interpretation(GoalTeachingInterpretationCorrection)
    case goalSubject(GoalTeachingGoalSubjectCorrection)
    case classification(GoalTeachingClassificationCorrection)
    case requirementRelevance(GoalTeachingRequirementRelevanceCorrection)
    case contradictionDisposition(GoalTeachingContradictionDispositionCorrection)
    case energyFit(GoalTeachingEnergyFitCorrection)
}

extension GoalTeachingPayload: Codable {
    private enum CodingKeys: String, CodingKey {
        case type
        case interpretation
        case goalSubject
        case classification
        case requirementRelevance
        case contradictionDisposition
        case energyFit
    }

    private enum PayloadType: String, Codable {
        case interpretation
        case goalSubject
        case classification
        case requirementRelevance
        case contradictionDisposition
        case energyFit
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .interpretation(value):
            try container.encode(PayloadType.interpretation, forKey: .type)
            try container.encode(value, forKey: .interpretation)
        case let .goalSubject(value):
            try container.encode(PayloadType.goalSubject, forKey: .type)
            try container.encode(value, forKey: .goalSubject)
        case let .classification(value):
            try container.encode(PayloadType.classification, forKey: .type)
            try container.encode(value, forKey: .classification)
        case let .requirementRelevance(value):
            try container.encode(PayloadType.requirementRelevance, forKey: .type)
            try container.encode(value, forKey: .requirementRelevance)
        case let .contradictionDisposition(value):
            try container.encode(PayloadType.contradictionDisposition, forKey: .type)
            try container.encode(value, forKey: .contradictionDisposition)
        case let .energyFit(value):
            try container.encode(PayloadType.energyFit, forKey: .type)
            try container.encode(value, forKey: .energyFit)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(PayloadType.self, forKey: .type) {
        case .interpretation:
            self = .interpretation(try container.decode(GoalTeachingInterpretationCorrection.self, forKey: .interpretation))
        case .goalSubject:
            self = .goalSubject(try container.decode(GoalTeachingGoalSubjectCorrection.self, forKey: .goalSubject))
        case .classification:
            self = .classification(try container.decode(GoalTeachingClassificationCorrection.self, forKey: .classification))
        case .requirementRelevance:
            self = .requirementRelevance(try container.decode(GoalTeachingRequirementRelevanceCorrection.self, forKey: .requirementRelevance))
        case .contradictionDisposition:
            self = .contradictionDisposition(try container.decode(GoalTeachingContradictionDispositionCorrection.self, forKey: .contradictionDisposition))
        case .energyFit:
            self = .energyFit(try container.decode(GoalTeachingEnergyFitCorrection.self, forKey: .energyFit))
        }
    }
}

struct GoalTeachingSignal: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let goalID: String
    let createdAt: String
    let updatedAt: String
    let source: GoalTeachingSignalSource
    let kind: GoalTeachingSignalKind
    let disposition: GoalTeachingDisposition
    let anchor: GoalTeachingStableAnchor
    let payload: GoalTeachingPayload
    let applicationKey: String
    let userNote: String?

    static func makeApplicationKey(
        goalID: String,
        kind: GoalTeachingSignalKind,
        anchor: GoalTeachingStableAnchor,
        normalizedTargetValue: String
    ) -> String {
        [
            goalID,
            kind.rawValue,
            anchor.normalizedIdentity,
            normalizedTargetValue
        ].joined(separator: "##")
    }
}

/// A validated correction that is safe to show or hand to a future canonical
/// mutation command. It deliberately excludes the user's free-form note and
/// correction payload so proposal surfaces do not become a second persistence
/// or disclosure boundary.
struct GoalTeachingCorrectionProposal: Sendable, Equatable, Hashable {
    let goalID: String
    let capturedAt: String
    let kind: GoalTeachingSignalKind
    let source: GoalTeachingSignalSource
    let anchor: GoalTeachingStableAnchor
    let applicationKey: String
}

struct GoalTeachingCaptureTarget: Codable, Sendable, Equatable, Hashable {
    let artifactKind: GoalTeachingArtifactKind
    let canonicalField: GoalTeachingCanonicalField?
    let candidateID: String?
    let stageID: String?
    let stepID: String?
    let interpretationSummary: String?
    let interpretationModeHint: GoalMode?
    let interpretationDomainHints: [LifeDomainKey]
    let requirementSummary: String?
    let readinessToken: String?
    let contradictionCode: GoalContradictionCode?
    let contradictionArtifactRefs: [GoalTeachingContradictionArtifactRef]
    let energyTargetKind: GoalEnergyFitTargetKind?
    let energyTargetID: String?

    init(
        artifactKind: GoalTeachingArtifactKind,
        canonicalField: GoalTeachingCanonicalField? = nil,
        candidateID: String? = nil,
        stageID: String? = nil,
        stepID: String? = nil,
        interpretationSummary: String? = nil,
        interpretationModeHint: GoalMode? = nil,
        interpretationDomainHints: [LifeDomainKey] = [],
        requirementSummary: String? = nil,
        readinessToken: String? = nil,
        contradictionCode: GoalContradictionCode? = nil,
        contradictionArtifactRefs: [GoalTeachingContradictionArtifactRef] = [],
        energyTargetKind: GoalEnergyFitTargetKind? = nil,
        energyTargetID: String? = nil
    ) {
        self.artifactKind = artifactKind
        self.canonicalField = canonicalField
        self.candidateID = candidateID
        self.stageID = stageID
        self.stepID = stepID
        self.interpretationSummary = interpretationSummary
        self.interpretationModeHint = interpretationModeHint
        self.interpretationDomainHints = interpretationDomainHints
        self.requirementSummary = requirementSummary
        self.readinessToken = readinessToken
        self.contradictionCode = contradictionCode
        self.contradictionArtifactRefs = contradictionArtifactRefs
        self.energyTargetKind = energyTargetKind
        self.energyTargetID = energyTargetID
    }
}

struct GoalTeachingCaptureRequest: Codable, Sendable, Equatable, Hashable {
    let goalID: String
    let capturedAt: String
    let kind: GoalTeachingSignalKind
    let payload: GoalTeachingPayload
    let target: GoalTeachingCaptureTarget
    let userNote: String?
}

struct GoalTeachingApplicableSet: Codable, Sendable, Equatable, Hashable {
    let goalID: String
    let signals: [GoalTeachingSignal]
    let supersededSignalIDs: [String]
}

extension GoalTeachingPayload {
    var normalizedTargetValue: String {
        switch self {
        case let .interpretation(value):
            return [
                normalize(value.preferredInterpretationSummary),
                value.preferredModeHint?.rawValue ?? "",
                value.preferredDomainHints.map(\.rawValue).sorted().joined(separator: "|")
            ].joined(separator: "::")
        case let .goalSubject(value):
            return normalize(value.correctedCanonicalIntent)
        case let .classification(value):
            return value.normalizedTargetValue
        case let .requirementRelevance(value):
            return value.correctedDisposition.rawValue
        case let .contradictionDisposition(value):
            return value.correctedDisposition.rawValue
        case let .energyFit(value):
            return value.correctedDisposition.rawValue
        }
    }
}

func normalize(_ value: String) -> String {
    value
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .lowercased()
}
