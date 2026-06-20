import Foundation

actor PreviewCaptureRepository: CaptureRepository {
    private var storage: [String: Capture]

    init(seedCaptures: [Capture] = []) {
        self.storage = Dictionary(uniqueKeysWithValues: seedCaptures.map { ($0.id, $0) })
    }

    func listCaptures() async throws -> [Capture] {
        storage.values.sorted { $0.updatedAt > $1.updatedAt }
    }

    func capture(id: String) async throws -> Capture? {
        storage[id]
    }

    func saveCaptures(_ captures: [Capture]) async throws {
        for capture in captures {
            storage[capture.id] = capture
        }
    }
}
