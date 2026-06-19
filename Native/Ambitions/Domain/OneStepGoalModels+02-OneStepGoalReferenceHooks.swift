import Foundation

struct OneStepGoalReferenceHooks: Codable, Sendable, Equatable, Hashable {
    let lifeAreaReference: LifeGraphObjectReference?
    let linkedGoalReferences: [LifeGraphObjectReference]
    let northStarReferences: [LifeGraphObjectReference]
    let pathReferences: [LifeGraphObjectReference]
    let milestoneReferences: [LifeGraphObjectReference]
    let stepReferences: [LifeGraphObjectReference]
    let proofReferences: [LifeGraphObjectReference]
    let decisionReferences: [LifeGraphObjectReference]
    let receiptReferences: [LifeGraphObjectReference]
    let reviewReferences: [LifeGraphObjectReference]
    let captureReferences: [LifeGraphObjectReference]
    let futurePlanReferences: [LifeGraphObjectReference]

    init(
        lifeAreaReference: LifeGraphObjectReference? = nil,
        linkedGoalReferences: [LifeGraphObjectReference] = [],
        northStarReferences: [LifeGraphObjectReference] = [],
        pathReferences: [LifeGraphObjectReference] = [],
        milestoneReferences: [LifeGraphObjectReference] = [],
        stepReferences: [LifeGraphObjectReference] = [],
        proofReferences: [LifeGraphObjectReference] = [],
        decisionReferences: [LifeGraphObjectReference] = [],
        receiptReferences: [LifeGraphObjectReference] = [],
        reviewReferences: [LifeGraphObjectReference] = [],
        captureReferences: [LifeGraphObjectReference] = [],
        futurePlanReferences: [LifeGraphObjectReference] = []
    ) {
        self.lifeAreaReference = lifeAreaReference?.isWellFormed == true ? lifeAreaReference : nil
        self.linkedGoalReferences = Self.orderedUnique(linkedGoalReferences)
        self.northStarReferences = Self.orderedUnique(northStarReferences)
        self.pathReferences = Self.orderedUnique(pathReferences)
        self.milestoneReferences = Self.orderedUnique(milestoneReferences)
        self.stepReferences = Self.orderedUnique(stepReferences)
        self.proofReferences = Self.orderedUnique(proofReferences)
        self.decisionReferences = Self.orderedUnique(decisionReferences)
        self.receiptReferences = Self.orderedUnique(receiptReferences)
        self.reviewReferences = Self.orderedUnique(reviewReferences)
        self.captureReferences = Self.orderedUnique(captureReferences)
        self.futurePlanReferences = Self.orderedUnique(futurePlanReferences)
    }

    static func orderedUnique(_ references: [LifeGraphObjectReference]) -> [LifeGraphObjectReference] {
        var seen = Set<String>()
        return references
            .filter(\.isWellFormed)
            .filter { seen.insert($0.stableKey).inserted }
            .sorted { lhs, rhs in
                if lhs.kind.rawValue != rhs.kind.rawValue {
                    return lhs.kind.rawValue < rhs.kind.rawValue
                }
                if lhs.displayLabel.localizedCaseInsensitiveCompare(rhs.displayLabel) != .orderedSame {
                    return lhs.displayLabel.localizedCaseInsensitiveCompare(rhs.displayLabel) == .orderedAscending
                }
                return lhs.stableKey < rhs.stableKey
            }
    }
}

struct OneStepGoalAccessibilityProjection: Codable, Sendable, Equatable, Hashable {
    let label: String
    let value: String
    let hint: String
}

struct OneStepGoal: Codable, Sendable, Equatable, Hashable, Identifiable {
    let schemaVersion: String
    let id: OneStepGoalID
    let title: String
    let note: String?
    let lifeAreaID: LifeAreaID?
    let status: OneStepGoalStatus
    let timing: OneStepGoalTimingMetadata?
    let source: OneStepGoalSource
    let sourceCaptureID: String?
    let linkedGoalIDs: [String]
    let northStarIDs: [NorthStarID]
    let proofReferenceIDs: [String]
    let receiptReferenceIDs: [String]
    let decisionReferenceIDs: [String]
    let reviewReferenceIDs: [String]
    let archiveReason: String?
    let createdAt: String?
    let updatedAt: String?
    let completedAt: String?
    let archivedAt: String?
    let lastReferencedAt: String?
    let isSensitive: Bool
    let correctionLabel: String
    let conversionContract: OneStepGoalConversionContract
    let relationshipHooks: OneStepGoalReferenceHooks

    init(
        schemaVersion: String = oneStepGoalSchemaVersion,
        id: OneStepGoalID,
        title: String,
        note: String? = nil,
        lifeAreaID: LifeAreaID? = nil,
        status: OneStepGoalStatus = .ready,
        timing: OneStepGoalTimingMetadata? = nil,
        source: OneStepGoalSource = .manual,
        sourceCaptureID: String? = nil,
        linkedGoalIDs: [String] = [],
        northStarIDs: [NorthStarID] = [],
        proofReferenceIDs: [String] = [],
        receiptReferenceIDs: [String] = [],
        decisionReferenceIDs: [String] = [],
        reviewReferenceIDs: [String] = [],
        archiveReason: String? = nil,
        createdAt: String? = nil,
        updatedAt: String? = nil,
        completedAt: String? = nil,
        archivedAt: String? = nil,
        lastReferencedAt: String? = nil,
        isSensitive: Bool = false,
        correctionLabel: String = "Update this",
        conversionContract: OneStepGoalConversionContract = OneStepGoalConversionContract(),
        relationshipHooks: OneStepGoalReferenceHooks? = nil
    ) {
        self.schemaVersion = schemaVersion
        self.id = id
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.note = Self.normalizedOptional(note)
        self.lifeAreaID = lifeAreaID
        self.status = status
        self.timing = timing
        self.source = source
        self.sourceCaptureID = Self.normalizedOptional(sourceCaptureID)
        self.linkedGoalIDs = Self.orderedUniqueStrings(linkedGoalIDs)
        self.northStarIDs = Self.orderedUniqueNorthStarIDs(northStarIDs)
        self.proofReferenceIDs = Self.orderedUniqueStrings(proofReferenceIDs)
        self.receiptReferenceIDs = Self.orderedUniqueStrings(receiptReferenceIDs)
        self.decisionReferenceIDs = Self.orderedUniqueStrings(decisionReferenceIDs)
        self.reviewReferenceIDs = Self.orderedUniqueStrings(reviewReferenceIDs)
        self.archiveReason = Self.normalizedOptional(archiveReason)
        self.createdAt = Self.normalizedOptional(createdAt)
        self.updatedAt = Self.normalizedOptional(updatedAt)
        self.completedAt = Self.normalizedOptional(completedAt)
        self.archivedAt = Self.normalizedOptional(archivedAt)
        self.lastReferencedAt = Self.normalizedOptional(lastReferencedAt)
        self.isSensitive = isSensitive
        self.correctionLabel = Self.normalizedRequired(correctionLabel, fallback: "Update this")
        self.conversionContract = conversionContract

        let areaReference = lifeAreaID.map { areaID in
            LifeGraphObjectReference(
                kind: .lifeArea,
                id: areaID.rawValue,
                label: LifeAreaDefinition.canonical.first(where: { $0.id == areaID })?.displayName,
                sourceDomain: .goals
            )
        }
        self.relationshipHooks = relationshipHooks ?? OneStepGoalReferenceHooks(
            lifeAreaReference: areaReference,
            linkedGoalReferences: self.linkedGoalIDs.map {
                LifeGraphObjectReference(kind: .goal, id: $0, sourceDomain: .goals)
            },
            northStarReferences: self.northStarIDs.map {
                LifeGraphObjectReference(kind: .northStar, id: $0.rawValue, sourceDomain: .goals)
            },
            proofReferences: self.proofReferenceIDs.map {
                LifeGraphObjectReference(kind: .proof, id: $0, parentContextID: id.rawValue, sourceDomain: .proof)
            },
            decisionReferences: self.decisionReferenceIDs.map {
                LifeGraphObjectReference(kind: .decision, id: $0, parentContextID: id.rawValue, sourceDomain: .goals)
            },
            receiptReferences: self.receiptReferenceIDs.map {
                LifeGraphObjectReference(kind: .receipt, id: $0, parentContextID: id.rawValue, sourceDomain: .receipt)
            },
            reviewReferences: self.reviewReferenceIDs.map {
                LifeGraphObjectReference(kind: .review, id: $0, parentContextID: id.rawValue, sourceDomain: .you)
            },
            captureReferences: self.sourceCaptureID.map {
                [LifeGraphObjectReference(kind: .capture, id: $0, sourceDomain: .capture)]
            } ?? []
        )
    }

    var objectReference: LifeGraphObjectReference {
        LifeGraphObjectReference(
            kind: .oneStepGoal,
            id: id.rawValue,
            label: title.isEmpty ? "One-Step Goal" : title,
            sourceDomain: .goals
        )
    }

    var canBePromotedToGoal: Bool {
        conversionContract.canPromoteToGoal && status != .archived
    }

    var canAttachToGoal: Bool {
        conversionContract.canAttachToGoal && status != .archived
    }

    var redacted: OneStepGoal {
        OneStepGoal(
            schemaVersion: schemaVersion,
            id: id,
            title: "Private item",
            note: "Detail hidden",
            lifeAreaID: lifeAreaID,
            status: status,
            timing: nil,
            source: source,
            sourceCaptureID: sourceCaptureID,
            linkedGoalIDs: linkedGoalIDs,
            northStarIDs: northStarIDs,
            proofReferenceIDs: proofReferenceIDs,
            receiptReferenceIDs: receiptReferenceIDs,
            decisionReferenceIDs: decisionReferenceIDs,
            reviewReferenceIDs: reviewReferenceIDs,
            archiveReason: archiveReason.map { _ in "Detail hidden" },
            createdAt: createdAt,
            updatedAt: updatedAt,
            completedAt: completedAt,
            archivedAt: archivedAt,
            lastReferencedAt: lastReferencedAt,
            isSensitive: true,
            correctionLabel: correctionLabel,
            conversionContract: conversionContract,
            relationshipHooks: relationshipHooks
        )
    }

    func conversionReceiptMetadata(
        for kind: OneStepGoalConversionKind,
        targetGoalID: String? = nil
    ) -> OneStepGoalConversionReceiptMetadata {
        let targetGoal = Self.normalizedOptional(targetGoalID).map {
            LifeGraphObjectReference(kind: .goal, id: $0, sourceDomain: .goals)
        }
        let title: String
        let summary: String
        let resultState: ActionReceiptResultState
        let factKind: ActionReceiptChangedFactKind
        switch kind {
        case .promoteToGoal:
            title = "Task ready to become goal"
            summary = "This One-Step Goal can become a Goal after confirmation. No Goal is created automatically."
            resultState = .needsConfirmation
            factKind = .promotedTaskToGoal
        case .attachToGoal:
            title = "Task ready to attach"
            summary = "This One-Step Goal can attach to a Goal after confirmation."
            resultState = .needsConfirmation
            factKind = .attachedTaskToGoal
        case .demoteFromGoal:
            title = "Goal can become One-Step Goal"
            summary = "This keeps the work smaller when a full Goal structure is too heavy."
            resultState = .needsConfirmation
            factKind = .demotedGoalToTask
        }

        return OneStepGoalConversionReceiptMetadata(
            kind: kind,
            resultState: resultState,
            changedFactKind: factKind,
            sourceObject: objectReference,
            targetObject: targetGoal,
            receiptTitle: title,
            receiptSummary: summary,
            requiresConfirmation: conversionContract.requiresConfirmation
        )
    }

    var localLabelTags: [String] {
        var tags: [String] = [source.rawValue]

        if status.isOpen {
            tags.append("open")
        }

        switch status {
        case .ready:
            break
        case .today:
            tags.append("today")
        case .scheduled:
            tags.append(contentsOf: ["scheduled", "upcoming"])
        case .waiting:
            tags.append(contentsOf: ["waiting", "blocked"])
        case .reviewLater:
            tags.append(contentsOf: ["held", "someday_future", "needs_review"])
        case .parked:
            tags.append(contentsOf: ["held", "blocked"])
        case .completed:
            tags.append("done")
        case .archived:
            tags.append("archived")
        }

        if timing?.hasDueMetadata == true {
            tags.append("scheduled")
            if status != .today {
                tags.append("upcoming")
            }
        }

        if timing?.reviewAfter != nil {
            tags.append(contentsOf: ["held", "someday_future", "needs_review"])
        }

        if proofReferenceIDs.isEmpty {
            tags.append("proof_needed")
        }

        if reviewReferenceIDs.isEmpty {
            tags.append("needs_review")
        }

        if source == .manual && sourceCaptureID == nil {
            tags.append("source_needed")
        }

        return Self.orderedUniqueStrings(tags)
    }

    static func normalizedRequired(_ value: String, fallback: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? fallback : trimmed
    }

    static func normalizedOptional(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              trimmed.isEmpty == false else {
            return nil
        }
        return trimmed
    }

    static func orderedUniqueStrings(_ values: [String]) -> [String] {
        var seen = Set<String>()
        return values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
            .filter { seen.insert($0).inserted }
            .sorted()
    }

    static func orderedUniqueNorthStarIDs(_ values: [NorthStarID]) -> [NorthStarID] {
        var seen = Set<NorthStarID>()
        return values
            .filter { seen.insert($0).inserted }
            .sorted()
    }
}
