import Foundation

protocol ExternalSurfaceSnapshotWriting: Sendable {
    func refresh(now: Date) async
}

actor ExternalSurfaceSnapshotWriter: ExternalSurfaceSnapshotWriting {
    private let repositories: AppRepositories
    private let builder: ExternalSurfaceSnapshotBuilder
    private let appGroupSnapshotStore: AppGroupSnapshotStore?

    init(
        repositories: AppRepositories,
        builder: ExternalSurfaceSnapshotBuilder = ExternalSurfaceSnapshotBuilder(),
        appGroupSnapshotStore: AppGroupSnapshotStore? = nil
    ) {
        self.repositories = repositories
        self.builder = builder
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
            try await appGroupSnapshotStore.write(record)

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
        guard widgetRedacted.isSubset(of: redactionRequired) else {
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
}

enum ExternalSurfaceSnapshotWriterError: Error {
    case missingProjectionStore
    case missingAppGroupSnapshotStore
    case missingProjection(ProjectionID)
    case unsafeWidgetProjection
    case privacyProjectionMismatch
}
