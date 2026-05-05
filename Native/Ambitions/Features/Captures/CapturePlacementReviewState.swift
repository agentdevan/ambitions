import AmbitionsDesignSystem

struct CapturePlacementReviewState: Sendable, Equatable, Identifiable {
    let id: String
    let title: String
    let placementStateTitle: String
    let destinationLabel: String
    let objectTypeLabel: String
    let consequenceLabel: String
    let privacyLabel: String
    let confirmationLabel: String
    let archiveLabel: String
    let state: AmbitionVisualState

    var accessibilityValue: String {
        [
            placementStateTitle,
            destinationLabel,
            objectTypeLabel,
            consequenceLabel,
            privacyLabel,
            confirmationLabel,
            archiveLabel
        ].joined(separator: ". ")
    }
}

extension Capture {
    var placementReviewState: CapturePlacementReviewState {
        CapturePlacementReviewState(
            id: "capture-placement-review-\(id)",
            title: "Captured item review",
            placementStateTitle: placementStateTitle,
            destinationLabel: placementDestinationLabel,
            objectTypeLabel: kind.title,
            consequenceLabel: placementConsequenceLabel,
            privacyLabel: placementPrivacyLabel,
            confirmationLabel: placementConfirmationLabel,
            archiveLabel: "Archive keeps it out of active review.",
            state: placementVisualState
        )
    }

    private var placementStateTitle: String {
        switch status {
        case .needsTriage, .actionable:
            route == .captureInbox ? "Needs a Place" : "Ready to Place"
        case .seed, .goalBound, .scheduled, .delegated, .waiting, .optionalSomeday:
            "Placed"
        case .archived:
            "Archived"
        }
    }

    private var placementDestinationLabel: String {
        switch route {
        case .captureInbox:
            "Needs a Place"
        case .planSeed:
            "Task / Plan"
        case .goalSeed:
            "Goal seed"
        case .goalAttachment:
            "Goal proof"
        case .deliverableSeed:
            "Idea"
        case .waiting:
            "Waiting"
        case .optionalSomeday:
            "Review later"
        case .archive:
            "Archive"
        }
    }

    private var placementConsequenceLabel: String {
        switch route {
        case .captureInbox:
            "Keeps this capture correctable until you choose a route."
        case .planSeed:
            "Creates plan work only after you choose Task."
        case .goalSeed:
            "Starts a goal seed only after you choose Grow into Goal."
        case .goalAttachment:
            "Attaches as proof only after you choose a goal."
        case .deliverableSeed:
            "Keeps this as an idea without scheduling it."
        case .waiting:
            "Parks this as waiting without changing Today."
        case .optionalSomeday:
            "Keeps this for later without competing with active work."
        case .archive:
            "Moves this capture out of the active list."
        }
    }

    private var placementPrivacyLabel: String {
        switch privacy {
        case .standard:
            "Stored on this device"
        case .calendarDerived:
            "Calendar-derived"
        case .sensitive, .privateUserText, .syncMetadata:
            "Private detail hidden"
        }
    }

    private var placementConfirmationLabel: String {
        switch status {
        case .archived:
            "No active placement changes are available."
        default:
            "You choose before this changes Today, Goals, or Plan."
        }
    }

    private var placementVisualState: AmbitionVisualState {
        switch status {
        case .needsTriage:
            .selected
        case .actionable, .seed:
            .default
        case .goalBound, .scheduled, .delegated:
            .success
        case .waiting:
            .warning
        case .optionalSomeday, .archived:
            .disabled
        }
    }
}
