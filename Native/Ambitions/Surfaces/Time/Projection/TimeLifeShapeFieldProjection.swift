import AmbitionsDesignSystem
import Foundation

extension TimeLifeSuiteProjector {
    func lifeShapeField(
        shapes: [TimeLifeSuiteShapeState],
        weekDays: [TimeElasticWeekDayState],
        calendarAwareness: TimeCalendarAwarenessState,
        openCaptureCount: Int,
        activeGoalCount: Int,
        placementCandidates: [TimePlacementCandidate] = [],
        mode: TimeSurfaceMode
    ) -> LifeShapeFieldState {
        let day = shapes.first { $0.kind == .day }
        let week = shapes.first { $0.kind == .week }
        let life = shapes.first { $0.kind == .life }
        let pressuredDays = weekDays.filter { [.tight, .fragile, .overloaded].contains($0.level) }.count
        let openDays = weekDays.filter { $0.level == .open }.count
        let protectedBlocks = weekDays.flatMap(\.blocks).filter { $0.kind == .protected || $0.kind == .fixed }.count
        let totalBlocks = weekDays.flatMap(\.blocks).count
        let hasScheduleContext = mode != .empty || calendarAwareness.status == .calendarAware
        let capacityFit: LifeShapeCapacityFit
        if mode == .empty {
            capacityFit = .open
        } else if pressuredDays >= 3 {
            capacityFit = .overloaded
        } else if pressuredDays > 0 || openCaptureCount > 0 {
            capacityFit = .tight
        } else {
            capacityFit = .steady
        }
        let pressureKind = PressureEngine().kind(
            for: Self.pressureOrdinal(
                pressuredDays: pressuredDays,
                openCaptureCount: openCaptureCount,
                activeGoalCount: activeGoalCount,
                protectedBlocks: protectedBlocks
            )
        )

        let sourceTitle = calendarAwareness.canRequestCalendarRead ? "Calendar optional" : "Manual Time source"
        let sourceDetail = calendarAwareness.canRequestCalendarRead
            ? "Calendar can inform availability, but Time does not become an event grid."
            : "Time is shaped from local goals, captures, and manual defaults."
        let weekCapacityStatement = Self.weekCapacityStatement(
            activeGoalCount: activeGoalCount,
            openDays: openDays,
            protectedBlocks: protectedBlocks,
            hasScheduleContext: hasScheduleContext
        )
        let renderState = lifeShapeRenderState(
            capacityFit: capacityFit,
            calendarAwareness: calendarAwareness,
            openCaptureCount: openCaptureCount,
            protectedBlocks: protectedBlocks,
            mode: mode
        )
        let placementCandidate = placementCandidates.first
        let placementUnavailableReason = placementCandidate == nil
            ? "Create or select a Step before placing time."
            : "Placement is available for \(placementCandidate?.title ?? "this Step")."

        return LifeShapeFieldState(
            defaultHorizon: .week,
            capacityFit: capacityFit,
            segments: [
                LifeShapeSegment(
                    kind: .openTime,
                    detail: placementCandidate == nil
                        ? (hasScheduleContext
                            ? "Open windows stay visible; no Step is selected for placement."
                            : "Open windows need local schedule context before Time can place work.")
                        : "Open windows can place \(placementCandidate?.title ?? "the selected Step").",
                    valueLabel: hasScheduleContext ? (openDays == 1 ? "1 open day" : "\(openDays) open days") : "Low context",
                    weight: hasScheduleContext && weekDays.isEmpty == false ? Double(openDays) / Double(weekDays.count) : 0,
                    visualState: hasScheduleContext && openDays > 0 ? .selected : .default
                ),
                LifeShapeSegment(
                    kind: .goalTime,
                    detail: activeGoalCount == 0 ? "No active goal is asking for Time yet." : "\(activeGoalCount) active goal\(activeGoalCount == 1 ? "" : "s") shape this field.",
                    valueLabel: activeGoalCount == 1 ? "1 goal" : "\(activeGoalCount) goals",
                    weight: min(Double(activeGoalCount) / 5.0, 1),
                    visualState: activeGoalCount == 0 ? .default : .selected
                ),
                LifeShapeSegment(
                    kind: .protectedTime,
                    detail: protectedBlocks == 0 ? "No protected time is marked yet." : "\(protectedBlocks) fixed or protected block\(protectedBlocks == 1 ? "" : "s") stay visible.",
                    valueLabel: protectedBlocks == 1 ? "1 protected" : "\(protectedBlocks) protected",
                    weight: totalBlocks == 0 ? 0 : Double(protectedBlocks) / Double(totalBlocks),
                    visualState: protectedBlocks > 0 ? .selected : .default
                ),
                LifeShapeSegment(
                    kind: .pressure,
                    detail: Self.pressureDetail(kind: pressureKind, pressuredDays: pressuredDays),
                    valueLabel: pressureKind.title,
                    weight: capacityFit == .overloaded ? 0.92 : (capacityFit == .tight ? 0.72 : 0.38),
                    visualState: capacityFit.visualState
                ),
                LifeShapeSegment(
                    kind: .recovery,
                    detail: pressuredDays == 0 ? "Recovery stays available as margin." : "Lighten the loudest pressure before widening the week.",
                    valueLabel: "Recovery",
                    weight: pressuredDays == 0 ? 0.28 : 0.60,
                    visualState: pressuredDays == 0 ? .default : .warning
                ),
                LifeShapeSegment(
                    kind: .source,
                    detail: sourceDetail,
                    valueLabel: "Local",
                    weight: 0.34,
                    visualState: .selected
                )
            ],
            semanticMarks: semanticMarks(
                weekDays: weekDays,
                calendarAwareness: calendarAwareness,
                openCaptureCount: openCaptureCount,
                activeGoalCount: activeGoalCount,
                pressuredDays: pressuredDays,
                openDays: openDays,
                protectedBlocks: protectedBlocks,
                capacityFit: capacityFit,
                renderState: renderState
            ),
            renderState: renderState,
            readings: [
                .day: LifeShapeReading(
                    horizon: .day,
                    title: "Day shape",
                    summary: day?.summary ?? "Manual shaping is available for today.",
                    capacityStatement: day?.capacityLabel ?? "Capacity: qualitative only.",
                    sourceDetail: day?.provenanceLabel ?? sourceDetail
                ),
                .week: LifeShapeReading(
                    horizon: .week,
                    title: "Week fit",
                    summary: week?.summary ?? "The week has room until local goals or captures change it.",
                    capacityStatement: weekCapacityStatement,
                    sourceDetail: week?.provenanceLabel ?? sourceDetail
                ),
                .month: LifeShapeReading(
                    horizon: .month,
                    title: "Month shape",
                    summary: life?.summary ?? "The longer Time arc is quiet until active goals shape it.",
                    capacityStatement: life?.capacityLabel ?? "Capacity: qualitative only.",
                    sourceDetail: life?.provenanceLabel ?? sourceDetail
                ),
                .year: LifeShapeReading(
                    horizon: .year,
                    title: "Year shape",
                    summary: life?.summary ?? "The year stays directional until active goals shape it.",
                    capacityStatement: life?.capacityLabel ?? "Capacity: qualitative only.",
                    sourceDetail: life?.provenanceLabel ?? sourceDetail
                )
            ],
            placementCandidate: placementCandidate,
            placementUnavailableReason: placementUnavailableReason,
            calendarRows: Self.calendarRows(
                weekDays: weekDays,
                readings: [
                    .day: day,
                    .week: week,
                    .month: life,
                    .year: life
                ],
                capacityFit: capacityFit,
                pressureKind: pressureKind,
                openDays: openDays,
                protectedBlocks: protectedBlocks,
                activeGoalCount: activeGoalCount,
                placementCandidate: placementCandidate,
                hasScheduleContext: hasScheduleContext
            ),
            sourceState: LifeShapeSourceState(
                title: sourceTitle,
                detail: sourceDetail,
                whyThisLabel: "Why this? Based on local goals, captures, protected time, pressure, and user choice.",
                privacyLabel: calendarAwareness.canRequestCalendarRead
                    ? "Calendar access stays optional and local."
                    : "No external calendar source is required.",
                visualState: calendarAwareness.canRequestCalendarRead ? .selected : .default
            ),
            reflowProposal: LifeShapeReflowProposal(
                title: capacityFit == .tight || capacityFit == .overloaded ? "Review pressure before adding more" : "Keep the week fit around what matters",
                detail: openCaptureCount == 0
                    ? "No unplaced capture is forcing a Time change."
                    : "\(openCaptureCount) capture\(openCaptureCount == 1 ? "" : "s") need placement before Time changes.",
                actionTitle: "Review shape",
                visualState: capacityFit.visualState
            ),
            receipt: LifeShapeReceipt(
                title: "No silent calendar changes",
                detail: "Time changes require confirmation and leave a receipt.",
                ageLabel: "Current",
                visualState: .selected
            ),
            continuityDockItems: ["Open field", "Protect time", "Review change"]
        )
    }

    static func countLabel(_ count: Int, singular: String, plural: String) -> String {
        "\(count) \(count == 1 ? singular : plural)"
    }

    static func calendarRows(
        weekDays: [TimeElasticWeekDayState],
        readings: [TimeHorizon: TimeLifeSuiteShapeState?],
        capacityFit: LifeShapeCapacityFit,
        pressureKind: PressureKind,
        openDays: Int,
        protectedBlocks: Int,
        activeGoalCount: Int,
        placementCandidate: TimePlacementCandidate?,
        hasScheduleContext: Bool
    ) -> [TimeCalendarRow] {
        let dayShape = readings[.day] ?? nil
        let weekShape = readings[.week] ?? nil
        let monthShape = readings[.month] ?? nil
        let fixedLabel = protectedBlocks == 0 ? "None marked" : countLabel(protectedBlocks, singular: "anchor", plural: "anchors")
        let openLabel = hasScheduleContext ? (openDays == 1 ? "1 open day" : "\(openDays) open days") : "Low context"
        let placementDetail = placementCandidate.map { "Placement candidate: \($0.title)." } ?? "Placement waits for a real Step."
        let scheduledBlock = weekDays
            .flatMap(\.blocks)
            .first { block in
                block.timingLabel.localizedCaseInsensitiveContains("Scheduled")
            }
        return [
            TimeCalendarRow(
                id: "time.calendar.now",
                kind: .now,
                title: "Now",
                value: dayShape?.title ?? "Today",
                detail: dayShape?.summary ?? "Current day stays first.",
                visualState: .selected,
                isOperational: true
            ),
            TimeCalendarRow(
                id: "time.calendar.fixed-point",
                kind: .fixedPoint,
                title: "Next fixed point",
                value: fixedLabel,
                detail: protectedBlocks == 0 ? "No fixed point is loaded locally." : "Fixed and protected anchors are visible before placement.",
                visualState: protectedBlocks == 0 ? .default : .selected,
                isOperational: protectedBlocks > 0
            ),
            TimeCalendarRow(
                id: "time.calendar.open-window",
                kind: .openWindow,
                title: "Open windows",
                value: openLabel,
                detail: hasScheduleContext ? placementDetail : "Open windows need local Steps, protected time, or calendar context before placement.",
                visualState: hasScheduleContext && openDays > 0 ? .selected : .default,
                isOperational: hasScheduleContext && openDays > 0 && placementCandidate != nil
            ),
            TimeCalendarRow(
                id: "time.calendar.scheduled-step",
                kind: .scheduledStep,
                title: "Scheduled Step",
                value: scheduledBlock?.timingLabel ?? "None",
                detail: scheduledBlock.map { "\($0.title). \($0.detail)" } ?? "Local Steps appear here only after a real Step is scheduled.",
                visualState: scheduledBlock == nil ? .default : .selected,
                isOperational: scheduledBlock != nil
            ),
            TimeCalendarRow(
                id: "time.calendar.protected-window",
                kind: .protectedWindow,
                title: "Protected windows",
                value: protectedBlocks == 0 ? "None" : "\(protectedBlocks)",
                detail: protectedBlocks == 0 ? "Protection can be added from an explicit Time action." : "Protected windows block fake placement.",
                visualState: protectedBlocks == 0 ? .default : .selected,
                isOperational: true
            ),
            TimeCalendarRow(
                id: "time.calendar.pressure",
                kind: .pressure,
                title: "Pressure",
                value: pressureKind.title,
                detail: capacityFit.title,
                visualState: capacityFit.visualState,
                isOperational: true
            ),
            TimeCalendarRow(
                id: "time.calendar.buffer",
                kind: .buffer,
                title: "Buffer",
                value: capacityFit == .tight || capacityFit == .overloaded ? "Review" : "Room",
                detail: "Transition room stays visible before broad reflow.",
                visualState: capacityFit.visualState,
                isOperational: true
            ),
            TimeCalendarRow(
                id: "time.calendar.recovery",
                kind: .recovery,
                title: "Recovery",
                value: capacityFit == .open ? "Open" : "Guarded",
                detail: "Recovery remains a labeled capacity signal.",
                visualState: capacityFit == .open ? .selected : .default,
                isOperational: true
            ),
            TimeCalendarRow(
                id: "time.calendar.goal-load",
                kind: .goalLoad,
                title: "Goal load",
                value: activeGoalCount == 1 ? "1 goal" : "\(activeGoalCount) goals",
                detail: activeGoalCount == 0 ? "No active goal is asking for Time." : "Goal-linked Steps can become placement candidates.",
                visualState: activeGoalCount == 0 ? .default : .selected,
                isOperational: activeGoalCount > 0
            ),
            TimeCalendarRow(
                id: "time.calendar.day",
                kind: .day,
                title: "Day",
                value: dayShape?.capacityLabel ?? "Current",
                detail: dayShape?.summary ?? "Day view is available.",
                visualState: .selected,
                isOperational: true
            ),
            TimeCalendarRow(
                id: "time.calendar.week",
                kind: .week,
                title: "Week",
                value: weekShape?.capacityLabel ?? "Current",
                detail: weekShape?.summary ?? "Week view is available.",
                visualState: .selected,
                isOperational: true
            ),
            TimeCalendarRow(
                id: "time.calendar.month",
                kind: .month,
                title: "Month",
                value: monthShape?.capacityLabel ?? "Staged",
                detail: monthShape?.summary ?? "Month remains directional from local state.",
                visualState: .default,
                isOperational: monthShape != nil
            ),
            TimeCalendarRow(
                id: "time.calendar.year",
                kind: .year,
                title: "Year",
                value: monthShape?.capacityLabel ?? "Staged",
                detail: monthShape?.summary ?? "Year remains directional from local state.",
                visualState: .default,
                isOperational: monthShape != nil
            ),
            TimeCalendarRow(
                id: "time.calendar.list",
                kind: .list,
                title: "List",
                value: "Accessible",
                detail: "Rows expose the same Time signals for VoiceOver and large text.",
                visualState: .selected,
                isOperational: true
            )
        ]
    }

    static func weekCapacityStatement(
        activeGoalCount: Int,
        openDays: Int,
        protectedBlocks: Int,
        hasScheduleContext: Bool = true
    ) -> String {
        guard hasScheduleContext else {
            return "Capacity remains qualitative until local schedule context exists."
        }

        var parts: [String] = []
        if activeGoalCount > 0 {
            parts.append(countLabel(activeGoalCount, singular: "active goal", plural: "active goals"))
        }
        if openDays > 0 {
            parts.append(openDays == 1 ? "one day still has room" : "\(openDays) days still have room")
        }
        if protectedBlocks > 0 {
            parts.append(countLabel(protectedBlocks, singular: "protected block", plural: "protected blocks"))
        }

        guard parts.isEmpty == false else {
            return "This week is still taking shape from local context."
        }

        if activeGoalCount == 0 && protectedBlocks == 0 && openDays >= 5 {
            return "This week is still mostly open."
        }

        return parts.joined(separator: ", ").sentenceCasedWithPeriod
    }

    static func pressureOrdinal(
        pressuredDays: Int,
        openCaptureCount: Int,
        activeGoalCount: Int,
        protectedBlocks: Int
    ) -> Int {
        var ordinal = pressuredDays >= 3 ? 3 : pressuredDays
        if openCaptureCount > 0 { ordinal += 1 }
        if activeGoalCount >= 4 { ordinal += 1 }
        if protectedBlocks > 0 && pressuredDays > 0 { ordinal += 1 }
        return ordinal
    }

    static func pressureDetail(kind: PressureKind, pressuredDays: Int) -> String {
        switch kind {
        case .light:
            "Capacity has room before another Step is added."
        case .crowded:
            "One part of the week is close enough to review first."
        case .tight:
            pressuredDays == 0
                ? "Pressure is present qualitatively; no pressured day is claimed yet."
                : "\(pressuredDays) day\(pressuredDays == 1 ? "" : "s") should stay narrow before adding more."
        case .needsBuffer:
            "Shorten one ask or protect one window before adding more."
        }
    }

}

private extension String {
    var sentenceCasedWithPeriod: String {
        guard let first else { return self }
        let sentence = String(first).uppercased() + dropFirst()
        return sentence.hasSuffix(".") ? sentence : "\(sentence)."
    }
}
