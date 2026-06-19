import Foundation

enum TimeRitualsAccessibility {
    static func summary(for state: AsyncViewState<TimeRitualsDashboard>, inlineMessage: TimeRitualInlineMessage?) -> String {
        let base: [String]
        switch state {
        case .loading:
            base = ["Time", "Rituals", "Loading recurring loops"]
        case let .failed(message):
            base = ["Time", "Rituals unavailable", message]
        case let .loaded(dashboard):
            base = [
                "Time",
                "Rituals",
                dashboard.title,
                "\(dashboard.rituals.count) active",
                "\(dashboard.recoveryRituals.count) in recovery"
            ]
        }

        return (base + [inlineMessage?.title, inlineMessage?.body].compactMap { $0 })
            .filter { $0.isEmpty == false }
            .joined(separator: ". ")
    }
}

struct TimeRitualsMutationProof: Identifiable, Sendable, Equatable {
    let id: String
    let runtimeMutation: String
    let visibleStageMutation: String
    let accessibilityAnnouncement: String
    let proofArtifactID: String

    init(action: TimeRitualActionState, response: TimeRitualActionResponse) {
        let proofArtifactID = response.proofArtifactID ?? "time-rituals.unpersisted.\(action.id)"
        self.id = "\(action.id).\(proofArtifactID)"
        self.runtimeMutation = "time-rituals.\(action.kind.rawValue)"
        self.visibleStageMutation = response.message?.title ?? action.title
        self.accessibilityAnnouncement = response.message?.title ?? "\(action.title) updated."
        self.proofArtifactID = proofArtifactID
    }

    static func failed(action: TimeRitualActionState, message: String) -> TimeRitualsMutationProof {
        TimeRitualsMutationProof(
            id: "\(action.id).failed",
            runtimeMutation: "time-rituals.\(action.kind.rawValue).failed",
            visibleStageMutation: "Ritual action could not finish",
            accessibilityAnnouncement: "Ritual action could not finish. \(message)",
            proofArtifactID: "time-rituals.failure.\(action.id)"
        )
    }

    static func route(action: TimeRitualActionState) -> TimeRitualsMutationProof {
        TimeRitualsMutationProof(
            id: "\(action.id).route",
            runtimeMutation: "stage-route.open-goal-detail",
            visibleStageMutation: "Opening ritual context",
            accessibilityAnnouncement: "Opening ritual context.",
            proofArtifactID: "stage-route.\(action.id)"
        )
    }

    static func route(label: String, routeID: String) -> TimeRitualsMutationProof {
        TimeRitualsMutationProof(
            id: "\(routeID).route",
            runtimeMutation: "stage-route.\(routeID)",
            visibleStageMutation: label,
            accessibilityAnnouncement: "\(label).",
            proofArtifactID: "stage-route.\(routeID)"
        )
    }

    private init(
        id: String,
        runtimeMutation: String,
        visibleStageMutation: String,
        accessibilityAnnouncement: String,
        proofArtifactID: String
    ) {
        self.id = id
        self.runtimeMutation = runtimeMutation
        self.visibleStageMutation = visibleStageMutation
        self.accessibilityAnnouncement = accessibilityAnnouncement
        self.proofArtifactID = proofArtifactID
    }
}
