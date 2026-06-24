import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedYouService {
    func makeAssumptionCorrections(snapshot: Snapshot) -> YouAssumptionCorrectionState {
        let activeSignals = snapshot.teachingSignals.filter { $0.disposition == .active }
        let correctionEvents = snapshot.eventLedger.filter { $0.kind == .userCorrectionAdded }
        return YouAssumptionCorrectionState(
            title: "Corrections and assumptions",
            subtitle: "Ambitions should be teachable without asking you to understand its internals.",
            items: [
                SettingsItem(
                    id: "you-correction-active",
                    title: "Active corrections",
                    subtitle: "Existing teaching signals are the current correction path. They are local and bounded to the artifacts they reference.",
                    icon: "checkmark.bubble",
                    valueLabel: activeSignals.isEmpty ? "None yet" : "\(activeSignals.count) active"
                ),
                SettingsItem(
                    id: "you-correction-ledger",
                    title: "Correction events",
                    subtitle: "Your correction history can explain why future recommendations changed.",
                    icon: "clock.arrow.circlepath",
                    valueLabel: correctionEvents.isEmpty ? "No recent entries" : "\(correctionEvents.count) recent"
                ),
                SettingsItem(
                    id: "you-correction-availability",
                    title: "You can correct this",
                    subtitle: "Goal Detail explanations and existing teaching flows remain the supported place to correct assumptions.",
                    icon: "pencil.and.list.clipboard",
                    valueLabel: "Supported where shown"
                )
            ],
            footer: "This is an entry point into existing correction systems, not a second memory model or a full Correction Review."
        )
    }

    func makeAutomationBoundary(safetySamples: SafetyBoundarySamples) -> YouAutomationBoundaryState {
        YouAutomationBoundaryState(
            title: "What Ambitions will not do silently",
            subtitle: "The safe automation policy keeps external, broad, destructive, and unsupported changes confirmation-gated or blocked.",
            rules: [
                YouConstitutionRule(
                    id: "automation-calendar",
                    title: "No silent calendar changes",
                    detail: safetySamples.calendarWrite.reasons.map(\.userFacingSummary).joined(separator: " "),
                    statusLabel: "Requires confirmation",
                    state: .warning
                ),
                YouConstitutionRule(
                    id: "automation-reflow",
                    title: "No silent broad reflow",
                    detail: safetySamples.broadReflow.reasons.map(\.userFacingSummary).joined(separator: " "),
                    statusLabel: "Requires confirmation",
                    state: .warning
                ),
                YouConstitutionRule(
                    id: "automation-memory",
                    title: "No unsupported forgetting",
                    detail: safetySamples.forgetMemory.blockedFacts.first ?? "No memory was forgotten.",
                    statusLabel: safetySamples.destructiveBlocked ? "Blocked safely" : "Unavailable",
                    state: .warning
                ),
                YouConstitutionRule(
                    id: "automation-correction",
                    title: "Corrections stay user-directed",
                    detail: "Correcting a recommendation is a local policy-recognized action when tied to an existing target.",
                    statusLabel: "User controlled",
                    state: .success
                )
            ],
            footer: "This describes policy decisions only. It does not execute calendar writes, sync resolution, deletion, or undo."
        )
    }

    func makePlanningDefaultsCenter(
        calendarAuthorization: CalendarRemindersAuthorizationState,
        remindersAuthorization: CalendarRemindersAuthorizationState,
        safetySamples: SafetyBoundarySamples
    ) -> YouPlanningDefaultsCenterState {
        YouPlanningDefaultsCenterState(
            title: "Planning setup that earns its place",
            subtitle: "These defaults explain how Ambitions shapes Time suggestions without treating setup as homework.",
            sections: [
                YouPlanningDefaultsSection(
                    id: "schedule-availability",
                    title: "Schedule & Availability",
                    subtitle: "Time boundaries help the scheduling surface avoid treating committed or protected time as available.",
                    preferences: [
                        YouPlanningDefaultsPreference(
                            id: "schedule-anchors",
                            title: "Work, school, and anchors",
                            whyItMatters: "Plan can keep committed blocks, transitions, sleep, care, and recovery from being mistaken for open capacity.",
                            statusLabel: calendarAuthorizationLabel(calendarAuthorization),
                            privacyLabel: "Calendar awareness is Time-owned and requested only after a clear Time action.",
                            defaultLabel: "Optional",
                            accessibilityHint: "Explains why schedule anchors improve planning fit.",
                            state: .default
                        ),
                        YouPlanningDefaultsPreference(
                            id: "schedule-buffers",
                            title: "Buffers and protected time",
                            whyItMatters: "Buffers and protected free time create breathing room before Ambitions suggests where work can fit.",
                            statusLabel: "Protected",
                            privacyLabel: "Open time is not automatically filled.",
                            defaultLabel: "Do not fill",
                            accessibilityHint: "Explains how buffers protect capacity.",
                            state: .success
                        )
                    ],
                    footer: "Setup remains optional. Ambitions should ask for clearer boundaries only when planning quality depends on them."
                ),
                YouPlanningDefaultsSection(
                    id: "planning-defaults",
                    title: "Planning Defaults",
                    subtitle: "Defaults keep Time useful without making hidden changes.",
                    preferences: [
                        YouPlanningDefaultsPreference(
                            id: "planning-open-time",
                            title: "Open time behavior",
                            whyItMatters: "Open windows are capacity signals, not an invitation to pack the day.",
                            statusLabel: AvailabilityState.doNotFill.displayLabel,
                            privacyLabel: "Your time, your rules.",
                            defaultLabel: "Default",
                            accessibilityHint: "Explains the open time default.",
                            state: .success
                        ),
                        YouPlanningDefaultsPreference(
                            id: "planning-reflow",
                            title: "Reflow permission",
                            whyItMatters: "Meaningful day changes stay reviewable so Plan can recover without taking over.",
                            statusLabel: "Ask first",
                            privacyLabel: "Receipts explain consequential changes.",
                            defaultLabel: nil,
                            accessibilityHint: "Explains the reflow permission boundary.",
                            state: .warning
                        )
                    ],
                    footer: "Day, Week, and Month remain capacity lenses. They are not calendar modes."
                ),
                YouPlanningDefaultsSection(
                    id: "vacation-away-time",
                    title: "Vacation / Away Time",
                    subtitle: "Away time protects recovery unless you explicitly mark a window open.",
                    preferences: [
                        YouPlanningDefaultsPreference(
                            id: "vacation-default",
                            title: "Away time default",
                            whyItMatters: "Vacation is not free time by default, so Plan does not turn recovery into a work queue.",
                            statusLabel: VacationAvailabilityBehavior.defaultBehavior.displayLabel,
                            privacyLabel: "The selected behavior applies only to planning fit.",
                            defaultLabel: "Default",
                            accessibilityHint: "Explains the away time default.",
                            state: .success
                        ),
                        YouPlanningDefaultsPreference(
                            id: "vacation-override",
                            title: "Per-vacation override",
                            whyItMatters: "A specific trip can be open, protected, or mixed without changing future away-time defaults unless you choose to.",
                            statusLabel: "Per away block",
                            privacyLabel: "Future defaults change only through visible user choice.",
                            defaultLabel: nil,
                            accessibilityHint: "Explains per-vacation override behavior.",
                            state: .default
                        )
                    ],
                    footer: "Away-time behavior is a planning boundary, not a judgment about how time should be spent."
                ),
                YouPlanningDefaultsSection(
                    id: "automation-trust",
                    title: "Privacy & automation",
                    subtitle: "Trust comes before automation; automation remains permission posture, not silent control.",
                    preferences: [
                        YouPlanningDefaultsPreference(
                            id: "automation-guided",
                            title: "Guided automation",
                            whyItMatters: AutomationLevel.defaultLevel.explanation,
                            statusLabel: AutomationLevel.defaultLevel.displayLabel,
                            privacyLabel: "Ambitions proposes first and asks before consequential changes.",
                            defaultLabel: "Default",
                            accessibilityHint: "Explains the Guided automation default.",
                            state: .selected
                        ),
                        YouPlanningDefaultsPreference(
                            id: "automation-confirmation",
                            title: "Confirmation boundary",
                            whyItMatters: safetySamples.calendarWrite.reasons.map(\.userFacingSummary).joined(separator: " "),
                            statusLabel: "Confirm first",
                            privacyLabel: "No silent calendar changes.",
                            defaultLabel: nil,
                            accessibilityHint: "Explains the automation confirmation boundary.",
                            state: .warning
                        )
                    ],
                    footer: "This center explains the default. It does not execute calendar writes, permission requests, or broad reflow."
                )
            ],
            footer: "Planning setup is useful when it makes recommendations fit real capacity. It should never pressure completion or imply hidden access."
        )
    }

    func makeAvailabilityCenter(
        calendarAuthorization: CalendarRemindersAuthorizationState,
        remindersAuthorization: CalendarRemindersAuthorizationState,
        safetySamples: SafetyBoundarySamples
    ) -> YouAvailabilityCenterState {
        YouAvailabilityCenterState(
            title: "Availability Center",
            subtitle: "The rules Time must respect before it suggests where work fits.",
            hardContextStack: [
                YouAvailabilityCenterItem(
                    id: "hard-context-work-school",
                    title: "Work, school, and fixed anchors",
                    summary: "Committed blocks, sleep, care, commute, and buffers win before any planning suggestion.",
                    statusLabel: calendarAuthorizationLabel(calendarAuthorization),
                    sourceLabel: "Source: Time-owned calendar boundary",
                    state: .default
                ),
                YouAvailabilityCenterItem(
                    id: "hard-context-protected-time",
                    title: "Protected time",
                    summary: "Protected pockets are treated as real commitments, not open capacity.",
                    statusLabel: "Hard context",
                    sourceLabel: "Source: User default",
                    state: .success
                )
            ],
            protectedPocketMap: [
                YouAvailabilityCenterItem(
                    id: "protected-pocket-open-time",
                    title: "Open time is not auto-filled",
                    summary: "Open windows can help Time see possibility, but Ambitions must not pack them by default.",
                    statusLabel: AvailabilityState.doNotFill.displayLabel,
                    sourceLabel: "Source: Planning default",
                    state: .success
                ),
                YouAvailabilityCenterItem(
                    id: "protected-pocket-buffers",
                    title: "Buffers create breathing room",
                    summary: "Transitions, rest, and family/context margins stay visible before a day is reshaped.",
                    statusLabel: "Protected",
                    sourceLabel: "Source: Capacity boundary",
                    state: .success
                )
            ],
            planningDefaults: [
                YouAvailabilityCenterItem(
                    id: "planning-defaults-capacity-lenses",
                    title: "Day, Week, and Month are capacity lenses",
                    summary: "They are not calendar modes and should not become dense event grids.",
                    statusLabel: "Capacity lens",
                    sourceLabel: "Source: Product canon",
                    state: .default
                ),
                YouAvailabilityCenterItem(
                    id: "planning-defaults-reflow-review",
                    title: "Reflow stays reviewable",
                    summary: "Meaningful rearrangement needs a visible review boundary and receipt posture.",
                    statusLabel: "Ask first",
                    sourceLabel: "Source: Trust default",
                    state: .warning
                )
            ],
            automationTrustControls: [
                YouAvailabilityCenterItem(
                    id: "automation-guided-default",
                    title: "Guided automation is default",
                    summary: AutomationLevel.defaultLevel.explanation,
                    statusLabel: AutomationLevel.defaultLevel.displayLabel,
                    sourceLabel: "Source: Automation policy",
                    state: .selected
                ),
                YouAvailabilityCenterItem(
                    id: "automation-calendar-confirmation",
                    title: "Calendar writes require confirmation",
                    summary: safetySamples.calendarWrite.reasons.map(\.userFacingSummary).joined(separator: " "),
                    statusLabel: "Requires confirmation",
                    sourceLabel: "Source: Time safety policy",
                    state: .warning
                )
            ],
            durationSourceProof: DurationSource.allCases.map { source in
                YouAvailabilityCenterItem(
                    id: "duration-source-\(source.rawValue)",
                    title: durationTitle(for: source),
                    summary: durationSubtitle(for: source),
                    statusLabel: "Labeled",
                    sourceLabel: "Source: Duration proof",
                    state: source == .unset ? .default : .success
                )
            },
            vacationAwayBehavior: [
                YouAvailabilityCenterItem(
                    id: "away-default",
                    title: "Vacation is not free time by default",
                    summary: "Away time protects recovery unless the user explicitly marks part of it available.",
                    statusLabel: VacationAvailabilityBehavior.defaultBehavior.displayLabel,
                    sourceLabel: "Source: Away behavior default",
                    state: .success
                ),
                YouAvailabilityCenterItem(
                    id: "away-override",
                    title: "Per-away override",
                    summary: "A specific away block can be open, protected, or mixed without changing future defaults.",
                    statusLabel: "Visible choice",
                    sourceLabel: "Source: User override",
                    state: .default
                )
            ],
            footer: "Availability Center explains how defaults affect Today and time-fit guidance. It does not request permissions, write calendars, auto-fill open time, or run broad reflow."
        )
    }

    func durationTitle(for source: DurationSource) -> String {
        switch source {
        case .userSet: "User-set"
        case .userAccepted: "Accepted suggestion"
        case .suggested: "Suggested"
        case .historical: "Historical range"
        case .unset: "Unset"
        case .actual: "Actual"
        }
    }

    func durationSubtitle(for source: DurationSource) -> String {
        switch source {
        case .userSet: "Shown as planned because you set it."
        case .userAccepted: "Shown as planned after you accept it."
        case .suggested: "Always labeled as suggested."
        case .historical: "Always labeled as usually."
        case .unset: "Shown as Duration not set."
        case .actual: "Shown only after completion evidence exists."
        }
    }

    func makePolicyReceipts(safetySamples: SafetyBoundarySamples) -> [ActionReceipt] {
        [
            safetySamples.calendarWrite.recommendedReceipt(occurredAt: "2026-04-27T00:00:00Z"),
            safetySamples.forgetMemory.recommendedReceipt(occurredAt: "2026-04-27T00:00:01Z"),
            safetySamples.localCorrection.recommendedReceipt(occurredAt: "2026-04-27T00:00:02Z")
        ]
    }

    func makeReceiptAudit(snapshot: Snapshot, receipts: [ActionReceipt]) -> YouReceiptAuditState {
        let projection = ActionReceiptProjection(receipts: receipts)
        return YouReceiptAuditState(
            title: "Receipts and audit posture",
            subtitle: "A compact trust summary of what can explain actions today. Reviews now turns these signals into a calm receipt layer.",
            items: [
                SettingsItem(
                    id: "you-receipts-domain",
                    title: "Receipts",
                    subtitle: "Receipts can summarize what changed, why, correction availability, safe fallback, and undo status where supported.",
                    icon: "doc.text.magnifyingglass",
                    valueLabel: "\(projection.displaySummaries(limit: 3).count) policy examples"
                ),
                SettingsItem(
                    id: "you-receipts-ledger",
                    title: "Recent Event Ledger",
                    subtitle: "Recent ledger entries remain local evidence. This page shows counts and status rather than raw logs.",
                    icon: "clock",
                    valueLabel: snapshot.eventLedger.isEmpty ? "No recent events" : "\(snapshot.eventLedger.count) recent"
                ),
                SettingsItem(
                    id: "you-receipts-memory",
                    title: "Memory receipts",
                    subtitle: "Why remembered this should cite source, freshness, use, privacy posture, and correction or delete availability before memory is reused.",
                    icon: "brain.head.profile",
                    valueLabel: snapshot.teachingSignals.isEmpty ? "Evidence-light" : "Why remembered"
                ),
                SettingsItem(
                    id: "you-receipts-review",
                    title: "Reviews v1",
                    subtitle: "Recovery Review and Life OS Receipt summarize local events, receipts, proof, and corrections without creating a separate top-level destination.",
                    icon: "rectangle.stack.badge.play",
                    valueLabel: snapshot.eventLedger.isEmpty ? "Nothing to review yet" : "Ready to review"
                )
            ],
            footer: "Receipts are exposed here as trust posture, not as a full history browser."
        )
    }

}
