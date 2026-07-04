import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedGoalsService {

    func archiveLearningLines(cards: [GoalsAtlasSurfaceState]) -> [String] {
        let archivedCards = cards.filter {
            [.parked, .completed, .cancelledDropped, .previous].contains($0.lifecycleState)
        }
        guard archivedCards.isEmpty == false else {
            return ["Archive learning will appear after a goal is completed, parked, or closed."]
        }

        return archivedCards.prefix(3).map { card in
            switch card.lifecycleState {
            case .completed:
                return "\(card.title): completed with \(card.proofSummary.title.lowercased())."
            case .cancelledDropped:
                return "\(card.title): closed without being treated as failure."
            case .parked:
                return "\(card.title): parked so attention can stay honest."
            case .previous:
                return "\(card.title): preserved as previous progress."
            default:
                return "\(card.title): kept in history."
            }
        }
    }


    struct GoalsLifeAreaFixtureDefinition: Sendable, Hashable {
        let id: String
        let title: String
        let summary: String
        let domainKey: LifeDomainKey?
    }


    static let equalWeightLifeAreaFixtures: [GoalsLifeAreaFixtureDefinition] = [
        .init(id: "music", title: "Music", summary: "Songs, practice, listening, and musical identity.", domainKey: nil),
        .init(id: "fitness", title: "Fitness", summary: "Training, strength, mobility, and physical practice.", domainKey: nil),
        .init(id: "finance", title: "Money", summary: "Money decisions, security, and practical resources.", domainKey: .finance),
        .init(id: "relationships", title: "Relationships", summary: "People, care, support, and shared responsibilities.", domainKey: .relationships),
        .init(id: "career", title: "Career", summary: "Work, calling, and visible contribution.", domainKey: .career),
        .init(id: "health", title: "Health", summary: "Body, recovery, energy, and care.", domainKey: .health),
        .init(id: "learning", title: "Learning", summary: "Learning, credentials, and skill-building.", domainKey: .education),
        .init(id: "home", title: "Home", summary: "Home, household, and the places life runs through.", domainKey: .home),
        .init(id: "creative", title: "Creative", summary: "Creative work, craft, and self-expression.", domainKey: .creativity),
        .init(id: "personal-growth", title: "Personal Growth", summary: "Identity, reflection, and becoming more yourself.", domainKey: .personalGrowth)
    ]

    static let lifeAreaControls: [GoalsLifeAreaControlState] = [
        .init(id: "reorder", title: "Reorder", systemImage: "arrow.up.arrow.down", accessibilityHint: "Changes area order manually without scoring areas."),
        .init(id: "pin", title: "Pin", systemImage: "pin", accessibilityHint: "Keeps an area visible without making it more important than other areas."),
        .init(id: "hide", title: "Hide", systemImage: "eye.slash", accessibilityHint: "Hides an area locally without deleting history."),
        .init(id: "rename", title: "Rename", systemImage: "pencil", accessibilityHint: "Renames the area in the user's language."),
        .init(id: "add", title: "Add", systemImage: "plus", accessibilityHint: "Adds a user-owned life area."),
        .init(id: "archive", title: "Archive", systemImage: "archivebox", accessibilityHint: "Archives an area without treating it as failure."),
        .init(id: "connect-today", title: "Connect Today", systemImage: "arrow.triangle.branch", accessibilityHint: "Shows how a thread feeds Today."),
        .init(id: "open-thread", title: "Open thread", systemImage: "arrow.up.right", accessibilityHint: "Opens the goal thread attached to an area.")
    ]

    func makeLifeAreasState(
        snapshot: Snapshot,
        cards: [GoalsAtlasSurfaceState],
        northStars: [NorthStar],
        oneStepGoals: [OneStepGoal]
    ) -> GoalsLifeAreasOverviewState {
        let cardsByGoalID = Dictionary(uniqueKeysWithValues: cards.compactMap { card in
            card.target.goalID.map { ($0, card) }
        })
        let projection = LifeAreaAtlasProjector().overview(
            from: .init(
                goals: snapshot.goals,
                goalThreadHierarchies: snapshot.goalThreadHierarchies,
                northStars: northStars,
                oneStepGoals: oneStepGoals,
                maxGoalReferencesPerArea: 3
            )
        )
        let contentAreas = projection.areas.filter(\.counts.hasContent)
        let projectedAreasByDomain = Dictionary(uniqueKeysWithValues: projection.areas.map { ($0.id.rawValue, $0) })
        let maxVisibleAreas = Self.equalWeightLifeAreaFixtures.count
        let items = Self.equalWeightLifeAreaFixtures.map { fixture in
            let area = fixture.domainKey.flatMap { projectedAreasByDomain[$0.lifeAreaID.rawValue] }
            let orderedGoalReferences = ((area?.activeGoals ?? []) + (area?.parkedGoals ?? []))
                .sorted { lhs, rhs in
                    (cardsByGoalID[lhs.id]?.manualPriorityRank ?? Int.max) < (cardsByGoalID[rhs.id]?.manualPriorityRank ?? Int.max)
                }
            let activeGoalReferences = Array(orderedGoalReferences.prefix(3))
            let threadLinkedGoals = orderedGoalReferences.compactMap { goalReference -> Goal? in
                snapshot.goals.first(where: { $0.id == goalReference.id })
            }
            let goalThreadSummary = area?.relationshipHooks.goalThreadReferences.first?.displayLabel
            let proofCount = threadLinkedGoals.reduce(0) { partialResult, goal in
                partialResult + (cardsByGoalID[goal.id]?.proofSummary.count ?? 0)
            }
            let goalReferences = activeGoalReferences.map { goal in
                let card = cardsByGoalID[goal.id]
                    return GoalAtlasPreviewItem(
                        id: goal.id,
                        title: goal.title,
                        subtitle: card?.nextVisibleStep.title ?? goal.summary ?? "Held in this Life Area",
                        state: card?.lifecycleState.visualState ?? visualState(for: goal.state)
                    )
                }
            let hasContent = area?.counts.hasContent ?? false
            let controlSummary = "Reorder, pin, hide, rename, add, archive, connect to Today, or open goal thread."
            let todayTraceSummary = goalThreadSummary.map { "Feeds Today through \($0)." } ?? "Ready to connect to Today when a thread belongs here."
            return GoalsLifeAreaItemState(
                id: fixture.id,
                title: fixture.title,
                subtitle: hasContent ? area?.compactSummary ?? "Equal-weight area" : "Equal-weight area",
                nextFocus: area?.nextFocus ?? fixture.summary,
                goalThreadSummary: goalThreadSummary,
                activeGoalCount: area?.counts.activeGoalCount ?? 0,
                parkedGoalCount: area?.counts.parkedGoalCount ?? 0,
                goalThreadCount: area?.counts.goalThreadCount ?? 0,
                northStarCount: area?.counts.northStarCount ?? 0,
                oneStepGoalCount: area?.counts.oneStepGoalCount ?? 0,
                proofCount: proofCount,
                receiptCount: area?.counts.receiptCount ?? 0,
                goalReferences: Array(goalReferences),
                isDefaultFixture: true,
                controlSummary: controlSummary,
                todayTraceSummary: todayTraceSummary,
                openThreadLabel: goalReferences.isEmpty ? "Open thread when ready" : "Open goal thread",
                state: area.map { visualState(for: $0.posture) } ?? .default,
                accessibilityLabel: "Life Area, \(fixture.title)",
                accessibilityValue: [
                    hasContent ? area?.accessibility.value ?? "Visible" : "No active thread yet",
                    "Equal-weight default area",
                    todayTraceSummary,
                    controlSummary
                ].compactMap { $0 }.joined(separator: ". "),
                accessibilityHint: "User controls visibility and order manually. Areas keep the same size and do not compete for attention."
            )
        }

        return GoalsLifeAreasOverviewState(
            title: "Life areas",
            subtitle: contentAreas.isEmpty
                ? "Ten default areas stay visible and user-controlled before any area has active work."
                : "Ten default areas stay equal-weight while source, proof, and Today traces explain the active threads.",
            items: Array(items),
            contentAreaCount: contentAreas.count,
            emptyTitle: projection.emptyTitle,
            emptyMessage: projection.emptyMessage,
            availableZoomModes: GoalsSemanticZoomMode.allCases,
            controls: Self.lifeAreaControls,
            supportsListFallback: true,
            maxVisibleAreas: maxVisibleAreas,
            equalWeightSummary: "Music, Fitness, Money, Relationships, Career, Health, Learning, Home, Creative, and Personal Growth stay equal-weight by default.",
            accessibilityLabel: "Life areas",
            accessibilityValue: "Equal-weight default areas: \(Self.equalWeightLifeAreaFixtures.map(\.title).joined(separator: ", ")). \(projection.accessibility.value)",
            accessibilityHint: "Map view has a list fallback and never adds a top-level tab. Controls are manual and local: reorder, pin, hide, rename, add, archive, connect to Today, and open goal thread."
        )
    }


    func makeNorthStarsRailState(
        northStars: [NorthStar],
        goals: [Goal]
    ) -> GoalsNorthStarsRailState {
        let projection = NorthStarProjector().projection(
            from: NorthStarProjector.Input(
                northStars: northStars,
                goals: goals,
                includeArchived: false,
                maxNorthStarsPerArea: 4
            )
        )
        let items = projection.areas.flatMap { area in
            area.northStars.map { northStar in
                GoalsNorthStarRailItemState(
                    id: northStar.id.rawValue,
                    title: northStar.title,
                    subtitle: northStar.summary ?? northStar.activationReadiness.displayName,
                    lifeAreaLabel: area.definition?.displayName ?? "Area unavailable",
                    postureLabel: northStar.posture.displayName,
                    readinessLabel: northStar.activationReadiness.displayName,
                    suggestedNextAction: northStar.suggestedNextAction ?? "Held without pressure",
                    linkedActiveGoalCount: northStar.linkedActiveGoalCount,
                    canBeShaped: northStar.canBeShaped,
                    shapeIntoGoalLabel: northStar.shapeIntoGoalLabel,
                    state: visualState(for: northStar.posture),
                    accessibilityLabel: northStar.accessibility.label,
                    accessibilityValue: northStar.accessibility.value,
                    accessibilityHint: northStar.accessibility.hint
                )
            }
        }

        return GoalsNorthStarsRailState(
            title: projection.title,
            subtitle: projection.subtitle,
            items: Array(items.prefix(6)),
            totalCount: projection.counts.total,
            emptyTitle: projection.emptyTitle,
            emptyMessage: projection.emptyMessage,
            accessibilityLabel: projection.accessibility.label,
            accessibilityValue: projection.accessibility.value,
            accessibilityHint: projection.accessibility.hint
        )
    }


    func makeOneStepGoalsPanelState(
        oneStepGoals: [OneStepGoal],
        goals: [Goal]
    ) -> GoalsOneStepGoalsPanelState {
        let projection = OneStepGoalProjector().projection(
            from: OneStepGoalProjector.Input(
                oneStepGoals: oneStepGoals,
                goals: goals,
                includeArchived: false,
                maxOneStepGoalsPerArea: 4
            )
        )
        let items = projection.areas.flatMap { area in
            area.oneStepGoals.map { oneStepGoal in
                GoalsOneStepGoalPanelItemState(
                    id: oneStepGoal.id.rawValue,
                    title: oneStepGoal.title,
                    subtitle: oneStepGoal.note ?? oneStepGoal.suggestedNextAction,
                    areaLabel: area.displayName,
                    statusLabel: oneStepGoal.status.displayName,
                    timingLabel: oneStepGoal.timingLabel,
                    suggestedNextAction: oneStepGoal.suggestedNextAction,
                    canPromoteToGoal: oneStepGoal.canPromoteToGoal,
                    canAttachToGoal: oneStepGoal.canAttachToGoal,
                    promoteLabel: "Make this a goal",
                    attachLabel: "Attach to goal",
                    state: visualState(for: oneStepGoal.status),
                    accessibilityLabel: oneStepGoal.accessibility.label,
                    accessibilityValue: oneStepGoal.accessibility.value,
                    accessibilityHint: oneStepGoal.accessibility.hint
                )
            }
        }

        return GoalsOneStepGoalsPanelState(
            title: projection.title,
            subtitle: projection.subtitle,
            items: Array(items.prefix(5)),
            openCount: projection.counts.openCount,
            parkedCount: projection.counts.parked,
            emptyTitle: projection.emptyTitle,
            emptyMessage: projection.emptyMessage,
            accessibilityLabel: projection.accessibility.label,
            accessibilityValue: projection.accessibility.value,
            accessibilityHint: projection.accessibility.hint
        )
    }


    func oneStepGoals(from captures: [Capture], now: Date) -> [OneStepGoal] {
        captures.compactMap { capture -> OneStepGoal? in
            guard capture.linkedGoalID == nil else { return nil }
            switch capture.kind {
            case .oneTimeCommitment, .deadlineTask:
                break
            case .raw, .goalSeed, .goalSupportingTask, .deliverableSeed, .waitingItem, .optionalSomeday, .archiveItem:
                return nil
            }

            return OneStepGoal(
                id: OneStepGoalID(rawValue: "capture.\(capture.id)"),
                title: capture.rawText,
                note: nil,
                lifeAreaID: nil,
                status: oneStepGoalStatus(for: capture),
                timing: OneStepGoalTimingMetadata(
                    dueAt: nil,
                    dueLabel: capture.deadlineText,
                    reminderAt: nil,
                    reminderLabel: nil,
                    reviewAfter: nil
                ),
                source: .capture,
                sourceCaptureID: capture.id,
                createdAt: capture.createdAt,
                updatedAt: capture.updatedAt,
                lastReferencedAt: DomainTimestamp.string(from: now)
            )
        }
    }


    func oneStepGoalStatus(for capture: Capture) -> OneStepGoalStatus {
        switch capture.status {
        case .scheduled:
            return .scheduled
        case .waiting, .delegated:
            return .waiting
        case .optionalSomeday:
            return .parked
        case .archived:
            return .archived
        case .needsTriage, .seed:
            return .reviewLater
        case .actionable, .goalBound:
            return capture.deadlineKind == .hard ? .today : .ready
        }
    }
}
