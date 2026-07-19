import Foundation

let ambitionsProductCanonV2SchemaVersion = "ambitions_product_canon_v2.native.v1"

enum TimeContextKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case work
    case school
    case vacation
    case away
    case calendarEvent = "calendar_event"
    case commute
    case setup
    case transitionBuffer = "transition_buffer"
    case protected
    case family
    case household
    case petCare = "pet_care"
    case sleep
    case recovery
    case open
    case free
}

enum ContextSource: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case fromYou = "from_you"
    case workSchedule = "work_schedule"
    case schoolSchedule = "school_schedule"
    case calendar
    case plan
    case protectedByYou = "protected_by_you"
    case receipt
    case proof
    case suggestedByAmbitions = "suggested_by_ambitions"
    case systemDefault = "system_default"

    var evidenceLabel: String {
        switch self {
        case .fromYou: "From you"
        case .workSchedule: "Based on your work schedule"
        case .schoolSchedule: "Based on your school schedule"
        case .calendar: "From your calendar"
        case .plan: "Based on your plan"
        case .protectedByYou: "Protected by you"
        case .receipt: "From a receipt"
        case .proof: "From proof"
        case .suggestedByAmbitions: "Suggested by Ambitions"
        case .systemDefault: "Created in Ambitions"
        }
    }
}

enum RigidityLevel: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case fixed
    case anchored
    case protected
    case flexible
    case optional
    case waiting
    case someday

    var canReflowWithoutExplicitApproval: Bool {
        switch self {
        case .flexible, .optional:
            true
        case .fixed, .anchored, .protected, .waiting, .someday:
            false
        }
    }

    var displayLabel: String {
        switch self {
        case .fixed: "Fixed"
        case .anchored: "Anchored"
        case .protected: "Protected"
        case .flexible: "Flexible"
        case .optional: "Optional"
        case .waiting: "Waiting"
        case .someday: "Someday"
        }
    }
}

enum AvailabilityState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case free
    case open
    case flexible
    case protectedFreeTime = "protected_free_time"
    case unavailable
    case lowControl = "low_control"
    case availableIfNeeded = "available_if_needed"
    case doNotFill = "do_not_fill"

    var displayLabel: String {
        switch self {
        case .free: "Free"
        case .open: "Open"
        case .flexible: "Flexible"
        case .protectedFreeTime: "Protected free time"
        case .unavailable: "Unavailable"
        case .lowControl: "Low-control"
        case .availableIfNeeded: "Available if needed"
        case .doNotFill: "Do not fill"
        }
    }

    var isUsableOnlyByUserChoice: Bool {
        switch self {
        case .protectedFreeTime, .availableIfNeeded, .doNotFill:
            true
        case .free, .open, .flexible, .unavailable, .lowControl:
            false
        }
    }
}

enum DurationSource: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case userSet = "user_set"
    case userAccepted = "user_accepted"
    case suggested
    case historical
    case unset
    case actual
}

struct DurationMetadata: Codable, Sendable, Equatable, Hashable {
    let plannedDuration: Duration?
    let actualDuration: Duration?
    let source: DurationSource
    let range: ClosedRange<Duration>?

    init(
        plannedDuration: Duration? = nil,
        actualDuration: Duration? = nil,
        source: DurationSource,
        range: ClosedRange<Duration>? = nil
    ) {
        self.plannedDuration = plannedDuration
        self.actualDuration = actualDuration
        self.source = source
        self.range = range
    }

    var displayLabel: String {
        switch source {
        case .userSet, .userAccepted:
            guard let plannedDuration else { return "Duration not set" }
            return "\(Self.format(plannedDuration)) planned"
        case .suggested:
            if let range {
                return "Suggested: \(Self.format(range.lowerBound))-\(Self.format(range.upperBound))"
            }
            guard let plannedDuration else { return "Suggested duration not set" }
            return "Suggested: \(Self.format(plannedDuration))"
        case .historical:
            if let range {
                return "Usually \(Self.format(range.lowerBound))-\(Self.format(range.upperBound))"
            }
            guard let plannedDuration else { return "Usually not enough history yet" }
            return "Usually \(Self.format(plannedDuration))"
        case .unset:
            return "Duration not set"
        case .actual:
            guard let actualDuration else { return "Duration not set" }
            return "Completed in \(Self.format(actualDuration))"
        }
    }

    var isGroundedForFactDisplay: Bool {
        switch source {
        case .userSet, .userAccepted, .suggested, .historical, .unset, .actual:
            true
        }
    }

    private static func format(_ duration: Duration) -> String {
        let seconds = max(0, Int(duration.components.seconds))
        if seconds < 60 { return "\(seconds) sec" }
        let minutes = seconds / 60
        if minutes < 60 { return "\(minutes) min" }
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        return remainingMinutes == 0 ? "\(hours)h" : "\(hours)h \(remainingMinutes)m"
    }
}

enum ReadinessState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case ready
    case waitingOnPerson = "waiting_on_person"
    case waitingOnTime = "waiting_on_time"
    case waitingOnPlace = "waiting_on_place"
    case waitingOnTool = "waiting_on_tool"
    case blocked
    case needsReview = "needs_review"

    var displayLabel: String {
        switch self {
        case .ready: "Ready"
        case .waitingOnPerson, .waitingOnTime, .waitingOnPlace, .waitingOnTool: "Waiting"
        case .blocked: "Blocked"
        case .needsReview: "Needs Review"
        }
    }

    var isDoableNow: Bool {
        self == .ready
    }
}

enum ContextRequirement: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case location
    case device
    case tool
    case energyType = "energy_type"
    case internetRequired = "internet_required"
    case quietRequired = "quiet_required"
    case peopleRequired = "people_required"

    var displayLabel: String {
        switch self {
        case .location: "Location"
        case .device: "Device"
        case .tool: "Tool"
        case .energyType: "Energy"
        case .internetRequired: "Internet required"
        case .quietRequired: "Quiet required"
        case .peopleRequired: "People required"
        }
    }
}

enum ClosureState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case now
    case next
    case later
    case awaitingClosure = "awaiting_closure"
    case completed
    case stillCounts = "still_counts"
    case moved
    case skippedIntentionally = "skipped_intentionally"
    case notNeeded = "not_needed"
    case blocked
    case waiting
    case needsRecovery = "needs_recovery"
    case needsReview = "needs_review"

    var displayLabel: String {
        switch self {
        case .now: "Now"
        case .next: "Next"
        case .later: "Later"
        case .awaitingClosure: "Needs a quick check"
        case .completed: "Completed"
        case .stillCounts: "Still Counts"
        case .moved: "Rescheduled"
        case .skippedIntentionally: "Skipped intentionally"
        case .notNeeded: "Not Needed"
        case .blocked, .needsRecovery: "Needs Recovery"
        case .waiting: "Waiting"
        case .needsReview: "Needs Review"
        }
    }
}

enum CognitiveFit: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case deepWork = "deep_work"
    case creative
    case admin
    case light
    case recoveryFriendly = "recovery_friendly"
    case errands
    case social
    case planning
    case review
    case household

    var displayLabel: String {
        switch self {
        case .deepWork: "Deep work"
        case .creative: "Creative"
        case .admin: "Admin"
        case .light: "Light"
        case .recoveryFriendly: "Recovery-friendly"
        case .errands: "Errands"
        case .social: "Social"
        case .planning: "Planning"
        case .review: "Review"
        case .household: "Household"
        }
    }
}

enum CognitiveFitEvidence: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case inferredFromContext = "inferred_from_context"
    case inferredFromHistory = "inferred_from_history"
    case inferredFromRule = "inferred_from_rule"
    case userSelected = "user_selected"
}

struct StepCognitiveFit: Codable, Sendable, Equatable, Hashable {
    let fit: CognitiveFit
    let evidence: CognitiveFitEvidence
}

enum AutomationLevel: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case manual
    case guided
    case adaptive

    static let defaultLevel: AutomationLevel = .guided

    var displayLabel: String {
        switch self {
        case .manual: "Manual"
        case .guided: "Guided"
        case .adaptive: "Adaptive"
        }
    }

    var explanation: String {
        switch self {
        case .manual: "Ambitions suggests. You decide."
        case .guided: "Ambitions proposes and asks before changing meaningful parts of the day."
        case .adaptive: "Ambitions may adjust flexible items within your rules and saves receipts."
        }
    }
}

enum VacationAvailabilityBehavior: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unavailable
    case protected
    case flexible
    case open

    static let defaultBehavior: VacationAvailabilityBehavior = .unavailable

    var availabilityState: AvailabilityState {
        switch self {
        case .unavailable: .unavailable
        case .protected: .protectedFreeTime
        case .flexible: .flexible
        case .open: .open
        }
    }

    var displayLabel: String {
        switch self {
        case .unavailable: "Unavailable"
        case .protected: "Protected"
        case .flexible: "Flexible"
        case .open: "Open"
        }
    }
}

struct TimeContextBlock: Identifiable, Codable, Sendable, Equatable, Hashable {
    let id: UUID
    let kind: TimeContextKind
    let start: Date
    let end: Date
    let source: ContextSource
    let rigidity: RigidityLevel
    let availability: AvailabilityState

    init(
        id: UUID = UUID(),
        kind: TimeContextKind,
        start: Date,
        end: Date,
        source: ContextSource,
        rigidity: RigidityLevel,
        availability: AvailabilityState
    ) {
        self.id = id
        self.kind = kind
        self.start = start
        self.end = max(end, start)
        self.source = source
        self.rigidity = rigidity
        self.availability = availability
    }

    var interval: DateInterval {
        DateInterval(start: start, end: end)
    }

    var isHardContext: Bool {
        switch kind {
        case .open, .free:
            return false
        case .vacation, .away:
            return availability != .open && availability != .flexible && availability != .availableIfNeeded
        case .work, .school, .calendarEvent, .commute, .setup, .transitionBuffer, .protected, .family, .household, .petCare, .sleep, .recovery:
            return true
        }
    }
}
