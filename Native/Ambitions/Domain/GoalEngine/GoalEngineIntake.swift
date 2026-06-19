import Foundation

struct IntakeSignals {
    let normalizedLower: String
    let learning: Bool
    let exploration: Bool
    let support: Bool
    let delegationOnly: Bool
    let noDeadlines: Bool
    let recurring: Bool
    let maintenance: Bool
    let recovery: Bool
    let launchProject: Bool
    let childActor: Bool
    let observedOnly: Bool
    let explicitISODate: String?
    let explicitDate: Bool
    let hardDeadline: Bool
    let targetWindow: Bool
    let metaPreferenceOnly: Bool
    let ambiguousSubject: Bool
}
