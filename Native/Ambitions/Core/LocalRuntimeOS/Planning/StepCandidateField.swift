import Foundation

struct StepCandidateField: Codable, Sendable, Equatable, Hashable, Identifiable {
    let schemaVersion: String
    let id: String
    let goalID: String?
    let deadlineTargetDate: String?
    let generatedAt: String
    let sourceProvenance: [CandidateSource]
    let candidates: [StepCandidate]
    let rankingTrace: CandidateRankingTrace
    let sourceAtlasExpansionTrace: SourceAtlasStepExpansionTrace?
    let localOnly: Bool

    init(
        goalID: String? = nil,
        deadlineTargetDate: String? = nil,
        generatedAt: String,
        sourceProvenance: [CandidateSource] = [],
        candidates: [StepCandidate],
        rankingTrace: CandidateRankingTrace,
        sourceAtlasExpansionTrace: SourceAtlasStepExpansionTrace? = nil,
        localOnly: Bool = true
    ) {
        self.schemaVersion = stepCandidateFieldSchemaVersion
        self.goalID = Self.normalizedOptional(goalID)
        self.deadlineTargetDate = Self.normalizedOptional(deadlineTargetDate)
        self.generatedAt = Self.normalizedRequired(generatedAt)
        self.sourceProvenance = Array(Set(sourceProvenance)).sorted { $0.rawValue < $1.rawValue }
        self.candidates = candidates
        self.rankingTrace = rankingTrace
        self.sourceAtlasExpansionTrace = sourceAtlasExpansionTrace ?? rankingTrace.sourceAtlasExpansionTrace
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
        let rejectedIDs = Set(rankingTrace.rejectedCandidateIDs + rankingTrace.suppressedRejectedCandidateIDs)
        return candidates.filter { rejectedIDs.contains($0.id) }
    }

    var candidateIDs: [String] {
        candidates.map(\.id)
    }
}

struct CandidateGenerationContext: Sendable {
    let goalID: String?
    let deadlineTargetDate: String?
    let compilerOutput: GoalIntentDayCompilerOutput?
    let runtimeOutput: PrivateLifeRuntimeKernelDecisionOutput?
    let decisionRecord: PrivateLifeRuntimeKernelDecisionRecord?
    let replayTrace: ReplayableDecisionTrace?
    let factorLedger: PersonalizationFactorLedger?
    let lifeContextProjection: LifeContextRuntimeProjection?
    let rejectionHistory: [StepCandidateRejectionRecord]
    let sourceAtlasExpansionTrace: SourceAtlasStepExpansionTrace?
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
        rejectionHistory: [StepCandidateRejectionRecord] = [],
        sourceAtlasExpansionTrace: SourceAtlasStepExpansionTrace? = nil,
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
        self.rejectionHistory = rejectionHistory
        self.sourceAtlasExpansionTrace = sourceAtlasExpansionTrace
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
        if sourceAtlasExpansionTrace != nil {
            sources.append(.sourceAtlasPathComposition)
            sources.append(.sourceAtlasPack)
            sources.append(.sourceAtlasStepCandidateSeed)
        }
        return Array(Set(sources)).sorted { $0.rawValue < $1.rawValue }
    }

    var contextFingerprint: String {
        CandidateSource.stableIdentifier(
            prefix: "step-candidate-context",
            components: [
                goalID ?? "unscoped",
                deadlineTargetDate ?? "no-deadline",
                compilerOutputFingerprint,
                runtimeFingerprint,
                decisionFingerprint,
                replayFingerprint,
                factorFingerprint,
                lifeContextFingerprint
            ]
        )
    }

    var relevantRejectionHistory: [StepCandidateRejectionRecord] {
        rejectionHistory.filter { $0.contextFingerprint == contextFingerprint }
    }

    var compilerOutputFingerprint: String {
        guard let compilerOutput else { return "compiler.none" }
        return CandidateSource.stableIdentifier(
            prefix: "compiler",
            components: [
                compilerOutput.intent.id,
                compilerOutput.compiledAt,
                compilerOutput.status.rawValue,
                compilerOutput.compiledSteps.map { "\($0.id):\($0.title):\($0.orderIndex)" }.joined(separator: "|"),
                compilerOutput.blockedReasons.map(\.kind.rawValue).joined(separator: ",")
            ]
        )
    }

    var runtimeFingerprint: String {
        runtimeOutput?.personalizationFactorLedger.replayProjection.stableFingerprint ?? "runtime.none"
    }

    var decisionFingerprint: String {
        decisionRecord?.personalizationFactorLedger.replayProjection.stableFingerprint ?? "decision.none"
    }

    var replayFingerprint: String {
        replayTrace?.personalizationFactorLedger.replayProjection.stableFingerprint ?? "replay.none"
    }

    var factorFingerprint: String {
        resolvedFactorLedger?.replayProjection.stableFingerprint ?? "factors.none"
    }

    var lifeContextFingerprint: String {
        guard let lifeContextProjection else { return "life.none" }
        let signature = [
            lifeContextProjection.lifeStage.rawValue,
            lifeContextProjection.availableOpportunityAnchors.map(\.id).sorted().joined(separator: ","),
            lifeContextProjection.hardConstraints.map(\.id).sorted().joined(separator: ","),
            lifeContextProjection.softConstraints.map(\.id).sorted().joined(separator: ","),
            lifeContextProjection.travelModel.transportationAccess.rawValue,
            lifeContextProjection.travelModel.locationPrecision.rawValue,
            lifeContextProjection.eligibilityModel.map(\.id).sorted().joined(separator: ","),
            lifeContextProjection.historySummary.map { "\($0.id):\($0.freshness.rawValue)" }.sorted().joined(separator: ","),
            lifeContextProjection.excludedHistorySummary.map { "\($0.id):\($0.reason.rawValue)" }.sorted().joined(separator: ","),
            lifeContextProjection.sourceFreshnessSummary.map { "\($0.sourceID):\($0.freshness.rawValue)" }.sorted().joined(separator: ","),
            lifeContextProjection.sensitiveUseWarnings.map(\.factID).sorted().joined(separator: ","),
            lifeContextProjection.missingContextQuestions.map(\.id).sorted().joined(separator: ",")
        ].joined(separator: "|")
        return CandidateSource.stableIdentifier(prefix: "life-context", components: [signature])
    }
}

extension CandidateScore {
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

extension StepImpactSimulation {
    static func clamp(_ value: Double) -> Double {
        min(max(value, 0), 1)
    }
}

extension CandidateValidity {
    static func normalized(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

extension CandidateSource {
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

extension CandidateSource {
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

}
