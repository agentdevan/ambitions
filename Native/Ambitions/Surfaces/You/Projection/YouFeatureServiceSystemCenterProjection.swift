import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedYouService {
    func makeSystemCenter(
        snapshot: Snapshot,
        syncStatus: SyncCapabilityStatus,
        notificationStatus: YouNotificationAuthorization,
        calendarAuthorization: CalendarRemindersAuthorizationState,
        reviews: YouReviewsState,
        contextSignals: Int,
        appearanceSummary: String
        ) -> YouSystemCenterState {
        YouSystemCenterState(
            title: "Settings",
            subtitle: "Local profile keeps appearance, capture, privacy, data, receipts, and defaults inspectable.",
            sections: [
                YouSystemCenterSection(
                    id: "planning-behavior",
                    title: "Planning Defaults",
                    footer: "Guided automation is the default. Ambitions does not fill open time just because it exists.",
                    items: [
                        YouSystemCenterItem(
                            id: "schedule-availability",
                            title: "Schedule & Availability",
                            subtitle: "Work, school, protected time, buffers, and anchors.",
                            icon: "calendar.badge.clock",
                            statusLabel: calendarAuthorizationLabel(calendarAuthorization),
                            semanticState: .calendarDerived,
                            accessibilityHint: "Opens Schedule and Availability."
                        ),
                        YouSystemCenterItem(
                            id: "plan-behavior",
                            title: "Time Behavior",
                            subtitle: "Open time, protected free time, buffers, and reflow rules.",
                            icon: "slider.horizontal.below.rectangle",
                            statusLabel: "Do not fill",
                            semanticState: .protected,
                            accessibilityHint: "Opens Time Behavior."
                        ),
                        YouSystemCenterItem(
                            id: "automation-trust",
                            title: "Privacy & automation",
                            subtitle: "Trust comes before automation. \(AutomationLevel.defaultLevel.explanation)",
                            icon: "hand.raised",
                            statusLabel: AutomationLevel.defaultLevel.displayLabel,
                            semanticState: .trust,
                            accessibilityHint: "Opens Trust and Automation."
                        ),
                        YouSystemCenterItem(
                            id: "vacation-away-time",
                            title: "Vacation / Away Time",
                            subtitle: "Vacation is not free time unless you mark it open.",
                            icon: "airplane.departure",
                            statusLabel: VacationAvailabilityBehavior.defaultBehavior.displayLabel,
                            semanticState: .protected,
                            accessibilityHint: "Opens Vacation and Away Time."
                        ),
                        YouSystemCenterItem(
                            id: "durations",
                            title: "Durations",
                            subtitle: "Planned, suggested, historical, actual, or unset.",
                            icon: "timer",
                            statusLabel: "Grounded",
                            semanticState: .trust,
                            accessibilityHint: "Opens duration behavior."
                        )
                    ]
                ),
                YouSystemCenterSection(
                    id: "memory-and-trust",
                    title: "Memory and Trust",
                    footer: nil,
                    items: [
                        YouSystemCenterItem(
                            id: "what-ambitions-knows",
                            title: "What Ambitions Knows",
                            subtitle: "Local context you can inspect, correct, reset, or hold back.",
                            icon: "brain.head.profile",
                            statusLabel: contextSignals == 0 ? "Empty" : "Stored on this device",
                            semanticState: contextSignals == 0 ? .neutral : .trust,
                            accessibilityHint: "Opens local memory controls."
                        ),
                        YouSystemCenterItem(
                            id: "trust-center",
                            title: "Trust Center",
                            subtitle: "Permissions, privacy, and boundaries.",
                            icon: "checkmark.shield",
                            statusLabel: "Review",
                            semanticState: .trust,
                            accessibilityHint: "Opens Trust Center."
                        ),
                        YouSystemCenterItem(
                            id: "receipts-history",
                            title: "Receipts & History",
                            subtitle: "What changed and why.",
                            icon: "doc.text.magnifyingglass",
                            statusLabel: "Stored on this device",
                            semanticState: .neutral,
                            accessibilityHint: "Opens receipt history."
                        ),
                        YouSystemCenterItem(
                            id: "corrections",
                            title: "Corrections",
                            subtitle: "Fix assumptions and teaching signals.",
                            icon: "checkmark.bubble",
                            statusLabel: snapshot.teachingSignals.isEmpty ? "Ready" : "\(snapshot.teachingSignals.count)",
                            semanticState: .caution,
                            accessibilityHint: "Opens corrections."
                        )
                    ]
                ),
                YouSystemCenterSection(
                    id: "reviews-and-progress",
                    title: "Reviews and Progress",
                    footer: nil,
                    items: [
                        YouSystemCenterItem(
                            id: "reviews",
                            title: "Reviews",
                            subtitle: "Recovery and progress check-ins.",
                            icon: "rectangle.stack.badge.play",
                            statusLabel: "Review",
                            semanticState: .review,
                            accessibilityHint: "Opens Reviews."
                        ),
                        YouSystemCenterItem(
                            id: "proof",
                            title: "Proof",
                            subtitle: "Evidence and progress notes.",
                            icon: "checkmark.seal",
                            statusLabel: "Local",
                            semanticState: .success,
                            accessibilityHint: "Opens proof summary."
                        ),
                        YouSystemCenterItem(
                            id: "archive-completed",
                            title: "Archive / Completed",
                            subtitle: "Saved learning from finished work.",
                            icon: "archivebox",
                            statusLabel: "Saved",
                            semanticState: .neutral,
                            accessibilityHint: "Opens archive summary."
                        )
                    ]
                ),
                YouSystemCenterSection(
                    id: "personal-defaults",
                    title: "Defaults",
                    footer: nil,
                    items: [
                        YouSystemCenterItem(
                            id: "you",
                            title: "Local profile",
                            subtitle: "Name and default landing tab.",
                            icon: "person.crop.circle",
                            statusLabel: snapshot.appState.userDisplayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Optional" : "Local",
                            semanticState: .neutral,
                            accessibilityHint: "Opens local profile settings."
                        ),
                        YouSystemCenterItem(
                            id: "personalization",
                            title: "Personalization",
                            subtitle: "Tone and planning defaults.",
                            icon: "slider.horizontal.3",
                            statusLabel: "Defaults",
                            semanticState: .trust,
                            accessibilityHint: "Opens personalization settings."
                        ),
                        YouSystemCenterItem(
                            id: "appearance",
                            title: "Appearance",
                            subtitle: "Mode and accent.",
                            icon: "paintpalette",
                            statusLabel: snapshot.appState.appearancePreference.title,
                            semanticState: .success,
                            accessibilityHint: "Opens Appearance Studio."
                        )
                    ]
                ),
                YouSystemCenterSection(
                    id: "system-edges",
                    title: "System Edges",
                    footer: nil,
                    items: [
                        YouSystemCenterItem(
                            id: "notifications",
                            title: "Notifications",
                            subtitle: "Reminder permission.",
                            icon: "bell.badge",
                            statusLabel: notificationStatus.statusLabel,
                            semanticState: notificationStatus.statusLabel == "Denied" ? .caution : .neutral,
                            accessibilityHint: "Opens notification settings."
                        ),
                        YouSystemCenterItem(
                            id: "integrations",
                            title: "Integrations",
                            subtitle: "Calendar and reminders.",
                            icon: "rectangle.connected.to.line.below",
                            statusLabel: calendarAuthorizationLabel(calendarAuthorization),
                            semanticState: .calendarDerived,
                            accessibilityHint: "Opens integrations."
                        ),
                        YouSystemCenterItem(
                            id: "widgets-live-activities-shortcuts",
                            title: "Widgets / Live Activities / Shortcuts",
                            subtitle: "External surface status.",
                            icon: "square.grid.2x2",
                            statusLabel: "Bounded",
                            semanticState: .neutral,
                            accessibilityHint: "Opens external surface status."
                        ),
                        YouSystemCenterItem(
                            id: "export-import",
                            title: "Export / Import",
                            subtitle: "Local backup and restore posture.",
                            icon: "externaldrive",
                            statusLabel: syncTrustStatusLabel(syncStatus),
                            semanticState: .caution,
                            accessibilityHint: "Opens export and import status."
                        )
                    ]
                ),
                YouSystemCenterSection(
                    id: "accessibility-and-support",
                    title: "Accessibility and Support",
                    footer: "Rows open details; nothing here changes plans silently.",
                    items: [
                        YouSystemCenterItem(
                            id: "accessibility",
                            title: "Accessibility",
                            subtitle: "Claims and manual review status.",
                            icon: "figure",
                            statusLabel: "Locked",
                            semanticState: .accessibilityUnverified,
                            accessibilityHint: "Opens accessibility status."
                        ),
                        YouSystemCenterItem(
                            id: "help-support",
                            title: "Help / Support",
                            subtitle: "Guidance and support posture.",
                            icon: "questionmark.circle",
                            statusLabel: "Guide",
                            semanticState: .neutral,
                            accessibilityHint: "Opens help and support."
                        ),
                        YouSystemCenterItem(
                            id: "about",
                            title: "About",
                            subtitle: "Local-first app status.",
                            icon: "info.circle",
                            statusLabel: "Local",
                            semanticState: .neutral,
                            accessibilityHint: "Opens about Ambitions."
                        )
                    ]
                )
            ],
            footer: "You keeps setup, history, trust, and controls together without changing anything silently."
        )
    }

}
