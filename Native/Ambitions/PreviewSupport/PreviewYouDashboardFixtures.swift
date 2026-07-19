import AmbitionsDesignSystem
import Foundation

extension PreviewFixtures {
    static let defaultYouDashboard = YouDashboard(
        hero: YouHeroState(
            title: "Preview User's system",
            subtitle: "Configuration, trust, and optional personalization stay calm and explicit here.",
            dominantTruth: "Appearance is curated, trust is local-first, and optional context remains inspectable.",
            supportingTruth: "System configuration stays separate from workflow. Optional context stays inspectable, local-first, and reversible.",
            trustWhisper: "Current trust posture: Ambitions is running in explicit local-only mode. Notifications are not requested for local reminders.",
            status: .selected,
            pills: [
                YouStatusPill(id: "you-pill-appearance", title: "System mode with Sage", icon: "paintpalette", state: .selected),
                YouStatusPill(id: "you-pill-sync", title: "Ambitions is running in explicit local-only mode.", icon: "lock.shield", state: .selected),
                YouStatusPill(id: "you-pill-context", title: "6 context signals on device", icon: "waveform.path.ecg", state: .default)
            ],
            stats: [
                MetricSummary(id: "you-1", title: "Open goals", value: "3", detail: "In active review", icon: "target"),
                MetricSummary(id: "you-2", title: "Tracked rituals", value: "6", detail: "Current set", icon: "repeat"),
                MetricSummary(id: "you-3", title: "Review cadence", value: "Weekly", detail: "Sunday reset", icon: "calendar"),
                MetricSummary(id: "you-4", title: "Context signals", value: "6", detail: "Evidence, feedback, and teaching", icon: "sparkles")
            ]
        ),
        systemCenter: YouSystemCenterState(
            title: "You",
            subtitle: "Your settings, memory, and trust controls.",
            sections: [
                YouSystemCenterSection(
                    id: "me",
                    title: "Me",
                    footer: nil,
                    items: [
                        YouSystemCenterItem(id: "you", title: "User System Profile", subtitle: "Name and default landing tab.", icon: "person.crop.circle", statusLabel: "Local", semanticState: .neutral, accessibilityHint: "Opens User System Profile settings."),
                        YouSystemCenterItem(id: "personalization", title: "Personalization", subtitle: "Tone and planning defaults.", icon: "slider.horizontal.3", statusLabel: "Defaults", semanticState: .trust, accessibilityHint: "Opens personalization settings."),
                        YouSystemCenterItem(id: "appearance", title: "Appearance", subtitle: "Mode and accent.", icon: "paintpalette", statusLabel: "System", semanticState: .success, accessibilityHint: "Opens Appearance Studio.")
                    ]
                ),
                YouSystemCenterSection(
                    id: "memory-and-trust",
                    title: "Memory and Trust",
                    footer: nil,
                    items: [
                        YouSystemCenterItem(id: "what-ambitions-knows", title: "What Ambitions Knows", subtitle: "Saved local context.", icon: "brain.head.profile", statusLabel: "Local", semanticState: .trust, accessibilityHint: "Opens local memory controls."),
                        YouSystemCenterItem(id: "trust-center", title: "Trust Center", subtitle: "Permissions, privacy, and boundaries.", icon: "checkmark.shield", statusLabel: "Review", semanticState: .trust, accessibilityHint: "Opens Trust Center."),
                        YouSystemCenterItem(id: "receipts-history", title: "Receipts & History", subtitle: "What changed and why.", icon: "doc.text.magnifyingglass", statusLabel: "Local", semanticState: .neutral, accessibilityHint: "Opens receipt history."),
                        YouSystemCenterItem(id: "corrections", title: "Corrections", subtitle: "Fix assumptions and teaching signals.", icon: "checkmark.bubble", statusLabel: "Ready", semanticState: .caution, accessibilityHint: "Opens corrections.")
                    ]
                ),
                YouSystemCenterSection(
                    id: "reviews-and-progress",
                    title: "Reviews and Progress",
                    footer: nil,
                    items: [
                        YouSystemCenterItem(id: "reviews", title: "Reviews", subtitle: "Recovery and progress check-ins.", icon: "rectangle.stack.badge.play", statusLabel: "Review", semanticState: .review, accessibilityHint: "Opens Reviews."),
                        YouSystemCenterItem(id: "proof", title: "Proof", subtitle: "Evidence and progress notes.", icon: "checkmark.seal", statusLabel: "Local", semanticState: .success, accessibilityHint: "Opens proof summary."),
                        YouSystemCenterItem(id: "archive-completed", title: "Archive / Completed", subtitle: "Saved learning from finished work.", icon: "archivebox", statusLabel: "Saved", semanticState: .neutral, accessibilityHint: "Opens archive summary.")
                    ]
                ),
                YouSystemCenterSection(
                    id: "system-edges",
                    title: "System Edges",
                    footer: nil,
                    items: [
                        YouSystemCenterItem(id: "notifications", title: "Notifications", subtitle: "Reminder permission.", icon: "bell.badge", statusLabel: "Not requested", semanticState: .neutral, accessibilityHint: "Opens notification settings."),
                        YouSystemCenterItem(id: "integrations", title: "Integrations", subtitle: "Calendar and reminders.", icon: "rectangle.connected.to.line.below", statusLabel: "Not requested", semanticState: .calendarDerived, accessibilityHint: "Opens integrations."),
                        YouSystemCenterItem(id: "widgets-live-activities-shortcuts", title: "Widgets / Live Activities / Shortcuts", subtitle: "External surface status.", icon: "square.grid.2x2", statusLabel: "Bounded", semanticState: .neutral, accessibilityHint: "Opens external surface status."),
                        YouSystemCenterItem(id: "export-import", title: "Export / Import", subtitle: "Local backup and restore posture.", icon: "externaldrive", statusLabel: "Manual", semanticState: .caution, accessibilityHint: "Opens export and import status.")
                    ]
                ),
                YouSystemCenterSection(
                    id: "accessibility-and-support",
                    title: "Accessibility and Support",
                    footer: "Rows open details; nothing here changes plans silently.",
                    items: [
                        YouSystemCenterItem(id: "accessibility", title: "Accessibility", subtitle: "Claims and manual review status.", icon: "figure", statusLabel: "Locked", semanticState: .accessibilityUnverified, accessibilityHint: "Opens accessibility status."),
                        YouSystemCenterItem(id: "help-support", title: "Help / Support", subtitle: "Guidance and support posture.", icon: "questionmark.circle", statusLabel: "Guide", semanticState: .neutral, accessibilityHint: "Opens help and support."),
                        YouSystemCenterItem(id: "about", title: "About", subtitle: "Local-first app status.", icon: "info.circle", statusLabel: "Local", semanticState: .neutral, accessibilityHint: "Opens about Ambitions.")
                    ]
                )
            ],
            footer: "You keeps settings, history, trust, and controls together."
        ),
        controlRoom: YouControlRoomState(
            title: "Profile map",
            subtitle: "A short map of the trust areas you can inspect from the User System Profile.",
            entries: [
                YouControlRoomEntry(id: "you-control-constitution", title: "Personal Operating Constitution", subtitle: "Recommendation posture, recovery tone, planning strictness, and confirmation rules.", icon: "scroll", statusLabel: "Local defaults", state: .selected),
                YouControlRoomEntry(id: "you-control-memory", title: "What Ambitions Knows", subtitle: "Local evidence, feedback, corrections, captures, and event history Ambitions can explain and let you correct.", icon: "brain.head.profile", statusLabel: "Stored on this device", state: .default),
                YouControlRoomEntry(id: "you-control-corrections", title: "Corrections and assumptions", subtitle: "Assumptions can be corrected through existing teaching and explanation paths.", icon: "checkmark.bubble", statusLabel: "2 active", state: .success),
                YouControlRoomEntry(id: "you-control-receipts", title: "Receipts and audit posture", subtitle: "Reviews turns local receipts, recovery, proof, and corrections into a calm receipt layer.", icon: "doc.text.magnifyingglass", statusLabel: "Ready to review", state: .default)
            ],
            footer: "Open details from their owning surfaces for deep review. You stays oriented around trust, control, and current status."
        ),
        constitution: YouConstitutionState(
            title: "Personal Operating Constitution",
            subtitle: "The local rules Ambitions uses to stay useful without becoming pushy or silent.",
            postureSummary: "Calm, conservative, correction-aware, and local-first by default.",
            rules: [
                YouConstitutionRule(id: "constitution-local-first", title: "Start from local truth", detail: "Goals, captures, evidence, corrections, and recent ledger events are read from this device. Sync is not currently connected.", statusLabel: "Stored on this device", state: .selected),
                YouConstitutionRule(id: "constitution-recovery-tone", title: "Recover without shame", detail: "Delays, skips, and smaller-version requests are treated as recovery context, not blame.", statusLabel: "Calm recovery", state: .success),
                YouConstitutionRule(id: "constitution-low-risk-preferences", title: "Make low-risk preferences visible", detail: "Display, density, recovery, and repeated routing preferences may be remembered only when they stay visible, source-tied, and correctable.", statusLabel: "Receipt first", state: .default),
                YouConstitutionRule(id: "constitution-sensitive-memory", title: "Ask before sensitive memory", detail: "Health, relationship, financial, location, calendar-derived, and sensitive Life Area context requires user review before stronger memory use.", statusLabel: "Approval required", state: .warning),
                YouConstitutionRule(id: "constitution-operating-manual-evidence", title: "Do not invent an operating manual", detail: "The personal operating manual can summarize explicit local choices and evidence, but it must admit when context is thin.", statusLabel: "Evidence-led", state: .success),
                YouConstitutionRule(id: "constitution-calendar", title: "Ask before calendar writes", detail: "Calendar access is explicit and Time-owned. Calendar writes require confirmation and are never silent.", statusLabel: "Not requested", state: .warning)
            ],
            footer: "These are current local defaults, not a broad account/preferences system. Deeper Constitution maturity remains future-owned."
        ),
        memoryControls: YouMemoryControlState(
            title: "What Ambitions Knows",
            subtitle: "Local memory areas Ambitions can use, what each one is for, and where you can correct it.",
            items: [
                SettingsItem(id: "you-memory-ledger", title: "Event Ledger", subtitle: "Recent meaningful actions and changes can support explanations. Full raw history stays off this top-level surface.", icon: "list.bullet.rectangle", valueLabel: "2 recent"),
                SettingsItem(id: "you-memory-evidence", title: "Proof and feedback", subtitle: "Progress evidence and feedback help Ambitions avoid relying only on intention.", icon: "checkmark.seal", valueLabel: "4 local"),
                SettingsItem(id: "you-memory-corrections", title: "Corrections and teaching", subtitle: "User-confirmed corrections can adjust future explanations where existing teaching signals support it.", icon: "slider.horizontal.3", valueLabel: "2 local"),
                SettingsItem(id: "you-memory-forget", title: "Forget or clear memory", subtitle: "Destructive memory deletion is not exposed here because safe review, confirmation, and undo coverage are not complete.", icon: "trash.slash", valueLabel: "Unavailable"),
                SettingsItem(id: "you-memory-rejected", title: "Rejected memory", subtitle: "Rejected learning stays reviewable and source-tied here; durable rejection rules wait for receipt-backed correction and delete coverage.", icon: "xmark.seal", valueLabel: "Review first")
            ],
            consent: YouPersonalizationConsentState(
                title: "Personalization consent",
                summary: "Ambitions can use current local memory to explain and suggest, but stronger memory changes stay reviewable.",
                sourceLabel: "Based on local records",
                sensitiveMemoryLabel: "Sensitive memory requires approval",
                hiddenMemoryLabel: "No hidden memory creation",
                controlLabel: "You are in control"
            ),
            privateModeControls: [
                YouPrivateModeControl(id: "private-mode-compact-detail", title: "Compact private detail", summary: "Proof, feedback, and narrative memory stay summarized before any detailed review.", statusLabel: "Summaries first", privacyLabel: "Detail hidden", controlLabel: "Open owning surface", state: .success),
                YouPrivateModeControl(id: "private-mode-external-surfaces", title: "External surfaces", summary: "Widgets, Live Activities, Shortcuts, and Share Extension must use privacy snapshots or fallback routes.", statusLabel: "Protected", privacyLabel: "Snapshot-safe", controlLabel: "No raw memory", state: .warning),
                YouPrivateModeControl(id: "private-mode-sensitive-memory", title: "Sensitive memory", summary: "Sensitive categories are not inferred here and require explicit approval before stronger use.", statusLabel: "Approval required", privacyLabel: "No sensitive inference", controlLabel: "Review first", state: .warning),
                YouPrivateModeControl(id: "private-mode-destructive-controls", title: "Destructive controls", summary: "Forget, delete, and broad pause remain blocked until confirmation, receipt, and undo coverage are proven.", statusLabel: "Future-owned", privacyLabel: "No silent deletion", controlLabel: "Blocked safely", state: .warning)
            ],
            groups: [
                YouMemoryGroup(
                    id: "memory-group-current",
                    title: "Current local memory",
                    subtitle: "Used only from local Ambitions records available in this runtime.",
                    footer: "Current does not mean permanent. It means the source is active in the local app right now.",
                    items: [
                        YouMemoryItem(
                            id: "memory-item-ledger",
                            title: "Recent actions and changes",
                            detail: "2 recent local events are available for explanation and review context.",
                            sourceLabel: "Event Ledger",
                            freshness: .current,
                            usedFor: "Used for Why Changed, reviews, recovery summaries, and receipt context.",
                            privacyLabel: "Private by default",
                            actions: [
                                YouMemoryAction(id: "inspect-ledger", title: "Inspect", statusLabel: "Available", detail: "Review happens through receipts, reviews, and owning surfaces.", state: .success),
                                YouMemoryAction(id: "delete-ledger", title: "Delete", statusLabel: "Not exposed", detail: "Raw destructive deletion waits for a safe confirmation and undo boundary.", state: .warning)
                            ],
                            accessibilityLabel: "Recent actions and changes memory",
                            accessibilityValue: "Current. Private by default.",
                            accessibilityHint: "Shows what the event ledger is used for and why deletion is not exposed here."
                        ),
                        YouMemoryItem(
                            id: "memory-item-proof-feedback",
                            title: "Proof and feedback",
                            detail: "4 proof or feedback records can ground progress and review language.",
                            sourceLabel: "Proof and feedback",
                            freshness: .current,
                            usedFor: "Used for progress summaries, review receipts, and avoiding intention-only recommendations.",
                            privacyLabel: "Detail hidden in compact views",
                            actions: [
                                YouMemoryAction(id: "update-proof", title: "Update this", statusLabel: "Use owning surface", detail: "Proof and feedback stay corrected from Goal Detail, Capture, or Review context.", state: .default),
                                YouMemoryAction(id: "pause-proof", title: "Pause use", statusLabel: "Review later", detail: "Pause is represented as a review need here until a safe preference exists.", state: .warning)
                            ],
                            accessibilityLabel: "Proof and feedback memory",
                            accessibilityValue: "Current. Detail hidden in compact views.",
                            accessibilityHint: "Shows what proof and feedback memory is used for and where it can be corrected."
                        )
                    ]
                ),
                YouMemoryGroup(
                    id: "memory-group-corrections",
                    title: "Corrections and review signals",
                    subtitle: "User-corrected context is kept explicit and source-tied.",
                    footer: "No sensitive identity categories are inferred here.",
                    items: [
                        YouMemoryItem(
                            id: "memory-item-corrections",
                            title: "Corrections and teaching",
                            detail: "2 local teaching signals can influence future explanation language.",
                            sourceLabel: "Manual corrections",
                            freshness: .current,
                            usedFor: "Used for Why Changed, lighter-version preferences, and future recommendations that cite local evidence.",
                            privacyLabel: "Correctable",
                            actions: [
                                YouMemoryAction(id: "correct-teaching", title: "Correct", statusLabel: "Available", detail: "Corrections stay tied to existing teaching and explanation paths.", state: .success),
                                YouMemoryAction(id: "reject-teaching", title: "Reject reuse", statusLabel: "Review first", detail: "Rejected correction memory is treated as a review need until receipt-backed rejection and delete coverage are proven.", state: .warning),
                                YouMemoryAction(id: "delete-teaching", title: "Delete", statusLabel: "Needs confirmation", detail: "Deletion is not claimed until safe review, confirmation, and undo coverage exist.", state: .warning)
                            ],
                            accessibilityLabel: "Corrections and teaching memory",
                            accessibilityValue: "Current. Correctable.",
                            accessibilityHint: "Shows how corrections affect future explanations and why deletion requires confirmation."
                        )
                    ]
                )
            ],
            narrativeMemories: [
                YouNarrativeMemory(
                    id: "narrative-memory-corrections",
                    title: "You corrected how Ambitions reads something",
                    summary: "2 manual corrections can change future explanation language where the original artifact still exists.",
                    sourceLabel: "Manual corrections",
                    freshness: .current,
                    usedFor: "Used for Why Changed, recommendation wording, and future review prompts that cite the correction.",
                    sensitiveStatusLabel: "No sensitive inference",
                    actions: [
                        YouMemoryAction(id: "narrative-correct", title: "Correct", statusLabel: "Use owning surface", detail: "Goal Detail, Capture, and explanation controls remain the supported correction paths.", state: .success),
                        YouMemoryAction(id: "narrative-reject", title: "Reject reuse", statusLabel: "Review first", detail: "Rejection is not durable memory behavior here; it is a safe review boundary until receipts and delete coverage exist.", state: .warning),
                        YouMemoryAction(id: "narrative-delete", title: "Delete", statusLabel: "Needs confirmation", detail: "Deletion is not claimed until safe review, confirmation, and undo coverage exist.", state: .warning),
                        YouMemoryAction(id: "narrative-pause", title: "Pause use", statusLabel: "Review later", detail: "Pause is shown as a review need until a safe preference exists.", state: .warning)
                    ],
                    accessibilityLabel: "Narrative memory from corrections",
                    accessibilityValue: "Current. Manual corrections. Sensitive categories are not inferred.",
                    accessibilityHint: "Shows what this narrative memory uses and which correction, delete, and pause controls are safe or blocked."
                )
            ],
            conservativePatterns: [
                YouMemoryPattern(
                    id: "memory-pattern-corrections",
                    title: "Correction-shaped learning",
                    summary: "Only user-confirmed correction signals are treated as learning here.",
                    sourceLabel: "2 manual",
                    reviewLabel: "Review before reuse",
                    state: .success
                )
            ],
            memoryLensItems: [
                YouMemoryLensItem(
                    id: "memory-lens-current-plan",
                    title: "Current plan context",
                    summary: "4 proof or feedback records can ground plan recall.",
                    sourceLabel: "Current plan",
                    sourceAgeLabel: "Current",
                    whyRemembered: "Why remembered: current goals, proof, and feedback help recall return to Plan or Goal Detail instead of inventing a second history.",
                    privacyShutterLabel: "Summary only",
                    reviewLabel: "Safe for context recall",
                    correctionLabel: "Correct in owning surface",
                    rejectionLabel: "No durable memory claim",
                    state: .success,
                    accessibilityLabel: "Search current plan context",
                    accessibilityValue: "Current. Summary only.",
                    accessibilityHint: "Shows source age, why remembered, privacy boundary, and correction posture for current plan recall."
                ),
                YouMemoryLensItem(
                    id: "memory-lens-corrections",
                    title: "Correction memory",
                    summary: "2 user-confirmed corrections can shape future explanation language.",
                    sourceLabel: "Manual corrections",
                    sourceAgeLabel: "Current",
                    whyRemembered: "Why remembered: user corrections can prevent repeated bad assumptions, but reuse stays reviewable.",
                    privacyShutterLabel: "No sensitive inference",
                    reviewLabel: "Review before durable memory",
                    correctionLabel: "Correct or reject reuse",
                    rejectionLabel: "Deletion waits for receipt proof",
                    state: .warning,
                    accessibilityLabel: "Search correction memory",
                    accessibilityValue: "Current. Review before durable memory.",
                    accessibilityHint: "Shows correction, rejection, and deletion boundaries for correction memory."
                ),
                YouMemoryLensItem(
                    id: "memory-lens-open-captures",
                    title: "Open capture context",
                    summary: "1 open capture may need placement before it influences planning.",
                    sourceLabel: "Captured thought",
                    sourceAgeLabel: "May need review",
                    whyRemembered: "Why remembered: unresolved captures may explain what is waiting for review without becoming hidden work.",
                    privacyShutterLabel: "Stored on this device",
                    reviewLabel: "Place before stronger use",
                    correctionLabel: "Edit in Capture",
                    rejectionLabel: "Archive from Capture",
                    state: .warning,
                    accessibilityLabel: "Search open capture context",
                    accessibilityValue: "May need review. Stored on this device.",
                    accessibilityHint: "Shows source age, privacy boundary, and placement controls for open capture recall."
                )
            ],
            recoverySummary: "Memory can be reviewed and corrected from the owning surfaces. Broad delete, forget, and pause controls remain confirmation-gated or future-owned.",
            footer: "What Ambitions Knows is local, inspectable, and correctable through existing safe seams. Broad forgetting and deletion remain manual/future until the safe boundary can prove the result."
        ),
        personalVault: YouPersonalVaultState(
            title: "Personal Vault",
            subtitle: "Sensitive local signal rows keep storage, export, reset, delete, provenance, privacy, and permission labels visible without hidden inference.",
            sections: [
                YouPersonalVaultSection(
                    id: "personal-vault-signals",
                    title: "Sensitive local signals",
                    subtitle: "Visible rows stay local-first and explainable before stronger policy work lands.",
                    rows: [
                        YouPersonalVaultRow(
                            id: "personal-vault-defaults",
                            kind: .signal,
                            title: "Personal defaults",
                            summary: "Name, landing tab, appearance, and review cadence stay separate from the surfaces they influence.",
                            sourceLabel: "User System Profile",
                            storageLabel: "Stored on this device",
                            exportLabel: "Summary export only",
                            resetLabel: "Reset in You",
                            deleteLabel: "Delete requires confirmation",
                            provenanceLabel: "Profile source state",
                            privacyPolicyLabel: "Private by default",
                            permissionLabel: "User-owned",
                            state: .selected,
                            accessibilityLabel: "Personal defaults personal vault row",
                            accessibilityValue: "Stored on this device. Summary export only. Reset in You. Delete requires confirmation. Profile source state. Private by default. User-owned.",
                            accessibilityHint: "Shows the profile defaults row and the visible storage, export, reset, delete, provenance, privacy, and permission labels."
                        ),
                        YouPersonalVaultRow(
                            id: "personal-vault-permissions",
                            kind: .permission,
                            title: "Permission matrix",
                            summary: "Notifications, calendar, export, and destructive delete stay explicit instead of implied.",
                            sourceLabel: "Trust Center",
                            storageLabel: "Status stored locally",
                            exportLabel: "Export status only",
                            resetLabel: "Revoke or re-request in system settings",
                            deleteLabel: "Delete remains confirmation-gated",
                            provenanceLabel: "System authorization state",
                            privacyPolicyLabel: "No silent writes",
                            permissionLabel: "Permission-gated",
                            state: .selected,
                            accessibilityLabel: "Permission matrix personal vault row",
                            accessibilityValue: "Status stored locally. Export status only. Revoke or re-request in system settings. Delete remains confirmation-gated. System authorization state. No silent writes. Permission-gated.",
                            accessibilityHint: "Shows the permission matrix row and its local-first trust boundary."
                        )
                    ]
                ),
                YouPersonalVaultSection(
                    id: "personal-vault-proofs",
                    title: "Proof and storage",
                    subtitle: "Export and storage boundaries stay visible until stronger proof work lands.",
                    rows: [
                        YouPersonalVaultRow(
                            id: "personal-vault-proof",
                            kind: .signal,
                            title: "Proof and receipts",
                            summary: "Receipt summaries stay visible without exposing raw logs by default.",
                            sourceLabel: "Receipts and History",
                            storageLabel: "Stored on this device",
                            exportLabel: "Summary export only",
                            resetLabel: "Reset in Receipts",
                            deleteLabel: "Delete requires confirmation",
                            provenanceLabel: "Receipt-backed provenance",
                            privacyPolicyLabel: "Summaries first",
                            permissionLabel: "Inspect in Trust Center",
                            state: .selected,
                            accessibilityLabel: "Proof and receipts personal vault row",
                            accessibilityValue: "Stored on this device. Summary export only. Reset in Receipts. Delete requires confirmation. Receipt-backed provenance. Summaries first. Inspect in Trust Center.",
                            accessibilityHint: "Shows the proof and receipt row and the local boundaries around export, reset, and delete."
                        ),
                        YouPersonalVaultRow(
                            id: "personal-vault-storage",
                            kind: .permission,
                            title: "Protected storage boundary",
                            summary: "On-device storage is active, but protected-storage proof and broader export claims remain unverified.",
                            sourceLabel: "AppStateSnapshot",
                            storageLabel: "Local-only",
                            exportLabel: "Portable snapshot pending proof",
                            resetLabel: "Reset on device",
                            deleteLabel: "Delete requires confirmation",
                            provenanceLabel: "SourceRecord / Receipt",
                            privacyPolicyLabel: "No silent retention or export",
                            permissionLabel: "Future-owned",
                            state: .warning,
                            accessibilityLabel: "Protected storage boundary personal vault row",
                            accessibilityValue: "Local-only. Portable snapshot pending proof. Reset on device. Delete requires confirmation. SourceRecord / Receipt. No silent retention or export. Future-owned.",
                            accessibilityHint: "Shows the storage boundary row and the current proof gap around protected storage."
                        )
                    ]
                )
            ],
            footer: "Personal Vault stays local-first, inspectable, and explicit about what is not complete yet. Protected-storage proof, privacy review, and release claims remain unverified here."
        ),
        assumptionCorrections: YouAssumptionCorrectionState(
            title: "Corrections and assumptions",
            subtitle: "Ambitions should be teachable without asking you to understand its internals.",
            items: [
                SettingsItem(id: "you-correction-active", title: "Active corrections", subtitle: "Existing teaching signals are the current correction path.", icon: "checkmark.bubble", valueLabel: "2 active"),
                SettingsItem(id: "you-correction-availability", title: "You can correct this", subtitle: "Goal Detail explanations and existing teaching flows remain the supported place to correct assumptions.", icon: "pencil.and.list.clipboard", valueLabel: "Supported where shown")
            ],
            footer: "This is a foundation layer, not a second memory model or a full Correction Review."
        ),
        automationBoundary: YouAutomationBoundaryState(
            title: "What Ambitions will not do silently",
            subtitle: "The safe automation policy keeps external, broad, destructive, and unsupported changes confirmation-gated or blocked.",
            rules: [
                YouConstitutionRule(id: "automation-calendar", title: "No silent calendar changes", detail: "Calendar changes need explicit confirmation.", statusLabel: "Requires confirmation", state: .warning),
                YouConstitutionRule(id: "automation-reflow", title: "No silent broad reflow", detail: "This would change more than one part of the plan.", statusLabel: "Requires confirmation", state: .warning),
                YouConstitutionRule(id: "automation-memory", title: "No unsupported forgetting", detail: "No memory was forgotten.", statusLabel: "Blocked safely", state: .warning)
            ],
            footer: "This describes policy decisions only. It does not execute calendar writes, sync resolution, deletion, or undo."
        ),
        receiptAudit: YouReceiptAuditState(
            title: "Receipts and audit posture",
            subtitle: "A compact trust summary of what can explain actions today. Reviews now turns these signals into a calm receipt layer.",
            items: [
                SettingsItem(id: "you-receipts-domain", title: "Receipts", subtitle: "Receipts can summarize what changed, why, correction availability, safe fallback, and undo status where supported.", icon: "doc.text.magnifyingglass", valueLabel: "3 policy examples"),
                SettingsItem(id: "you-receipts-memory", title: "Memory receipts", subtitle: "Why remembered this should cite source, freshness, use, privacy posture, and correction or delete availability before memory is reused.", icon: "brain.head.profile", valueLabel: "Why remembered"),
                SettingsItem(id: "you-receipts-review", title: "Reviews", subtitle: "Recovery Review and Life OS Receipt summarize local events, receipts, proof, and corrections without creating a separate top-level destination.", icon: "rectangle.stack.badge.play", valueLabel: "Ready to review")
            ],
            footer: "Receipts are exposed here as trust posture, not as a full history browser."
        ),
        reviews: YouReviewsState(
            projection: ReviewsV1Projector().project(
                ReviewsV1ProjectionInput(
                    generatedAt: "2026-04-27T12:00:00Z",
                    timeframeLabel: "Recent local review",
                    eventLedgerEntries: [
                        EventLedgerEntry(
                            id: "preview-review-completed",
                            kind: .actionCompleted,
                            occurredAt: "2026-04-27T11:00:00Z",
                            source: .today,
                            title: "Completed deep work block",
                            summary: "A meaningful action closed with local proof.",
                            tone: .positive
                        ),
                        EventLedgerEntry(
                            id: "preview-review-recovery",
                            kind: .recoveryAccepted,
                            occurredAt: "2026-04-27T10:00:00Z",
                            source: .plan,
                            title: "Recovery path accepted",
                            summary: "A smaller next step was selected without changing Calendar.",
                            tone: .recovering
                        )
                    ],
                    proofEvidence: [
                        ProgressEvidence(
                            id: "preview-proof-review",
                            goalID: "goal-native",
                            stepID: "step-native",
                            evidenceKind: .stepCompleted,
                            source: .manual,
                            capturedAt: "2026-04-27T11:02:00Z",
                            progressDelta: nil,
                            confidenceDelta: nil,
                            minutesInvested: 45,
                            note: "Validated the review surface copy."
                        )
                    ],
                    calendarStatusLabel: "Not requested"
                )
            ),
            title: "Reviews",
            subtitle: "Recovery Review and Life OS Receipt for what happened, what changed, and what should carry forward.",
            footer: "Reviews uses existing local ledgers, receipts, proof, and correction signals. It does not restore Insights as a tab or claim live sync, account systems, or verified accessibility."
        ),
        appearanceStudio: YouAppearanceStudioState(
            title: "Appearance Studio",
            subtitle: "Curated, authored control over mode and accent so the shell stays legible without turning into a palette catalog.",
            previewSummary: "Preview the current palette against real Ambitions objects before you save.",
            modeOptions: [
                YouAppearanceOption(id: "appearance-system", title: "System", subtitle: "Follow the device while keeping Ambitions hierarchy intact.", preference: .system),
                YouAppearanceOption(id: "appearance-light", title: "Light", subtitle: "Use the warm light palette full time.", preference: .light),
                YouAppearanceOption(id: "appearance-dark", title: "Dark", subtitle: "Use the flagship dark palette full time.", preference: .dark)
            ],
            accentOptions: [
                YouAccentOption(id: "accent-sage", title: "Sage", subtitle: "Quiet, grounded, and balanced.", family: .sage),
                YouAccentOption(id: "accent-blue-gray", title: "Blue Gray", subtitle: "Cooler and architectural.", family: .blueGray),
                YouAccentOption(id: "accent-muted-gold", title: "Muted Gold", subtitle: "Warm emphasis with restrained glow.", family: .mutedGold),
                YouAccentOption(id: "accent-copper", title: "Copper", subtitle: "Richer warmth for stronger highlights.", family: .copper),
                YouAccentOption(id: "accent-sand", title: "Sand", subtitle: "Soft neutral warmth with gentle contrast.", family: .sand)
            ],
            previewSwatches: [
                YouPreviewSwatch(id: "preview-now", title: "Start Here", subtitle: "Primary decision surface with one calm action and source proof.", eyebrow: "Decision", objectKind: .startHere, accentFamily: .sage, appearancePreference: .system, state: .selected, accessibilityLabel: "Appearance preview for Start Here decision surface"),
                YouPreviewSwatch(id: "preview-rail", title: "Reality Meridian", subtitle: "Now, Next, and Later stay readable without status clutter.", eyebrow: "Continuity", objectKind: .realityRail, accentFamily: .sage, appearancePreference: .system, state: .default, accessibilityLabel: "Appearance preview for Reality Meridian continuity spine"),
                YouPreviewSwatch(id: "preview-lifeshape", title: "Life Calendar", subtitle: "Capacity contour keeps pressure visible without becoming a calendar.", eyebrow: "Capacity", objectKind: .lifeShape, accentFamily: .sage, appearancePreference: .system, state: .default, accessibilityLabel: "Appearance preview for Life Calendar capacity contour"),
                YouPreviewSwatch(id: "preview-receipt", title: "Receipt Drawer", subtitle: "Proof and source folds keep trust quieter than primary action.", eyebrow: "Proof", objectKind: .receiptDrawer, accentFamily: .sage, appearancePreference: .system, state: .default, accessibilityLabel: "Appearance preview for Receipt Drawer trust layer")
            ],
            footer: "Appearance changes use the existing shared theme system. Save keeps the choice for the next launch; leaving without saving preserves the current persisted default."
        ),
        trustCenter: YouTrustCenterState(
            title: "Trust Center",
            subtitle: "Trust should read as configuration truth, not a debug console. The pulse below stays calm and human-readable.",
            pulse: YouTrustPulseState(
                title: "Sync pulse",
                subtitle: "Local-first and stable",
                detail: "Portable continuity stays explicit and local-first in this build. Future cloud or continuity productization remains deferred.",
                state: .selected
            ),
            items: [
                SettingsItem(id: "you-trust-sync", title: "System trust posture", subtitle: "The current runtime runs from on-device storage, portable backup/restore, and no implied live cloud backend.", icon: "lock.shield", valueLabel: "Ambitions is running in explicit local-only mode."),
                SettingsItem(id: "you-trust-notifications", title: "Notification pulse", subtitle: "Local reminder scheduling exists on the current runtime. Authorization stays explicit here so ambient trust never feels hidden.", icon: "bell.badge", valueLabel: "Not requested"),
                SettingsItem(id: "you-trust-routing", title: "System status", subtitle: "\(ExternalSurfaceTruth.verifiedRoutingTruth). External routes stay on canonical destinations, and ambient surfaces preserve local-first continuity language.", icon: "arrow.triangle.branch", valueLabel: "Calm")
            ],
            dataMap: [
                YouTrustDataMapItem(id: "trust-data-map-local-context", title: "Local context", dataTypes: "Goals, captures, proof, corrections, receipts, reviews", sourceLabel: "Preview local signals", controlLabel: "Inspect and correct from owning surfaces", privacyLabel: "Private by default", statusLabel: "Stored on this device", semanticState: .trust),
                YouTrustDataMapItem(id: "trust-data-map-permissions", title: "Permission boundaries", dataTypes: "Notifications and Time-owned calendar awareness", sourceLabel: "Notifications not requested; calendar not requested", controlLabel: "System permission controls stay explicit", privacyLabel: "No silent calendar writes", statusLabel: "Permission-gated", semanticState: .calendarDerived),
                YouTrustDataMapItem(id: "trust-data-map-receipts", title: "Receipts and correction state", dataTypes: "Action receipts, undo posture, correction availability", sourceLabel: "2 receipt examples", controlLabel: "Change, correct, or review where supported", privacyLabel: "Summaries first", statusLabel: "Evidence-led", semanticState: .review),
                YouTrustDataMapItem(id: "trust-data-map-future-owned", title: "Future-owned edges", dataTypes: "Sync, export proof, destructive delete, broad memory controls", sourceLabel: "Ambitions is running in explicit local-only mode.", controlLabel: "Blocked until owner batch proves safety", privacyLabel: "No hidden account or cloud claim", statusLabel: "Future-owned", semanticState: .caution)
            ],
            sections: [
                YouTrustCenterSection(
                    id: "trust-center-status",
                    title: "Status and boundaries",
                    footer: "These rows describe current runtime truth.",
                    routes: [
                        YouTrustCenterRoute(id: "trust-route-local-data", title: "Local data status", subtitle: "Goals, captures, proof, corrections, receipts, and reviews read from this device.", icon: "internaldrive", statusLabel: "Stored on this device", semanticState: .trust, accessibilityHint: "Shows local storage trust status."),
                        YouTrustCenterRoute(id: "trust-route-calendar", title: "Calendar boundary", subtitle: "Calendar awareness is Time-owned. Writes require confirmation.", icon: "calendar.badge.clock", statusLabel: "Not requested", semanticState: .calendarDerived, accessibilityHint: "Shows calendar permission and write boundary."),
                        YouTrustCenterRoute(id: "trust-route-external-surfaces", title: "External surfaces", subtitle: "External surfaces must use privacy snapshots and fallback routes.", icon: "rectangle.3.group", statusLabel: ExternalSurfaceTruth.productizedNeedsPlatformReview, semanticState: .caution, accessibilityHint: "Shows external-surface verification status.")
                    ]
                ),
                YouTrustCenterSection(
                    id: "trust-center-receipts",
                    title: "Receipts, corrections, and explanations",
                    footer: "Receipt rows summarize policy and action history without exposing raw logs by default.",
                    routes: [
                        YouTrustCenterRoute(id: "trust-route-receipts", title: "Receipts", subtitle: "Receipts say what happened, what changed, why, and what can be corrected or undone.", icon: "doc.text.magnifyingglass", statusLabel: "3 examples", semanticState: .review, accessibilityHint: "Shows receipt history posture."),
                        YouTrustCenterRoute(id: "trust-route-corrections", title: "Correction routes", subtitle: "Supported corrections stay tied to existing Goal Detail, Capture, teaching, and explanation seams.", icon: "checkmark.bubble", statusLabel: "2 local", semanticState: .trust, accessibilityHint: "Shows correction availability."),
                        YouTrustCenterRoute(id: "trust-route-undo", title: "Undo rules", subtitle: "Local undo is shown only where safe.", icon: "arrow.uturn.backward", statusLabel: "No silent undo", semanticState: .caution, accessibilityHint: "Shows undo safety posture.")
                    ]
                ),
                YouTrustCenterSection(
                    id: "trust-center-privacy-future",
                    title: "Privacy and future-owned capabilities",
                    footer: "Unavailable states stay visible.",
                    routes: [
                        YouTrustCenterRoute(id: "trust-route-privacy", title: "Privacy defaults", subtitle: "Sensitive details should be hidden on compact and external surfaces unless the user chooses otherwise.", icon: "hand.raised", statusLabel: "Private by default", semanticState: .protected, accessibilityHint: "Shows privacy-safe display posture."),
                        YouTrustCenterRoute(id: "trust-route-sync-export", title: "Sync / Export truth", subtitle: "Sync is not connected. Export and import proof remain future-owned.", icon: "externaldrive", statusLabel: "Ambitions is running in explicit local-only mode.", semanticState: .caution, accessibilityHint: "Shows sync and export truth."),
                        YouTrustCenterRoute(id: "trust-route-accessibility-claims", title: "Accessibility claims", subtitle: "Internal evidence exists. Public claims stay locked until manual VoiceOver, Dynamic Type, Reduce Motion, contrast, and motor review is recorded.", icon: "figure", statusLabel: "Claims locked", semanticState: .accessibilityUnverified, accessibilityHint: "Shows accessibility claim status.")
                    ]
                )
            ],
            receiptSummaries: [
                ActionReceiptDisplaySummary(id: "preview-receipt-calendar", title: "Calendar write blocked", summary: "No calendar change happened because confirmation is required.", resultState: .needsConfirmation, occurredAt: "2026-04-27T12:10:00Z", sourceDomain: .time, undoAvailability: .requiresConfirmation, correctionAvailability: .availableWithReason, nextActionTitle: "Review in Time", safetyState: .confirmationRequired),
                ActionReceiptDisplaySummary(id: "preview-receipt-memory", title: "Memory deletion blocked", summary: "No memory was forgotten because safe review and undo are incomplete.", resultState: .failedSafely, occurredAt: "2026-04-27T12:09:00Z", sourceDomain: .you, undoAvailability: .unsafe, correctionAvailability: .unavailable, nextActionTitle: nil, safetyState: .safeFailure)
            ],
            footer: "This establishes the trust framing layer only. Deeper continuity and sync-trust productization remain future-owned, so this surface stays truthful about what exists today."
        ),
        contextVault: YouContextVaultState(
            title: "Context Vault",
            subtitle: "Optional personal context is inspectable here before later compliance work deepens policy and export surfaces.",
            items: [
                YouContextVaultItem(id: "you-vault-signals", title: "Signals in use", subtitle: "These are the current categories the app can already read from its native repositories.", icon: "tray.full", detail: "2 evidence records, 2 feedback events, 2 teaching signals"),
                YouContextVaultItem(id: "you-vault-planning", title: "Planning memory", subtitle: "Clarifications, blocked drafts, and open captures stay visible so future intelligence work remains auditable.", icon: "rectangle.stack.badge.person.crop", detail: "1 draft signal, 1 open capture"),
                YouContextVaultItem(id: "you-vault-identity", title: "Personal defaults", subtitle: "Name, launch defaults, and appearance stay separate from the execution surfaces they influence.", icon: "person.text.rectangle", detail: "Preview User")
            ],
            policyItems: [
                YouSignalPolicyItem(id: "you-policy-optional", title: "Optional by design", detail: "Context is there to improve fit and trust. It is not required to use the core planning system.", state: .default),
                YouSignalPolicyItem(id: "you-policy-local", title: "Local-first posture", detail: "Signals stay on device in this build and should remain inspectable before any future continuity expansion.", state: .selected),
                YouSignalPolicyItem(id: "you-policy-explicit", title: "Inspectable and understandable", detail: "The app should be able to explain what signal types exist without feeling invasive or technical.", state: .default)
            ],
            footer: "This is a foundation layer, not a second memory model or a full Correction Review."
        ),
        sourceAtlasKnowledge: makePreviewSourceAtlasKnowledgeState(),
        integrationsSection: YouSectionGroup(
            title: "Integrations and permissions",
            subtitle: "Only the system edges that materially affect trust or routing belong here.",
            items: [
                SettingsItem(id: "you-integration-notifications", title: "Notifications", subtitle: "Authorization: Not requested yet. Local reminders stay on-device and bounded to the current runtime.", icon: "bell.badge", valueLabel: "Not requested"),
                SettingsItem(id: "you-integration-reminders", title: "Reminders integration", subtitle: "Reminder write paths exist on the current EventKit seam. Authorization stays explicit so scheduling trust is legible.", icon: "checklist", valueLabel: "Not requested"),
                SettingsItem(id: "you-integration-calendar", title: "Calendar integration", subtitle: "Calendar event creation and conflict detection exist on the shared EventKit seam. Read depth depends on authorization level.", icon: "calendar.badge.clock", valueLabel: "Not requested"),
                SettingsItem(id: "you-integration-widgets", title: "Widgets and Live Activity", subtitle: "\(ExternalSurfaceTruth.productizedNeedsPlatformReview). Widgets and Live Activity read the shared external snapshot, Now State Lease, and local-first continuity posture.", icon: "rectangle.3.group", valueLabel: ExternalSurfaceTruth.productizedNeedsPlatformReview),
                SettingsItem(id: "you-integration-shortcuts", title: "Navigation shortcuts", subtitle: "\(ExternalSurfaceTruth.availableButNeedsManualVerification). App Intents stay navigation-only and keep canonical routing ownership.", icon: "sparkles.rectangle.stack", valueLabel: ExternalSurfaceTruth.availableButNeedsManualVerification),
                SettingsItem(id: "you-integration-share", title: "Share Extension", subtitle: "\(ExternalSurfaceTruth.notShippedInThisBuild). Share intake remains deferred until a dedicated extension target and handoff path exist.", icon: "square.and.arrow.up", valueLabel: ExternalSurfaceTruth.notShippedInThisBuild)
            ],
            footer: "Notification and integration status should answer whether anything important needs attention without becoming the first layer."
        ),
        defaultsSection: YouSectionGroup(
            title: "Personal defaults",
            subtitle: "These choices shape the shell, not the truth of your goals or day.",
            items: [
                SettingsItem(id: "you-default-tab", title: "Default landing tab", subtitle: "Used on the next cold launch so re-entry starts where you prefer.", icon: "square.grid.2x2", valueLabel: "Today"),
                SettingsItem(id: "you-default-review", title: "Review cadence", subtitle: "How often the app frames a planning reset using the current local planning loop.", icon: "clock.arrow.circlepath", valueLabel: "Weekly"),
                SettingsItem(id: "you-default-storage", title: "Storage mode", subtitle: "Goals, captures, evidence, and teaching signals persist through the native on-device repositories.", icon: "internaldrive", valueLabel: "Local-only")
            ],
            footer: nil
        ),
        accountSection: YouSectionGroup(
            title: "Account and billing",
            subtitle: "This build stays explicit about what is not configured yet so You never implies hidden account requirements.",
            items: [
                SettingsItem(id: "you-account-mode", title: "Account mode", subtitle: "No sign-in or cloud account is required for the current shipping native experience.", icon: "person.crop.circle", valueLabel: "On-device only"),
                SettingsItem(id: "you-account-billing", title: "Billing", subtitle: "Subscriptions, digital unlocks, and purchase flows are not active product scope in this build.", icon: "creditcard", valueLabel: "Not active")
            ],
            footer: "Future account or monetization work should land only when canon and release-compliance truth explicitly activate it."
        ),
        notificationAuthorization: YouNotificationAuthorization(
            statusLabel: "Not requested",
            detail: "Not requested yet.",
            canRequestAuthorization: true,
            actionTitle: "Enable notifications"
        ),
        preferences: YouPreferencesState(preferredTab: .today, appearancePreference: .system, accentFamily: .sage, reviewCadenceDays: 7, localOnlyModeEnabled: true)
    )
}
