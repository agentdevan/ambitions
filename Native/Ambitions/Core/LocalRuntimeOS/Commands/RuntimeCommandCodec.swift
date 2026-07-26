import AmbitionsDesignSystem
import Foundation

let runtimeCommandSchemaVersion = 2

protocol LegacyRuntimeCommandShape {
    var id: String { get }
    var kind: AmbitionsCommandKind { get }
    var target: AmbitionsCommandTarget { get }
    var payload: AmbitionsCommandPayload { get }
}

struct LegacyRuntimeCommandInput: LegacyRuntimeCommandShape {
    let id: String
    let kind: AmbitionsCommandKind
    let target: AmbitionsCommandTarget
    let payload: AmbitionsCommandPayload
}

struct RuntimeCommandObjectID: RawRepresentable, Codable, Sendable, Equatable, Hashable {
    let rawValue: String

    init?(rawValue: String) {
        guard let value = RuntimeDomainObjectID(rawValue: rawValue), value.rawValue == rawValue else { return nil }
        self.rawValue = value.rawValue
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        guard let value = Self(rawValue: raw) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid command object identity.")
        }
        self = value
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

struct RuntimeCommandReceiptID: RawRepresentable, Codable, Sendable, Equatable, Hashable {
    let rawValue: String

    init?(rawValue: String) {
        guard let value = RuntimeReceiptID(rawValue: rawValue), value.rawValue == rawValue else { return nil }
        self.rawValue = value.rawValue
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        guard let value = Self(rawValue: raw) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid command receipt identity.")
        }
        self = value
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

struct RuntimeCommandContent: Codable, Sendable, Equatable, Hashable {
    let rawText: String?
    let title: String?
    let notes: String?
    let dueText: String?
    let deadlineText: String?
    let contextLens: NowContextLens?
    let commitmentKind: NowCommitmentKind?
    let priorityHints: AmbitionsCommandPriorityHints
    let goalRelationship: NowGoalPressureKind?
    let destinationRoute: CaptureRoute?
    let explanationID: String?

    init(_ payload: AmbitionsCommandPayload = AmbitionsCommandPayload()) {
        rawText = payload.rawText
        title = payload.title
        notes = payload.notes
        dueText = payload.dueText
        deadlineText = payload.deadlineText
        contextLens = payload.contextLens
        commitmentKind = payload.commitmentKind
        priorityHints = payload.priorityHints
        goalRelationship = payload.goalRelationship
        destinationRoute = payload.destinationRoute.flatMap(CaptureRoute.init(rawValue:))
        explanationID = payload.explanationID
    }

    var primaryText: String? { rawText ?? title }

}

struct ExternalCreationProvenance: Codable, Sendable, Equatable {
    let requestID: String
    let source: ExternalCreationSource
    let sourceApplication: String?
    let sourceURL: String?
    let sourceType: CaptureSourceType
    let landing: ExternalCreationLanding
    let provenanceHint: String?
}

enum CalendarDisplacedDisposition: String, Codable, Sendable, Equatable, Hashable {
    case held
    case notDisplaced = "not_displaced"
}

enum CalendarLifeShapeImpact: String, Codable, Sendable, Equatable, Hashable {
    case pressureShiftsProtected = "pressure-shifts-protected"
    case recalculatedBeforeCommit = "recalculated_before_commit"
}

struct CalendarPressureSignal: RawRepresentable, Codable, Sendable, Equatable, Hashable {
    let rawValue: String
    init?(rawValue: String) {
        guard rawValue.isEmpty == false,
              rawValue == rawValue.trimmingCharacters(in: .whitespacesAndNewlines),
              rawValue == rawValue.precomposedStringWithCanonicalMapping,
              rawValue.unicodeScalars.contains(where: CharacterSet.controlCharacters.contains) == false else { return nil }
        self.rawValue = rawValue
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        guard let value = Self(rawValue: raw) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid calendar pressure signal.")
        }
        self = value
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

struct CalendarWriteCommandIntent: Codable, Sendable, Equatable, Hashable {
    enum OperationIdentityProvenance: String, Codable, Sendable, Equatable, Hashable {
        case currentRequired = "current_required"
        case legacyExplicit = "legacy_explicit"
        case legacyAbsent = "legacy_absent"
    }

    let operationID: RuntimeExternalOperationID?
    let operationIdentityProvenance: OperationIdentityProvenance
    let userConfirmed: Bool
    let placement: TimePlacementCommandIntent?
    let destinationStepID: RuntimeCommandObjectID?
    let destinationStepTitle: String?
    let originalBlockID: RuntimeCommandObjectID?
    let displacedDisposition: CalendarDisplacedDisposition
    let destinationStepPressure: CalendarPressureSignal?
    let originStepPressure: CalendarPressureSignal?
    let lifeshapeImpact: CalendarLifeShapeImpact
    let scheduleBlockID: RuntimeCommandObjectID?

    private enum CodingKeys: String, CodingKey {
        case operationID, operationIdentityProvenance, userConfirmed, placement, destinationStepID
        case destinationStepTitle, originalBlockID, displacedDisposition, destinationStepPressure
        case originStepPressure, lifeshapeImpact, scheduleBlockID
    }

    init(
        operationID: RuntimeExternalOperationID,
        userConfirmed: Bool,
        placement: TimePlacementCommandIntent?,
        destinationStepID: RuntimeCommandObjectID?,
        destinationStepTitle: String?,
        originalBlockID: RuntimeCommandObjectID?,
        displacedDisposition: CalendarDisplacedDisposition,
        destinationStepPressure: CalendarPressureSignal?,
        originStepPressure: CalendarPressureSignal?,
        lifeshapeImpact: CalendarLifeShapeImpact,
        scheduleBlockID: RuntimeCommandObjectID? = nil
    ) {
        self.operationID = operationID
        operationIdentityProvenance = .currentRequired
        self.userConfirmed = userConfirmed
        self.placement = placement
        self.destinationStepID = destinationStepID
        self.destinationStepTitle = destinationStepTitle
        self.originalBlockID = originalBlockID
        self.displacedDisposition = displacedDisposition
        self.destinationStepPressure = destinationStepPressure
        self.originStepPressure = originStepPressure
        self.lifeshapeImpact = lifeshapeImpact
        self.scheduleBlockID = scheduleBlockID
    }

    fileprivate init(
        legacyOperationID: RuntimeExternalOperationID?,
        userConfirmed: Bool,
        placement: TimePlacementCommandIntent?,
        destinationStepID: RuntimeCommandObjectID?,
        destinationStepTitle: String?,
        originalBlockID: RuntimeCommandObjectID?,
        displacedDisposition: CalendarDisplacedDisposition,
        destinationStepPressure: CalendarPressureSignal?,
        originStepPressure: CalendarPressureSignal?,
        lifeshapeImpact: CalendarLifeShapeImpact,
        scheduleBlockID: RuntimeCommandObjectID?
    ) {
        operationID = legacyOperationID
        operationIdentityProvenance = legacyOperationID == nil ? .legacyAbsent : .legacyExplicit
        self.userConfirmed = userConfirmed
        self.placement = placement
        self.destinationStepID = destinationStepID
        self.destinationStepTitle = destinationStepTitle
        self.originalBlockID = originalBlockID
        self.displacedDisposition = displacedDisposition
        self.destinationStepPressure = destinationStepPressure
        self.originStepPressure = originStepPressure
        self.lifeshapeImpact = lifeshapeImpact
        self.scheduleBlockID = scheduleBlockID
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let operationID = try container.decodeIfPresent(RuntimeExternalOperationID.self, forKey: .operationID) else {
            throw DecodingError.dataCorruptedError(forKey: .operationID, in: container, debugDescription: "Current v2 calendar commands require external-operation identity.")
        }
        let provenance = try container.decodeIfPresent(OperationIdentityProvenance.self, forKey: .operationIdentityProvenance) ?? .currentRequired
        guard provenance == .currentRequired else {
            throw DecodingError.dataCorruptedError(forKey: .operationIdentityProvenance, in: container, debugDescription: "Legacy calendar identity provenance is adapter-only.")
        }
        self.operationID = operationID
        operationIdentityProvenance = provenance
        userConfirmed = try container.decode(Bool.self, forKey: .userConfirmed)
        placement = try container.decodeIfPresent(TimePlacementCommandIntent.self, forKey: .placement)
        destinationStepID = try container.decodeIfPresent(RuntimeCommandObjectID.self, forKey: .destinationStepID)
        destinationStepTitle = try container.decodeIfPresent(String.self, forKey: .destinationStepTitle)
        originalBlockID = try container.decodeIfPresent(RuntimeCommandObjectID.self, forKey: .originalBlockID)
        displacedDisposition = try container.decode(CalendarDisplacedDisposition.self, forKey: .displacedDisposition)
        destinationStepPressure = try container.decodeIfPresent(CalendarPressureSignal.self, forKey: .destinationStepPressure)
        originStepPressure = try container.decodeIfPresent(CalendarPressureSignal.self, forKey: .originStepPressure)
        lifeshapeImpact = try container.decode(CalendarLifeShapeImpact.self, forKey: .lifeshapeImpact)
        scheduleBlockID = try container.decodeIfPresent(RuntimeCommandObjectID.self, forKey: .scheduleBlockID)
    }
}

private let runtimeJournalCommandRecordSchemaVersion = "runtime_journal_command_record.native.v1"

struct RuntimeJournalCommandRecord: Codable, Sendable, Equatable, Hashable {
    enum Storage: Codable, Sendable, Equatable, Hashable {
        case current(RuntimeCommandV2Envelope)
        case legacyCalendar(LegacyCalendarJournalCommand)
    }

    let storage: Storage
    let schemaVersion: String

    private enum CodingKeys: String, CodingKey { case storage, schemaVersion }

    init(command: AmbitionsCommand) throws {
        if case let .schedule(schedule) = command.typedPayload,
           case let .calendarWrite(intent) = schedule.action,
           intent.operationIdentityProvenance != .currentRequired {
            storage = .legacyCalendar(try LegacyCalendarJournalCommand(command: command, intent: intent))
        } else {
            storage = .current(try RuntimeCommandV2Envelope(command: command, payload: command.typedPayload))
        }
        schemaVersion = runtimeJournalCommandRecordSchemaVersion
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try values.decode(String.self, forKey: .schemaVersion)
        guard schemaVersion == runtimeJournalCommandRecordSchemaVersion else {
            throw DecodingError.dataCorruptedError(
                forKey: .schemaVersion, in: values, debugDescription: "Unsupported journal command record version."
            )
        }
        storage = try values.decode(Storage.self, forKey: .storage)
        let hasValidStorage: Bool
        switch storage {
        case let .current(envelope):
            if let normalized = try? RuntimeCommandV2Envelope(command: envelope.command, payload: envelope.payload) {
                hasValidStorage = normalized == envelope
            } else {
                hasValidStorage = false
            }
        case let .legacyCalendar(record):
            hasValidStorage = record.hasValidInvariants
        }
        if hasValidStorage == false {
            throw DecodingError.dataCorruptedError(
                forKey: .storage, in: values, debugDescription: "Invalid journal command record."
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(storage, forKey: .storage)
        try values.encode(schemaVersion, forKey: .schemaVersion)
    }

    var command: AmbitionsCommand {
        switch storage {
        case let .current(envelope): envelope.command
        case let .legacyCalendar(record): record.command
        }
    }
}

struct LegacyCalendarJournalCommand: Codable, Sendable, Equatable, Hashable {
    let id: String
    let expectedRevision: RuntimeExpectedRevision
    let provenance: RuntimeCommandProvenance
    let privacy: RuntimeCommandPrivacy
    let idempotencyKey: CommandIdempotencyKey
    let targetIdentities: [RuntimeDomainObjectID]
    let target: AmbitionsCommandTarget
    let content: RuntimeCommandContent
    let intent: LegacyCalendarJournalIntent
    let validationState: AmbitionsCommandValidationState
    let executionStatus: AmbitionsCommandExecutionStatus
    let result: AmbitionsCommandExecutionResult?
    let createdAt: String
    let requestedAt: String
    let relations: AmbitionsCommandRelations
    let sourceSchemaVersion: String

    init(command: AmbitionsCommand, intent: CalendarWriteCommandIntent) throws {
        guard intent.operationIdentityProvenance != .currentRequired else {
            throw RuntimeFoundationError.validation
        }
        guard let commandID = RuntimeCommandID(rawValue: command.id), commandID.rawValue == command.id,
              command.idempotencyKey.isWellFormed,
              RuntimeNestedIdentityValidator.hasValidIdentities(inEncodable: command.typedPayload),
              RuntimeNestedIdentityValidator.hasValidIdentities(inEncodable: command.relations) else {
            throw RuntimeFoundationError.invalidIdentity(.command)
        }
        id = commandID.rawValue
        expectedRevision = command.expectedRevision
        provenance = RuntimeCommandProvenance(
            source: command.source, actor: command.actor, sourceSurface: command.sourceSurface
        )
        privacy = RuntimeCommandPrivacy(classification: command.privacy, localOnly: command.localOnly)
        idempotencyKey = command.idempotencyKey
        var seen = Set<RuntimeDomainObjectID>()
        targetIdentities = [
            command.target.goalID, command.target.captureID, command.target.timeID, command.target.reviewID,
            command.target.stepID, command.target.deliverableID, command.target.scopeItemID,
            command.target.recommendationID, command.target.explanationID,
        ].compactMap { $0.flatMap(RuntimeDomainObjectID.init(rawValue:)) }
            .filter { seen.insert($0).inserted }
        target = command.target
        content = command.content
        self.intent = try LegacyCalendarJournalIntent(intent)
        validationState = command.validationState
        executionStatus = command.executionStatus
        result = command.result
        createdAt = command.createdAt
        requestedAt = command.requestedAt
        relations = command.relations
        sourceSchemaVersion = command.schemaVersion
    }

    var command: AmbitionsCommand {
        AmbitionsCommand(
            id: id,
            source: provenance.source,
            typedPayload: .schedule(ScheduleCommand(
                action: .calendarWrite(intent.calendarIntent), target: target, content: content
            )),
            expectedRevision: expectedRevision,
            idempotencyKey: idempotencyKey,
            validationState: validationState,
            executionStatus: executionStatus,
            result: result,
            createdAt: createdAt,
            requestedAt: requestedAt,
            actor: provenance.actor,
            sourceSurface: provenance.sourceSurface,
            relations: relations,
            localOnly: privacy.localOnly,
            privacy: privacy.classification,
            schemaVersion: sourceSchemaVersion
        )
    }

    var hasValidInvariants: Bool {
        guard let commandID = RuntimeCommandID(rawValue: id), commandID.rawValue == id,
              idempotencyKey.isWellFormed,
              intent.operationIdentityProvenance != .currentRequired,
              (intent.operationIdentityProvenance == .legacyAbsent) == (intent.operationID == nil),
              RuntimeNestedIdentityValidator.hasValidIdentities(inEncodable: self) else { return false }
        let rawTargetIDs = [
            target.goalID, target.captureID, target.timeID, target.reviewID, target.stepID,
            target.deliverableID, target.scopeItemID, target.recommendationID, target.explanationID,
        ].compactMap { $0 }
        var seen = Set<String>()
        return rawTargetIDs.filter { seen.insert($0).inserted } == targetIdentities.map(\.rawValue)
    }
}

struct LegacyCalendarJournalIntent: Codable, Sendable, Equatable, Hashable {
    let operationID: RuntimeExternalOperationID?
    let operationIdentityProvenance: CalendarWriteCommandIntent.OperationIdentityProvenance
    let userConfirmed: Bool
    let placement: TimePlacementCommandIntent?
    let destinationStepID: RuntimeCommandObjectID?
    let destinationStepTitle: String?
    let originalBlockID: RuntimeCommandObjectID?
    let displacedDisposition: CalendarDisplacedDisposition
    let destinationStepPressure: CalendarPressureSignal?
    let originStepPressure: CalendarPressureSignal?
    let lifeshapeImpact: CalendarLifeShapeImpact
    let scheduleBlockID: RuntimeCommandObjectID?

    init(_ intent: CalendarWriteCommandIntent) throws {
        guard intent.operationIdentityProvenance != .currentRequired,
              (intent.operationIdentityProvenance == .legacyAbsent) == (intent.operationID == nil) else {
            throw RuntimeFoundationError.validation
        }
        operationID = intent.operationID
        operationIdentityProvenance = intent.operationIdentityProvenance
        userConfirmed = intent.userConfirmed
        placement = intent.placement
        destinationStepID = intent.destinationStepID
        destinationStepTitle = intent.destinationStepTitle
        originalBlockID = intent.originalBlockID
        displacedDisposition = intent.displacedDisposition
        destinationStepPressure = intent.destinationStepPressure
        originStepPressure = intent.originStepPressure
        lifeshapeImpact = intent.lifeshapeImpact
        scheduleBlockID = intent.scheduleBlockID
    }

    var calendarIntent: CalendarWriteCommandIntent {
        CalendarWriteCommandIntent(
            legacyOperationID: operationID,
            userConfirmed: userConfirmed,
            placement: placement,
            destinationStepID: destinationStepID,
            destinationStepTitle: destinationStepTitle,
            originalBlockID: originalBlockID,
            displacedDisposition: displacedDisposition,
            destinationStepPressure: destinationStepPressure,
            originStepPressure: originStepPressure,
            lifeshapeImpact: lifeshapeImpact,
            scheduleBlockID: scheduleBlockID
        )
    }
}

struct TimePlacementCommandIntent: Codable, Sendable, Equatable, Hashable {
    let start: String
    let end: String
    let approvedDurationMinutes: Int?
    let contextLens: NowContextLens?
    let relatedGoalID: RuntimeCommandObjectID?
    let relatedCaptureID: RuntimeCommandObjectID?
    let candidateID: RuntimeCommandObjectID?
    let candidateKind: TimePlacementCandidateKind?
    let sourceLabel: String?
    let trigger: ProtectedStepPlacementTrigger?
    let explicitUserApproval: Bool?
    let originalStart: String?
    let originalEnd: String?
    let automationPolicy: ProtectedStepPlacementAutomationPolicy?
    let contextQuality: ProtectedStepPlacementContextQuality?
    let placementPriority: PlacementPriority?

    init(
        start: String,
        end: String,
        approvedDurationMinutes: Int?,
        contextLens: NowContextLens?,
        relatedGoalID: RuntimeCommandObjectID?,
        relatedCaptureID: RuntimeCommandObjectID?,
        candidateID: RuntimeCommandObjectID? = nil,
        candidateKind: TimePlacementCandidateKind? = nil,
        sourceLabel: String? = nil,
        trigger: ProtectedStepPlacementTrigger? = nil,
        explicitUserApproval: Bool? = nil,
        originalStart: String? = nil,
        originalEnd: String? = nil,
        automationPolicy: ProtectedStepPlacementAutomationPolicy? = nil,
        contextQuality: ProtectedStepPlacementContextQuality? = nil,
        placementPriority: PlacementPriority? = nil
    ) {
        self.start = start
        self.end = end
        self.approvedDurationMinutes = approvedDurationMinutes
        self.contextLens = contextLens
        self.relatedGoalID = relatedGoalID
        self.relatedCaptureID = relatedCaptureID
        self.candidateID = candidateID
        self.candidateKind = candidateKind
        self.sourceLabel = sourceLabel
        self.trigger = trigger
        self.explicitUserApproval = explicitUserApproval
        self.originalStart = originalStart
        self.originalEnd = originalEnd
        self.automationPolicy = automationPolicy
        self.contextQuality = contextQuality
        self.placementPriority = placementPriority
    }
}

struct TimeCorrectionCommandIntent: Codable, Sendable, Equatable, Hashable {
    let action: TimeMutationActionKind
    let start: String?
    let end: String?
}

struct CommandUndoIntent: Codable, Sendable, Equatable, Hashable {
    let originalReceiptID: RuntimeCommandReceiptID
    let expectedProjectionVersion: Int64
}

struct RecoveryRecommendationCommand: Codable, Sendable, Equatable, Hashable {
    let goalID: RuntimeCommandObjectID?
    let captureID: RuntimeCommandObjectID?
    let timeID: RuntimeCommandObjectID?
    let title: String?
    let explanationID: RuntimeCommandObjectID?
}

struct CaptureCommand: Codable, Sendable, Equatable {
    enum EntryPoint: String, Codable, Sendable, Equatable {
        case shellCompose, shellUtility, goalsCreate, todayQuickCapture, goalsQuickCapture, timeQuickCapture
        case youQuickCapture, globalCaptureComposer, deepLink, appIntent, notification, widget, shareExtension, external
    }
    enum FlagshipRoute: String, Codable, Sendable, Equatable {
        case task, goal, idea, proofItem = "proof_item", waitingItem = "waiting_item"
        case plan, contextualNote = "contextual_note", reminder, ritual, archive, decision
    }
    enum Action: Codable, Sendable, Equatable {
        case quickCapture(externalCreation: ExternalCreationProvenance?)
        case routeCommitment
        case attachToGoal(CaptureGoalHandoffPlan?)
        case markWaiting
        case archive
    }

    let action: Action
    let target: AmbitionsCommandTarget
    let content: RuntimeCommandContent
    let sourceType: CaptureSourceType?
    let entryPoint: EntryPoint?
    let route: CaptureRoute?
    let flagshipRoute: FlagshipRoute?
    let placementID: FlagshipPlacementID?
    let draftID: FlagshipDraftID?

    init(
        action: Action,
        target: AmbitionsCommandTarget,
        content: RuntimeCommandContent,
        sourceType: CaptureSourceType? = nil,
        entryPoint: EntryPoint? = nil,
        route: CaptureRoute? = nil,
        flagshipRoute: FlagshipRoute? = nil,
        placementID: FlagshipPlacementID? = nil,
        draftID: FlagshipDraftID? = nil
    ) {
        self.action = action
        self.target = target
        self.content = content
        self.sourceType = sourceType
        self.entryPoint = entryPoint
        self.route = route
        self.flagshipRoute = flagshipRoute
        self.placementID = placementID
        self.draftID = draftID
    }
}

struct FlagshipPlacementID: RawRepresentable, Codable, Sendable, Equatable, Hashable {
    let rawValue: String
    init?(rawValue: String) {
        guard rawValue == rawValue.trimmingCharacters(in: .whitespacesAndNewlines),
              rawValue.isEmpty == false,
              rawValue.unicodeScalars.contains(where: CharacterSet.controlCharacters.contains) == false else { return nil }
        self.rawValue = rawValue.precomposedStringWithCanonicalMapping
        guard self.rawValue == rawValue else { return nil }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        guard let value = Self(rawValue: raw) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid flagship placement identity.")
        }
        self = value
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

struct FlagshipDraftID: RawRepresentable, Codable, Sendable, Equatable, Hashable {
    let rawValue: String
    init?(rawValue: String) {
        guard rawValue == rawValue.trimmingCharacters(in: .whitespacesAndNewlines),
              rawValue.isEmpty == false,
              rawValue.unicodeScalars.contains(where: CharacterSet.controlCharacters.contains) == false else { return nil }
        self.rawValue = rawValue.precomposedStringWithCanonicalMapping
        guard self.rawValue == rawValue else { return nil }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        guard let value = Self(rawValue: raw) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid flagship draft identity.")
        }
        self = value
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

struct GoalCommand: Codable, Sendable, Equatable {
    enum Action: String, Codable, Sendable, Equatable, Hashable {
        case create, update, setPriority, setUrgency, setDeadline, setContextLens
        case clearContextLens, addDeliverable, removeDeliverable, addScopeItem, removeScopeItem
    }

    let action: Action
    let target: AmbitionsCommandTarget
    let content: RuntimeCommandContent
}

struct StepCommand: Codable, Sendable, Equatable {
    enum Action: Codable, Sendable, Equatable {
        case startSession
        case complete
        case delay
        case split
        case recover(RecoveryRecommendationCommand?)
        case todayGoalStep(TodayGoalStepActionPlan)
    }

    let action: Action
    let target: AmbitionsCommandTarget
    let content: RuntimeCommandContent
}

struct ScheduleCommand: Codable, Sendable, Equatable {
    enum Action: Codable, Sendable, Equatable {
        case createItem(TimePlacementCommandIntent?)
        case schedule(TimePlacementCommandIntent?)
        case placeStep(TimePlacementCommandIntent?)
        case protectWindow(TimePlacementCommandIntent?)
        case correctWindow(TimeCorrectionCommandIntent)
        case undo(CommandUndoIntent)
        case ritual(TimeRitualActionPlan)
        case calendarWrite(CalendarWriteCommandIntent)
    }

    let action: Action
    let target: AmbitionsCommandTarget
    let content: RuntimeCommandContent
}

struct ReminderCommand: Codable, Sendable, Equatable, Hashable {
    enum Action: String, Codable, Sendable, Equatable, Hashable { case create, update, delete }
    let action: Action
    let target: AmbitionsCommandTarget
    let content: RuntimeCommandContent
}

struct ProfilePreferencesCommandValues: Codable, Sendable, Equatable, Hashable {
    let preferredTab: AmbitionsSurface
    let appearancePreference: AppAppearancePreference
    let accentFamily: AmbitionAccentFamily
    let reviewCadenceDays: Int
    let localOnlyModeEnabled: Bool
}

struct ProfileCommand: Codable, Sendable, Equatable, Hashable {
    enum Action: String, Codable, Sendable, Equatable, Hashable { case updatePreferences }
    let action: Action
    let target: AmbitionsCommandTarget
    let content: RuntimeCommandContent
    let preferences: ProfilePreferencesCommandValues?

    init(
        action: Action,
        target: AmbitionsCommandTarget,
        content: RuntimeCommandContent,
        preferences: ProfilePreferencesCommandValues? = nil
    ) {
        self.action = action
        self.target = target
        self.content = content
        self.preferences = preferences
    }
}

struct HistoryCommand: Codable, Sendable, Equatable {
    enum Action: Codable, Sendable, Equatable {
        case openDestination
        case askWhy
        case dismissRecommendation
        case todayReceipt(TodayReceiptDomainEvent)
    }

    let action: Action
    let target: AmbitionsCommandTarget
    let content: RuntimeCommandContent
}

struct RepairCommand: Codable, Sendable, Equatable, Hashable {
    enum Action: String, Codable, Sendable, Equatable, Hashable { case recover, openDestination }
    let action: Action
    let recommendation: RecoveryRecommendationCommand
    let target: AmbitionsCommandTarget
    let content: RuntimeCommandContent
}

struct ImportDeletionCommand: Codable, Sendable, Equatable, Hashable {
    enum Action: String, Codable, Sendable, Equatable, Hashable {
        case prepareExport, performExport, deleteObject, forgetMemory
    }

    let action: Action
    let target: AmbitionsCommandTarget
    let content: RuntimeCommandContent
}

struct ExternalOperationCommand: Codable, Sendable, Equatable, Hashable {
    enum Action: String, Codable, Sendable, Equatable, Hashable {
        case create
        case compensateRemoval = "compensate_removal"
    }

    let operationID: RuntimeExternalOperationID
    let kind: RuntimeExternalEffectKind
    let target: AmbitionsCommandTarget
    let title: String
    let action: Action?
    let sourceOperationID: RuntimeExternalOperationID?
    let sourceProviderReference: RuntimeExternalProviderReference?
    let sourceReceiptID: RuntimeReceiptID?
    let compensationPlanID: RuntimeRollbackPlanID?
    let compensationPlanDigest: String?

    init(
        operationID: RuntimeExternalOperationID,
        kind: RuntimeExternalEffectKind,
        target: AmbitionsCommandTarget,
        title: String,
        action: Action = .create,
        sourceOperationID: RuntimeExternalOperationID? = nil,
        sourceProviderReference: RuntimeExternalProviderReference? = nil,
        sourceReceiptID: RuntimeReceiptID? = nil,
        compensationPlanID: RuntimeRollbackPlanID? = nil,
        compensationPlanDigest: String? = nil
    ) {
        self.operationID = operationID
        self.kind = kind
        self.target = target
        self.title = title
        self.action = action
        self.sourceOperationID = sourceOperationID
        self.sourceProviderReference = sourceProviderReference
        self.sourceReceiptID = sourceReceiptID
        self.compensationPlanID = compensationPlanID
        self.compensationPlanDigest = compensationPlanDigest
    }

    var effectiveAction: Action { action ?? .create }
}

enum RuntimeCommandPayload: Codable, Sendable, Equatable {
    case capture(CaptureCommand)
    case goal(GoalCommand)
    case step(StepCommand)
    case schedule(ScheduleCommand)
    case reminder(ReminderCommand)
    case profile(ProfileCommand)
    case history(HistoryCommand)
    case repair(RepairCommand)
    case importDeletion(ImportDeletionCommand)
    case externalOperation(ExternalOperationCommand)
    case compensation(RuntimeCompensationCommand)

    var target: AmbitionsCommandTarget {
        switch self {
        case let .capture(value): value.target
        case let .goal(value): value.target
        case let .step(value): value.target
        case let .schedule(value): value.target
        case let .reminder(value): value.target
        case let .profile(value): value.target
        case let .history(value): value.target
        case let .repair(value): value.target
        case let .importDeletion(value): value.target
        case let .externalOperation(value): value.target
        case let .compensation(value): value.target
        }
    }

    var content: RuntimeCommandContent {
        switch self {
        case let .capture(value): value.content
        case let .goal(value): value.content
        case let .step(value): value.content
        case let .schedule(value): value.content
        case let .reminder(value): value.content
        case let .profile(value): value.content
        case let .history(value): value.content
        case let .repair(value): value.content
        case let .importDeletion(value): value.content
        case let .externalOperation(value): RuntimeCommandContent(AmbitionsCommandPayload(title: value.title))
        case let .compensation(value): value.content
        }
    }

    func hash(into hasher: inout Hasher) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        if let bytes = try? encoder.encode(self) {
            hasher.combine(bytes)
        } else {
            hasher.combine(diagnosticFamily)
            hasher.combine(diagnosticCase)
            hasher.combine(target)
            hasher.combine(content)
        }
    }
}

enum RuntimeCommandOperation: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case quickCapture = "quick_capture", openDestination = "open_destination", createGoal = "create_goal", updateGoal = "update_goal"
    case attachToGoal = "attach_to_goal", createTimeItem = "create_time_item", scheduleItem = "schedule_item"
    case placeStepInTime = "place_step_in_time", protectTimeWindow = "protect_time_window", correctTimeWindow = "correct_time_window"
    case startStepSession = "start_focus", completeAction = "complete_action", delayAction = "delay_action"
    case splitAction = "split_action", recoverAction = "recover_action", markWaiting = "mark_waiting", archiveItem = "archive_item"
    case setPriority = "set_priority", setUrgency = "set_urgency", prepareExport = "prepare_export", performExport = "perform_export"
    case deleteObject = "delete_object", forgetMemory = "forget_memory", setDeadline = "set_deadline", setContextLens = "set_context_lens"
    case clearContextLensOverride = "clear_context_lens_override", updateUserPreferences = "update_user_preferences"
    case routeCommitment = "route_commitment", addDeliverable = "add_deliverable", removeDeliverable = "remove_deliverable"
    case addGoalScopeItem = "add_goal_scope_item", removeGoalScopeItem = "remove_goal_scope_item", askWhy = "ask_why"
    case dismissRecommendation = "dismiss_recommendation"
    case createReminder = "create_reminder", updateReminder = "update_reminder", deleteReminder = "delete_reminder"
    case externalReminder = "external_reminder", externalCalendarEvent = "external_calendar_event"
    case compensateMutation = "compensate_mutation"
}

extension RuntimeCommandPayload {
    var isQuickCapture: Bool {
        guard case let .capture(value) = self,
              case .quickCapture = value.action else { return false }
        return true
    }

    func retargeted(to target: AmbitionsCommandTarget) -> RuntimeCommandPayload {
        switch self {
        case let .capture(value): .capture(CaptureCommand(action: value.action, target: target, content: value.content, sourceType: value.sourceType, entryPoint: value.entryPoint, route: value.route, flagshipRoute: value.flagshipRoute, placementID: value.placementID, draftID: value.draftID))
        case let .goal(value): .goal(GoalCommand(action: value.action, target: target, content: value.content))
        case let .step(value): .step(StepCommand(action: value.action, target: target, content: value.content))
        case let .schedule(value): .schedule(ScheduleCommand(action: value.action, target: target, content: value.content))
        case let .reminder(value): .reminder(ReminderCommand(action: value.action, target: target, content: value.content))
        case let .profile(value): .profile(ProfileCommand(action: value.action, target: target, content: value.content, preferences: value.preferences))
        case let .history(value): .history(HistoryCommand(action: value.action, target: target, content: value.content))
        case let .repair(value): .repair(RepairCommand(action: value.action, recommendation: value.recommendation, target: target, content: value.content))
        case let .importDeletion(value): .importDeletion(ImportDeletionCommand(action: value.action, target: target, content: value.content))
        case let .externalOperation(value): .externalOperation(ExternalOperationCommand(
            operationID: value.operationID, kind: value.kind, target: target,
            title: value.title, action: value.effectiveAction,
            sourceOperationID: value.sourceOperationID,
            sourceProviderReference: value.sourceProviderReference,
            sourceReceiptID: value.sourceReceiptID,
            compensationPlanID: value.compensationPlanID,
            compensationPlanDigest: value.compensationPlanDigest
        ))
        case let .compensation(value): .compensation(RuntimeCompensationCommand(
            sourceReceiptID: value.sourceReceiptID, planID: value.planID,
            planDigest: value.planDigest, sourceLineage: value.sourceLineage,
            action: value.action, targets: value.targets,
            requiresConfirmation: value.requiresConfirmation,
            target: target, content: value.content
        ))
        }
    }
}

extension RuntimeCommandPayload: Hashable {}

extension RuntimeCommandPayload {
    var diagnosticFamily: String {
        switch self {
        case .capture: "capture"
        case .goal: "goal"
        case .step: "step"
        case .schedule: "schedule"
        case .reminder: "reminder"
        case .profile: "profile"
        case .history: "history"
        case .repair: "repair"
        case .importDeletion: "importDeletion"
        case .externalOperation: "externalOperation"
        case .compensation: "compensation"
        }
    }

    var diagnosticCase: String {
        switch self {
        case let .capture(value):
            switch value.action {
            case .quickCapture: "quickCapture"
            case .routeCommitment: "routeCommitment"
            case .attachToGoal: "attachToGoal"
            case .markWaiting: "markWaiting"
            case .archive: "archive"
            }
        case let .goal(value): value.action.rawValue
        case let .step(value):
            switch value.action {
            case .startSession: "startSession"
            case .complete: "complete"
            case .delay: "delay"
            case .split: "split"
            case .recover: "recover"
            case let .todayGoalStep(plan): "todayGoalStep.\(plan.actionKind.rawValue)"
            }
        case let .schedule(value):
            switch value.action {
            case .createItem: "createItem"
            case .schedule: "schedule"
            case .placeStep: "placeStep"
            case .protectWindow: "protectWindow"
            case let .correctWindow(intent): "correctWindow.\(intent.action.rawValue)"
            case .undo: "undo"
            case let .ritual(plan): "ritual.\(plan.actionKind.rawValue)"
            case .calendarWrite: "calendarWrite"
            }
        case let .reminder(value): value.action.rawValue
        case let .profile(value): value.action.rawValue
        case let .history(value):
            switch value.action {
            case .openDestination: "openDestination"
            case .askWhy: "askWhy"
            case .dismissRecommendation: "dismissRecommendation"
            case let .todayReceipt(receipt): "todayReceipt.\(receipt.kind.rawValue)"
            }
        case let .repair(value): value.action.rawValue
        case let .importDeletion(value): value.action.rawValue
        case let .externalOperation(value): value.kind.rawValue
        case let .compensation(value): "execute.\(value.action.aggregateKind.rawValue)"
        }
    }

    init(upgrading command: any LegacyRuntimeCommandShape) {
        let content = RuntimeCommandContent(command.payload)
        let target = command.target
        if command.kind == .scheduleItem,
           command.payload.metadata["calendarWriteIntent"] == "true",
           let calendar = Self.legacyCalendarWrite(command) {
            self = .schedule(ScheduleCommand(action: .calendarWrite(calendar), target: target, content: content))
            return
        }
        if let operationRaw = command.payload.metadata["externalEffectOperationID"] ?? command.payload.metadata["operationID"],
           let operationID = RuntimeExternalOperationID(rawValue: operationRaw),
           operationID.rawValue == operationRaw,
           let kindRaw = command.payload.metadata["externalEffectKind"],
           let kind = RuntimeExternalEffectKind(rawValue: kindRaw),
           let title = command.payload.title {
            self = .externalOperation(ExternalOperationCommand(
                operationID: operationID, kind: kind, target: target, title: title
            ))
            return
        }
        if let plan = Self.legacyCaptureGoalHandoff(command) {
            self = .capture(CaptureCommand(action: .attachToGoal(plan), target: target, content: content))
            return
        }
        if let plan = Self.legacyTimeRitual(command) {
            self = .schedule(ScheduleCommand(action: .ritual(plan), target: target, content: content))
            return
        }
        if let plan = Self.legacyTodayGoalStep(command) {
            self = .step(StepCommand(action: .todayGoalStep(plan), target: target, content: content))
            return
        }
        if let receipt = Self.legacyTodayReceipt(command) {
            self = .history(HistoryCommand(action: .todayReceipt(receipt), target: target, content: content))
            return
        }
        switch command.kind {
        case .quickCapture:
            let metadata = command.payload.metadata
            let provenance: ExternalCreationProvenance?
            if let requestID = metadata[ExternalCreationCommandMetadataKey.requestID],
               let sourceRaw = metadata[ExternalCreationCommandMetadataKey.source],
               let source = ExternalCreationSource(rawValue: sourceRaw),
               let sourceTypeRaw = metadata[ExternalCreationCommandMetadataKey.sourceType],
               let sourceType = CaptureSourceType(rawValue: sourceTypeRaw),
               let landingRaw = metadata[ExternalCreationCommandMetadataKey.landing],
               let landing = ExternalCreationLanding(rawValue: landingRaw) {
                provenance = ExternalCreationProvenance(
                    requestID: requestID,
                    source: source,
                    sourceApplication: metadata[ExternalCreationCommandMetadataKey.sourceApplication],
                    sourceURL: metadata[ExternalCreationCommandMetadataKey.sourceURL],
                    sourceType: sourceType,
                    landing: landing,
                    provenanceHint: metadata[ExternalCreationCommandMetadataKey.provenanceHint]
                )
            } else {
                provenance = nil
            }
            self = .capture(CaptureCommand(
                action: .quickCapture(externalCreation: provenance),
                target: target,
                content: content,
                sourceType: metadata[ExternalCreationCommandMetadataKey.sourceType].flatMap(CaptureSourceType.init(rawValue:)),
                entryPoint: metadata["captureEntryPoint"].flatMap(CaptureCommand.EntryPoint.init(rawValue:)),
                route: metadata["captureRoute"].flatMap(CaptureRoute.init(rawValue:)),
                flagshipRoute: metadata["captureRouteType"].flatMap(CaptureCommand.FlagshipRoute.init(rawValue:)),
                placementID: command.payload.destinationRoute.flatMap(FlagshipPlacementID.init(rawValue:)),
                draftID: metadata["flagshipDraftID"].flatMap(FlagshipDraftID.init(rawValue:))
            ))
        case .routeCommitment:
            self = .capture(CaptureCommand(action: .routeCommitment, target: target, content: content))
        case .attachToGoal:
            self = .capture(CaptureCommand(action: .attachToGoal(Self.legacyCaptureGoalHandoff(command)), target: target, content: content))
        case .markWaiting:
            self = .capture(CaptureCommand(action: .markWaiting, target: target, content: content))
        case .archiveItem:
            self = .capture(CaptureCommand(action: .archive, target: target, content: content))
        case .createGoal:
            self = .goal(GoalCommand(action: .create, target: target, content: content))
        case .updateGoal:
            self = .goal(GoalCommand(action: .update, target: target, content: content))
        case .setPriority:
            self = .goal(GoalCommand(action: .setPriority, target: target, content: content))
        case .setUrgency:
            self = .goal(GoalCommand(action: .setUrgency, target: target, content: content))
        case .setDeadline:
            self = .goal(GoalCommand(action: .setDeadline, target: target, content: content))
        case .setContextLens:
            self = .goal(GoalCommand(action: .setContextLens, target: target, content: content))
        case .clearContextLensOverride:
            self = .goal(GoalCommand(action: .clearContextLens, target: target, content: content))
        case .addDeliverable:
            self = .goal(GoalCommand(action: .addDeliverable, target: target, content: content))
        case .removeDeliverable:
            self = .goal(GoalCommand(action: .removeDeliverable, target: target, content: content))
        case .addGoalScopeItem:
            self = .goal(GoalCommand(action: .addScopeItem, target: target, content: content))
        case .removeGoalScopeItem:
            self = .goal(GoalCommand(action: .removeScopeItem, target: target, content: content))
        case .startStepSession:
            self = .step(StepCommand(action: .startSession, target: target, content: content))
        case .completeAction, .delayAction, .splitAction:
            if let plan = Self.legacyTodayGoalStep(command) {
                self = .step(StepCommand(action: .todayGoalStep(plan), target: target, content: content))
            } else {
                let action: StepCommand.Action = command.kind == .completeAction ? .complete : command.kind == .delayAction ? .delay : .split
                self = .step(StepCommand(action: action, target: target, content: content))
            }
        case .recoverAction:
            if let plan = Self.legacyTodayGoalStep(command) {
                self = .step(StepCommand(action: .todayGoalStep(plan), target: target, content: content))
            } else {
                self = .step(StepCommand(
                    action: .recover(RecoveryRecommendationCommand(
                        goalID: target.goalID.flatMap(RuntimeCommandObjectID.init(rawValue:)),
                        captureID: target.captureID.flatMap(RuntimeCommandObjectID.init(rawValue:)),
                        timeID: target.timeID.flatMap(RuntimeCommandObjectID.init(rawValue:)),
                        title: content.title,
                        explanationID: content.explanationID.flatMap(RuntimeCommandObjectID.init(rawValue:))
                    )),
                    target: target,
                    content: content
                ))
            }
        case .createTimeItem, .scheduleItem, .placeStepInTime, .protectTimeWindow:
            let placement = Self.legacyPlacement(command)
            let action: ScheduleCommand.Action
            if command.kind == .scheduleItem, let calendar = Self.legacyCalendarWrite(command) {
                action = .calendarWrite(calendar)
            } else if command.kind == .scheduleItem {
                action = .schedule(placement)
            } else if command.kind == .placeStepInTime {
                action = .placeStep(placement)
            } else if command.kind == .protectTimeWindow {
                action = .protectWindow(placement)
            } else {
                action = .createItem(placement)
            }
            self = .schedule(ScheduleCommand(action: action, target: target, content: content))
        case .correctTimeWindow:
            if let receiptID = command.payload.metadata["undoOriginalReceiptID"],
               let typedReceiptID = RuntimeCommandReceiptID(rawValue: receiptID),
               let version = command.payload.metadata["expectedProjectionVersion"].flatMap(Int64.init) {
                self = .schedule(ScheduleCommand(action: .undo(CommandUndoIntent(
                    originalReceiptID: typedReceiptID,
                    expectedProjectionVersion: version
                )), target: target, content: content))
            } else {
                let action = command.payload.metadata["correctionKind"].flatMap(TimeMutationActionKind.init(rawValue:)) ?? .notUsable
                self = .schedule(ScheduleCommand(action: .correctWindow(TimeCorrectionCommandIntent(
                    action: action,
                    start: command.payload.metadata["startAt"] ?? command.payload.metadata["start"],
                    end: command.payload.metadata["endAt"] ?? command.payload.metadata["end"]
                )), target: target, content: content))
            }
        case .updateUserPreferences:
            let metadata = command.payload.metadata
            let preferences: ProfilePreferencesCommandValues?
            if let preferredTabRaw = metadata["preferredTab"],
               let preferredTab = AmbitionsSurface(rawValue: preferredTabRaw),
               let appearanceRaw = metadata["appearancePreference"],
               let appearance = AppAppearancePreference(rawValue: appearanceRaw),
               let accentRaw = metadata["accentFamily"],
               let accent = AmbitionAccentFamily(rawValue: accentRaw),
               let cadenceRaw = metadata["reviewCadenceDays"],
               let cadence = Int(cadenceRaw), cadence > 0,
               let localOnlyRaw = metadata["localOnlyModeEnabled"],
               let localOnly = Bool(localOnlyRaw) {
                preferences = ProfilePreferencesCommandValues(
                    preferredTab: preferredTab.canonicalTopLevelTab,
                    appearancePreference: appearance,
                    accentFamily: accent,
                    reviewCadenceDays: cadence,
                    localOnlyModeEnabled: localOnly
                )
            } else {
                preferences = nil
            }
            self = .profile(ProfileCommand(
                action: .updatePreferences,
                target: target,
                content: content,
                preferences: preferences
            ))
        case .openDestination:
            self = .history(HistoryCommand(action: .openDestination, target: target, content: content))
        case .askWhy:
            self = .history(HistoryCommand(action: .askWhy, target: target, content: content))
        case .dismissRecommendation:
            if let receipt = Self.legacyTodayReceipt(command) {
                self = .history(HistoryCommand(action: .todayReceipt(receipt), target: target, content: content))
            } else {
                self = .history(HistoryCommand(action: .dismissRecommendation, target: target, content: content))
            }
        case .prepareExport:
            self = .importDeletion(ImportDeletionCommand(action: .prepareExport, target: target, content: content))
        case .performExport:
            self = .importDeletion(ImportDeletionCommand(action: .performExport, target: target, content: content))
        case .deleteObject:
            self = .importDeletion(ImportDeletionCommand(action: .deleteObject, target: target, content: content))
        case .forgetMemory:
            self = .importDeletion(ImportDeletionCommand(action: .forgetMemory, target: target, content: content))
        }
    }

    var operation: RuntimeCommandOperation {
        switch self {
        case let .capture(value):
            switch value.action {
            case .quickCapture: .quickCapture
            case .routeCommitment: .routeCommitment
            case .attachToGoal: .attachToGoal
            case .markWaiting: .markWaiting
            case .archive: .archiveItem
            }
        case let .goal(value):
            switch value.action {
            case .create: .createGoal
            case .update: .updateGoal
            case .setPriority: .setPriority
            case .setUrgency: .setUrgency
            case .setDeadline: .setDeadline
            case .setContextLens: .setContextLens
            case .clearContextLens: .clearContextLensOverride
            case .addDeliverable: .addDeliverable
            case .removeDeliverable: .removeDeliverable
            case .addScopeItem: .addGoalScopeItem
            case .removeScopeItem: .removeGoalScopeItem
            }
        case let .step(value):
            switch value.action {
            case .startSession: .startStepSession
            case .complete: .completeAction
            case .delay: .delayAction
            case .split: .splitAction
            case .recover: .recoverAction
            case let .todayGoalStep(plan): TodayGoalStepActionPlan.operation(for: plan.actionKind)
            }
        case let .schedule(value):
            switch value.action {
            case .createItem: .createTimeItem
            case .schedule, .calendarWrite: .scheduleItem
            case .placeStep: .placeStepInTime
            case .protectWindow: .protectTimeWindow
            case .correctWindow, .undo: .correctTimeWindow
            case let .ritual(plan): TimeRitualActionPlan.operation(for: plan.actionKind)
            }
        case let .reminder(value):
            switch value.action {
            case .create: .createReminder
            case .update: .updateReminder
            case .delete: .deleteReminder
            }
        case .profile: .updateUserPreferences
        case let .history(value):
            switch value.action {
            case .openDestination: .openDestination
            case .askWhy: .askWhy
            case .dismissRecommendation: .dismissRecommendation
            case let .todayReceipt(receipt): receipt.kind == .closure ? .completeAction : .dismissRecommendation
            }
        case let .repair(value): value.action == .openDestination ? .openDestination : .recoverAction
        case let .importDeletion(value):
            switch value.action {
            case .prepareExport: .prepareExport
            case .performExport: .performExport
            case .deleteObject: .deleteObject
            case .forgetMemory: .forgetMemory
            }
        case let .externalOperation(value): value.kind == .reminder ? .externalReminder : .externalCalendarEvent
        case .compensation: .compensateMutation
        }
    }

    private static func legacyPlacement(_ command: any LegacyRuntimeCommandShape) -> TimePlacementCommandIntent? {
        let metadata = command.payload.metadata
        guard let start = metadata["startAt"] ?? metadata["start"] else { return nil }
        let duration = (metadata["approvedDurationMinutes"] ?? metadata["durationMinutes"]).flatMap(Int.init)
        let end = metadata["endAt"] ?? metadata["end"] ?? duration.flatMap { minutes in
            DomainTimestamp.date(from: start).map {
                DomainTimestamp.string(from: $0.addingTimeInterval(TimeInterval(minutes * 60)))
            }
        }
        guard let end else { return nil }
        return TimePlacementCommandIntent(
            start: start,
            end: end,
            approvedDurationMinutes: duration,
            contextLens: metadata["contextLens"].flatMap(NowContextLens.init(rawValue:)) ?? command.payload.contextLens,
            relatedGoalID: (metadata["relatedGoalID"] ?? command.target.goalID).flatMap(RuntimeCommandObjectID.init(rawValue:)),
            relatedCaptureID: (metadata["relatedCaptureID"] ?? command.target.captureID).flatMap(RuntimeCommandObjectID.init(rawValue:)),
            candidateID: metadata["placementCandidateID"].flatMap(RuntimeCommandObjectID.init(rawValue:)),
            candidateKind: metadata["placementCandidateKind"].flatMap(TimePlacementCandidateKind.init(rawValue:)),
            sourceLabel: metadata["placementSource"],
            trigger: Self.legacyPlacementTrigger(command),
            explicitUserApproval: metadata["explicitUserApproval"].map { ["true", "confirmed", "approved"].contains($0.lowercased()) },
            originalStart: metadata["originalStartAt"] ?? metadata["originalStart"] ?? metadata["currentStartAt"] ?? metadata["currentStart"],
            originalEnd: metadata["originalEndAt"] ?? metadata["originalEnd"] ?? metadata["currentEndAt"] ?? metadata["currentEnd"],
            automationPolicy: (metadata["protectedPlacementAutomationPolicy"] ?? metadata["automaticPlacementPolicy"] ?? metadata["automationPolicy"])
                .flatMap(ProtectedStepPlacementAutomationPolicy.init(rawValue:)),
            contextQuality: (metadata["protectedPlacementContextQuality"] ?? metadata["contextQuality"])
                .flatMap(ProtectedStepPlacementContextQuality.init(rawValue:)),
            placementPriority: (metadata["placementPriority"] ?? metadata["priority"] ?? metadata["userPriority"])
                .flatMap(PlacementPriority.userFacingValue(from:))
        )
    }

    fileprivate static func legacyCaptureGoalHandoff(_ command: any LegacyRuntimeCommandShape) -> CaptureGoalHandoffPlan? {
        legacyBase64Payload(
            command,
            markerKey: "captureGoalHandoffMutation",
            payloadKey: "captureGoalHandoffPlan"
        )
    }

    fileprivate static func legacyTimeRitual(_ command: any LegacyRuntimeCommandShape) -> TimeRitualActionPlan? {
        legacyBase64Payload(
            command,
            markerKey: "timeRitualActionMutation",
            payloadKey: "timeRitualActionPlan"
        )
    }

    fileprivate static func legacyTodayGoalStep(_ command: any LegacyRuntimeCommandShape) -> TodayGoalStepActionPlan? {
        legacyBase64Payload(
            command,
            markerKey: "todayGoalStepActionMutation",
            payloadKey: "todayGoalStepActionPlan"
        )
    }

    fileprivate static func legacyTodayReceipt(_ command: any LegacyRuntimeCommandShape) -> TodayReceiptDomainEvent? {
        legacyBase64Payload(
            command,
            markerKey: "todayReceiptMutation",
            payloadKey: "todayReceiptPayload"
        )
    }

    private static func legacyBase64Payload<Value: Decodable>(
        _ command: any LegacyRuntimeCommandShape,
        markerKey: String,
        payloadKey: String
    ) -> Value? {
        guard command.payload.metadata[markerKey] == "true",
              let encoded = command.payload.metadata[payloadKey],
              let data = Data(base64Encoded: encoded) else { return nil }
        do {
            return try JSONDecoder().decode(Value.self, from: data)
        } catch {
            return nil
        }
    }

    private static func legacyPlacementTrigger(_ command: any LegacyRuntimeCommandShape) -> ProtectedStepPlacementTrigger? {
        if command.payload.metadata["missedRecoveryMoveIt"] == "true" || command.payload.metadata["recoveryAction"] == "move_it" {
            return .missedRecoveryMoveIt
        }
        return command.payload.metadata["placementTrigger"].flatMap(ProtectedStepPlacementTrigger.init(rawValue:))
    }

    fileprivate static func legacyCalendarWrite(_ command: any LegacyRuntimeCommandShape) -> CalendarWriteCommandIntent? {
        let operationRaw = command.payload.metadata["externalEffectOperationID"]
        guard command.payload.metadata["calendarWriteIntent"] == "true",
              let confirmedRaw = command.payload.metadata["userConfirmed"],
              let userConfirmed = Bool(confirmedRaw) else { return nil }
        let operationID = operationRaw.flatMap(RuntimeExternalOperationID.init(rawValue:))
        if let operationRaw, operationID?.rawValue != operationRaw { return nil }
        let metadata = command.payload.metadata
        return CalendarWriteCommandIntent(
            legacyOperationID: operationID,
            userConfirmed: userConfirmed,
            placement: legacyPlacement(command),
            destinationStepID: (command.target.stepID ?? metadata["destinationStepID"]).flatMap(RuntimeCommandObjectID.init(rawValue:)),
            destinationStepTitle: metadata["destinationStepTitle"],
            originalBlockID: (metadata["originalBlockID"] ?? command.target.timeID).flatMap(RuntimeCommandObjectID.init(rawValue:)),
            displacedDisposition: metadata["displacedDisposition"].flatMap(CalendarDisplacedDisposition.init(rawValue:)) ?? .notDisplaced,
            destinationStepPressure: metadata["destinationStepPressure"].flatMap(CalendarPressureSignal.init(rawValue:)),
            originStepPressure: metadata["originStepPressure"].flatMap(CalendarPressureSignal.init(rawValue:)),
            lifeshapeImpact: metadata["lifeshapeImpact"].flatMap(CalendarLifeShapeImpact.init(rawValue:)) ?? .recalculatedBeforeCommit,
            scheduleBlockID: metadata["scheduleBlockID"].flatMap(RuntimeCommandObjectID.init(rawValue:))
        )
    }
}

struct RuntimeCommandProvenance: Codable, Sendable, Equatable, Hashable {
    let source: AmbitionsCommandSource
    let actor: AmbitionsCommandActor
    let sourceSurface: String?
}

struct RuntimeCommandPrivacy: Codable, Sendable, Equatable, Hashable {
    let classification: EventLedgerPrivacyClassification
    let localOnly: Bool
}

struct RuntimeCommandV2Envelope: Codable, Sendable, Equatable, Hashable, Identifiable {
    let schemaVersion: Int
    let id: RuntimeCommandID
    let expectedRevision: RuntimeExpectedRevision
    let provenance: RuntimeCommandProvenance
    let privacy: RuntimeCommandPrivacy
    let idempotencyKey: CommandIdempotencyKey
    let targetIdentities: [RuntimeDomainObjectID]
    let payload: RuntimeCommandPayload
    let validationState: AmbitionsCommandValidationState
    let executionStatus: AmbitionsCommandExecutionStatus
    let result: AmbitionsCommandExecutionResult?
    let createdAt: String
    let requestedAt: String
    let relations: AmbitionsCommandRelations

    init(command: AmbitionsCommand, payload: RuntimeCommandPayload) throws {
        guard let id = RuntimeCommandID(rawValue: command.id), id.rawValue == command.id else {
            throw RuntimeFoundationError.invalidIdentity(.command)
        }
        guard command.idempotencyKey.isWellFormed,
              command.idempotencyKey.rawValue == command.idempotencyKey.rawValue.trimmingCharacters(in: .whitespacesAndNewlines),
              command.idempotencyKey.schemaVersion == commandIdempotencyKeySchemaVersion else {
            throw RuntimeFoundationError.validation
        }
        if case let .schedule(schedule) = payload, case .undo = schedule.action {
            // Historical schedule undo is decoded for inspection only. Canonical
            // compensation is represented by the dedicated compensation family.
            throw RuntimeFoundationError.unsupportedSchema
        }
        if case let .schedule(schedule) = payload,
           case let .calendarWrite(intent) = schedule.action,
           (intent.operationID == nil || intent.operationIdentityProvenance != .currentRequired) {
            throw RuntimeFoundationError.externalOperation(intent.operationID)
        }
        guard RuntimeNestedIdentityValidator.hasValidIdentities(inEncodable: payload),
              RuntimeNestedIdentityValidator.hasValidIdentities(inEncodable: command.relations) else {
            throw RuntimeFoundationError.invalidIdentity(.domainObject)
        }
        schemaVersion = runtimeCommandSchemaVersion
        self.id = id
        expectedRevision = command.expectedRevision
        provenance = RuntimeCommandProvenance(
            source: command.source,
            actor: command.actor,
            sourceSurface: command.sourceSurface
        )
        privacy = RuntimeCommandPrivacy(classification: command.privacy, localOnly: command.localOnly)
        idempotencyKey = command.idempotencyKey
        var seen = Set<RuntimeDomainObjectID>()
        let rawTargetIdentities = [
            payload.target.goalID,
            payload.target.captureID,
            payload.target.timeID,
            payload.target.reviewID,
            payload.target.stepID,
            payload.target.deliverableID,
            payload.target.scopeItemID,
            payload.target.recommendationID,
            payload.target.explanationID
        ].compactMap { $0 }
        let normalizedTargetIdentities = rawTargetIdentities.compactMap(RuntimeDomainObjectID.init(rawValue:))
        guard normalizedTargetIdentities.count == rawTargetIdentities.count,
              zip(normalizedTargetIdentities, rawTargetIdentities).allSatisfy({ $0.rawValue == $1 }) else {
            throw RuntimeFoundationError.invalidIdentity(.domainObject)
        }
        targetIdentities = normalizedTargetIdentities
        .filter { seen.insert($0).inserted }
        self.payload = payload
        validationState = command.validationState
        executionStatus = command.executionStatus
        result = command.result
        createdAt = command.createdAt
        requestedAt = command.requestedAt
        relations = command.relations
    }

    var command: AmbitionsCommand {
        AmbitionsCommand(
            id: id.rawValue,
            source: provenance.source,
            typedPayload: payload,
            expectedRevision: expectedRevision,
            idempotencyKey: idempotencyKey,
            validationState: validationState,
            executionStatus: executionStatus,
            result: result,
            createdAt: createdAt,
            requestedAt: requestedAt,
            actor: provenance.actor,
            sourceSurface: provenance.sourceSurface,
            relations: relations,
            localOnly: privacy.localOnly,
            privacy: privacy.classification
        )
    }
}

enum RuntimeCommandDecodeResult: Sendable, Equatable {
    case supported(command: AmbitionsCommand, upgradedFromV1: Bool)
    case unsupported(RuntimeUnsupportedCommand)
    case corrupt(RuntimeUnsupportedCommand)
}

struct RuntimeUnsupportedCommand: Sendable, Equatable {
    enum Reason: String, Sendable, Equatable {
        case futureVersion, unknownFamilyOrCase, oversized, corrupt
    }
    let originalBytes: Data
    let reason: Reason
    let recovery: RuntimeFoundationError
}

enum RuntimeCommandCodecError: Error, Sendable, Equatable {
    case unsupported(RuntimeUnsupportedCommand)
    case corrupt(RuntimeUnsupportedCommand)
    case envelopeTooLarge(maximumBytes: Int, actualBytes: Int)
}

struct RuntimeCommandCodec: Sendable {
    static let maximumEnvelopeBytes = 524_288

    func encode(_ command: AmbitionsCommand) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        let bytes = try encoder.encode(RuntimeCommandV2Envelope(command: command, payload: command.typedPayload))
        guard bytes.count <= Self.maximumEnvelopeBytes else {
            throw RuntimeCommandCodecError.envelopeTooLarge(
                maximumBytes: Self.maximumEnvelopeBytes,
                actualBytes: bytes.count
            )
        }
        return bytes
    }

    func decode(_ bytes: Data) -> RuntimeCommandDecodeResult {
        guard bytes.count <= Self.maximumEnvelopeBytes else {
            return .unsupported(RuntimeUnsupportedCommand(
                originalBytes: Data(),
                reason: .oversized,
                recovery: .validation
            ))
        }
        let decoder = JSONDecoder()
        if let probe = try? decoder.decode(SchemaProbe.self, from: bytes) {
            if probe.schemaVersion == String(runtimeCommandSchemaVersion) || probe.schemaVersion == "runtime_command.native.v2" {
                return decodeV2(bytes, decoder: decoder)
            }
            if probe.schemaVersion == ambitionsCommandSchemaVersion {
                return LegacyV1CommandAdapter().decode(bytes)
            }
            return .unsupported(RuntimeUnsupportedCommand(
                originalBytes: bytes,
                reason: .futureVersion,
                recovery: .unsupportedSchema
            ))
        }
        if let integerProbe = try? decoder.decode(IntegerSchemaProbe.self, from: bytes) {
            guard integerProbe.schemaVersion == runtimeCommandSchemaVersion else {
                return .unsupported(RuntimeUnsupportedCommand(
                    originalBytes: bytes,
                    reason: .futureVersion,
                    recovery: .unsupportedSchema
                ))
            }
            return decodeV2(bytes, decoder: decoder)
        }
        return .corrupt(RuntimeUnsupportedCommand(
            originalBytes: bytes,
            reason: .corrupt,
            recovery: .corruption
        ))
    }

    private func decodeV2(_ bytes: Data, decoder: JSONDecoder) -> RuntimeCommandDecodeResult {
        do {
            let envelope = try decoder.decode(RuntimeCommandV2Envelope.self, from: bytes)
            guard envelope.hasValidInvariants(originalBytes: bytes) else {
                return .corrupt(RuntimeUnsupportedCommand(
                    originalBytes: bytes,
                    reason: .corrupt,
                    recovery: .corruption
                ))
            }
            if case let .schedule(schedule) = envelope.payload, case .undo = schedule.action {
                return .unsupported(RuntimeUnsupportedCommand(
                    originalBytes: bytes,
                    reason: .unknownFamilyOrCase,
                    recovery: .unsupportedSchema
                ))
            }
            return .supported(command: envelope.command, upgradedFromV1: false)
        } catch {
            let reason: RuntimeUnsupportedCommand.Reason = Self.hasUnknownPayloadDiscriminator(bytes) || Self.isUnknownClosedEnum(error)
                ? .unknownFamilyOrCase
                : .corrupt
            return reason == .unknownFamilyOrCase ? .unsupported(RuntimeUnsupportedCommand(
                originalBytes: bytes,
                reason: reason,
                recovery: .unsupportedSchema
            )) : .corrupt(RuntimeUnsupportedCommand(originalBytes: bytes, reason: reason, recovery: .corruption))
        }
    }

    fileprivate static func isUnknownClosedEnum(_ error: Error) -> Bool {
        guard case let DecodingError.dataCorrupted(context) = error else { return false }
        if context.debugDescription.contains("Cannot initialize") &&
            context.debugDescription.contains("from invalid String value") { return true }
        if context.debugDescription.hasPrefix("Unknown ") { return true }
        let closedEnumKeys: Set<String> = [
            "action", "actionKind", "kind", "source", "sourceType", "entryPoint", "route", "flagshipRoute",
            "landing", "destination", "contextLens", "commitmentKind", "goalRelationship",
            "importance", "urgency", "deadline", "consequence", "effort", "contextFit", "userPreference",
            "capacityHint", "recoveryState", "candidateKind", "trigger", "automationPolicy", "contextQuality",
            "placementPriority", "displacedDisposition", "lifeshapeImpact", "preferredTab",
            "appearancePreference", "accentFamily", "resultState", "sourceDomain", "privacyLevel",
            "proofRelevance", "correctionAvailability", "undoAvailability", "safetyState"
        ]
        return context.codingPath.last.map { closedEnumKeys.contains($0.stringValue) } ?? false
    }

    private static func hasUnknownPayloadDiscriminator(_ bytes: Data) -> Bool {
        guard let root = try? JSONSerialization.jsonObject(with: bytes) as? [String: Any],
              let payload = root["payload"] as? [String: Any],
              let family = payload.keys.first else { return false }
        let families = Set(["capture", "goal", "step", "schedule", "reminder", "profile", "history", "repair", "importDeletion", "externalOperation", "compensation"])
        guard families.contains(family) else { return true }
        let actionsByFamily: [String: Set<String>] = [
            "capture": ["quickCapture", "routeCommitment", "attachToGoal", "markWaiting", "archive"],
            "goal": ["create", "update", "setPriority", "setUrgency", "setDeadline", "setContextLens", "clearContextLens", "addDeliverable", "removeDeliverable", "addScopeItem", "removeScopeItem"],
            "step": ["startSession", "complete", "delay", "split", "recover", "todayGoalStep"],
            "schedule": ["createItem", "schedule", "placeStep", "protectWindow", "correctWindow", "undo", "ritual", "calendarWrite"],
            "reminder": ["create", "update", "delete"],
            "profile": ["updatePreferences"],
            "history": ["openDestination", "askWhy", "dismissRecommendation", "todayReceipt"],
            "repair": ["recover", "openDestination"],
            "importDeletion": ["prepareExport", "performExport", "deleteObject", "forgetMemory"]
        ]
        if let supportedActions = actionsByFamily[family],
           let action = discriminator(named: "action", in: payload) ?? stringValue(named: "action", in: payload),
           supportedActions.contains(action) == false { return true }
        if family == "externalOperation",
           let rawKind = stringValue(named: "kind", in: payload),
           RuntimeExternalEffectKind(rawValue: rawKind) == nil { return true }
        if family == "step",
           discriminator(named: "action", in: payload) == "todayGoalStep",
           let rawActionKind = stringValue(named: "actionKind", in: payload),
           TodayGoalStepActionKind(rawValue: rawActionKind) == nil { return true }
        if family == "schedule",
           discriminator(named: "action", in: payload) == "ritual",
           let rawActionKind = stringValue(named: "actionKind", in: payload),
           TimeRitualActionKind(rawValue: rawActionKind) == nil { return true }
        return false
    }

    private static func discriminator(named key: String, in value: Any) -> String? {
        if let dictionary = value as? [String: Any] {
            if let enumValue = dictionary[key] as? [String: Any] { return enumValue.keys.first }
            for nested in dictionary.values {
                if let result = discriminator(named: key, in: nested) { return result }
            }
        } else if let array = value as? [Any] {
            for nested in array {
                if let result = discriminator(named: key, in: nested) { return result }
            }
        }
        return nil
    }

    private static func stringValue(named key: String, in value: Any) -> String? {
        if let dictionary = value as? [String: Any] {
            if let string = dictionary[key] as? String { return string }
            for nested in dictionary.values {
                if let result = stringValue(named: key, in: nested) { return result }
            }
        } else if let array = value as? [Any] {
            for nested in array {
                if let result = stringValue(named: key, in: nested) { return result }
            }
        }
        return nil
    }

    private struct SchemaProbe: Decodable { let schemaVersion: String }
    private struct IntegerSchemaProbe: Decodable { let schemaVersion: Int }
}

private extension RuntimeCommandV2Envelope {
    func hasValidInvariants(originalBytes: Data) -> Bool {
        guard idempotencyKey.isWellFormed,
              idempotencyKey.schemaVersion == commandIdempotencyKeySchemaVersion,
              idempotencyKey.rawValue == idempotencyKey.rawValue.trimmingCharacters(in: .whitespacesAndNewlines),
              idempotencyKey.rawValue == idempotencyKey.rawValue.precomposedStringWithCanonicalMapping,
              idempotencyKey.rawValue.unicodeScalars.contains(where: CharacterSet.controlCharacters.contains) == false,
              let root = try? JSONSerialization.jsonObject(with: originalBytes) as? [String: Any],
              let rawID = root["id"] as? String,
              rawID == id.rawValue,
              let rawIdempotency = root["idempotencyKey"] as? [String: Any],
              rawIdempotency["rawValue"] as? String == idempotencyKey.rawValue,
              rawIdempotency["schemaVersion"] as? String == commandIdempotencyKeySchemaVersion,
              let rawTargets = root["targetIdentities"] as? [String],
              rawTargets == targetIdentities.map(\.rawValue) else { return false }
        guard RuntimeNestedIdentityValidator.hasValidIdentities(in: root) else { return false }
        let targetIDs = [payload.target.goalID, payload.target.captureID, payload.target.timeID,
                         payload.target.reviewID, payload.target.stepID, payload.target.deliverableID,
                         payload.target.scopeItemID, payload.target.recommendationID, payload.target.explanationID]
            .compactMap { $0 }
        var seen = Set<String>()
        let expected = targetIDs.filter { seen.insert($0).inserted }
        return expected == targetIdentities.map(\.rawValue)
    }
}

private enum RuntimeNestedIdentityValidator {
    static func hasValidIdentities<Value: Encodable>(inEncodable value: Value) -> Bool {
        guard let bytes = try? JSONEncoder().encode(value),
              let object = try? JSONSerialization.jsonObject(with: bytes) else { return false }
        return hasValidIdentities(in: object)
    }

    static func hasValidIdentities(in value: Any, key: String? = nil) -> Bool {
        if let dictionary = value as? [String: Any] {
            return dictionary.allSatisfy { nestedKey, nestedValue in
                hasValidIdentities(in: nestedValue, key: nestedKey)
            }
        }
        if let array = value as? [Any] {
            if let key, key.hasSuffix("IDs") {
                return array.allSatisfy { element in
                    guard let raw = element as? String else { return false }
                    return valid(raw, for: key)
                }
            }
            return array.allSatisfy { hasValidIdentities(in: $0, key: key) }
        }
        guard let key, let raw = value as? String,
              key == "id" || key.hasSuffix("ID") else { return true }
        return valid(raw, for: key)
    }

    private static func valid(_ raw: String, for key: String) -> Bool {
        if key == "commandID" { return RuntimeCommandID(rawValue: raw)?.rawValue == raw }
        if key.localizedCaseInsensitiveContains("receipt") {
            return RuntimeReceiptID(rawValue: raw)?.rawValue == raw
        }
        if key.localizedCaseInsensitiveContains("operation") {
            return RuntimeExternalOperationID(rawValue: raw)?.rawValue == raw
        }
        return RuntimeDomainObjectID(rawValue: raw)?.rawValue == raw
    }
}

struct LegacyV1CommandAdapter: Sendable {
    func decode(_ bytes: Data) -> RuntimeCommandDecodeResult {
        guard bytes.count <= RuntimeCommandCodec.maximumEnvelopeBytes else {
            return .unsupported(RuntimeUnsupportedCommand(
                originalBytes: Data(),
                reason: .oversized,
                recovery: .validation
            ))
        }
        do {
            let legacy = try JSONDecoder().decode(LegacyV1AmbitionsCommand.self, from: bytes)
            guard legacy.schemaVersion == ambitionsCommandSchemaVersion else {
                return .unsupported(RuntimeUnsupportedCommand(
                    originalBytes: bytes,
                    reason: .futureVersion,
                    recovery: .unsupportedSchema
                ))
            }
            guard let identity = RuntimeCommandID(rawValue: legacy.id),
                  identity.rawValue == legacy.id,
                  legacyIdentitiesAreValid(legacy) else {
                return .corrupt(RuntimeUnsupportedCommand(
                    originalBytes: bytes,
                    reason: .corrupt,
                    recovery: .corruption
                ))
            }
            guard legacyBehaviorIsSupported(legacy) else {
                return .unsupported(RuntimeUnsupportedCommand(
                    originalBytes: bytes,
                    reason: .unknownFamilyOrCase,
                    recovery: .unsupportedSchema
                ))
            }
            let typed = RuntimeCommandPayload(upgrading: legacy)
            return .supported(command: AmbitionsCommand(
                id: legacy.id,
                source: legacy.source,
                typedPayload: typed,
                validationState: legacy.validationState,
                executionStatus: legacy.executionStatus,
                result: legacy.result,
                createdAt: legacy.createdAt,
                requestedAt: legacy.requestedAt,
                actor: legacy.actor,
                sourceSurface: legacy.sourceSurface,
                relations: legacy.relations,
                localOnly: legacy.localOnly,
                privacy: legacy.privacy,
                schemaVersion: legacy.schemaVersion
            ), upgradedFromV1: true)
        } catch {
            let reason: RuntimeUnsupportedCommand.Reason = Self.hasUnknownLegacyDiscriminator(bytes) || RuntimeCommandCodec.isUnknownClosedEnum(error)
                ? .unknownFamilyOrCase
                : .corrupt
            let unsupported = RuntimeUnsupportedCommand(
                originalBytes: bytes,
                reason: reason,
                recovery: reason == .corrupt ? .corruption : .unsupportedSchema
            )
            return reason == .corrupt ? .corrupt(unsupported) : .unsupported(unsupported)
        }
    }

    private func legacyIdentitiesAreValid(_ command: any LegacyRuntimeCommandShape) -> Bool {
        let metadata = command.payload.metadata
        let targetIDs = [
            command.target.goalID, command.target.captureID, command.target.timeID,
            command.target.reviewID, command.target.stepID, command.target.deliverableID,
            command.target.scopeItemID, command.target.recommendationID, command.target.explanationID,
        ].compactMap { $0 }
        guard targetIDs.allSatisfy({ RuntimeCommandObjectID(rawValue: $0)?.rawValue == $0 }) else { return false }
        let metadataIDKeys = [
            "relatedGoalID", "relatedCaptureID", "placementCandidateID", "destinationStepID",
            "originalBlockID", "scheduleBlockID", "recoveryGoalID", "recoveryCaptureID",
            "recoveryTimeID", "recoveryExplanationID",
        ]
        guard metadataIDKeys.allSatisfy({ key in
            guard let raw = metadata[key] else { return true }
            return RuntimeCommandObjectID(rawValue: raw)?.rawValue == raw
        }) else { return false }
        if let explanationID = command.payload.explanationID,
           RuntimeCommandObjectID(rawValue: explanationID)?.rawValue != explanationID { return false }
        if let requestID = metadata[ExternalCreationCommandMetadataKey.requestID],
           RuntimeCommandObjectID(rawValue: requestID)?.rawValue != requestID { return false }
        if let operationRaw = metadata["externalEffectOperationID"] ?? metadata["operationID"],
           RuntimeExternalOperationID(rawValue: operationRaw)?.rawValue != operationRaw { return false }
        if let receiptRaw = metadata["undoOriginalReceiptID"],
           RuntimeCommandReceiptID(rawValue: receiptRaw)?.rawValue != receiptRaw { return false }
        if metadata["captureGoalHandoffMutation"] == "true" {
            guard let plan = RuntimeCommandPayload.legacyCaptureGoalHandoff(command), hasValidNestedIdentities(plan) else { return false }
        }
        if metadata["timeRitualActionMutation"] == "true" {
            guard let plan = RuntimeCommandPayload.legacyTimeRitual(command), hasValidNestedIdentities(plan) else { return false }
        }
        if metadata["todayGoalStepActionMutation"] == "true" {
            guard let plan = RuntimeCommandPayload.legacyTodayGoalStep(command), hasValidNestedIdentities(plan) else { return false }
        }
        if metadata["todayReceiptMutation"] == "true" {
            guard let receipt = RuntimeCommandPayload.legacyTodayReceipt(command), hasValidNestedIdentities(receipt) else { return false }
        }
        return true
    }

    private static func hasUnknownLegacyDiscriminator(_ bytes: Data) -> Bool {
        guard let object = try? JSONSerialization.jsonObject(with: bytes) as? [String: Any],
              let rawKind = object["kind"] as? String else { return false }
        return AmbitionsCommandKind(rawValue: rawKind) == nil
    }

    private func legacyBehaviorIsSupported(_ command: any LegacyRuntimeCommandShape) -> Bool {
        let metadata = command.payload.metadata
        let targetIDs = [
            command.target.goalID, command.target.captureID, command.target.timeID,
            command.target.reviewID, command.target.stepID, command.target.deliverableID,
            command.target.scopeItemID, command.target.recommendationID, command.target.explanationID,
        ].compactMap { $0 }
        guard targetIDs.allSatisfy({ RuntimeCommandObjectID(rawValue: $0)?.rawValue == $0 }) else { return false }
        let typedMetadataIDKeys = [
            "relatedGoalID", "relatedCaptureID", "placementCandidateID", "destinationStepID",
            "originalBlockID", "scheduleBlockID", "recoveryGoalID", "recoveryCaptureID",
            "recoveryTimeID", "recoveryExplanationID",
        ]
        guard typedMetadataIDKeys.allSatisfy({ key in
            guard let raw = metadata[key] else { return true }
            return RuntimeCommandObjectID(rawValue: raw)?.rawValue == raw
        }) else { return false }
        if let explanationID = command.payload.explanationID,
           RuntimeCommandObjectID(rawValue: explanationID)?.rawValue != explanationID { return false }
        if let requestID = metadata[ExternalCreationCommandMetadataKey.requestID],
           RuntimeCommandObjectID(rawValue: requestID)?.rawValue != requestID { return false }
        if metadata["calendarWriteIntent"] != "true",
           metadata["externalEffectKind"] != nil || metadata["operationID"] != nil {
            guard let operationRaw = metadata["externalEffectOperationID"] ?? metadata["operationID"],
                  let operationID = RuntimeExternalOperationID(rawValue: operationRaw),
                  operationID.rawValue == operationRaw,
                  let kindRaw = metadata["externalEffectKind"],
                  RuntimeExternalEffectKind(rawValue: kindRaw) != nil,
                  command.payload.title != nil else { return false }
        }
        if metadata["captureGoalHandoffMutation"] == "true" {
            guard let plan = RuntimeCommandPayload.legacyCaptureGoalHandoff(command) else { return false }
            return hasValidNestedIdentities(plan)
        }
        if metadata["timeRitualActionMutation"] == "true" {
            guard let plan = RuntimeCommandPayload.legacyTimeRitual(command) else { return false }
            return hasValidNestedIdentities(plan)
        }
        if metadata["todayGoalStepActionMutation"] == "true" {
            guard let plan = RuntimeCommandPayload.legacyTodayGoalStep(command) else { return false }
            return hasValidNestedIdentities(plan)
        }
        if metadata["todayReceiptMutation"] == "true" {
            guard let receipt = RuntimeCommandPayload.legacyTodayReceipt(command) else { return false }
            return hasValidNestedIdentities(receipt)
        }
        if command.kind == .correctTimeWindow {
            if command.payload.metadata["undoOriginalReceiptID"] != nil {
                guard let receiptRaw = command.payload.metadata["undoOriginalReceiptID"],
                      RuntimeCommandReceiptID(rawValue: receiptRaw)?.rawValue == receiptRaw else { return false }
                return command.payload.metadata["expectedProjectionVersion"].flatMap(Int64.init) != nil
            }
            guard let raw = command.payload.metadata["correctionKind"],
                  let correction = TimeMutationActionKind(rawValue: raw) else { return false }
            return TimeMutationActionKind.correctionKinds.contains(correction)
        }
        if command.payload.metadata["calendarWriteIntent"] == "true" {
            return RuntimeCommandPayload.legacyCalendarWrite(command) != nil
        }
        return true
    }

    private func hasValidNestedIdentities<Value: Encodable>(_ value: Value) -> Bool {
        guard let bytes = try? JSONEncoder().encode(value),
              let object = try? JSONSerialization.jsonObject(with: bytes) else { return false }
        return RuntimeNestedIdentityValidator.hasValidIdentities(in: object)
    }
}

struct LegacyV1AmbitionsCommand: Codable, Sendable, Equatable, Hashable, LegacyRuntimeCommandShape {
    let id: String
    let kind: AmbitionsCommandKind
    let source: AmbitionsCommandSource
    let target: AmbitionsCommandTarget
    let payload: AmbitionsCommandPayload
    let validationState: AmbitionsCommandValidationState
    let executionStatus: AmbitionsCommandExecutionStatus
    let result: AmbitionsCommandExecutionResult?
    let createdAt: String
    let requestedAt: String
    let actor: AmbitionsCommandActor
    let sourceSurface: String?
    let relations: AmbitionsCommandRelations
    let localOnly: Bool
    let privacy: EventLedgerPrivacyClassification
    let schemaVersion: String
}

extension AmbitionsCommand {
    var canonicalPayload: RuntimeCommandPayload {
        typedPayload
    }

    var calendarWriteCommandIntent: CalendarWriteCommandIntent? {
        guard case let .schedule(command) = canonicalPayload,
              case let .calendarWrite(intent) = command.action else { return nil }
        return intent
    }

    var timePlacementCommandIntent: TimePlacementCommandIntent? {
        guard case let .schedule(command) = canonicalPayload else { return nil }
        switch command.action {
        case let .createItem(value), let .schedule(value), let .placeStep(value), let .protectWindow(value):
            return value
        case .correctWindow, .undo, .ritual, .calendarWrite:
            return nil
        }
    }

    var timeCorrectionCommandIntent: TimeCorrectionCommandIntent? {
        guard case let .schedule(command) = canonicalPayload,
              case let .correctWindow(intent) = command.action else { return nil }
        return intent
    }

    var commandUndoIntent: CommandUndoIntent? {
        guard case let .schedule(command) = canonicalPayload,
              case let .undo(intent) = command.action else { return nil }
        return intent
    }

    var externalCreationProvenance: ExternalCreationProvenance? {
        guard case let .capture(command) = canonicalPayload,
              case let .quickCapture(provenance) = command.action else { return nil }
        return provenance
    }

    var typedCaptureCommand: CaptureCommand? {
        guard case let .capture(command) = canonicalPayload else { return nil }
        return command
    }
}
