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

struct CaptureCorrectionReviewState: Sendable, Equatable, Identifiable {
    let id: String
    let title: String
    let routeCorrectionLabel: String
    let notGoalLabel: String
    let notNowLabel: String
    let receiptLabel: String
    let learningBoundaryLabel: String

    var accessibilityValue: String {
        [
            routeCorrectionLabel,
            notGoalLabel,
            notNowLabel,
            receiptLabel,
            learningBoundaryLabel
        ].joined(separator: ". ")
    }
}

struct CaptureGoalSeedIncubatorState: Sendable, Equatable, Identifiable {
    let id: String
    let title: String
    let whyGoalLabel: String
    let startingPositionProofLabel: String
    let firstMilestoneAnchorLabel: String
    let firstStepLabel: String
    let proofSourceSeedLabel: String
    let promotionConfirmationLabel: String
    let state: AmbitionVisualState

    var accessibilityValue: String {
        [
            whyGoalLabel,
            startingPositionProofLabel,
            firstMilestoneAnchorLabel,
            firstStepLabel,
            proofSourceSeedLabel,
            promotionConfirmationLabel
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

    var correctionReviewState: CaptureCorrectionReviewState {
        CaptureCorrectionReviewState(
            id: "capture-correction-review-\(id)",
            title: "Correction options",
            routeCorrectionLabel: routeCorrectionLabel,
            notGoalLabel: notGoalLabel,
            notNowLabel: "Not now: Review later keeps it out of Today.",
            receiptLabel: "Correction receipt: the change you choose is reviewable.",
            learningBoundaryLabel: "Placement choices stay local and reviewable; no hidden memory changes."
        )
    }

    var goalSeedIncubatorState: CaptureGoalSeedIncubatorState {
        CaptureGoalSeedIncubatorState(
            id: "capture-goal-seed-incubator-\(id)",
            title: "Goal Seed Incubator",
            whyGoalLabel: "Why this may be a goal: the capture can be shaped, but it is not promoted yet.",
            startingPositionProofLabel: "Starting position proof: \(sourceType?.title ?? "Capture") text stays editable.",
            firstMilestoneAnchorLabel: "First milestone anchor: Create Goal will show the first bounded milestone before saving.",
            firstStepLabel: "First step: review the seed setup in Goals before promotion.",
            proofSourceSeedLabel: "Proof/source seed: the capture can stay attached after you confirm.",
            promotionConfirmationLabel: "Promotion confirmation: no Goal is created until you choose Grow into Goal and then Create Goal.",
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
        case .timeSeed:
            "Task / Plan"
        case .goalSeed:
            "Goal seed"
        case .goalAttachment:
            "Goal proof"
        case .deliverableSeed:
            "Idea"
        case .proofItem:
            "Proof"
        case .constraintItem:
            "Constraint"
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
        case .timeSeed:
            "Creates plan work only after you choose Task."
        case .goalSeed:
            "Starts a goal seed only after you choose Grow into Goal."
        case .goalAttachment:
            "Attaches as proof only after you choose a goal."
        case .deliverableSeed:
            "Keeps this as an idea without scheduling it."
        case .proofItem:
            "Preserves this as proof without changing Today."
        case .constraintItem:
            "Keeps this as a constraint Ambitions can surface for review."
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

    private var routeCorrectionLabel: String {
        switch status {
        case .archived:
            "Archived captures stay out of active correction."
        default:
            "Place somewhere else: choose Task, Goal, Waiting, Review later, or Archive."
        }
    }

    private var notGoalLabel: String {
        switch route {
        case .goalSeed, .goalAttachment:
            "Not a goal: keep it as Task, Idea, Waiting, or Review later."
        default:
            "Not a goal: no Goal is created unless you choose Grow into Goal."
        }
    }
}
