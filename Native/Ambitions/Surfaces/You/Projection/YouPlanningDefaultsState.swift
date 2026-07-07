import AmbitionsDesignSystem
import Foundation

struct YouPlanningDefaultsPreference: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let whyItMatters: String
    let statusLabel: String
    let privacyLabel: String
    let defaultLabel: String?
    let accessibilityHint: String
    let state: AmbitionVisualState
}

struct YouPlanningDefaultsSection: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let preferences: [YouPlanningDefaultsPreference]
    let footer: String
}

struct YouPlanningDefaultsCenterState: Sendable, Equatable {
    let title: String
    let subtitle: String
    let sections: [YouPlanningDefaultsSection]
    let footer: String

    static let empty = YouPlanningDefaultsCenterState(
        title: "Planning setup",
        subtitle: "Schedule, availability, defaults, away time, and automation boundaries stay user-owned.",
        sections: [],
        footer: "Planning setup is optional and does not request permissions by itself."
    )

    func section(id: String) -> YouPlanningDefaultsSection? {
        sections.first { $0.id == id }
    }
}

struct YouAvailabilityCenterItem: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let summary: String
    let statusLabel: String
    let sourceLabel: String
    let state: AmbitionVisualState
}

struct YouAvailabilityCenterState: Sendable, Equatable {
    let title: String
    let subtitle: String
    let hardContextStack: [YouAvailabilityCenterItem]
    let protectedPocketMap: [YouAvailabilityCenterItem]
    let planningDefaults: [YouAvailabilityCenterItem]
    let automationTrustControls: [YouAvailabilityCenterItem]
    let durationSourceProof: [YouAvailabilityCenterItem]
    let vacationAwayBehavior: [YouAvailabilityCenterItem]
    let footer: String

    static let empty = YouAvailabilityCenterState(
        title: "Availability Center",
        subtitle: "Hard context, protected pockets, defaults, automation trust, durations, and away behavior stay reviewable before Time uses them.",
        hardContextStack: [],
        protectedPocketMap: [],
        planningDefaults: [],
        automationTrustControls: [],
        durationSourceProof: [],
        vacationAwayBehavior: [],
        footer: "Availability is user-owned. Open time is not automatically free work time."
    )
}
