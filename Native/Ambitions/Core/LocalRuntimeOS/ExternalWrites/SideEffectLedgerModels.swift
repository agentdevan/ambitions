import Foundation

let sideEffectLedgerSchemaVersion = "side_effect_ledger.native.v1"

enum SideEffectLedgerEffectKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case localOnly = "local_only"
    case notification
    case calendar
    case externalSnapshot = "external_snapshot"
    case export
    case sync
    case destructiveDataChange = "destructive_data_change"
    case privacyMemory = "privacy_memory"
    case commandBridge = "command_bridge"
    case unknown
}

enum SideEffectLedgerStatus: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case proposed
    case queued
    case leased
    case succeeded
    case preparedDraft = "prepared_draft"
    case confirmationRequired = "confirmation_required"
    case blocked
    case failedSafely = "failed_safely"
    case recordedLocalOnly = "recorded_local_only"
    case unsupported
}

enum SideEffectLedgerBoundary: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case localOnly = "local_only"
    case confirmationGate = "confirmation_gate"
    case externalEffect = "external_effect"
    case destructive = "destructive"
    case privacySensitive = "privacy_sensitive"
    case unsupported
}

struct SideEffectLedgerRecord: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let effectKind: SideEffectLedgerEffectKind
    let status: SideEffectLedgerStatus
    let boundary: SideEffectLedgerBoundary
    let actionKind: SafeAutomationActionKind
    let sourceDomain: ActionReceiptSourceDomain
    let commandID: String?
    let claimToken: String?
    let leaseID: String?
    let leasedAt: String?
    let leaseExpiresAt: String?
    let targetObjects: [LifeGraphObjectReference]
    let occurredAt: String
    let localOnly: Bool
    let requiresConfirmation: Bool
    let externalEffect: Bool
    let reasons: [SafeAutomationPolicyReason]
    let blockedFacts: [String]
    let degradedFacts: [String]
    let receiptID: String?
    let schemaVersion: String

    init(
        id: String,
        effectKind: SideEffectLedgerEffectKind,
        status: SideEffectLedgerStatus,
        boundary: SideEffectLedgerBoundary,
        actionKind: SafeAutomationActionKind,
        sourceDomain: ActionReceiptSourceDomain,
        commandID: String? = nil,
        claimToken: String? = nil,
        leaseID: String? = nil,
        leasedAt: String? = nil,
        leaseExpiresAt: String? = nil,
        targetObjects: [LifeGraphObjectReference] = [],
        occurredAt: String,
        localOnly: Bool = true,
        requiresConfirmation: Bool,
        externalEffect: Bool,
        reasons: [SafeAutomationPolicyReason] = [],
        blockedFacts: [String] = [],
        degradedFacts: [String] = [],
        receiptID: String? = nil,
        schemaVersion: String = sideEffectLedgerSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.effectKind = effectKind
        self.status = status
        self.boundary = boundary
        self.actionKind = actionKind
        self.sourceDomain = sourceDomain
        self.commandID = commandID?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        self.claimToken = claimToken?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        self.leaseID = leaseID?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        self.leasedAt = leasedAt?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        self.leaseExpiresAt = leaseExpiresAt?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        self.targetObjects = Self.orderedUniqueTargets(targetObjects)
        self.occurredAt = occurredAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.localOnly = localOnly
        self.requiresConfirmation = requiresConfirmation
        self.externalEffect = externalEffect
        self.reasons = Self.orderedUniqueReasons(reasons)
        self.blockedFacts = Self.normalizedUnique(blockedFacts)
        self.degradedFacts = Self.normalizedUnique(degradedFacts)
        self.receiptID = receiptID?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        self.schemaVersion = schemaVersion
    }

    init(
        decision: SafeAutomationPolicyDecision,
        commandID: String? = nil,
        occurredAt: String,
        receiptID: String? = nil
    ) {
        self.init(
            id: Self.recordID(decision: decision, commandID: commandID),
            effectKind: SideEffectLedgerEffectKind(actionKind: decision.actionKind),
            status: SideEffectLedgerStatus(decision: decision),
            boundary: SideEffectLedgerBoundary(decision: decision),
            actionKind: decision.actionKind,
            sourceDomain: decision.sourceDomain,
            commandID: commandID,
            targetObjects: decision.targetObjects,
            occurredAt: occurredAt,
            localOnly: true,
            requiresConfirmation: decision.requiresExplicitUserConfirmation,
            externalEffect: decision.safetyClassification == .externalEffect,
            reasons: decision.reasons,
            blockedFacts: decision.blockedFacts,
            degradedFacts: decision.degradedFacts,
            receiptID: receiptID
        )
    }

    var isWellFormed: Bool {
        id.isEmpty == false && occurredAt.isEmpty == false && schemaVersion == sideEffectLedgerSchemaVersion
    }

    var mayExecuteWithoutUserConfirmation: Bool {
        localOnly && externalEffect == false && requiresConfirmation == false && status == .recordedLocalOnly
    }

    static func fromCommand(
        _ command: AmbitionsCommand,
        occurredAt: String,
        evaluator: SafeAutomationPolicyEvaluator = SafeAutomationPolicyEvaluator()
    ) -> SideEffectLedgerRecord {
        let decision = evaluator.evaluate(SafeAutomationProposedAction.fromCommand(command))
        return SideEffectLedgerRecord(decision: decision, commandID: command.id, occurredAt: occurredAt)
    }

    private static func recordID(decision: SafeAutomationPolicyDecision, commandID: String?) -> String {
        let commandComponent = commandID?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty ?? "policy"
        return "side-effect.\(commandComponent).\(decision.id)"
            .replacingOccurrences(of: " ", with: "_")
            .lowercased()
    }

    private static func orderedUniqueTargets(_ targets: [LifeGraphObjectReference]) -> [LifeGraphObjectReference] {
        var seen = Set<String>()
        return targets
            .filter(\.isWellFormed)
            .filter { seen.insert($0.stableKey).inserted }
            .sorted { lhs, rhs in lhs.stableKey < rhs.stableKey }
    }

    private static func orderedUniqueReasons(_ reasons: [SafeAutomationPolicyReason]) -> [SafeAutomationPolicyReason] {
        var seen = Set<SafeAutomationPolicyReason>()
        return reasons.filter { seen.insert($0).inserted }
    }

    private static func normalizedUnique(_ values: [String]) -> [String] {
        let normalized = values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
        return Array(Set(normalized)).sorted()
    }
}

extension SideEffectLedgerEffectKind {
    init(actionKind: SafeAutomationActionKind) {
        switch actionKind {
        case .prepareCalendarBlock, .writeCalendarBlock:
            self = .calendar
        case .prepareExport, .performExport:
            self = .export
        case .prepareSyncResolution, .applySyncResolution:
            self = .sync
        case .deleteObject:
            self = .destructiveDataChange
        case .forgetMemory:
            self = .privacyMemory
        case .externalCommand:
            self = .commandBridge
        case .createCapture, .routeCapture, .attachToGoal, .detachFromGoal,
             .archiveItem, .unarchiveItem, .markWaiting, .markDone,
             .moveActionLater, .changePriority, .changeDeadline, .changeTimeWindow,
             .shrinkAction, .splitAction, .dropAction, .deferAction,
             .correctRecommendation, .editLocalNote, .dismissSuggestion, .noOp:
            self = .localOnly
        }
    }
}

extension SideEffectLedgerStatus {
    init(decision: SafeAutomationPolicyDecision) {
        switch decision.receiptRecommendation.resultState {
        case .draftedPrepared, .exportedPrepared:
            self = .preparedDraft
        case .needsConfirmation:
            self = .confirmationRequired
        case .failedSafely:
            self = .failedSafely
        case .noOp:
            self = .recordedLocalOnly
        default:
            self = Self(permissionLevel: decision.permissionLevel)
        }
    }

    private init(permissionLevel: SafeAutomationPermissionLevel) {
        switch permissionLevel {
        case .executeLocalOnly:
            self = .recordedLocalOnly
        case .prepareDraft:
            self = .preparedDraft
        case .requiresConfirmation:
            self = .confirmationRequired
        case .neverAutomate:
            self = .blocked
        case .notSupportedYet:
            self = .unsupported
        case .suggestOnly:
            self = .proposed
        }
    }
}

extension SideEffectLedgerBoundary {
    init(decision: SafeAutomationPolicyDecision) {
        switch decision.safetyClassification {
        case .safeLocal, .reversibleLocal:
            self = .localOnly
        case .confirmationGated, .broadPlanMutation:
            self = .confirmationGate
        case .externalEffect:
            self = .externalEffect
        case .destructive:
            self = .destructive
        case .privacySensitive:
            self = .privacySensitive
        case .unsupported, .unsafe:
            self = .unsupported
        }
    }
}

protocol SideEffectLedgerRepository: Sendable {
    func append(_ record: SideEffectLedgerRecord) async throws
    func fetchRecent(limit: Int) async throws -> [SideEffectLedgerRecord]
    func fetchRecords(status: SideEffectLedgerStatus) async throws -> [SideEffectLedgerRecord]
    func fetchRecord(id: String) async throws -> SideEffectLedgerRecord?
    func claim(_ record: SideEffectLedgerRecord, token: String) async throws -> SideEffectLedgerClaimResult
    func finalize(_ record: SideEffectLedgerRecord, token: String) async throws -> Bool
}

enum SideEffectLedgerClaimResult: Sendable, Equatable {
    case claimed(SideEffectLedgerRecord)
    case existing(SideEffectLedgerRecord)
}

actor InMemorySideEffectLedgerRepository: SideEffectLedgerRepository {
    private var records: [SideEffectLedgerRecord] = []

    func append(_ record: SideEffectLedgerRecord) async throws {
        guard record.isWellFormed else { return }
        records.removeAll { $0.id == record.id }
        records.append(record)
    }

    func fetchRecent(limit: Int) async throws -> [SideEffectLedgerRecord] {
        Array(records.sorted(by: Self.sort).prefix(max(0, limit)))
    }

    func fetchRecords(status: SideEffectLedgerStatus) async throws -> [SideEffectLedgerRecord] {
        records.filter { $0.status == status }.sorted(by: Self.sort)
    }

    func fetchRecord(id: String) async throws -> SideEffectLedgerRecord? {
        records.first { $0.id == id }
    }

    func claim(_ record: SideEffectLedgerRecord, token: String) async throws -> SideEffectLedgerClaimResult {
        if let existing = records.first(where: { $0.id == record.id }) {
            return .existing(existing)
        }
        let claimed = record.claiming(token: token)
        records.append(claimed)
        return .claimed(claimed)
    }

    func finalize(_ record: SideEffectLedgerRecord, token: String) async throws -> Bool {
        guard let index = records.firstIndex(where: { $0.id == record.id }),
              records[index].claimToken == token else { return false }
        records[index] = record.finalized()
        return true
    }

    private static func sort(_ lhs: SideEffectLedgerRecord, _ rhs: SideEffectLedgerRecord) -> Bool {
        if lhs.occurredAt != rhs.occurredAt {
            return lhs.occurredAt > rhs.occurredAt
        }
        return lhs.id < rhs.id
    }
}

extension SideEffectLedgerRecord {
    func claiming(token: String) -> SideEffectLedgerRecord {
        SideEffectLedgerRecord(
            id: id,
            effectKind: effectKind,
            status: .leased,
            boundary: boundary,
            actionKind: actionKind,
            sourceDomain: sourceDomain,
            commandID: commandID,
            claimToken: token,
            leaseID: leaseID,
            leasedAt: leasedAt,
            leaseExpiresAt: leaseExpiresAt,
            targetObjects: targetObjects,
            occurredAt: occurredAt,
            localOnly: localOnly,
            requiresConfirmation: requiresConfirmation,
            externalEffect: externalEffect,
            reasons: reasons,
            blockedFacts: blockedFacts,
            degradedFacts: degradedFacts,
            receiptID: receiptID,
            schemaVersion: schemaVersion
        )
    }

    func finalized() -> SideEffectLedgerRecord {
        SideEffectLedgerRecord(
            id: id,
            effectKind: effectKind,
            status: status,
            boundary: boundary,
            actionKind: actionKind,
            sourceDomain: sourceDomain,
            commandID: commandID,
            targetObjects: targetObjects,
            occurredAt: occurredAt,
            localOnly: localOnly,
            requiresConfirmation: requiresConfirmation,
            externalEffect: externalEffect,
            reasons: reasons,
            blockedFacts: blockedFacts,
            degradedFacts: degradedFacts,
            receiptID: receiptID,
            schemaVersion: schemaVersion
        )
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
