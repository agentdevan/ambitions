import Foundation

struct LifeAreaSummary: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: LifeAreaID
    let definition: LifeAreaDefinition
    let posture: LifeAreaPosture
    let counts: LifeAreaCounts
    let activeGoals: [LifeAreaGoalReference]
    let parkedGoals: [LifeAreaGoalReference]
    let mostRelevantGoal: LifeAreaGoalReference?
    let nextFocus: String?
    let emptyTitle: String
    let emptyMessage: String
    let privacyLevel: LifeAreaPrivacyLevel
    let relationshipHooks: LifeAreaRelationshipHooks
    let accessibility: LifeAreaAccessibilityProjection

    var compactSummary: String {
        if privacyLevel == .redacted {
            return "Detail hidden"
        }
        if counts.activeGoalCount > 0 {
            return "\(counts.activeGoalCount) active goal\(counts.activeGoalCount == 1 ? "" : "s")"
        }
        if counts.parkedGoalCount > 0 {
            return "\(counts.parkedGoalCount) parked goal\(counts.parkedGoalCount == 1 ? "" : "s")"
        }
        if counts.goalThreadCount > 0 {
            return "\(counts.goalThreadCount) goal thread\(counts.goalThreadCount == 1 ? "" : "s")"
        }
        if counts.northStarCount > 0 {
            return "\(counts.northStarCount) North Star\(counts.northStarCount == 1 ? "" : "s")"
        }
        if counts.oneStepGoalCount > 0 {
            return "\(counts.oneStepGoalCount) One-Step Goal\(counts.oneStepGoalCount == 1 ? "" : "s")"
        }
        return emptyTitle
    }

    var redacted: LifeAreaSummary {
        LifeAreaSummary(
            definition: definition,
            posture: .unavailable,
            counts: counts,
            activeGoals: activeGoals.map { _ in LifeAreaGoalReference.redactedPlaceholder },
            parkedGoals: parkedGoals.map { _ in LifeAreaGoalReference.redactedPlaceholder },
            mostRelevantGoal: mostRelevantGoal.map { _ in LifeAreaGoalReference.redactedPlaceholder },
            nextFocus: "Detail hidden",
            privacyLevel: .redacted,
            relationshipHooks: relationshipHooks
        )
    }

    init(
        definition: LifeAreaDefinition,
        posture: LifeAreaPosture,
        counts: LifeAreaCounts,
        activeGoals: [LifeAreaGoalReference],
        parkedGoals: [LifeAreaGoalReference],
        mostRelevantGoal: LifeAreaGoalReference?,
        nextFocus: String?,
        emptyTitle: String = "No goals here yet",
        emptyMessage: String = "Organize this area when something belongs here.",
        privacyLevel: LifeAreaPrivacyLevel,
        relationshipHooks: LifeAreaRelationshipHooks
    ) {
        self.id = definition.id
        self.definition = definition
        self.posture = posture
        self.counts = counts
        self.activeGoals = activeGoals
        self.parkedGoals = parkedGoals
        self.mostRelevantGoal = mostRelevantGoal
        self.nextFocus = nextFocus
        self.emptyTitle = emptyTitle
        self.emptyMessage = emptyMessage
        self.privacyLevel = privacyLevel
        self.relationshipHooks = relationshipHooks
        self.accessibility = Self.accessibilityProjection(
            definition: definition,
            posture: posture,
            counts: counts,
            privacyLevel: privacyLevel
        )
    }

    private static func accessibilityProjection(
        definition: LifeAreaDefinition,
        posture: LifeAreaPosture,
        counts: LifeAreaCounts,
        privacyLevel: LifeAreaPrivacyLevel
    ) -> LifeAreaAccessibilityProjection {
        let value: String
        if privacyLevel == .redacted {
            value = "Private area. Detail hidden."
        } else {
            value = [
                posture.displayName,
                "\(counts.activeGoalCount) active",
                "\(counts.parkedGoalCount) parked",
                "\(counts.goalThreadCount) goal threads",
                "\(counts.northStarCount) North Stars",
                "\(counts.oneStepGoalCount) One-Step Goals",
                "\(counts.waitingCount) waiting",
                "\(counts.proofCount) proof",
                "\(counts.receiptCount) receipts"
            ].joined(separator: ", ")
        }
        return LifeAreaAccessibilityProjection(
            label: "Life Area, \(definition.displayName)",
            value: value,
            hint: "Map and list share the same ordered meaning. Reduce Motion keeps the same object meaning without relying on motion."
        )
    }
}

private extension LifeAreaGoalReference {
    static var redactedPlaceholder: LifeAreaGoalReference {
        LifeAreaGoalReference(
            id: "private-item",
            title: "Private item",
            summary: "Detail hidden",
            state: .active,
            relationshipKind: .independent,
            objectReference: LifeGraphObjectReference(kind: .goal, id: "private-item", label: "Private item", sourceDomain: .goals)
        )
    }

    init(
        id: String,
        title: String,
        summary: String?,
        state: GoalLifecycleState,
        relationshipKind: GoalRelationshipKind,
        objectReference: LifeGraphObjectReference
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.state = state
        self.relationshipKind = relationshipKind
        self.objectReference = objectReference
    }
}
