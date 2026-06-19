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

extension OneStepGoalViewSummary {
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

    static func normalizedOptional(_ value: String?) -> String? {
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

    static func normalizedRequired(_ value: String, fallback: String) -> String {
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
