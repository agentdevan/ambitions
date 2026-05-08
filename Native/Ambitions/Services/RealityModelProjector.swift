import Foundation

struct RealityProjectionInput: Sendable, Equatable {
    let now: Date
    let horizon: DateInterval
    let activeContextLens: NowContextLens
    let workingWindows: [RealityWindow]
    let freeTimeWindows: [RealityWindow]
    let protectedWindows: [RealityWindow]
    let flexibleWindows: [RealityWindow]
    let scheduledBlocks: [ScheduledAmbitionsBlock]
    let calendarBusyWindows: [RealityWindow]
    let calendarContext: CalendarDerivedContext?
    let deadlineHints: [Date]
    let minimumWindowMinutes: Int

    init(
        now: Date,
        horizon: DateInterval,
        activeContextLens: NowContextLens = .all,
        workingWindows: [RealityWindow] = [],
        freeTimeWindows: [RealityWindow] = [],
        protectedWindows: [RealityWindow] = [],
        flexibleWindows: [RealityWindow] = [],
        scheduledBlocks: [ScheduledAmbitionsBlock] = [],
        calendarBusyWindows: [RealityWindow] = [],
        calendarContext: CalendarDerivedContext? = nil,
        deadlineHints: [Date] = [],
        minimumWindowMinutes: Int = 30
    ) {
        self.now = now
        self.horizon = horizon
        self.activeContextLens = activeContextLens
        self.workingWindows = workingWindows
        self.freeTimeWindows = freeTimeWindows
        self.protectedWindows = protectedWindows
        self.flexibleWindows = flexibleWindows
        self.scheduledBlocks = scheduledBlocks
        self.calendarBusyWindows = calendarBusyWindows
        self.calendarContext = calendarContext
        self.deadlineHints = deadlineHints
        self.minimumWindowMinutes = max(15, minimumWindowMinutes)
    }
}

protocol RealitySnapshotProjecting: Sendable {
    func project(input: RealityProjectionInput) -> RealitySnapshot
}

struct RealityModelProjector: RealitySnapshotProjecting {
    func project(input: RealityProjectionInput) -> RealitySnapshot {
        let generatedAt = input.now
        let scheduledWindows = input.scheduledBlocks.map { block in
            RealityWindow(
                id: "window.scheduled.\(block.id)",
                kind: .scheduledAmbitionsBlock,
                source: .ambitionsPlan,
                start: block.start,
                end: block.end,
                title: block.title,
                contextLens: block.contextLens,
                isFlexible: false,
                relatedGoalID: block.relatedGoalID,
                relatedCaptureID: block.relatedCaptureID,
                relatedPlanID: block.relatedPlanID
            )
        }
        let baselineWindows = baselineWindowsIfNeeded(input: input)
        let windows = clipped(
            input.workingWindows +
            input.freeTimeWindows +
            input.protectedWindows +
            input.flexibleWindows +
            scheduledWindows +
            input.calendarBusyWindows +
            baselineWindows,
            to: input.horizon
        )
        let blocking = windows.filter { window in
            [.blockedBusy, .protected, .scheduledAmbitionsBlock, .calendarDerivedBusy].contains(window.kind)
        }
        let openCandidates = makeOpenCandidates(
            horizon: input.horizon,
            blocking: blocking,
            activeContextLens: input.activeContextLens,
            calendarAware: input.calendarContext?.hasCalendarReadAccess == true || input.calendarBusyWindows.isEmpty == false,
            minimumWindowMinutes: input.minimumWindowMinutes,
            nextDeadline: input.deadlineHints.filter { $0 >= input.horizon.start }.min()
        )
        let capacity = makeCapacityEstimate(windows: windows, openCandidates: openCandidates)
        let conflicts = makeConflictSummary(windows: windows)
        let availability = AvailabilitySummary(
            horizonStart: input.horizon.start,
            horizonEnd: input.horizon.end,
            openWindowCount: openCandidates.count,
            blockedWindowCount: windows.filter { $0.kind == .blockedBusy || $0.kind == .calendarDerivedBusy }.count,
            protectedWindowCount: windows.filter { $0.kind == .protected }.count,
            calendarDerivedBusyCount: windows.filter(\.isCalendarDerived).count,
            schedulePressure: capacity.capacityLevel,
            summary: availabilitySummary(openCandidates: openCandidates, capacity: capacity, calendarContext: input.calendarContext)
        )
        let deadlinePressure = makeDeadlinePressure(deadlines: input.deadlineHints, openCandidates: openCandidates, horizon: input.horizon)
        let ledgerIDs = Array(Set(windows.flatMap(\.eventLedgerEntryIDs) + (input.calendarContext?.eventLedgerEntryIDs ?? []))).sorted()
        let explanationIDs = Array(Set(windows.flatMap(\.recommendationExplanationIDs) + (input.calendarContext?.recommendationExplanationIDs ?? []))).sorted()

        return RealitySnapshot(
            id: "reality.\(DomainTimestamp.string(from: generatedAt))",
            generatedAt: generatedAt,
            horizonStart: input.horizon.start,
            horizonEnd: input.horizon.end,
            activeContextLens: input.activeContextLens,
            windows: windows,
            openWindowCandidates: openCandidates,
            availability: availability,
            calendarContext: input.calendarContext,
            conflictSummary: conflicts,
            scheduledBlocks: input.scheduledBlocks,
            capacityEstimate: capacity,
            deadlinePressure: deadlinePressure,
            contextFitSummary: contextFitSummary(activeContextLens: input.activeContextLens, openCandidates: openCandidates),
            eventLedgerEntryIDs: ledgerIDs,
            recommendationExplanationIDs: explanationIDs
        )
    }
}

extension RealityModelProjector {
    func nowPressureSummary(from snapshot: RealitySnapshot) -> NowPressureSummary {
        NowPressureSummary(
            level: snapshot.capacityEstimate.capacityLevel,
            itemCount: snapshot.conflictSummary.conflictCount,
            summary: snapshot.availability.summary,
            evidenceReferenceIDs: snapshot.eventLedgerEntryIDs
        )
    }
}

private extension RealityModelProjector {
    func baselineWindowsIfNeeded(input: RealityProjectionInput) -> [RealityWindow] {
        guard input.workingWindows.isEmpty && input.freeTimeWindows.isEmpty && input.flexibleWindows.isEmpty else {
            return []
        }
        return [
            RealityWindow(
                id: "window.default.flexible.\(DomainTimestamp.string(from: input.horizon.start))",
                kind: .flexible,
                source: .systemDefault,
                start: input.horizon.start,
                end: input.horizon.end,
                title: "Planning horizon",
                contextLens: input.activeContextLens,
                isFlexible: true
            )
        ]
    }

    func clipped(_ windows: [RealityWindow], to horizon: DateInterval) -> [RealityWindow] {
        windows.compactMap { window in
            let start = max(window.start, horizon.start)
            let end = min(window.end, horizon.end)
            guard end > start else { return nil }
            return RealityWindow(
                id: window.id,
                kind: window.kind,
                source: window.source,
                start: start,
                end: end,
                title: window.title,
                contextLens: window.contextLens,
                isFlexible: window.isFlexible,
                isProtected: window.isProtected,
                relatedGoalID: window.relatedGoalID,
                relatedCaptureID: window.relatedCaptureID,
                relatedPlanID: window.relatedPlanID,
                eventLedgerEntryIDs: window.eventLedgerEntryIDs,
                recommendationExplanationIDs: window.recommendationExplanationIDs
            )
        }
    }

    func makeOpenCandidates(
        horizon: DateInterval,
        blocking: [RealityWindow],
        activeContextLens: NowContextLens,
        calendarAware: Bool,
        minimumWindowMinutes: Int,
        nextDeadline: Date?
    ) -> [OpenWindowCandidate] {
        let sorted = blocking.sorted { lhs, rhs in
            if lhs.start == rhs.start { return lhs.end < rhs.end }
            return lhs.start < rhs.start
        }
        var cursor = horizon.start
        var candidates: [OpenWindowCandidate] = []

        for window in sorted {
            if window.end <= cursor { continue }
            if window.start > cursor {
                appendCandidate(
                    start: cursor,
                    end: min(window.start, horizon.end),
                    activeContextLens: activeContextLens,
                    calendarAware: calendarAware,
                    minimumWindowMinutes: minimumWindowMinutes,
                    nextDeadline: nextDeadline,
                    into: &candidates
                )
            }
            cursor = max(cursor, window.end)
            if cursor >= horizon.end { break }
        }

        appendCandidate(
            start: cursor,
            end: horizon.end,
            activeContextLens: activeContextLens,
            calendarAware: calendarAware,
            minimumWindowMinutes: minimumWindowMinutes,
            nextDeadline: nextDeadline,
            into: &candidates
        )
        return candidates
    }

    func appendCandidate(
        start: Date,
        end: Date,
        activeContextLens: NowContextLens,
        calendarAware: Bool,
        minimumWindowMinutes: Int,
        nextDeadline: Date?,
        into candidates: inout [OpenWindowCandidate]
    ) {
        let minutes = Int(end.timeIntervalSince(start) / 60)
        guard minutes >= minimumWindowMinutes else { return }
        let source: RealityWindowSource = calendarAware ? .calendarDerived : .systemDefault
        let deadlineFits = nextDeadline.map { end <= $0 } ?? true
        candidates.append(
            OpenWindowCandidate(
                id: "open.\(candidates.count + 1).\(Int(start.timeIntervalSince1970))",
                start: start,
                end: end,
                contextLens: activeContextLens,
                source: source,
                fitSummary: "\(minutes) minutes open\(calendarAware ? " after calendar-derived busy time" : " in the baseline plan").",
                canFitDeadlineItem: deadlineFits
            )
        )
    }

    func makeCapacityEstimate(windows: [RealityWindow], openCandidates: [OpenWindowCandidate]) -> CapacityEstimate {
        let open = openCandidates.reduce(0) { $0 + $1.durationMinutes }
        let protected = windows.filter { $0.kind == .protected }.reduce(0) { $0 + $1.durationMinutes }
        let busy = windows.filter { $0.kind == .blockedBusy || $0.kind == .calendarDerivedBusy }.reduce(0) { $0 + $1.durationMinutes }
        let flexible = windows.filter { $0.kind == .flexible || $0.kind == .open }.reduce(0) { $0 + $1.durationMinutes }
        let scheduled = windows.filter { $0.kind == .scheduledAmbitionsBlock }.reduce(0) { $0 + $1.durationMinutes }
        let calendarBusy = windows.filter(\.isCalendarDerived).reduce(0) { $0 + $1.durationMinutes }
        let total = max(1, open + protected + busy + scheduled)
        let pressure = Double(busy + scheduled + protected) / Double(total)
        let level: NowPressureLevel
        if pressure >= 0.8 {
            level = .high
        } else if pressure >= 0.6 {
            level = .elevated
        } else if pressure >= 0.4 {
            level = .moderate
        } else if open == 0 {
            level = .critical
        } else {
            level = .low
        }
        return CapacityEstimate(
            totalOpenMinutes: open,
            protectedMinutes: protected,
            blockedMinutes: busy,
            flexibleMinutes: flexible,
            scheduledAmbitionsMinutes: scheduled,
            calendarBusyMinutes: calendarBusy,
            capacityLevel: level,
            summary: open == 0 ? "No open windows are visible in this horizon." : "\(open) minutes remain visible as open planning capacity.",
            localOnly: true,
            privacy: calendarBusy > 0 ? .calendarDerived : .standard
        )
    }

    func makeConflictSummary(windows: [RealityWindow]) -> RealityConflictSummary {
        let blocking = windows.filter { [.blockedBusy, .protected, .scheduledAmbitionsBlock, .calendarDerivedBusy].contains($0.kind) }
            .sorted { $0.start < $1.start }
        var affected: [String] = []
        for index in blocking.indices {
            guard index + 1 < blocking.endIndex else { continue }
            let current = blocking[index]
            let next = blocking[index + 1]
            if current.end > next.start {
                affected.append(contentsOf: [current.id, next.id])
            }
        }
        let uniqueAffected = Array(Set(affected)).sorted()
        return RealityConflictSummary(
            conflictCount: uniqueAffected.isEmpty ? 0 : uniqueAffected.count,
            calendarConflictCount: blocking.filter(\.isCalendarDerived).filter { uniqueAffected.contains($0.id) }.count,
            protectedConflictCount: blocking.filter { $0.kind == .protected && uniqueAffected.contains($0.id) }.count,
            affectedWindowIDs: uniqueAffected,
            summary: uniqueAffected.isEmpty ? "No conflicts are visible in this horizon." : "\(uniqueAffected.count) windows overlap and need a user decision.",
            localOnly: true,
            privacy: blocking.contains(where: \.isCalendarDerived) ? .calendarDerived : .standard
        )
    }

    func makeDeadlinePressure(deadlines: [Date], openCandidates: [OpenWindowCandidate], horizon: DateInterval) -> NowPressureSummary {
        let upcoming = deadlines.filter { $0 >= horizon.start && $0 <= horizon.end }.sorted()
        guard let first = upcoming.first else {
            return NowPressureSummary(level: .none, summary: "No deadline pressure is visible in this horizon.")
        }
        let openBeforeDeadline = openCandidates.filter { $0.end <= first }.reduce(0) { $0 + $1.durationMinutes }
        let level: NowPressureLevel = openBeforeDeadline >= 120 ? .moderate : (openBeforeDeadline > 0 ? .elevated : .high)
        return NowPressureSummary(
            level: level,
            itemCount: upcoming.count,
            summary: openBeforeDeadline > 0
                ? "\(openBeforeDeadline) open minutes are visible before the next deadline."
                : "No open window is visible before the next deadline."
        )
    }

    func availabilitySummary(openCandidates: [OpenWindowCandidate], capacity: CapacityEstimate, calendarContext: CalendarDerivedContext?) -> String {
        if calendarContext?.hasCalendarReadAccess == true {
            return "\(openCandidates.count) open window\(openCandidates.count == 1 ? "" : "s") after calendar-derived busy time."
        }
        return "\(openCandidates.count) baseline open window\(openCandidates.count == 1 ? "" : "s"); Time still works without calendar access."
    }

    func contextFitSummary(activeContextLens: NowContextLens, openCandidates: [OpenWindowCandidate]) -> String {
        guard activeContextLens != .all else {
            return "Open windows can accept any context until the user narrows the lens."
        }
        let matching = openCandidates.filter { $0.contextLens == activeContextLens || $0.contextLens == .all }.count
        return "\(matching) open window\(matching == 1 ? "" : "s") can fit \(activeContextLens.rawValue.replacingOccurrences(of: "_", with: " ")) work."
    }
}
