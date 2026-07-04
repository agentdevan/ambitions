import Foundation

enum OpenCapacityBand: String, Sendable, CaseIterable, Hashable {
    case transitionOnly
    case lightWindow
    case focusedBlock
    case deepBlock
}

struct LifeShapePlanningDefaults: Sendable, Hashable {
    let minimumStepMinutes: Int
    let transitionBufferMinutes: Int
    let allowDeepBlocks: Bool

    init(minimumStepMinutes: Int = 10, transitionBufferMinutes: Int = 5, allowDeepBlocks: Bool = true) {
        self.minimumStepMinutes = max(1, minimumStepMinutes)
        self.transitionBufferMinutes = max(0, transitionBufferMinutes)
        self.allowDeepBlocks = allowDeepBlocks
    }
}

struct OpenCapacityInput: Sendable, Hashable {
    let now: Date
    let dayStart: Date
    let dayEnd: Date
    let fixedPoints: [FixedPoint]
    let protectedBoundaries: [ProtectedBoundary]
    let manualUnavailableWindows: [ProtectedBoundary]
    let planningDefaults: LifeShapePlanningDefaults
    let stepDurationEstimates: [Int]
    let calendarPermissionState: CalendarPermissionState

    init(
        now: Date,
        dayStart: Date,
        dayEnd: Date,
        fixedPoints: [FixedPoint] = [],
        protectedBoundaries: [ProtectedBoundary] = [],
        manualUnavailableWindows: [ProtectedBoundary] = [],
        planningDefaults: LifeShapePlanningDefaults = LifeShapePlanningDefaults(),
        stepDurationEstimates: [Int] = [],
        calendarPermissionState: CalendarPermissionState = .unavailable
    ) {
        self.now = now
        self.dayStart = dayStart
        self.dayEnd = dayEnd
        self.fixedPoints = fixedPoints
        self.protectedBoundaries = protectedBoundaries
        self.manualUnavailableWindows = manualUnavailableWindows
        self.planningDefaults = planningDefaults
        self.stepDurationEstimates = stepDurationEstimates.map { max(1, $0) }.sorted()
        self.calendarPermissionState = calendarPermissionState
    }
}

struct OpenCapacityWindow: Identifiable, Sendable, Hashable {
    let id: String
    let start: Date
    let end: Date
    let usableMinutes: Int
    let band: OpenCapacityBand
    let canFitEstimatedStep: Bool
    let derivation: LifeShapeDerivation
    let accessibilitySummary: String
}

struct OpenCapacityProjection: Sendable, Hashable {
    let windows: [OpenCapacityWindow]
    let visibleWindows: [OpenCapacityWindow]
    let calendarFallback: LifeShapeFallback?
    let semanticSummary: String
}

struct OpenCapacityEngine: Sendable {
    func project(_ input: OpenCapacityInput) -> OpenCapacityProjection {
        let horizonStart = max(input.now, input.dayStart)
        guard input.dayEnd > horizonStart else {
            return OpenCapacityProjection(
                windows: [],
                visibleWindows: [],
                calendarFallback: calendarFallback(for: input.calendarPermissionState),
                semanticSummary: "No open capacity remains in this day."
            )
        }
        guard hasCapacityEvidence(input) else {
            return OpenCapacityProjection(
                windows: [],
                visibleWindows: [],
                calendarFallback: calendarFallback(for: input.calendarPermissionState),
                semanticSummary: "Manual planning is available, but no open capacity is claimed yet."
            )
        }

        let blocked = mergedBlockedIntervals(input: input, horizonStart: horizonStart, horizonEnd: input.dayEnd)
        let rawWindows = openIntervals(from: horizonStart, to: input.dayEnd, blocked: blocked)
        let windows = rawWindows.enumerated().map { index, interval in
            makeWindow(index: index, interval: interval, input: input, fragmented: rawWindows.count > 1)
        }
        let visibleWindows = visibleWindows(from: windows)
        let summary: String
        if visibleWindows.isEmpty {
            summary = input.calendarPermissionState == .denied
                ? "Calendar is unavailable, and manual blocks leave no open window right now."
                : "Manual blocks leave no open window right now."
        } else {
            summary = "\(visibleWindows.count) open window\(visibleWindows.count == 1 ? "" : "s") available from deterministic local inputs."
        }

        return OpenCapacityProjection(
            windows: windows,
            visibleWindows: visibleWindows,
            calendarFallback: calendarFallback(for: input.calendarPermissionState),
            semanticSummary: summary
        )
    }

    private func makeWindow(
        index: Int,
        interval: DateInterval,
        input: OpenCapacityInput,
        fragmented: Bool
    ) -> OpenCapacityWindow {
        let buffer = input.planningDefaults.transitionBufferMinutes
        let usableMinutes = max(0, Int(interval.duration / 60) - buffer)
        let canFitEstimatedStep = input.stepDurationEstimates.first.map { usableMinutes >= $0 } ?? (usableMinutes >= input.planningDefaults.minimumStepMinutes)
        let band = band(
            usableMinutes: usableMinutes,
            fragmented: fragmented,
            allowDeepBlocks: input.planningDefaults.allowDeepBlocks
        )
        let id = "open.\(index).\(Int(interval.start.timeIntervalSince1970)).\(Int(interval.end.timeIntervalSince1970))"
        let derivation = LifeShapeDerivation(
            inputRefs: inputRefs(input: input),
            ruleIDs: [
                "lifeshape.open.subtract-blocked-intervals",
                "lifeshape.open.apply-transition-buffer",
                LifeShapeRuleID(rawValue: "lifeshape.open.band.\(band.rawValue)")
            ],
            clockDerivation: "Frozen input now \(Int(input.now.timeIntervalSince1970)) against day boundary \(Int(input.dayStart.timeIntervalSince1970))-\(Int(input.dayEnd.timeIntervalSince1970)).",
            fallbackState: calendarFallback(for: input.calendarPermissionState)
        )
        return OpenCapacityWindow(
            id: id,
            start: interval.start,
            end: interval.end,
            usableMinutes: usableMinutes,
            band: band,
            canFitEstimatedStep: canFitEstimatedStep,
            derivation: derivation,
            accessibilitySummary: "\(band.title). \(usableMinutes) usable minutes after transition buffer."
        )
    }

    private func inputRefs(input: OpenCapacityInput) -> [LifeShapeInputRef] {
        let refs = [
            LifeShapeInputRef(id: "lifeshape.clock.now", kind: .clock, label: "Current Time"),
            LifeShapeInputRef(id: "lifeshape.day-boundary", kind: .localDefault, label: "Day boundary")
        ] + input.fixedPoints.map(\.inputRef) + input.protectedBoundaries.map(\.inputRef) + input.manualUnavailableWindows.map(\.inputRef)
        return Array(Set(refs)).sorted { $0.id < $1.id }
    }

    private func hasCapacityEvidence(_ input: OpenCapacityInput) -> Bool {
        input.calendarPermissionState.canRead ||
            input.fixedPoints.isEmpty == false ||
            input.protectedBoundaries.isEmpty == false ||
            input.manualUnavailableWindows.isEmpty == false
    }

    private func band(usableMinutes: Int, fragmented: Bool, allowDeepBlocks: Bool) -> OpenCapacityBand {
        if usableMinutes < 10 { return .transitionOnly }
        if usableMinutes < 25 { return .lightWindow }
        if usableMinutes < 60 { return .focusedBlock }
        return allowDeepBlocks && fragmented == false ? .deepBlock : .focusedBlock
    }

    private func visibleWindows(from windows: [OpenCapacityWindow]) -> [OpenCapacityWindow] {
        if windows.count <= 4 { return windows }
        return windows
            .sorted {
                if $0.band.rank != $1.band.rank { return $0.band.rank > $1.band.rank }
                if $0.usableMinutes != $1.usableMinutes { return $0.usableMinutes > $1.usableMinutes }
                return $0.start < $1.start
            }
            .prefix(3)
            .sorted { $0.start < $1.start }
    }

    private func calendarFallback(for permission: CalendarPermissionState) -> LifeShapeFallback? {
        CalendarPermission().lifeShapeFallback(permissionState: permission)
    }

    private func mergedBlockedIntervals(
        input: OpenCapacityInput,
        horizonStart: Date,
        horizonEnd: Date
    ) -> [DateInterval] {
        let intervals = (input.fixedPoints.map { DateInterval(start: $0.start, end: $0.end) } +
            input.protectedBoundaries.map { DateInterval(start: $0.start, end: $0.end) } +
            input.manualUnavailableWindows.map { DateInterval(start: $0.start, end: $0.end) })
            .compactMap { clipped($0, start: horizonStart, end: horizonEnd) }
            .sorted { $0.start < $1.start }
        return intervals.reduce(into: [DateInterval]()) { merged, interval in
            guard let last = merged.last else {
                merged.append(interval)
                return
            }
            if interval.start <= last.end {
                merged[merged.count - 1] = DateInterval(start: last.start, end: max(last.end, interval.end))
            } else {
                merged.append(interval)
            }
        }
    }

    private func openIntervals(from start: Date, to end: Date, blocked: [DateInterval]) -> [DateInterval] {
        var cursor = start
        var intervals: [DateInterval] = []
        for block in blocked {
            if block.start > cursor {
                intervals.append(DateInterval(start: cursor, end: block.start))
            }
            cursor = max(cursor, block.end)
        }
        if cursor < end {
            intervals.append(DateInterval(start: cursor, end: end))
        }
        return intervals
    }

    private func clipped(_ interval: DateInterval, start: Date, end: Date) -> DateInterval? {
        let clippedStart = max(interval.start, start)
        let clippedEnd = min(interval.end, end)
        guard clippedEnd > clippedStart else { return nil }
        return DateInterval(start: clippedStart, end: clippedEnd)
    }
}

private extension OpenCapacityBand {
    var title: String {
        switch self {
        case .transitionOnly: "Transition only"
        case .lightWindow: "Light window"
        case .focusedBlock: "Focused block"
        case .deepBlock: "Deep block"
        }
    }

    var rank: Int {
        switch self {
        case .transitionOnly: 0
        case .lightWindow: 1
        case .focusedBlock: 2
        case .deepBlock: 3
        }
    }
}
