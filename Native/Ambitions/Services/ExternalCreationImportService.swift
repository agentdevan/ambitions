import Foundation

struct ExternalCreationImportResult: Sendable, Equatable {
    let importedCaptureIDs: [String]
    let preferredLanding: ExternalCreationLanding?
    let source: ExternalCreationSource?

    var importedCount: Int { importedCaptureIDs.count }
}

@MainActor
protocol ExternalCreationImporting: AnyObject {
    func importPendingCreations(now: Date) async -> ExternalCreationImportResult
}

@MainActor
final class DefaultExternalCreationImportService: ExternalCreationImporting {
    private let store: SharedExternalCreationStore
    private let captureService: any CaptureServicing

    init(
        store: SharedExternalCreationStore = SharedExternalCreationStore(),
        captureService: any CaptureServicing
    ) {
        self.store = store
        self.captureService = captureService
    }

    func importPendingCreations(now: Date = .now) async -> ExternalCreationImportResult {
        let requests: [ExternalCreationRequest]
        do {
            requests = try store.drain()
        } catch {
            return ExternalCreationImportResult(importedCaptureIDs: [], preferredLanding: nil, source: nil)
        }

        var importedIDs: [String] = []
        var preferredLanding: ExternalCreationLanding?
        var source: ExternalCreationSource?

        for request in requests {
            do {
                let capture = try await captureService.createCapture(
                    CreateCaptureRequest(
                        rawText: request.text,
                        sourceType: captureSourceType(for: request.source),
                        triage: CaptureTriageMetadata(
                            destination: request.landing == .createGoal ? .turnIntoGoal : .doSoon,
                            hint: provenanceHint(for: request)
                        )
                    ),
                    now: now
                )
                importedIDs.append(capture.id)
                preferredLanding = preferredLanding ?? request.landing
                source = source ?? request.source
            } catch {
                continue
            }
        }

        return ExternalCreationImportResult(importedCaptureIDs: importedIDs, preferredLanding: preferredLanding, source: source)
    }

    private func captureSourceType(for source: ExternalCreationSource) -> CaptureSourceType {
        CaptureSourceType(rawValue: source.captureSourceTypeRawValue) ?? .todayQuickCapture
    }

    private func provenanceHint(for request: ExternalCreationRequest) -> String? {
        switch (request.sourceApplication, request.sourceURL) {
        case let (.some(application), .some(url)):
            return "From \(application): \(url)"
        case let (.some(application), .none):
            return "From \(application)"
        case let (.none, .some(url)):
            return "Shared URL: \(url)"
        case (.none, .none):
            return nil
        }
    }
}
