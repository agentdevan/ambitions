import AmbitionsDesignSystem
import Foundation

struct ProfilePlanningDefaultsPreference: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let whyItMatters: String
    let statusLabel: String
    let privacyLabel: String
    let defaultLabel: String?
    let accessibilityHint: String
    let state: AmbitionVisualState
}

struct ProfilePlanningDefaultsSection: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let preferences: [ProfilePlanningDefaultsPreference]
    let footer: String
}

struct ProfilePlanningDefaultsCenterState: Sendable, Equatable {
    let title: String
    let subtitle: String
    let sections: [ProfilePlanningDefaultsSection]
    let footer: String

    static let empty = ProfilePlanningDefaultsCenterState(
        title: "Planning setup",
        subtitle: "Schedule, availability, defaults, away time, and automation boundaries stay user-owned.",
        sections: [],
        footer: "Planning setup is optional and does not request permissions by itself."
    )

    func section(id: String) -> ProfilePlanningDefaultsSection? {
        sections.first { $0.id == id }
    }
}
