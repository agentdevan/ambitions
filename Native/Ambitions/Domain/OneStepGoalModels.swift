import Foundation

let oneStepGoalSchemaVersion = "one_step_goal.native.v1"

struct OneStepGoalID: RawRepresentable, Codable, Sendable, Equatable, Hashable, Comparable {
    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func < (lhs: OneStepGoalID, rhs: OneStepGoalID) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

enum OneStepGoalStatus: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case ready
    case today
    case scheduled
    case waiting
    case reviewLater = "review_later"
    case parked
    case completed
    case archived

    var displayName: String {
        switch self {
        case .ready:
            return "Ready"
        case .today:
            return "Today"
        case .scheduled:
            return "Scheduled"
        case .waiting:
            return "Waiting"
        case .reviewLater:
            return "Review later"
        case .parked:
            return "Parked"
        case .completed:
            return "Done"
        case .archived:
            return "Archived"
        }
    }

    var isOpen: Bool {
        switch self {
        case .ready, .today, .scheduled, .waiting, .reviewLater:
            return true
        case .parked, .completed, .archived:
            return false
        }
    }

    var isArchived: Bool {
        self == .archived
    }
}

enum OneStepGoalSource: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case manual
    case capture
    case smartAttachment = "smart_attachment"
    case command
    case demotedGoal = "demoted_goal"
    case review
}

enum OneStepGoalPrivacyLevel: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case full
    case compact
    case redacted
}

enum OneStepGoalConversionKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case promoteToGoal = "promote_to_goal"
    case attachToGoal = "attach_to_goal"
    case demoteFromGoal = "demote_from_goal"

    var displayName: String {
        switch self {
        case .promoteToGoal:
            return "Make this a goal"
        case .attachToGoal:
            return "Attach to goal"
        case .demoteFromGoal:
            return "Keep as One-Step Goal"
        }
    }
}

enum OneStepGoalSavedViewKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case labelsTags = "labels_tags"
    case today
    case upcoming
    case scheduled
    case open
    case waiting
    case blocked
    case held
    case somedayFuture = "someday_future"
    case proofNeeded = "proof_needed"
    case needsReview = "needs_review"
    case sourceNeeded = "source_needed"

    var displayName: String {
        switch self {
        case .labelsTags:
            return "Labels/tags"
        case .today:
            return "Today"
        case .upcoming:
            return "Upcoming"
        case .scheduled:
            return "Scheduled"
        case .open:
            return "Open"
        case .waiting:
            return "Waiting"
        case .blocked:
            return "Blocked"
        case .held:
            return "Held"
        case .somedayFuture:
            return "Someday/Future"
        case .proofNeeded:
            return "Proof Needed"
        case .needsReview:
            return "Needs Review"
        case .sourceNeeded:
            return "Source Needed"
        }
    }

    var criteriaTags: [String] {
        switch self {
        case .labelsTags:
            return []
        case .today:
            return ["today"]
        case .upcoming:
            return ["upcoming"]
        case .scheduled:
            return ["scheduled"]
        case .open:
            return ["open"]
        case .waiting:
            return ["waiting"]
        case .blocked:
            return ["blocked"]
        case .held:
            return ["held"]
        case .somedayFuture:
            return ["someday_future"]
        case .proofNeeded:
            return ["proof_needed"]
        case .needsReview:
            return ["needs_review"]
        case .sourceNeeded:
            return ["source_needed"]
        }
    }

    var criteriaDescription: String {
        switch self {
        case .labelsTags:
            return "Browse the local label index."
        case .today:
            return "Work tagged for today."
        case .upcoming:
            return "Work tagged for the near future."
        case .scheduled:
            return "Work with explicit timing."
        case .open:
            return "Work that is still open."
        case .waiting:
            return "Work waiting on something else."
        case .blocked:
            return "Work currently blocked."
        case .held:
            return "Work being held for later."
        case .somedayFuture:
            return "Work deferred to someday or future review."
        case .proofNeeded:
            return "Work missing proof references."
        case .needsReview:
            return "Work missing review support."
        case .sourceNeeded:
            return "Work missing source context."
        }
    }
}

struct OneStepGoalLabelSummary: Codable, Sendable, Equatable, Hashable {
    let id: String
    let title: String
    let count: Int
    let goalIDs: [OneStepGoalID]
}

struct OneStepGoalViewSummary: Codable, Sendable, Equatable, Hashable {
    let id: String
    let kind: OneStepGoalSavedViewKind
    let title: String
    let count: Int
    let goalIDs: [OneStepGoalID]
    let criteriaTags: [String]
    let criteriaDescription: String
}

private extension OneStepGoalViewSummary {
    var privacySafeCompact: OneStepGoalViewSummary {
        OneStepGoalViewSummary(
            id: id,
            kind: kind,
            title: title,
            count: 0,
            goalIDs: [],
            criteriaTags: [],
            criteriaDescription: criteriaDescription
        )
    }
}

struct OneStepGoalTimingMetadata: Codable, Sendable, Equatable, Hashable {
    let dueAt: String?
    let dueLabel: String?
    let reminderAt: String?
    let reminderLabel: String?
    let reviewAfter: String?

    init(
        dueAt: String? = nil,
        dueLabel: String? = nil,
        reminderAt: String? = nil,
        reminderLabel: String? = nil,
        reviewAfter: String? = nil
    ) {
        self.dueAt = Self.normalizedOptional(dueAt)
        self.dueLabel = Self.normalizedOptional(dueLabel)
        self.reminderAt = Self.normalizedOptional(reminderAt)
        self.reminderLabel = Self.normalizedOptional(reminderLabel)
        self.reviewAfter = Self.normalizedOptional(reviewAfter)
    }

    var hasDueMetadata: Bool {
        dueAt != nil || dueLabel != nil
    }

    var hasReminderMetadata: Bool {
        reminderAt != nil || reminderLabel != nil
    }

    var compactLabel: String? {
        dueLabel ?? dueAt ?? reminderLabel ?? reminderAt ?? reviewAfter
    }

    var accessibilityValue: String {
        [
            dueLabel.map { "Due \($0)" } ?? dueAt.map { "Due \($0)" },
            reminderLabel.map { "Reminder \($0)" } ?? reminderAt.map { "Reminder \($0)" },
            reviewAfter.map { "Review after \($0)" }
        ].compactMap { $0 }.joined(separator: ". ")
    }

    private static func normalizedOptional(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              trimmed.isEmpty == false else {
            return nil
        }
        return trimmed
    }
}

struct OneStepGoalConversionContract: Codable, Sendable, Equatable, Hashable {
    let canPromoteToGoal: Bool
    let canAttachToGoal: Bool
    let canBeCreatedFromDemotedGoal: Bool
    let promoteToGoalLabel: String
    let attachToGoalLabel: String
    let demoteGoalToTaskLabel: String
    let requiresConfirmation: Bool
    let receiptRequired: Bool

    init(
        canPromoteToGoal: Bool = true,
        canAttachToGoal: Bool = true,
        canBeCreatedFromDemotedGoal: Bool = true,
        promoteToGoalLabel: String = "Make this a goal",
        attachToGoalLabel: String = "Attach to goal",
        demoteGoalToTaskLabel: String = "Keep as One-Step Goal",
        requiresConfirmation: Bool = true,
        receiptRequired: Bool = true
    ) {
        self.canPromoteToGoal = canPromoteToGoal
        self.canAttachToGoal = canAttachToGoal
        self.canBeCreatedFromDemotedGoal = canBeCreatedFromDemotedGoal
        self.promoteToGoalLabel = Self.normalizedRequired(promoteToGoalLabel, fallback: "Make this a goal")
        self.attachToGoalLabel = Self.normalizedRequired(attachToGoalLabel, fallback: "Attach to goal")
        self.demoteGoalToTaskLabel = Self.normalizedRequired(demoteGoalToTaskLabel, fallback: "Keep as One-Step Goal")
        self.requiresConfirmation = requiresConfirmation
        self.receiptRequired = receiptRequired
    }

    private static func normalizedRequired(_ value: String, fallback: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? fallback : trimmed
    }
}

struct OneStepGoalConversionReceiptMetadata: Codable, Sendable, Equatable, Hashable {
    let kind: OneStepGoalConversionKind
    let resultState: ActionReceiptResultState
    let changedFactKind: ActionReceiptChangedFactKind
    let sourceObject: LifeGraphObjectReference
    let targetObject: LifeGraphObjectReference?
    let receiptTitle: String
    let receiptSummary: String
    let requiresConfirmation: Bool

    var affectedObjects: [LifeGraphObjectReference] {
        ([sourceObject] + [targetObject].compactMap { $0 })
            .filter(\.isWellFormed)
    }
}

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

    private static func orderedUnique(_ references: [LifeGraphObjectReference]) -> [LifeGraphObjectReference] {
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

    private static func normalizedRequired(_ value: String, fallback: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? fallback : trimmed
    }

    private static func normalizedOptional(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              trimmed.isEmpty == false else {
            return nil
        }
        return trimmed
    }

    private static func orderedUniqueStrings(_ values: [String]) -> [String] {
        var seen = Set<String>()
        return values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
            .filter { seen.insert($0).inserted }
            .sorted()
    }

    private static func orderedUniqueNorthStarIDs(_ values: [NorthStarID]) -> [NorthStarID] {
        var seen = Set<NorthStarID>()
        return values
            .filter { seen.insert($0).inserted }
            .sorted()
    }
}

struct OneStepGoalSummary: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: OneStepGoalID
    let title: String
    let note: String?
    let lifeAreaID: LifeAreaID?
    let status: OneStepGoalStatus
    let timingLabel: String?
    let linkedActiveGoalCount: Int
    let proofCount: Int
    let receiptCount: Int
    let reviewCount: Int
    let canPromoteToGoal: Bool
    let canAttachToGoal: Bool
    let suggestedNextAction: String
    let privacyLevel: OneStepGoalPrivacyLevel
    let objectReference: LifeGraphObjectReference
    let relationshipHooks: OneStepGoalReferenceHooks
    let accessibility: OneStepGoalAccessibilityProjection

    init(oneStepGoal: OneStepGoal, linkedActiveGoalCount: Int, privacyLevel: OneStepGoalPrivacyLevel) {
        let hidden = privacyLevel == .redacted
        let visibleGoal = hidden ? oneStepGoal.redacted : oneStepGoal
        self.id = visibleGoal.id
        self.title = hidden ? "Private item" : visibleGoal.title
        self.note = hidden ? "Detail hidden" : visibleGoal.note
        self.lifeAreaID = visibleGoal.lifeAreaID
        self.status = visibleGoal.status
        self.timingLabel = hidden ? nil : visibleGoal.timing?.compactLabel
        self.linkedActiveGoalCount = linkedActiveGoalCount
        self.proofCount = visibleGoal.proofReferenceIDs.count
        self.receiptCount = visibleGoal.receiptReferenceIDs.count
        self.reviewCount = visibleGoal.reviewReferenceIDs.count
        self.canPromoteToGoal = visibleGoal.canBePromotedToGoal
        self.canAttachToGoal = visibleGoal.canAttachToGoal
        self.suggestedNextAction = Self.suggestedNextAction(for: visibleGoal)
        self.privacyLevel = privacyLevel
        self.objectReference = hidden
            ? LifeGraphObjectReference(kind: .oneStepGoal, id: visibleGoal.id.rawValue, label: "Private item", sourceDomain: .goals)
            : visibleGoal.objectReference
        self.relationshipHooks = visibleGoal.relationshipHooks
        self.accessibility = Self.accessibilityProjection(
            oneStepGoal: visibleGoal,
            hidden: hidden,
            linkedActiveGoalCount: linkedActiveGoalCount
        )
    }

    private static func suggestedNextAction(for oneStepGoal: OneStepGoal) -> String {
        switch oneStepGoal.status {
        case .ready:
            return "Ready when you are"
        case .today:
            return "Available today"
        case .scheduled:
            return "Review schedule"
        case .waiting:
            return "Waiting"
        case .reviewLater:
            return "Review later"
        case .parked:
            return "Parked"
        case .completed:
            return "Done"
        case .archived:
            return "Archived"
        }
    }

    private static func accessibilityProjection(
        oneStepGoal: OneStepGoal,
        hidden: Bool,
        linkedActiveGoalCount: Int
    ) -> OneStepGoalAccessibilityProjection {
        if hidden {
            return OneStepGoalAccessibilityProjection(
                label: "Private item",
                value: "\(oneStepGoal.status.displayName). Detail hidden.",
                hint: "This standalone One-Step Goal can be reviewed without exposing sensitive details."
            )
        }

        let timingValue = oneStepGoal.timing?.accessibilityValue
        let value = [
            oneStepGoal.status.displayName,
            timingValue?.isEmpty == false ? timingValue : nil,
            "\(linkedActiveGoalCount) linked active goal\(linkedActiveGoalCount == 1 ? "" : "s")"
        ].compactMap { $0 }.joined(separator: ". ")
        return OneStepGoalAccessibilityProjection(
            label: "One-Step Goal, \(oneStepGoal.title)",
            value: value,
            hint: "Standalone task. It can become or attach to a Goal only after confirmation."
        )
    }
}

struct OneStepGoalAreaSummary: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let lifeAreaID: LifeAreaID?
    let definition: LifeAreaDefinition?
    let displayName: String
    let oneStepGoals: [OneStepGoalSummary]
    let counts: OneStepGoalStatusCounts
    let emptyTitle: String
    let emptyMessage: String
    let privacyLevel: OneStepGoalPrivacyLevel
    let accessibility: OneStepGoalAccessibilityProjection
}

struct OneStepGoalStatusCounts: Codable, Sendable, Equatable, Hashable {
    let ready: Int
    let today: Int
    let scheduled: Int
    let waiting: Int
    let reviewLater: Int
    let parked: Int
    let completed: Int
    let archived: Int

    var total: Int {
        ready + today + scheduled + waiting + reviewLater + parked + completed + archived
    }

    var openCount: Int {
        ready + today + scheduled + waiting + reviewLater
    }
}

struct OneStepGoalsProjection: Codable, Sendable, Equatable, Hashable {
    let schemaVersion: String
    let title: String
    let subtitle: String
    let labels: [OneStepGoalLabelSummary]
    let filters: [OneStepGoalViewSummary]
    let savedViews: [OneStepGoalViewSummary]
    let areas: [OneStepGoalAreaSummary]
    let counts: OneStepGoalStatusCounts
    let emptyTitle: String
    let emptyMessage: String
    let privacyLevel: OneStepGoalPrivacyLevel
    let accessibility: OneStepGoalAccessibilityProjection

    var privacySafeCompact: OneStepGoalsProjection {
        OneStepGoalsProjection(
            schemaVersion: schemaVersion,
            title: title,
            subtitle: "One-Step Goals are available with sensitive details hidden.",
            labels: [],
            filters: filters.map(\.privacySafeCompact),
            savedViews: savedViews.map(\.privacySafeCompact),
            areas: areas.map { area in
                OneStepGoalAreaSummary(
                    id: area.id,
                    lifeAreaID: area.lifeAreaID,
                    definition: area.definition,
                    displayName: area.displayName,
                    oneStepGoals: area.oneStepGoals.map { summary in
                        OneStepGoalSummary(
                            oneStepGoal: OneStepGoal(
                                id: summary.id,
                                title: "Private item",
                                note: "Detail hidden",
                                lifeAreaID: summary.lifeAreaID,
                                status: summary.status,
                                linkedGoalIDs: summary.relationshipHooks.linkedGoalReferences.map(\.id),
                                proofReferenceIDs: summary.relationshipHooks.proofReferences.map(\.id),
                                receiptReferenceIDs: summary.relationshipHooks.receiptReferences.map(\.id),
                                decisionReferenceIDs: summary.relationshipHooks.decisionReferences.map(\.id),
                                reviewReferenceIDs: summary.relationshipHooks.reviewReferences.map(\.id),
                                isSensitive: true,
                                relationshipHooks: summary.relationshipHooks
                            ),
                            linkedActiveGoalCount: summary.linkedActiveGoalCount,
                            privacyLevel: .redacted
                        )
                    },
                    counts: area.counts,
                    emptyTitle: "No One-Step Goals here yet",
                    emptyMessage: "Standalone tasks can live here without becoming full goals.",
                    privacyLevel: .redacted,
                    accessibility: OneStepGoalAccessibilityProjection(
                        label: "One-Step Goals, \(area.displayName)",
                        value: "\(area.counts.total) One-Step Goals. Detail hidden.",
                        hint: "Sensitive standalone task details are hidden."
                    )
                )
            },
            counts: counts,
            emptyTitle: "No One-Step Goals yet",
            emptyMessage: "Quick standalone work can live here without becoming a full plan.",
            privacyLevel: .redacted
        )
    }

    init(
        schemaVersion: String = oneStepGoalSchemaVersion,
        title: String = "One-Step Goals",
        subtitle: String = "Standalone tasks held without becoming full plans.",
        labels: [OneStepGoalLabelSummary] = [],
        filters: [OneStepGoalViewSummary] = [],
        savedViews: [OneStepGoalViewSummary] = [],
        areas: [OneStepGoalAreaSummary],
        counts: OneStepGoalStatusCounts,
        emptyTitle: String = "No One-Step Goals yet",
        emptyMessage: String = "Quick standalone work can live here without becoming a full plan.",
        privacyLevel: OneStepGoalPrivacyLevel
    ) {
        self.schemaVersion = schemaVersion
        self.title = title
        self.subtitle = subtitle
        self.labels = labels
        self.filters = filters
        self.savedViews = savedViews
        self.areas = areas
        self.counts = counts
        self.emptyTitle = emptyTitle
        self.emptyMessage = emptyMessage
        self.privacyLevel = privacyLevel
        self.accessibility = OneStepGoalAccessibilityProjection(
            label: title,
            value: "\(counts.total) One-Step Goals. \(counts.openCount) open. \(counts.parked) parked.",
            hint: "One-Step Goals are standalone Tasks. Steps remain inside Goals, Paths, or Plans."
        )
    }
}
