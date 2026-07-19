import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedYouService {
    func makeMemoryControls(
        snapshot: Snapshot,
        personalRuntimeLearningSignals: [PersonalRuntimeLearningSignal] = []
    ) -> YouMemoryControlState {
        let correctionCount = snapshot.teachingSignals.count
        let correctionStatus = correctionCount == 0 ? "None yet" : "\(correctionCount) local"
        let openCaptures = snapshot.captures.filter { $0.status != .archived }.count
        let proofFeedbackCount = snapshot.evidence.count + snapshot.feedback.count
        let eventCount = snapshot.eventLedger.count
        let hasRecentMemory = eventCount + proofFeedbackCount + correctionCount + openCaptures > 0
        let narrativeMemories = makeNarrativeMemories(
            eventCount: eventCount,
            proofFeedbackCount: proofFeedbackCount,
            correctionCount: correctionCount,
            openCaptures: openCaptures
        )
        let conservativePatterns = makeConservativeMemoryPatterns(
            eventCount: eventCount,
            proofFeedbackCount: proofFeedbackCount,
            correctionCount: correctionCount,
            openCaptures: openCaptures
        )
        let memoryLensItems = makeMemoryLensItems(
            eventCount: eventCount,
            proofFeedbackCount: proofFeedbackCount,
            correctionCount: correctionCount,
            openCaptures: openCaptures
        )
        let runtimeInspectionItems = makeRuntimeInspectionItems(
            eventCount: eventCount,
            proofFeedbackCount: proofFeedbackCount,
            correctionCount: correctionCount,
            openCaptures: openCaptures
        )
        let personalRuntimeInspectionItems = makePersonalRuntimeLearningSignalInspectionItems(personalRuntimeLearningSignals)
        let localLearningControls = makeLocalLearningControls(
            eventCount: eventCount,
            proofFeedbackCount: proofFeedbackCount,
            correctionCount: correctionCount,
            openCaptures: openCaptures
        )
        let personalRuntimeLearningControls = makePersonalRuntimeLearningSignalControls(personalRuntimeLearningSignals)
        return YouMemoryControlState(
            title: "What Ambitions Knows",
            subtitle: "Local memory areas Ambitions can use, what each one is for, and where you can correct, reset, disable, delete, or export it.",
            items: [
                SettingsItem(
                    id: "you-memory-ledger",
                    title: "Event Ledger",
                    subtitle: "Recent meaningful actions and changes can support explanations. Full raw history stays off this top-level surface.",
                    icon: "list.bullet.rectangle",
                    valueLabel: snapshot.eventLedger.isEmpty ? "No recent events" : "\(snapshot.eventLedger.count) recent"
                ),
                SettingsItem(
                    id: "you-memory-evidence",
                    title: "Proof and feedback",
                    subtitle: "Progress evidence and feedback help Ambitions avoid relying only on intention.",
                    icon: "checkmark.seal",
                    valueLabel: "\(snapshot.evidence.count + snapshot.feedback.count) local"
                ),
                SettingsItem(
                    id: "you-memory-corrections",
                    title: "Corrections and teaching",
                    subtitle: "User-confirmed corrections can adjust future explanations where existing teaching signals support it.",
                    icon: "slider.horizontal.3",
                    valueLabel: correctionStatus
                ),
                SettingsItem(
                    id: "you-memory-captures",
                    title: "Open captures",
                    subtitle: "Unarchived captures remain visible to the local planning loop until routed or archived.",
                    icon: "tray.full",
                    valueLabel: "\(snapshot.captures.filter { $0.status != .archived }.count) open"
                ),
                SettingsItem(
                    id: "you-memory-forget",
                    title: "Forget or clear memory",
                    subtitle: "Destructive memory deletion is not exposed here because safe review, confirmation, and undo coverage are not complete.",
                    icon: "trash.slash",
                    valueLabel: "Unavailable"
                ),
                SettingsItem(
                    id: "you-memory-rejected",
                    title: "Rejected memory",
                    subtitle: "Rejected learning stays reviewable and source-tied here; durable rejection rules wait for receipt-backed correction and delete coverage.",
                    icon: "xmark.seal",
                    valueLabel: "Review first"
                )
            ],
            consent: YouPersonalizationConsentState(
                title: "Personalization consent",
                summary: "Ambitions can use current local memory to explain and suggest, but stronger memory changes stay reviewable, resettable, and receipt-aware.",
                sourceLabel: "Based on local records",
                sensitiveMemoryLabel: "Sensitive memory requires approval",
                hiddenMemoryLabel: "No hidden memory creation",
                controlLabel: "You are in control"
            ),
            privateModeControls: [
                YouPrivateModeControl(
                    id: "private-mode-compact-detail",
                    title: "Compact private detail",
                    summary: "Proof, feedback, and narrative memory stay summarized before any detailed review.",
                    statusLabel: "Summaries first",
                    privacyLabel: "Detail hidden",
                    controlLabel: "Open owning surface",
                    state: .success
                ),
                YouPrivateModeControl(
                    id: "private-mode-external-surfaces",
                    title: "External surfaces",
                    summary: "Widgets, Live Activities, Shortcuts, and Share Extension must use privacy snapshots or fallback routes.",
                    statusLabel: "Protected",
                    privacyLabel: "Snapshot-safe",
                    controlLabel: "No raw memory",
                    state: .warning
                ),
                YouPrivateModeControl(
                    id: "private-mode-sensitive-memory",
                    title: "Sensitive memory",
                    summary: "Sensitive categories are not inferred here and require explicit approval before stronger use.",
                    statusLabel: "Approval required",
                    privacyLabel: "No sensitive inference",
                    controlLabel: "Review first",
                    state: .warning
                ),
                YouPrivateModeControl(
                    id: "private-mode-destructive-controls",
                    title: "Destructive controls",
                    summary: "Forget, delete, and broad pause remain blocked until confirmation, receipt, and undo coverage are proven.",
                    statusLabel: "Future-owned",
                    privacyLabel: "No silent deletion",
                    controlLabel: "Blocked safely",
                    state: .warning
                )
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
                            detail: eventCount == 0 ? "No recent local events are available yet." : "\(eventCount) recent local events are available for explanation and review context.",
                            sourceLabel: "Event Ledger",
                            freshness: eventCount == 0 ? .basedOnOlderContext : .current,
                            usedFor: "Used for Why Changed, reviews, recovery summaries, and receipt context.",
                            privacyLabel: "Private by default",
                            actions: [
                                memoryAction(id: "inspect-ledger", title: "Inspect", statusLabel: eventCount == 0 ? "Empty" : "Available", detail: "Review happens through receipts, reviews, and owning surfaces.", state: eventCount == 0 ? .default : .success),
                                memoryAction(id: "delete-ledger", title: "Delete", statusLabel: "Not exposed", detail: "Raw destructive deletion waits for a safe confirmation and undo boundary.", state: .warning)
                            ],
                            accessibilityLabel: "Recent actions and changes memory",
                            accessibilityValue: eventCount == 0 ? "Based on older context. Private by default." : "Current. Private by default.",
                            accessibilityHint: "Shows what the event ledger is used for and why deletion is not exposed here."
                        ),
                        YouMemoryItem(
                            id: "memory-item-proof-feedback",
                            title: "Proof and feedback",
                            detail: proofFeedbackCount == 0 ? "No proof or feedback records are available yet." : "\(proofFeedbackCount) proof or feedback records can ground progress and review language.",
                            sourceLabel: "Proof and feedback",
                            freshness: proofFeedbackCount == 0 ? .mayNeedReview : .current,
                            usedFor: "Used for progress summaries, review receipts, and avoiding intention-only recommendations.",
                            privacyLabel: "Detail hidden in compact views",
                            actions: [
                                memoryAction(id: "update-proof", title: "Update this", statusLabel: "Use owning surface", detail: "Proof and feedback stay corrected from Goal Detail, Capture, or Review context.", state: .default),
                                memoryAction(id: "pause-proof", title: "Pause use", statusLabel: "Review later", detail: "Pause is represented as a review need here until a safe preference exists.", state: .warning)
                            ],
                            accessibilityLabel: "Proof and feedback memory",
                            accessibilityValue: "\(proofFeedbackCount == 0 ? YouMemoryFreshness.mayNeedReview.label : YouMemoryFreshness.current.label). Detail hidden in compact views.",
                            accessibilityHint: "Shows what proof and feedback memory is used for and where it can be corrected."
                        ),
                        YouMemoryItem(
                            id: "memory-item-captures",
                            title: "Open captures",
                            detail: openCaptures == 0 ? "No open captures need placement." : "\(openCaptures) open captures may still need routing, review, or archiving.",
                            sourceLabel: "Capture",
                            freshness: openCaptures == 0 ? .current : .mayNeedReview,
                            usedFor: "Used for Needs a Place routing, planning prompts, and safe follow-up.",
                            privacyLabel: "Stored on this device",
                            actions: [
                                memoryAction(id: "edit-captures", title: "Edit", statusLabel: openCaptures == 0 ? "Nothing open" : "Available in Capture", detail: "Capture owns editing, routing, archiving, and receipts for captured items.", state: openCaptures == 0 ? .default : .success)
                            ],
                            accessibilityLabel: "Open captures memory",
                            accessibilityValue: openCaptures == 0 ? "Current. No open captures." : "May Need Review. Stored on this device.",
                            accessibilityHint: "Shows whether captures are contributing to local memory."
                        )
                    ]
                ),
                YouMemoryGroup(
                    id: "memory-group-corrections",
                    title: "Corrections and review signals",
                    subtitle: "User-corrected context is kept explicit and source-tied.",
                    footer: "No sensitive identity categories are inferred here. Correction signals stay bounded to the artifacts that created them.",
                    items: [
                        YouMemoryItem(
                            id: "memory-item-corrections",
                            title: "Corrections and teaching",
                            detail: correctionCount == 0 ? "No active teaching signals are saved yet." : "\(correctionCount) local teaching signals can influence future explanation language.",
                            sourceLabel: "Manual corrections",
                            freshness: correctionCount == 0 ? .basedOnOlderContext : .current,
                            usedFor: "Used for Why Changed, lighter-version preferences, and future recommendations that cite local evidence.",
                            privacyLabel: "Correctable",
                            actions: [
                                memoryAction(id: "correct-teaching", title: "Correct", statusLabel: correctionCount == 0 ? "Available when present" : "Available", detail: "Corrections stay tied to existing teaching and explanation paths.", state: correctionCount == 0 ? .default : .success),
                                memoryAction(id: "reject-teaching", title: "Reject reuse", statusLabel: "Review first", detail: "Rejected correction memory is treated as a review need until receipt-backed rejection and delete coverage are proven.", state: .warning),
                                memoryAction(id: "delete-teaching", title: "Delete", statusLabel: "Needs confirmation", detail: "Deletion is not claimed until safe review, confirmation, and undo coverage exist.", state: .warning)
                            ],
                            accessibilityLabel: "Corrections and teaching memory",
                            accessibilityValue: correctionCount == 0 ? "Based on Older Context. Correctable when present." : "Current. Correctable.",
                            accessibilityHint: "Shows how corrections affect future explanations and why deletion requires confirmation."
                        )
                    ]
                )
            ],
            narrativeMemories: narrativeMemories,
            conservativePatterns: conservativePatterns,
            memoryLensItems: memoryLensItems,
            runtimeInspectionItems: runtimeInspectionItems + personalRuntimeInspectionItems,
            localLearningControls: localLearningControls + personalRuntimeLearningControls,
            recoverySummary: hasRecentMemory ? "Memory can be reviewed and corrected from the owning surfaces. Broad delete, forget, and pause controls remain confirmation-gated or future-owned." : "There is little local memory yet. Ambitions should say when a recommendation is evidence-light instead of pretending it knows more.",
            footer: "What Ambitions Knows is local, inspectable, and correctable through existing safe seams. Narrative memory only appears from explicit local evidence, receipts, corrections, reviews, or confirmations; broad forgetting, deletion, and export remain confirmation-gated, export-bounded, and durable rejected-memory rules remain manual/future until the safe boundary can prove the result."
        )
    }

    func makePersonalVaultState(
        snapshot: Snapshot,
        syncStatus: SyncCapabilityStatus,
        notificationStatus: YouNotificationAuthorization,
        remindersAuthorization: CalendarRemindersAuthorizationState,
        calendarAuthorization: CalendarRemindersAuthorizationState,
        receipts: [ActionReceipt],
        memoryControls: YouMemoryControlState
    ) -> YouPersonalVaultState {
        let receiptCount = ActionReceiptProjection(receipts: receipts).displaySummaries().count
        let learningControlCount = memoryControls.localLearningControls.count
        let personalDefaultsRow = makePersonalVaultRow(
            id: "personal-vault-defaults",
            kind: .signal,
            title: "Personal defaults",
            summary: "Name, starting surface, appearance, and review cadence stay separate from the surfaces they influence.",
            sourceLabel: "User System Profile",
            storageLabel: snapshot.appState.localOnlyModeEnabled ? "Stored on this device" : "Needs review",
            exportLabel: "Summary export only",
            resetLabel: "Reset in You",
            deleteLabel: "Delete requires confirmation",
            provenanceLabel: "Personal context source",
            privacyPolicyLabel: "Private by default",
            permissionLabel: "User-owned",
            state: snapshot.appState.userDisplayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .default : .selected,
            accessibilityHint: "Shows the personal defaults row and the visible storage, export, reset, delete, provenance, privacy, and permission labels."
        )
        let learningRow = makePersonalVaultRow(
            id: "personal-vault-learning",
            kind: .signal,
            title: "Local learning signals",
            summary: memoryControls.localLearningControls.isEmpty ? "Local learning stays summary-only until the current runtime collects signals." : "\(learningControlCount) local learning controls stay reviewable in Search Ambitions.",
            sourceLabel: "Search Ambitions",
            storageLabel: "Stored on this device",
            exportLabel: "Summary plus receipt labels",
            resetLabel: "Reset in Search Ambitions",
            deleteLabel: "Delete requires confirmation",
            provenanceLabel: "Source / Receipt / Reason",
            privacyPolicyLabel: "Private by default",
            permissionLabel: "Review gated",
            state: memoryControls.localLearningControls.isEmpty ? .default : .selected,
            accessibilityHint: "Shows the learning signal row and how local learning remains inspectable without hidden inference."
        )
        let proofRow = makePersonalVaultRow(
            id: "personal-vault-proof",
            kind: .signal,
            title: "Proof and receipts",
            summary: receiptCount == 0 ? "Receipt summaries are not present yet." : "\(receiptCount) receipt summaries stay visible without exposing raw logs by default.",
            sourceLabel: "Receipts and History",
            storageLabel: "Stored on this device",
            exportLabel: "Summary export only",
            resetLabel: "Reset in Receipts",
            deleteLabel: "Delete requires confirmation",
            provenanceLabel: "Receipt-backed provenance",
            privacyPolicyLabel: "Summaries first",
            permissionLabel: "Inspect in Trust Center",
            state: receiptCount == 0 ? .default : .selected,
            accessibilityHint: "Shows the proof and receipt row and the local boundaries around export, reset, and delete."
        )
        let permissionsRow = makePersonalVaultRow(
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
            state: (notificationStatus.statusLabel == "Denied" || calendarAuthorization == .denied || remindersAuthorization == .denied || syncStatus.availability == .unavailable) ? .warning : .selected,
            accessibilityHint: "Shows the permission matrix row and its local-first trust boundary."
        )
        let storageRow = makePersonalVaultRow(
            id: "personal-vault-storage",
            kind: .permission,
            title: "Protected storage boundary",
            summary: snapshot.appState.localOnlyModeEnabled ? "On-device storage is active, but protected-storage proof and broader export claims remain unverified." : "Storage mode needs review before broader protection claims can be made.",
            sourceLabel: "AppStateSnapshot",
            storageLabel: snapshot.appState.localOnlyModeEnabled ? "Local-only" : "Needs review",
            exportLabel: "Portable snapshot pending proof",
            resetLabel: "Reset on device",
            deleteLabel: "Delete requires confirmation",
            provenanceLabel: "Source / Receipt",
            privacyPolicyLabel: "No silent retention or export",
            permissionLabel: "Future-owned",
            state: snapshot.appState.localOnlyModeEnabled ? .warning : .default,
            accessibilityHint: "Shows the storage boundary row and the current proof gap around protected storage."
        )

        return YouPersonalVaultState(
            title: "Personal Vault",
            subtitle: "Sensitive local signal rows keep storage, export, reset, delete, provenance, privacy, and permission labels visible without hidden inference.",
            sections: [
                YouPersonalVaultSection(
                    id: "personal-vault-signals",
                    title: "Sensitive local signals",
                    subtitle: "Visible rows stay local-first and explainable before stronger policy work lands.",
                    rows: [
                        personalDefaultsRow,
                        learningRow,
                        proofRow
                    ]
                ),
                YouPersonalVaultSection(
                    id: "personal-vault-permissions",
                    title: "Permissions center",
                    subtitle: "Permission rows stay explicit and reviewable instead of implied.",
                    rows: [
                        permissionsRow,
                        storageRow
                    ]
                )
            ],
            footer: "Personal Vault stays local-first, inspectable, and explicit about what is not complete yet. Protected-storage proof, privacy review, and release claims remain unverified here."
        )
    }

    func makePersonalVaultRow(
        id: String,
        kind: YouPersonalVaultRowKind,
        title: String,
        summary: String,
        sourceLabel: String,
        storageLabel: String,
        exportLabel: String,
        resetLabel: String,
        deleteLabel: String,
        provenanceLabel: String,
        privacyPolicyLabel: String,
        permissionLabel: String,
        state: AmbitionVisualState,
        accessibilityHint: String
    ) -> YouPersonalVaultRow {
        let accessibilityValue = [
            storageLabel,
            exportLabel,
            resetLabel,
            deleteLabel,
            provenanceLabel,
            privacyPolicyLabel,
            permissionLabel
        ]
        .joined(separator: ". ")

        return YouPersonalVaultRow(
            id: id,
            kind: kind,
            title: title,
            summary: summary,
            sourceLabel: sourceLabel,
            storageLabel: storageLabel,
            exportLabel: exportLabel,
            resetLabel: resetLabel,
            deleteLabel: deleteLabel,
            provenanceLabel: provenanceLabel,
            privacyPolicyLabel: privacyPolicyLabel,
            permissionLabel: permissionLabel,
            state: state,
            accessibilityLabel: "\(title) personal vault row",
            accessibilityValue: accessibilityValue,
            accessibilityHint: accessibilityHint
        )
    }

}
