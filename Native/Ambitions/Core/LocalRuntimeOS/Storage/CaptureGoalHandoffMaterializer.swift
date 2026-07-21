import Foundation
import SwiftData

enum CaptureGoalHandoffFailurePoint: Sendable, Equatable {
    case none
    case afterCaptureWrite
}

enum CaptureGoalHandoffStorageError: Error, Equatable {
    case injectedFailure(CaptureGoalHandoffFailurePoint)
}

struct SwiftDataCaptureGoalHandoffMaterializer: CaptureGoalHandoffMaterializing {
    let store: AmbitionsPersistenceStore
    var failurePoint: CaptureGoalHandoffFailurePoint = .none

    func validate(_ plan: CaptureGoalHandoffPlan) async throws {
        let repositories = PersistenceBootstrap.makeRepositories(store: store, configuration: .preview)
        try await RepositoryCaptureGoalHandoffMaterializer(repositories: repositories).validate(plan)
    }

    func materialize(_ plan: CaptureGoalHandoffPlan) async throws {
        _ = try await store.transaction(id: "capture-goal-handoff-\(plan.captureID)-\(plan.goalID)") { context in
            guard let goalRecord = try context.fetch(FetchDescriptor<GoalRecord>())
                .first(where: { $0.id == plan.goalID }) else {
                throw CaptureGoalHandoffError.goalUnavailable
            }
            guard goalRecord.createdAt == plan.expectedGoalIdentity.createdAt else {
                throw CaptureGoalHandoffError.recreatedGoal
            }
            guard let captureRecord = try context.fetch(FetchDescriptor<CaptureRecord>())
                .first(where: { $0.id == plan.captureID }) else {
                throw CaptureGoalHandoffError.captureUnavailable
            }
            let currentCapture = try RepositoryMapping.capture(from: captureRecord)
            if currentCapture == plan.updatedCapture { return }
            guard currentCapture == plan.expectedCapture else { throw CaptureGoalHandoffError.staleCapture }

            try SwiftDataCapturePersistence.saveCaptures([plan.updatedCapture], in: context)
            if failurePoint == .afterCaptureWrite {
                throw CaptureGoalHandoffStorageError.injectedFailure(.afterCaptureWrite)
            }
        }
    }
}
