import AmbitionsDesignSystem
import Foundation

extension AmbitionsDayRailViewState {
    static func compatibility(
        mode: TodayExperienceMode,
        hero: TodayExecutionHeroState,
        todayPlanLayer: TodayPlanLayerState,
        closure: TodayContractEntryState,
        sourceLabel: String
    ) -> AmbitionsDayRailViewState {
        let privacy = DayRailPrivacyProjectionState(
            classification: .standard,
            isSensitiveProjection: false,
            titleReplacement: nil,
            sourceLabel: "Stored on this device"
        )
        let source = DayRailSourceLabelState(id: "source.plan", label: sourceLabel, source: .standard)
        let detailTarget = DayRailDetailTargetState.from(hero.primaryAction)
        let duration = DayRailDurationState.placeholder(for: hero.primaryAction)
        let heroStep = DayRailHeroStepState(
            id: "day-rail.hero.\(hero.primaryAction.id)",
            title: hero.title,
            subtitle: hero.subtitle,
            duration: duration,
            fitLabel: hero.confidenceLabel,
            whySummary: hero.explanation?.summary ?? hero.subtitle,
            sourceQualityLabel: "Source-backed by the current plan",
            becauseLine: "Because \(hero.explanation?.summary ?? hero.subtitle)",
            contextEdge: StartHereContextEdgeState(
                title: "Context edge",
                summary: todayPlanLayer.openWindowLabel,
                sourceLabel: source.label
            ),
            timeFitProof: StartHereTimeFitProofState(
                title: "Time fit",
                summary: duration.label,
                detail: hero.confidenceLabel
            ),
            goalThread: StartHereGoalThreadState(
                title: "Goal thread",
                summary: DayRailHeroStepState.goalThreadSummary(for: detailTarget),
                detail: DayRailHeroStepState.goalThreadDetail(for: detailTarget)
            ),
            receiptItem: DayRailHeroStepState.receiptItem(
                id: "start-here.compat.\(hero.primaryAction.id)",
                title: hero.title,
                sourceLabel: source.label,
                freshness: .fresh,
                privacyLabel: privacy.sourceLabel,
                becauseLine: hero.explanation?.summary ?? hero.subtitle
            ),
            primaryAction: hero.primaryAction,
            secondaryAction: DayRailStepDetailState.placeholderActions(target: hero.primaryAction.target).first,
            detailTarget: detailTarget,
            sourceLabels: [source]
        )
        return AmbitionsDayRailViewState(
            id: "day-rail.compat.\(mode.rawValue)",
            mode: mode == .empty ? .empty : .normal,
            dateTitle: "Today",
            contextSummary: todayPlanLayer.openWindowLabel,
            heroStep: mode == .empty ? nil : heroStep,
            rows: DayRailRowState.rows(from: todayPlanLayer.items, fallbackHero: heroStep, privacy: privacy, source: source),
            primaryAction: mode == .empty ? nil : hero.primaryAction,
            rowTapDetailTargetPlaceholder: mode == .empty ? nil : detailTarget,
            durationSource: duration.source,
            contextLabels: [source],
            privacyProjection: privacy,
            closureSlot: DayRailClosureSlotState(
                title: closure.title,
                subtitle: closure.subtitle,
                reservedForActionClosureSheet: true
            ),
            proofSlot: DayRailProofSlotState(
                title: "Proof saved",
                subtitle: "Start Here keeps the receipt seam visible before anything changes.",
                noSilentChanges: true,
                reservedForReceiptPeek: false
            )
        )
    }
}

extension DayRailDurationState {
    static func placeholder(for action: TodayInlineAction) -> DayRailDurationState {
        switch action.kind {
        case .startStepSession:
            return DayRailDurationState(minutes: 25, source: .suggested, label: "25 min suggested")
        case .complete:
            return DayRailDurationState(minutes: nil, source: .notSet, label: "Duration not set")
        case .openPlan, .protectLater:
            return DayRailDurationState(minutes: nil, source: .acceptedFromPlan, label: "Accepted from plan")
        default:
            return DayRailDurationState(minutes: nil, source: .notSet, label: "Duration not set")
        }
    }
}

extension DayRailDetailTargetState {
    static func from(_ action: TodayInlineAction?) -> DayRailDetailTargetState {
        guard let action else {
            return DayRailDetailTargetState(
                kind: .unavailable,
                goalID: nil,
                stepID: nil,
                draftID: nil,
                placeholderLabel: "Detail opens in a later F-series batch."
            )
        }
        let kind: DayRailDetailTargetKind
        switch action.kind {
        case .quickLog:
            kind = .captureContext
        case .openPlan, .protectLater:
            kind = .planContext
        default:
            kind = action.target.goalID != nil || action.target.stepID != nil || action.target.draftID != nil
                ? .stepDetail
                : .unavailable
        }
        return DayRailDetailTargetState(
            kind: kind,
            goalID: action.target.goalID,
            stepID: action.target.stepID,
            draftID: action.target.draftID,
            placeholderLabel: kind == .stepDetail
                ? "Open Step Detail."
                : "Context route stays in the existing Today flow."
        )
    }
}

extension DayRailPrivacyProjectionState {
    init(classification: EventLedgerPrivacyClassification) {
        switch classification {
        case .sensitive, .privateUserText:
            self.init(
                classification: classification,
                isSensitiveProjection: true,
                titleReplacement: "Private item",
                sourceLabel: "Private source"
            )
        case .calendarDerived:
            self.init(
                classification: classification,
                isSensitiveProjection: false,
                titleReplacement: nil,
                sourceLabel: "Calendar-derived"
            )
        case .standard, .syncMetadata:
            self.init(
                classification: classification,
                isSensitiveProjection: false,
                titleReplacement: nil,
                sourceLabel: "Stored on this device"
            )
        }
    }

    func visibleTitle(_ title: String) -> String {
        titleReplacement ?? title
    }

    func visibleSubtitle(_ subtitle: String) -> String {
        isSensitiveProjection ? "Details stay private on Today." : subtitle.todayShortSentence
    }
}

extension DayRailRowSlot {
    var title: String {
        switch self {
        case .now:
            "Now"
        case .next:
            "Next"
        case .later:
            "Later"
        }
    }
}

extension DayRailPrivacyProjectionState {
    func detailTitle(_ title: String) -> String {
        isSensitiveProjection ? "Private step" : title
    }

    var detailPrivacyLabel: String? {
        isSensitiveProjection ? "Details hidden here" : nil
    }

    func detailContext(_ contextLabel: String) -> String {
        isSensitiveProjection ? "Details hidden here" : contextLabel.todayShortSentence
    }

    func goalLinkLabel(from label: String) -> String {
        isSensitiveProjection
            ? "Goal link hidden here"
            : "Goal link: \(label.todayShortSentence)"
    }

    func sourceSummary(from labels: [DayRailSourceLabelState]) -> String {
        if isSensitiveProjection {
            return sourceLabel
        }
        let publicLabels = labels.map(\.label).filter { $0.isEmpty == false }.prefix(2)
        return publicLabels.isEmpty ? sourceLabel : publicLabels.joined(separator: " · ")
    }

    func whyBullets(primary: String, sourceLabel: String, contextLabel: String, goalSupport: String) -> [String] {
        if isSensitiveProjection {
            return [
                "Details hidden here.",
                "Based on your plan.",
                "You can review or adjust this before starting.",
            ]
        }

        var bullets = [
            primary.todayShortSentence,
            sourceLabel,
            contextLabel.todayShortSentence,
        ]
        if goalSupport.isEmpty == false {
            bullets.append(goalSupport.todayShortSentence)
        }
        return Array(bullets.filter { $0.isEmpty == false }.prefix(4))
    }
}

extension DayRailRowState {
    static func rows(
        from items: [TodayPlanLayerItemState],
        fallbackHero: DayRailHeroStepState?,
        privacy: DayRailPrivacyProjectionState,
        source: DayRailSourceLabelState
    ) -> [DayRailRowState] {
        let slots: [DayRailRowSlot] = [.now, .next, .later]
        let mapped = zip(slots, items.prefix(3)).map { slot, item in
            DayRailRowState(
                id: "day-rail.row.\(slot.rawValue).\(item.id)",
                slot: slot,
                title: privacy.visibleTitle(item.title),
                subtitle: privacy.visibleSubtitle(item.subtitle),
                duration: DayRailDurationState.placeholder(for: item.action ?? fallbackHero?.primaryAction ?? TodayInlineAction(kind: .openPlan, title: "Open Plan", systemImage: "calendar", state: .default, target: TodayActionTarget())),
                detailTarget: DayRailDetailTargetState.from(item.action ?? fallbackHero?.primaryAction),
                sourceLabels: [source]
            )
        }
        if mapped.isEmpty, let fallbackHero {
            return [
                DayRailRowState(
                    id: "day-rail.row.now.\(fallbackHero.id)",
                    slot: .now,
                    title: fallbackHero.title,
                    subtitle: fallbackHero.subtitle,
                    duration: fallbackHero.duration,
                    detailTarget: fallbackHero.detailTarget,
                    sourceLabels: fallbackHero.sourceLabels
                )
            ]
        }
        return Array(mapped)
    }
}

extension DayRailHeroStepState {
    static func goalThreadSummary(for target: DayRailDetailTargetState) -> String {
        if target.goalID != nil || target.stepID != nil {
            return "Connected to the current goal path"
        }
        if target.draftID != nil {
            return "Connected to a draft that needs a place"
        }
        return "One-step path"
    }

    static func goalThreadDetail(for target: DayRailDetailTargetState) -> String {
        switch target.kind {
        case .stepDetail:
            return "Step Detail keeps the path and receipt together."
        case .planContext:
            return "Plan keeps the next capacity choice reviewable."
        case .captureContext:
            return "Capture keeps placement reviewable before anything changes."
        case .unavailable:
            return "No hidden goal change is implied."
        }
    }

    static func receiptItem(
        id: String,
        title: String,
        sourceLabel: String,
        freshness: SourceFreshnessState,
        privacyLabel: String,
        becauseLine: String
    ) -> TrustReceiptLayerItem {
        TrustReceiptLayerItem(
            id: id,
            kind: .needsReview,
            title: "Start Here receipt seam",
            summary: "No change has been made yet.",
            sourceLabel: sourceLabel,
            freshness: freshness,
            privacyLabel: privacyLabel,
            whyLabel: becauseLine.todayShortSentence,
            changeLabel: "Starting opens the current step; closing writes the receipt later.",
            undoLabel: nil,
            correctionLabel: "Review or adjust before changing the plan.",
            reviewLabel: nil,
            redactedDetail: title
        )
    }
}
