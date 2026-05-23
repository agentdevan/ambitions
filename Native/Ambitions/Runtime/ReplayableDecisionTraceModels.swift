import Foundation

let replayableDecisionTraceSchemaVersion = "replayable_decision_trace.native.v1"

enum ReplayableDecisionTraceState: String, Codable, Sendable, Equatable, Hashable {
    case ready
    case blocked
    case missing
}

enum ReplayableDecisionTraceBlockReason: String, Codable, Sendable, Equatable, Hashable {
    case missingRecommendationTrace = "missing_recommendation_trace"
    case nonLocalBoundary = "non_local_boundary"
    case remoteIntelligenceBackend = "remote_intelligence_backend"
    case goalIntelligenceQuarantined = "goal_intelligence_quarantined"
    case incompleteRecommendationTrace = "incomplete_recommendation_trace"
    case sourceBlocked = "source_blocked"
    case fitBlocked = "fit_blocked"
    case receiptMissing = "receipt_missing"
    case unsafeRecommendationTrace = "unsafe_recommendation_trace"
}

struct ReplayableDecisionTraceBoundaryFacts: Codable, Sendable, Equatable, Hashable {
    let isLocalOnly: Bool
    let usesSwiftDataPersistence: Bool
    let usesRepositoryBackedMemory: Bool
    let syncBackendKind: String
    let hasHostedBackend: Bool
    let hasRemoteIntelligenceBackend: Bool
    let hasExternalCloudLLMDependency: Bool
    let allowsExternalSideEffectsInsideUnitOfWorkBoundaries: Bool

    init(_ boundary: PrivateLifeRuntimeBoundary) {
        isLocalOnly = boundary.isLocalOnly
        usesSwiftDataPersistence = boundary.usesSwiftDataPersistence
        usesRepositoryBackedMemory = boundary.usesRepositoryBackedMemory
        syncBackendKind = boundary.syncBackendKind.rawValue
        hasHostedBackend = boundary.hasHostedBackend
        hasRemoteIntelligenceBackend = boundary.hasRemoteIntelligenceBackend
        hasExternalCloudLLMDependency = boundary.hasExternalCloudLLMDependency
        allowsExternalSideEffectsInsideUnitOfWorkBoundaries = boundary.allowsExternalSideEffectsInsideUnitOfWorkBoundaries
    }
}

struct ReplayableDecisionTraceMemoryFacts: Codable, Sendable, Equatable, Hashable {
    let goalCount: Int
    let draftCount: Int
    let evidenceCount: Int
    let feedbackCount: Int
    let captureCount: Int

    init(_ memory: RuntimeMemorySummary) {
        goalCount = memory.goalCount
        draftCount = memory.draftCount
        evidenceCount = memory.evidenceCount
        feedbackCount = memory.feedbackCount
        captureCount = memory.captureCount
    }
}

struct ReplayableDecisionTraceKnowledgeProviderFacts: Codable, Sendable, Equatable, Hashable {
    let providerID: String
    let availability: String
    let runtimeTrustPosture: String

    init(_ status: KnowledgeProviderStatus) {
        providerID = status.provider.id
        availability = status.availability.rawValue
        runtimeTrustPosture = status.runtimeTrustPosture.rawValue
    }
}

struct ReplayableDecisionTraceRuntimeFacts: Codable, Sendable, Equatable, Hashable {
    let clientKind: String
    let clientIsConstrainedPrototype: Bool
    let boundary: ReplayableDecisionTraceBoundaryFacts
    let syncStatusBackendKind: String
    let syncStatusAvailability: String
    let syncStatusTrustPosture: String
    let knowledgeProviders: [ReplayableDecisionTraceKnowledgeProviderFacts]
    let memory: ReplayableDecisionTraceMemoryFacts

    init(_ runtimeContext: RuntimeContextSnapshot) {
        clientKind = runtimeContext.clientContext.kind.rawValue
        clientIsConstrainedPrototype = runtimeContext.clientContext.isConstrainedPrototype
        boundary = ReplayableDecisionTraceBoundaryFacts(runtimeContext.capabilities.privateLifeRuntimeBoundary)
        syncStatusBackendKind = runtimeContext.syncStatus.backendKind.rawValue
        syncStatusAvailability = runtimeContext.syncStatus.availability.rawValue
        syncStatusTrustPosture = runtimeContext.syncStatus.trustPosture.rawValue
        knowledgeProviders = runtimeContext.knowledgeProviderStatuses
            .sorted { lhs, rhs in
                if lhs.provider.id != rhs.provider.id {
                    return lhs.provider.id < rhs.provider.id
                }
                if lhs.availability.rawValue != rhs.availability.rawValue {
                    return lhs.availability.rawValue < rhs.availability.rawValue
                }
                return lhs.runtimeTrustPosture.rawValue < rhs.runtimeTrustPosture.rawValue
            }
            .map(ReplayableDecisionTraceKnowledgeProviderFacts.init)
        memory = ReplayableDecisionTraceMemoryFacts(runtimeContext.memorySummary)
    }
}

struct ReplayableDecisionTraceLifeContextFacts: Codable, Sendable, Equatable, Hashable {
    let readiness: String
    let goalText: String?
    let startHereTitle: String
    let startHereExplanation: String
    let cadence: String
    let urgency: String
    let milestone: String
    let pathwayLabels: [String]
    let sourceFreshnessStates: [String]
    let historyFactIDs: [String]
    let excludedHistoryFactIDs: [String]
    let excludedHistoryReasons: [String]
    let missingContextQuestionIDs: [String]
    let opportunityAnchorIDs: [String]
    let ageYears: Int?
    let lifeStage: String

    init(_ effect: PrivateLifeRuntimeLifeContextEffect, projection: LifeContextRuntimeProjection?) {
        readiness = effect.readiness.rawValue
        goalText = effect.goalText
        startHereTitle = effect.startHereTitle
        startHereExplanation = effect.startHereExplanation
        cadence = effect.cadence
        urgency = effect.urgency
        milestone = effect.milestone
        pathwayLabels = effect.pathwayLabels.normalizedStrings()
        sourceFreshnessStates = effect.sourceFreshnessStates.normalizedStrings()
        historyFactIDs = effect.historyFactIDs.normalizedStrings()
        excludedHistoryFactIDs = effect.excludedHistoryFactIDs.normalizedStrings()
        excludedHistoryReasons = effect.excludedHistoryReasons.normalizedStrings()
        missingContextQuestionIDs = effect.missingContextQuestionIDs.normalizedStrings()
        opportunityAnchorIDs = effect.opportunityAnchorIDs.normalizedStrings()
        ageYears = projection?.ageYears
        lifeStage = projection?.lifeStage.rawValue ?? "unknown"
    }
}

struct ReplayableDecisionTraceGoalIntelligencePrivacyFacts: Codable, Sendable, Equatable, Hashable {
    let hasSourceAudit: Bool
    let sourceAuditRowIDs: [String]
    let hasWhyNow: Bool
    let hasApplicableSignals: Bool
    let quarantineIssueIDs: [String]
    let canDriveRecommendation: Bool
    let isQuarantined: Bool

    init(context: RuntimeGoalIntelligenceContext) {
        let sourceAuditRowIDs = context.explainability.sourceAudit.rows
            .map(\.resourceID)
            .normalizedStrings()
        self.hasSourceAudit = sourceAuditRowIDs.isEmpty == false
        self.sourceAuditRowIDs = sourceAuditRowIDs
        self.hasWhyNow = context.whyNow != nil
        self.hasApplicableSignals = context.applicableSignals != nil
        self.quarantineIssueIDs = context.quarantine.issues.map(\.rawValue).normalizedStrings()
        self.canDriveRecommendation = context.quarantine.canDriveRecommendation
        self.isQuarantined = context.quarantine.isQuarantined
    }
}

struct ReplayableDecisionTraceGoalIntelligenceFacts: Codable, Sendable, Equatable, Hashable {
    let goalID: String?
    let draftID: String?
    let primaryStepID: String?
    let freshnessPosture: String
    let understandingConfidence: String
    let pathConfidence: String?
    let sourceAuditRowCount: Int
    let sourceAuditRowIDs: [String]
    let contradictionIDs: [String]
    let correctionControlIDs: [String]
    let appliedTeachingBadgeIDs: [String]
    let privacy: ReplayableDecisionTraceGoalIntelligencePrivacyFacts

    init(_ context: RuntimeGoalIntelligenceContext) {
        goalID = context.goalID
        draftID = context.draftID
        primaryStepID = context.primaryStepID
        freshnessPosture = context.explainability.freshness.posture.rawValue
        understandingConfidence = context.explainability.confidence.understandingConfidence.rawValue
        pathConfidence = context.explainability.confidence.pathConfidence?.rawValue

        let auditRowIDs = context.explainability.sourceAudit.rows
            .map(\.resourceID)
            .normalizedStrings()
        sourceAuditRowCount = auditRowIDs.count
        sourceAuditRowIDs = auditRowIDs
        contradictionIDs = context.explainability.contradictions.map(\.id).normalizedStrings()
        correctionControlIDs = context.explainability.correctionControls.map(\.id).normalizedStrings()
        appliedTeachingBadgeIDs = context.explainability.appliedTeachingBadges.map(\.signalID).normalizedStrings()
        privacy = ReplayableDecisionTraceGoalIntelligencePrivacyFacts(context: context)
    }
}

struct ReplayableDecisionTraceRecommendationSourceFacts: Codable, Sendable, Equatable, Hashable {
    let citedSourceIDs: [String]
    let sourceBlockReasons: [String]
    let localEvidenceCategories: [String]
    let canSupportRecommendation: Bool

    init(_ source: RecommendationTraceSource) {
        citedSourceIDs = source.citedSourceIDs.normalizedStrings()
        sourceBlockReasons = source.sourceAtlasBlockReasons.normalizedStrings()
        localEvidenceCategories = source.localEvidenceCategories.map(\.rawValue).normalizedStrings()
        canSupportRecommendation = source.canSupportRecommendation
    }
}

struct ReplayableDecisionTraceRecommendationFitFacts: Codable, Sendable, Equatable, Hashable {
    let state: String
    let blockReasons: [String]
    let canDriveRecommendation: Bool

    init(_ fit: RecommendationTraceFit) {
        state = fit.state.rawValue
        blockReasons = fit.blockReasons.normalizedStrings()
        canDriveRecommendation = fit.canDriveRecommendation
    }
}

struct ReplayableDecisionTraceRecommendationControlFacts: Codable, Sendable, Equatable, Hashable {
    let correctionActionIDs: [String]
    let controlActionIDs: [String]
    let correctableFieldKeys: [String]
    let hasRequiredControl: Bool

    init(_ control: RecommendationTraceControl) {
        correctionActionIDs = control.correctionActionIDs.normalizedStrings()
        controlActionIDs = control.controlActionIDs.normalizedStrings()
        correctableFieldKeys = control.correctableFieldKeys.normalizedStrings()
        hasRequiredControl = control.hasRequiredControl
    }
}

struct ReplayableDecisionTraceRecommendationReceiptFacts: Codable, Sendable, Equatable, Hashable {
    let state: String
    let receiptIDs: [String]
    let actionReceiptIDs: [String]
    let proofReferenceIDs: [String]
    let requiresReceiptBeforeBehaviorChange: Bool

    init(_ receiptBehavior: RecommendationTraceReceiptBehavior) {
        state = receiptBehavior.state.rawValue
        receiptIDs = receiptBehavior.receiptIDs.normalizedStrings()
        actionReceiptIDs = receiptBehavior.actionReceiptIDs.normalizedStrings()
        proofReferenceIDs = receiptBehavior.proofReferenceIDs.normalizedStrings()
        requiresReceiptBeforeBehaviorChange = receiptBehavior.requiresReceiptBeforeBehaviorChange
    }
}

struct ReplayableDecisionTraceDecisionReceiptFacts: Codable, Sendable, Equatable, Hashable {
    let state: String
    let summary: String
    let receiptBehaviorState: String
    let receiptIDs: [String]
    let actionReceiptIDs: [String]
    let proofReferenceIDs: [String]
    let requiresReceiptBeforeBehaviorChange: Bool
    let canDriveRecommendation: Bool

    init(record: PrivateLifeRuntimeKernelDecisionRecord, output: PrivateLifeRuntimeKernelDecisionOutput) {
        receiptBehaviorState = record.receiptBehavior.state.rawValue
        receiptIDs = record.receiptBehavior.receiptIDs.normalizedStrings()
        actionReceiptIDs = record.receiptBehavior.actionReceiptIDs.normalizedStrings()
        proofReferenceIDs = record.receiptBehavior.proofReferenceIDs.normalizedStrings()
        requiresReceiptBeforeBehaviorChange = record.receiptBehavior.requiresReceiptBeforeBehaviorChange
        canDriveRecommendation = output.canDriveRecommendation

        if record.receiptBehavior.state == .receiptAvailable {
            state = "ready"
            summary = "Decision replay is backed by local receipt evidence."
        } else if record.receiptBehavior.state == .receiptRequired {
            state = "needs_approval"
            summary = "Decision replay needs receipt approval before behavior can change."
        } else if record.receiptBehavior.state == .notApplicable {
            state = "not_applicable"
            summary = "Decision replay does not require a receipt for this path."
        } else {
            state = "missing"
            summary = "Decision replay is missing the required local receipt evidence."
        }
    }
}

struct ReplayableDecisionTraceRecommendationFacts: Codable, Sendable, Equatable, Hashable {
    let recommendationID: String
    let source: ReplayableDecisionTraceRecommendationSourceFacts
    let fit: ReplayableDecisionTraceRecommendationFitFacts
    let uncertaintyIDs: [String]
    let control: ReplayableDecisionTraceRecommendationControlFacts
    let receipt: ReplayableDecisionTraceRecommendationReceiptFacts

    init(_ record: PrivateLifeRuntimeKernelDecisionRecord) {
        recommendationID = record.recommendationTrace.recommendationID
        source = ReplayableDecisionTraceRecommendationSourceFacts(record.source)
        fit = ReplayableDecisionTraceRecommendationFitFacts(record.fit)
        uncertaintyIDs = record.uncertainty.uncertaintyIDs.normalizedStrings()
        control = ReplayableDecisionTraceRecommendationControlFacts(record.control)
        receipt = ReplayableDecisionTraceRecommendationReceiptFacts(record.receiptBehavior)
    }
}

struct ReplayableDecisionTrace: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let schemaVersion: String
    let decisionKey: String
    let decisionRecordID: String?
    let state: ReplayableDecisionTraceState
    let blockingReasons: [ReplayableDecisionTraceBlockReason]
    let runtime: ReplayableDecisionTraceRuntimeFacts
    let lifeContext: ReplayableDecisionTraceLifeContextFacts
    let personalizationFactorLedger: PersonalizationFactorLedger
    let goalIntelligence: ReplayableDecisionTraceGoalIntelligenceFacts?
    let decisionReceipt: ReplayableDecisionTraceDecisionReceiptFacts?
    let recommendation: ReplayableDecisionTraceRecommendationFacts?

    init(
        input: PrivateLifeRuntimeKernelDecisionInput,
        output: PrivateLifeRuntimeKernelDecisionOutput,
        record: PrivateLifeRuntimeKernelDecisionRecord?
    ) {
        id = Self.stableTraceID(from: output.decisionID)
        schemaVersion = replayableDecisionTraceSchemaVersion
        decisionKey = input.decisionKey
        decisionRecordID = output.recordID.map(Self.stableRecordID)
        runtime = ReplayableDecisionTraceRuntimeFacts(input.traceContext.runtimeContext)
        lifeContext = ReplayableDecisionTraceLifeContextFacts(
            output.lifeContextEffect,
            projection: input.traceContext.lifeContextProjection
        )
        personalizationFactorLedger = output.personalizationFactorLedger
        goalIntelligence = input.traceContext.goalIntelligenceContext.map(ReplayableDecisionTraceGoalIntelligenceFacts.init)
        decisionReceipt = record.map { ReplayableDecisionTraceDecisionReceiptFacts(record: $0, output: output) }
        recommendation = record.map(ReplayableDecisionTraceRecommendationFacts.init)

        if output.hasRecommendationTrace == false {
            state = .missing
        } else if output.canDriveRecommendation {
            state = .ready
        } else {
            state = .blocked
        }

        blockingReasons = Self.blockingReasons(
            input: input,
            output: output,
            record: record
        )
    }

    var isLocalOnly: Bool {
        runtime.boundary.isLocalOnly
    }

    var isReplayable: Bool {
        state == .ready
    }

    var hasRecommendationTrace: Bool {
        recommendation != nil
    }
}

extension PrivateLifeRuntimeKernel {
    func makeReplayableDecisionTrace(_ input: PrivateLifeRuntimeKernelDecisionInput) -> ReplayableDecisionTrace {
        let output = evaluate(input)
        let record = makeDecisionRecord(input)
        return ReplayableDecisionTrace(input: input, output: output, record: record)
    }
}

private extension ReplayableDecisionTrace {
    static func blockingReasons(
        input: PrivateLifeRuntimeKernelDecisionInput,
        output: PrivateLifeRuntimeKernelDecisionOutput,
        record: PrivateLifeRuntimeKernelDecisionRecord?
    ) -> [ReplayableDecisionTraceBlockReason] {
        var reasons: [ReplayableDecisionTraceBlockReason] = []
        let runtimeContext = input.traceContext.runtimeContext

        if runtimeContext.capabilities.privateLifeRuntimeBoundary.isLocalOnly == false ||
            runtimeContext.capabilities.privateLifeRuntimeBoundary.hasHostedBackend ||
            runtimeContext.capabilities.hasRemoteIntelligenceBackend ||
            runtimeContext.capabilities.privateLifeRuntimeBoundary.hasExternalCloudLLMDependency ||
            runtimeContext.capabilities.privateLifeRuntimeBoundary.allowsExternalSideEffectsInsideUnitOfWorkBoundaries {
            reasons.append(.nonLocalBoundary)
        }

        if runtimeContext.capabilities.hasRemoteIntelligenceBackend {
            reasons.append(.remoteIntelligenceBackend)
        }

        if input.traceContext.goalIntelligenceContext?.quarantine.canDriveRecommendation == false {
            reasons.append(.goalIntelligenceQuarantined)
        }

        guard let record else {
            reasons.append(.missingRecommendationTrace)
            return reasons.normalized()
        }

        if record.recommendationTrace.isComplete == false {
            reasons.append(.incompleteRecommendationTrace)
        }
        if record.source.canSupportRecommendation == false {
            reasons.append(.sourceBlocked)
        }
        if record.fit.canDriveRecommendation == false {
            reasons.append(.fitBlocked)
        }
        if record.receiptBehavior.state == .receiptMissing {
            reasons.append(.receiptMissing)
        }
        if output.canDriveRecommendation == false {
            reasons.append(.unsafeRecommendationTrace)
        }

        return reasons.normalized()
    }

    static func stableTraceID(from rawID: String) -> String {
        "replayable-decision-trace.\(stableHexDigest(rawID))"
    }

    static func stableRecordID(from rawID: String) -> String {
        "replayable-decision-record.\(stableHexDigest(rawID))"
    }

    static func stableHexDigest(_ value: String) -> String {
        var hash: UInt64 = 0xcbf29ce484222325
        for byte in value.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 0x100000001b3
        }
        return String(hash, radix: 16)
    }
}

private extension Array where Element == String {
    func normalizedStrings() -> [String] {
        Array(
            Set(
                map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { $0.isEmpty == false }
            )
        )
        .sorted()
    }
}

private extension Array where Element == ReplayableDecisionTraceBlockReason {
    func normalized() -> [ReplayableDecisionTraceBlockReason] {
        Array(Set(self)).sorted { lhs, rhs in
            lhs.rawValue < rhs.rawValue
        }
    }
}
