import Foundation

struct UserSystemProfile: Codable, Sendable, Equatable, Identifiable {
    enum PersistenceAuthority: String, Codable, Sendable, Equatable, Hashable {
        case derivedFromLocalContextAndSettings = "derived_from_local_context_and_settings"
    }

    let id: String
    let displayName: String
    let planningDefaults: [String]
    let notificationPreferences: [String]
    let appearancePreferences: [String]
    let privacyPreferences: [String]
    let permissions: [String]
    let connectedSources: [String]
    let historyPreferences: [String]
    let exportSharePreferences: [String]
    let securityControls: [String]
    let localAuthenticationSettings: [String]
    let accountState: String
    let referencePackState: String

    var persistenceAuthority: PersistenceAuthority {
        .derivedFromLocalContextAndSettings
    }

    var requiresDedicatedProfileRecord: Bool {
        false
    }

    var privateGraphBackendAllowed: Bool {
        false
    }

    init(
        id: String = "user-system-profile",
        displayName: String,
        planningDefaults: [String] = [],
        notificationPreferences: [String] = [],
        appearancePreferences: [String] = [],
        privacyPreferences: [String] = [],
        permissions: [String] = [],
        connectedSources: [String] = [],
        historyPreferences: [String] = [],
        exportSharePreferences: [String] = [],
        securityControls: [String] = [],
        localAuthenticationSettings: [String] = [],
        accountState: String = "Local-only",
        referencePackState: String = "Not connected"
    ) {
        self.id = Self.normalizedRequired(id, fallback: "user-system-profile")
        self.displayName = Self.normalizedRequired(displayName, fallback: "User System Profile")
        self.planningDefaults = Self.orderedUnique(planningDefaults)
        self.notificationPreferences = Self.orderedUnique(notificationPreferences)
        self.appearancePreferences = Self.orderedUnique(appearancePreferences)
        self.privacyPreferences = Self.orderedUnique(privacyPreferences)
        self.permissions = Self.orderedUnique(permissions)
        self.connectedSources = Self.orderedUnique(connectedSources)
        self.historyPreferences = Self.orderedUnique(historyPreferences)
        self.exportSharePreferences = Self.orderedUnique(exportSharePreferences)
        self.securityControls = Self.orderedUnique(securityControls)
        self.localAuthenticationSettings = Self.orderedUnique(localAuthenticationSettings)
        self.accountState = Self.normalizedRequired(accountState, fallback: "Local-only")
        self.referencePackState = Self.normalizedRequired(referencePackState, fallback: "Not connected")
    }

    var inspectionSummary: String {
        [
            "User System Profile: \(displayName)",
            "Planning setup: \(Self.summary(planningDefaults, fallback: "review-gated"))",
            "Trust controls: \(Self.summary(securityControls, fallback: "review-gated"))",
            "Local learning: \(Self.summary(historyPreferences, fallback: "available when local signals exist"))",
            "Personal vault: \(Self.summary(connectedSources, fallback: "summary only"))",
            "Reset controls: \(Self.summary(localAuthenticationSettings, fallback: "review-gated"))",
            "Privacy: \(Self.summary(privacyPreferences, fallback: "Stored on this device"))",
            "Automation: \(Self.summary(permissions, fallback: "explicit permission only"))",
            "Source, receipt, and reason boundaries stay inspectable from What Ambitions Knows and Trust Center"
        ].joined(separator: " | ")
    }

    private static func summary(_ values: [String], fallback: String) -> String {
        values.isEmpty ? fallback : values.prefix(4).joined(separator: ", ")
    }

    private static func normalizedRequired(_ value: String, fallback: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? fallback : trimmed
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        var seen = Set<String>()
        return values.compactMap { value in
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmed.isEmpty == false, seen.insert(trimmed).inserted else { return nil }
            return trimmed
        }
    }
}
