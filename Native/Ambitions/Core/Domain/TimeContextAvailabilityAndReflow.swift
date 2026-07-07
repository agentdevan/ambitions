import Foundation

struct AvailabilityWindow: Codable, Sendable, Equatable, Hashable {
    let start: Date
    let end: Date
    let state: AvailabilityState
    let source: ContextSource

    init(start: Date, end: Date, state: AvailabilityState, source: ContextSource) {
        self.start = start
        self.end = max(end, start)
        self.state = state
        self.source = source
    }

    var interval: DateInterval {
        DateInterval(start: start, end: end)
    }
}

struct StepOccurrence: Identifiable, Codable, Sendable, Equatable, Hashable {
    let id: UUID
    let stepID: UUID
    let scheduledWindow: DateInterval?
    let duration: DurationMetadata
    let rigidity: RigidityLevel
    let readiness: ReadinessState
    let contextRequirements: [ContextRequirement]
    let closureState: ClosureState?
    let cognitiveFits: [StepCognitiveFit]

    init(
        id: UUID = UUID(),
        stepID: UUID,
        scheduledWindow: DateInterval? = nil,
        duration: DurationMetadata,
        rigidity: RigidityLevel,
        readiness: ReadinessState,
        contextRequirements: [ContextRequirement] = [],
        closureState: ClosureState? = nil,
        cognitiveFits: [StepCognitiveFit] = []
    ) {
        self.id = id
        self.stepID = stepID
        self.scheduledWindow = scheduledWindow
        self.duration = duration
        self.rigidity = rigidity
        self.readiness = readiness
        self.contextRequirements = Array(Set(contextRequirements)).sorted { $0.rawValue < $1.rawValue }
        self.closureState = closureState
        self.cognitiveFits = cognitiveFits
    }

    var isRecommendableNow: Bool {
        readiness.isDoableNow && closureState != .waiting && closureState != .blocked && closureState != .needsRecovery
    }
}

enum ReflowReason: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case completedEarly = "completed_early"
    case hardContextChanged = "hard_context_changed"
    case scheduleOpened = "schedule_opened"
    case planOverloaded = "plan_overloaded"
    case userRequested = "user_requested"
}

enum ReflowOption: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case suggestStep = "suggest_step"
    case reflowDay = "reflow_day"
    case protectTime = "protect_time"
    case keepPlan = "keep_plan"

    var displayLabel: String {
        switch self {
        case .suggestStep: "Suggest a step"
        case .reflowDay: "Reflow my day"
        case .protectTime: "Protect this time"
        case .keepPlan: "Keep plan as is"
        }
    }
}

struct ReflowOpportunity: Codable, Sendable, Equatable, Hashable {
    let reason: ReflowReason
    let openedWindow: AvailabilityWindow
    let suggestedOptions: [ReflowOption]
    let requiresUserApproval: Bool

    init(
        reason: ReflowReason,
        openedWindow: AvailabilityWindow,
        suggestedOptions: [ReflowOption] = [.suggestStep, .reflowDay, .protectTime, .keepPlan],
        requiresUserApproval: Bool = true
    ) {
        self.reason = reason
        self.openedWindow = openedWindow
        self.suggestedOptions = Array(Set(suggestedOptions)).sorted { $0.rawValue < $1.rawValue }
        self.requiresUserApproval = requiresUserApproval
    }

    var promptTitle: String {
        switch reason {
        case .completedEarly: "Use this open time?"
        case .hardContextChanged, .scheduleOpened, .planOverloaded, .userRequested: "Adjust the plan?"
        }
    }
}

struct VacationAvailabilityChoice: Codable, Sendable, Equatable, Hashable {
    let behavior: VacationAvailabilityBehavior
    let makeDefaultForFutureVacations: Bool

    init(
        behavior: VacationAvailabilityBehavior = .defaultBehavior,
        makeDefaultForFutureVacations: Bool = false
    ) {
        self.behavior = behavior
        self.makeDefaultForFutureVacations = makeDefaultForFutureVacations
    }
}

struct TimeContextHierarchyProjector: Sendable {
    func availabilityWindows(
        dayStart: Date,
        dayEnd: Date,
        blocks: [TimeContextBlock],
        defaultSource: ContextSource = .systemDefault
    ) -> [AvailabilityWindow] {
        guard dayEnd > dayStart else { return [] }
        let day = DateInterval(start: dayStart, end: dayEnd)
        let hardIntervals = blocks
            .filter(\.isHardContext)
            .compactMap { block -> DateInterval? in
                guard block.end > block.start else { return nil }
                return day.intersection(with: block.interval)
            }
            .sorted { $0.start < $1.start }

        var cursor = dayStart
        var windows: [AvailabilityWindow] = []
        for interval in hardIntervals {
            if interval.start > cursor {
                windows.append(AvailabilityWindow(start: cursor, end: interval.start, state: .open, source: defaultSource))
            }
            cursor = max(cursor, interval.end)
        }
        if cursor < dayEnd {
            windows.append(AvailabilityWindow(start: cursor, end: dayEnd, state: .open, source: defaultSource))
        }
        return windows.filter { $0.end > $0.start }
    }
}
