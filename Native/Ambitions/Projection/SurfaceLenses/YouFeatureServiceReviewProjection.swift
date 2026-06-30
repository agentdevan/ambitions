import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedYouService {
    func makeTrustHistoryCenter(
        snapshot: Snapshot,
        receipts: [ActionReceipt],
        safetySamples: SafetyBoundarySamples,
        calendarAuthorization: CalendarRemindersAuthorizationState,
        notificationStatus: YouNotificationAuthorization
    ) -> YouTrustHistoryCenterState {
        YouTrustHistoryProjector().project(
            YouTrustHistoryProjector.Input(
                receipts: ActionReceiptProjection(receipts: receipts).displaySummaries(limit: 2),
                recentEvents: Array(snapshot.eventLedger.prefix(2)),
                proofCount: snapshot.evidence.count,
                sourceReviewCount: snapshot.eventLedger.filter(\.trust.requiresReview).count + snapshot.teachingSignals.count,
                automationReviewCount: safetySamples.confirmationRequired + (safetySamples.destructiveBlocked ? 1 : 0),
                permissionSummary: "Notifications \(notificationStatus.statusLabel); calendar \(calendarAuthorizationLabel(calendarAuthorization))."
            )
        )
    }

    func makeCrossSurfaceProofReview(snapshot: Snapshot) -> YouCrossSurfaceProofReviewState {
        let captureSeedCount = snapshot.captures.filter { $0.status != .archived }.count +
            snapshot.drafts.filter { draft in
                draft.latestResultKind == .planned ||
                    draft.latestResultKind == .starterPlanned ||
                    draft.latestResultKind == .clarificationRequired
            }.count
        let goalProofCount = snapshot.evidence.filter { !$0.goalID.isEmpty }.count
        let todayCompletionProofCount = snapshot.evidence.filter { evidence in
            evidence.evidenceKind == .stepCompleted || evidence.evidenceKind == .sessionLogged
        }.count
        let planReceiptCount = snapshot.eventLedger.filter { event in
            event.source == .plan ||
                event.source == .planner ||
                event.kind == .planRecovered ||
                event.kind == .planRescheduled ||
                event.kind == .planUpdated
        }.count
        let goalChangeCount = snapshot.eventLedger.filter { event in
            event.source == .goals ||
                event.source == .goalEngine ||
                event.kind == .goalCreated ||
                event.kind == .goalUpdated ||
                event.kind == .deadlineChanged ||
                event.kind == .priorityChanged
        }.count
        let reviewPromptCount = snapshot.eventLedger.filter(\.trust.requiresReview).count +
            snapshot.teachingSignals.count

        return YouCrossSurfaceProofReviewProjector().project(
            YouCrossSurfaceProofReviewProjector.Input(
                captureSeedCount: captureSeedCount,
                goalProofCount: goalProofCount,
                todayCompletionProofCount: todayCompletionProofCount,
                planReceiptCount: planReceiptCount,
                goalChangeCount: goalChangeCount,
                reviewPromptCount: reviewPromptCount
            )
        )
    }

    func makeReviews(
        snapshot: Snapshot,
        receipts: [ActionReceipt],
        calendarAuthorization: CalendarRemindersAuthorizationState
    ) -> YouReviewsState {
        let projection = ReviewsV1Projector().project(
            ReviewsV1ProjectionInput(
                generatedAt: DomainTimestamp.string(from: .now),
                timeframeLabel: "Recent local review",
                eventLedgerEntries: snapshot.eventLedger,
                receipts: receipts,
                proofEvidence: snapshot.evidence,
                teachingSignals: snapshot.teachingSignals,
                calendarStatusLabel: calendarAuthorizationLabel(calendarAuthorization)
            )
        )

        return YouReviewsState(
            projection: projection,
            title: "Reviews",
            subtitle: "Recovery Review and Life OS Receipt for what happened, what changed, and what should carry forward.",
            footer: "Reviews uses existing local ledgers, receipts, proof, and correction signals. It does not restore Insights as a tab or claim live sync, account systems, or verified accessibility."
        )
    }

    func dominantTruth(
        syncStatus: SyncCapabilityStatus,
        notificationStatus: YouNotificationAuthorization,
        appearanceSummary: String
    ) -> String {
        if notificationStatus.statusLabel == "Denied" {
            return "Appearance is configured, but one trust edge still needs attention: notifications are denied."
        }
        return "Trust is \(syncStatus.trustPosture == .localOnly ? "local-first" : "bounded"), memory is inspectable, and risky changes require confirmation."
    }

    func syncPulseTitle(for status: SyncCapabilityStatus) -> String {
        switch status.trustPosture {
        case .localOnly:
            return "Local-first and stable"
        }
    }

    func syncTrustStatusLabel(_ status: SyncCapabilityStatus) -> String {
        if status.availability == .unavailable &&
            status.trustPosture == .localOnly &&
            status.detail.describesLocalOnlyRuntime {
            return "Not currently connected"
        }
        return status.detail
    }

    func syncExportTruthSubtitle(_ status: SyncCapabilityStatus) -> String {
        if status.availability == .unavailable &&
            status.trustPosture == .localOnly &&
            status.detail.describesLocalOnlyRuntime {
            return "Sync is not connected. Export and import proof remain future-owned until the disaster drill passes."
        }
        return "\(status.detail) Export and import proof remain future-owned until the disaster drill passes."
    }

    func syncVisualState(_ status: SyncCapabilityStatus) -> AmbitionVisualState {
        switch status.trustPosture {
        case .localOnly:
            return .selected
        }
    }

    func appearanceSubtitle(for preference: AppAppearancePreference) -> String {
        switch preference {
        case .system:
            return "Follow the device while keeping Ambitions hierarchy intact."
        case .light:
            return "Use the warm light palette full time."
        case .dark:
            return "Use the flagship dark palette full time."
        }
    }

    func accentSubtitle(for family: AmbitionAccentFamily) -> String {
        switch family {
        case .sage:
            return "Quiet, grounded, and balanced."
        case .blueGray:
            return "Cooler and architectural."
        case .mutedGold:
            return "Warm emphasis with restrained glow."
        case .copper:
            return "Richer warmth for stronger highlights."
        case .sand:
            return "Soft neutral warmth with gentle contrast."
        }
    }

    func notificationAuthorizationSubtitle(for status: YouNotificationAuthorization) -> String {
        if status.statusLabel == "Denied" {
            return "Denied in system settings. Local reminders exist, but trust is clearer when notification delivery is enabled or intentionally left off."
        }
        return "Authorization: \(status.detail) Local reminders stay on-device and bounded to the current runtime."
    }

    func calendarAuthorizationLabel(_ state: CalendarRemindersAuthorizationState) -> String {
        switch state {
        case .notDetermined:
            return "Not requested"
        case .denied:
            return "Denied"
        case .restricted:
            return "Restricted"
        case .authorized:
            return "Authorized"
        case .writeOnly:
            return "Write only"
        case .fullAccess:
            return "Full access"
        }
    }

    func isPlanningFriction(_ event: GoalFeedbackEvent) -> Bool {
        switch event {
        case .skipped, .confused, .tooBig, .notRelevant, .askedForSmallerVersion:
            return true
        default:
            return false
        }
    }

    func reviewLabel(days: Int) -> String {
        if days <= 1 {
            return "Daily"
        }
        if days == 7 {
            return "Weekly"
        }
        return "Every \(days) days"
    }

    func notificationAuthorizationStatus(_ state: NotificationAuthorizationState) -> YouNotificationAuthorization {
        switch state {
        case .notDetermined:
            return YouNotificationAuthorization(
                statusLabel: "Not requested",
                detail: "Not requested yet.",
                canRequestAuthorization: true,
                actionTitle: "Enable notifications"
            )
        case .denied:
            return YouNotificationAuthorization(
                statusLabel: "Denied",
                detail: "Denied in system settings.",
                canRequestAuthorization: false,
                actionTitle: nil
            )
        case .authorized:
            return YouNotificationAuthorization(
                statusLabel: "Allowed",
                detail: "Allowed for local reminders.",
                canRequestAuthorization: false,
                actionTitle: nil
            )
        case .provisional:
            return YouNotificationAuthorization(
                statusLabel: "Allowed",
                detail: "Provisionally allowed for local reminders.",
                canRequestAuthorization: false,
                actionTitle: nil
            )
        case .ephemeral:
            return YouNotificationAuthorization(
                statusLabel: "Allowed",
                detail: "Temporarily allowed for local reminders.",
                canRequestAuthorization: false,
                actionTitle: nil
            )
        }
    }

    func goalSourceOrdering(lhs: Goal, rhs: Goal) -> Bool {
        if lhs.updatedAt != rhs.updatedAt {
            return lhs.updatedAt > rhs.updatedAt
        }
        let titleCompare = lhs.title.localizedCaseInsensitiveCompare(rhs.title)
        if titleCompare != .orderedSame {
            return titleCompare == .orderedAscending
        }
        return lhs.id < rhs.id
    }

    func planSectionOrdering(lhs: PlanSection, rhs: PlanSection) -> Bool {
        if lhs.orderIndex != rhs.orderIndex {
            return lhs.orderIndex < rhs.orderIndex
        }
        let titleCompare = lhs.title.localizedCaseInsensitiveCompare(rhs.title)
        if titleCompare != .orderedSame {
            return titleCompare == .orderedAscending
        }
        return lhs.id < rhs.id
    }

    func stepSourceOrdering(lhs: Step, rhs: Step) -> Bool {
        if lhs.state != rhs.state {
            return stepStateRank(lhs.state) < stepStateRank(rhs.state)
        }
        let titleCompare = lhs.title.localizedCaseInsensitiveCompare(rhs.title)
        if titleCompare != .orderedSame {
            return titleCompare == .orderedAscending
        }
        return lhs.id < rhs.id
    }

    func stepStateRank(_ state: StepLifecycleState) -> Int {
        switch state {
        case .planned, .active:
            return 0
        case .blocked:
            return 1
        case .completed, .cancelled:
            return 2
        }
    }
}

private extension String {
    var describesLocalOnlyRuntime: Bool {
        contains("explicit local-only mode") || contains("local-device authority")
    }
}
