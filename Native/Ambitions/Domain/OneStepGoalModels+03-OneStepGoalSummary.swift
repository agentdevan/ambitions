import Foundation

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

    static func suggestedNextAction(for oneStepGoal: OneStepGoal) -> String {
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

    static func accessibilityProjection(
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
            hint: "One-Step Goal. It can become or attach to a Goal only after confirmation."
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
                    emptyMessage: "One-Step Goals can live here without becoming fuller goals.",
                    privacyLevel: .redacted,
                    accessibility: OneStepGoalAccessibilityProjection(
                        label: "One-Step Goals, \(area.displayName)",
                        value: "\(area.counts.total) One-Step Goals. Detail hidden.",
                        hint: "Sensitive One-Step Goal details are hidden."
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
        subtitle: String = "One-Step Goals held without becoming full plans.",
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
            hint: "One-Step Goals can stand alone. Steps remain inside Goals or Paths."
        )
    }
}
