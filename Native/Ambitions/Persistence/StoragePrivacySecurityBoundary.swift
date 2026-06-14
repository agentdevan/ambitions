import Foundation

let storagePrivacySecurityBoundarySchemaVersion = "storage_privacy_security_boundary.native.v1"

enum StorageProtectedMode: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case enforcedReview = "enforced_review"
    case notEnforced = "not_enforced"

    var isEnforced: Bool {
        self == .enforcedReview
    }
}

enum StoragePrivacyBoundaryDestination: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case localStore = "local_store"
    case userICloud = "user_icloud"
    case portableExport = "portable_export"
    case supportBundle = "support_bundle"
    case localIndex = "local_index"
    case r2PublicSourcePack = "r2_public_source_pack"
    case sourceAtlasCache = "source_atlas_cache"
    case receiptReplayInspection = "receipt_replay_inspection"
    case whatAmbitionsKnows = "what_ambitions_knows"

    var requiresProtectedReview: Bool {
        switch self {
        case .portableExport, .supportBundle, .localIndex, .r2PublicSourcePack, .sourceAtlasCache:
            return true
        case .localStore, .userICloud, .receiptReplayInspection, .whatAmbitionsKnows:
            return false
        }
    }

    var requiresRedactionForPrivateData: Bool {
        switch self {
        case .portableExport, .supportBundle, .sourceAtlasCache, .receiptReplayInspection:
            return true
        case .localStore, .userICloud, .localIndex, .r2PublicSourcePack, .whatAmbitionsKnows:
            return false
        }
    }
}

enum StoragePrivacySecurityBoundaryIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case malformedRecord = "malformed_record"
    case privateCategoryMarkedExportSafe = "private_category_marked_export_safe"
    case privateCategoryIndexed = "private_category_indexed"
    case privateCategorySupportVisibleWithoutRedaction = "private_category_support_visible_without_redaction"
    case privateCategoryPublicEligible = "private_category_public_eligible"
    case protectedModeNotEnforced = "protected_mode_not_enforced"
    case userReviewMissing = "user_review_missing"
    case redactionSummaryMissing = "redaction_summary_missing"
    case sourceRecordBoundaryMissing = "source_record_boundary_missing"
    case receiptBoundaryMissing = "receipt_boundary_missing"
    case replayTraceBoundaryMissing = "replay_trace_boundary_missing"
    case whatAmbitionsKnowsInspectionMissing = "what_ambitions_knows_inspection_missing"
}

struct StoragePrivacySecurityBoundaryFinding: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let recordID: String
    let destination: StoragePrivacyBoundaryDestination?
    let issue: StoragePrivacySecurityBoundaryIssue
    let summary: String

    init(
        recordID: String,
        destination: StoragePrivacyBoundaryDestination? = nil,
        issue: StoragePrivacySecurityBoundaryIssue,
        summary: String
    ) {
        self.recordID = recordID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.destination = destination
        self.issue = issue
        self.summary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.id = [
            self.recordID,
            destination?.rawValue ?? "storage",
            issue.rawValue
        ].joined(separator: ".")
    }
}

struct StoragePrivacyBoundaryRecord: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let privacyClass: AFEPStoragePrivacyClass
    let indexingPolicy: AFEPIndexingPolicy
    let exportPolicy: AFEPExportPolicy
    let measurementEvidenceState: AFEPMeasurementEvidenceState
    let destinations: [StoragePrivacyBoundaryDestination]
    let redactionSummary: String
    let sourceRecordID: String?
    let receiptID: String?
    let replayTraceID: String?
    let whatAmbitionsKnowsInspectionPath: String?
    let userReviewed: Bool
    let schemaVersion: String

    init(
        id: String,
        title: String,
        privacyClass: AFEPStoragePrivacyClass,
        indexingPolicy: AFEPIndexingPolicy = .notIndexed,
        exportPolicy: AFEPExportPolicy = .blocked,
        measurementEvidenceState: AFEPMeasurementEvidenceState = .planned,
        destinations: [StoragePrivacyBoundaryDestination],
        redactionSummary: String = "",
        sourceRecordID: String? = nil,
        receiptID: String? = nil,
        replayTraceID: String? = nil,
        whatAmbitionsKnowsInspectionPath: String? = nil,
        userReviewed: Bool = false,
        schemaVersion: String = storagePrivacySecurityBoundarySchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.privacyClass = privacyClass
        self.indexingPolicy = indexingPolicy
        self.exportPolicy = exportPolicy
        self.measurementEvidenceState = measurementEvidenceState
        self.destinations = Array(Set(destinations)).sorted { $0.rawValue < $1.rawValue }
        self.redactionSummary = redactionSummary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceRecordID = sourceRecordID?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.receiptID = receiptID?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.replayTraceID = replayTraceID?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.whatAmbitionsKnowsInspectionPath = whatAmbitionsKnowsInspectionPath?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.userReviewed = userReviewed
        self.schemaVersion = schemaVersion
    }

    var containsPrivateUserData: Bool {
        privacyClass.requiresRedaction
    }

    var needsRuntimeInspectionAnchors: Bool {
        containsPrivateUserData ||
            destinations.contains(.portableExport) ||
            destinations.contains(.supportBundle) ||
            destinations.contains(.receiptReplayInspection) ||
            destinations.contains(.sourceAtlasCache)
    }

    var needsProtectedMode: Bool {
        containsPrivateUserData &&
            destinations.contains { $0.requiresProtectedReview }
    }

    var hasRedactionSummary: Bool {
        redactionSummary.isEmpty == false
    }

    var hasSourceRecordBoundary: Bool {
        sourceRecordID?.isEmpty == false
    }

    var hasReceiptBoundary: Bool {
        receiptID?.isEmpty == false
    }

    var hasReplayTraceBoundary: Bool {
        replayTraceID?.isEmpty == false
    }

    var hasWhatAmbitionsKnowsInspection: Bool {
        whatAmbitionsKnowsInspectionPath?.isEmpty == false
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            title.isEmpty == false &&
            destinations.isEmpty == false &&
            schemaVersion == storagePrivacySecurityBoundarySchemaVersion
    }
}

struct StoragePrivacyRedactedProjection: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let recordID: String
    let destination: StoragePrivacyBoundaryDestination
    let visibleTitle: String
    let privacyClass: AFEPStoragePrivacyClass
    let redactionApplied: Bool
    let redactionSummary: String
    let sourceRecordID: String?
    let receiptID: String?
    let replayTraceID: String?
    let sourceRecordPresent: Bool
    let receiptPresent: Bool
    let replayTracePresent: Bool
    let whatAmbitionsKnowsInspectionPresent: Bool

    var isBoundaryPreserving: Bool {
        sourceRecordPresent &&
            receiptPresent &&
            replayTracePresent &&
            whatAmbitionsKnowsInspectionPresent
    }
}

struct StoragePrivacyRedactionFilter: Sendable, Equatable, Hashable {
    func projection(
        for record: StoragePrivacyBoundaryRecord,
        destination: StoragePrivacyBoundaryDestination
    ) -> StoragePrivacyRedactedProjection {
        let shouldRedact = record.containsPrivateUserData && destination.requiresRedactionForPrivateData
        let visibleTitle = shouldRedact ? record.privacyClass.redactedTitle : record.title

        return StoragePrivacyRedactedProjection(
            id: "\(record.id).\(destination.rawValue)",
            recordID: record.id,
            destination: destination,
            visibleTitle: visibleTitle,
            privacyClass: record.privacyClass,
            redactionApplied: shouldRedact,
            redactionSummary: shouldRedact ? record.redactionSummary : "",
            sourceRecordID: shouldRedact ? nil : record.sourceRecordID,
            receiptID: shouldRedact ? nil : record.receiptID,
            replayTraceID: shouldRedact ? nil : record.replayTraceID,
            sourceRecordPresent: record.hasSourceRecordBoundary,
            receiptPresent: record.hasReceiptBoundary,
            replayTracePresent: record.hasReplayTraceBoundary,
            whatAmbitionsKnowsInspectionPresent: record.hasWhatAmbitionsKnowsInspection
        )
    }
}

struct StoragePrivacySecurityBoundaryReport: Codable, Sendable, Equatable {
    let schemaVersion: String
    let protectedMode: StorageProtectedMode
    let checkedRecordCount: Int
    let records: [StoragePrivacyBoundaryRecord]
    let projections: [StoragePrivacyRedactedProjection]
    let findings: [StoragePrivacySecurityBoundaryFinding]

    var issueCount: Int {
        findings.count
    }

    var isGreen: Bool {
        findings.isEmpty
    }

    var canPreparePortableExport: Bool {
        isGreen && projections.contains { $0.destination == .portableExport }
    }

    var canPrepareSupportBundle: Bool {
        isGreen && projections.contains { $0.destination == .supportBundle }
    }

    var canBuildLocalIndex: Bool {
        isGreen && records.contains { $0.destinations.contains(.localIndex) }
    }

    var canPublishPublicSourcePack: Bool {
        isGreen && records.contains { $0.destinations.contains(.r2PublicSourcePack) }
    }
}

struct StoragePrivacySecurityBoundaryValidator: Sendable, Equatable, Hashable {
    private let redactionFilter: StoragePrivacyRedactionFilter

    init(redactionFilter: StoragePrivacyRedactionFilter = StoragePrivacyRedactionFilter()) {
        self.redactionFilter = redactionFilter
    }

    func validate(
        records: [StoragePrivacyBoundaryRecord],
        protectedMode: StorageProtectedMode = .enforcedReview
    ) -> StoragePrivacySecurityBoundaryReport {
        var findings: [StoragePrivacySecurityBoundaryFinding] = []

        for record in records {
            appendShapeFindings(record, to: &findings)
            appendPrivateDataFindings(record, protectedMode: protectedMode, to: &findings)
            appendRuntimeAnchorFindings(record, to: &findings)
        }

        let projections = records.flatMap { record in
            record.destinations.map { destination in
                redactionFilter.projection(for: record, destination: destination)
            }
        }

        return StoragePrivacySecurityBoundaryReport(
            schemaVersion: storagePrivacySecurityBoundarySchemaVersion,
            protectedMode: protectedMode,
            checkedRecordCount: records.count,
            records: records,
            projections: projections.sorted { $0.id < $1.id },
            findings: findings.sorted { $0.id < $1.id }
        )
    }

    private func appendShapeFindings(
        _ record: StoragePrivacyBoundaryRecord,
        to findings: inout [StoragePrivacySecurityBoundaryFinding]
    ) {
        if record.schemaVersion != storagePrivacySecurityBoundarySchemaVersion {
            findings.append(StoragePrivacySecurityBoundaryFinding(
                recordID: record.id,
                issue: .unsupportedSchema,
                summary: "Storage privacy boundary schema is not current."
            ))
        }
        if record.isWellFormed == false {
            findings.append(StoragePrivacySecurityBoundaryFinding(
                recordID: record.id,
                issue: .malformedRecord,
                summary: "Storage privacy boundary record must include an id, title, destination, and current schema."
            ))
        }
    }

    private func appendPrivateDataFindings(
        _ record: StoragePrivacyBoundaryRecord,
        protectedMode: StorageProtectedMode,
        to findings: inout [StoragePrivacySecurityBoundaryFinding]
    ) {
        guard record.containsPrivateUserData else {
            if record.privacyClass != .publicMetadata && record.destinations.contains(.r2PublicSourcePack) {
                findings.append(StoragePrivacySecurityBoundaryFinding(
                    recordID: record.id,
                    destination: .r2PublicSourcePack,
                    issue: .privateCategoryPublicEligible,
                    summary: "Only public metadata can enter public source-pack paths."
                ))
            }
            return
        }

        if record.exportPolicy == .safe {
            findings.append(StoragePrivacySecurityBoundaryFinding(
                recordID: record.id,
                issue: .privateCategoryMarkedExportSafe,
                summary: "Private storage categories cannot be marked export safe."
            ))
        }
        if record.indexingPolicy == .indexed {
            findings.append(StoragePrivacySecurityBoundaryFinding(
                recordID: record.id,
                destination: .localIndex,
                issue: .privateCategoryIndexed,
                summary: "Private storage categories cannot be indexed."
            ))
        }
        if record.destinations.contains(.r2PublicSourcePack) {
            findings.append(StoragePrivacySecurityBoundaryFinding(
                recordID: record.id,
                destination: .r2PublicSourcePack,
                issue: .privateCategoryPublicEligible,
                summary: "Private user data cannot enter public source-pack paths."
            ))
        }
        if record.destinations.contains(.supportBundle) && record.hasRedactionSummary == false {
            findings.append(StoragePrivacySecurityBoundaryFinding(
                recordID: record.id,
                destination: .supportBundle,
                issue: .privateCategorySupportVisibleWithoutRedaction,
                summary: "Support bundle visibility requires a redaction summary for private data."
            ))
        }
        if record.needsProtectedMode && protectedMode.isEnforced == false {
            findings.append(StoragePrivacySecurityBoundaryFinding(
                recordID: record.id,
                issue: .protectedModeNotEnforced,
                summary: "Protected mode must be enforced before private storage reaches export, support, index, or source-cache paths."
            ))
        }
        if record.needsProtectedMode && record.userReviewed == false {
            findings.append(StoragePrivacySecurityBoundaryFinding(
                recordID: record.id,
                issue: .userReviewMissing,
                summary: "Protected mode requires explicit user review before private storage leaves local-only inspection."
            ))
        }
        if record.destinations.contains(where: { $0.requiresRedactionForPrivateData }) && record.hasRedactionSummary == false {
            findings.append(StoragePrivacySecurityBoundaryFinding(
                recordID: record.id,
                issue: .redactionSummaryMissing,
                summary: "Private export, support, receipt, replay, and source-cache projections require a redaction summary."
            ))
        }
    }

    private func appendRuntimeAnchorFindings(
        _ record: StoragePrivacyBoundaryRecord,
        to findings: inout [StoragePrivacySecurityBoundaryFinding]
    ) {
        guard record.needsRuntimeInspectionAnchors else { return }

        if record.hasSourceRecordBoundary == false {
            findings.append(StoragePrivacySecurityBoundaryFinding(
                recordID: record.id,
                issue: .sourceRecordBoundaryMissing,
                summary: "Storage privacy boundary must keep a SourceRecord anchor."
            ))
        }
        if record.hasReceiptBoundary == false {
            findings.append(StoragePrivacySecurityBoundaryFinding(
                recordID: record.id,
                issue: .receiptBoundaryMissing,
                summary: "Storage privacy boundary must keep a Receipt anchor."
            ))
        }
        if record.hasReplayTraceBoundary == false {
            findings.append(StoragePrivacySecurityBoundaryFinding(
                recordID: record.id,
                issue: .replayTraceBoundaryMissing,
                summary: "Storage privacy boundary must keep a ReplayTrace anchor."
            ))
        }
        if record.hasWhatAmbitionsKnowsInspection == false {
            findings.append(StoragePrivacySecurityBoundaryFinding(
                recordID: record.id,
                issue: .whatAmbitionsKnowsInspectionMissing,
                summary: "Storage privacy boundary must route to You / What Ambitions knows inspection."
            ))
        }
    }
}

enum StoragePrivacyBoundaryCatalog {
    static func records(
        from manifest: PortableExportManifest,
        userReviewed: Bool = true
    ) -> [StoragePrivacyBoundaryRecord] {
        manifest.categories.map { summary in
            StoragePrivacyBoundaryRecord(
                id: "portable_export.\(summary.category.rawValue)",
                title: summary.title,
                privacyClass: summary.privacyClass,
                indexingPolicy: summary.indexingPolicy,
                exportPolicy: summary.exportPolicy,
                measurementEvidenceState: summary.measurementEvidenceState,
                destinations: destinations(for: summary.category),
                redactionSummary: summary.privacyClass.requiresRedaction ? summary.previewRule : "",
                sourceRecordID: "SourceRecord.portable_export.\(summary.category.rawValue)",
                receiptID: "Receipt.portable_export.\(summary.category.rawValue)",
                replayTraceID: "ReplayTrace.portable_export.\(summary.category.rawValue)",
                whatAmbitionsKnowsInspectionPath: "You / What Ambitions knows / Portable export / \(summary.title)",
                userReviewed: userReviewed
            )
        }
    }

    private static func destinations(for category: PortableExportCategory) -> [StoragePrivacyBoundaryDestination] {
        switch category {
        case .goalsAndPlans, .captures, .proof, .memory:
            return [.localStore, .portableExport, .supportBundle, .whatAmbitionsKnows]
        case .receipts:
            return [.localStore, .portableExport, .supportBundle, .receiptReplayInspection, .whatAmbitionsKnows]
        case .settings:
            return [.localStore, .portableExport, .whatAmbitionsKnows]
        }
    }
}

private extension AFEPStoragePrivacyClass {
    var redactedTitle: String {
        switch self {
        case .publicMetadata:
            return "Public metadata"
        case .systemOwned:
            return "System-owned setting"
        case .localOnly:
            return "Local-only private item"
        case .privateSensitive:
            return "Private life item"
        case .proofRestricted:
            return "Private proof item"
        case .replayRestricted:
            return "Private replay item"
        case .lineageRestricted:
            return "Private lineage item"
        }
    }
}
