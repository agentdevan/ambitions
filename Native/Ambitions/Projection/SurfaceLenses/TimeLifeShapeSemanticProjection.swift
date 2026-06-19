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
        let dayCount = max(weekDays.count, 1)
        let pressureIntensity = max(Double(pressuredDays) / Double(dayCount), capacityFit == .tight ? 0.64 : 0.20)
        let transitionFriction = min(max(Double(pressuredDays - openDays) / Double(dayCount), 0), 1)
        let goalLoad = min(Double(activeGoalCount) / 5.0, 1)
        let recoveryNeed = max(pressureIntensity, transitionFriction)
        let freeTimeQuality = min(Double(openDays) / Double(dayCount), 1)
        let executionLaneIntensity = max(freeTimeQuality, openCaptureCount > 0 ? 0.42 : 0.30)
        let protectedIntensity = min(Double(protectedBlocks) / Double(max(weekDays.flatMap(\.blocks).count, 1)), 1)
        let sourceConflictActive = renderState == .sourceConflict || calendarAwareness.status == .denied
        let receiptActive = renderState == .receiptAttached || renderState == .reflowPreview

        var marks = [
            LifeShapeSemanticMark(kind: .pressure, valueLabel: capacityFit.title, detail: "Pressure is a compression ridge with inspectable meaning.", intensity: pressureIntensity, visualState: capacityFit.visualState),
            LifeShapeSemanticMark(kind: .cognitiveLoad, valueLabel: pressuredDays == 0 ? "Light" : "Review", detail: "Cognitive load follows pressured days and remains text-labeled.", intensity: pressureIntensity * 0.78, visualState: pressuredDays == 0 ? .default : .warning),
            LifeShapeSemanticMark(kind: .physicalEnergy, valueLabel: recoveryNeed > 0.55 ? "Reserve" : "Steady", detail: "Physical energy appears as a reserve basin when recovery is needed.", intensity: recoveryNeed * 0.62, visualState: recoveryNeed > 0.55 ? .warning : .default),
            LifeShapeSemanticMark(kind: .transitionFriction, valueLabel: transitionFriction > 0.35 ? "Narrow" : "Smooth", detail: "Transition friction is a narrowed bridge when pressure exceeds open lanes.", intensity: transitionFriction, visualState: transitionFriction > 0.35 ? .warning : .default),
            LifeShapeSemanticMark(kind: .protectedTime, valueLabel: protectedBlocks == 0 ? "None" : "\(protectedBlocks) held", detail: "Protected time is a preserved boundary/pocket.", intensity: protectedIntensity, visualState: protectedBlocks == 0 ? .default : .selected),
            LifeShapeSemanticMark(kind: .recoveryNeed, valueLabel: recoveryNeed > 0.55 ? "Needed" : "Reserve", detail: "Recovery need is a reserve pocket, never a failure.", intensity: recoveryNeed, visualState: recoveryNeed > 0.55 ? .warning : .default),
            LifeShapeSemanticMark(kind: .freeTimeQuality, valueLabel: openDays == 0 ? "Thin" : "\(openDays) open", detail: "Free-time quality is an available lane/basin.", intensity: freeTimeQuality, visualState: openDays == 0 ? .warning : .selected),
            LifeShapeSemanticMark(kind: .executionLanes, valueLabel: openDays == 0 ? "Review" : "Open", detail: "Execution lanes show where action can fit.", intensity: executionLaneIntensity, visualState: openDays == 0 ? .warning : .selected),
            LifeShapeSemanticMark(kind: .goalLoad, valueLabel: activeGoalCount == 0 ? "No anchors" : "\(activeGoalCount) anchors", detail: "Goal load is an anchored lane.", intensity: goalLoad, visualState: activeGoalCount == 0 ? .default : .selected)
        ]

        marks.append(
            LifeShapeSemanticMark(kind: .sourceConflict, valueLabel: sourceConflictActive ? "Split trace" : "Clear", detail: "Source conflict uses a split trace/unresolved overlap.", intensity: sourceConflictActive ? 0.82 : 0.18, visualState: sourceConflictActive ? .warning : .default)
        )
        marks.append(
            LifeShapeSemanticMark(kind: .receiptReflow, valueLabel: receiptActive ? "Attached" : "Ready", detail: "Receipt/review appears as a proof mark attached to changed regions.", intensity: receiptActive ? 0.70 : 0.24, visualState: receiptActive ? .selected : .default)
        )
        return marks
    }

}
