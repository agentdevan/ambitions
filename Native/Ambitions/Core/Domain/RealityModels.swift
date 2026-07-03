import Foundation

let realityModelSchemaVersion = "reality_model.native.v1"

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
    let userInitiatedTimeAction: String?
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
        userInitiatedTimeAction: String? = nil,
        explanation: String,
        eventLedgerEntryIDs: [String] = [],
        recommendationExplanationIDs: [String] = []
    ) {
        self.permissionState = permissionState
        self.observedRangeStart = observedRangeStart
        self.observedRangeEnd = observedRangeEnd
        self.derivedBusyWindowCount = max(0, derivedBusyWindowCount)
        self.hasCalendarReadAccess = permissionState.canRead
        self.userInitiatedTimeAction = userInitiatedTimeAction
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
        "You / Search Ambitions can inspect this local schedule block, source, receipt, and reason."
    }
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
