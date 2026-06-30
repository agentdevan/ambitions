import Foundation

enum PrivacyExportDestination: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case portablePackage = "portable_package"
    case supportBundle = "support_bundle"
    case diagnosticsAttachment = "diagnostics_attachment"
}

struct PrivacyExportRequest: Codable, Sendable, Equatable, Hashable {
    let id: String
    let destination: PrivacyExportDestination
    let records: [StoragePrivacyBoundaryRecord]
    let protectedMode: StorageProtectedMode
    let userReviewed: Bool

    init(
        id: String,
        destination: PrivacyExportDestination,
        records: [StoragePrivacyBoundaryRecord],
        protectedMode: StorageProtectedMode = .enforcedReview,
        userReviewed: Bool
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.destination = destination
        self.records = records
        self.protectedMode = protectedMode
        self.userReviewed = userReviewed
    }
}

struct PrivacyExportDecision: Codable, Sendable, Equatable {
    let requestID: String
    let destination: PrivacyExportDestination
    let permitted: Bool
    let report: StoragePrivacySecurityBoundaryReport
    let allowedProjectionIDs: [String]
    let receipt: PrivacySecurityReceipt
}

struct ExportPolicy: Sendable, Equatable {
    let validator: StoragePrivacySecurityBoundaryValidator

    init(validator: StoragePrivacySecurityBoundaryValidator = StoragePrivacySecurityBoundaryValidator()) {
        self.validator = validator
    }

    func evaluate(_ request: PrivacyExportRequest) -> PrivacyExportDecision {
        let reviewedRecords = request.records.map { record in
            StoragePrivacyBoundaryRecord(
                id: record.id,
                title: record.title,
                privacyClass: record.privacyClass,
                indexingPolicy: record.indexingPolicy,
                exportPolicy: record.exportPolicy,
                measurementEvidenceState: record.measurementEvidenceState,
                destinations: record.destinations,
                redactionSummary: record.redactionSummary,
                sourceRecordID: record.sourceRecordID,
                receiptID: record.receiptID,
                replayTraceID: record.replayTraceID,
                whatAmbitionsKnowsInspectionPath: record.whatAmbitionsKnowsInspectionPath,
                userReviewed: record.userReviewed && request.userReviewed,
                schemaVersion: record.schemaVersion
            )
        }
        let report = validator.validate(records: reviewedRecords, protectedMode: request.protectedMode)
        let allowedProjectionIDs = projections(for: request.destination, report: report).map(\.id).sorted()
        let destinationAllowed = destinationAllowed(request.destination, report: report)
        let permitted = destinationAllowed && allowedProjectionIDs.isEmpty == false
        let issueCodes = report.findings.map { $0.issue.rawValue }

        return PrivacyExportDecision(
            requestID: request.id,
            destination: request.destination,
            permitted: permitted,
            report: report,
            allowedProjectionIDs: allowedProjectionIDs,
            receipt: PrivacySecurityReceipt(
                id: "privacy_receipt.export.\(request.id)",
                action: .export,
                objectID: request.id,
                surface: .portableExport,
                permitted: permitted,
                redactionApplied: report.projections.contains { $0.redactionApplied },
                localOnlyInspectionPath: "You / Privacy / Export review / \(request.id)",
                issueCodes: issueCodes,
                summary: permitted
                    ? "Privacy export policy permitted \(request.destination.rawValue) after protected review."
                    : "Privacy export policy blocked \(request.destination.rawValue)."
            )
        )
    }

    private func destinationAllowed(
        _ destination: PrivacyExportDestination,
        report: StoragePrivacySecurityBoundaryReport
    ) -> Bool {
        switch destination {
        case .portablePackage:
            return report.canPreparePortableExport
        case .supportBundle, .diagnosticsAttachment:
            return report.canPrepareSupportBundle
        }
    }

    private func projections(
        for destination: PrivacyExportDestination,
        report: StoragePrivacySecurityBoundaryReport
    ) -> [StoragePrivacyRedactedProjection] {
        switch destination {
        case .portablePackage:
            return report.projections.filter { $0.destination == .portableExport }
        case .supportBundle, .diagnosticsAttachment:
            return report.projections.filter { $0.destination == .supportBundle }
        }
    }
}
