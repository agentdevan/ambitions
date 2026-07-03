import Foundation

enum StepQualityDecision: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case accept
    case degrade
    case reject
}

enum StepQualityStatus: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case green
    case yellow
    case red
}

enum StepQualityBlockingCode: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case genericStep = "generic_step"
    case genericPattern = "generic_pattern"
    case ambiguousStep = "ambiguous_step"
    case shameLanguage = "shame_language"
    case overlongStep = "overlong_step"
    case unsafeStep = "unsafe_step"
    case staleSource = "stale_source"
    case highRiskNeedsReview = "high_risk_needs_review"
    case inaccessibleStep = "inaccessible_step"
    case nonElasticStep = "non_elastic_step"
    case missingRepairPath = "missing_repair_path"
    case missingSourceRecord = "missing_source_record"
    case missingReceipt = "missing_receipt"
    case missingReplayTrace = "missing_replay_trace"
    case nonLocalRuntimeBoundary = "non_local_runtime_boundary"
    case silentMutationRisk = "silent_mutation_risk"
}

enum StepQualitySourceState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case officialCurrent = "official_current"
    case maintainerCurated = "maintainer_curated"
    case localProofOnly = "local_proof_only"
    case starterGuidanceOnly = "starter_guidance_only"
    case sourceNeeded = "source_needed"
    case reviewRequired = "review_required"
    case stale
    case sourceChanged = "source_changed"
    case contradicted
    case revoked
    case blocked
    case unknown

    var isEligibleForVisibleStep: Bool {
        switch self {
        case .officialCurrent, .maintainerCurated, .localProofOnly, .starterGuidanceOnly:
            return true
        case .sourceNeeded, .reviewRequired, .stale, .sourceChanged, .contradicted, .revoked, .blocked, .unknown:
            return false
        }
    }
}

enum StepQualityRiskLevel: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case low
    case moderate
    case high
}

enum ProtectedStepSurface: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case today
    case goals
    case sharing
    case yearInAmbitions = "year_in_ambitions"
    case widget
    case appIntent = "app_intent"
}

struct StepQualityRepairPath: Codable, Sendable, Equatable, Hashable {
    let owner: String
    let fallback: String
    let annotationCode: String

    init(owner: String, fallback: String, annotationCode: String) {
        self.owner = owner.trimmingCharacters(in: .whitespacesAndNewlines)
        self.fallback = fallback.trimmingCharacters(in: .whitespacesAndNewlines)
        self.annotationCode = annotationCode.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isUsable: Bool {
        owner.isEmpty == false && fallback.isEmpty == false && annotationCode.isEmpty == false
    }
}

struct StepQualityAccessibilitySemantics: Codable, Sendable, Equatable, Hashable {
    let voiceOverLabel: String
    let voiceOverValue: String
    let voiceOverHint: String
    let nonVisualSummary: String
    let visualOnlyMeaning: Bool
    let supportsDynamicType: Bool
    let supportsReduceMotion: Bool

    init(
        voiceOverLabel: String,
        voiceOverValue: String,
        voiceOverHint: String,
        nonVisualSummary: String,
        visualOnlyMeaning: Bool = false,
        supportsDynamicType: Bool = true,
        supportsReduceMotion: Bool = true
    ) {
        self.voiceOverLabel = voiceOverLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        self.voiceOverValue = voiceOverValue.trimmingCharacters(in: .whitespacesAndNewlines)
        self.voiceOverHint = voiceOverHint.trimmingCharacters(in: .whitespacesAndNewlines)
        self.nonVisualSummary = nonVisualSummary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.visualOnlyMeaning = visualOnlyMeaning
        self.supportsDynamicType = supportsDynamicType
        self.supportsReduceMotion = supportsReduceMotion
    }
}

struct StepQualityElasticityCoverage: Codable, Sendable, Equatable, Hashable {
    let minimumViable: Bool
    let standard: Bool
    let proofOnly: Bool
    let recoverySafe: Bool
    let replacement: Bool
    let split: Bool
    let merge: Bool

    init(
        minimumViable: Bool,
        standard: Bool,
        proofOnly: Bool,
        recoverySafe: Bool,
        replacement: Bool,
        split: Bool = false,
        merge: Bool = false
    ) {
        self.minimumViable = minimumViable
        self.standard = standard
        self.proofOnly = proofOnly
        self.recoverySafe = recoverySafe
        self.replacement = replacement
        self.split = split
        self.merge = merge
    }

    var coversVisibleStepRequirement: Bool {
        minimumViable && standard && proofOnly && recoverySafe && replacement
    }
}

struct StepQualitySourceAuthority: Codable, Sendable, Equatable, Hashable {
    let state: StepQualitySourceState
    let sourceRecordIDs: [String]
    let freshnessState: String
    let reviewState: String
    let riskLevel: StepQualityRiskLevel
    let runtimeEligible: Bool

    init(
        state: StepQualitySourceState,
        sourceRecordIDs: [String],
        freshnessState: String,
        reviewState: String,
        riskLevel: StepQualityRiskLevel,
        runtimeEligible: Bool
    ) {
        self.state = state
        self.sourceRecordIDs = Self.normalized(sourceRecordIDs)
        self.freshnessState = freshnessState.trimmingCharacters(in: .whitespacesAndNewlines)
        self.reviewState = reviewState.trimmingCharacters(in: .whitespacesAndNewlines)
        self.riskLevel = riskLevel
        self.runtimeEligible = runtimeEligible
    }

    private static func normalized(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct StepQualityProofExpectation: Codable, Sendable, Equatable, Hashable {
    let primitive: String
    let receiptIDs: [String]
    let proofTraceID: String?
    let replayTraceID: String?

    init(primitive: String, receiptIDs: [String], proofTraceID: String?, replayTraceID: String?) {
        self.primitive = primitive.trimmingCharacters(in: .whitespacesAndNewlines)
        self.receiptIDs = Self.normalized(receiptIDs)
        self.proofTraceID = Self.normalizedOptional(proofTraceID)
        self.replayTraceID = Self.normalizedOptional(replayTraceID)
    }

    private static func normalized(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }

    private static func normalizedOptional(_ value: String?) -> String? {
        guard let normalized = value?.trimmingCharacters(in: .whitespacesAndNewlines), normalized.isEmpty == false else {
            return nil
        }
        return normalized
    }
}

struct StepQualityInput: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let stepText: String
    let actionVerb: String
    let object: String
    let durationMinutes: Int
    let protectedSurfaces: [ProtectedStepSurface]
    let sourceAuthority: StepQualitySourceAuthority
    let proofExpectation: StepQualityProofExpectation
    let accessibility: StepQualityAccessibilitySemantics
    let elasticityCoverage: StepQualityElasticityCoverage
    let repairPath: StepQualityRepairPath?
    let localOnly: Bool
    let highRiskDomain: Bool
    let highRiskReviewApproved: Bool
    let unsafeDomainFlag: Bool
    let mutatesPlansSilently: Bool

    init(
        id: String,
        stepText: String,
        actionVerb: String,
        object: String,
        durationMinutes: Int,
        protectedSurfaces: [ProtectedStepSurface],
        sourceAuthority: StepQualitySourceAuthority,
        proofExpectation: StepQualityProofExpectation,
        accessibility: StepQualityAccessibilitySemantics,
        elasticityCoverage: StepQualityElasticityCoverage,
        repairPath: StepQualityRepairPath?,
        localOnly: Bool = true,
        highRiskDomain: Bool = false,
        highRiskReviewApproved: Bool = false,
        unsafeDomainFlag: Bool = false,
        mutatesPlansSilently: Bool = false
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.stepText = stepText.trimmingCharacters(in: .whitespacesAndNewlines)
        self.actionVerb = actionVerb.trimmingCharacters(in: .whitespacesAndNewlines)
        self.object = object.trimmingCharacters(in: .whitespacesAndNewlines)
        self.durationMinutes = max(0, durationMinutes)
        self.protectedSurfaces = Array(Set(protectedSurfaces)).sorted { $0.rawValue < $1.rawValue }
        self.sourceAuthority = sourceAuthority
        self.proofExpectation = proofExpectation
        self.accessibility = accessibility
        self.elasticityCoverage = elasticityCoverage
        self.repairPath = repairPath
        self.localOnly = localOnly
        self.highRiskDomain = highRiskDomain
        self.highRiskReviewApproved = highRiskReviewApproved
        self.unsafeDomainFlag = unsafeDomainFlag
        self.mutatesPlansSilently = mutatesPlansSilently
    }
}

struct StepQualityVerdict: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let candidateId: String
    let decision: StepQualityDecision
    let status: StepQualityStatus
    let blockingCodes: [StepQualityBlockingCode]
    let repairPath: StepQualityRepairPath?
    let proofBoundary: String
    let downstreamConsumers: [ProtectedStepSurface]

    var canBecomeVisibleStep: Bool {
        decision == .accept && status == .green && blockingCodes.isEmpty
    }
}

struct RecommendedStepEligibility: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let candidateId: String
    let visibleStepText: String
    let protectedSurfaces: [ProtectedStepSurface]
    let canShow: Bool
    let verdict: StepQualityVerdict
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceID: String?
    let whatAmbitionsKnowsRoute: String
}

struct StepQualityFirewall: Sendable, Equatable {
    let maximumVisibleStepMinutes: Int
    let maximumVisibleStepCharacters: Int

    init(maximumVisibleStepMinutes: Int = 45, maximumVisibleStepCharacters: Int = 120) {
        self.maximumVisibleStepMinutes = maximumVisibleStepMinutes
        self.maximumVisibleStepCharacters = maximumVisibleStepCharacters
    }

    func evaluate(_ input: StepQualityInput) -> RecommendedStepEligibility {
        let blockingCodes = blockingCodes(for: input)
        let decision: StepQualityDecision = blockingCodes.isEmpty ? .accept : .reject
        let repairPath = input.repairPath?.isUsable == true ? input.repairPath : nil
        let status: StepQualityStatus
        if blockingCodes.isEmpty {
            status = .green
        } else if repairPath == nil {
            status = .red
        } else {
            status = .yellow
        }
        let allCodes = normalizedCodes(blockingCodes + (blockingCodes.isEmpty == false && repairPath == nil ? [.missingRepairPath] : []))
        let verdict = StepQualityVerdict(
            id: verdictIdentifier(input: input, codes: allCodes, decision: decision, status: status),
            candidateId: input.id,
            decision: decision,
            status: status,
            blockingCodes: allCodes,
            repairPath: repairPath,
            proofBoundary: "SourceRecord + Receipt + ReplayTrace + local StepQualityFirewall",
            downstreamConsumers: input.protectedSurfaces
        )
        return RecommendedStepEligibility(
            id: "recommended-step-eligibility.\(verdict.id)",
            candidateId: input.id,
            visibleStepText: input.stepText,
            protectedSurfaces: input.protectedSurfaces,
            canShow: verdict.canBecomeVisibleStep,
            verdict: verdict,
            sourceRecordIDs: input.sourceAuthority.sourceRecordIDs,
            receiptIDs: input.proofExpectation.receiptIDs,
            replayTraceID: input.proofExpectation.replayTraceID,
            whatAmbitionsKnowsRoute: "you://what-ambitions-knows/recommended-step/\(input.id)"
        )
    }

    func evaluate(_ inputs: [StepQualityInput]) -> [RecommendedStepEligibility] {
        inputs.sorted { $0.id < $1.id }.map(evaluate)
    }

    private func blockingCodes(for input: StepQualityInput) -> [StepQualityBlockingCode] {
        var codes: Set<StepQualityBlockingCode> = []
        let normalizedStep = normalized(input.stepText)
        let normalizedObject = normalized(input.object)
        let normalizedVerb = normalized(input.actionVerb)

        if normalizedVerb.isEmpty {
            codes.insert(.ambiguousStep)
        }
        if normalizedObject.isEmpty || Self.genericObjects.contains(normalizedObject) {
            codes.insert(.ambiguousStep)
        }
        if Self.blockedGenericPhrases.contains(normalizedStep) || Self.blockedGenericPhrases.contains(where: { normalizedStep.contains($0) && $0.contains(" ") }) {
            codes.insert(.genericStep)
        }
        if Self.genericVerbs.contains(normalizedVerb) && Self.genericObjects.contains(normalizedObject) {
            codes.insert(.genericPattern)
        }
        if Self.ambiguousPhrases.contains(where: { normalizedStep.contains($0) }) {
            codes.insert(.ambiguousStep)
        }
        if Self.shamePhrases.contains(where: { normalizedStep.contains($0) }) {
            codes.insert(.shameLanguage)
        }
        if input.durationMinutes > maximumVisibleStepMinutes || input.stepText.count > maximumVisibleStepCharacters {
            codes.insert(.overlongStep)
        }
        if input.unsafeDomainFlag || Self.unsafePhrases.contains(where: { normalizedStep.contains($0) }) {
            codes.insert(.unsafeStep)
        }
        if input.sourceAuthority.state.isEligibleForVisibleStep == false ||
            input.sourceAuthority.runtimeEligible == false ||
            normalized(input.sourceAuthority.freshnessState).contains("stale") ||
            normalized(input.sourceAuthority.reviewState).contains("blocked") {
            codes.insert(.staleSource)
        }
        if input.highRiskDomain && input.highRiskReviewApproved == false {
            codes.insert(.highRiskNeedsReview)
        }
        if accessibilityIsUnsafe(input.accessibility, stepText: input.stepText) {
            codes.insert(.inaccessibleStep)
        }
        if input.elasticityCoverage.coversVisibleStepRequirement == false {
            codes.insert(.nonElasticStep)
        }
        if input.sourceAuthority.sourceRecordIDs.isEmpty {
            codes.insert(.missingSourceRecord)
        }
        if input.proofExpectation.receiptIDs.isEmpty {
            codes.insert(.missingReceipt)
        }
        if input.proofExpectation.replayTraceID == nil {
            codes.insert(.missingReplayTrace)
        }
        if input.localOnly == false {
            codes.insert(.nonLocalRuntimeBoundary)
        }
        if input.mutatesPlansSilently {
            codes.insert(.silentMutationRisk)
        }
        return normalizedCodes(Array(codes))
    }

    private func accessibilityIsUnsafe(_ accessibility: StepQualityAccessibilitySemantics, stepText: String) -> Bool {
        let genericLabels = Set(["step", "button", "action", "item", "open"])
        return accessibility.voiceOverLabel.isEmpty ||
            accessibility.voiceOverValue.isEmpty ||
            accessibility.voiceOverHint.isEmpty ||
            accessibility.nonVisualSummary.isEmpty ||
            accessibility.visualOnlyMeaning ||
            accessibility.supportsDynamicType == false ||
            accessibility.supportsReduceMotion == false ||
            genericLabels.contains(normalized(accessibility.voiceOverLabel)) ||
            normalized(accessibility.nonVisualSummary).contains(normalized(stepText)) == false
    }

    private func normalizedCodes(_ codes: [StepQualityBlockingCode]) -> [StepQualityBlockingCode] {
        Array(Set(codes)).sorted { $0.rawValue < $1.rawValue }
    }

    private func normalized(_ value: String) -> String {
        value
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.isEmpty == false }
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func verdictIdentifier(input: StepQualityInput, codes: [StepQualityBlockingCode], decision: StepQualityDecision, status: StepQualityStatus) -> String {
        [
            "step-quality",
            input.id,
            decision.rawValue,
            status.rawValue,
            codes.map(\.rawValue).joined(separator: ","),
            input.sourceAuthority.sourceRecordIDs.joined(separator: ","),
            input.proofExpectation.receiptIDs.joined(separator: ","),
            input.proofExpectation.replayTraceID ?? "missing-ReplayTrace"
        ]
        .joined(separator: ".")
    }

    private static let blockedGenericPhrases: Set<String> = [
        "work on your goal",
        "make progress",
        "research this",
        "review your plan",
        "continue",
        "do the next thing",
        "try to improve",
        "keep going",
        "make a plan",
        "work on it"
    ]

    private static let genericVerbs: Set<String> = [
        "work",
        "work on",
        "make",
        "handle",
        "deal with",
        "continue",
        "improve",
        "review",
        "research",
        "do"
    ]

    private static let genericObjects: Set<String> = [
        "it",
        "this",
        "that",
        "goal",
        "your goal",
        "plan",
        "your plan",
        "progress",
        "next thing",
        "everything"
    ]

    private static let ambiguousPhrases: Set<String> = [
        "figure it out",
        "sort this out",
        "handle this",
        "deal with it",
        "look into it",
        "do something"
    ]

    private static let shamePhrases: Set<String> = [
        "you should have",
        "no excuses",
        "you let everyone down",
        "not good enough",
        "lazy",
        "disappointed in yourself",
        "stop falling behind"
    ]

    private static let unsafePhrases: Set<String> = [
        "ignore medical advice",
        "skip medication",
        "hide this from",
        "bypass consent",
        "drive while exhausted",
        "spend rent money"
    ]
}
