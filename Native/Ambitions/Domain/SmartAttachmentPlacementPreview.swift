import Foundation

struct SmartAttachmentPlacementPreview: Sendable, Equatable {
    let originalText: String
    let postInputStateTitle: String
    let suggestedDestination: String
    let objectTypeLabel: String
    let appearanceLabel: String
    let consequenceLabel: String
    let affectsToday: Bool
    let privacyLabel: String
    let primaryActionTitle: String
    let changeActionTitle: String
    let safeActionTitle: String
}

extension SmartAttachmentResult {
    var placementPreview: SmartAttachmentPlacementPreview {
        let destination = selectedCandidate?.target.displaySegments.joined(separator: " · ") ?? "Needs a Place"
        let routeType = selectedCandidate?.target.routeType ?? .idea
        let appearance = selectedCandidate?.target.placementLabel ?? appearanceLabel(for: routeType)
        let affectsToday = routeType == .task && appearance.localizedCaseInsensitiveContains("Today")

        return SmartAttachmentPlacementPreview(
            originalText: input.rawText,
            postInputStateTitle: postInputStateTitle(for: routeType),
            suggestedDestination: destination,
            objectTypeLabel: objectTypeLabel(for: routeType),
            appearanceLabel: appearance,
            consequenceLabel: consequenceLabel(for: routeType, destination: destination, affectsToday: affectsToday),
            affectsToday: affectsToday,
            privacyLabel: privacyLevel.placementLabel,
            primaryActionTitle: "Place it",
            changeActionTitle: "Change",
            safeActionTitle: "Decide later"
        )
    }
}

private extension SmartAttachmentResult {
    func postInputStateTitle(for routeType: SmartAttachmentRouteType) -> String {
        switch resultState {
        case .needsClarification:
            return "Needs a Place"
        case .savedToNeedsPlace, .failedSafely:
            return "Needs a Place"
        case .savedStandalone, .attached:
            return routeType == .goal ? "Grow into Goal" : "Ready to Place"
        }
    }

    func objectTypeLabel(for routeType: SmartAttachmentRouteType) -> String {
        switch routeType {
        case .task:
            return "Task"
        case .goal:
            return "Goal seed"
        case .idea, .contextualNote:
            return savesToNeedsPlace ? "Unplaced capture" : "Idea"
        case .proofItem:
            return "Proof"
        case .waitingItem:
            return "Waiting item"
        case .plan:
            return "Plan item"
        case .reminder:
            return "Task"
        case .ritual:
            return "Ritual idea"
        case .archive:
            return "Archived capture"
        case .decision:
            return "Decision"
        }
    }

    func appearanceLabel(for routeType: SmartAttachmentRouteType) -> String {
        switch routeType {
        case .task, .reminder:
            return "Today"
        case .goal:
            return "Goals"
        case .plan:
            return "This Week"
        case .proofItem:
            return "Goal proof"
        case .waitingItem:
            return "Waiting"
        case .decision:
            return "Decisions"
        case .archive:
            return "Archive"
        case .idea, .contextualNote, .ritual:
            return savesToNeedsPlace ? "Needs a Place" : "Capture"
        }
    }

    func consequenceLabel(for routeType: SmartAttachmentRouteType, destination: String, affectsToday: Bool) -> String {
        if savesToNeedsPlace {
            return "Saved safely without forcing structure."
        }

        if affectsToday {
            return "Adds a visible Task to Today after you confirm."
        }

        switch routeType {
        case .goal:
            return "Creates a Goal seed after you confirm."
        case .proofItem:
            if goalRelevanceScan?.forcedAttachmentBlocked == true {
                return "Keeps proof local until you approve the goal attachment."
            }
            return "Attaches Proof to \(destination) after you confirm."
        case .waitingItem:
            return "Adds a Waiting item after you confirm."
        case .plan:
            return "Adds a Plan item without changing calendars."
        case .decision:
            return "Saves a Decision candidate after you confirm."
        case .archive:
            return "Moves the capture out of the active list."
        case .task, .reminder:
            return "Creates a Task after you confirm."
        case .idea, .contextualNote, .ritual:
            return "Keeps the capture findable without scheduling it."
        }
    }
}

private extension ActionReceiptPrivacyLevel {
    var placementLabel: String {
        switch self {
        case .safeToShow:
            return "Stored on this device"
        case .privateItem, .sensitive, .redacted:
            return "Private item"
        case .unavailable:
            return "Unavailable locally"
        }
    }
}
