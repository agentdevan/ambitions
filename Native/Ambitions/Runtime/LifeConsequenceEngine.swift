import Foundation

enum LifeConsequenceTrigger: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case scheduleInstall = "schedule_install"
    case skipStep = "skip_step"
    case shrinkStep = "shrink_step"
    case replaceStep = "replace_step"
    case extendStep = "extend_step"
    case deadlineChange = "deadline_change"
    case sourceChange = "source_change"
    case availabilityChange = "availability_change"
    case protectedTimeChange = "protected_time_change"
    case highRiskReview = "high_risk_review"
    case unsafeState = "unsafe_state"
}

enum LifeConsequenceSeverity: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case silent
    case inform
    case confirm
    case warn
    case block
    case impossible

    var isMaterial: Bool {
        self != .silent
    }

    var blocksDownstream: Bool {
        self == .block || self == .impossible
    }

    fileprivate var order: Int {
        switch self {
        case .silent: return 0
        case .inform: return 1
        case .confirm: return 2
        case .warn: return 3
        case .block: return 4
        case .impossible: return 5
        }
    }
}

enum LifeConsequenceVisibilityPreference: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case quiet
    case balanced
    case detailed
    case expert
}

enum LifeConsequenceVisibilityState: String, Codable, Sendable, Equatable, Hashable {
    case compressed
    case visible
    case reviewRequired = "review_required"
    case blocked
}

enum LifeConsequenceSourceAuthorityState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case current
    case stale
    case reviewRequired = "review_required"
    case revoked
    case contradicted
}

enum LifeConsequenceRecoveryImpact: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case none
    case light
    case review
    case heavy
}

enum LifeConsequenceIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case scheduleInstallBlocked = "schedule_install_blocked"
    case missingScheduleInstallReceipt = "missing_schedule_install_receipt"
    case missingRollbackTrace = "missing_rollback_trace"
    case missingConsequenceInput = "missing_consequence_input"
    case missingAffectedGoal = "missing_affected_goal"
    case missingSourceRecord = "missing_source_record"
    case missingReceipt = "missing_receipt"
    case missingReplayTrace = "missing_replay_trace"
    case missingInspectionRoute = "missing_inspection_route"
    case treatyOutputMissing = "treaty_output_missing"
    case treatyViolationHidden = "treaty_violation_hidden"
    case treatyBlocked = "treaty_blocked"
    case nonSuppressibleEventHidden = "non_suppressible_event_hidden"
    case hiddenConsequenceMutation = "hidden_consequence_mutation"
    case irreversibleReflow = "irreversible_reflow"
    case nonLocalRuntimeBoundary = "non_local_runtime_boundary"
    case protectedTimeBroken = "protected_time_broken"
    case deadlineImpossible = "deadline_impossible"
    case sourceRevoked = "source_revoked"
    case unsafeState = "unsafe_state"
    case highRiskReviewRequired = "high_risk_review_required"
    case scheduleInstallFailure = "schedule_install_failure"
}

struct LifeConsequenceGoalTreaty: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let participatingGoalIDs: [String]
    let protectedGoalID: String?
    let constraintSummary: String
    let violationSeverity: LifeConsequenceSeverity
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceID: String?
    let whatAmbitionsKnowsRoute: String?
    let localOnly: Bool

    init(
        id: String,
        title: String,
        participatingGoalIDs: [String],
        protectedGoalID: String?,
        constraintSummary: String,
        violationSeverity: LifeConsequenceSeverity,
        sourceRecordIDs: [String],
        receiptIDs: [String],
        replayTraceID: String?,
        whatAmbitionsKnowsRoute: String?,
        localOnly: Bool = true
    ) {
        self.id = Self.normalized(id)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.participatingGoalIDs = Self.normalizedIDs(participatingGoalIDs)
        self.protectedGoalID = Self.normalizedOptional(protectedGoalID)
        self.constraintSummary = constraintSummary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.violationSeverity = violationSeverity
        self.sourceRecordIDs = Self.normalizedIDs(sourceRecordIDs)
        self.receiptIDs = Self.normalizedIDs(receiptIDs)
        self.replayTraceID = Self.normalizedOptional(replayTraceID)
        self.whatAmbitionsKnowsRoute = Self.normalizedOptional(whatAmbitionsKnowsRoute)
        self.localOnly = localOnly
    }

    var isInspectable: Bool {
        id.isEmpty == false &&
            title.isEmpty == false &&
            participatingGoalIDs.isEmpty == false &&
            constraintSummary.isEmpty == false &&
            sourceRecordIDs.isEmpty == false &&
            receiptIDs.isEmpty == false &&
            replayTraceID != nil &&
            whatAmbitionsKnowsRoute != nil &&
            localOnly
    }

    func participates(in goalID: String) -> Bool {
        participatingGoalIDs.contains(goalID) || protectedGoalID == goalID
    }

    private static func normalized(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func normalizedIDs(_ values: [String]) -> [String] {
        Array(Set(values.map(normalized).filter { $0.isEmpty == false })).sorted()
    }

    private static func normalizedOptional(_ value: String?) -> String? {
        guard let normalized = value?.trimmingCharacters(in: .whitespacesAndNewlines), normalized.isEmpty == false else {
            return nil
        }
        return normalized
    }
}

struct LifeConsequenceImpact: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let affectedGoalID: String
    let affectedGoalTitle: String
    let trigger: LifeConsequenceTrigger
    let deadlineMinutesDelta: Int
    let densityMinutesDelta: Int
    let proofValueDelta: Int
    let dependencyIDs: [String]
    let protectedTimeBroken: Bool
    let sourceAuthority: LifeConsequenceSourceAuthorityState
    let recoveryImpact: LifeConsequenceRecoveryImpact
    let materialDisplacement: Bool
    let highRiskReviewRequired: Bool
    let unsafeState: Bool
    let scheduleInstallFailure: Bool
    let treatyIDs: [String]
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceID: String?
    let whatAmbitionsKnowsRoute: String?
    let userVisible: Bool
    let localOnly: Bool
    let reversible: Bool

    init(
        id: String,
        affectedGoalID: String,
        affectedGoalTitle: String,
        trigger: LifeConsequenceTrigger,
        deadlineMinutesDelta: Int = 0,
        densityMinutesDelta: Int = 0,
        proofValueDelta: Int = 0,
        dependencyIDs: [String] = [],
        protectedTimeBroken: Bool = false,
        sourceAuthority: LifeConsequenceSourceAuthorityState = .current,
        recoveryImpact: LifeConsequenceRecoveryImpact = .none,
        materialDisplacement: Bool = false,
        highRiskReviewRequired: Bool = false,
        unsafeState: Bool = false,
        scheduleInstallFailure: Bool = false,
        treatyIDs: [String] = [],
        sourceRecordIDs: [String],
        receiptIDs: [String],
        replayTraceID: String?,
        whatAmbitionsKnowsRoute: String?,
        userVisible: Bool = true,
        localOnly: Bool = true,
        reversible: Bool = true
    ) {
        self.id = Self.normalized(id)
        self.affectedGoalID = Self.normalized(affectedGoalID)
        self.affectedGoalTitle = affectedGoalTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        self.trigger = trigger
        self.deadlineMinutesDelta = deadlineMinutesDelta
        self.densityMinutesDelta = densityMinutesDelta
        self.proofValueDelta = proofValueDelta
        self.dependencyIDs = Self.normalizedIDs(dependencyIDs)
        self.protectedTimeBroken = protectedTimeBroken
        self.sourceAuthority = sourceAuthority
        self.recoveryImpact = recoveryImpact
        self.materialDisplacement = materialDisplacement
        self.highRiskReviewRequired = highRiskReviewRequired
        self.unsafeState = unsafeState
        self.scheduleInstallFailure = scheduleInstallFailure
        self.treatyIDs = Self.normalizedIDs(treatyIDs)
        self.sourceRecordIDs = Self.normalizedIDs(sourceRecordIDs)
        self.receiptIDs = Self.normalizedIDs(receiptIDs)
        self.replayTraceID = Self.normalizedOptional(replayTraceID)
        self.whatAmbitionsKnowsRoute = Self.normalizedOptional(whatAmbitionsKnowsRoute)
        self.userVisible = userVisible
        self.localOnly = localOnly
        self.reversible = reversible
    }

    var isInspectable: Bool {
        id.isEmpty == false &&
            affectedGoalID.isEmpty == false &&
            affectedGoalTitle.isEmpty == false &&
            sourceRecordIDs.isEmpty == false &&
            receiptIDs.isEmpty == false &&
            replayTraceID != nil &&
            whatAmbitionsKnowsRoute != nil &&
            localOnly
    }

    private static func normalized(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func normalizedIDs(_ values: [String]) -> [String] {
        Array(Set(values.map(normalized).filter { $0.isEmpty == false })).sorted()
    }

    private static func normalizedOptional(_ value: String?) -> String? {
        guard let normalized = value?.trimmingCharacters(in: .whitespacesAndNewlines), normalized.isEmpty == false else {
            return nil
        }
        return normalized
    }
}

struct LifeConsequenceTreatyOutput: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let treatyID: String
    let affectedGoalIDs: [String]
    let severity: LifeConsequenceSeverity
    let violated: Bool
    let consequencePhrase: String
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceID: String
    let whatAmbitionsKnowsRoute: String
}

struct LifeConsequenceReceipt: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let impactID: String
    let affectedGoalID: String
    let trigger: LifeConsequenceTrigger
    let severity: LifeConsequenceSeverity
    let visibility: LifeConsequenceVisibilityState
    let changedSummary: String
    let consequencePhrase: String
    let rollbackState: String
    let treatyIDs: [String]
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceID: String
    let whatAmbitionsKnowsRoute: String
    let reversible: Bool
    let localOnly: Bool
}

struct LifeConsequenceTrace: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let goalReferenceID: String
    let scheduleInstallTraceID: String?
    let receiptIDs: [String]
    let treatyOutputIDs: [String]
    let issueIDs: [String]
    let replayTraceIDs: [String]
    let fingerprint: String
    let localOnly: Bool
}

struct LifeConsequenceEngineInput: Sendable, Equatable {
    let scheduleInstallRecord: ScheduleInstallRecord
    let impacts: [LifeConsequenceImpact]
    let treaties: [LifeConsequenceGoalTreaty]
    let visibilityPreference: LifeConsequenceVisibilityPreference
    let evaluatedAt: String
    let localOnly: Bool

    init(
        scheduleInstallRecord: ScheduleInstallRecord,
        impacts: [LifeConsequenceImpact],
        treaties: [LifeConsequenceGoalTreaty],
        visibilityPreference: LifeConsequenceVisibilityPreference,
        evaluatedAt: String,
        localOnly: Bool = true
    ) {
        self.scheduleInstallRecord = scheduleInstallRecord
        self.impacts = impacts
        self.treaties = treaties
        self.visibilityPreference = visibilityPreference
        self.evaluatedAt = evaluatedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.localOnly = localOnly
    }
}

struct LifeConsequenceRecord: Sendable, Equatable {
    let id: String
    let goalReferenceID: String
    let receipts: [LifeConsequenceReceipt]
    let treatyOutputs: [LifeConsequenceTreatyOutput]
    let trace: LifeConsequenceTrace
    let issues: [LifeConsequenceIssue]
    let highestSeverity: LifeConsequenceSeverity

    var canDriveConsequenceReflowSegment: Bool {
        issues.isEmpty &&
            trace.localOnly &&
            highestSeverity.blocksDownstream == false &&
            materialReceiptCoverageComplete
    }

    var runtimeCoreSegment: RuntimeCoreChainSegment {
        RuntimeCoreChainSegment(
            kind: .consequenceReflow,
            state: canDriveConsequenceReflowSegment ? .ready : .blocked,
            sourceRecordIDs: normalizedIDs(receipts.flatMap(\.sourceRecordIDs) + treatyOutputs.flatMap(\.sourceRecordIDs)),
            receiptIDs: normalizedIDs(receipts.flatMap(\.receiptIDs) + treatyOutputs.flatMap(\.receiptIDs)),
            replayTraceID: canDriveConsequenceReflowSegment ? trace.id : nil,
            whatAmbitionsKnowsRoute: canDriveConsequenceReflowSegment ? "you://what-ambitions-knows/life-consequence/\(goalReferenceID)" : nil,
            isReversible: receipts.allSatisfy(\.reversible),
            canDriveVisibleExecution: canDriveConsequenceReflowSegment,
            blocksDownstream: canDriveConsequenceReflowSegment == false
        )
    }

    private var materialReceiptCoverageComplete: Bool {
        highestSeverity == .silent || receipts.isEmpty == false
    }
}

struct LifeConsequenceEngine: Sendable, Equatable {
    func evaluate(_ input: LifeConsequenceEngineInput) -> LifeConsequenceRecord {
        var issues = baselineIssues(for: input)
        let sortedImpacts = input.impacts.sorted { lhs, rhs in
            if lhs.affectedGoalID == rhs.affectedGoalID {
                return lhs.id < rhs.id
            }
            return lhs.affectedGoalID < rhs.affectedGoalID
        }
        let sortedTreaties = input.treaties.sorted { $0.id < $1.id }

        var severitiesByImpact: [String: LifeConsequenceSeverity] = [:]
        var visibilityByImpact: [String: LifeConsequenceVisibilityState] = [:]
        var impactTreatiesByID: [String: [LifeConsequenceGoalTreaty]] = [:]

        for impact in sortedImpacts {
            let participatingTreaties = sortedTreaties.filter { treaty in
                treaty.participates(in: impact.affectedGoalID) || impact.treatyIDs.contains(treaty.id)
            }
            let severity = severity(for: impact, treaties: participatingTreaties)
            let visibility = visibility(for: severity, preference: input.visibilityPreference)
            severitiesByImpact[impact.id] = severity
            visibilityByImpact[impact.id] = visibility
            impactTreatiesByID[impact.id] = participatingTreaties
            issues.formUnion(impactIssues(impact, severity: severity, visibility: visibility, treaties: participatingTreaties))
        }

        let treatyOutputs = makeTreatyOutputs(impacts: sortedImpacts, severitiesByImpact: severitiesByImpact, treatiesByImpact: impactTreatiesByID)
        if sortedTreaties.contains(where: { $0.isInspectable == false }) {
            issues.insert(.treatyOutputMissing)
        }

        let receipts = makeReceipts(
            input: input,
            impacts: sortedImpacts,
            severitiesByImpact: severitiesByImpact,
            visibilityByImpact: visibilityByImpact,
            treatiesByImpact: impactTreatiesByID,
            allowReceipts: input.scheduleInstallRecord.canDriveScheduleInstallSegment
        )
        let highestSeverity = sortedImpacts.reduce(LifeConsequenceSeverity.silent) { current, impact in
            moreSevere(current, severitiesByImpact[impact.id] ?? .silent)
        }
        if highestSeverity.isMaterial && receipts.isEmpty {
            issues.insert(.missingReceipt)
        }

        let sortedIssues = issues.sorted { $0.rawValue < $1.rawValue }
        let trace = makeTrace(input: input, receipts: receipts, treatyOutputs: treatyOutputs, issues: sortedIssues)

        return LifeConsequenceRecord(
            id: stableIdentifier(
                prefix: "life-consequence.record",
                components: [
                    input.scheduleInstallRecord.goalReferenceID,
                    trace.fingerprint,
                    sortedIssues.map(\.rawValue).joined(separator: ",")
                ]
            ),
            goalReferenceID: input.scheduleInstallRecord.goalReferenceID,
            receipts: receipts,
            treatyOutputs: treatyOutputs,
            trace: trace,
            issues: sortedIssues,
            highestSeverity: highestSeverity
        )
    }

    private func baselineIssues(for input: LifeConsequenceEngineInput) -> Set<LifeConsequenceIssue> {
        var issues: Set<LifeConsequenceIssue> = []
        if input.scheduleInstallRecord.canDriveScheduleInstallSegment == false {
            issues.insert(.scheduleInstallBlocked)
        }
        if input.scheduleInstallRecord.installReceipt == nil {
            issues.insert(.missingScheduleInstallReceipt)
        }
        if input.scheduleInstallRecord.rollbackTrace == nil {
            issues.insert(.missingRollbackTrace)
        }
        if input.impacts.isEmpty {
            issues.insert(.missingConsequenceInput)
        }
        if input.localOnly == false || input.scheduleInstallRecord.trace.localOnly == false {
            issues.insert(.nonLocalRuntimeBoundary)
        }
        return issues
    }

    private func severity(for impact: LifeConsequenceImpact, treaties: [LifeConsequenceGoalTreaty]) -> LifeConsequenceSeverity {
        var severity: LifeConsequenceSeverity = .silent
        if impact.deadlineMinutesDelta > 0 || impact.densityMinutesDelta > 0 || impact.proofValueDelta < 0 || impact.recoveryImpact != .none {
            severity = moreSevere(severity, .inform)
        }
        if impact.deadlineMinutesDelta >= 30 || impact.densityMinutesDelta >= 30 || impact.materialDisplacement || impact.sourceAuthority == .stale || impact.sourceAuthority == .reviewRequired || impact.dependencyIDs.isEmpty == false {
            severity = moreSevere(severity, .confirm)
        }
        if impact.deadlineMinutesDelta >= 90 || impact.densityMinutesDelta >= 60 || impact.proofValueDelta <= -25 || impact.recoveryImpact == .heavy {
            severity = moreSevere(severity, .warn)
        }
        if impact.protectedTimeBroken || impact.highRiskReviewRequired || impact.unsafeState || impact.scheduleInstallFailure || impact.sourceAuthority == .revoked || impact.sourceAuthority == .contradicted {
            severity = moreSevere(severity, .block)
        }
        if impact.deadlineMinutesDelta >= 240 || impact.proofValueDelta <= -75 {
            severity = moreSevere(severity, .impossible)
        }
        for treaty in treaties where treaty.participates(in: impact.affectedGoalID) {
            severity = moreSevere(severity, treaty.violationSeverity)
        }
        return severity
    }

    private func visibility(
        for severity: LifeConsequenceSeverity,
        preference: LifeConsequenceVisibilityPreference
    ) -> LifeConsequenceVisibilityState {
        switch severity {
        case .silent:
            return preference == .quiet ? .compressed : .visible
        case .inform:
            return preference == .quiet ? .compressed : .visible
        case .confirm, .warn:
            return .reviewRequired
        case .block, .impossible:
            return .blocked
        }
    }

    private func impactIssues(
        _ impact: LifeConsequenceImpact,
        severity: LifeConsequenceSeverity,
        visibility: LifeConsequenceVisibilityState,
        treaties: [LifeConsequenceGoalTreaty]
    ) -> Set<LifeConsequenceIssue> {
        var issues: Set<LifeConsequenceIssue> = []
        if impact.affectedGoalID.isEmpty || impact.affectedGoalTitle.isEmpty {
            issues.insert(.missingAffectedGoal)
        }
        if impact.isInspectable == false {
            if impact.sourceRecordIDs.isEmpty {
                issues.insert(.missingSourceRecord)
            }
            if impact.receiptIDs.isEmpty {
                issues.insert(.missingReceipt)
            }
            if impact.replayTraceID == nil {
                issues.insert(.missingReplayTrace)
            }
            if impact.whatAmbitionsKnowsRoute == nil {
                issues.insert(.missingInspectionRoute)
            }
        }
        if impact.localOnly == false {
            issues.insert(.nonLocalRuntimeBoundary)
        }
        if impact.reversible == false && severity.isMaterial {
            issues.insert(.irreversibleReflow)
        }
        if impact.protectedTimeBroken {
            issues.insert(.protectedTimeBroken)
        }
        if impact.deadlineMinutesDelta >= 240 || impact.proofValueDelta <= -75 {
            issues.insert(.deadlineImpossible)
        }
        if impact.sourceAuthority == .revoked || impact.sourceAuthority == .contradicted {
            issues.insert(.sourceRevoked)
        }
        if impact.unsafeState {
            issues.insert(.unsafeState)
        }
        if impact.highRiskReviewRequired {
            issues.insert(.highRiskReviewRequired)
        }
        if impact.scheduleInstallFailure {
            issues.insert(.scheduleInstallFailure)
        }
        if severity.order >= LifeConsequenceSeverity.confirm.order && (visibility == .compressed || impact.userVisible == false) {
            issues.insert(.nonSuppressibleEventHidden)
        }
        if severity.isMaterial && impact.userVisible == false {
            issues.insert(.hiddenConsequenceMutation)
        }
        if treaties.contains(where: { $0.violationSeverity.blocksDownstream }) {
            issues.insert(.treatyBlocked)
        }
        if treaties.isEmpty == false && impact.userVisible == false {
            issues.insert(.treatyViolationHidden)
        }
        return issues
    }

    private func makeTreatyOutputs(
        impacts: [LifeConsequenceImpact],
        severitiesByImpact: [String: LifeConsequenceSeverity],
        treatiesByImpact: [String: [LifeConsequenceGoalTreaty]]
    ) -> [LifeConsequenceTreatyOutput] {
        impacts.flatMap { impact in
            (treatiesByImpact[impact.id] ?? []).map { treaty in
                let severity = moreSevere(severitiesByImpact[impact.id] ?? .silent, treaty.violationSeverity)
                let outputID = stableIdentifier(prefix: "life-consequence.treaty", components: [treaty.id, impact.id, severity.rawValue])
                return LifeConsequenceTreatyOutput(
                    id: outputID,
                    treatyID: treaty.id,
                    affectedGoalIDs: normalizedIDs([impact.affectedGoalID] + treaty.participatingGoalIDs),
                    severity: severity,
                    violated: severity.order >= treaty.violationSeverity.order && severity != .silent,
                    consequencePhrase: "\(impact.affectedGoalTitle) changes under \(treaty.title); \(treaty.constraintSummary)",
                    sourceRecordIDs: normalizedIDs(treaty.sourceRecordIDs + impact.sourceRecordIDs),
                    receiptIDs: normalizedIDs(treaty.receiptIDs + impact.receiptIDs + [outputID]),
                    replayTraceID: treaty.replayTraceID ?? impact.replayTraceID ?? "missing-ReplayTrace",
                    whatAmbitionsKnowsRoute: treaty.whatAmbitionsKnowsRoute ?? impact.whatAmbitionsKnowsRoute ?? "you://what-ambitions-knows/life-consequence"
                )
            }
        }
        .sorted { lhs, rhs in
            if lhs.treatyID == rhs.treatyID {
                return lhs.id < rhs.id
            }
            return lhs.treatyID < rhs.treatyID
        }
    }

    private func makeReceipts(
        input: LifeConsequenceEngineInput,
        impacts: [LifeConsequenceImpact],
        severitiesByImpact: [String: LifeConsequenceSeverity],
        visibilityByImpact: [String: LifeConsequenceVisibilityState],
        treatiesByImpact: [String: [LifeConsequenceGoalTreaty]],
        allowReceipts: Bool
    ) -> [LifeConsequenceReceipt] {
        guard allowReceipts else {
            return []
        }
        return impacts.compactMap { impact in
            let severity = severitiesByImpact[impact.id] ?? .silent
            guard severity.isMaterial, impact.isInspectable else {
                return nil
            }
            let treatyIDs = (treatiesByImpact[impact.id] ?? []).map(\.id).sorted()
            let receiptID = stableIdentifier(
                prefix: "life-consequence.receipt",
                components: [
                    input.scheduleInstallRecord.goalReferenceID,
                    impact.id,
                    severity.rawValue,
                    treatyIDs.joined(separator: ",")
                ]
            )
            return LifeConsequenceReceipt(
                id: receiptID,
                impactID: impact.id,
                affectedGoalID: impact.affectedGoalID,
                trigger: impact.trigger,
                severity: severity,
                visibility: visibilityByImpact[impact.id] ?? .visible,
                changedSummary: changedSummary(for: impact),
                consequencePhrase: consequencePhrase(for: impact, severity: severity),
                rollbackState: impact.reversible ? "Reversible through schedule rollback trace \(input.scheduleInstallRecord.rollbackTrace?.id ?? "missing-rollback")" : "Safe stop required before runtime continues",
                treatyIDs: treatyIDs,
                sourceRecordIDs: normalizedIDs(impact.sourceRecordIDs + (input.scheduleInstallRecord.installReceipt?.sourceRecordIDs ?? [])),
                receiptIDs: normalizedIDs(impact.receiptIDs + (input.scheduleInstallRecord.installReceipt?.receiptIDs ?? []) + [receiptID]),
                replayTraceID: impact.replayTraceID ?? input.scheduleInstallRecord.trace.id,
                whatAmbitionsKnowsRoute: impact.whatAmbitionsKnowsRoute ?? "you://what-ambitions-knows/life-consequence/\(impact.affectedGoalID)",
                reversible: impact.reversible && input.scheduleInstallRecord.rollbackTrace?.reversible == true,
                localOnly: impact.localOnly && input.localOnly
            )
        }
        .sorted { lhs, rhs in
            if lhs.affectedGoalID == rhs.affectedGoalID {
                return lhs.id < rhs.id
            }
            return lhs.affectedGoalID < rhs.affectedGoalID
        }
    }

    private func makeTrace(
        input: LifeConsequenceEngineInput,
        receipts: [LifeConsequenceReceipt],
        treatyOutputs: [LifeConsequenceTreatyOutput],
        issues: [LifeConsequenceIssue]
    ) -> LifeConsequenceTrace {
        let receiptIDs = receipts.map(\.id).sorted()
        let treatyOutputIDs = treatyOutputs.map(\.id).sorted()
        let issueIDs = issues.map(\.rawValue)
        let replayTraceIDs = normalizedIDs(
            receipts.map(\.replayTraceID) +
                treatyOutputs.map(\.replayTraceID) +
                input.scheduleInstallRecord.trace.replayTraceIDs
        )
        let fingerprint = stableIdentifier(
            prefix: "life-consequence.fingerprint",
            components: [
                input.scheduleInstallRecord.trace.id,
                receiptIDs.joined(separator: ","),
                treatyOutputIDs.joined(separator: ","),
                issueIDs.joined(separator: ","),
                input.visibilityPreference.rawValue
            ]
        )
        return LifeConsequenceTrace(
            id: stableIdentifier(prefix: "life-consequence.trace", components: [input.scheduleInstallRecord.goalReferenceID, fingerprint]),
            goalReferenceID: input.scheduleInstallRecord.goalReferenceID,
            scheduleInstallTraceID: input.scheduleInstallRecord.trace.id,
            receiptIDs: receiptIDs,
            treatyOutputIDs: treatyOutputIDs,
            issueIDs: issueIDs,
            replayTraceIDs: replayTraceIDs,
            fingerprint: fingerprint,
            localOnly: input.localOnly && input.scheduleInstallRecord.trace.localOnly
        )
    }

    private func changedSummary(for impact: LifeConsequenceImpact) -> String {
        [
            "deadline \(impact.deadlineMinutesDelta)m",
            "density \(impact.densityMinutesDelta)m",
            "proof \(impact.proofValueDelta)",
            "recovery \(impact.recoveryImpact.rawValue)",
            "source \(impact.sourceAuthority.rawValue)"
        ].joined(separator: "; ")
    }

    private func consequencePhrase(for impact: LifeConsequenceImpact, severity: LifeConsequenceSeverity) -> String {
        switch severity {
        case .silent:
            return "\(impact.affectedGoalTitle) has no material consequence."
        case .inform:
            return "\(impact.affectedGoalTitle) changes lightly and stays inspectable."
        case .confirm:
            return "\(impact.affectedGoalTitle) needs review before the plan changes."
        case .warn:
            return "\(impact.affectedGoalTitle) carries material pressure and must stay visible."
        case .block:
            return "\(impact.affectedGoalTitle) cannot continue under the current constraint."
        case .impossible:
            return "\(impact.affectedGoalTitle) is not viable without changing scope, source, capacity, or deadline."
        }
    }

    private func moreSevere(_ lhs: LifeConsequenceSeverity, _ rhs: LifeConsequenceSeverity) -> LifeConsequenceSeverity {
        lhs.order >= rhs.order ? lhs : rhs
    }

    private func stableIdentifier(prefix: String, components: [String]) -> String {
        ([prefix] + components.map { normalizedToken($0) })
            .filter { $0.isEmpty == false }
            .joined(separator: ".")
    }

    private func normalizedToken(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.isEmpty == false }
            .joined(separator: "-")
    }

    private func normalizedIDs(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

private extension LifeConsequenceRecord {
    func normalizedIDs(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}
