import Foundation

let ambitionGraphProjectionSchemaVersion = "ambition_graph_projection_store.native.v1"

enum AmbitionGraphProjectionSurface: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case today
    case goals
    case capture
    case time
    case you
}

struct AmbitionGraphProjectionSnapshot: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let sourceSnapshotID: String
    let surface: AmbitionGraphProjectionSurface
    let generatedAt: String
    let ambitionID: String
    let localProjectionOnly: Bool
    let sourceFields: [String]
    let sourceObjectIDs: [String]
    let privacyClasses: [AmbitionPrivacyClass]
    let ambitionPrivacyClasses: [AmbitionPrivacyClass]
    let commitmentIDs: [String]
    let proofIDs: [String]
    let constraintIDs: [String]
    let outcomeIDs: [String]
    let identityDirectionIDs: [String]
    let stepIDs: [String]
    let closureEventIDs: [String]
    let recoveryThreadIDs: [String]
    let recommendationTraceIDs: [String]
    let schemaVersion: String

    init(
        id: String,
        sourceSnapshotID: String,
        surface: AmbitionGraphProjectionSurface,
        generatedAt: String,
        ambitionID: String,
        localProjectionOnly: Bool = true,
        sourceFields: [String] = [],
        sourceObjectIDs: [String] = [],
        privacyClasses: [AmbitionPrivacyClass] = [],
        ambitionPrivacyClasses: [AmbitionPrivacyClass] = [],
        commitmentIDs: [String] = [],
        proofIDs: [String] = [],
        constraintIDs: [String] = [],
        outcomeIDs: [String] = [],
        identityDirectionIDs: [String] = [],
        stepIDs: [String] = [],
        closureEventIDs: [String] = [],
        recoveryThreadIDs: [String] = [],
        recommendationTraceIDs: [String] = [],
        schemaVersion: String = ambitionGraphProjectionSchemaVersion
    ) {
        self.id = id
        self.sourceSnapshotID = sourceSnapshotID
        self.surface = surface
        self.generatedAt = generatedAt
        self.ambitionID = ambitionID
        self.localProjectionOnly = localProjectionOnly
        self.sourceFields = Self.orderedUnique(sourceFields)
        self.sourceObjectIDs = Self.orderedUnique(sourceObjectIDs)
        self.privacyClasses = Self.orderedPrivacyClasses(privacyClasses)
        self.ambitionPrivacyClasses = Self.orderedPrivacyClasses(ambitionPrivacyClasses)
        self.commitmentIDs = Self.orderedUnique(commitmentIDs)
        self.proofIDs = Self.orderedUnique(proofIDs)
        self.constraintIDs = Self.orderedUnique(constraintIDs)
        self.outcomeIDs = Self.orderedUnique(outcomeIDs)
        self.identityDirectionIDs = Self.orderedUnique(identityDirectionIDs)
        self.stepIDs = Self.orderedUnique(stepIDs)
        self.closureEventIDs = Self.orderedUnique(closureEventIDs)
        self.recoveryThreadIDs = Self.orderedUnique(recoveryThreadIDs)
        self.recommendationTraceIDs = Self.orderedUnique(recommendationTraceIDs)
        self.schemaVersion = schemaVersion
    }

    var hasPrivateContent: Bool {
        let privateSignals: Set<AmbitionPrivacyClass> = [
            .privateUserText,
            .privateProof,
            .privateConstraint
        ]
        return Set(privacyClasses).intersection(privateSignals).isEmpty == false
    }

    static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }

    static func orderedPrivacyClasses(_ values: [AmbitionPrivacyClass]) -> [AmbitionPrivacyClass] {
        var result: [AmbitionPrivacyClass] = []
        for value in values {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        return result.sorted { $0.rawValue < $1.rawValue }
    }
}

struct AmbitionGraphCrossSurfaceLoop: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let sourceSnapshotID: String
    let generatedAt: String
    let ambitionID: String
    let localProjectionOnly: Bool
    let coveredSurfaces: [AmbitionGraphProjectionSurface]
    let surfaceProjectionIDs: [String]
    let sourceFields: [String]
    let sourceObjectIDs: [String]
    let privacyClasses: [AmbitionPrivacyClass]
    let identityDirectionIDs: [String]
    let outcomeIDs: [String]
    let commitmentIDs: [String]
    let stepIDs: [String]
    let closureEventIDs: [String]
    let proofIDs: [String]
    let recoveryThreadIDs: [String]
    let recommendationTraceIDs: [String]
    let schemaVersion: String

    init(
        id: String,
        sourceSnapshotID: String,
        generatedAt: String,
        ambitionID: String,
        localProjectionOnly: Bool,
        coveredSurfaces: [AmbitionGraphProjectionSurface],
        surfaceProjectionIDs: [String],
        sourceFields: [String],
        sourceObjectIDs: [String],
        privacyClasses: [AmbitionPrivacyClass],
        identityDirectionIDs: [String],
        outcomeIDs: [String],
        commitmentIDs: [String],
        stepIDs: [String],
        closureEventIDs: [String],
        proofIDs: [String],
        recoveryThreadIDs: [String],
        recommendationTraceIDs: [String],
        schemaVersion: String = ambitionGraphProjectionSchemaVersion
    ) {
        self.id = id
        self.sourceSnapshotID = sourceSnapshotID
        self.generatedAt = generatedAt
        self.ambitionID = ambitionID
        self.localProjectionOnly = localProjectionOnly
        self.coveredSurfaces = Self.orderedSurfaces(coveredSurfaces)
        self.surfaceProjectionIDs = AmbitionGraphProjectionSnapshot.orderedUnique(surfaceProjectionIDs)
        self.sourceFields = AmbitionGraphProjectionSnapshot.orderedUnique(sourceFields)
        self.sourceObjectIDs = AmbitionGraphProjectionSnapshot.orderedUnique(sourceObjectIDs)
        self.privacyClasses = Self.orderedPrivacyClasses(privacyClasses)
        self.identityDirectionIDs = AmbitionGraphProjectionSnapshot.orderedUnique(identityDirectionIDs)
        self.outcomeIDs = AmbitionGraphProjectionSnapshot.orderedUnique(outcomeIDs)
        self.commitmentIDs = AmbitionGraphProjectionSnapshot.orderedUnique(commitmentIDs)
        self.stepIDs = AmbitionGraphProjectionSnapshot.orderedUnique(stepIDs)
        self.closureEventIDs = AmbitionGraphProjectionSnapshot.orderedUnique(closureEventIDs)
        self.proofIDs = AmbitionGraphProjectionSnapshot.orderedUnique(proofIDs)
        self.recoveryThreadIDs = AmbitionGraphProjectionSnapshot.orderedUnique(recoveryThreadIDs)
        self.recommendationTraceIDs = AmbitionGraphProjectionSnapshot.orderedUnique(recommendationTraceIDs)
        self.schemaVersion = schemaVersion
    }

    var connectsEveryCanonicalSurface: Bool {
        coveredSurfaces == AmbitionGraphProjectionSurface.allCases
    }

    var carriesGoalToLifeDirectionContext: Bool {
        identityDirectionIDs.isEmpty == false &&
            outcomeIDs.isEmpty == false &&
            commitmentIDs.isEmpty == false &&
            stepIDs.isEmpty == false &&
            closureEventIDs.isEmpty == false &&
            proofIDs.isEmpty == false &&
            recoveryThreadIDs.isEmpty == false
    }

    static func orderedSurfaces(_ values: [AmbitionGraphProjectionSurface]) -> [AmbitionGraphProjectionSurface] {
        let order = Dictionary(uniqueKeysWithValues: AmbitionGraphProjectionSurface.allCases.enumerated().map { ($0.element, $0.offset) })
        var result: [AmbitionGraphProjectionSurface] = []
        for value in values {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        return result.sorted { (order[$0] ?? 0) < (order[$1] ?? 0) }
    }

    static func orderedPrivacyClasses(_ values: [AmbitionPrivacyClass]) -> [AmbitionPrivacyClass] {
        var result: [AmbitionPrivacyClass] = []
        for value in values {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        return result.sorted { $0.rawValue < $1.rawValue }
    }
}
