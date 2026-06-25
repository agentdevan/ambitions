import Foundation

extension DefaultMemoryLensService {
    func prioritizationOrder(seedIntent: ShellCommandIntent?, origin: AmbitionsSurface?) -> [MemoryLensResultKind: Int] {
        switch seedIntent {
        case .openGoal:
            return [.goal: 0, .step: 1, .whyNow: 2, .recentChange: 3, .teaching: 4, .learning: 5, .proof: 6, .capture: 7, .timeWindow: 8, .setting: 9]
        case .openCapture:
            return [.capture: 0, .thought: 1, .goal: 2, .step: 3, .recentChange: 4, .whyNow: 5, .proof: 6, .timeWindow: 7, .setting: 8]
        case .openWeek:
            return [.timeWindow: 0, .step: 1, .recentChange: 2, .whyNow: 3, .capture: 4, .goal: 5, .proof: 6, .setting: 7]
        default:
            switch origin {
            case .today:
                return [.step: 0, .whyNow: 1, .goal: 2, .recentChange: 3, .capture: 4, .proof: 5, .timeWindow: 6, .setting: 7]
            case .goals:
                return [.goal: 0, .step: 1, .whyNow: 2, .proof: 3, .teaching: 4, .learning: 5, .capture: 6, .timeWindow: 7, .setting: 8]
            case .time:
                return [.timeWindow: 0, .step: 1, .goal: 2, .recentChange: 3, .capture: 4, .proof: 5, .setting: 6]
            case .you:
                return [.setting: 0, .receipt: 1, .proof: 2, .recentChange: 3, .goal: 4, .capture: 5, .timeWindow: 6]
            case nil:
                return [.step: 0, .whyNow: 1, .goal: 2, .capture: 3, .proof: 4, .recentChange: 5, .timeWindow: 6, .setting: 7]
            }
        }
    }

    func makeTimeResults() -> [MemoryLensResult] {
        [
            MemoryLensResult(
                id: "time-root",
                title: "Open Time",
                subtitle: "Capacity and protected windows.",
                explanation: "Open the current Time surface without changing the calendar.",
                queryText: "time capacity protected window fixed point schedule week today",
                timestamp: "9999-12-31T23:59:59Z",
                kind: .timeWindow,
                facet: .open,
                actionTitle: "Open Time",
                destination: .tab(.time)
            ),
            MemoryLensResult(
                id: "time-weekly-review",
                title: "Weekly Review",
                subtitle: "Review the current week.",
                explanation: "Open the existing weekly review route.",
                queryText: "weekly review time week",
                timestamp: "9999-12-31T23:59:58Z",
                kind: .timeWindow,
                facet: .open,
                actionTitle: "Open review",
                destination: .timeRoute(.weeklyReview)
            )
        ]
    }

    func makeSettingResults() -> [MemoryLensResult] {
        let settings: [(YouRouteTarget, String, String)] = [
            (.appearance, "Appearance", "System, Light, Dark, and accent."),
            (.capturePreferences, "Capture", "Input, dictation, attachments, and teaching state."),
            (.lifeAreas, "Life Areas", "Defaults and customization ownership."),
            (.privacy, "Privacy", "Local data and privacy controls."),
            (.localDataControls, "Local Data", "On-device data controls."),
            (.sourceSettings, "Sources", "Permissions, freshness, and source inspection."),
            (.receiptsHistory, "Receipts", "Saved receipts and history."),
            (.accessibility, "Accessibility", "System settings and app support status."),
            (.about, "About", "Version, privacy, legal, and diagnostics status.")
        ]
        return settings.map { route, title, subtitle in
            MemoryLensResult(
                id: "you-\(route.rawValue)",
                title: title,
                subtitle: subtitle,
                explanation: "Open the existing You settings route.",
                queryText: [title, subtitle, route.rawValue].joined(separator: " "),
                timestamp: "9999-12-31T23:59:57Z",
                kind: .setting,
                facet: .open,
                actionTitle: "Open",
                destination: .youRoute(route)
            )
        }
    }

    func makeStepResults(goals: [Goal], actionableSteps: [Step]) -> [MemoryLensResult] {
        let goalByStepID = goals.reduce(into: [String: Goal]()) { partialResult, goal in
            for step in goal.plan?.sections.flatMap(\.steps) ?? [] {
                partialResult[step.id] = goal
            }
        }
        let planSteps = goals.flatMap { goal in
            (goal.plan?.sections.flatMap(\.steps) ?? []).map { step in
                stepResult(step, goal: goal)
            }
        }
        let unlistedActionable = actionableSteps.compactMap { step -> MemoryLensResult? in
            guard let goal = goalByStepID[step.id] else {
                return nil
            }
            return stepResult(step, goal: goal)
        }
        var seen = Set<String>()
        return (planSteps + unlistedActionable).filter { result in
            seen.insert(result.id).inserted
        }
    }

    func stepResult(_ step: Step, goal: Goal) -> MemoryLensResult {
        MemoryLensResult(
            id: "step-\(goal.id)-\(step.id)",
            title: step.title,
            subtitle: "\(goal.title). \(step.state.searchTitle).",
            explanation: "Open the goal that owns this Step.",
            queryText: [step.title, step.summary ?? "", goal.title, step.state.searchTitle, step.successSignals.joined(separator: " ")].joined(separator: " "),
            timestamp: goal.updatedAt,
            kind: .step,
            facet: .open,
            actionTitle: "Open step",
            destination: .goal(goal.id)
        )
    }

    func makeProofResults(_ evidence: [ProgressEvidence], goals: [Goal]) -> [MemoryLensResult] {
        let goalByID = Dictionary(uniqueKeysWithValues: goals.map { ($0.id, $0) })
        return evidence.map { item in
            let goal = goalByID[item.goalID]
            return MemoryLensResult(
                id: "proof-\(item.id)",
                title: item.note?.isEmpty == false ? item.note! : item.evidenceKind.searchTitle,
                subtitle: goal.map { "History for \($0.title)." } ?? "Saved history.",
                explanation: "Open the goal or local history for this saved change.",
                queryText: [
                    item.note ?? "",
                    item.evidenceKind.searchTitle,
                    goal?.title ?? "",
                    item.stepID ?? ""
                ].joined(separator: " "),
                timestamp: item.capturedAt,
                kind: .proof,
                facet: .open,
                actionTitle: goal == nil ? "Open history" : "Review history",
                destination: goal.map { .goal($0.id) } ?? .youRoute(.receiptsHistory)
            )
        }
    }

    func makeGoalResults(_ goals: [Goal]) -> [MemoryLensResult] {
        goals.map { goal in
            MemoryLensResult(
                id: "goal-\(goal.id)",
                title: goal.title,
                subtitle: goal.summary ?? goal.mode.displayTitle,
                explanation: "Open Goal Detail.",
                queryText: ([goal.title, goal.summary, goal.mode.displayTitle].compactMap { $0 } + goal.tags).joined(separator: " "),
                timestamp: goal.updatedAt,
                kind: .goal,
                facet: .open,
                actionTitle: "Open goal",
                destination: .goal(goal.id)
            )
        }
    }

    func makeCaptureResults(_ captures: [Capture]) -> [MemoryLensResult] {
        captures.map { capture in
            let destination: ShellCommandDestination = capture.linkedGoalID.map { .goal($0) } ?? .overlay(
                .commandSheet(intent: .quickCapture, entrySource: .shellUtility, presentationContext: .quickCapture)
            )
            return MemoryLensResult(
                id: "capture-\(capture.id)",
                title: capture.rawText,
                subtitle: capture.triage?.destination?.title ?? capture.status.title,
                explanation: capture.linkedGoalID == nil ? "Open Capture before this becomes work." : "Open the linked goal.",
                queryText: [capture.rawText, capture.triage?.destination?.title, capture.status.title].compactMap { $0 }.joined(separator: " "),
                timestamp: capture.updatedAt,
                kind: capture.kind == .raw ? .thought : .capture,
                facet: .open,
                actionTitle: capture.linkedGoalID == nil ? "Open Capture" : "Open goal",
                destination: destination
            )
        }
    }

    func makeFeedbackResults(_ feedback: [GoalFeedbackEvent], goals: [Goal]) -> [MemoryLensResult] {
        feedback.map { event in
            let title: String
            let explanation: String
            switch event {
            case .completed:
                title = "Completion captured"
                explanation = "The plan now has proof of movement."
            case .skipped:
                title = "Skip recorded"
                explanation = "The skip is useful context for reshaping."
            case .delayed:
                title = "Delay recorded"
                explanation = "Timing changed, so the safest Step may be gentler or later."
            case .edited:
                title = "Schedule edited"
                explanation = "A Step or plan phrase changed."
            case .confused:
                title = "Clarify next step"
                explanation = "Confusion is a signal to make the Step clearer."
            case .tooBig:
                title = "Step marked too big"
                explanation = "The app should prefer a smaller version."
            case .tooEasy:
                title = "Step marked too easy"
                explanation = "The Step may need more meaningful signal."
            case .notRelevant:
                title = "Relevance changed"
                explanation = "The path needs a relevance check."
            case .askedForSmallerVersion:
                title = "Asked for a smaller version"
                explanation = "Recovery context can start from a believable Step."
            case .askedWhyThisMatters:
                title = "Asked why this matters"
                explanation = "Why-now context stays close to the goal."
            }
            let goalID = goalID(for: event, goals: goals)

            return MemoryLensResult(
                id: "feedback-\(event.base.id)",
                title: title,
                subtitle: event.base.note ?? "Recent plan and execution change.",
                explanation: explanation,
                queryText: [title, event.base.note, goalTitle(goalID: goalID, goals: goals), "what changed recent change"].compactMap { $0 }.joined(separator: " "),
                timestamp: event.base.occurredAt,
                kind: .recentChange,
                facet: .whatChanged,
                actionTitle: goalID == nil ? "Open history" : "Open goal",
                destination: goalID.map { .goal($0) } ?? .youRoute(.history)
            )
        }
    }

    func makeWhyNowResults(_ goals: [Goal], feedback: [GoalFeedbackEvent]) -> [MemoryLensResult] {
        var results: [MemoryLensResult] = []
        for goal in goals {
            guard let step = goal.plan?.sections
                .sorted(by: { $0.orderIndex < $1.orderIndex })
                .flatMap(\.steps)
                .first(where: { $0.state != .completed && $0.state != .cancelled }) else {
                continue
            }
            let recentGoalFeedback = feedback.filter { event in
                goal.plan?.sections.flatMap(\.steps).contains(where: { $0.id == event.base.stepID }) == true
            }
            let pressure = pressurePhrase(for: goal, step: step, recentFeedback: recentGoalFeedback)
            results.append(MemoryLensResult(
                id: "why-now-\(goal.id)-\(step.id)",
                title: "Why now: \(goal.title)",
                subtitle: pressure,
                explanation: "This points to the current useful Step.",
                queryText: [goal.title, step.title, pressure, "why now current step"].joined(separator: " "),
                timestamp: goal.updatedAt,
                kind: .whyNow,
                facet: .whyNow,
                actionTitle: "Open goal",
                destination: .goal(goal.id)
            ))
        }
        return results
    }

    func makeTeachingResults(_ signals: [GoalTeachingSignal], goals: [Goal]) -> [MemoryLensResult] {
        signals.map { signal in
            let title = signal.userNote?.isEmpty == false ? signal.userNote! : signal.kind.rawValue.replacingOccurrences(of: "_", with: " ")
            let subtitle = correctionSubtitle(for: signal)
            return MemoryLensResult(
                id: "teaching-\(signal.id)",
                title: title.capitalized,
                subtitle: subtitle,
                explanation: "This correction is useful truth for this goal.",
                queryText: [title, subtitle, signal.kind.rawValue, goalTitle(goalID: signal.goalID, goals: goals), "recent correction teaching"].compactMap { $0 }.joined(separator: " "),
                timestamp: signal.updatedAt,
                kind: .teaching,
                facet: .recentCorrection,
                actionTitle: "Open goal",
                destination: .goal(signal.goalID)
            )
        }
    }

    func makeLearningResults(_ goals: [Goal], feedback: [GoalFeedbackEvent], teaching: [GoalTeachingSignal]) -> [MemoryLensResult] {
        let goalIDsWithFeedback = Set(feedback.compactMap { goalID(for: $0, goals: goals) })
        let goalIDsWithTeaching = Set(teaching.map(\.goalID))
        return goals
            .filter { goalIDsWithFeedback.contains($0.id) || goalIDsWithTeaching.contains($0.id) }
            .map { goal in
                let correctionCount = teaching.filter { $0.goalID == goal.id }.count
                let feedbackCount = feedback.filter { goalID(for: $0, goals: goals) == goal.id }.count
                let subtitle = correctionCount > 0
                    ? "\(correctionCount) correction\(correctionCount == 1 ? "" : "s") are shaping this path."
                    : "\(feedbackCount) recent signal\(feedbackCount == 1 ? "" : "s") are shaping this path."
                return MemoryLensResult(
                    id: "learning-\(goal.id)",
                    title: "Learning: \(goal.title)",
                    subtitle: subtitle,
                    explanation: "Local learning opens the owning goal.",
                    queryText: [goal.title, subtitle, "recent learning what learned correction feedback"].joined(separator: " "),
                    timestamp: goal.updatedAt,
                    kind: .learning,
                    facet: .recentLearning,
                    actionTitle: "Open goal",
                    destination: .goal(goal.id)
                )
            }
    }

    func goalID(for event: GoalFeedbackEvent, goals: [Goal]) -> String? {
        let stepID = event.base.stepID
        guard stepID.isEmpty == false else { return nil }
        return goals.first { goal in
            goal.plan?.sections.flatMap(\.steps).contains(where: { $0.id == stepID }) == true
        }?.id
    }

    func goalTitle(goalID: String?, goals: [Goal]) -> String? {
        guard let goalID else { return nil }
        return goals.first(where: { $0.id == goalID })?.title
    }

    func pressurePhrase(for goal: Goal, step: Step, recentFeedback: [GoalFeedbackEvent]) -> String {
        if recentFeedback.contains(where: { if case .askedForSmallerVersion = $0 { return true }; return false }) {
            return "A smaller version is now the calmest Step."
        }
        if recentFeedback.contains(where: { if case .delayed = $0 { return true }; return false }) {
            return "Timing changed recently, so this Step needs a believable return."
        }
        if step.timing.dueAt != nil || step.timing.targetBy != nil || goal.timing.dueAt != nil || goal.timing.targetBy != nil {
            return "Time pressure is visible, but the Step stays bounded."
        }
        return "This is the next readable Step from the current local plan."
    }

    func correctionSubtitle(for signal: GoalTeachingSignal) -> String {
        switch signal.kind {
        case .interpretationCorrection:
            return "Goal interpretation was clarified."
        case .goalSubjectCorrection:
            return "Goal subject was clarified."
        case .classificationCorrection:
            return "Goal classification was clarified."
        case .requirementRelevanceCorrection:
            return "Requirement relevance was clarified."
        case .contradictionDispositionCorrection:
            return "A contradiction was clarified."
        case .energyFitCorrection:
            return "Energy fit was clarified."
        }
    }

    func originBias(for result: MemoryLensResult) -> [AmbitionsSurface] {
        switch result.destination {
        case let .tab(surface):
            [surface.canonicalTopLevelTab]
        case .goal:
            result.kind == .step || result.kind == .whyNow ? [.today, .goals] : [.goals]
        case .timeRoute:
            [.time]
        case .youRoute:
            [.you]
        case let .overlay(overlay):
            overlay.isActivatedCaptureComposer ? AmbitionsSurface.allCases : [.today]
        }
    }
}

private extension StepLifecycleState {
    var searchTitle: String {
        switch self {
        case .planned: "Planned"
        case .active: "Active"
        case .completed: "Completed"
        case .blocked: "Blocked"
        case .cancelled: "Not needed"
        }
    }
}

private extension ProgressEvidenceKind {
    var searchTitle: String {
        rawValue.replacingOccurrences(of: "_", with: " ").capitalized
    }
}
