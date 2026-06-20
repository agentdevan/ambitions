import Foundation

let promiseLedgerSchemaVersion = "promise_ledger.native.v1"

enum CommitmentKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case promiseMade = "promise_made"
    case promiseReceived = "promise_received"
    case followUp = "follow_up"
    case obligation
    case checkIn = "check_in"
    case decisionNeeded = "decision_needed"
    case resourceNeeded = "resource_needed"
    case feedbackNeeded = "feedback_needed"
}

enum CommitmentDirection: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case userOwes = "user_owes"
    case userWaiting = "user_waiting"
    case mutual
    case informational
}

enum CommitmentState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case open
    case waiting
    case dueSoon = "due_soon"
    case overdue
    case done
    case parked
    case blocked
}

enum CommitmentSensitivity: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case low
    case normal
    case sensitive
}

enum WaitingReason: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case personResponse = "person_response"
    case feedback
    case resource
    case decision
    case money
    case timeWindow = "time_window"
    case externalEvent = "external_event"
    case calendarWindow = "calendar_window"
    case unknown
}

enum WaitingState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case waiting
    case followUpDue = "follow_up_due"
    case overdue
    case resolved
    case parked
    case blocked
}

enum SocialLoadSignalKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case waitingOnSomeone = "waiting_on_someone"
    case someoneWaitingOnYou = "someone_waiting_on_you"
    case overduePromise = "overdue_promise"
    case sensitiveFollowUp = "sensitive_follow_up"
    case lowStakesFollowUp = "low_stakes_follow_up"
}

struct ManualPersonReference: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let displayName: String
    let roleContextLabel: String?
    let sourceDomain: LifeGraphSourceDomain?
    let schemaVersion: String

    init(
        id: String,
        displayName: String,
        roleContextLabel: String? = nil,
        sourceDomain: LifeGraphSourceDomain? = nil,
        schemaVersion: String = promiseLedgerSchemaVersion
    ) {
        self.id = Self.normalizedRequired(id)
        self.displayName = Self.normalizedRequired(displayName)
        self.roleContextLabel = Self.normalizedOptional(roleContextLabel)
        self.sourceDomain = sourceDomain
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false && displayName.isEmpty == false
    }

    var lifeGraphObjectReference: LifeGraphObjectReference {
        LifeGraphObjectReference(
            kind: .person,
            id: id,
            label: displayName,
            sourceDomain: sourceDomain ?? .commitment
        )
    }

    func resourceReference(attachedTo object: LifeGraphObjectReference) -> ResourceReference {
        ResourceReference(
            id: "person-resource-\(id)",
            kind: .personReference,
            title: displayName,
            locator: "manual-person-reference:\(id)",
            summary: roleContextLabel,
            attachedObject: object,
            sourceDomain: sourceDomain ?? .commitment
        )
    }

    fileprivate var orderingKey: String {
        [
            displayName.lowercased(),
            roleContextLabel?.lowercased() ?? "",
            id
        ].joined(separator: ":")
    }

    fileprivate var dedupeKey: String {
        id.lowercased()
    }
}

struct CommitmentReference: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let summary: String?
    let kind: CommitmentKind
    let direction: CommitmentDirection
    let state: CommitmentState
    let relatedPerson: ManualPersonReference?
    let attachedObject: LifeGraphObjectReference?
    let dueOrFollowUpAt: String?
    let sensitivity: CommitmentSensitivity?
    let sourceDomain: LifeGraphSourceDomain?
    let schemaVersion: String

    init(
        id: String,
        title: String,
        summary: String? = nil,
        kind: CommitmentKind,
        direction: CommitmentDirection,
        state: CommitmentState = .open,
        relatedPerson: ManualPersonReference? = nil,
        attachedObject: LifeGraphObjectReference? = nil,
        dueOrFollowUpAt: String? = nil,
        sensitivity: CommitmentSensitivity? = nil,
        sourceDomain: LifeGraphSourceDomain? = nil,
        schemaVersion: String = promiseLedgerSchemaVersion
    ) {
        self.id = Self.normalizedRequired(id)
        self.title = Self.normalizedRequired(title)
        self.summary = Self.normalizedOptional(summary)
        self.kind = kind
        self.direction = direction
        self.state = state
        self.relatedPerson = relatedPerson
        self.attachedObject = attachedObject
        self.dueOrFollowUpAt = Self.normalizedOptional(dueOrFollowUpAt)
        self.sensitivity = sensitivity
        self.sourceDomain = sourceDomain
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            title.isEmpty == false &&
            (relatedPerson?.isWellFormed ?? true) &&
            (attachedObject?.isWellFormed ?? true)
    }

    var isOpenCommitment: Bool {
        switch state {
        case .open, .waiting, .dueSoon, .overdue, .blocked:
            return true
        case .done, .parked:
            return false
        }
    }

    var lifeGraphObjectReference: LifeGraphObjectReference {
        LifeGraphObjectReference(
            kind: .commitment,
            id: id,
            parentContextID: attachedObject?.id,
            label: title,
            sourceDomain: sourceDomain ?? .commitment
        )
    }

    fileprivate var orderingKey: String {
        [
            dueOrFollowUpAt ?? "",
            relatedPerson?.orderingKey ?? "",
            state.rawValue,
            kind.rawValue,
            title.lowercased(),
            id
        ].joined(separator: ":")
    }

    fileprivate var dedupeKey: String {
        id.lowercased()
    }
}

struct WaitingItemReference: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let summary: String?
    let reason: WaitingReason
    let state: WaitingState
    let relatedPerson: ManualPersonReference?
    let attachedObject: LifeGraphObjectReference?
    let dueOrFollowUpAt: String?
    let sourceDomain: LifeGraphSourceDomain?
    let schemaVersion: String

    init(
        id: String,
        title: String,
        summary: String? = nil,
        reason: WaitingReason,
        state: WaitingState = .waiting,
        relatedPerson: ManualPersonReference? = nil,
        attachedObject: LifeGraphObjectReference? = nil,
        dueOrFollowUpAt: String? = nil,
        sourceDomain: LifeGraphSourceDomain? = nil,
        schemaVersion: String = promiseLedgerSchemaVersion
    ) {
        self.id = Self.normalizedRequired(id)
        self.title = Self.normalizedRequired(title)
        self.summary = Self.normalizedOptional(summary)
        self.reason = reason
        self.state = state
        self.relatedPerson = relatedPerson
        self.attachedObject = attachedObject
        self.dueOrFollowUpAt = Self.normalizedOptional(dueOrFollowUpAt)
        self.sourceDomain = sourceDomain
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            title.isEmpty == false &&
            (relatedPerson?.isWellFormed ?? true) &&
            (attachedObject?.isWellFormed ?? true)
    }

    var isWaitingItem: Bool {
        switch state {
        case .waiting, .followUpDue, .overdue, .blocked:
            return true
        case .resolved, .parked:
            return false
        }
    }

    var lifeGraphObjectReference: LifeGraphObjectReference {
        LifeGraphObjectReference(
            kind: .waitingItem,
            id: id,
            parentContextID: attachedObject?.id,
            label: title,
            sourceDomain: sourceDomain ?? .commitment
        )
    }

    fileprivate var orderingKey: String {
        [
            dueOrFollowUpAt ?? "",
            relatedPerson?.orderingKey ?? "",
            state.rawValue,
            reason.rawValue,
            title.lowercased(),
            id
        ].joined(separator: ":")
    }

    fileprivate var dedupeKey: String {
        id.lowercased()
    }
}

struct SocialLoadSignal: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: SocialLoadSignalKind
    let title: String
    let relatedPerson: ManualPersonReference?
    let commitmentID: String?
    let waitingItemID: String?
}

struct PromiseLedgerProjection: Sendable, Equatable {
    let personReferences: [ManualPersonReference]
    let commitments: [CommitmentReference]
    let waitingItems: [WaitingItemReference]
    let socialLoadSignals: [SocialLoadSignal]
    let lifeGraphProjection: LifeGraphRelationshipProjection

    init(
        personReferences: [ManualPersonReference] = [],
        commitments: [CommitmentReference] = [],
        waitingItems: [WaitingItemReference] = []
    ) {
        self.commitments = Self.validOrderedUniqueCommitments(commitments)
        self.waitingItems = Self.validOrderedUniqueWaitingItems(waitingItems)
        self.personReferences = Self.validOrderedUniquePeople(
            personReferences +
                self.commitments.compactMap(\.relatedPerson) +
                self.waitingItems.compactMap(\.relatedPerson)
        )
        self.socialLoadSignals = Self.projectSocialLoadSignals(
            commitments: self.commitments,
            waitingItems: self.waitingItems
        )
        self.lifeGraphProjection = LifeGraphRelationshipProjection(
            relationships: Self.projectRelationships(
                commitments: self.commitments,
                waitingItems: self.waitingItems
            )
        )
    }

    var openCommitments: [CommitmentReference] {
        commitments.filter(\.isOpenCommitment)
    }

    var activeWaitingItems: [WaitingItemReference] {
        waitingItems.filter(\.isWaitingItem)
    }

    func commitments(for person: ManualPersonReference) -> [CommitmentReference] {
        commitments.filter { $0.relatedPerson?.dedupeKey == person.dedupeKey }
    }

    func waitingItems(for person: ManualPersonReference) -> [WaitingItemReference] {
        waitingItems.filter { $0.relatedPerson?.dedupeKey == person.dedupeKey }
    }

    func relationshipProjection(for object: LifeGraphObjectReference) -> LifeGraphRelationshipProjection {
        LifeGraphRelationshipProjection(
            relationships: lifeGraphProjection.relationships.filter {
                $0.source.stableKey == object.stableKey || $0.target.stableKey == object.stableKey
            }
        )
    }

    private static func validOrderedUniquePeople(_ people: [ManualPersonReference]) -> [ManualPersonReference] {
        validOrderedUnique(people, keyPath: \.dedupeKey, ordering: { $0.orderingKey < $1.orderingKey })
    }

    private static func validOrderedUniqueCommitments(_ commitments: [CommitmentReference]) -> [CommitmentReference] {
        validOrderedUnique(commitments, keyPath: \.dedupeKey, ordering: { $0.orderingKey < $1.orderingKey })
    }

    private static func validOrderedUniqueWaitingItems(_ waitingItems: [WaitingItemReference]) -> [WaitingItemReference] {
        validOrderedUnique(waitingItems, keyPath: \.dedupeKey, ordering: { $0.orderingKey < $1.orderingKey })
    }

    private static func validOrderedUnique<Value>(
        _ values: [Value],
        keyPath: KeyPath<Value, String>,
        ordering: (Value, Value) -> Bool
    ) -> [Value] where Value: Identifiable {
        var seen = Set<String>()
        return values
            .filter { value in
                switch value {
                case let person as ManualPersonReference:
                    return person.isWellFormed
                case let commitment as CommitmentReference:
                    return commitment.isWellFormed
                case let waitingItem as WaitingItemReference:
                    return waitingItem.isWellFormed
                default:
                    return true
                }
            }
            .sorted(by: ordering)
            .filter { seen.insert($0[keyPath: keyPath]).inserted }
    }

    private static func projectRelationships(
        commitments: [CommitmentReference],
        waitingItems: [WaitingItemReference]
    ) -> [LifeGraphRelationship] {
        commitments.flatMap(projectedRelationships) + waitingItems.flatMap(projectedRelationships)
    }

    private static func projectedRelationships(for commitment: CommitmentReference) -> [LifeGraphRelationship] {
        guard commitment.isWellFormed else { return [] }

        let commitmentObject = commitment.lifeGraphObjectReference
        var relationships: [LifeGraphRelationship] = []

        if let attachedObject = commitment.attachedObject {
            relationships.append(
                LifeGraphRelationship(
                    kind: commitment.relationshipKindToAttachedObject,
                    source: commitmentObject,
                    target: attachedObject,
                    note: commitment.summary
                )
            )
        }

        if let person = commitment.relatedPerson {
            relationships.append(
                LifeGraphRelationship(
                    kind: .relatesTo,
                    source: person.lifeGraphObjectReference,
                    target: commitmentObject,
                    note: person.roleContextLabel
                )
            )
        }

        return relationships
    }

    private static func projectedRelationships(for waitingItem: WaitingItemReference) -> [LifeGraphRelationship] {
        guard waitingItem.isWellFormed else { return [] }

        let waitingObject = waitingItem.lifeGraphObjectReference
        var relationships: [LifeGraphRelationship] = []

        if let attachedObject = waitingItem.attachedObject {
            relationships.append(
                LifeGraphRelationship(
                    kind: waitingItem.state == .blocked ? .blocks : .waitsOn,
                    source: waitingObject,
                    target: attachedObject,
                    note: waitingItem.summary
                )
            )
        }

        if let person = waitingItem.relatedPerson {
            relationships.append(
                LifeGraphRelationship(
                    kind: .relatesTo,
                    source: person.lifeGraphObjectReference,
                    target: waitingObject,
                    note: person.roleContextLabel
                )
            )
        }

        return relationships
    }

    private static func projectSocialLoadSignals(
        commitments: [CommitmentReference],
        waitingItems: [WaitingItemReference]
    ) -> [SocialLoadSignal] {
        let commitmentSignals = commitments.flatMap { commitment -> [SocialLoadSignal] in
            var signals: [SocialLoadSignal] = []

            if commitment.direction == .userOwes,
               commitment.state != .done,
               commitment.state != .parked {
                signals.append(
                    SocialLoadSignal(
                        id: "social-load:someone-waiting:\(commitment.id)",
                        kind: .someoneWaitingOnYou,
                        title: commitment.title,
                        relatedPerson: commitment.relatedPerson,
                        commitmentID: commitment.id,
                        waitingItemID: nil
                    )
                )
            }

            if commitment.state == .overdue {
                signals.append(
                    SocialLoadSignal(
                        id: "social-load:overdue-promise:\(commitment.id)",
                        kind: .overduePromise,
                        title: commitment.title,
                        relatedPerson: commitment.relatedPerson,
                        commitmentID: commitment.id,
                        waitingItemID: nil
                    )
                )
            }

            if commitment.kind == .followUp,
               commitment.sensitivity == .sensitive {
                signals.append(
                    SocialLoadSignal(
                        id: "social-load:sensitive-follow-up:\(commitment.id)",
                        kind: .sensitiveFollowUp,
                        title: commitment.title,
                        relatedPerson: commitment.relatedPerson,
                        commitmentID: commitment.id,
                        waitingItemID: nil
                    )
                )
            }

            if commitment.kind == .followUp,
               commitment.sensitivity == .low {
                signals.append(
                    SocialLoadSignal(
                        id: "social-load:low-stakes-follow-up:\(commitment.id)",
                        kind: .lowStakesFollowUp,
                        title: commitment.title,
                        relatedPerson: commitment.relatedPerson,
                        commitmentID: commitment.id,
                        waitingItemID: nil
                    )
                )
            }

            return signals
        }

        let waitingSignals = waitingItems
            .filter(\.isWaitingItem)
            .map { waitingItem in
                SocialLoadSignal(
                    id: "social-load:waiting-on-someone:\(waitingItem.id)",
                    kind: .waitingOnSomeone,
                    title: waitingItem.title,
                    relatedPerson: waitingItem.relatedPerson,
                    commitmentID: nil,
                    waitingItemID: waitingItem.id
                )
            }

        return (commitmentSignals + waitingSignals).sorted { lhs, rhs in
            if lhs.kind.rawValue != rhs.kind.rawValue {
                return lhs.kind.rawValue < rhs.kind.rawValue
            }
            if lhs.title.localizedCaseInsensitiveCompare(rhs.title) != .orderedSame {
                return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
            }
            return lhs.id < rhs.id
        }
    }
}

private extension CommitmentReference {
    var relationshipKindToAttachedObject: LifeGraphRelationshipKind {
        switch kind {
        case .promiseMade, .obligation, .checkIn:
            return .supports
        case .promiseReceived, .resourceNeeded, .feedbackNeeded:
            return .dependsOn
        case .followUp:
            return direction == .userWaiting ? .waitsOn : .relatesTo
        case .decisionNeeded:
            return .explains
        }
    }
}

private extension ManualPersonReference {
    static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func normalizedOptional(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              trimmed.isEmpty == false else {
            return nil
        }
        return trimmed
    }
}

private extension CommitmentReference {
    static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func normalizedOptional(_ value: String?) -> String? {
        ManualPersonReference.normalizedOptional(value)
    }
}

private extension WaitingItemReference {
    static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func normalizedOptional(_ value: String?) -> String? {
        ManualPersonReference.normalizedOptional(value)
    }
}
