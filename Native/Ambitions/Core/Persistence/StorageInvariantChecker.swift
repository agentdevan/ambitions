import AmbitionsDesignSystem
import Foundation
import SwiftData

let storageInvariantCheckerSchemaVersion = "storage_invariant_checker.native.v1"

enum StorageInvariantSeverity: String, Sendable, Equatable, Hashable {
    case advisory
    case blocker
}

enum StorageInvariantIssueKind: String, Sendable, Equatable, Hashable {
    case emptyRequiredValue = "empty_required_value"
    case missingReferencedRecord = "missing_referenced_record"
    case malformedEncodedPayload = "malformed_encoded_payload"
    case malformedSnapshotPayload = "malformed_snapshot_payload"
    case unknownRawValue = "unknown_raw_value"
}

struct StorageInvariantIssue: Identifiable, Sendable, Equatable, Hashable {
    let id: String
    let storedTypeName: String
    let recordID: String
    let fieldName: String
    let kind: StorageInvariantIssueKind
    let severity: StorageInvariantSeverity
    let message: String
    let degradation: PersistedValueDegradationEntry?

    init(
        storedTypeName: String,
        recordID: String,
        fieldName: String,
        kind: StorageInvariantIssueKind,
        severity: StorageInvariantSeverity = .blocker,
        message: String,
        degradation: PersistedValueDegradationEntry? = nil
    ) {
        self.id = "\(storedTypeName).\(recordID).\(fieldName).\(kind.rawValue)"
        self.storedTypeName = storedTypeName
        self.recordID = recordID
        self.fieldName = fieldName
        self.kind = kind
        self.severity = severity
        self.message = message
        self.degradation = degradation
    }
}

struct StorageInvariantReport: Sendable, Equatable {
    let schemaVersion: String
    let ledgerSchemaVersion: String
    let issueCount: Int
    let blockerCount: Int
    let issues: [StorageInvariantIssue]
    let migrationExecutionAllowed: Bool

    var isGreen: Bool {
        blockerCount == 0 && migrationExecutionAllowed == false
    }

    init(
        schemaVersion: String = storageInvariantCheckerSchemaVersion,
        ledgerSchemaVersion: String = StorageSchemaVersionLedger.current.schemaVersion,
        issues: [StorageInvariantIssue],
        migrationExecutionAllowed: Bool = false
    ) {
        self.schemaVersion = schemaVersion
        self.ledgerSchemaVersion = ledgerSchemaVersion
        self.issueCount = issues.count
        self.blockerCount = issues.filter { $0.severity == .blocker }.count
        self.issues = issues
        self.migrationExecutionAllowed = migrationExecutionAllowed
    }
}

struct StorageInvariantChecker: Sendable {
    func check(store: AmbitionsPersistenceStore) async throws -> StorageInvariantReport {
        try await store.read { context in
            try check(context: context)
        }
    }

    func check(context: ModelContext) throws -> StorageInvariantReport {
        let goals = try context.fetch(FetchDescriptor<GoalRecord>())
        let drafts = try context.fetch(FetchDescriptor<GoalDraftRecord>())
        let plans = try context.fetch(FetchDescriptor<GoalPlanRecord>())
        let sections = try context.fetch(FetchDescriptor<PlanSectionRecord>())
        let steps = try context.fetch(FetchDescriptor<StepRecord>())
        let evidence = try context.fetch(FetchDescriptor<ProgressEvidenceRecord>())
        let feedback = try context.fetch(FetchDescriptor<FeedbackEventRecord>())
        let captures = try context.fetch(FetchDescriptor<CaptureRecord>())
        let teaching = try context.fetch(FetchDescriptor<TeachingSignalRecord>())
        let events = try context.fetch(FetchDescriptor<EventLedgerRecord>())
        let sideEffects = try context.fetch(FetchDescriptor<SideEffectLedgerStorageRecord>())
        let appStates = try context.fetch(FetchDescriptor<AppStateRecord>())
        let lifeContextBundles = try context.fetch(FetchDescriptor<LifeContextBundleRecord>())

        let goalIDs = Set(goals.map(\.id))
        let planIDs = Set(plans.map(\.id))
        let sectionIDs = Set(sections.map(\.id))
        let stepIDs = Set(steps.map(\.id))
        let captureIDs = Set(captures.map(\.id))

        var issues: [StorageInvariantIssue] = []

        for record in goals {
            appendRequired(record.id, "GoalRecord", record.id, "id", to: &issues)
            appendRequired(record.title, "GoalRecord", record.id, "title", to: &issues)
            appendRaw(GoalLifecycleState.self, record.stateRaw, .active, "GoalRecord", record.id, "stateRaw", to: &issues)
            appendRaw(GoalMode.self, record.modeRaw, .project, "GoalRecord", record.id, "modeRaw", to: &issues)
            appendRaw(GoalRelationshipKind.self, record.relationshipKindRaw, .independent, "GoalRecord", record.id, "relationshipKindRaw", to: &issues)
            appendRaw(ExecutionOwnership.self, record.actorOwnershipRaw, .self, "GoalRecord", record.id, "actorOwnershipRaw", to: &issues)
            appendRaw(GoalTempo.self, record.tempoRaw, .untimed, "GoalRecord", record.id, "tempoRaw", to: &issues)
            appendRaw(TimingType.self, record.timingTypeRaw, .logWhenDone, "GoalRecord", record.id, "timingTypeRaw", to: &issues)
            appendDecodable([String].self, record.childGoalIDsData, "GoalRecord", record.id, "childGoalIDsData", to: &issues)
            appendDecodable([String].self, record.supportGoalIDsData, "GoalRecord", record.id, "supportGoalIDsData", to: &issues)
            appendDecodable([String].self, record.tagsData, "GoalRecord", record.id, "tagsData", to: &issues)
            appendJSON(record.snapshotData, "GoalRecord", record.id, "snapshotData", to: &issues)
        }

        for record in drafts {
            appendRequired(record.id, "GoalDraftRecord", record.id, "id", to: &issues)
            appendRequired(record.title, "GoalDraftRecord", record.id, "title", to: &issues)
            appendJSON(record.snapshotData, "GoalDraftRecord", record.id, "snapshotData", to: &issues)
        }

        for record in plans {
            appendReference(record.goalID, in: goalIDs, "GoalPlanRecord", record.id, "goalID", to: &issues)
            appendJSON(record.snapshotData, "GoalPlanRecord", record.id, "snapshotData", to: &issues)
        }

        for record in sections {
            appendReference(record.goalID, in: goalIDs, "PlanSectionRecord", record.id, "goalID", to: &issues)
            appendReference(record.planID, in: planIDs, "PlanSectionRecord", record.id, "planID", to: &issues)
            appendRaw(PlanSectionKind.self, record.kindRaw, .overview, "PlanSectionRecord", record.id, "kindRaw", to: &issues)
        }

        for record in steps {
            appendReference(record.goalID, in: goalIDs, "StepRecord", record.id, "goalID", to: &issues)
            appendReference(record.planID, in: planIDs, "StepRecord", record.id, "planID", to: &issues)
            appendReference(record.sectionID, in: sectionIDs, "StepRecord", record.id, "sectionID", to: &issues)
            appendRequired(record.title, "StepRecord", record.id, "title", to: &issues)
            appendRaw(StepType.self, record.typeRaw, .actionUnit, "StepRecord", record.id, "typeRaw", to: &issues)
            appendRaw(StepLifecycleState.self, record.stateRaw, .planned, "StepRecord", record.id, "stateRaw", to: &issues)
            appendRaw(ExecutionOwnership.self, record.ownerOwnershipRaw, .self, "StepRecord", record.id, "ownerOwnershipRaw", to: &issues)
            appendRaw(GoalTempo.self, record.tempoRaw, .untimed, "StepRecord", record.id, "tempoRaw", to: &issues)
            appendRaw(TimingType.self, record.timingTypeRaw, .logWhenDone, "StepRecord", record.id, "timingTypeRaw", to: &issues)
            appendDecodable([String].self, record.dependencyStepIDsData, "StepRecord", record.id, "dependencyStepIDsData", to: &issues)
            appendJSON(record.snapshotData, "StepRecord", record.id, "snapshotData", to: &issues)
        }

        for record in evidence {
            appendReference(record.goalID, in: goalIDs, "ProgressEvidenceRecord", record.id, "goalID", to: &issues)
            if let stepID = record.stepID {
                appendReference(stepID, in: stepIDs, "ProgressEvidenceRecord", record.id, "stepID", to: &issues)
            }
            appendRaw(ProgressEvidenceKind.self, record.evidenceKindRaw, .stepCompleted, "ProgressEvidenceRecord", record.id, "evidenceKindRaw", to: &issues)
            appendRaw(EvidenceSource.self, record.sourceRaw, .manual, "ProgressEvidenceRecord", record.id, "sourceRaw", to: &issues)
            appendJSON(record.snapshotData, "ProgressEvidenceRecord", record.id, "snapshotData", to: &issues)
        }

        for record in feedback {
            appendReference(record.goalID, in: goalIDs, "FeedbackEventRecord", record.id, "goalID", to: &issues)
            appendReference(record.stepID, in: stepIDs, "FeedbackEventRecord", record.id, "stepID", to: &issues)
            appendJSON(record.payloadData, "FeedbackEventRecord", record.id, "payloadData", to: &issues)
        }

        for record in captures {
            appendRequired(record.rawText, "CaptureRecord", record.id, "rawText", to: &issues)
            appendOptionalRaw(CaptureSourceType.self, record.sourceTypeRaw, "CaptureRecord", record.id, "sourceTypeRaw", to: &issues)
            appendRaw(CaptureStatus.self, record.statusRaw, .actionable, "CaptureRecord", record.id, "statusRaw", legacyAliases: ["pending": .actionable, "processed": .goalBound], to: &issues)
            if let linkedGoalID = record.linkedGoalID {
                appendReference(linkedGoalID, in: goalIDs, "CaptureRecord", record.id, "linkedGoalID", to: &issues)
            }
            appendJSON(record.snapshotData, "CaptureRecord", record.id, "snapshotData", to: &issues)
        }

        for record in teaching {
            appendReference(record.goalID, in: goalIDs, "TeachingSignalRecord", record.id, "goalID", to: &issues)
            appendJSON(record.snapshotData, "TeachingSignalRecord", record.id, "snapshotData", to: &issues)
        }

        for record in events {
            if let goalID = record.goalID {
                appendReference(goalID, in: goalIDs, "EventLedgerRecord", record.id, "goalID", to: &issues)
            }
            if let captureID = record.captureID {
                appendReference(captureID, in: captureIDs, "EventLedgerRecord", record.id, "captureID", to: &issues)
            }
            if let planID = record.planID {
                appendReference(planID, in: planIDs, "EventLedgerRecord", record.id, "planID", to: &issues)
            }
            appendRequired(record.title, "EventLedgerRecord", record.id, "title", to: &issues)
            appendRaw(EventLedgerKind.self, record.kindRaw, .goalUpdated, "EventLedgerRecord", record.id, "kindRaw", to: &issues)
            appendRaw(EventLedgerSource.self, record.sourceRaw, .system, "EventLedgerRecord", record.id, "sourceRaw", to: &issues)
            appendRaw(EventLedgerTone.self, record.toneRaw, .neutral, "EventLedgerRecord", record.id, "toneRaw", to: &issues)
            appendRaw(EventLedgerPrivacyClassification.self, record.privacyRaw, .standard, "EventLedgerRecord", record.id, "privacyRaw", to: &issues)
            appendJSON(record.snapshotData, "EventLedgerRecord", record.id, "snapshotData", to: &issues)
        }

        for record in sideEffects {
            appendRequired(record.id, "SideEffectLedgerStorageRecord", record.id, "id", to: &issues)
            appendRaw(SideEffectLedgerEffectKind.self, record.effectKindRaw, .unknown, "SideEffectLedgerStorageRecord", record.id, "effectKindRaw", to: &issues)
            appendRaw(SideEffectLedgerStatus.self, record.statusRaw, .blocked, "SideEffectLedgerStorageRecord", record.id, "statusRaw", to: &issues)
            appendRaw(SideEffectLedgerBoundary.self, record.boundaryRaw, .unsupported, "SideEffectLedgerStorageRecord", record.id, "boundaryRaw", to: &issues)
            appendRaw(SafeAutomationActionKind.self, record.actionKindRaw, .noOp, "SideEffectLedgerStorageRecord", record.id, "actionKindRaw", to: &issues)
            appendRaw(ActionReceiptSourceDomain.self, record.sourceDomainRaw, .today, "SideEffectLedgerStorageRecord", record.id, "sourceDomainRaw", to: &issues)
            appendDecodable([LifeGraphObjectReference].self, record.targetObjectsData, "SideEffectLedgerStorageRecord", record.id, "targetObjectsData", to: &issues)
            appendDecodable([SafeAutomationPolicyReason].self, record.reasonsData, "SideEffectLedgerStorageRecord", record.id, "reasonsData", to: &issues)
            appendDecodable([String].self, record.blockedFactsData, "SideEffectLedgerStorageRecord", record.id, "blockedFactsData", to: &issues)
            appendDecodable([String].self, record.degradedFactsData, "SideEffectLedgerStorageRecord", record.id, "degradedFactsData", to: &issues)
            appendJSON(record.snapshotData, "SideEffectLedgerStorageRecord", record.id, "snapshotData", to: &issues)
        }

        for record in appStates {
            appendRaw(AmbitionsSurface.self, record.preferredTabRaw, .today, "AppStateRecord", record.id, "preferredTabRaw", to: &issues)
            appendRaw(AppAppearancePreference.self, record.appearancePreferenceRaw, .system, "AppStateRecord", record.id, "appearancePreferenceRaw", to: &issues)
            appendOptionalRaw(AmbitionAccentFamily.self, record.accentFamilyRaw, "AppStateRecord", record.id, "accentFamilyRaw", to: &issues)
            appendOptionalRaw(AppSession.BootstrapSource.self, record.lastBootstrapSourceRaw, "AppStateRecord", record.id, "lastBootstrapSourceRaw", to: &issues)
            if let lastOpenedGoalID = record.lastOpenedGoalID {
                appendReference(lastOpenedGoalID, in: goalIDs, "AppStateRecord", record.id, "lastOpenedGoalID", to: &issues)
            }
            appendJSON(record.snapshotData, "AppStateRecord", record.id, "snapshotData", to: &issues)
        }

        for record in lifeContextBundles {
            appendRequired(record.id, "LifeContextBundleRecord", record.id, "id", to: &issues)
            appendRequired(record.schemaVersion, "LifeContextBundleRecord", record.id, "schemaVersion", to: &issues)
            appendJSON(record.snapshotData, "LifeContextBundleRecord", record.id, "snapshotData", to: &issues)
        }

        return StorageInvariantReport(issues: issues.sorted { $0.id < $1.id })
    }

    private func appendRequired(
        _ value: String,
        _ storedTypeName: String,
        _ recordID: String,
        _ fieldName: String,
        to issues: inout [StorageInvariantIssue]
    ) {
        if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            issues.append(StorageInvariantIssue(
                storedTypeName: storedTypeName,
                recordID: recordID,
                fieldName: fieldName,
                kind: .emptyRequiredValue,
                message: "\(storedTypeName).\(fieldName) must not be empty."
            ))
        }
    }

    private func appendReference(
        _ value: String,
        in validIDs: Set<String>,
        _ storedTypeName: String,
        _ recordID: String,
        _ fieldName: String,
        to issues: inout [StorageInvariantIssue]
    ) {
        if validIDs.contains(value) == false {
            issues.append(StorageInvariantIssue(
                storedTypeName: storedTypeName,
                recordID: recordID,
                fieldName: fieldName,
                kind: .missingReferencedRecord,
                message: "\(storedTypeName).\(fieldName) references missing record \(value)."
            ))
        }
    }

    private func appendDecodable<Value: Decodable>(
        _ type: Value.Type,
        _ data: Data,
        _ storedTypeName: String,
        _ recordID: String,
        _ fieldName: String,
        to issues: inout [StorageInvariantIssue]
    ) {
        do {
            _ = try PersistenceCoding.decode(type, from: data)
        } catch {
            issues.append(StorageInvariantIssue(
                storedTypeName: storedTypeName,
                recordID: recordID,
                fieldName: fieldName,
                kind: .malformedEncodedPayload,
                message: "\(storedTypeName).\(fieldName) could not be decoded."
            ))
        }
    }

    private func appendJSON(
        _ data: Data,
        _ storedTypeName: String,
        _ recordID: String,
        _ fieldName: String,
        to issues: inout [StorageInvariantIssue]
    ) {
        do {
            _ = try JSONSerialization.jsonObject(with: data)
        } catch {
            issues.append(StorageInvariantIssue(
                storedTypeName: storedTypeName,
                recordID: recordID,
                fieldName: fieldName,
                kind: .malformedSnapshotPayload,
                message: "\(storedTypeName).\(fieldName) is not valid JSON."
            ))
        }
    }

    private func appendRaw<Value>(
        _ type: Value.Type,
        _ rawValue: String,
        _ fallback: Value,
        _ storedTypeName: String,
        _ recordID: String,
        _ fieldName: String,
        legacyAliases: [String: Value] = [:],
        to issues: inout [StorageInvariantIssue]
    ) where Value: RawRepresentable & Sendable & Equatable, Value.RawValue == String {
        let result = PersistedValueDegradation.resolve(
            type,
            rawValue: rawValue,
            fallback: fallback,
            storedTypeName: storedTypeName,
            fieldName: fieldName,
            legacyAliases: legacyAliases
        )
        appendDegradation(result.degradation, storedTypeName, recordID, fieldName, to: &issues)
    }

    private func appendOptionalRaw<Value>(
        _ type: Value.Type,
        _ rawValue: String?,
        _ storedTypeName: String,
        _ recordID: String,
        _ fieldName: String,
        legacyAliases: [String: Value] = [:],
        to issues: inout [StorageInvariantIssue]
    ) where Value: RawRepresentable & Sendable & Equatable, Value.RawValue == String {
        let result = PersistedValueDegradation.resolveOptional(
            type,
            rawValue: rawValue,
            storedTypeName: storedTypeName,
            fieldName: fieldName,
            legacyAliases: legacyAliases
        )
        appendDegradation(result.degradation, storedTypeName, recordID, fieldName, to: &issues)
    }

    private func appendDegradation(
        _ degradation: PersistedValueDegradationEntry?,
        _ storedTypeName: String,
        _ recordID: String,
        _ fieldName: String,
        to issues: inout [StorageInvariantIssue]
    ) {
        guard let degradation else { return }
        issues.append(StorageInvariantIssue(
            storedTypeName: storedTypeName,
            recordID: recordID,
            fieldName: fieldName,
            kind: .unknownRawValue,
            severity: degradation.requiresReview ? .blocker : .advisory,
            message: "\(storedTypeName).\(fieldName) degraded persisted raw value.",
            degradation: degradation
        ))
    }
}
