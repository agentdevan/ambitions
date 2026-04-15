import Foundation
import Observation

enum CreateGoalSubmissionState: Sendable, Equatable {
    case idle
    case loading
    case failed(String)
}

@MainActor
@Observable
final class CreateGoalViewModel {
    var title: String
    var selectedMode: GoalMode?
    var submissionState: CreateGoalSubmissionState

    init(
        title: String = "",
        selectedMode: GoalMode? = nil,
        submissionState: CreateGoalSubmissionState = .idle
    ) {
        self.title = title
        self.selectedMode = selectedMode
        self.submissionState = submissionState
    }

    var canSubmit: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false && !isSubmitting
    }

    var isSubmitting: Bool {
        if case .loading = submissionState {
            return true
        }
        return false
    }

    func submit(using service: any GoalsServicing, now: Date = .now) async -> CreateGoalResponse? {
        submissionState = .loading
        do {
            let response = try await service.createGoal(
                CreateGoalRequest(
                    title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                    mode: selectedMode
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
