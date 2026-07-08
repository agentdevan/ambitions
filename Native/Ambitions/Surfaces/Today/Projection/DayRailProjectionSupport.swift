import AmbitionsDesignSystem
import Foundation

extension DayRailDurationState {
    static func placeholder(for action: TodayInlineAction) -> DayRailDurationState {
        switch action.kind {
        case .startStepSession:
            return DayRailDurationState(minutes: 25, source: .suggested, label: "25 min suggested")
        case .complete:
            return DayRailDurationState(minutes: nil, source: .notSet, label: "Duration not set")
        case .openTime, .protectLater:
            return DayRailDurationState(minutes: nil, source: .acceptedFromPlan, label: "Accepted from Time")
        default:
            return DayRailDurationState(minutes: nil, source: .notSet, label: "Duration not set")
        }
    }
}

extension DayRailHeroStepState {
    static func sourceRecordLabel(for sourceLabels: [DayRailSourceLabelState]) -> String {
        sourceLabels.isEmpty ? "Source record unavailable" : "Source record stays local"
    }

    static func replayTraceLabel(localOnly: Bool) -> String {
        localOnly ? "Review path stays inspectable" : "Review path needs proof"
    }

    static func replayInspectionLabel(sourceRecordLabel: String, replayTraceLabel: String) -> String {
        "\(sourceRecordLabel). \(replayTraceLabel)."
    }

    static func goalThreadSummary(for target: DayRailDetailTargetState) -> String {
        if target.goalID != nil || target.stepID != nil {
            return "Connected to the current goal path"
        }
        if target.draftID != nil {
            return "Connected to a capture draft under review"
        }
        return "One-step path"
    }

    static func goalThreadDetail(for target: DayRailDetailTargetState) -> String {
        switch target.kind {
        case .stepDetail:
            return "Step Detail keeps the path and review history together."
        case .planContext:
            return "Time keeps the next capacity choice reviewable."
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
            title: "Start here review history",
            summary: "No change has been made yet.",
            sourceLabel: sourceLabel,
            freshness: freshness,
            privacyLabel: privacyLabel,
            whyLabel: becauseLine.todayShortSentence,
            changeLabel: "Starting opens the current step; closing keeps review history visible.",
            undoLabel: nil,
            correctionLabel: "Review or adjust before changing the plan.",
            reviewLabel: nil,
            redactedDetail: title
        )
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
                placeholderLabel: "Detail opens when the focused step surface is available."
            )
        }
        let kind: DayRailDetailTargetKind
        switch action.kind {
        case .quickLog:
            kind = .captureContext
        case .openTime, .protectLater:
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

extension DayRailRowState {
    static func rows(
        from items: [TodayTimeLayerItemState],
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
                duration: DayRailDurationState.placeholder(for: item.action ?? fallbackHero?.primaryAction ?? TodayInlineAction(kind: .openTime, title: "Open Time", systemImage: "calendar", state: .default, target: TodayActionTarget())),
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
