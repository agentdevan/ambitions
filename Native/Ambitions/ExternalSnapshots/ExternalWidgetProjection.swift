import Foundation

struct ExternalWidgetProjection: Sendable, Equatable {
    struct VariantRow: Sendable, Equatable {
        let kind: ExternalSurfaceVariantKind
        let title: String
        let detail: String
        let privacySummary: String
        let actionTitle: String
    }

    let title: String
    let detail: String
    let lockDetail: String
    let trustSummary: String
    let privacySummary: String
    let accessibilityLabel: String
    let primaryURL: URL?
    let pressureLevel: ExternalSurfacePressureLevel
    let variants: [VariantRow]

    init(snapshot: ExternalSurfaceSnapshot?) {
        let glance = ExternalSurfaceGlanceState(snapshot: snapshot)
        let privacy = snapshot?.privacy ?? .safeDefault
        let contract = ExternalSurfaceContractRegistry.contract(for: .widgets)
        let title = ExternalWidgetProjection.title(for: glance)
        let detail = ExternalWidgetProjection.detail(for: glance)
        let privacySummary = ExternalWidgetProjection.privacySummary(
            glance: glance,
            privacy: privacy,
            contract: contract
        )

        self.title = title
        self.detail = detail
        self.lockDetail = ExternalWidgetProjection.lockDetail(for: glance, privacy: privacy)
        self.trustSummary = "\(glance.continuity.syncHealth.label) · \(glance.continuity.lease.freshnessLabel)"
        self.privacySummary = privacySummary
        self.accessibilityLabel = "\(title). \(detail). \(privacySummary). \(glance.continuity.lease.freshnessLabel)."
        self.primaryURL = ExternalWidgetProjection.primaryURL(for: glance, contract: contract)
        self.pressureLevel = glance.pressureLevel
        self.variants = ExternalWidgetProjection.variantRows(for: glance)
    }

    private static func primaryURL(
        for glance: ExternalSurfaceGlanceState,
        contract: ExternalSurfaceContract
    ) -> URL? {
        ExternalSurfaceActionPayload.safeDeepLinkURL(
            surface: .goalDetail,
            goalID: glance.primaryReference?.goalID,
            origin: .widget,
            fallbackTab: contract.fallbackTab ?? "today"
        )
    }

    private static func variantRows(for glance: ExternalSurfaceGlanceState) -> [VariantRow] {
        guard glance.continuity.lease.status == .current else { return [] }
        guard let ambientState = glance.ambientState else { return [] }
        let flagshipRows = [
            ambientState.currentStep,
            ambientState.todayPressure,
            ambientState.protectedTime,
            ambientState.captureEntry,
            ambientState.recovery,
        ].compactMap(\.self)
        let compatibilityRows = [ambientState.today, ambientState.focus, ambientState.goal, ambientState.plan]
        return (flagshipRows + compatibilityRows)
            .sorted { prominenceRank($0.prominence) > prominenceRank($1.prominence) }
            .map {
                VariantRow(
                    kind: $0.kind,
                    title: $0.title,
                    detail: $0.detail,
                    privacySummary: $0.privacySummary,
                    actionTitle: $0.action.title
                )
            }
    }

    private static func title(for glance: ExternalSurfaceGlanceState) -> String {
        switch glance.continuity.lease.status {
        case .current:
            break
        case .stale:
            return "Open Ambitions to refresh"
        case .unavailable:
            return "Open Ambitions"
        }
        if let today = glance.ambientState?.today {
            return today.title
        }
        if let ritualCue = glance.ritualCue {
            return ritualTitle(for: ritualCue.kind)
        }
        switch glance.todayPosture {
        case .empty:
            return "No next step"
        case .active:
            return "Next step ready"
        case .waiting:
            return "Waiting on a blocker"
        case .recovery:
            return "Recovery step ready"
        }
    }

    private static func detail(for glance: ExternalSurfaceGlanceState) -> String {
        switch glance.continuity.lease.status {
        case .current:
            break
        case .stale:
            return "This may be behind."
        case .unavailable:
            return "Confirm the latest local state in Ambitions."
        }
        if let today = glance.ambientState?.today {
            return today.detail
        }
        if let ritualCue = glance.ritualCue {
            switch ritualCue.kind {
            case .morningSetup:
                return "One next step is ready."
            case .middayReset:
                return ritualCue.progressState == .needsReset ? "A smaller reset is ready." : "The next step still fits."
            case .eveningClose:
                return "Close the loop in Today."
            case .weeklyReset:
                return "Review the week in Today."
            }
        }
        switch glance.todayPosture {
        case .waiting:
            return "Open Ambitions for the next useful step."
        case .empty:
            return "Open Ambitions to refresh your plan."
        case .active, .recovery:
            return urgencyLabel(glance.urgency)
        }
    }

    private static func lockDetail(
        for glance: ExternalSurfaceGlanceState,
        privacy: ExternalSurfacePrivacySnapshotPolicy
    ) -> String {
        switch glance.continuity.lease.status {
        case .current:
            return detail(for: glance)
        case .stale:
            return privacy.staleLabel
        case .unavailable:
            return privacy.unavailableLabel
        }
    }

    private static func privacySummary(
        glance: ExternalSurfaceGlanceState,
        privacy: ExternalSurfacePrivacySnapshotPolicy,
        contract: ExternalSurfaceContract
    ) -> String {
        if glance.continuity.lease.status == .unavailable {
            return privacy.unavailableLabel
        }
        if glance.continuity.lease.status == .stale {
            return privacy.staleLabel
        }
        if contract.hidesSensitiveDetailsByDefault {
            return privacy.sensitiveDetailLabel
        }
        return "Widget details follow your Ambitions privacy settings."
    }

    private static func prominenceRank(_ prominence: ExternalSurfaceVariantProminence) -> Int {
        switch prominence {
        case .quiet:
            return 0
        case .standard:
            return 1
        case .elevated:
            return 2
        }
    }

    private static func ritualTitle(for kind: ExternalSurfaceRitualKind) -> String {
        switch kind {
        case .morningSetup:
            return "Morning setup"
        case .middayReset:
            return "Midday reset"
        case .eveningClose:
            return "Evening close"
        case .weeklyReset:
            return "Weekly reset"
        }
    }

    private static func urgencyLabel(_ urgency: ExternalSurfaceUrgency) -> String {
        switch urgency {
        case .overdue:
            return "Needs attention"
        case .soon:
            return "Coming up soon"
        case .normal:
            return "In progress"
        case .anytime:
            return "Flexible timing"
        }
    }
}
