import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedTodayService {
    func makeExperience(snapshot: Snapshot, userDisplayName: String, now: Date, entryContext: TodayEntryContext) async throws -> TodayExperience {
        let activeGoals = snapshot.goals.filter { $0.state == .active || $0.state == .paused }
        let learningSnapshot = learningService.buildSnapshot(
            goals: activeGoals,
            evidence: snapshot.evidence,
            feedback: snapshot.feedback,
            now: now
        )
        let sharedLifeSnapshot = sharedLifeService.buildSnapshot(
            goals: activeGoals,
            evidence: snapshot.evidence,
            feedback: snapshot.feedback,
            now: now
        )
        let draftsByGoalID: [String: PersistedGoalDraft] = Dictionary(uniqueKeysWithValues: snapshot.drafts.compactMap { draft in
            guard let plannedGoalID = draft.plannedGoalID else { return nil }
            return (plannedGoalID, draft)
        })
        let energyModelsByGoalID = draftsByGoalID.compactMapValues(\.metadata?.energyModel)
        let rankedSelections = selector.rankedSelections(
            goals: activeGoals,
            evidence: snapshot.evidence,
            feedback: snapshot.feedback,
            canonicalEnergyModelsByGoalID: energyModelsByGoalID,
            now: now
        )
        let allSteps = activeGoals.flatMap { $0.plan?.sections.flatMap(\.steps) ?? [] }
        let actionableSteps = rankedSelections.map(\.step)
        let shellSummaries = try await todayShellSummaries(
            goals: activeGoals,
            draftsByGoalID: draftsByGoalID,
            actionableSteps: actionableSteps,
            now: now
        )

        let clarificationDrafts = snapshot.drafts.filter { $0.latestResultKind == .clarificationRequired }
        let blockedDrafts = snapshot.drafts.filter { $0.latestResultKind == .blocked }

        let completedSteps = allSteps.filter { $0.state == .completed }.count
        let totalSteps = allSteps.count
        let completedToday = todayCompletionTitles(snapshot: snapshot, now: now)
        let frictionCount = snapshot.feedback.filter { event in
            switch event {
            case .skipped, .confused, .tooBig, .notRelevant, .askedForSmallerVersion:
                return true
            default:
                return false
            }
        }.count

        let mode: TodayExperienceMode = {
            if activeGoals.isEmpty && snapshot.drafts.isEmpty { return .empty }
            if snapshot.appState.lastSeedVersion == DemoSeedPipeline.seedVersion { return .seeded }
            return .active
        }()

        let header = makeHeader(
            mode: mode,
            userDisplayName: userDisplayName,
            now: now,
            activeGoals: activeGoals,
            actionableCount: actionableSteps.count,
            clarificationCount: clarificationDrafts.count,
            blockedCount: blockedDrafts.count
        )
        let ritual = makeRitual(
            snapshot: snapshot,
            activeGoals: activeGoals,
            learningSnapshot: learningSnapshot,
            sharedLifeSnapshot: sharedLifeSnapshot,
            now: now
        )
        let dailyTargets = makeDailyTargets(
            mode: mode,
            goals: activeGoals,
            actionableSteps: actionableSteps,
            draftsByGoalID: draftsByGoalID,
            completion: (completedSteps, totalSteps),
            shellSummaries: shellSummaries
        )
        let focus = makeFocus(
            clarificationDrafts: clarificationDrafts,
            blockedDrafts: blockedDrafts,
            rankedSelections: rankedSelections,
            actionableSteps: actionableSteps,
            goals: activeGoals,
            draftsByGoalID: draftsByGoalID,
            feedback: snapshot.feedback,
            evidence: snapshot.evidence,
            shellSummaries: shellSummaries
        )
        let freeTime = makeFreeTime(
            goals: activeGoals,
            actionableSteps: actionableSteps,
            draftsByGoalID: draftsByGoalID
        )
        let milestone = makeMilestone(
            goals: activeGoals,
            draftsByGoalID: draftsByGoalID,
            shellSummaries: shellSummaries
        )
        let momentum = makeMomentum(
            activeGoals: activeGoals,
            evidence: snapshot.evidence,
            completedToday: completedToday.count,
            frictionCount: frictionCount
        )
        let quickCapture = makeQuickCapture(goal: activeGoals.first, step: actionableSteps.first)
        let reflection = makeReflection(
            now: now,
            completedToday: completedToday,
            activeGoals: activeGoals,
            feedback: snapshot.feedback
        )

        let posture = dayPosture(
            mode: mode,
            entryContext: entryContext,
            frictionCount: frictionCount,
            clarificationCount: clarificationDrafts.count,
            blockedCount: blockedDrafts.count,
            actionableCount: actionableSteps.count
        )

        let hero = makeHero(
            header: header,
            ritual: ritual,
            focus: focus,
            dailyTargets: dailyTargets,
            freeTime: freeTime,
            milestone: milestone,
            posture: posture,
            entryContext: entryContext
        )
        let support = makeSupportLayer(
            now: now,
            posture: posture,
            entryContext: entryContext,
            focus: focus,
            dailyTargets: dailyTargets,
            freeTime: freeTime,
            milestone: milestone,
            momentum: momentum,
            quickCapture: quickCapture,
            reflection: reflection,
            completedToday: completedToday,
            shellSummary: focus.shellSummary ?? milestone.shellSummary
        )
        let cacheKey = TodayDerivedReadModelCacheKey(
            mode: mode,
            snapshot: snapshot,
            hero: hero,
            support: support,
            now: now,
            entryContext: entryContext
        )
        let execution: TodayExecutionViewState
        if let cached = derivedReadModelCache.value(for: cacheKey) {
            execution = cached
        } else {
            execution = TodayReadModelProjector(selector: selector).project(
                mode: mode,
                snapshot: snapshot,
                activeGoals: activeGoals,
                hero: hero,
                support: support,
                now: now,
                entryContext: entryContext
            )
            derivedReadModelCache.store(execution, for: cacheKey)
        }

        return TodayExperience(
            mode: mode,
            hero: hero,
            support: support,
            execution: execution
        )
    }

    func dayPosture(
        mode: TodayExperienceMode,
        entryContext: TodayEntryContext,
        frictionCount: Int,
        clarificationCount: Int,
        blockedCount: Int,
        actionableCount: Int
    ) -> TodayDayPosture {
        if mode == .empty {
            return .noPlan
        }
        switch entryContext.normalized {
        case .recovery:
            return .recovering
        case .stepSession:
            return .stable
        case .standard, .focus:
            break
        }
        if clarificationCount > 0 {
            return .lowData
        }
        if blockedCount > 0 {
            return .drifted
        }
        if frictionCount >= 4 || actionableCount >= 5 {
            return .overloaded
        }
        if frictionCount >= 2 || actionableCount >= 4 {
            return .tight
        }
        return .stable
    }

    func makeHero(
        header: TodayHeaderState,
        ritual: TodayRitualLoopState,
        focus: TodayFocusState,
        dailyTargets: TodayDailyTargetsState,
        freeTime: TodayFreeTimeState,
        milestone: TodayMilestoneState,
        posture: TodayDayPosture,
        entryContext: TodayEntryContext
    ) -> TodayHeroState {
        let heroSeed = heroSeed(from: focus, ritual: ritual, milestone: milestone)
        let trustWhisper = heroSeed.shellSummary.map { summary in
            TodayTrustWhisperState(
                title: "Why this now",
                detail: summary.explanationSummary,
                state: .selected
            )
        }
        let nextItem = nextHeroItem(from: dailyTargets, excluding: heroSeed.title) ?? nextHeroItem(from: freeTime)

        return TodayHeroState(
            truth: TodayHeroTruthState(
                greeting: header.greeting,
                dominantText: dominantText(for: posture, heroTitle: heroSeed.title),
                supportingText: heroSupportingText(for: posture, heroDetail: heroSeed.detail, ritual: ritual),
                nowTitle: heroSeed.title,
                nowSubtitle: heroSeed.detail,
                nextTitle: nextItem?.title,
                nextSubtitle: nextItem?.subtitle,
                posture: posture,
                contextPills: header.contextPills,
                trustWhisper: trustWhisper,
                shellSummary: heroSeed.shellSummary
            ),
            primaryAction: makePrimaryAction(
                posture: posture,
                entryContext: entryContext,
                focus: focus,
                freeTime: freeTime,
                milestone: milestone
            ),
            reentry: makeReentryState(entryContext: entryContext)
        )
    }

    func makeSupportLayer(
        now: Date,
        posture: TodayDayPosture,
        entryContext: TodayEntryContext,
        focus: TodayFocusState,
        dailyTargets: TodayDailyTargetsState,
        freeTime: TodayFreeTimeState,
        milestone: TodayMilestoneState,
        momentum: TodayMomentumState,
        quickCapture: TodayQuickCaptureState,
        reflection: TodayReflectionState,
        completedToday: [String],
        shellSummary: GoalShellSummaryState?
    ) -> TodaySupportLayerState {
        TodaySupportLayerState(
            timeAperture: makeTimeAperture(
                now: now,
                posture: posture,
                focus: focus,
                dailyTargets: dailyTargets,
                freeTime: freeTime,
                milestone: milestone,
                shellSummary: shellSummary
            ),
            recoveryBloom: makeRecoveryBloom(
                posture: posture,
                focus: focus,
                freeTime: freeTime
            ),
            stepSession: makeStepSession(
                entryContext: entryContext,
                focus: focus,
                posture: posture,
                shellSummary: shellSummary
            ),
            fixedCommitments: TodayFixedCommitmentsState(
                title: dailyTargets.title,
                summary: dailyTargets.subtitle,
                items: dailyTargets.items.map {
                    TodaySupportItemState(
                        id: $0.id,
                        title: $0.title,
                        subtitle: $0.subtitle,
                        label: $0.timingLabel,
                        state: $0.state,
                        action: $0.primaryAction ?? $0.secondaryAction
                    )
                },
                emptyMessage: dailyTargets.emptyMessage
            ),
            flexibleRoom: TodayFlexibleRoomState(
                title: freeTime.title,
                summary: freeTime.subtitle,
                items: freeTime.opportunities.map {
                    TodaySupportItemState(
                        id: $0.id,
                        title: $0.title,
                        subtitle: $0.subtitle,
                        label: $0.timingLabel,
                        state: $0.state,
                        action: $0.action
                    )
                },
                emptyMessage: freeTime.opportunities.isEmpty ? "Free space is allowed to stay free." : nil
            ),
            momentum: TodayMomentumStripState(
                title: momentum.title,
                summary: momentum.subtitle,
                metrics: momentum.metrics,
                note: momentum.note,
                celebrationLine: completedToday.isEmpty ? nil : "Momentum is already visible today."
            ),
            quickCaptureAction: quickCapture.actions.first,
            quickCaptureTitle: quickCapture.title,
            quickCaptureDetail: quickCapture.helpText,
            timeAction: TodayInlineAction(
                kind: .openTime,
                title: "Open Time",
                systemImage: "calendar",
                state: .default,
                target: TodayActionTarget()
            ),
            reflectionPrompt: reflection.prompt,
            reflectionHighlights: reflection.highlights
        )
    }

}
