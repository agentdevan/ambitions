import Foundation

let realityModelSchemaVersion = "reality_model.native.v1"

enum RealityWindowKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case working
    case freeTime = "free_time"
    case protected
    case vacation
    case away
    case blockedBusy = "blocked_busy"
    case flexible
    case scheduledAmbitionsBlock = "scheduled_ambitions_block"
    case calendarDerivedBusy = "calendar_derived_busy"
    case open

    var isAwayLike: Bool {
        self == .vacation || self == .away
    }
}

enum RealityWindowSource: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case userDefined = "user_defined"
    case ambitionsPlan = "ambitions_plan"
    case captureSeed = "capture_seed"
    case calendarDerived = "calendar_derived"
    case systemDefault = "system_default"
}

enum CalendarPermissionState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case notDetermined = "not_determined"
    case denied
    case restricted
    case readWrite = "read_write"
    case writeOnly = "write_only"
    case unavailable

    var canRead: Bool { self == .readWrite }
    var canWrite: Bool { self == .readWrite || self == .writeOnly }
}

struct RealityWindow: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: RealityWindowKind
    let source: RealityWindowSource
    let start: Date
    let end: Date
    let title: String
    let contextLens: NowContextLens
    let isFlexible: Bool
    let isProtected: Bool
    let isCalendarDerived: Bool
    let localOnly: Bool
    let privacy: EventLedgerPrivacyClassification
    let relatedGoalID: String?
    let relatedCaptureID: String?
    let relatedPlanID: String?
    let eventLedgerEntryIDs: [String]
    let recommendationExplanationIDs: [String]

    init(
        id: String,
        kind: RealityWindowKind,
        source: RealityWindowSource,
        start: Date,
        end: Date,
        title: String,
        contextLens: NowContextLens = .all,
        isFlexible: Bool? = nil,
        isProtected: Bool? = nil,
        relatedGoalID: String? = nil,
        relatedCaptureID: String? = nil,
        relatedPlanID: String? = nil,
        eventLedgerEntryIDs: [String] = [],
        recommendationExplanationIDs: [String] = []
    ) {
        self.id = id
        self.kind = kind
        self.source = source
        self.start = start
        self.end = end
        self.title = title
        self.contextLens = contextLens
        self.isFlexible = isFlexible ?? (kind == .flexible || kind == .open)
        self.isProtected = isProtected ?? (kind == .protected)
        self.isCalendarDerived = source == .calendarDerived || kind == .calendarDerivedBusy
        self.localOnly = true
        self.privacy = source == .calendarDerived ? .calendarDerived : .standard
        self.relatedGoalID = relatedGoalID
        self.relatedCaptureID = relatedCaptureID
        self.relatedPlanID = relatedPlanID
        self.eventLedgerEntryIDs = Self.normalized(eventLedgerEntryIDs)
        self.recommendationExplanationIDs = Self.normalized(recommendationExplanationIDs)
    }

    var durationMinutes: Int {
        max(0, Int(end.timeIntervalSince(start) / 60))
    }

    var interval: DateInterval {
        DateInterval(start: start, end: end)
    }

    var isAwayLike: Bool {
        kind.isAwayLike
    }

    private static func normalized(_ values: [String]) -> [String] {
        Array(Set(values.filter { $0.isEmpty == false })).sorted()
    }
}

struct OpenWindowCandidate: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let start: Date
    let end: Date
    let durationMinutes: Int
    let contextLens: NowContextLens
    let source: RealityWindowSource
    let fitSummary: String
    let canFitDeadlineItem: Bool
    let isCalendarDerived: Bool
    let localOnly: Bool
    let privacy: EventLedgerPrivacyClassification

    init(
        id: String,
        start: Date,
        end: Date,
        contextLens: NowContextLens = .all,
        source: RealityWindowSource,
        fitSummary: String,
        canFitDeadlineItem: Bool = true
    ) {
        self.id = id
        self.start = start
        self.end = end
        self.durationMinutes = max(0, Int(end.timeIntervalSince(start) / 60))
        self.contextLens = contextLens
        self.source = source
        self.fitSummary = fitSummary
        self.canFitDeadlineItem = canFitDeadlineItem
        self.isCalendarDerived = source == .calendarDerived
        self.localOnly = true
        self.privacy = source == .calendarDerived ? .calendarDerived : .standard
    }
}

struct CapacityEstimate: Codable, Sendable, Equatable, Hashable {
    let openMinutes: Int
    let totalOpenMinutes: Int
    let protectedMinutes: Int
    let vacationAwayMinutes: Int
    let blockedBusyMinutes: Int
    let blockedMinutes: Int
    let flexibleMinutes: Int
    let scheduledAmbitionsMinutes: Int
    let calendarBusyMinutes: Int
    let timeFitProofSummary: String
    let deadlineFitProofSummary: String
    let capacityLevel: NowPressureLevel
    let summary: String
    let localOnly: Bool
    let privacy: EventLedgerPrivacyClassification
}

struct AvailabilitySummary: Codable, Sendable, Equatable, Hashable {
    let horizonStart: Date
    let horizonEnd: Date
    let openWindowCount: Int
    let blockedWindowCount: Int
    let protectedWindowCount: Int
    let calendarDerivedBusyCount: Int
    let schedulePressure: NowPressureLevel
    let summary: String
}

struct RealityConflictSummary: Codable, Sendable, Equatable, Hashable {
    let conflictCount: Int
    let calendarConflictCount: Int
    let protectedConflictCount: Int
    let affectedWindowIDs: [String]
    let summary: String
    let localOnly: Bool
    let privacy: EventLedgerPrivacyClassification
}

struct CalendarDerivedContext: Codable, Sendable, Equatable, Hashable {
    let permissionState: CalendarPermissionState
    let observedRangeStart: Date?
    let observedRangeEnd: Date?
    let derivedBusyWindowCount: Int
    let hasCalendarReadAccess: Bool
    let userInitiatedPlanAction: String?
    let explanation: String
    let eventLedgerEntryIDs: [String]
    let recommendationExplanationIDs: [String]
    let localOnly: Bool
    let privacy: EventLedgerPrivacyClassification

    init(
        permissionState: CalendarPermissionState,
        observedRangeStart: Date? = nil,
        observedRangeEnd: Date? = nil,
        derivedBusyWindowCount: Int = 0,
        userInitiatedPlanAction: String? = nil,
        explanation: String,
        eventLedgerEntryIDs: [String] = [],
        recommendationExplanationIDs: [String] = []
    ) {
        self.permissionState = permissionState
        self.observedRangeStart = observedRangeStart
        self.observedRangeEnd = observedRangeEnd
        self.derivedBusyWindowCount = max(0, derivedBusyWindowCount)
        self.hasCalendarReadAccess = permissionState.canRead
        self.userInitiatedPlanAction = userInitiatedPlanAction
        self.explanation = explanation
        self.eventLedgerEntryIDs = Array(Set(eventLedgerEntryIDs.filter { $0.isEmpty == false })).sorted()
        self.recommendationExplanationIDs = Array(Set(recommendationExplanationIDs.filter { $0.isEmpty == false })).sorted()
        self.localOnly = true
        self.privacy = .calendarDerived
    }
}

struct ScheduledAmbitionsBlock: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let start: Date
    let end: Date
    let contextLens: NowContextLens
    let relatedGoalID: String?
    let relatedCaptureID: String?
    let relatedPlanID: String?
    let isUserConfirmed: Bool
    let calendarEventIdentifier: String?
    let localOnly: Bool
    let privacy: EventLedgerPrivacyClassification

    init(
        id: String,
        title: String,
        start: Date,
        end: Date,
        contextLens: NowContextLens = .all,
        relatedGoalID: String? = nil,
        relatedCaptureID: String? = nil,
        relatedPlanID: String? = nil,
        isUserConfirmed: Bool,
        calendarEventIdentifier: String? = nil
    ) {
        self.id = id
        self.title = title
        self.start = start
        self.end = end
        self.contextLens = contextLens
        self.relatedGoalID = relatedGoalID
        self.relatedCaptureID = relatedCaptureID
        self.relatedPlanID = relatedPlanID
        self.isUserConfirmed = isUserConfirmed
        self.calendarEventIdentifier = calendarEventIdentifier
        self.localOnly = true
        self.privacy = .standard
    }
}

struct ScheduledBlockWriteIntent: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let block: ScheduledAmbitionsBlock
    let requestedAt: Date
    let source: AmbitionsCommandSource
    let requiresExplicitUserConfirmation: Bool

    init(
        id: String,
        block: ScheduledAmbitionsBlock,
        requestedAt: Date,
        source: AmbitionsCommandSource = .time,
        requiresExplicitUserConfirmation: Bool = true
    ) {
        self.id = id
        self.block = block
        self.requestedAt = requestedAt
        self.source = source
        self.requiresExplicitUserConfirmation = requiresExplicitUserConfirmation
    }

    var isExecutable: Bool {
        block.isUserConfirmed && requiresExplicitUserConfirmation
    }
}

typealias CalendarWriteIntent = ScheduledBlockWriteIntent

extension ScheduledAmbitionsBlock {
    var localScheduleSourceRecordID: String {
        "SourceRecord.local-schedule.\(id)"
    }

    func localScheduleReceiptID(action: String) -> String {
        "Receipt.local-schedule.\(id).\(action)"
    }

    func localScheduleReplayTraceID(action: String) -> String {
        "ReplayTrace.local-schedule.\(id).\(action)"
    }

    var localScheduleYouInspectionSummary: String {
        "You / What Ambitions knows can inspect this local schedule block, its SourceRecord, Receipt, and ReplayTrace IDs."
    }
}

func localScheduleBlocks(from data: Data, decoder: JSONDecoder = JSONDecoder()) throws -> [ScheduledAmbitionsBlock] {
    try decoder.decode([ScheduledAmbitionsBlock].self, from: data)
}

func localScheduleExportData(
    for blocks: [ScheduledAmbitionsBlock],
    encoder: JSONEncoder = JSONEncoder()
) throws -> Data {
    try encoder.encode(blocks)
}

func loadLocalScheduleBlocks(from fileURL: URL, decoder: JSONDecoder = JSONDecoder()) throws -> [ScheduledAmbitionsBlock] {
    guard FileManager.default.fileExists(atPath: fileURL.path) else {
        return []
    }
    return try localScheduleBlocks(from: Data(contentsOf: fileURL), decoder: decoder)
}

@discardableResult
func saveLocalScheduleBlocks(
    _ blocks: [ScheduledAmbitionsBlock],
    to fileURL: URL,
    encoder: JSONEncoder = JSONEncoder()
) throws -> [String] {
    try FileManager.default.createDirectory(
        at: fileURL.deletingLastPathComponent(),
        withIntermediateDirectories: true
    )
    let sortedBlocks = blocks.sorted {
        if $0.start != $1.start {
            return $0.start < $1.start
        }
        return $0.id < $1.id
    }
    try localScheduleExportData(for: sortedBlocks, encoder: encoder)
        .write(to: fileURL, options: [.atomic])
    return sortedBlocks.map { $0.localScheduleReceiptID(action: "save") }
}

@discardableResult
func upsertLocalScheduleBlock(
    _ block: ScheduledAmbitionsBlock,
    in fileURL: URL,
    decoder: JSONDecoder = JSONDecoder(),
    encoder: JSONEncoder = JSONEncoder()
) throws -> [String] {
    let existing = try loadLocalScheduleBlocks(from: fileURL, decoder: decoder)
    let retained = existing.filter { $0.id != block.id }
    return try saveLocalScheduleBlocks(retained + [block], to: fileURL, encoder: encoder)
}

@discardableResult
func deleteLocalScheduleBlock(
    id: String,
    from fileURL: URL,
    decoder: JSONDecoder = JSONDecoder(),
    encoder: JSONEncoder = JSONEncoder()
) throws -> String? {
    let existing = try loadLocalScheduleBlocks(from: fileURL, decoder: decoder)
    guard existing.contains(where: { $0.id == id }) else {
        return nil
    }
    let retained = existing.filter { $0.id != id }
    _ = try saveLocalScheduleBlocks(retained, to: fileURL, encoder: encoder)
    return "Receipt.local-schedule.\(id).delete"
}

struct RealitySnapshot: Codable, Sendable, Equatable, Identifiable {
    let id: String
    let generatedAt: Date
    let horizonStart: Date
    let horizonEnd: Date
    let activeContextLens: NowContextLens
    let windows: [RealityWindow]
    let vacationAwayWindows: [RealityWindow]
    let openWindowCandidates: [OpenWindowCandidate]
    let availability: AvailabilitySummary
    let calendarContext: CalendarDerivedContext?
    let conflictSummary: RealityConflictSummary
    let scheduledBlocks: [ScheduledAmbitionsBlock]
    let capacityEstimate: CapacityEstimate
    let deadlinePressure: NowPressureSummary
    let contextFitSummary: String
    let eventLedgerEntryIDs: [String]
    let recommendationExplanationIDs: [String]
    let localOnly: Bool
    let privacy: EventLedgerPrivacyClassification
    let schemaVersion: String

    init(
        id: String,
        generatedAt: Date,
        horizonStart: Date,
        horizonEnd: Date,
        activeContextLens: NowContextLens,
        windows: [RealityWindow],
        vacationAwayWindows: [RealityWindow] = [],
        openWindowCandidates: [OpenWindowCandidate],
        availability: AvailabilitySummary,
        calendarContext: CalendarDerivedContext? = nil,
        conflictSummary: RealityConflictSummary,
        scheduledBlocks: [ScheduledAmbitionsBlock] = [],
        capacityEstimate: CapacityEstimate,
        deadlinePressure: NowPressureSummary,
        contextFitSummary: String,
        eventLedgerEntryIDs: [String] = [],
        recommendationExplanationIDs: [String] = [],
        schemaVersion: String = realityModelSchemaVersion
    ) {
        self.id = id
        self.generatedAt = generatedAt
        self.horizonStart = horizonStart
        self.horizonEnd = horizonEnd
        self.activeContextLens = activeContextLens
        self.windows = windows.sorted { lhs, rhs in
            if lhs.start == rhs.start { return lhs.id < rhs.id }
            return lhs.start < rhs.start
        }
        self.vacationAwayWindows = vacationAwayWindows.sorted { lhs, rhs in
            if lhs.start == rhs.start { return lhs.id < rhs.id }
            return lhs.start < rhs.start
        }
        self.openWindowCandidates = openWindowCandidates.sorted { lhs, rhs in
            if lhs.start == rhs.start { return lhs.id < rhs.id }
            return lhs.start < rhs.start
        }
        self.availability = availability
        self.calendarContext = calendarContext
        self.conflictSummary = conflictSummary
        self.scheduledBlocks = scheduledBlocks.sorted { $0.start < $1.start }
        self.capacityEstimate = capacityEstimate
        self.deadlinePressure = deadlinePressure
        self.contextFitSummary = contextFitSummary
        self.eventLedgerEntryIDs = Array(Set(eventLedgerEntryIDs.filter { $0.isEmpty == false })).sorted()
        self.recommendationExplanationIDs = Array(Set(recommendationExplanationIDs.filter { $0.isEmpty == false })).sorted()
        self.localOnly = true
        self.privacy = calendarContext == nil && windows.contains(where: \.isCalendarDerived) == false ? .standard : .calendarDerived
        self.schemaVersion = schemaVersion
    }
}
