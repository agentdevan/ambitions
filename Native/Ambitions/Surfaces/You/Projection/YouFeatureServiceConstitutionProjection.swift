import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedYouService {
    func makePreviewSwatches(
        selectedAppearance: AppAppearancePreference,
        selectedAccent: AmbitionAccentFamily
    ) -> [YouPreviewSwatch] {
        [
            YouPreviewSwatch(
                id: "preview-now",
                title: "Start Here",
                subtitle: "Primary decision surface with one calm action and source proof.",
                eyebrow: "Decision",
                objectKind: .startHere,
                accentFamily: selectedAccent,
                appearancePreference: selectedAppearance,
                state: .selected,
                accessibilityLabel: "Appearance preview for Start Here decision surface"
            ),
            YouPreviewSwatch(
                id: "preview-rail",
                title: "Reality Meridian",
                subtitle: "Now, Next, and Later stay readable without status clutter.",
                eyebrow: "Continuity",
                objectKind: .realityRail,
                accentFamily: selectedAccent,
                appearancePreference: selectedAppearance,
                state: .default,
                accessibilityLabel: "Appearance preview for Reality Meridian continuity spine"
            ),
            YouPreviewSwatch(
                id: "preview-lifeshape",
                title: "LifeShape",
                subtitle: "Capacity contour keeps pressure visible without becoming a calendar.",
                eyebrow: "Capacity",
                objectKind: .lifeShape,
                accentFamily: selectedAccent,
                appearancePreference: selectedAppearance,
                state: .default,
                accessibilityLabel: "Appearance preview for LifeShape capacity contour"
            ),
            YouPreviewSwatch(
                id: "preview-receipt",
                title: "Receipt Drawer",
                subtitle: "Proof and source folds keep trust quieter than primary action.",
                eyebrow: "Proof",
                objectKind: .receiptDrawer,
                accentFamily: selectedAccent,
                appearancePreference: selectedAppearance,
                state: .default,
                accessibilityLabel: "Appearance preview for Receipt Drawer trust layer"
            )
        ]
    }

    struct SafetyBoundarySamples {
        let calendarWrite: SafeAutomationPolicyDecision
        let broadReflow: SafeAutomationPolicyDecision
        let forgetMemory: SafeAutomationPolicyDecision
        let prepareExport: SafeAutomationPolicyDecision
        let localCorrection: SafeAutomationPolicyDecision

        var confirmationRequired: Int {
            [calendarWrite, broadReflow, forgetMemory, prepareExport, localCorrection]
                .filter(\.mustNeverBeSilent)
                .count
        }

        var destructiveBlocked: Bool {
            forgetMemory.permissionLevel == .neverAutomate &&
                forgetMemory.receiptRecommendation.resultState == .failedSafely
        }
    }

    func safetyBoundarySamples() -> SafetyBoundarySamples {
        let evaluator = SafeAutomationPolicyEvaluator()
        let planBlock = LifeGraphObjectReference(kind: .action, id: "you-policy-calendar-write", sourceDomain: .time)
        let planStep = LifeGraphObjectReference(kind: .step, id: "you-policy-reflow", sourceDomain: .time)
        let memoryObject = LifeGraphObjectReference(kind: .correction, id: "you-policy-memory", sourceDomain: .you)
        let correctionObject = LifeGraphObjectReference(kind: .correction, id: "you-policy-correction", sourceDomain: .you)

        return SafetyBoundarySamples(
            calendarWrite: evaluator.evaluate(
                SafeAutomationProposedAction(kind: .writeCalendarBlock, sourceDomain: .time, targetObjects: [planBlock])
            ),
            broadReflow: evaluator.evaluate(
                SafeAutomationProposedAction(kind: .splitAction, sourceDomain: .time, targetObjects: [planStep])
            ),
            forgetMemory: evaluator.evaluate(
                SafeAutomationProposedAction(kind: .forgetMemory, sourceDomain: .you, targetObjects: [memoryObject])
            ),
            prepareExport: evaluator.evaluate(
                SafeAutomationProposedAction(kind: .prepareExport, sourceDomain: .you)
            ),
            localCorrection: evaluator.evaluate(
                SafeAutomationProposedAction(kind: .correctRecommendation, sourceDomain: .you, targetObjects: [correctionObject])
            )
        )
    }

    func makeConstitution(
        snapshot: Snapshot,
        calendarAuthorization: CalendarRemindersAuthorizationState,
        notificationStatus: YouNotificationAuthorization,
        safetySamples: SafetyBoundarySamples
    ) -> YouConstitutionState {
        YouConstitutionState(
            title: "Personal Operating Constitution",
            subtitle: "The local rules Ambitions uses to stay useful without becoming pushy or silent.",
            postureSummary: "Calm, conservative, correction-aware, and local-first by default.",
            rules: [
                YouConstitutionRule(
                    id: "constitution-local-first",
                    title: "Start from local truth",
                    detail: "Goals, captures, evidence, corrections, and recent ledger events are read from this device. Sync is not currently connected.",
                    statusLabel: "Stored on this device",
                    state: .selected
                ),
                YouConstitutionRule(
                    id: "constitution-recommendation-posture",
                    title: "Suggest one doable step",
                    detail: "Suggestions should be explainable by goal, plan, evidence, or recent feedback, not vague intelligence claims.",
                    statusLabel: snapshot.eventLedger.isEmpty ? "Evidence-light" : "Uses local evidence",
                    state: .default
                ),
                YouConstitutionRule(
                    id: "constitution-recovery-tone",
                    title: "Recover without blame",
                    detail: "Delays, skips, and smaller-version requests are treated as recovery context, not blame.",
                    statusLabel: "Calm recovery",
                    state: .success
                ),
                YouConstitutionRule(
                    id: "constitution-low-risk-preferences",
                    title: "Make low-risk preferences visible",
                    detail: "Display, density, recovery, and repeated routing preferences may be remembered only when they stay visible, source-tied, and correctable.",
                    statusLabel: "Receipt first",
                    state: .default
                ),
                YouConstitutionRule(
                    id: "constitution-sensitive-memory",
                    title: "Ask before sensitive memory",
                    detail: "Health, relationship, financial, location, calendar-derived, and sensitive Life Area context requires user review before stronger memory use.",
                    statusLabel: "Approval required",
                    state: .warning
                ),
                YouConstitutionRule(
                    id: "constitution-operating-manual-evidence",
                    title: "Do not invent an operating manual",
                    detail: "The personal operating manual can summarize explicit local choices and evidence, but it must admit when context is thin.",
                    statusLabel: snapshot.eventLedger.isEmpty && snapshot.teachingSignals.isEmpty ? "Evidence-light" : "Evidence-led",
                    state: snapshot.eventLedger.isEmpty && snapshot.teachingSignals.isEmpty ? .default : .success
                ),
                YouConstitutionRule(
                    id: "constitution-calendar",
                    title: "Ask before calendar writes",
                    detail: "Calendar access is explicit and Time-owned. Calendar writes require confirmation and are never silent.",
                    statusLabel: calendarAuthorizationLabel(calendarAuthorization),
                    state: safetySamples.calendarWrite.mustNeverBeSilent ? .warning : .default
                ),
                YouConstitutionRule(
                    id: "constitution-interruptions",
                    title: "Interruptions stay optional",
                    detail: "Notifications can support reminders, but Ambitions still works when notification access is denied or not requested.",
                    statusLabel: notificationStatus.statusLabel,
                    state: notificationStatus.canRequestAuthorization ? .default : .warning
                )
            ],
            footer: "The Constitution is a local boundary, not a sync policy."
        )
    }

}
