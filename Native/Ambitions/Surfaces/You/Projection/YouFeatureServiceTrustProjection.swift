import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedYouService {
    func makeTrustDataMap(
        snapshot: Snapshot,
        syncStatus: SyncCapabilityStatus,
        notificationStatus: YouNotificationAuthorization,
        calendarAuthorization: CalendarRemindersAuthorizationState,
        receipts: [ActionReceipt],
        personalVault: YouPersonalVaultState
    ) -> [YouTrustDataMapItem] {
        let openCaptures = snapshot.captures.filter { $0.status != .archived }.count
        let receiptCount = ActionReceiptProjection(receipts: receipts).displaySummaries().count
        let localSignalCount = snapshot.evidence.count + snapshot.feedback.count + snapshot.teachingSignals.count + snapshot.eventLedger.count
        let personalVaultRowCount = personalVault.sections.flatMap(\.rows).count
        return [
            YouTrustDataMapItem(
                id: "trust-data-map-personal-vault",
                title: "Personal vault",
                dataTypes: "Sensitive local signals, permissions, export, reset, delete, provenance, privacy policy",
                sourceLabel: personalVaultRowCount == 0 ? "Summary only" : "\(personalVaultRowCount) rows in You",
                controlLabel: "Inspect in Search Ambitions",
                privacyLabel: "Private by default",
                statusLabel: "Local and inspectable",
                semanticState: .trust
            ),
            YouTrustDataMapItem(
                id: "trust-data-map-local-context",
                title: "Local context",
                dataTypes: "Goals, captures, proof, corrections, receipts, reviews",
                sourceLabel: "\(localSignalCount) local signals, \(openCaptures) open captures",
                controlLabel: "Inspect and correct from owning surfaces",
                privacyLabel: "Private by default",
                statusLabel: "Stored on this device",
                semanticState: .trust
            ),
            YouTrustDataMapItem(
                id: "trust-data-map-permissions",
                title: "Permission boundaries",
                dataTypes: "Notifications and Time-owned calendar awareness",
                sourceLabel: "Notifications \(notificationStatus.statusLabel); calendar \(calendarAuthorizationLabel(calendarAuthorization))",
                controlLabel: "System permission controls stay explicit",
                privacyLabel: "No silent calendar writes",
                statusLabel: "Permission-gated",
                semanticState: .calendarDerived
            ),
            YouTrustDataMapItem(
                id: "trust-data-map-receipts",
                title: "Receipts and correction state",
                dataTypes: "Action receipts, undo posture, correction availability",
                sourceLabel: receiptCount == 0 ? "No recent receipts" : "\(receiptCount) receipt examples",
                controlLabel: "Change, correct, or review where supported",
                privacyLabel: "Summaries first",
                statusLabel: "Evidence-led",
                semanticState: .review
            ),
            YouTrustDataMapItem(
                id: "trust-data-map-future-owned",
                title: "Future-owned edges",
                dataTypes: "Sync, export proof, destructive delete, broad memory controls",
                sourceLabel: syncStatus.detail,
                controlLabel: "Blocked until owner proof confirms safety",
                privacyLabel: "No hidden account or cloud claim",
                statusLabel: "Future-owned",
                semanticState: .caution
            )
        ]
    }

    func makeTrustCenterSections(
        syncStatus: SyncCapabilityStatus,
        notificationStatus: YouNotificationAuthorization,
        calendarAuthorization: CalendarRemindersAuthorizationState,
        receipts: [ActionReceipt],
        teachingSignalCount: Int,
        personalVault: YouPersonalVaultState
    ) -> [YouTrustCenterSection] {
        let receiptProjection = ActionReceiptProjection(receipts: receipts)
        let undoCount = receiptProjection.undoAvailableReceipts().count
        let receiptCount = receiptProjection.displaySummaries().count
        let personalVaultRowCount = personalVault.sections.flatMap(\.rows).count

        return [
            YouTrustCenterSection(
                id: "trust-center-status",
                title: "Status and boundaries",
                footer: "These rows describe current runtime truth. They do not request permissions or enable future services by themselves.",
                routes: [
                    YouTrustCenterRoute(
                        id: "trust-route-local-data",
                        title: "Local data status",
                        subtitle: "Goals, captures, proof, corrections, receipts, and reviews read from this device in the current runtime.",
                        icon: "internaldrive",
                        statusLabel: "Stored on this device",
                        semanticState: .trust,
                        accessibilityHint: "Shows local storage trust status."
                    ),
                    YouTrustCenterRoute(
                        id: "trust-route-calendar",
                        title: "Calendar boundary",
                        subtitle: "Calendar awareness is Time-owned. Writes require confirmation and are never silent.",
                        icon: "calendar.badge.clock",
                        statusLabel: calendarAuthorizationLabel(calendarAuthorization),
                        semanticState: .calendarDerived,
                        accessibilityHint: "Shows calendar permission and write boundary."
                    ),
                    YouTrustCenterRoute(
                        id: "trust-route-notifications",
                        title: "Notification boundary",
                        subtitle: "Local reminders are optional and permission-gated. Ambitions still works without notification access.",
                        icon: "bell.badge",
                        statusLabel: notificationStatus.statusLabel,
                        semanticState: notificationStatus.statusLabel == "Denied" ? .caution : .neutral,
                        accessibilityHint: "Shows notification permission status."
                    ),
                    YouTrustCenterRoute(
                        id: "trust-route-external-surfaces",
                        title: "External surfaces",
                        subtitle: "Widgets, Live Activities, Shortcuts, and Share Extension must use privacy snapshots and fallback routes.",
                        icon: "rectangle.3.group",
                        statusLabel: ExternalSurfaceTruth.productizedNeedsPlatformReview,
                        semanticState: .caution,
                        accessibilityHint: "Shows external-surface verification status."
                    ),
                    YouTrustCenterRoute(
                        id: "trust-route-personal-vault",
                        title: "Personal vault",
                        subtitle: "Sensitive local signal rows, provenance, and permission labels stay visible before broader policy work.",
                        icon: "lock.shield",
                        statusLabel: personalVaultRowCount == 0 ? "Summary only" : "\(personalVaultRowCount) rows",
                        semanticState: .trust,
                        accessibilityHint: "Shows personal vault and permissions posture."
                    )
                ]
            ),
            YouTrustCenterSection(
                id: "trust-center-receipts",
                title: "Receipts, corrections, and explanations",
                footer: "Receipt rows summarize policy and action history without exposing raw logs by default.",
                routes: [
                    YouTrustCenterRoute(
                        id: "trust-route-receipts",
                        title: "Receipts",
                        subtitle: "Receipts say what happened, what changed, why, and what can be corrected or undone.",
                        icon: "doc.text.magnifyingglass",
                        statusLabel: receiptCount == 0 ? "No recent receipts" : "\(receiptCount) examples",
                        semanticState: .review,
                        accessibilityHint: "Shows receipt history posture."
                    ),
                    YouTrustCenterRoute(
                        id: "trust-route-why-this",
                        title: "Why This?",
                        subtitle: "Recommendations name the action, source, reason, uncertainty, user control, and receipt behavior before trust-sensitive action.",
                        icon: "questionmark.bubble",
                        statusLabel: "Explain first",
                        semanticState: .trust,
                        accessibilityHint: "Shows why this explanation posture."
                    ),
                    YouTrustCenterRoute(
                        id: "trust-route-quiet-reflow",
                        title: "Quiet Reflow",
                        subtitle: "Meaningful time changes stay previewed before apply; manual planning remains available if a source is unavailable.",
                        icon: "arrow.triangle.2.circlepath",
                        statusLabel: "Preview first",
                        semanticState: .calendarDerived,
                        accessibilityHint: "Shows preview changes and user choice posture."
                    ),
                    YouTrustCenterRoute(
                        id: "trust-route-corrections",
                        title: "Correction routes",
                        subtitle: "Supported corrections stay tied to existing Goal Detail, Capture, teaching, and explanation seams.",
                        icon: "checkmark.bubble",
                        statusLabel: teachingSignalCount == 0 ? "Available where shown" : "\(teachingSignalCount) local",
                        semanticState: .trust,
                        accessibilityHint: "Shows correction availability."
                    ),
                    YouTrustCenterRoute(
                        id: "trust-route-undo",
                        title: "Undo rules",
                        subtitle: "Local undo is shown only where safe. Broad, external, destructive, or unsupported changes stay blocked or confirmation-gated.",
                        icon: "arrow.uturn.backward",
                        statusLabel: undoCount == 0 ? "No silent undo" : "\(undoCount) available",
                        semanticState: .caution,
                        accessibilityHint: "Shows undo safety posture."
                    ),
                    YouTrustCenterRoute(
                        id: "trust-route-explanations",
                        title: "Explanations",
                        subtitle: "Why This, Why Now, Why Changed, and What This Uses should cite local evidence or admit when detail is unavailable.",
                        icon: "text.bubble",
                        statusLabel: "Evidence-led",
                        semanticState: .trust,
                        accessibilityHint: "Shows explanation rule posture."
                    )
                ]
            ),
            YouTrustCenterSection(
                id: "trust-center-privacy-future",
                title: "Privacy and future-owned capabilities",
                footer: "Unavailable states stay visible so this surface does not imply hidden accounts, cloud sync, or production-ready export.",
                routes: [
                    YouTrustCenterRoute(
                        id: "trust-route-privacy",
                        title: "Privacy defaults",
                        subtitle: "Sensitive details should be hidden on compact and external surfaces unless the user chooses otherwise.",
                        icon: "hand.raised",
                        statusLabel: "Private by default",
                        semanticState: .protected,
                        accessibilityHint: "Shows privacy-safe display posture."
                    ),
                    YouTrustCenterRoute(
                        id: "trust-route-sync-export",
                        title: "Sync / Export truth",
                        subtitle: syncExportTruthSubtitle(syncStatus),
                        icon: "externaldrive",
                        statusLabel: syncTrustStatusLabel(syncStatus),
                        semanticState: .caution,
                        accessibilityHint: "Shows sync and export truth."
                    ),
                    YouTrustCenterRoute(
                        id: "trust-route-vault-export",
                        title: "Vault export boundary",
                        subtitle: "Personal vault rows stay explicit about what can be exported, reset, deleted, or kept summary-only.",
                        icon: "square.and.arrow.up",
                        statusLabel: personalVaultRowCount == 0 ? "Summary only" : "Review only",
                        semanticState: .caution,
                        accessibilityHint: "Shows vault export and delete boundary."
                    ),
                    YouTrustCenterRoute(
                        id: "trust-route-accessibility-claims",
                        title: "Accessibility claims",
                        subtitle: "Internal evidence exists. Public claims stay locked until manual VoiceOver, Dynamic Type, Reduce Motion, contrast, and motor review is recorded.",
                        icon: "figure",
                        statusLabel: "Claims locked",
                        semanticState: .accessibilityUnverified,
                        accessibilityHint: "Shows accessibility claim status."
                    )
                ]
            )
        ]
    }

}
