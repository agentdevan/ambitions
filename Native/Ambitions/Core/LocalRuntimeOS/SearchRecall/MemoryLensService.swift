import AmbitionsDesignSystem
import Foundation

enum MemoryLensResultKind: String, Sendable, Equatable {
    case step
    case goal
    case timeWindow
    case capture
    case thought
    case proof
    case receipt
    case recentChange
    case whyNow
    case teaching
    case learning
    case setting

    var title: String {
        switch self {
        case .step: "Step"
        case .goal: "Goal"
        case .timeWindow: "Time"
        case .capture: "Capture"
        case .thought: "Thought"
        case .proof: "Proof"
        case .receipt: "Receipt"
        case .recentChange: "Recent change"
        case .whyNow: "Why now"
        case .teaching: "Correction"
        case .learning: "Learning"
        case .setting: "You"
        }
    }

    var systemImage: String {
        switch self {
        case .step: "checkmark.circle"
        case .goal: "target"
        case .timeWindow: "calendar"
        case .capture: "tray.full"
        case .thought: "text.bubble"
        case .proof: "checkmark.seal"
        case .receipt: "doc.text.magnifyingglass"
        case .recentChange: "clock.arrow.circlepath"
        case .whyNow: "questionmark.circle"
        case .teaching: "sparkles.rectangle.stack"
        case .learning: "lightbulb"
        case .setting: "gearshape"
        }
    }

    var visualState: AmbitionVisualState {
        switch self {
        case .goal, .step: .selected
        case .timeWindow, .capture, .thought, .setting: .default
        case .proof, .receipt: .success
        case .recentChange: .warning
        case .whyNow: .selected
        case .teaching: .success
        case .learning: .success
        }
    }

    var family: LocalSearchObjectFamily {
        switch self {
        case .step: .step
        case .goal, .whyNow, .learning, .teaching: .goal
        case .timeWindow: .timeWindow
        case .capture: .capture
        case .thought: .thought
        case .proof: .proof
        case .receipt, .recentChange: .receipt
        case .setting: .setting
        }
    }
}

enum MemoryLensRecallFacet: String, Sendable, Equatable, CaseIterable {
    case whatChanged
    case whyNow
    case recentCorrection
    case recentLearning
    case openEntry
    case open

    var title: String {
        switch self {
        case .whatChanged: "What changed"
        case .whyNow: "Why now"
        case .recentCorrection: "Recent correction"
        case .recentLearning: "Recent learning"
        case .openEntry: "Open"
        case .open: "Open"
        }
    }
}

enum MemoryLensSourceEvidence: String, Sendable, Equatable, CaseIterable {
    case currentPlan
    case capturedThought
    case userFeedback
    case userCorrection
    case localSetting
    case localProof

    var title: String {
        switch self {
        case .currentPlan: "Current plan"
        case .capturedThought: "Captured thought"
        case .userFeedback: "User feedback"
        case .userCorrection: "User correction"
        case .localSetting: "Local setting"
        case .localProof: "Local proof"
        }
    }
}

enum MemoryLensConfidenceBand: String, Sendable, Equatable, CaseIterable {
    case direct
    case inferred
    case needsReview

    var title: String {
        switch self {
        case .direct: "Direct"
        case .inferred: "Inferred"
        case .needsReview: "Needs review"
        }
    }
}

enum MemoryLensTrustDecayState: String, Sendable, Equatable, CaseIterable {
    case current
    case aging
    case reviewBeforeUse

    var title: String {
        switch self {
        case .current: "Current"
        case .aging: "Aging"
        case .reviewBeforeUse: "Review before use"
        }
    }
}

enum MemoryLensContextRecallClass: String, Sendable, Equatable, CaseIterable {
    case lifeEvent
    case decision
    case contextRecall
    case correctionMemory

    var title: String {
        switch self {
        case .lifeEvent: "Life event"
        case .decision: "Decision"
        case .contextRecall: "Context recall"
        case .correctionMemory: "Correction memory"
        }
    }
}

enum MemoryLensContextRetrievalScope: String, Sendable, Equatable, CaseIterable {
    case activePlan
    case inboxContext
    case feedbackHistory
    case correctionTrail
    case appContinuity

    var title: String {
        switch self {
        case .activePlan: "Active plan"
        case .inboxContext: "Inbox context"
        case .feedbackHistory: "Feedback history"
        case .correctionTrail: "Correction trail"
        case .appContinuity: "App continuity"
        }
    }
}

struct MemoryLensResult: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let explanation: String
    let queryText: String
    let timestamp: String
    let kind: MemoryLensResultKind
    let facet: MemoryLensRecallFacet
    let actionTitle: String
    let destination: ShellCommandDestination

    var state: AmbitionVisualState { kind.visualState }
    var badgeTitle: String { kind.title }
    var systemImage: String { kind.systemImage }
    var facetTitle: String { facet.title }
    var sourceEvidence: MemoryLensSourceEvidence {
        switch kind {
        case .goal, .step, .timeWindow, .whyNow, .learning:
            .currentPlan
        case .capture, .thought:
            .capturedThought
        case .recentChange:
            .userFeedback
        case .teaching:
            .userCorrection
        case .proof, .receipt:
            .localProof
        case .setting:
            .localSetting
        }
    }
    var confidenceBand: MemoryLensConfidenceBand {
        switch kind {
        case .goal, .step, .timeWindow, .capture, .thought, .proof, .receipt, .teaching, .setting:
            .direct
        case .recentChange, .whyNow, .learning:
            .inferred
        }
    }
    var trustDecayState: MemoryLensTrustDecayState {
        switch kind {
        case .goal, .step, .timeWindow, .capture, .thought, .proof, .receipt, .recentChange, .whyNow, .teaching, .setting:
            .current
        case .learning:
            .aging
        }
    }
    var contextRecallClass: MemoryLensContextRecallClass {
        switch kind {
        case .timeWindow:
            .lifeEvent
        case .recentChange, .whyNow:
            .decision
        case .goal, .step, .capture, .thought, .proof, .receipt, .setting:
            .contextRecall
        case .teaching, .learning:
            .correctionMemory
        }
    }
    var requiresUserReviewBeforeDurableMemory: Bool {
        switch contextRecallClass {
        case .lifeEvent, .contextRecall:
            false
        case .decision, .correctionMemory:
            true
        }
    }
    var allowsMemoryClaim: Bool { false }
    var retrievalScope: MemoryLensContextRetrievalScope {
        switch kind {
        case .goal, .step, .timeWindow, .whyNow, .learning:
            .activePlan
        case .capture, .thought:
            .inboxContext
        case .recentChange:
            .feedbackHistory
        case .teaching:
            .correctionTrail
        case .proof, .receipt, .setting:
            .appContinuity
        }
    }
    var contextRetrievalSummary: String {
        requiresUserReviewBeforeDurableMemory ? "Review before using this." : "Ready to open."
    }
    var recallSearchTokens: String {
        [
            retrievalScope.title,
            sourceEvidence.title,
            confidenceBand.title,
            trustDecayState.title,
            contextRecallClass.title,
            requiresUserReviewBeforeDurableMemory ? "review before durable memory" : "safe context recall"
        ].joined(separator: " ")
    }

    var searchFamily: LocalSearchObjectFamily { kind.family }
    var sourceAreaTitle: String { trustedSearchHandoffOwner.title }
    var stateTitle: String {
        switch kind {
        case .step: "Open"
        case .goal: "Current"
        case .timeWindow: "Available"
        case .capture, .thought: "Needs place"
        case .proof, .receipt: "Saved"
        case .recentChange: "Review"
        case .whyNow: "Recommended step"
        case .teaching, .learning: "Learning"
        case .setting: "Available"
        }
    }
    var inspectActionTitle: String? {
        switch kind {
        case .proof, .receipt, .recentChange, .whyNow, .teaching, .learning:
            "Inspect"
        case .step, .goal, .timeWindow, .capture, .thought, .setting:
            nil
        }
    }
}

struct DefaultMemoryLensService: MemoryLensServicing {
    private let repositories: AppRepositories

    init(repositories: AppRepositories) {
        self.repositories = repositories
    }

    func search(query: String, seedIntent: ShellCommandIntent?, origin: AmbitionsSurface?) async -> [MemoryLensResult] {
        async let goals = repositories.goals.listGoals()
        async let actionableSteps = repositories.goals.listActionableSteps()
        async let captures = repositories.captures.listCaptures()
        async let evidence = repositories.evidence.listEvidence(goalID: nil)
        async let feedback = repositories.feedback.listEvents(goalID: nil)
        async let teaching = repositories.teaching.listSignals(goalID: nil)

        do {
            let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let resolvedGoals = try await goals
            let resolvedActionableSteps = try await actionableSteps
            let resolvedCaptures = try await captures
            let resolvedEvidence = try await evidence
            let resolvedFeedback = try await feedback
            let resolvedTeaching = try await teaching
            let stepResults = makeStepResults(goals: resolvedGoals, actionableSteps: resolvedActionableSteps)
            let goalResults = makeGoalResults(resolvedGoals)
            let captureResults = makeCaptureResults(resolvedCaptures)
            let proofResults = makeProofResults(resolvedEvidence, goals: resolvedGoals)
            let feedbackResults = makeFeedbackResults(resolvedFeedback, goals: resolvedGoals)
            let whyNowResults = makeWhyNowResults(resolvedGoals, feedback: resolvedFeedback)
            let teachingResults = makeTeachingResults(resolvedTeaching, goals: resolvedGoals)
            let learningResults = makeLearningResults(resolvedGoals, feedback: resolvedFeedback, teaching: resolvedTeaching)
            let timeResults = makeTimeResults()
            let settingResults = makeSettingResults()

            let prioritized = prioritizationOrder(seedIntent: seedIntent, origin: origin)
            var combined: [MemoryLensResult] = timeResults
            combined.append(contentsOf: whyNowResults)
            combined.append(contentsOf: stepResults)
            combined.append(contentsOf: learningResults)
            combined.append(contentsOf: feedbackResults)
            combined.append(contentsOf: proofResults)
            combined.append(contentsOf: goalResults)
            combined.append(contentsOf: captureResults)
            combined.append(contentsOf: teachingResults)
            combined.append(contentsOf: settingResults)
            let records = combined.map { result in
                LocalSearchRecord(
                    id: result.id,
                    family: result.searchFamily,
                    title: result.title,
                    context: result.userFacingContext,
                    sourceArea: result.sourceAreaTitle,
                    state: result.stateTitle,
                    primaryActionTitle: result.actionTitle,
                    inspectActionTitle: result.inspectActionTitle,
                    destination: result.destination,
                    updatedAt: result.timestamp,
                    searchableText: [result.queryText, result.recallSearchTokens].joined(separator: " "),
                    originBias: originBias(for: result)
                )
            }
            let familyPriority = prioritized.reduce(into: [LocalSearchObjectFamily: Int]()) { partialResult, pair in
                let family = pair.key.family
                partialResult[family] = min(partialResult[family] ?? pair.value, pair.value)
            }
            let orderedRecords = LocalSearchIndex(records: records).search(
                query: trimmedQuery,
                origin: origin,
                familyPriority: familyPriority
            )
            return orderedRecords.compactMap { record in
                combined.first { $0.id == record.id }
            }
        } catch {
            return []
        }
    }
}
