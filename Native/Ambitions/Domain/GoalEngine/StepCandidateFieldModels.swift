import Foundation

let stepCandidateFieldSchemaVersion = "step_candidate_field.native.v1"

enum CandidateSource: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case goalIntentCompiler = "goal_intent_compiler"
    case privateLifeRuntime = "private_life_runtime"
    case replayTrace = "replay_trace"
    case personalizationFactorLedger = "personalization_factor_ledger"
    case fallback
}

enum CandidateValidity: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case preferred
    case review
    case fallback
    case blocked
    case rejected

    var sortWeight: Int {
        switch self {
        case .preferred:
            return 4
        case .review:
            return 3
        case .fallback:
            return 2
        case .blocked:
            return 1
        case .rejected:
            return 0
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .preferred:
            return "Preferred"
        case .review:
            return "Needs review"
        case .fallback:
            return "Fallback"
        case .blocked:
            return "Blocked"
        case .rejected:
            return "Rejected"
        }
    }
}

enum CandidateRiskLevel: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case low
    case moderate
    case high

    var sortWeight: Int {
        switch self {
        case .low:
            return 2
        case .moderate:
            return 1
        case .high:
            return 0
        }
    }
}

enum StepCandidateKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case directBest = "direct_best"
    case lighter
    case shorter
    case lowerEnergy = "lower_energy"
    case locationCompatible = "location_compatible"
    case noEquipment = "no_equipment"
    case recoverySafe = "recovery_safe"
    case adminSetup = "admin_setup"
    case learningResearch = "learning_research"
    case proofGathering = "proof_gathering"
    case prerequisite
    case maintenance
    case catchUp = "catch_up"
    case substitution
    case parallelPath = "parallel_path"
    case fallback

    var semanticLabel: String {
        switch self {
        case .directBest:
            return "Direct best"
        case .lighter:
            return "Lighter"
        case .shorter:
            return "Shorter"
        case .lowerEnergy:
            return "Lower energy"
        case .locationCompatible:
            return "Location compatible"
        case .noEquipment:
            return "No equipment"
        case .recoverySafe:
            return "Recovery safe"
        case .adminSetup:
            return "Admin setup"
        case .learningResearch:
            return "Learning and research"
        case .proofGathering:
            return "Proof gathering"
        case .prerequisite:
            return "Prerequisite"
        case .maintenance:
            return "Maintenance"
        case .catchUp:
            return "Catch up"
        case .substitution:
            return "Substitution"
        case .parallelPath:
            return "Parallel path"
        case .fallback:
            return "Fallback"
        }
    }

    var defaultValidity: CandidateValidity {
        switch self {
        case .directBest, .lighter, .shorter, .lowerEnergy, .locationCompatible, .noEquipment, .recoverySafe, .adminSetup, .learningResearch, .proofGathering, .prerequisite, .maintenance, .catchUp, .substitution, .parallelPath:
            return .review
        case .fallback:
            return .fallback
        }
    }
}

struct CandidateTradeoff: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let label: String
    let benefit: String
    let cost: String
    let note: String?

    init(
        id: String,
        label: String,
        benefit: String,
        cost: String,
        note: String? = nil
    ) {
        self.id = Self.normalizedRequired(id)
        self.label = Self.normalizedRequired(label)
        self.benefit = Self.normalizedRequired(benefit)
        self.cost = Self.normalizedRequired(cost)
        self.note = Self.normalizedOptional(note)
    }
}

struct CandidateRejectionRisk: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let level: CandidateRiskLevel
    let summary: String
    let factorIDs: [String]
    let requiresReview: Bool

    init(
        id: String,
        level: CandidateRiskLevel,
        summary: String,
        factorIDs: [String] = [],
        requiresReview: Bool
    ) {
        self.id = Self.normalizedRequired(id)
        self.level = level
        self.summary = Self.normalizedRequired(summary)
        self.factorIDs = Self.normalizedStrings(factorIDs)
        self.requiresReview = requiresReview
    }
}

struct CandidateScore: Codable, Sendable, Equatable, Hashable {
    let durationScore: Double
    let energyScore: Double
    let accessScore: Double
    let goalContributionScore: Double
    let deadlineContributionScore: Double
    let futurePressureScore: Double
    let opportunityCostScore: Double
    let approvalRequirementScore: Double
    let validityScore: Double
    let factorEvidenceScore: Double
    let evidenceFactorIDs: [String]
    let total: Double

    init(
        durationScore: Double,
        energyScore: Double,
        accessScore: Double,
        goalContributionScore: Double,
        deadlineContributionScore: Double,
        futurePressureScore: Double,
        opportunityCostScore: Double,
        approvalRequirementScore: Double,
        validityScore: Double,
        factorEvidenceScore: Double,
        evidenceFactorIDs: [String] = []
    ) {
        self.durationScore = Self.clamp(durationScore)
        self.energyScore = Self.clamp(energyScore)
        self.accessScore = Self.clamp(accessScore)
        self.goalContributionScore = Self.clamp(goalContributionScore)
        self.deadlineContributionScore = Self.clamp(deadlineContributionScore)
        self.futurePressureScore = Self.clamp(futurePressureScore)
        self.opportunityCostScore = Self.clamp(opportunityCostScore)
        self.approvalRequirementScore = Self.clamp(approvalRequirementScore)
        self.validityScore = Self.clamp(validityScore)
        self.factorEvidenceScore = Self.clamp(factorEvidenceScore)
        self.evidenceFactorIDs = Self.normalizedStrings(evidenceFactorIDs)
        total = (
            self.durationScore * 0.10 +
            self.energyScore * 0.12 +
            self.accessScore * 0.12 +
            self.goalContributionScore * 0.15 +
            self.deadlineContributionScore * 0.10 +
            self.futurePressureScore * 0.10 +
            self.opportunityCostScore * 0.10 +
            self.approvalRequirementScore * 0.06 +
            self.validityScore * 0.05 +
            self.factorEvidenceScore * 0.10
        )
        self.total = Self.clamp(total)
    }
}

struct CandidateRankingTrace: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let schemaVersion: String
    let generatedAt: String
    let selectedCandidateID: String
    let rankedCandidateIDs: [String]
    let rejectedCandidateIDs: [String]
    let duplicateRejectedCandidateIDs: [String]
    let sourceProvenance: [CandidateSource]
    let factorEvidenceIDs: [String]
    let replayReferenceID: String?
    let replayFingerprint: String?
    let semanticSummary: String
    let factorlessRanking: Bool

    init(
        generatedAt: String,
        selectedCandidateID: String,
        rankedCandidateIDs: [String],
        rejectedCandidateIDs: [String],
        duplicateRejectedCandidateIDs: [String] = [],
        sourceProvenance: [CandidateSource] = [],
        factorEvidenceIDs: [String] = [],
        replayReferenceID: String? = nil,
        replayFingerprint: String? = nil,
        semanticSummary: String,
        factorlessRanking: Bool
    ) {
        self.schemaVersion = stepCandidateFieldSchemaVersion
        self.generatedAt = Self.normalizedRequired(generatedAt)
        self.selectedCandidateID = Self.normalizedRequired(selectedCandidateID)
        self.rankedCandidateIDs = Self.normalizedStrings(rankedCandidateIDs)
        self.rejectedCandidateIDs = Self.normalizedStrings(rejectedCandidateIDs)
        self.duplicateRejectedCandidateIDs = Self.normalizedStrings(duplicateRejectedCandidateIDs)
        self.sourceProvenance = Array(Set(sourceProvenance)).sorted { $0.rawValue < $1.rawValue }
        self.factorEvidenceIDs = Self.normalizedStrings(factorEvidenceIDs)
        self.replayReferenceID = Self.normalizedOptional(replayReferenceID)
        self.replayFingerprint = Self.normalizedOptional(replayFingerprint)
        self.semanticSummary = Self.normalizedRequired(semanticSummary)
        self.factorlessRanking = factorlessRanking
        self.id = Self.stableIdentifier(
            prefix: "candidate-ranking-trace",
            components: [
                self.selectedCandidateID,
                self.replayFingerprint ?? "no-replay",
                self.generatedAt
            ]
        )
    }
}

struct StepCandidate: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let sourceStepID: String
    let sourceCandidateID: String?
    let source: CandidateSource
    let kind: StepCandidateKind
    let title: String
    let summary: String
    let accessibilitySummary: String
    let estimatedMinutes: Int
    let estimatedEnergyCost: Double
    let accessRequirements: [String]
    let equipmentRequirements: [String]
    let facilityRequirements: [String]
    let goalContribution: Double
    let deadlineContribution: Double
    let futurePressureImpact: Double
    let opportunityCost: Double
    let approvalRequired: Bool
    let validity: CandidateValidity
    let tradeoffs: [CandidateTradeoff]
    let rejectionRisk: CandidateRejectionRisk
    let score: CandidateScore
    let normalizedSemanticSignature: String

    init(
        sourceStepID: String,
        sourceCandidateID: String? = nil,
        source: CandidateSource,
        kind: StepCandidateKind,
        title: String,
        summary: String,
        accessibilitySummary: String,
        estimatedMinutes: Int,
        estimatedEnergyCost: Double,
        accessRequirements: [String] = [],
        equipmentRequirements: [String] = [],
        facilityRequirements: [String] = [],
        goalContribution: Double,
        deadlineContribution: Double,
        futurePressureImpact: Double,
        opportunityCost: Double,
        approvalRequired: Bool,
        validity: CandidateValidity,
        tradeoffs: [CandidateTradeoff] = [],
        rejectionRisk: CandidateRejectionRisk,
        evidenceFactorIDs: [String] = [],
        semanticAnchor: String
    ) {
        self.sourceStepID = Self.normalizedRequired(sourceStepID)
        self.sourceCandidateID = Self.normalizedOptional(sourceCandidateID)
        self.source = source
        self.kind = kind
        self.title = Self.normalizedRequired(title)
        self.summary = Self.normalizedRequired(summary)
        self.accessibilitySummary = Self.normalizedRequired(accessibilitySummary)
        self.estimatedMinutes = max(0, estimatedMinutes)
        self.estimatedEnergyCost = Self.clamp(estimatedEnergyCost, lowerBound: 0, upperBound: 1)
        self.accessRequirements = Self.normalizedStrings(accessRequirements)
        self.equipmentRequirements = Self.normalizedStrings(equipmentRequirements)
        self.facilityRequirements = Self.normalizedStrings(facilityRequirements)
        self.goalContribution = Self.clamp(goalContribution)
        self.deadlineContribution = Self.clamp(deadlineContribution)
        self.futurePressureImpact = Self.clamp(futurePressureImpact)
        self.opportunityCost = Self.clamp(opportunityCost)
        self.approvalRequired = approvalRequired
        self.validity = validity
        self.tradeoffs = tradeoffs
        self.rejectionRisk = rejectionRisk

        let normalizedSemanticSignature = Self.semanticSignature(
            semanticAnchor: semanticAnchor,
            kind: kind,
            title: self.title,
            summary: self.summary,
            accessRequirements: self.accessRequirements,
            equipmentRequirements: self.equipmentRequirements,
            facilityRequirements: self.facilityRequirements,
            estimatedMinutes: self.estimatedMinutes,
            estimatedEnergyCost: self.estimatedEnergyCost,
            goalContribution: self.goalContribution,
            deadlineContribution: self.deadlineContribution,
            futurePressureImpact: self.futurePressureImpact,
            opportunityCost: self.opportunityCost,
            approvalRequired: self.approvalRequired,
            validity: validity,
            evidenceFactorIDs: evidenceFactorIDs
        )
        self.normalizedSemanticSignature = normalizedSemanticSignature
        self.id = Self.stableIdentifier(
            prefix: "step-candidate",
            components: [
                kind.rawValue,
                self.sourceStepID,
                normalizedSemanticSignature
            ]
        )
        self.score = CandidateScore(
            durationScore: Self.durationScore(for: estimatedMinutes, kind: kind),
            energyScore: Self.energyScore(for: kind, estimatedEnergyCost: self.estimatedEnergyCost),
            accessScore: Self.accessScore(
                kind: kind,
                accessRequirements: self.accessRequirements,
                equipmentRequirements: self.equipmentRequirements,
                facilityRequirements: self.facilityRequirements
            ),
            goalContributionScore: self.goalContribution,
            deadlineContributionScore: self.deadlineContribution,
            futurePressureScore: self.futurePressureImpact,
            opportunityCostScore: 1 - self.opportunityCost,
            approvalRequirementScore: approvalRequired ? 0.35 : 1,
            validityScore: Self.validityScore(for: validity),
            factorEvidenceScore: Self.factorEvidenceScore(for: evidenceFactorIDs),
            evidenceFactorIDs: evidenceFactorIDs
        )
    }
}

struct StepCandidateField: Codable, Sendable, Equatable, Hashable, Identifiable {
    let schemaVersion: String
    let id: String
    let goalID: String?
    let deadlineTargetDate: String?
    let generatedAt: String
    let sourceProvenance: [CandidateSource]
    let candidates: [StepCandidate]
    let rankingTrace: CandidateRankingTrace
    let localOnly: Bool

    init(
        goalID: String? = nil,
        deadlineTargetDate: String? = nil,
        generatedAt: String,
        sourceProvenance: [CandidateSource] = [],
        candidates: [StepCandidate],
        rankingTrace: CandidateRankingTrace,
        localOnly: Bool = true
    ) {
        self.schemaVersion = stepCandidateFieldSchemaVersion
        self.goalID = Self.normalizedOptional(goalID)
        self.deadlineTargetDate = Self.normalizedOptional(deadlineTargetDate)
        self.generatedAt = Self.normalizedRequired(generatedAt)
        self.sourceProvenance = Array(Set(sourceProvenance)).sorted { $0.rawValue < $1.rawValue }
        self.candidates = candidates
        self.rankingTrace = rankingTrace
        self.localOnly = localOnly
        self.id = Self.stableIdentifier(
            prefix: "step-candidate-field",
            components: [
                self.goalID ?? "unscoped",
                self.deadlineTargetDate ?? "no-deadline",
                self.generatedAt,
                rankingTrace.selectedCandidateID
            ]
        )
    }

    var selectedCandidate: StepCandidate? {
        candidates.first(where: { $0.id == rankingTrace.selectedCandidateID })
    }

    var selectedCandidateID: String {
        rankingTrace.selectedCandidateID
    }

    var rejectedCandidates: [StepCandidate] {
        let rejectedIDs = Set(rankingTrace.rejectedCandidateIDs)
        return candidates.filter { rejectedIDs.contains($0.id) }
    }

    var candidateIDs: [String] {
        candidates.map(\.id)
    }
}

struct CandidateGenerationContext: Sendable, Equatable {
    let goalID: String?
    let deadlineTargetDate: String?
    let compilerOutput: GoalIntentDayCompilerOutput?
    let runtimeOutput: PrivateLifeRuntimeKernelDecisionOutput?
    let decisionRecord: PrivateLifeRuntimeKernelDecisionRecord?
    let replayTrace: ReplayableDecisionTrace?
    let factorLedger: PersonalizationFactorLedger?
    let lifeContextProjection: LifeContextRuntimeProjection?
    let generatedAt: String
    let candidateLimit: Int
    let localOnly: Bool

    init(
        goalID: String? = nil,
        deadlineTargetDate: String? = nil,
        compilerOutput: GoalIntentDayCompilerOutput? = nil,
        runtimeOutput: PrivateLifeRuntimeKernelDecisionOutput? = nil,
        decisionRecord: PrivateLifeRuntimeKernelDecisionRecord? = nil,
        replayTrace: ReplayableDecisionTrace? = nil,
        factorLedger: PersonalizationFactorLedger? = nil,
        lifeContextProjection: LifeContextRuntimeProjection? = nil,
        generatedAt: String,
        candidateLimit: Int = 24,
        localOnly: Bool = true
    ) {
        self.goalID = Self.normalizedOptional(goalID)
        self.deadlineTargetDate = Self.normalizedOptional(deadlineTargetDate)
        self.compilerOutput = compilerOutput
        self.runtimeOutput = runtimeOutput
        self.decisionRecord = decisionRecord
        self.replayTrace = replayTrace
        self.factorLedger = factorLedger
        self.lifeContextProjection = lifeContextProjection
        self.generatedAt = Self.normalizedRequired(generatedAt)
        self.candidateLimit = max(1, candidateLimit)
        self.localOnly = localOnly
    }

    var resolvedFactorLedger: PersonalizationFactorLedger? {
        factorLedger ?? runtimeOutput?.personalizationFactorLedger ?? decisionRecord?.personalizationFactorLedger ?? replayTrace?.personalizationFactorLedger
    }

    var sourceProvenance: [CandidateSource] {
        var sources: [CandidateSource] = []
        if compilerOutput != nil {
            sources.append(.goalIntentCompiler)
        } else {
            sources.append(.fallback)
        }
        if runtimeOutput != nil || decisionRecord != nil {
            sources.append(.privateLifeRuntime)
        }
        if replayTrace != nil {
            sources.append(.replayTrace)
        }
        if resolvedFactorLedger != nil {
            sources.append(.personalizationFactorLedger)
        }
        return Array(Set(sources)).sorted { $0.rawValue < $1.rawValue }
    }
}

private extension CandidateScore {
    static func clamp(_ value: Double) -> Double {
        Self.clamp(value, lowerBound: 0, upperBound: 1)
    }

    static func clamp(_ value: Double, lowerBound: Double, upperBound: Double) -> Double {
        guard upperBound >= lowerBound else { return lowerBound }
        return min(max(value, lowerBound), upperBound)
    }

    static func normalizedStrings(_ values: [String]) -> [String] {
        values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
            .removingDuplicates()
            .sorted()
    }
}

private extension CandidateValidity {
    static func normalized(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

private extension CandidateSource {
    static func normalizedRequired(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        precondition(trimmed.isEmpty == false, "Expected a non-empty string")
        return trimmed
    }

    static func normalizedOptional(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    static func normalizedStrings(_ values: [String]) -> [String] {
        values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
            .removingDuplicates()
            .sorted()
    }

    static func clamp(_ value: Double, lowerBound: Double, upperBound: Double) -> Double {
        guard upperBound >= lowerBound else { return lowerBound }
        return min(max(value, lowerBound), upperBound)
    }

    static func stableIdentifier(prefix: String, components: [String]) -> String {
        let seed = components
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
            .joined(separator: "|")
        let hashed = stableHash(seed)
        return "\(prefix).\(hashed)"
    }

    static func stableHash(_ value: String) -> String {
        var hash: UInt64 = 14_695_981_039_346_656_037
        for byte in value.utf8 {
            hash ^= UInt64(byte)
            hash &*= 1_099_511_628_211
        }
        return String(hash, radix: 16, uppercase: false)
    }
}

private extension StepCandidate {
    static func normalizedRequired(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        precondition(trimmed.isEmpty == false, "Expected a non-empty string")
        return trimmed
    }

    static func normalizedOptional(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    static func normalizedStrings(_ values: [String]) -> [String] {
        values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
            .removingDuplicates()
            .sorted()
    }

    static func clamp(_ value: Double, lowerBound: Double = 0, upperBound: Double = 1) -> Double {
        guard upperBound >= lowerBound else { return lowerBound }
        return min(max(value, lowerBound), upperBound)
    }

    static func stableIdentifier(prefix: String, components: [String]) -> String {
        CandidateSource.stableIdentifier(prefix: prefix, components: components)
    }

    static func semanticSignature(
        semanticAnchor: String,
        kind: StepCandidateKind,
        title: String,
        summary: String,
        accessRequirements: [String],
        equipmentRequirements: [String],
        facilityRequirements: [String],
        estimatedMinutes: Int,
        estimatedEnergyCost: Double,
        goalContribution: Double,
        deadlineContribution: Double,
        futurePressureImpact: Double,
        opportunityCost: Double,
        approvalRequired: Bool,
        validity: CandidateValidity,
        evidenceFactorIDs: [String]
    ) -> String {
        [
            normalizedSemanticAnchor(semanticAnchor),
            normalizedSemanticAnchor(title),
            normalizedSemanticAnchor(summary),
            kind.rawValue,
            "minutes.\(durationBand(estimatedMinutes))",
            "energy.\(energyBand(estimatedEnergyCost))",
            "goal.\(band(goalContribution))",
            "deadline.\(band(deadlineContribution))",
            "pressure.\(band(futurePressureImpact))",
            "cost.\(band(opportunityCost))",
            approvalRequired ? "approval.required" : "approval.not_required",
            "validity.\(validity.rawValue)",
            "access.\(normalizedSemanticAnchor(accessRequirements.joined(separator: " ")))",
            "equipment.\(normalizedSemanticAnchor(equipmentRequirements.joined(separator: " ")))",
            "facility.\(normalizedSemanticAnchor(facilityRequirements.joined(separator: " ")))",
            evidenceFactorIDs.sorted().joined(separator: ",")
        ]
        .joined(separator: "|")
    }

    static func normalizedSemanticAnchor(_ value: String) -> String {
        let stopWords: Set<String> = [
            "a", "an", "and", "as", "at", "best", "by", "do", "for", "from", "in", "into", "it", "make", "now", "of", "on", "or", "path", "phase", "plan", "step", "the", "to", "today", "try", "up", "version", "work"
        ]

        let tokens = value
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false && stopWords.contains($0) == false }

        return tokens.joined(separator: ".")
    }

    static func durationBand(_ value: Int) -> String {
        switch value {
        case ..<6:
            return "micro"
        case ..<12:
            return "short"
        case ..<20:
            return "brief"
        case ..<35:
            return "standard"
        default:
            return "extended"
        }
    }

    static func energyBand(_ value: Double) -> String {
        switch value {
        case ..<0.2:
            return "very_low"
        case ..<0.4:
            return "low"
        case ..<0.6:
            return "moderate"
        case ..<0.8:
            return "high"
        default:
            return "very_high"
        }
    }

    static func band(_ value: Double) -> String {
        switch value {
        case ..<0.2:
            return "very_low"
        case ..<0.4:
            return "low"
        case ..<0.6:
            return "moderate"
        case ..<0.8:
            return "high"
        default:
            return "very_high"
        }
    }

    static func durationScore(for estimatedMinutes: Int, kind: StepCandidateKind) -> Double {
        let base: Double
        switch estimatedMinutes {
        case ..<6:
            base = 1
        case ..<12:
            base = 0.95
        case ..<20:
            base = 0.8
        case ..<35:
            base = 0.65
        default:
            base = 0.45
        }

        switch kind {
        case .shorter, .proofGathering, .fallback:
            return min(1, base + 0.08)
        case .lighter, .lowerEnergy, .maintenance, .parallelPath:
            return min(1, base + 0.03)
        default:
            return base
        }
    }

    static func energyScore(for kind: StepCandidateKind, estimatedEnergyCost: Double) -> Double {
        let baseline = 1 - clamp(estimatedEnergyCost, lowerBound: 0, upperBound: 1)
        switch kind {
        case .lighter, .shorter, .lowerEnergy, .recoverySafe, .fallback:
            return min(1, baseline + 0.1)
        case .maintenance, .proofGathering, .prerequisite:
            return min(1, baseline + 0.04)
        default:
            return baseline
        }
    }

    static func accessScore(
        kind: StepCandidateKind,
        accessRequirements: [String],
        equipmentRequirements: [String],
        facilityRequirements: [String]
    ) -> Double {
        let burden = Double(accessRequirements.count + equipmentRequirements.count + facilityRequirements.count)
        let baseline = clamp(1 - (burden * 0.12), lowerBound: 0, upperBound: 1)
        switch kind {
        case .locationCompatible, .noEquipment, .substitution, .parallelPath, .fallback:
            return min(1, baseline + 0.08)
        case .adminSetup, .maintenance:
            return min(1, baseline + 0.03)
        default:
            return baseline
        }
    }

    static func validityScore(for validity: CandidateValidity) -> Double {
        switch validity {
        case .preferred:
            return 1
        case .review:
            return 0.72
        case .fallback:
            return 0.5
        case .blocked:
            return 0.18
        case .rejected:
            return 0
        }
    }

    static func factorEvidenceScore(for evidenceFactorIDs: [String]) -> Double {
        guard evidenceFactorIDs.isEmpty == false else {
            return 0
        }

        return min(1, Double(evidenceFactorIDs.count) / 5)
    }
}

private extension CandidateGenerationContext {
    static func normalizedRequired(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        precondition(trimmed.isEmpty == false, "Expected a non-empty string")
        return trimmed
    }

    static func normalizedOptional(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

private extension StepCandidateField {
    static func normalizedRequired(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        precondition(trimmed.isEmpty == false, "Expected a non-empty string")
        return trimmed
    }

    static func normalizedOptional(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    static func normalizedStrings(_ values: [String]) -> [String] {
        values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
            .removingDuplicates()
            .sorted()
    }

    static func stableIdentifier(prefix: String, components: [String]) -> String {
        CandidateSource.stableIdentifier(prefix: prefix, components: components)
    }
}

private extension CandidateRankingTrace {
    static func normalizedRequired(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        precondition(trimmed.isEmpty == false, "Expected a non-empty string")
        return trimmed
    }

    static func normalizedOptional(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    static func normalizedStrings(_ values: [String]) -> [String] {
        values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
            .removingDuplicates()
            .sorted()
    }

    static func stableIdentifier(prefix: String, components: [String]) -> String {
        CandidateSource.stableIdentifier(prefix: prefix, components: components)
    }
}

private extension CandidateTradeoff {
    static func normalizedRequired(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        precondition(trimmed.isEmpty == false, "Expected a non-empty string")
        return trimmed
    }

    static func normalizedOptional(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    static func normalizedStrings(_ values: [String]) -> [String] {
        values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
            .removingDuplicates()
            .sorted()
    }
}

private extension CandidateRejectionRisk {
    static func normalizedRequired(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        precondition(trimmed.isEmpty == false, "Expected a non-empty string")
        return trimmed
    }

    static func normalizedOptional(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    static func normalizedStrings(_ values: [String]) -> [String] {
        values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
            .removingDuplicates()
            .sorted()
    }

    static func stableIdentifier(prefix: String, components: [String]) -> String {
        CandidateSource.stableIdentifier(prefix: prefix, components: components)
    }
}

private extension Array where Element == String {
    func removingDuplicates() -> [String] {
        var seen: Set<String> = []
        return filter { seen.insert($0).inserted }
    }
}
