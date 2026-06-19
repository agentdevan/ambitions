import Foundation

struct OneStepGoalProjector: Sendable {
    struct Input: Sendable {
        let oneStepGoals: [OneStepGoal]
        let goals: [Goal]
        let hiddenOneStepGoalIDs: Set<OneStepGoalID>
        let hiddenAreaIDs: Set<LifeAreaID>
        let privacyLevel: OneStepGoalPrivacyLevel
        let includeArchived: Bool
        let maxOneStepGoalsPerArea: Int

        init(
            oneStepGoals: [OneStepGoal],
            goals: [Goal] = [],
            hiddenOneStepGoalIDs: Set<OneStepGoalID> = [],
            hiddenAreaIDs: Set<LifeAreaID> = [],
            privacyLevel: OneStepGoalPrivacyLevel = .full,
            includeArchived: Bool = false,
            maxOneStepGoalsPerArea: Int = 5
        ) {
            self.oneStepGoals = oneStepGoals
            self.goals = goals
            self.hiddenOneStepGoalIDs = hiddenOneStepGoalIDs
            self.hiddenAreaIDs = hiddenAreaIDs
            self.privacyLevel = privacyLevel
            self.includeArchived = includeArchived
            self.maxOneStepGoalsPerArea = max(0, maxOneStepGoalsPerArea)
        }
    }

    func projection(from input: Input) -> OneStepGoalsProjection {
        let visibleOneStepGoals = input.oneStepGoals.filter { input.includeArchived || $0.status.isArchived == false }
        let activeGoalIDs = Set(input.goals.filter { $0.state == .active }.map(\.id))
        let labelEligibleOneStepGoals = visibleOneStepGoals.filter { oneStepGoal in
            isLabelVisible(oneStepGoal, input: input)
        }
        let labels = labelSummaries(for: labelEligibleOneStepGoals)
        let viewSummaries = viewSummaries(for: labelEligibleOneStepGoals, labelSummaries: labels)
        let groupedByArea = Dictionary(grouping: visibleOneStepGoals.compactMap { oneStepGoal -> (LifeAreaID, OneStepGoal)? in
            guard let lifeAreaID = oneStepGoal.lifeAreaID else { return nil }
            return (lifeAreaID, oneStepGoal)
        }, by: \.0).mapValues { pairs in pairs.map(\.1) }
        let standalone = visibleOneStepGoals.filter { $0.lifeAreaID == nil }

        let canonicalAreas = LifeAreaDefinition.canonical.map { definition in
            areaSummary(
                id: definition.id.rawValue,
                lifeAreaID: definition.id,
                definition: definition,
                displayName: definition.displayName,
                oneStepGoals: groupedByArea[definition.id] ?? [],
                activeGoalIDs: activeGoalIDs,
                input: input
            )
        }

        let knownAreaIDs = Set(LifeAreaDefinition.canonical.map(\.id))
        let unknownAreas = groupedByArea.keys
            .filter { knownAreaIDs.contains($0) == false }
            .sorted()
            .map { areaID in
                areaSummary(
                    id: areaID.rawValue,
                    lifeAreaID: areaID,
                    definition: nil,
                    displayName: "Area unavailable",
                    oneStepGoals: groupedByArea[areaID] ?? [],
                    activeGoalIDs: activeGoalIDs,
                    input: input
                )
            }

        let standaloneArea = standalone.isEmpty ? [] : [
            areaSummary(
                id: "standalone",
                lifeAreaID: nil,
                definition: nil,
                displayName: "No Life Area",
                oneStepGoals: standalone,
                activeGoalIDs: activeGoalIDs,
                input: input
            )
        ]

        let areas = (canonicalAreas + unknownAreas + standaloneArea).sorted(by: areaOrdering)
        return OneStepGoalsProjection(
            labels: labels,
            filters: viewSummaries,
            savedViews: viewSummaries,
            areas: areas,
            counts: statusCounts(for: visibleOneStepGoals),
            privacyLevel: input.privacyLevel
        )
    }

    private func labelSummaries(for oneStepGoals: [OneStepGoal]) -> [OneStepGoalLabelSummary] {
        var taggedGoalIDs: [String: [OneStepGoalID]] = [:]

        for oneStepGoal in oneStepGoals {
            for tag in oneStepGoal.localLabelTags {
                taggedGoalIDs[tag, default: []].append(oneStepGoal.id)
            }
        }

        return taggedGoalIDs
            .map { tag, goalIDs in
                OneStepGoalLabelSummary(
                    id: tag,
                    title: labelTitle(for: tag),
                    count: goalIDs.count,
                    goalIDs: goalIDs
                )
            }
            .sorted { lhs, rhs in
                if lhs.count != rhs.count {
                    return lhs.count > rhs.count
                }
                let titleOrder = lhs.title.localizedCaseInsensitiveCompare(rhs.title)
                if titleOrder != .orderedSame {
                    return titleOrder == .orderedAscending
                }
                return lhs.id < rhs.id
            }
    }

    private func isLabelVisible(_ oneStepGoal: OneStepGoal, input: Input) -> Bool {
        if input.privacyLevel == .redacted {
            return false
        }

        if input.hiddenOneStepGoalIDs.contains(oneStepGoal.id) || oneStepGoal.isSensitive {
            return false
        }

        if let lifeAreaID = oneStepGoal.lifeAreaID, input.hiddenAreaIDs.contains(lifeAreaID) {
            return false
        }

        return true
    }

    private func viewSummaries(
        for oneStepGoals: [OneStepGoal],
        labelSummaries: [OneStepGoalLabelSummary]
    ) -> [OneStepGoalViewSummary] {
        let allGoalIDs = oneStepGoals.map(\.id)
        let labelIDs = labelSummaries.map(\.id)
        return OneStepGoalSavedViewKind.allCases.map { kind in
            if kind == .labelsTags {
                return OneStepGoalViewSummary(
                    id: kind.rawValue,
                    kind: kind,
                    title: kind.displayName,
                    count: labelSummaries.count,
                    goalIDs: allGoalIDs,
                    criteriaTags: labelIDs,
                    criteriaDescription: kind.criteriaDescription
                )
            }

            let matchingGoals = oneStepGoals
                .filter { oneStepGoal in
                    let tags = Set(oneStepGoal.localLabelTags)
                    return kind.criteriaTags.allSatisfy(tags.contains)
                }

            return OneStepGoalViewSummary(
                id: kind.rawValue,
                kind: kind,
                title: kind.displayName,
                count: matchingGoals.count,
                goalIDs: matchingGoals.map(\.id),
                criteriaTags: kind.criteriaTags,
                criteriaDescription: kind.criteriaDescription
            )
        }
    }

    private func labelTitle(for tag: String) -> String {
        switch tag {
        case "open":
            return "Open"
        case "today":
            return "Today"
        case "scheduled":
            return "Scheduled"
        case "upcoming":
            return "Upcoming"
        case "waiting":
            return "Waiting"
        case "blocked":
            return "Blocked"
        case "held":
            return "Held"
        case "someday_future":
            return "Someday / Future"
        case "proof_needed":
            return "Proof Needed"
        case "needs_review":
            return "Needs Review"
        case "source_needed":
            return "Source Needed"
        case "done":
            return "Done"
        case "archived":
            return "Archived"
        case OneStepGoalSource.manual.rawValue:
            return "Manual"
        case OneStepGoalSource.capture.rawValue:
            return "Capture"
        case OneStepGoalSource.smartAttachment.rawValue:
            return "Smart Attachment"
        case OneStepGoalSource.command.rawValue:
            return "Command"
        case OneStepGoalSource.demotedGoal.rawValue:
            return "Demoted goal"
        case OneStepGoalSource.review.rawValue:
            return "Review"
        default:
            return tag.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }

    private func areaSummary(
        id: String,
        lifeAreaID: LifeAreaID?,
        definition: LifeAreaDefinition?,
        displayName: String,
        oneStepGoals: [OneStepGoal],
        activeGoalIDs: Set<String>,
        input: Input
    ) -> OneStepGoalAreaSummary {
        let isAreaHidden = lifeAreaID.map { input.hiddenAreaIDs.contains($0) } ?? false
        let ordered = oneStepGoals.sorted(by: oneStepGoalOrdering)
        let summaries = ordered
            .prefix(input.maxOneStepGoalsPerArea)
            .map { oneStepGoal in
                let privacyLevel: OneStepGoalPrivacyLevel = isAreaHidden ||
                    input.hiddenOneStepGoalIDs.contains(oneStepGoal.id) ||
                    oneStepGoal.isSensitive ||
                    input.privacyLevel == .redacted
                    ? .redacted
                    : input.privacyLevel
                return OneStepGoalSummary(
                    oneStepGoal: oneStepGoal,
                    linkedActiveGoalCount: oneStepGoal.linkedGoalIDs.filter { activeGoalIDs.contains($0) }.count,
                    privacyLevel: privacyLevel
                )
            }
        let counts = statusCounts(for: oneStepGoals)
        let areaPrivacy: OneStepGoalPrivacyLevel = isAreaHidden || input.privacyLevel == .redacted ? .redacted : input.privacyLevel
        return OneStepGoalAreaSummary(
            id: id,
            lifeAreaID: lifeAreaID,
            definition: definition,
            displayName: displayName,
            oneStepGoals: Array(summaries),
            counts: counts,
            emptyTitle: "No One-Step Goals here yet",
            emptyMessage: lifeAreaID == nil
                ? "One-Step Goals can wait here without becoming a fuller goal."
                : "Small One-Step Goals can live under this Life Area.",
            privacyLevel: areaPrivacy,
            accessibility: OneStepGoalAccessibilityProjection(
                label: "One-Step Goals, \(displayName)",
                value: areaPrivacy == .redacted
                    ? "\(counts.total) One-Step Goals. Detail hidden."
                    : "\(counts.total) One-Step Goals. \(counts.openCount) open. \(counts.parked) parked.",
                hint: "One-Step Goals can stand alone. They do not create Goals automatically."
            )
        )
    }

    private func areaOrdering(_ lhs: OneStepGoalAreaSummary, _ rhs: OneStepGoalAreaSummary) -> Bool {
        let leftRank = lhs.counts.total > 0 ? 0 : 1
        let rightRank = rhs.counts.total > 0 ? 0 : 1
        if leftRank != rightRank {
            return leftRank < rightRank
        }

        let leftOrder = lhs.definition?.canonicalOrder ?? (lhs.lifeAreaID == nil ? Int.max - 1 : Int.max)
        let rightOrder = rhs.definition?.canonicalOrder ?? (rhs.lifeAreaID == nil ? Int.max - 1 : Int.max)
        if leftOrder != rightOrder {
            return leftOrder < rightOrder
        }

        if lhs.displayName.localizedCaseInsensitiveCompare(rhs.displayName) != .orderedSame {
            return lhs.displayName.localizedCaseInsensitiveCompare(rhs.displayName) == .orderedAscending
        }
        return lhs.id < rhs.id
    }

    private func oneStepGoalOrdering(_ lhs: OneStepGoal, _ rhs: OneStepGoal) -> Bool {
        if statusRank(lhs.status) != statusRank(rhs.status) {
            return statusRank(lhs.status) < statusRank(rhs.status)
        }
        if lhs.timing?.dueAt != rhs.timing?.dueAt {
            return (lhs.timing?.dueAt ?? "9999-12-31T23:59:59Z") < (rhs.timing?.dueAt ?? "9999-12-31T23:59:59Z")
        }
        if lhs.lastReferencedAt != rhs.lastReferencedAt {
            return (lhs.lastReferencedAt ?? "") > (rhs.lastReferencedAt ?? "")
        }
        if lhs.updatedAt != rhs.updatedAt {
            return (lhs.updatedAt ?? "") > (rhs.updatedAt ?? "")
        }
        let leftArea = lhs.lifeAreaID?.rawValue ?? "zzzz-standalone"
        let rightArea = rhs.lifeAreaID?.rawValue ?? "zzzz-standalone"
        if leftArea != rightArea {
            return leftArea < rightArea
        }
        let titleCompare = lhs.title.localizedCaseInsensitiveCompare(rhs.title)
        if titleCompare != .orderedSame {
            return titleCompare == .orderedAscending
        }
        return lhs.id < rhs.id
    }

    private func statusRank(_ status: OneStepGoalStatus) -> Int {
        switch status {
        case .today, .ready, .scheduled:
            return 0
        case .waiting, .reviewLater:
            return 1
        case .parked:
            return 2
        case .completed:
            return 3
        case .archived:
            return 4
        }
    }

    private func statusCounts(for oneStepGoals: [OneStepGoal]) -> OneStepGoalStatusCounts {
        OneStepGoalStatusCounts(
            ready: oneStepGoals.filter { $0.status == .ready }.count,
            today: oneStepGoals.filter { $0.status == .today }.count,
            scheduled: oneStepGoals.filter { $0.status == .scheduled }.count,
            waiting: oneStepGoals.filter { $0.status == .waiting }.count,
            reviewLater: oneStepGoals.filter { $0.status == .reviewLater }.count,
            parked: oneStepGoals.filter { $0.status == .parked }.count,
            completed: oneStepGoals.filter { $0.status == .completed }.count,
            archived: oneStepGoals.filter { $0.status == .archived }.count
        )
    }
}
