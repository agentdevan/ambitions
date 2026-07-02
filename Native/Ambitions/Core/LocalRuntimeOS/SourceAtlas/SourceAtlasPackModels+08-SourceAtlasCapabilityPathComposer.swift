import Foundation

enum SourceAtlasLocalInfluenceKind: String, Codable, Sendable, Equatable, Hashable {
    case facilityAccess = "facility_access"
    case equipmentAccess = "equipment_access"
    case eligibilityPathway = "eligibility_pathway"
    case recoveryConstraint = "recovery_constraint"
    case travelFit = "travel_fit"
    case transportationConstraint = "transportation_constraint"
    case recentProof = "recent_proof"
    case other
}

struct SourceAtlasLocalInfluenceSignal: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: SourceAtlasLocalInfluenceKind
    let summary: String
    let affectedArea: String
    let lastAffectedLabel: String
    let fallbackBehavior: String
    let sourceLabel: String
    let weight: Double
    let active: Bool
    let allowedForRuntimeUse: Bool

    init(
        id: String,
        kind: SourceAtlasLocalInfluenceKind,
        summary: String,
        affectedArea: String,
        lastAffectedLabel: String,
        fallbackBehavior: String,
        sourceLabel: String,
        weight: Double,
        active: Bool = true,
        allowedForRuntimeUse: Bool = true
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.kind = kind
        self.summary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.affectedArea = affectedArea.trimmingCharacters(in: .whitespacesAndNewlines)
        self.lastAffectedLabel = lastAffectedLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        self.fallbackBehavior = fallbackBehavior.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceLabel = sourceLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        self.weight = min(max(weight, 0), 1)
        self.active = active
        self.allowedForRuntimeUse = allowedForRuntimeUse
    }
}

struct SourceAtlasLocalInfluenceSet: Codable, Sendable, Equatable, Hashable {
    let stableFingerprint: String
    let signals: [SourceAtlasLocalInfluenceSignal]

    init(
        stableFingerprint: String,
        signals: [SourceAtlasLocalInfluenceSignal]
    ) {
        self.stableFingerprint = stableFingerprint.trimmingCharacters(in: .whitespacesAndNewlines)
        self.signals = signals.sorted { lhs, rhs in
            if lhs.kind.rawValue != rhs.kind.rawValue {
                return lhs.kind.rawValue < rhs.kind.rawValue
            }
            return lhs.id < rhs.id
        }
    }
}

struct SourceAtlasCapabilityPathComposer: Sendable, Equatable {
    let goalID: String

    let userContextVersion: String

    let sourceAtlasProjectionID: String

    let packs: [SourceAtlasPack]

    let match: SourceAtlasIntentMatch

    let selection: SourceAtlasPackSelection

    let lifeContextProjection: LifeContextRuntimeProjection

    let localInfluenceSet: SourceAtlasLocalInfluenceSet?


    init(
        goalID: String,
        userContextVersion: String,
        sourceAtlasProjectionID: String,
        packs: [SourceAtlasPack],
        match: SourceAtlasIntentMatch,
        selection: SourceAtlasPackSelection,
        lifeContextProjection: LifeContextRuntimeProjection,
        localInfluenceSet: SourceAtlasLocalInfluenceSet? = nil
    ) {
        self.goalID = goalID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.userContextVersion = userContextVersion.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceAtlasProjectionID = sourceAtlasProjectionID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.packs = packs
        self.match = match
        self.selection = selection
        self.lifeContextProjection = lifeContextProjection
        self.localInfluenceSet = localInfluenceSet
    }
}
