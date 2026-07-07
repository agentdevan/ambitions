import Foundation

protocol ExternalSurfaceSnapshotWriting: Sendable {
    func refresh(now: Date) async
}

actor ExternalSurfaceSnapshotWriter: ExternalSurfaceSnapshotWriting {
    private let repositories: AppRepositories
    private let builder: ExternalSurfaceSnapshotBuilder
    private let privacyGate: PrivacyExternalBoundaryGate
    private let appGroupSnapshotStore: AppGroupSnapshotStore?

    init(
        repositories: AppRepositories,
        builder: ExternalSurfaceSnapshotBuilder = ExternalSurfaceSnapshotBuilder(),
        privacyGate: PrivacyExternalBoundaryGate = PrivacyExternalBoundaryGate(),
        appGroupSnapshotStore: AppGroupSnapshotStore? = nil
    ) {
        self.repositories = repositories
        self.builder = builder
        self.privacyGate = privacyGate
        self.appGroupSnapshotStore = appGroupSnapshotStore ?? repositories.appGroupSnapshotStore
    }

    func refresh(now: Date = .now) async {
        do {
            guard let projectionStore = repositories.projectionStore else {
                throw ExternalSurfaceSnapshotWriterError.missingProjectionStore
            }
            guard let appGroupSnapshotStore else {
                throw ExternalSurfaceSnapshotWriterError.missingAppGroupSnapshotStore
            }
            guard let widgetRecord = try await projectionStore.fetchRecord(id: .widget) else {
                throw ExternalSurfaceSnapshotWriterError.missingProjection(.widget)
            }
            guard let privacyRecord = try await projectionStore.fetchRecord(id: .privacy) else {
                throw ExternalSurfaceSnapshotWriterError.missingProjection(.privacy)
            }

            let widget = try LocalRuntimeStorageCoding.decode(WidgetProjection.self, from: widgetRecord.payloadData)
            let privacy = try LocalRuntimeStorageCoding.decode(PrivacyProjection.self, from: privacyRecord.payloadData)
            try validateExternalSurfacePrivacy(widget: widget, privacy: privacy)

            let snapshot = builder.makeSnapshot(widget: widget, privacy: privacy, now: now)
            let data = try PersistenceCoding.encode(snapshot)
            let record = AppGroupSnapshotRecord(
                id: SharedExternalSnapshotStore.snapshotRecordID,
                snapshotKind: SharedExternalSnapshotStore.snapshotKind,
                createdAt: DomainTimestamp.string(from: now),
                privacyClasses: safePrivacyClasses(from: widget),
                containsPrivateRuntimeData: false,
                payloadData: data
            )
            let privacyDecision = privacyGate.evaluateExternalSnapshot(record: record, widget: widget, privacy: privacy)
            try privacyGate.requirePermitted(privacyDecision)
            try await appGroupSnapshotStore.write(record)

            await recordExternalSnapshotSideEffect(status: .recordedLocalOnly, at: now)
        } catch {
            await recordExternalSnapshotSideEffect(
                status: .failedSafely,
                at: now,
                degradedFacts: [
                    "External snapshot refresh/write did not complete.",
                    Self.failureDiagnostic(for: error)
                ]
            )
            // Snapshot export is best-effort and must never block user flows.
        }
    }

    private func validateExternalSurfacePrivacy(widget: WidgetProjection, privacy: PrivacyProjection) throws {
        let unsafeRowPrivacy = widget.rows.map(\.privacySummary).filter { value in
            value == EventLedgerPrivacyClassification.privateUserText.rawValue ||
                value == EventLedgerPrivacyClassification.sensitive.rawValue
        }
        guard unsafeRowPrivacy.isEmpty else {
            throw ExternalSurfaceSnapshotWriterError.unsafeWidgetProjection
        }

        let redactionRequired = Set(privacy.redactionRequiredEventIDs)
        let widgetRedacted = Set(widget.redactedEventIDs)
        guard redactionRequired.isSubset(of: widgetRedacted) else {
            throw ExternalSurfaceSnapshotWriterError.privacyProjectionMismatch
        }
    }

    private func safePrivacyClasses(from widget: WidgetProjection) -> [EventLedgerPrivacyClassification] {
        let classes = widget.rows.compactMap { row -> EventLedgerPrivacyClassification? in
            guard let classification = EventLedgerPrivacyClassification(rawValue: row.privacySummary),
                  classification == .standard || classification == .calendarDerived || classification == .syncMetadata else {
                return nil
            }
            return classification
        }
        let unique = Array(Set(classes)).sorted { $0.rawValue < $1.rawValue }
        return unique.isEmpty ? [.standard] : unique
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

    private static func failureDiagnostic(for error: any Error) -> String {
        if let writerError = error as? ExternalSurfaceSnapshotWriterError {
            return "External snapshot writer failed: \(writerError)"
        }
        if let gateError = error as? PrivacyExternalBoundaryGateError {
            return "External snapshot privacy gate failed: \(gateError)"
        }
        if let storageError = error as? LocalRuntimeStorageError {
            return "External snapshot storage failed: \(storageError)"
        }
        return "External snapshot failed with \(String(describing: type(of: error)))"
    }
}

enum ExternalSurfaceSnapshotWriterError: Error {
    case missingProjectionStore
    case missingAppGroupSnapshotStore
    case missingProjection(ProjectionID)
    case unsafeWidgetProjection
    case privacyProjectionMismatch
}
