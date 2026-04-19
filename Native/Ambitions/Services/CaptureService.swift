import Foundation

struct CreateCaptureRequest: Sendable, Equatable {
    let rawText: String
    let sourceType: CaptureSourceType?
    let linkedGoalID: String?
    let triage: CaptureTriageMetadata?
    let revisitAfter: String?

    init(
        rawText: String,
        sourceType: CaptureSourceType? = nil,
        linkedGoalID: String? = nil,
        triage: CaptureTriageMetadata? = nil,
        revisitAfter: String? = nil
    ) {
        self.rawText = rawText
        self.sourceType = sourceType
        self.linkedGoalID = linkedGoalID
        self.triage = triage
        self.revisitAfter = revisitAfter
    }
}

struct CaptureStateUpdateRequest: Sendable, Equatable {
    let id: String
    let status: CaptureStatus
    let triage: CaptureTriageMetadata?
    let revisitAfter: String?

    init(
        id: String,
        status: CaptureStatus,
        triage: CaptureTriageMetadata? = nil,
        revisitAfter: String? = nil
    ) {
        self.id = id
        self.status = status
        self.triage = triage
        self.revisitAfter = revisitAfter
    }
}

struct AttachCaptureToGoalRequest: Sendable, Equatable {
    let captureID: String
    let goalID: String

    init(captureID: String, goalID: String) {
        self.captureID = captureID
        self.goalID = goalID
    }
}

struct TurnCaptureIntoGoalRequest: Sendable, Equatable {
    let captureID: String
    let mode: GoalMode?

    init(captureID: String, mode: GoalMode? = nil) {
        self.captureID = captureID
        self.mode = mode
    }
}

struct CaptureGoalBinding: Sendable, Equatable {
    let capture: Capture
    let target: GoalRouteTarget
}

struct DefaultCaptureService: CaptureServicing {
    private let repository: any CaptureRepository
    private let goalRepository: (any GoalRepository)?
    private let goalsService: (any GoalsServicing)?
    private let idProvider: @Sendable () -> String

    init(
        repository: any CaptureRepository,
        goalRepository: (any GoalRepository)? = nil,
        goalsService: (any GoalsServicing)? = nil,
        idProvider: @escaping @Sendable () -> String = { DomainIdentifier.prefixed("capture") }
    ) {
        self.repository = repository
        self.goalRepository = goalRepository
        self.goalsService = goalsService
        self.idProvider = idProvider
    }

    func createCapture(_ request: CreateCaptureRequest, now: Date) async throws -> Capture {
        let trimmed = request.rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            throw CaptureServiceError.emptyRawText
        }

        let timestamp = DomainTimestamp.string(from: now)
        let capture = Capture(
            id: idProvider(),
            createdAt: timestamp,
            updatedAt: timestamp,
            rawText: trimmed,
            sourceType: request.sourceType,
            status: .actionable,
            linkedGoalID: request.linkedGoalID,
            triage: request.triage,
            revisitAfter: request.revisitAfter
        )
        try await repository.saveCaptures([capture])
        return capture
    }

    func listCaptures() async throws -> [Capture] {
        try await repository.listCaptures()
    }

    func updateCaptureState(_ request: CaptureStateUpdateRequest, now: Date) async throws -> Capture? {
        guard let existing = try await repository.capture(id: request.id) else {
            return nil
        }
        guard existing.status.canTransition(to: request.status) else {
            throw CaptureServiceError.invalidTransition(from: existing.status, to: request.status)
        }

        let updated = capture(
            from: existing,
            status: request.status,
            linkedGoalID: existing.linkedGoalID,
            triage: request.triage ?? existing.triage,
            revisitAfter: request.revisitAfter ?? existing.revisitAfter,
            now: now
        )
        try await repository.saveCaptures([updated])
        return updated
    }

    func attachCaptureToGoal(_ request: AttachCaptureToGoalRequest, now: Date) async throws -> CaptureGoalBinding? {
        guard let existing = try await repository.capture(id: request.captureID) else {
            return nil
        }
        guard let goalRepository else {
            throw CaptureServiceError.missingGoalRepository
        }
        guard try await goalRepository.goal(id: request.goalID) != nil else {
            throw CaptureServiceError.goalNotFound
        }
        guard existing.status.canTransition(to: .goalBound) else {
            throw CaptureServiceError.invalidTransition(from: existing.status, to: .goalBound)
        }

        let updated = capture(
            from: existing,
            status: .goalBound,
            linkedGoalID: request.goalID,
            triage: CaptureTriageMetadata(destination: .attachToGoal, hint: existing.triage?.hint),
            revisitAfter: existing.revisitAfter,
            now: now
        )
        try await repository.saveCaptures([updated])
        return CaptureGoalBinding(capture: updated, target: GoalRouteTarget(goalID: request.goalID, draftID: nil))
    }

    func turnCaptureIntoGoal(_ request: TurnCaptureIntoGoalRequest, now: Date) async throws -> CaptureGoalBinding? {
        guard let existing = try await repository.capture(id: request.captureID) else {
            return nil
        }
        guard let goalsService else {
            throw CaptureServiceError.missingGoalsService
        }
        guard existing.status.canTransition(to: .goalBound) else {
            throw CaptureServiceError.invalidTransition(from: existing.status, to: .goalBound)
        }

        let response = try await goalsService.createGoal(
            CreateGoalRequest(title: existing.rawText, mode: request.mode),
            now: now
        )
        guard let goalID = response.target.goalID else {
            throw CaptureServiceError.goalCreationDidNotReturnGoal
        }

        let updated = capture(
            from: existing,
            status: .goalBound,
            linkedGoalID: goalID,
            triage: CaptureTriageMetadata(destination: .turnIntoGoal, hint: existing.triage?.hint),
            revisitAfter: existing.revisitAfter,
            now: now
        )
        try await repository.saveCaptures([updated])
        return CaptureGoalBinding(capture: updated, target: response.target)
    }

    func markCaptureProcessed(id: String, now: Date) async throws -> Capture? {
        try await updateCaptureState(
            CaptureStateUpdateRequest(id: id, status: .goalBound),
            now: now
        )
    }

    func markCaptureArchived(id: String, now: Date) async throws -> Capture? {
        try await updateCaptureState(
            CaptureStateUpdateRequest(id: id, status: .archived),
            now: now
        )
    }
}

private extension DefaultCaptureService {
    func capture(
        from existing: Capture,
        status: CaptureStatus,
        linkedGoalID: String?,
        triage: CaptureTriageMetadata?,
        revisitAfter: String?,
        now: Date
    ) -> Capture {
        Capture(
            id: existing.id,
            createdAt: existing.createdAt,
            updatedAt: DomainTimestamp.string(from: now),
            rawText: existing.rawText,
            sourceType: existing.sourceType,
            status: status,
            linkedGoalID: linkedGoalID,
            triage: triage,
            revisitAfter: revisitAfter
        )
    }
}

enum CaptureServiceError: LocalizedError {
    case emptyRawText
    case invalidTransition(from: CaptureStatus, to: CaptureStatus)
    case missingGoalRepository
    case missingGoalsService
    case goalNotFound
    case goalCreationDidNotReturnGoal

    var errorDescription: String? {
        switch self {
        case .emptyRawText:
            return "Capture text cannot be empty."
        case let .invalidTransition(from, to):
            return "Capture cannot move from \(from.title) to \(to.title)."
        case .missingGoalRepository:
            return "Capture goal attachment is unavailable."
        case .missingGoalsService:
            return "Capture goal creation is unavailable."
        case .goalNotFound:
            return "The selected goal could not be found."
        case .goalCreationDidNotReturnGoal:
            return "The created goal could not be opened."
        }
    }
}
