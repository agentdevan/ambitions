import Foundation
import Observation

enum CreateGoalSubmissionState: Sendable, Equatable {
    case idle
    case loading
    case failed(String)
}

enum CreateGoalPreviewLoadState: Sendable {
    case idle
    case loading
    case loaded(CreateGoalPreviewState)
    case failed(String)
}

@MainActor
@Observable
final class CreateGoalViewModel {
    var title: String
    var selectedMode: GoalMode?
    var entrySource: ShellCommandEntrySource
    var captureID: String?
    var selectedPace: StrategyComposerPaceChoice
    var selectedTargetDateOverride: String?
    var clarificationAnswers: [MissingFieldKey: String]
    var previewState: CreateGoalPreviewLoadState
    var submissionState: CreateGoalSubmissionState
    @ObservationIgnored private var previewRefreshTask: Task<Void, Never>?

    init(
        title: String = "",
        selectedMode: GoalMode? = nil,
        entrySource: ShellCommandEntrySource = .goalsCreate,
        captureID: String? = nil,
        selectedPace: StrategyComposerPaceChoice = .balanced,
        selectedTargetDateOverride: String? = nil,
        clarificationAnswers: [MissingFieldKey: String] = [:],
        previewState: CreateGoalPreviewLoadState = .idle,
        submissionState: CreateGoalSubmissionState = .idle
    ) {
        self.title = title
        self.selectedMode = selectedMode
        self.entrySource = entrySource
        self.captureID = captureID
        self.selectedPace = selectedPace
        self.selectedTargetDateOverride = selectedTargetDateOverride
        self.clarificationAnswers = clarificationAnswers
        self.previewState = previewState
        self.submissionState = submissionState
    }

    var canSubmit: Bool {
        trimmedTitle.isEmpty == false && !isSubmitting
    }

    var isSubmitting: Bool {
        if case .loading = submissionState {
            return true
        }
        return false
    }

    var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var previewKey: String {
        switch previewState {
        case .idle:
            return "idle"
        case .loading:
            return "loading"
        case let .failed(message):
            return "failed:\(message)"
        case let .loaded(state):
            return "loaded:\(state.resultKind.rawValue):\(state.selectedPace.rawValue):\(state.normalizedTitle)"
        }
    }

    var previewInputKey: String {
        let clarificationKey = clarificationAnswers
            .sorted { $0.key.rawValue < $1.key.rawValue }
            .map { "\($0.key.rawValue)=\($0.value)" }
            .joined(separator: "|")
        return [
            trimmedTitle,
            selectedMode?.rawValue ?? "auto",
            selectedPace.rawValue,
            selectedTargetDateOverride ?? "",
            clarificationKey
        ].joined(separator: "||")
    }

    var selectedTargetDateLabel: String? {
        selectedTargetDateOverride
    }

    func answer(for field: MissingFieldKey) -> String {
        clarificationAnswers[field] ?? ""
    }

    func setAnswer(_ answer: String, for field: MissingFieldKey) {
        let trimmed = answer.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            clarificationAnswers.removeValue(forKey: field)
        } else {
            clarificationAnswers[field] = trimmed
        }
    }

    func selectPace(_ choice: StrategyComposerPaceChoice) {
        selectedPace = choice
    }

    func applySuggestedDeadline(_ date: String) {
        selectedTargetDateOverride = date
        selectedPace = .conservative
    }

    func refreshPreview(using service: any GoalsServicing, now: Date = .now) async {
        guard trimmedTitle.isEmpty == false else {
            previewState = .idle
            return
        }

        previewState = .loading
        do {
            previewState = .loaded(
                try await service.previewCreateGoal(
                    CreateGoalPreviewRequest(
                        title: trimmedTitle,
                        mode: selectedMode,
                        entrySource: entrySource,
                        clarifiedFields: clarificationAnswers,
                        preferredPace: selectedPace,
                        targetDateOverride: selectedTargetDateOverride,
                        captureID: captureID
                    ),
                    now: now
                )
            )
        } catch {
            previewState = .failed("Unable to shape the strategy yet: \(error.localizedDescription)")
        }
    }

    func schedulePreviewRefresh(
        using service: any GoalsServicing,
        now: Date = .now,
        debounceNanoseconds: UInt64 = 250_000_000
    ) {
        previewRefreshTask?.cancel()

        guard trimmedTitle.isEmpty == false else {
            previewState = .idle
            return
        }

        let requestKey = previewInputKey
        previewRefreshTask = Task { [weak self] in
            guard let self else { return }

            do {
                try await Task.sleep(nanoseconds: debounceNanoseconds)
            } catch {
                return
            }

            guard Task.isCancelled == false else { return }
            await self.runScheduledPreviewRefresh(
                requestKey: requestKey,
                using: service,
                now: now
            )
        }
    }

    func cancelPreviewRefresh() {
        previewRefreshTask?.cancel()
        previewRefreshTask = nil
    }

    private func runScheduledPreviewRefresh(
        requestKey: String,
        using service: any GoalsServicing,
        now: Date
    ) async {
        guard requestKey == previewInputKey else { return }
        await refreshPreview(using: service, now: now)
    }

    func submit(using service: any GoalsServicing, now: Date = .now) async -> CreateGoalResponse? {
        submissionState = .loading
        do {
            let response = try await service.createGoal(
                CreateGoalRequest(
                    title: trimmedTitle,
                    mode: selectedMode,
                    entrySource: entrySource,
                    clarifiedFields: clarificationAnswers,
                    preferredPace: selectedPace,
                    targetDateOverride: selectedTargetDateOverride,
                    captureID: captureID
                ),
                now: now
            )
            submissionState = .idle
            return response
        } catch {
            submissionState = .failed("Unable to create Goal: \(error.localizedDescription)")
            return nil
        }
    }
}
