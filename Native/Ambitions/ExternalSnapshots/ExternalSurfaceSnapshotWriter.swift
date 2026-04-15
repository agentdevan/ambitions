import Foundation

protocol ExternalSurfaceSnapshotWriting: Sendable {
    func refresh(now: Date) async
}

protocol ExternalSurfaceSnapshotDataSink: Sendable {
    func write(_ data: Data) throws
}

actor ExternalSurfaceSnapshotWriter: ExternalSurfaceSnapshotWriting {
    private let repositories: AppRepositories
    private let builder: ExternalSurfaceSnapshotBuilder
    private let sink: any ExternalSurfaceSnapshotDataSink

    init(
        repositories: AppRepositories,
        builder: ExternalSurfaceSnapshotBuilder = ExternalSurfaceSnapshotBuilder(),
        sink: any ExternalSurfaceSnapshotDataSink = FileExternalSurfaceSnapshotDataSink.default()
    ) {
        self.repositories = repositories
        self.builder = builder
        self.sink = sink
    }

    func refresh(now: Date = .now) async {
        do {
            let goals = try await repositories.goals.listGoals()
            let snapshot = builder.makeSnapshot(goals: goals, now: now)
            let data = try PersistenceCoding.encode(snapshot)
            try sink.write(data)
        } catch {
            // Snapshot export is best-effort and must never block user flows.
        }
    }
}

struct FileExternalSurfaceSnapshotDataSink: ExternalSurfaceSnapshotDataSink {
    let fileURL: URL

    func write(_ data: Data) throws {
        let directory = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        try data.write(to: fileURL, options: .atomic)
    }

    static func `default`() -> FileExternalSurfaceSnapshotDataSink {
        FileExternalSurfaceSnapshotDataSink(fileURL: SharedExternalSnapshotStore.snapshotFileURL())
    }
}
