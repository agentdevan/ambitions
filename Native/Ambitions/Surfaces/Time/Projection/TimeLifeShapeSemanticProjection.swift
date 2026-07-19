import AmbitionsDesignSystem
import Foundation

extension TimeLifeSuiteProjector {
    func lifeShapeRenderState(
        capacityFit: LifeShapeCapacityFit,
        calendarAwareness: TimeCalendarAwarenessState,
        openCaptureCount: Int,
        protectedBlocks: Int,
        mode: TimeSurfaceMode
    ) -> LifeShapeRenderState {
        if calendarAwareness.status == .denied {
            return .calendarDenied
        }
        if calendarAwareness.canRequestCalendarRead == false {
            return .manualOnly
        }
        if capacityFit == .overloaded || capacityFit == .tight {
            return .pressureCluster
        }
        if openCaptureCount > 0 && protectedBlocks == 0 {
            return .sourceConflict
        }
        if openCaptureCount > 0 {
            return .reflowPreview
        }
        if mode != .empty {
            return .receiptAttached
        }
        return .defaultWeek
    }

    func semanticMarks(
        weekDays: [TimeElasticWeekDayState],
        calendarAwareness: TimeCalendarAwarenessState,
        openCaptureCount: Int,
        activeGoalCount: Int,
        pressuredDays: Int,
        openDays: Int,
        protectedBlocks: Int,
        capacityFit: LifeShapeCapacityFit,
        renderState: LifeShapeRenderState
    ) -> [LifeShapeSemanticMark] {
        let dayCount = weekDays.isEmpty ? 1 : weekDays.count
        let pressureIntensity = max(Double(pressuredDays) / Double(dayCount), capacityFit == .tight ? 0.64 : 0.20)
        let transitionFriction = min(max(Double(pressuredDays - openDays) / Double(dayCount), 0), 1)
        let goalLoad = min(Double(activeGoalCount) / 5.0, 1)
        let recoveryNeed = max(pressureIntensity, transitionFriction)
        let freeTimeQuality = min(Double(openDays) / Double(dayCount), 1)
        let executionLaneIntensity = max(freeTimeQuality, openCaptureCount > 0 ? 0.42 : 0.30)
        let blockCount = weekDays.flatMap(\.blocks).count
        let protectedIntensity = blockCount == 0 ? 0 : min(Double(protectedBlocks) / Double(blockCount), 1)
        let sourceConflictActive = renderState == .sourceConflict || calendarAwareness.status == .denied
        let receiptActive = renderState == .receiptAttached || renderState == .reflowPreview
        let pressureKind = PressureEngine().kind(
            for: Self.pressureOrdinal(
                pressuredDays: pressuredDays,
                openCaptureCount: openCaptureCount,
                activeGoalCount: activeGoalCount,
                protectedBlocks: protectedBlocks
            )
        )
        let weekInput = LifeShapeInputRef(
            id: "time.week-days.\(weekDays.count)",
            kind: .fixedPoint,
            label: "Elastic week day shape"
        )
        let calendarInput = LifeShapeInputRef(
            id: "time.calendar-awareness.\(calendarAwareness.status.rawValue)",
            kind: .protectedBoundary,
            label: calendarAwareness.title
        )
        let captureInput = LifeShapeInputRef(
            id: "time.open-captures.\(openCaptureCount)",
            kind: .capture,
            label: "\(openCaptureCount) open captures"
        )
        let goalInput = LifeShapeInputRef(
            id: "time.active-goals.\(activeGoalCount)",
            kind: .goal,
            label: "\(activeGoalCount) active goals"
        )
        let protectedInput = LifeShapeInputRef(
            id: "time.protected-blocks.\(protectedBlocks)",
            kind: .protectedBoundary,
            label: "\(protectedBlocks) protected blocks"
        )

        func makeMark(
            kind: LifeShapeSemanticMarkKind,
            valueLabel: String,
            detail: String,
            intensity: Double,
            visualState: AmbitionVisualState,
            inputRefs: [LifeShapeInputRef]
        ) -> LifeShapeSemanticMark {
            LifeShapeSemanticMark(
                kind: kind,
                valueLabel: valueLabel,
                detail: detail,
                intensity: intensity,
                visualState: visualState,
                inputRefs: inputRefs,
                ruleIDs: [LifeShapeRuleID(rawValue: "lifeshape.semantic.\(kind.rawValue)")],
                accessibilitySummary: "\(kind.title). \(valueLabel). \(detail)"
            )
        }

        var marks = [
            makeMark(kind: .pressure, valueLabel: pressureKind.title, detail: Self.pressureDetail(kind: pressureKind, pressuredDays: pressuredDays), intensity: pressureIntensity, visualState: capacityFit.visualState, inputRefs: [weekInput, calendarInput]),
            makeMark(kind: .cognitiveLoad, valueLabel: pressuredDays == 0 ? "Light" : "Review", detail: "Cognitive load follows pressured days and remains qualitative.", intensity: pressureIntensity * 0.78, visualState: pressuredDays == 0 ? .default : .warning, inputRefs: [weekInput]),
            makeMark(kind: .physicalEnergy, valueLabel: recoveryNeed > 0.55 ? "Reserve" : "Steady", detail: "Energy shows whether recovery should be kept available.", intensity: recoveryNeed * 0.62, visualState: recoveryNeed > 0.55 ? .warning : .default, inputRefs: [weekInput]),
            makeMark(kind: .transitionFriction, valueLabel: transitionFriction > 0.35 ? "Review" : "Smooth", detail: "Transition friction rises when pressure exceeds open time.", intensity: transitionFriction, visualState: transitionFriction > 0.35 ? .warning : .default, inputRefs: [weekInput]),
            makeMark(kind: .protectedTime, valueLabel: protectedBlocks == 0 ? "None" : "\(protectedBlocks) held", detail: "Protected time stays visible before Time changes.", intensity: protectedIntensity, visualState: protectedBlocks == 0 ? .default : .selected, inputRefs: [protectedInput, calendarInput]),
            makeMark(kind: .recoveryNeed, valueLabel: recoveryNeed > 0.55 ? "Needed" : "Reserve", detail: "Recovery need keeps room available without blame.", intensity: recoveryNeed, visualState: recoveryNeed > 0.55 ? .warning : .default, inputRefs: [weekInput]),
            makeMark(kind: .freeTimeQuality, valueLabel: openDays == 0 ? "Thin" : "\(openDays) open", detail: openDays == 0 ? "No clear opening is claimed yet." : "Use the clearest opening before adding more.", intensity: freeTimeQuality, visualState: openDays == 0 ? .warning : .selected, inputRefs: [weekInput]),
            makeMark(kind: .executionLanes, valueLabel: openDays == 0 ? "Review" : "Open", detail: "Open time shows where action can fit.", intensity: executionLaneIntensity, visualState: openDays == 0 ? .warning : .selected, inputRefs: [weekInput, captureInput]),
            makeMark(kind: .goalLoad, valueLabel: activeGoalCount == 0 ? "No anchors" : "\(activeGoalCount) anchors", detail: "Goal load follows active goals.", intensity: goalLoad, visualState: activeGoalCount == 0 ? .default : .selected, inputRefs: [goalInput])
        ]

        marks.append(
            makeMark(kind: .sourceConflict, valueLabel: sourceConflictActive ? "Review" : "Clear", detail: "Source conflict asks for review before Time changes.", intensity: sourceConflictActive ? 0.82 : 0.18, visualState: sourceConflictActive ? .warning : .default, inputRefs: [calendarInput, captureInput])
        )
        marks.append(
            makeMark(kind: .receiptReflow, valueLabel: receiptActive ? "Attached" : "Ready", detail: "Review stays attached to changed Time.", intensity: receiptActive ? 0.70 : 0.24, visualState: receiptActive ? .selected : .default, inputRefs: [weekInput, captureInput, goalInput])
        )
        return marks
    }

}
