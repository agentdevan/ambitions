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
            async let goals = repositories.goals.listGoals()
            async let captures = repositories.captures.listCaptures()
            let snapshot = try await builder.makeSnapshot(goals: goals, captures: captures, now: now)
            let data = try PersistenceCoding.encode(snapshot)
            try sink.write(data)

            await recordExternalSnapshotSideEffect(status: .recordedLocalOnly, at: now)
        } catch {
            await recordExternalSnapshotSideEffect(
                status: .failedSafely,
                at: now,
                degradedFacts: ["External snapshot refresh/write did not complete."]
            )
            // Snapshot export is best-effort and must never block user flows.
        }
    }

    private func recordExternalSnapshotSideEffect(
        status: SideEffectLedgerStatus,
        at date: Date,
        reasons: [SafeAutomationPolicyReason] = [],
        degradedFacts: [String] = []
    ) async {
        guard let sideEffectLedger = repositories.sideEffectLedger else {
            return
        }

        let occurredAt = DomainTimestamp.string(from: date)
        let record = SideEffectLedgerRecord(
            id: "externalSnapshot.\(status.rawValue).\(Int(date.timeIntervalSince1970))",
            effectKind: .externalSnapshot,
            status: status,
            boundary: .localOnly,
            actionKind: .noOp,
            sourceDomain: .system,
            occurredAt: occurredAt,
            localOnly: true,
            requiresConfirmation: false,
            externalEffect: false,
            reasons: reasons,
            degradedFacts: degradedFacts
        )

        try? await sideEffectLedger.append(record)
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
