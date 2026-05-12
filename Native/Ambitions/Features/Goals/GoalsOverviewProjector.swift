import Foundation

protocol GoalsOverviewProjecting {
    func makeOverview(from service: RepositoryBackedGoalsService) async throws -> GoalsOverview
}

struct GoalsOverviewProjector: GoalsOverviewProjecting {
    func makeOverview(from service: RepositoryBackedGoalsService) async throws -> GoalsOverview {
        let snapshot = try await service.loadSnapshot()
        let orderedIDs = service.normalizedPriorityOrder(snapshot: snapshot)
        let manualRanks = Dictionary(uniqueKeysWithValues: orderedIDs.enumerated().map { ($1, $0) })
        let learningSnapshot = service.learningService.buildSnapshot(
            goals: snapshot.goals,
            evidence: snapshot.evidence,
            feedback: snapshot.feedback,
            now: .now
        )
        let shellSummaries = try await service.overviewShellSummaries(snapshot: snapshot, now: .now)

        let goalItems = snapshot.goals.map { goal in
            service.makeGoalListItem(
                goal: goal,
                draft: snapshot.drafts.first(where: { $0.plannedGoalID == goal.id }),
                evidence: snapshot.evidence,
                feedback: snapshot.feedback,
                learningSummary: learningSnapshot.goalSummaries[goal.id],
                underrepresentedSignal: learningSnapshot.underrepresentedGoalSignals.first(where: { $0.goalID == goal.id }),
                manualRank: manualRanks[goal.id] ?? manualRanks.count,
                shellSummary: shellSummaries[goal.id]
            )
        }

        let draftItems = snapshot.drafts.compactMap { draft -> GoalListItem? in
            guard draft.plannedGoalID == nil else { return nil }
            return service.makeDraftListItem(
                draft: draft,
                manualRank: manualRanks[draft.id] ?? manualRanks.count,
                shellSummary: shellSummaries[draft.id]
            )
        }

        let items = goalItems + draftItems
        let cards = items.map { item in
            service.makeBoardCard(
                from: item,
                snapshot: snapshot,
                learningSummary: learningSnapshot.goalSummaries[item.target.goalID ?? ""]
            )
        }
        let activeCards = cards.filter { $0.lifecycleState.isCurrentPortfolioState || $0.renderState == .starter }
        let activeDirectionCards = activeCards
            .filter { $0.posture == .active || $0.lifecycleState == .protected }
            .sorted(by: service.boardPriorityDescriptor(lhs:rhs:))
        let pressuredCards = cards
            .filter { [.atRisk, .crowded, .stalled].contains($0.posture) || $0.lifecycleState == .waiting || $0.lifecycleState == .blocked }
            .sorted(by: service.boardPriorityDescriptor(lhs:rhs:))
        let recentMovementCards = activeCards
            .sorted(by: service.recentMovementDescriptor(lhs:rhs:))
            .prefix(3)
        let lowerPriorityCards = cards
            .filter { $0.posture == .lowerPriority || $0.posture == .achieved || $0.renderState == .onHold || $0.renderState == .achieved }
            .sorted(by: service.boardPriorityDescriptor(lhs:rhs:))
        let heroPrimaryAction = service.heroPrimaryAction(
            activeDirectionCards: activeDirectionCards,
            pressuredCards: pressuredCards,
            cards: cards
        )
        let oneStepGoals = service.oneStepGoals(from: snapshot.captures, now: .now)
        let northStars: [NorthStar] = []
        let lifeAreasState = service.makeLifeAreasState(
            snapshot: snapshot,
            cards: cards,
            northStars: northStars,
            oneStepGoals: oneStepGoals
        )
        let northStarsState = service.makeNorthStarsRailState(
            northStars: northStars,
            goals: snapshot.goals
        )
        let oneStepGoalsState = service.makeOneStepGoalsPanelState(
            oneStepGoals: oneStepGoals,
            goals: snapshot.goals
        )
        let weekPressureSummary = service.makeWeekPressureSummary(
            activeCount: activeCards.count,
            pressuredCount: pressuredCards.count,
            crowdedCount: pressuredCards.filter { $0.posture == .crowded }.count,
            stalledCount: pressuredCards.filter { $0.posture == .stalled }.count
        )
        let archiveSummary = service.makeArchiveSummary(cards: cards)
        let maturitySummary = service.makePortfolioMaturitySummary(
            cards: cards,
            oneStepGoals: oneStepGoals,
            archiveSummary: archiveSummary
        )
        let seeded = snapshot.appState.lastSeedVersion == DemoSeedPipeline.seedVersion

        return GoalsOverview(
            hero: service.makeHeroState(
                seeded: seeded,
                activeDirectionCards: activeDirectionCards,
                pressuredCards: pressuredCards,
                items: items,
                weekPressureSummary: weekPressureSummary
            ),
            heroPrimaryAction: heroPrimaryAction,
            bands: [
                GoalsBoardBand(
                    kind: .activeDirection,
                    title: "Active direction",
                    subtitle: activeDirectionCards.isEmpty
                        ? "The portfolio is quiet right now. The next step is to seed one live ambition."
                        : "The ambitions that are truly alive and still have believable momentum this week.",
                    cards: Array(activeDirectionCards.prefix(4))
                ),
                GoalsBoardBand(
                    kind: .pressure,
                    title: "Pressure points",
                    subtitle: pressuredCards.isEmpty
                        ? "Nothing is loudly off-track right now."
                        : "Where pressure, crowding, or drift is starting to distort the direction board.",
                    cards: Array(pressuredCards.prefix(4))
                ),
                GoalsBoardBand(
                    kind: .recentMovement,
                    title: "Recent movement",
                    subtitle: recentMovementCards.isEmpty
                        ? "Once a goal gets fresh evidence or a clearer step, it will surface here."
                        : "Visible momentum so you can see which ambitions are actually moving.",
                    cards: Array(recentMovementCards)
                )
            ],
            horizonLadder: service.makeHorizonLadder(
                activeDirectionCards: activeDirectionCards,
                pressuredCards: pressuredCards,
                snapshot: snapshot
            ),
            weekPressureSummary: weekPressureSummary,
            lowerPriority: GoalsLowerPriorityState(
                title: "Archive and quieter goals",
                subtitle: "Parked, completed, and cancelled goals stay part of the progress history without competing with live direction.",
                disclosureTitle: "Show archive",
                cards: lowerPriorityCards
            ),
            lifecycleRail: service.makeLifecycleRail(cards: cards),
            stateChips: service.makeStateChips(cards: cards),
            lifeAreas: lifeAreasState,
            northStars: northStarsState,
            oneStepGoals: oneStepGoalsState,
            atlasPreview: service.makeAtlasPreview(snapshot: snapshot, cards: cards, northStars: northStars, oneStepGoals: oneStepGoals),
            archiveSummary: archiveSummary,
            maturitySummary: maturitySummary,
            items: items,
            isSeeded: seeded,
            emptyTitle: "No goals yet",
            emptyMessage: "Once a goal or planning draft exists, this screen will immediately explain the path, not just dump steps."
        )
    }
}
