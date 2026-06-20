import Foundation

enum HighRiskSafetyDomain: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case standard
    case healthMedical = "health_medical"
    case legalCivic = "legal_civic"
    case financial
    case crisisSafety = "crisis_safety"
    case regulatedGoods = "regulated_goods"
    case cannabis
    case minorsStudent = "minors_student"
    case sensitivePrivate = "sensitive_private"
    case immigration
    case educationEligibility = "education_eligibility"
    case certificationEligibility = "certification_eligibility"
    case professionalBoundary = "professional_boundary"

    var requiresHighRiskReview: Bool {
        self != .standard
    }

    var requiresProfessionalBoundary: Bool {
        switch self {
        case .healthMedical, .legalCivic, .financial, .immigration, .educationEligibility, .certificationEligibility, .professionalBoundary:
            return true
        case .standard, .crisisSafety, .regulatedGoods, .cannabis, .minorsStudent, .sensitivePrivate:
            return false
        }
    }
}

enum HighRiskSafetyReviewState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case notRequired = "not_required"
    case approved
    case needed
    case blocked

    var canContinue: Bool {
        self == .notRequired || self == .approved
    }
}

enum HighRiskSafetyMode: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case allowed
    case sourceNeeded = "source_needed"
    case jurisdictionNeeded = "jurisdiction_needed"
    case reviewRequired = "review_required"
    case professionalBoundary = "professional_boundary"
    case unsafeBlocked = "unsafe_blocked"
    case blocked
}

enum HighRiskSafetyIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case upstreamCoverageBlocked = "upstream_coverage_blocked"
    case sourceAuthorityMissing = "source_authority_missing"
    case sourceAuthorityBlocked = "source_authority_blocked"
    case jurisdictionNeeded = "jurisdiction_needed"
    case jurisdictionIncompatible = "jurisdiction_incompatible"
    case highRiskReviewRequired = "high_risk_review_required"
    case professionalBoundaryRequired = "professional_boundary_required"
    case crisisSupportRequired = "crisis_support_required"
    case unsafeBlocked = "unsafe_blocked"
    case nonLocalRuntimeBoundary = "non_local_runtime_boundary"
    case privateProjectionBlocked = "private_projection_blocked"
    case consequenceBlocked = "consequence_blocked"
    case missingSourceRecord = "missing_source_record"
    case missingReceipt = "missing_receipt"
    case missingReplayTrace = "missing_replay_trace"
    case missingInspectionRoute = "missing_inspection_route"
}

struct HighRiskJurisdictionContext: Codable, Sendable, Equatable, Hashable {
    let domain: HighRiskSafetyDomain
    let requestedJurisdictionID: String?
    let requiresJurisdiction: Bool
    let reviewState: HighRiskSafetyReviewState
    let localOnly: Bool

    init(
        domain: HighRiskSafetyDomain,
        requestedJurisdictionID: String? = nil,
        requiresJurisdiction: Bool = false,
        reviewState: HighRiskSafetyReviewState = .notRequired,
        localOnly: Bool = true
    ) {
        self.domain = domain
        self.requestedJurisdictionID = Self.normalizedOptional(requestedJurisdictionID)
        self.requiresJurisdiction = requiresJurisdiction
        self.reviewState = reviewState
        self.localOnly = localOnly
    }

    var jurisdictionSatisfied: Bool {
        requiresJurisdiction == false || requestedJurisdictionID != nil
    }

    var professionalBoundaryRequired: Bool {
        domain.requiresProfessionalBoundary
    }

    var crisisSupportRequired: Bool {
        domain == .crisisSafety
    }

    private static func normalizedOptional(_ value: String?) -> String? {
        guard let normalized = value?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(), normalized.isEmpty == false else {
            return nil
        }
        return normalized.replacingOccurrences(of: ".", with: "_")
    }
}

struct HighRiskSafetyHandoff: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let issue: HighRiskSafetyIssue
    let route: String
    let requestedJurisdictionID: String?
    let blockedOutputs: [String]
    let allowedLocalActions: [String]
}

struct HighRiskSafetyReceipt: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let mode: HighRiskSafetyMode
    let domain: HighRiskSafetyDomain
    let issueCodes: [String]
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceID: String
    let whatAmbitionsKnowsRoute: String
    let localOnly: Bool
}

struct HighRiskSafetyTrace: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let goalReferenceID: String
    let anyGoalRecordID: String
    let sourceAuthorityRowID: String?
    let lifeConsequenceTraceID: String?
    let receiptIDs: [String]
    let handoffIDs: [String]
    let issueCodes: [String]
    let blockedOutputs: [String]
    let fingerprint: String
    let localOnly: Bool
}

struct HighRiskSafetyGateInput: Sendable, Equatable {
    let anyGoalRecord: AnyGoalCoverageRecord
    let sourceAuthorityInspection: SourceAtlasAuthorityInspectionRecord?
    let lifeConsequenceRecord: LifeConsequenceRecord?
    let context: HighRiskJurisdictionContext
    let evaluatedAt: String
    let localOnly: Bool

    init(
        anyGoalRecord: AnyGoalCoverageRecord,
        sourceAuthorityInspection: SourceAtlasAuthorityInspectionRecord? = nil,
        lifeConsequenceRecord: LifeConsequenceRecord? = nil,
        context: HighRiskJurisdictionContext,
        evaluatedAt: String,
        localOnly: Bool = true
    ) {
        self.anyGoalRecord = anyGoalRecord
        self.sourceAuthorityInspection = sourceAuthorityInspection
        self.lifeConsequenceRecord = lifeConsequenceRecord
        self.context = context
        self.evaluatedAt = evaluatedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.localOnly = localOnly
    }
}

struct HighRiskSafetyGateRecord: Sendable, Equatable {
    let id: String
    let goalReferenceID: String
    let mode: HighRiskSafetyMode
    let receipt: HighRiskSafetyReceipt
    let handoffs: [HighRiskSafetyHandoff]
    let trace: HighRiskSafetyTrace
    let issues: [HighRiskSafetyIssue]
    let canContinueToRuntimeCore: Bool
    let canGenerateVisibleStep: Bool
    let canInstallSchedule: Bool
    let canShare: Bool

    var runtimeCoreSegment: RuntimeCoreChainSegment {
        RuntimeCoreChainSegment(
            kind: .highRiskSafety,
            state: canContinueToRuntimeCore ? .ready : .blocked,
            sourceRecordIDs: receipt.sourceRecordIDs,
            receiptIDs: normalizedIDs(receipt.receiptIDs + [receipt.id]),
            replayTraceID: canContinueToRuntimeCore ? trace.id : nil,
            whatAmbitionsKnowsRoute: canContinueToRuntimeCore ? receipt.whatAmbitionsKnowsRoute : nil,
            isReversible: true,
            canDriveVisibleExecution: canGenerateVisibleStep,
            blocksDownstream: canContinueToRuntimeCore == false
        )
    }

    private func normalizedIDs(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct HighRiskSafetyJurisdictionGate: Sendable, Equatable {
    func evaluate(_ input: HighRiskSafetyGateInput) -> HighRiskSafetyGateRecord {
        let issues = sortedIssues(issues(for: input))
        let mode = mode(for: issues, input: input)
        let handoffs = makeHandoffs(input: input, issues: issues)
        let blockedOutputs = blockedOutputs(mode: mode, input: input)
        let sourceRecordIDs = sourceRecordIDs(input: input)
        let receiptIDs = receiptIDs(input: input)
        let replayTraceID = replayTraceID(input: input)
        let inspectionRoute = inspectionRoute(input: input)
        let receipt = HighRiskSafetyReceipt(
            id: stableIdentifier(prefix: "high-risk-safety.receipt", components: [input.anyGoalRecord.goalReferenceID, mode.rawValue, issues.map(\.rawValue).joined(separator: ",")]),
            mode: mode,
            domain: input.context.domain,
            issueCodes: issues.map(\.rawValue),
            sourceRecordIDs: sourceRecordIDs,
            receiptIDs: receiptIDs,
            replayTraceID: replayTraceID,
            whatAmbitionsKnowsRoute: inspectionRoute,
            localOnly: input.localOnly && input.context.localOnly
        )
        let trace = makeTrace(
            input: input,
            receipt: receipt,
            handoffs: handoffs,
            issues: issues,
            blockedOutputs: blockedOutputs
        )
        let canContinue = issues.isEmpty && mode == .allowed
        return HighRiskSafetyGateRecord(
            id: stableIdentifier(prefix: "high-risk-safety.record", components: [input.anyGoalRecord.goalReferenceID, trace.fingerprint]),
            goalReferenceID: input.anyGoalRecord.goalReferenceID,
            mode: mode,
            receipt: receipt,
            handoffs: handoffs,
            trace: trace,
            issues: issues,
            canContinueToRuntimeCore: canContinue,
            canGenerateVisibleStep: canContinue && input.anyGoalRecord.canGenerateVisibleStep && sourceCanDriveVisibleStep(input),
            canInstallSchedule: canContinue && sourceCanInstallSchedule(input),
            canShare: canContinue && sourceCanShare(input)
        )
    }
}

private extension HighRiskSafetyJurisdictionGate {
    func issues(for input: HighRiskSafetyGateInput) -> Set<HighRiskSafetyIssue> {
        var issues: Set<HighRiskSafetyIssue> = []

        if input.localOnly == false || input.context.localOnly == false {
            issues.insert(.nonLocalRuntimeBoundary)
        }
        if input.anyGoalRecord.canGenerateVisibleStep == false || input.anyGoalRecord.canContinueToStepQualityFirewall == false {
            issues.insert(.upstreamCoverageBlocked)
        }
        switch input.anyGoalRecord.operatingMode {
        case .unsafeBlocked:
            issues.insert(.unsafeBlocked)
        case .jurisdictionNeeded:
            issues.insert(.jurisdictionNeeded)
        case .supported, .unsupportedCaptured, .awaitingSource, .sourceArrived:
            break
        }
        if input.context.crisisSupportRequired {
            issues.insert(.crisisSupportRequired)
            issues.insert(.unsafeBlocked)
        }
        if input.context.jurisdictionSatisfied == false {
            issues.insert(.jurisdictionNeeded)
        }
        if input.context.reviewState.canContinue == false {
            issues.insert(.highRiskReviewRequired)
        }
        if input.context.domain.requiresHighRiskReview && input.context.reviewState != .approved {
            issues.insert(.highRiskReviewRequired)
        }
        if input.context.professionalBoundaryRequired && input.context.reviewState != .approved {
            issues.insert(.professionalBoundaryRequired)
        }
        if input.anyGoalRecord.coverageNeeds.contains(where: { $0.riskJurisdictionClass == .highRiskReview }) && input.context.reviewState != .approved {
            issues.insert(.highRiskReviewRequired)
        }
        if input.anyGoalRecord.coverageNeeds.contains(where: { $0.privacyClass == .blockedSensitive }) {
            issues.insert(.privateProjectionBlocked)
        }
        if input.anyGoalRecord.recoveryReceipt.sourceRecordIDs.isEmpty {
            issues.insert(.missingSourceRecord)
        }
        if input.anyGoalRecord.recoveryReceipt.receiptID.isEmpty {
            issues.insert(.missingReceipt)
        }
        if input.anyGoalRecord.recoveryReceipt.replayTraceID.isEmpty {
            issues.insert(.missingReplayTrace)
        }
        if input.anyGoalRecord.recoveryReceipt.whatAmbitionsKnowsRoute.isEmpty {
            issues.insert(.missingInspectionRoute)
        }
        if let inspection = input.sourceAuthorityInspection {
            if inspection.canSupportCurrentUse == false {
                issues.insert(.sourceAuthorityBlocked)
            }
            if inspection.selectedRow.canSupportVisibleStep == false || inspection.selectedRow.canInstallSchedule == false {
                issues.insert(.sourceAuthorityBlocked)
            }
            if inspection.selectedRow.issueCodes.contains(SourceAtlasAuthorityMeshIssue.jurisdictionIncompatible.rawValue) {
                issues.insert(.jurisdictionIncompatible)
            }
            if inspection.selectedRow.sourceIDs.isEmpty {
                issues.insert(.missingSourceRecord)
            }
        } else if input.anyGoalRecord.recoveryReceipt.sourceRecordIDs.isEmpty {
            issues.insert(.sourceAuthorityMissing)
        }
        if let consequence = input.lifeConsequenceRecord,
           consequence.canDriveConsequenceReflowSegment == false || consequence.highestSeverity.blocksDownstream {
            issues.insert(.consequenceBlocked)
        }

        return issues
    }

    func mode(for issues: [HighRiskSafetyIssue], input: HighRiskSafetyGateInput) -> HighRiskSafetyMode {
        if issues.contains(.unsafeBlocked) || issues.contains(.crisisSupportRequired) || input.context.reviewState == .blocked {
            return .unsafeBlocked
        }
        if issues.contains(.jurisdictionNeeded) || issues.contains(.jurisdictionIncompatible) {
            return .jurisdictionNeeded
        }
        if issues.contains(.professionalBoundaryRequired) {
            return .professionalBoundary
        }
        if issues.contains(.highRiskReviewRequired) {
            return .reviewRequired
        }
        if issues.contains(.sourceAuthorityMissing) || input.anyGoalRecord.operatingMode == .awaitingSource || input.anyGoalRecord.operatingMode == .unsupportedCaptured {
            return .sourceNeeded
        }
        if issues.isEmpty == false {
            return .blocked
        }
        return .allowed
    }

    func makeHandoffs(input: HighRiskSafetyGateInput, issues: [HighRiskSafetyIssue]) -> [HighRiskSafetyHandoff] {
        issues.compactMap { issue in
            guard issue == .jurisdictionNeeded ||
                issue == .jurisdictionIncompatible ||
                issue == .highRiskReviewRequired ||
                issue == .professionalBoundaryRequired ||
                issue == .crisisSupportRequired ||
                issue == .unsafeBlocked ||
                issue == .sourceAuthorityBlocked ||
                issue == .sourceAuthorityMissing else {
                return nil
            }
            return HighRiskSafetyHandoff(
                id: stableIdentifier(prefix: "high-risk-safety.handoff", components: [input.anyGoalRecord.goalReferenceID, issue.rawValue]),
                issue: issue,
                route: route(for: issue, goalID: input.anyGoalRecord.goalReferenceID),
                requestedJurisdictionID: input.context.requestedJurisdictionID ?? input.anyGoalRecord.jurisdictionHandoff?.requestedJurisdictionID,
                blockedOutputs: blockedOutputs(mode: mode(for: issues, input: input), input: input),
                allowedLocalActions: allowedLocalActions(for: issue)
            )
        }
        .sorted { $0.id < $1.id }
    }

    func makeTrace(
        input: HighRiskSafetyGateInput,
        receipt: HighRiskSafetyReceipt,
        handoffs: [HighRiskSafetyHandoff],
        issues: [HighRiskSafetyIssue],
        blockedOutputs: [String]
    ) -> HighRiskSafetyTrace {
        let issueCodes = issues.map(\.rawValue)
        let handoffIDs = handoffs.map(\.id).sorted()
        let fingerprint = stableIdentifier(
            prefix: "high-risk-safety.fingerprint",
            components: [
                input.anyGoalRecord.id,
                input.sourceAuthorityInspection?.selectedRow.id ?? "no-source-authority-row",
                input.lifeConsequenceRecord?.trace.id ?? "no-life-consequence",
                receipt.id,
                handoffIDs.joined(separator: ","),
                issueCodes.joined(separator: ","),
                blockedOutputs.joined(separator: ","),
                input.evaluatedAt
            ]
        )
        return HighRiskSafetyTrace(
            id: stableIdentifier(prefix: "high-risk-safety.trace", components: [input.anyGoalRecord.goalReferenceID, fingerprint]),
            goalReferenceID: input.anyGoalRecord.goalReferenceID,
            anyGoalRecordID: input.anyGoalRecord.id,
            sourceAuthorityRowID: input.sourceAuthorityInspection?.selectedRow.id,
            lifeConsequenceTraceID: input.lifeConsequenceRecord?.trace.id,
            receiptIDs: normalizedIDs(receipt.receiptIDs + [receipt.id]),
            handoffIDs: handoffIDs,
            issueCodes: issueCodes,
            blockedOutputs: blockedOutputs,
            fingerprint: fingerprint,
            localOnly: input.localOnly && input.context.localOnly && receipt.localOnly
        )
    }

    func blockedOutputs(mode: HighRiskSafetyMode, input: HighRiskSafetyGateInput) -> [String] {
        var outputs = Set<String>()
        if mode != .allowed || input.anyGoalRecord.canGenerateVisibleStep == false {
            outputs.insert("visible_step")
        }
        if mode != .allowed || sourceCanInstallSchedule(input) == false {
            outputs.insert("schedule_install")
        }
        if mode != .allowed || sourceCanShare(input) == false {
            outputs.insert("share_projection")
        }
        if mode == .unsafeBlocked || mode == .jurisdictionNeeded || mode == .reviewRequired || mode == .professionalBoundary {
            outputs.insert("coverage_request")
        }
        return outputs.sorted()
    }

    func allowedLocalActions(for issue: HighRiskSafetyIssue) -> [String] {
        switch issue {
        case .jurisdictionNeeded, .jurisdictionIncompatible:
            return ["open_jurisdiction_handoff", "preserve_local_receipt"]
        case .highRiskReviewRequired, .professionalBoundaryRequired:
            return ["open_review_handoff", "preserve_local_receipt"]
        case .crisisSupportRequired, .unsafeBlocked:
            return ["preserve_block_receipt", "show_safe_recovery_boundary"]
        case .sourceAuthorityBlocked, .sourceAuthorityMissing:
            return ["explain_source_needed", "inspect_source_authority"]
        default:
            return ["inspect_runtime_boundary"]
        }
    }

    func route(for issue: HighRiskSafetyIssue, goalID: String) -> String {
        switch issue {
        case .jurisdictionNeeded, .jurisdictionIncompatible:
            return "you://what-ambitions-knows/jurisdiction/\(goalID)"
        case .highRiskReviewRequired, .professionalBoundaryRequired:
            return "you://what-ambitions-knows/high-risk-review/\(goalID)"
        case .sourceAuthorityBlocked, .sourceAuthorityMissing:
            return "you://what-ambitions-knows/source-authority/\(goalID)"
        default:
            return "you://what-ambitions-knows/safety/\(goalID)"
        }
    }

    func sourceRecordIDs(input: HighRiskSafetyGateInput) -> [String] {
        normalizedIDs(
            input.anyGoalRecord.recoveryReceipt.sourceRecordIDs +
                (input.sourceAuthorityInspection?.selectedRow.sourceIDs ?? []) +
                (input.lifeConsequenceRecord?.runtimeCoreSegment.sourceRecordIDs ?? [])
        )
    }

    func receiptIDs(input: HighRiskSafetyGateInput) -> [String] {
        normalizedIDs(
            [input.anyGoalRecord.recoveryReceipt.receiptID] +
                (input.lifeConsequenceRecord?.runtimeCoreSegment.receiptIDs ?? [])
        )
    }

    func replayTraceID(input: HighRiskSafetyGateInput) -> String {
        input.lifeConsequenceRecord?.trace.id ?? input.anyGoalRecord.recoveryReceipt.replayTraceID
    }

    func inspectionRoute(input: HighRiskSafetyGateInput) -> String {
        input.anyGoalRecord.recoveryReceipt.whatAmbitionsKnowsRoute.isEmpty
            ? "you://what-ambitions-knows/high-risk-safety/\(input.anyGoalRecord.goalReferenceID)"
            : input.anyGoalRecord.recoveryReceipt.whatAmbitionsKnowsRoute
    }

    func sourceCanDriveVisibleStep(_ input: HighRiskSafetyGateInput) -> Bool {
        input.sourceAuthorityInspection?.selectedRow.canSupportVisibleStep ?? (input.anyGoalRecord.recoveryReceipt.sourceRecordIDs.isEmpty == false)
    }

    func sourceCanInstallSchedule(_ input: HighRiskSafetyGateInput) -> Bool {
        input.sourceAuthorityInspection?.selectedRow.canInstallSchedule ?? (input.anyGoalRecord.recoveryReceipt.sourceRecordIDs.isEmpty == false)
    }

    func sourceCanShare(_ input: HighRiskSafetyGateInput) -> Bool {
        input.sourceAuthorityInspection?.selectedRow.canShare ?? false
    }

    func sortedIssues(_ issues: Set<HighRiskSafetyIssue>) -> [HighRiskSafetyIssue] {
        issues.sorted { $0.rawValue < $1.rawValue }
    }

    func stableIdentifier(prefix: String, components: [String]) -> String {
        ([prefix] + components.map(normalizedToken))
            .filter { $0.isEmpty == false }
            .joined(separator: ".")
    }

    func normalizedToken(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.isEmpty == false }
            .joined(separator: "-")
    }

    func normalizedIDs(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}
