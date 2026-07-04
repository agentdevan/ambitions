import Foundation

struct CaptureDirectLookupEntry: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let captureID: String
    let intakeRecordID: String
    let draftID: String?
    let decisionID: String
    let route: CaptureRoute
    let kind: CaptureKind
    let sourceSurface: String
    let rawTextFingerprint: String
    let attachmentIDs: [String]
    let updatedAt: String
    let privacy: EventLedgerPrivacyClassification
    let checksum: String

    init(
        intake: CaptureIntakeJournalRecord,
        draft: CaptureDraftRecord?,
        decision: CaptureRouteDecision,
        updatedAt: String
    ) {
        captureID = intake.captureID
        intakeRecordID = intake.id
        draftID = draft?.id
        decisionID = decision.id
        route = decision.route
        kind = decision.kind
        sourceSurface = intake.sourceSurface
        rawTextFingerprint = CaptureRoutingStableID.checksum(prefix: "capture-text", components: [intake.rawText])
        attachmentIDs = intake.attachmentIDs
        self.updatedAt = CaptureRoutingStableID.required(updatedAt)
        privacy = intake.privacy
        id = CaptureRoutingStableID.make(prefix: "capture-lookup", components: [captureID, intakeRecordID, decisionID])
        checksum = CaptureRoutingStableID.checksum(
            prefix: "capture-lookup",
            components: [
                id,
                captureID,
                intakeRecordID,
                draftID ?? "",
                decisionID,
                route.rawValue,
                kind.rawValue,
                sourceSurface,
                rawTextFingerprint,
                attachmentIDs.joined(separator: ","),
                self.updatedAt,
                privacy.rawValue
            ]
        )
    }

    private init(
        id: String,
        captureID: String,
        intakeRecordID: String,
        draftID: String?,
        decisionID: String,
        route: CaptureRoute,
        kind: CaptureKind,
        sourceSurface: String,
        rawTextFingerprint: String,
        attachmentIDs: [String],
        updatedAt: String,
        privacy: EventLedgerPrivacyClassification
    ) {
        self.id = id
        self.captureID = captureID
        self.intakeRecordID = intakeRecordID
        self.draftID = draftID
        self.decisionID = decisionID
        self.route = route
        self.kind = kind
        self.sourceSurface = sourceSurface
        self.rawTextFingerprint = rawTextFingerprint
        self.attachmentIDs = attachmentIDs
        self.updatedAt = updatedAt
        self.privacy = privacy
        checksum = CaptureRoutingStableID.checksum(
            prefix: "capture-lookup",
            components: [
                id,
                captureID,
                intakeRecordID,
                draftID ?? "",
                decisionID,
                route.rawValue,
                kind.rawValue,
                sourceSurface,
                rawTextFingerprint,
                attachmentIDs.joined(separator: ","),
                updatedAt,
                privacy.rawValue
            ]
        )
    }

    func updatingRoute(
        route: CaptureRoute,
        kind: CaptureKind,
        decisionID: String?,
        updatedAt: String
    ) -> CaptureDirectLookupEntry {
        CaptureDirectLookupEntry(
            id: id,
            captureID: captureID,
            intakeRecordID: intakeRecordID,
            draftID: draftID,
            decisionID: CaptureRoutingStableID.optional(decisionID) ?? self.decisionID,
            route: route,
            kind: kind,
            sourceSurface: sourceSurface,
            rawTextFingerprint: rawTextFingerprint,
            attachmentIDs: attachmentIDs,
            updatedAt: CaptureRoutingStableID.required(updatedAt),
            privacy: privacy
        )
    }
}

actor CaptureDirectLookupIndex {
    private var entriesCache: [CaptureDirectLookupEntry]?
    private let fileStore: CaptureRoutingJSONFileStore<[CaptureDirectLookupEntry]>?

    init(fileURL: URL? = nil) {
        fileStore = fileURL.map { CaptureRoutingJSONFileStore(fileURL: $0, emptyValue: []) }
    }

    static func fileBacked(rootDirectory: URL) -> CaptureDirectLookupIndex {
        CaptureDirectLookupIndex(
            fileURL: CaptureRoutingJSONFileStore<[CaptureDirectLookupEntry]>.fileURL(
                rootDirectory: rootDirectory,
                fileName: "CaptureDirectLookupIndex.json"
            )
        )
    }

    @discardableResult
    func index(
        intake: CaptureIntakeJournalRecord,
        draft: CaptureDraftRecord?,
        decision: CaptureRouteDecision,
        updatedAt: String
    ) async throws -> CaptureDirectLookupEntry {
        var entries = try await loadEntries()
        let entry = CaptureDirectLookupEntry(intake: intake, draft: draft, decision: decision, updatedAt: updatedAt)
        entries.removeAll { $0.captureID == entry.captureID || $0.id == entry.id }
        entries.append(entry)
        entries.sort { $0.updatedAt < $1.updatedAt }
        try await persist(entries)
        return entry
    }

    func entry(captureID: String) async throws -> CaptureDirectLookupEntry? {
        try await loadEntries().last { $0.captureID == captureID }
    }

    func entries(route: CaptureRoute? = nil, kind: CaptureKind? = nil) async throws -> [CaptureDirectLookupEntry] {
        try await loadEntries().filter { entry in
            (route == nil || entry.route == route) &&
                (kind == nil || entry.kind == kind)
        }
    }

    func searchTextFingerprint(_ fingerprint: String) async throws -> [CaptureDirectLookupEntry] {
        let normalized = CaptureRoutingStableID.required(fingerprint)
        return try await loadEntries().filter { $0.rawTextFingerprint == normalized }
    }

    @discardableResult
    func updateRoute(
        captureID: String,
        route: CaptureRoute,
        kind: CaptureKind,
        decisionID: String? = nil,
        updatedAt: String
    ) async throws -> CaptureDirectLookupEntry? {
        var entries = try await loadEntries()
        guard let index = entries.lastIndex(where: { $0.captureID == captureID }) else {
            return nil
        }
        let updated = entries[index].updatingRoute(route: route, kind: kind, decisionID: decisionID, updatedAt: updatedAt)
        entries[index] = updated
        try await persist(entries)
        return updated
    }

    private func loadEntries() async throws -> [CaptureDirectLookupEntry] {
        if let entriesCache {
            return entriesCache
        }
        let loaded = try await fileStore?.load() ?? []
        entriesCache = loaded.sorted { $0.updatedAt < $1.updatedAt }
        return entriesCache ?? []
    }

    private func persist(_ entries: [CaptureDirectLookupEntry]) async throws {
        entriesCache = entries
        try await fileStore?.save(entries)
    }
}
