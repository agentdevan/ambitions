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

struct CaptureGoalHandoffState: Sendable, Equatable {
    let title: String
    let sourceLabel: String
    let consequenceLabel: String
    let privacyLabel: String
    let confirmationLabel: String

    init(captureTitle: String) {
        self.title = "Grow into Goal"
        self.sourceLabel = captureTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "From Capture"
            : captureTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        self.consequenceLabel = "Creates a goal only after you confirm the setup."
        self.privacyLabel = "Stored on this device"
        self.confirmationLabel = "Requires your confirmation"
    }
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
    private var creationAttemptID: String
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
        submissionState: CreateGoalSubmissionState = .idle,
        creationAttemptID: String = DomainIdentifier.prefixed("goal.create")
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
        self.creationAttemptID = creationAttemptID
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

    var captureGoalHandoff: CaptureGoalHandoffState? {
        guard captureID != nil else { return nil }
        return CaptureGoalHandoffState(captureTitle: trimmedTitle)
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

    func submit(
        using service: any GoalsServicing,
        runtimeCommandClient: RuntimeCommandClient,
        now: Date = .now
    ) async -> CreateGoalResponse? {
        submissionState = .loading
        do {
            guard let preparing = service as? any GoalCreationPreparing else {
                throw GoalsFeatureError.notActionable
            }
            let request = CreateGoalRequest(
                title: trimmedTitle,
                mode: selectedMode,
                entrySource: entrySource,
                clarifiedFields: clarificationAnswers,
                preferredPace: selectedPace,
                targetDateOverride: selectedTargetDateOverride,
                captureID: captureID
            )
            let prepared = try await preparing.prepareGoalCreation(request, now: now)
            guard let goal = prepared.goal,
                  let goalID = prepared.response.target.goalID,
                  goal.id == goalID else {
                throw GoalsFeatureError.notActionable
            }
            let command = AmbitionsCommand(
                id: "goal.create.command.\(creationAttemptID)",
                source: .goals,
                typedPayload: .goal(GoalCommand(
                    action: .create,
                    target: AmbitionsCommandTarget(goalID: goalID, destination: .goals),
                    content: RuntimeCommandContent(AmbitionsCommandPayload(rawText: trimmedTitle))
                )),
                idempotencyKey: CommandIdempotencyKey(creationAttemptID),
                createdAt: DomainTimestamp.string(from: now),
                actor: .user,
                sourceSurface: "Create Goal",
                privacy: .privateUserText
            )
            let authorityResult = await runtimeCommandClient.execute(
                command,
                CommandExecutionContext(now: now, actor: .user, sourceSurface: "Create Goal")
            )
            guard authorityResult.status == .succeeded,
                  authorityResult.metadata["commandReceiptID"]?.isEmpty == false,
                  authorityResult.target?.goalID == goalID,
                  hasProjectionEvidence(authorityResult.metadata) else {
                throw GoalsFeatureError.notActionable
            }
            let response = try await preparing.commitPreparedGoalCreation(prepared, now: now)
            creationAttemptID = DomainIdentifier.prefixed("goal.create")
            submissionState = .idle
            return response
        } catch {
            submissionState = .failed("Unable to create Goal: \(error.localizedDescription)")
            return nil
        }
    }

    private func hasProjectionEvidence(_ metadata: [String: String]) -> Bool {
        guard let countValue = metadata["runtimeProjectionCursorCount"],
              let count = Int(countValue),
              count > 0,
              let identifiers = metadata["runtimeProjectionCursorIDs"]?.split(separator: ","),
              identifiers.count == count,
              Set(identifiers).count == count else {
            return false
        }
        return true
    }
}
