import Foundation

enum ShellTrustedSearchHandoffOwner: String, Hashable, Sendable {
    case today
    case goals
    case time
    case you
    case globalCapture

    var title: String {
        switch self {
        case .today: "Today"
        case .goals: "Goals"
        case .time: "Time"
        case .you: "You"
        case .globalCapture: "Global Capture"
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .globalCapture:
            "Global Capture handoff"
        default:
            "\(title) handoff"
        }
    }
}

struct ShellTrustedSearchHandoff: Hashable, Identifiable, Sendable {
    let id: String
    let resultID: String
    let resultTitle: String
    let source: ShellCommandEntrySource
    let destination: ShellCommandDestination
    let owner: ShellTrustedSearchHandoffOwner
    let sourceEvidenceTitle: String
    let trustSummary: String
    let staleDestinationBlockers: [String]

    init(
        resultID: String,
        resultTitle: String,
        source: ShellCommandEntrySource,
        destination: ShellCommandDestination,
        owner: ShellTrustedSearchHandoffOwner,
        sourceEvidenceTitle: String,
        trustSummary: String,
        staleDestinationBlockers: [String]
    ) {
        self.id = [resultID, source.rawValue, destination.displayLabel, owner.rawValue].joined(separator: "|")
        self.resultID = resultID
        self.resultTitle = resultTitle
        self.source = source
        self.destination = destination
        self.owner = owner
        self.sourceEvidenceTitle = sourceEvidenceTitle
        self.trustSummary = trustSummary
        self.staleDestinationBlockers = staleDestinationBlockers
    }

    var isTrusted: Bool { staleDestinationBlockers.isEmpty }

    var body: String {
        guard isTrusted else {
            return "Search result was held because the destination is not an active Ambitions surface."
        }
        return "Opened \(resultTitle) from Search Ambitions into \(owner.title). \(sourceEvidenceTitle); \(trustSummary)."
    }
}

enum ShellCommandDestination: Hashable, Sendable {
    case tab(AppTab)
    case goal(String)
    case timeRoute(TimeRouteTarget)
    case youRoute(YouRouteTarget)
    case overlay(ShellOverlayState)

    var displayLabel: String {
        switch self {
        case let .tab(tab):
            tab.title
        case .goal:
            "Goal Detail"
        case let .timeRoute(target):
            switch target {
            case .habits: "Rituals"
            case .weeklyReview: "Weekly Review"
            }
        case let .youRoute(target):
            switch target {
            case .monthlyReview: "Monthly Review"
            case .history: "History"
            }
        case let .overlay(overlay):
            switch overlay.kind {
            case .quietCommandSheet: overlay.isActivatedCaptureComposer ? "Capture" : "Add something"
            case .memoryLens: "Search Ambitions"
            case .createGoal: "Create Goal"
            }
        }
    }

    var trustedSearchHandoffOwner: ShellTrustedSearchHandoffOwner {
        switch self {
        case let .tab(tab):
            switch tab.canonicalTopLevelTab {
            case .today: .today
            case .goals: .goals
            case .time: .time
            case .you: .you
            }
        case .goal:
            .goals
        case .timeRoute:
            .time
        case .youRoute:
            .you
        case let .overlay(overlay):
            overlay.isActivatedCaptureComposer ? .globalCapture : .today
        }
    }

    var staleIADestinationBlockers: [String] {
        var blockers: [String] = []
        if case let .tab(tab) = self, tab.isCanonicalTopLevel == false {
            blockers.append("Non-canonical tab \(tab.rawValue)")
        }

        let exactStaleRootLabels: Set<String> = ["plan", "pulse", "profile", "calendar", "inbox"]
        let normalizedLabel = displayLabel.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if exactStaleRootLabels.contains(normalizedLabel) {
            blockers.append("Stale IA destination \(displayLabel)")
        }
        return blockers
    }
}

extension MemoryLensResult {
    var trustedSearchHandoffOwner: ShellTrustedSearchHandoffOwner {
        destination.trustedSearchHandoffOwner
    }

    var staleIADestinationBlockers: [String] {
        destination.staleIADestinationBlockers
    }

    func trustedSearchHandoff(source: ShellCommandEntrySource) -> ShellTrustedSearchHandoff {
        ShellTrustedSearchHandoff(
            resultID: id,
            resultTitle: title,
            source: source,
            destination: destination,
            owner: trustedSearchHandoffOwner,
            sourceEvidenceTitle: sourceEvidence.title,
            trustSummary: contextRetrievalSummary,
            staleDestinationBlockers: staleIADestinationBlockers
        )
    }
}
