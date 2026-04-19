import Foundation

struct CreateCaptureRequest: Sendable, Equatable {
    let rawText: String
    let sourceType: CaptureSourceType?
    let linkedGoalID: String?

    init(rawText: String, sourceType: CaptureSourceType? = nil, linkedGoalID: String? = nil) {
        self.rawText = rawText
        self.sourceType = sourceType
        self.linkedGoalID = linkedGoalID
    }
}

struct DefaultCaptureService: CaptureServicing {
    private let repository: any CaptureRepository
    private let idProvider: @Sendable () -> String

    init(
        repository: any CaptureRepository,
        idProvider: @escaping @Sendable () -> String = { DomainIdentifier.prefixed("capture") }
    ) {
        self.repository = repository
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
            status: .pending,
            linkedGoalID: request.linkedGoalID
        )
        try await repository.saveCaptures([capture])
        return capture
    }

    func listCaptures() async throws -> [Capture] {
        try await repository.listCaptures()
    }

    func markCaptureProcessed(id: String, now: Date) async throws -> Capture? {
        try await markCapture(id: id, status: .processed, now: now)
    }

    func markCaptureArchived(id: String, now: Date) async throws -> Capture? {
        try await markCapture(id: id, status: .archived, now: now)
    }
}

private extension DefaultCaptureService {
    func markCapture(id: String, status: CaptureStatus, now: Date) async throws -> Capture? {
        guard let existing = try await repository.capture(id: id) else {
            return nil
        }

        let updated = Capture(
            id: existing.id,
            createdAt: existing.createdAt,
            updatedAt: DomainTimestamp.string(from: now),
            rawText: existing.rawText,
            sourceType: existing.sourceType,
            status: status,
            linkedGoalID: existing.linkedGoalID
        )
        try await repository.saveCaptures([updated])
        return updated
    }
}

enum CaptureServiceError: LocalizedError {
    case emptyRawText

    var errorDescription: String? {
        switch self {
        case .emptyRawText:
            return "Capture text cannot be empty."
        }
    }
}
