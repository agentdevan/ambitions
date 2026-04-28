import Foundation

struct NorthStarProjector: Sendable {
    struct Input: Sendable {
        let northStars: [NorthStar]
        let goals: [Goal]
        let hiddenNorthStarIDs: Set<NorthStarID>
        let hiddenAreaIDs: Set<LifeAreaID>
        let privacyLevel: NorthStarPrivacyLevel
        let includeArchived: Bool
        let maxNorthStarsPerArea: Int

        init(
            northStars: [NorthStar],
            goals: [Goal] = [],
            hiddenNorthStarIDs: Set<NorthStarID> = [],
            hiddenAreaIDs: Set<LifeAreaID> = [],
            privacyLevel: NorthStarPrivacyLevel = .full,
            includeArchived: Bool = false,
            maxNorthStarsPerArea: Int = 4
        ) {
            self.northStars = northStars
            self.goals = goals
            self.hiddenNorthStarIDs = hiddenNorthStarIDs
            self.hiddenAreaIDs = hiddenAreaIDs
            self.privacyLevel = privacyLevel
            self.includeArchived = includeArchived
            self.maxNorthStarsPerArea = max(0, maxNorthStarsPerArea)
        }
    }

    func projection(from input: Input) -> NorthStarsProjection {
        let visibleNorthStars = input.northStars.filter { input.includeArchived || $0.posture.isArchived == false }
        let activeGoalIDs = Set(input.goals.filter { $0.state == .active }.map(\.id))
        let grouped = Dictionary(grouping: visibleNorthStars, by: \.primaryLifeAreaID)

        let canonicalAreas = LifeAreaDefinition.canonical.map { definition in
            areaSummary(
                id: definition.id,
                definition: definition,
                northStars: grouped[definition.id] ?? [],
                activeGoalIDs: activeGoalIDs,
                input: input
            )
        }

        let knownAreaIDs = Set(LifeAreaDefinition.canonical.map(\.id))
        let unknownAreas = grouped.keys
            .filter { knownAreaIDs.contains($0) == false }
            .sorted()
            .map { areaID in
                areaSummary(
                    id: areaID,
                    definition: nil,
                    northStars: grouped[areaID] ?? [],
                    activeGoalIDs: activeGoalIDs,
                    input: input
                )
            }

        let areas = (canonicalAreas + unknownAreas).sorted(by: areaOrdering)
        return NorthStarsProjection(
            areas: areas,
            counts: postureCounts(for: visibleNorthStars),
            privacyLevel: input.privacyLevel
        )
    }

    private func areaSummary(
        id: LifeAreaID,
        definition: LifeAreaDefinition?,
        northStars: [NorthStar],
        activeGoalIDs: Set<String>,
        input: Input
    ) -> NorthStarAreaSummary {
        let isAreaHidden = input.hiddenAreaIDs.contains(id) || input.privacyLevel == .redacted
        let ordered = northStars.sorted(by: northStarOrdering)
        let summaries = ordered
            .prefix(input.maxNorthStarsPerArea)
            .map { northStar in
                let privacyLevel: NorthStarPrivacyLevel = isAreaHidden || input.hiddenNorthStarIDs.contains(northStar.id) || northStar.isSensitive
                    ? .redacted
                    : input.privacyLevel
                let linkedActiveGoalCount = northStar.linkedGoalIDs.filter { activeGoalIDs.contains($0) }.count
                return NorthStarSummary(
                    northStar: northStar,
                    linkedActiveGoalCount: linkedActiveGoalCount,
                    privacyLevel: privacyLevel
                )
            }
        let counts = postureCounts(for: northStars)
        let areaName = definition?.displayName ?? "Area unavailable"
        return NorthStarAreaSummary(
            id: id,
            definition: definition,
            northStars: Array(summaries),
            counts: counts,
            emptyTitle: "No North Stars here yet",
            emptyMessage: "This Life Area can hold long-range direction without turning it into pressure.",
            privacyLevel: isAreaHidden ? .redacted : input.privacyLevel,
            accessibility: NorthStarAccessibilityProjection(
                label: "North Stars, \(areaName)",
                value: isAreaHidden
                    ? "\(counts.total) North Stars. Detail hidden."
                    : "\(counts.total) North Stars. \(counts.readyToShape) ready to shape. \(counts.dormant) dormant for now.",
                hint: "North Stars are organized under Life Areas and can exist without active goals."
            )
        )
    }

    private func areaOrdering(_ lhs: NorthStarAreaSummary, _ rhs: NorthStarAreaSummary) -> Bool {
        let leftRank = lhs.counts.total > 0 ? 0 : 1
        let rightRank = rhs.counts.total > 0 ? 0 : 1
        if leftRank != rightRank {
            return leftRank < rightRank
        }

        let leftOrder = lhs.definition?.canonicalOrder ?? Int.max
        let rightOrder = rhs.definition?.canonicalOrder ?? Int.max
        if leftOrder != rightOrder {
            return leftOrder < rightOrder
        }

        let leftName = lhs.definition?.displayName ?? lhs.id.rawValue
        let rightName = rhs.definition?.displayName ?? rhs.id.rawValue
        if leftName.localizedCaseInsensitiveCompare(rightName) != .orderedSame {
            return leftName.localizedCaseInsensitiveCompare(rightName) == .orderedAscending
        }
        return lhs.id.rawValue < rhs.id.rawValue
    }

    private func northStarOrdering(_ lhs: NorthStar, _ rhs: NorthStar) -> Bool {
        if postureRank(lhs.posture) != postureRank(rhs.posture) {
            return postureRank(lhs.posture) < postureRank(rhs.posture)
        }
        if lhs.lastReferencedAt != rhs.lastReferencedAt {
            return (lhs.lastReferencedAt ?? "") > (rhs.lastReferencedAt ?? "")
        }
        if lhs.updatedAt != rhs.updatedAt {
            return (lhs.updatedAt ?? "") > (rhs.updatedAt ?? "")
        }
        if lhs.primaryLifeAreaID != rhs.primaryLifeAreaID {
            return lhs.primaryLifeAreaID < rhs.primaryLifeAreaID
        }
        let titleCompare = lhs.title.localizedCaseInsensitiveCompare(rhs.title)
        if titleCompare != .orderedSame {
            return titleCompare == .orderedAscending
        }
        return lhs.id < rhs.id
    }

    private func postureRank(_ posture: NorthStarPosture) -> Int {
        switch posture {
        case .readyToShape, .activeDirection:
            return 0
        case .dormant:
            return 1
        case .parked, .needsReview:
            return 2
        case .archived:
            return 3
        }
    }

    private func postureCounts(for northStars: [NorthStar]) -> NorthStarPostureCounts {
        NorthStarPostureCounts(
            dormant: northStars.filter { $0.posture == .dormant }.count,
            activeDirection: northStars.filter { $0.posture == .activeDirection }.count,
            parked: northStars.filter { $0.posture == .parked }.count,
            readyToShape: northStars.filter { $0.posture == .readyToShape }.count,
            needsReview: northStars.filter { $0.posture == .needsReview }.count,
            archived: northStars.filter { $0.posture == .archived }.count
        )
    }
}
