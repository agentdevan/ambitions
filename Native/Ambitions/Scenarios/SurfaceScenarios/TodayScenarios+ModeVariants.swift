import AmbitionsDesignSystem
import Foundation

extension PreviewTodayScenarios {
    static func makeModeScenario(
        from experience: TodayExperience,
        mode: DayRailMode,
        pressureLabel: String,
        pressureDetail: String
    ) -> TodayExperience {
        var pressure = pressureLabel
        if pressureLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            pressure = basePressureLabel(from: experience.execution.dayRail.mode, fallbackFrom: mode)
        }
        let detail = pressureDetail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? detailFor(mode: mode, pressureLabel: pressure)
            : pressureDetail

        let baseRail = experience.execution.dayRail
        let continuity = DayRailContinuityState.make(
            heroStep: baseRail.heroStep,
            rows: baseRail.rows,
            closureSlot: baseRail.closureSlot,
            proofSlot: baseRail.proofSlot,
            mode: mode,
            pressureLabel: pressure
        )
        let rail = AmbitionsDayRailViewState(
            id: "\(baseRail.id).mode-\(mode.rawValue)",
            mode: mode,
            dateTitle: baseRail.dateTitle,
            contextSummary: detail,
            heroStep: baseRail.heroStep,
            rows: baseRail.rows,
            primaryAction: baseRail.primaryAction,
            rowTapDetailTargetPlaceholder: baseRail.rowTapDetailTargetPlaceholder,
            durationSource: baseRail.durationSource,
            contextLabels: baseRail.contextLabels,
            privacyProjection: baseRail.privacyProjection,
            continuity: continuity,
            closureSlot: baseRail.closureSlot,
            proofSlot: baseRail.proofSlot
        )

        return TodayExperience(
            mode: experience.mode,
            hero: experience.hero,
            support: experience.support,
            execution: experience.execution.replacingDayRail(rail)
        )
    }

    static func makeLongReflowScenario(
        from experience: TodayExperience,
        title: String,
        subtitle: String,
        nextTitle: String,
        nextSubtitle: String
    ) -> TodayExperience {
        let reflowSupportScenario = makeScenario(
            posture: .stable,
            title: "Reflow target",
            supporting: "A long text path should reflow instead of truncating core proof and continuity meaning.",
            nowSubtitle: subtitle,
            nextTitle: nextTitle,
            nextSubtitle: nextSubtitle,
            primaryAction: experience.execution.dayRail.heroStep?.primaryAction ?? TodayInlineAction(
                kind: .complete,
                title: "Complete",
                systemImage: "checkmark",
                state: .success,
                target: TodayActionTarget(goalID: "goal-1", stepID: "step-1")
            ),
            supportingActions: [],
            reentry: nil,
            celebrationLine: nil
        )

        let baseRail = reflowSupportScenario.execution.dayRail
        guard let baseHero = baseRail.heroStep else { return reflowSupportScenario }
        let reflowHero = DayRailHeroStepState(
            id: "\(baseRail.id).reflow.hero",
            title: title,
            subtitle: subtitle,
            duration: baseHero.duration,
            fitLabel: baseHero.fitLabel,
            whySummary: subtitle,
            sourceQualityLabel: baseHero.sourceQualityLabel,
            becauseLine: subtitle,
            receiptLabel: baseHero.receiptLabel,
            proofLabel: baseHero.proofLabel,
            sourceRecordLabel: baseHero.sourceRecordLabel,
            replayTraceLabel: baseHero.replayTraceLabel,
            replayInspectionLabel: baseHero.replayInspectionLabel,
            contextEdge: baseHero.contextEdge,
            timeFitProof: baseHero.timeFitProof,
            goalThread: baseHero.goalThread,
            receiptItem: baseHero.receiptItem,
            primaryAction: baseHero.primaryAction,
            secondaryAction: baseHero.secondaryAction,
            detailTarget: baseHero.detailTarget,
            sourceLabels: baseHero.sourceLabels
        )
        let reflowRows = baseRail.rows.map { row in
            let detail = [row.detailTarget.placeholderLabel, row.title].first { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                ?? "Reflow-safe continuity"
            return DayRailRowState(
                id: "\(row.id).reflow",
                slot: row.slot,
                title: "\(row.title) · reflow target",
                subtitle: "\(row.subtitle). \(detail)",
                duration: row.duration,
                detailTarget: row.detailTarget,
                sourceLabels: row.sourceLabels
            )
        }
        let rail = AmbitionsDayRailViewState(
            id: "\(baseRail.id).reflow",
            mode: baseRail.mode,
            dateTitle: baseRail.dateTitle,
            contextSummary: baseRail.contextSummary,
            heroStep: reflowHero,
            rows: reflowRows,
            primaryAction: baseRail.primaryAction,
            rowTapDetailTargetPlaceholder: baseRail.rowTapDetailTargetPlaceholder,
            durationSource: baseRail.durationSource,
            contextLabels: baseRail.contextLabels,
            privacyProjection: baseRail.privacyProjection,
            continuity: DayRailContinuityState.make(
                heroStep: reflowHero,
                rows: reflowRows,
                closureSlot: baseRail.closureSlot,
                proofSlot: baseRail.proofSlot,
                mode: baseRail.mode,
                pressureLabel: baseRail.continuity.pressureLabel
            ),
            closureSlot: baseRail.closureSlot,
            proofSlot: baseRail.proofSlot
        )
        return TodayExperience(
            mode: experience.mode,
            hero: reflowSupportScenario.hero,
            support: reflowSupportScenario.support,
            execution: reflowSupportScenario.execution.replacingDayRail(rail)
        )
    }

    static func basePressureLabel(from currentMode: DayRailMode, fallbackFrom fallback: DayRailMode) -> String {
        switch fallback {
        case .normal:
            return currentMode == .normal ? "Ready" : "Recalibrated"
        case .recovery:
            return "Recovery active"
        case .protected:
            return "Protected now"
        case .overloaded:
            return "Needs trim"
        case .empty:
            return "Open"
        case .noSchedule:
            return "No schedule connected"
        }
    }

    static func detailFor(mode: DayRailMode, pressureLabel: String) -> String {
        switch mode {
        case .normal:
            return pressureLabel
        case .recovery:
            return "Recovery remains visible without opening a wider plan."
        case .protected:
            return "Protected segments stay visible and prioritized."
        case .overloaded:
            return "Pressure stays visible while the active node stays small."
        case .empty:
            return "No active recommendation."
        case .noSchedule:
            return "No schedule connected; Today stays anchored to active recommendation."
        }
    }
}
