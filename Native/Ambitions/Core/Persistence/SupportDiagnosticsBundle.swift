import Foundation

let supportDiagnosticsBundleSchemaVersion = "support_diagnostics_bundle.native.v1"

enum SupportDiagnosticsExportFormat: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case json = "json"
    case jsonLines = "json_lines"
    case markdownSummary = "markdown_summary"
}

enum SupportDiagnosticsBundleDestination: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case localInspection = "local_inspection"
    case userInitiatedShare = "user_initiated_share"
    case supportAttachment = "support_attachment"
    case thirdPartyAnalytics = "third_party_analytics"
}

enum SupportDiagnosticsBundleIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case exportFormatMissing = "export_format_missing"
    case thirdPartyAnalyticsDestination = "third_party_analytics_destination"
    case userReviewMissing = "user_review_missing"
    case storageBoundaryNotGreen = "storage_boundary_not_green"
    case supportBoundaryMissing = "support_boundary_missing"
    case supportBoundaryRedactionMissing = "support_boundary_redaction_missing"
    case privateDiagnosticVisible = "private_diagnostic_visible"
}

struct SupportDiagnosticsBundleFinding: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let issue: SupportDiagnosticsBundleIssue
    let summary: String
    let diagnosticID: String?

    init(
        issue: SupportDiagnosticsBundleIssue,
        summary: String,
        diagnosticID: String? = nil
    ) {
        self.issue = issue
        self.summary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.diagnosticID = diagnosticID?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.id = [
            "support_diagnostics",
            self.diagnosticID ?? "bundle",
            issue.rawValue
        ].joined(separator: ".")
    }
}

struct SupportDiagnosticsBundleEntry: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let diagnosticID: String
    let signal: DiagnosticLedgerSignal
    let severity: DiagnosticLedgerSeverity
    let occurredAt: String
    let title: String
    let summary: String
    let privacy: EventLedgerPrivacyClassification
    let redactionApplied: Bool
    let localOnly: Bool
    let requiresReview: Bool
    let sourceRecordAnchor: String
    let metadataKeys: [String]
    let payloadKeys: [String]

    var isSupportSafe: Bool {
        redactionApplied || privacy == .standard
    }
}

struct SupportDiagnosticsStorageBoundarySummary: Codable, Sendable, Equatable, Hashable {
    let issueCount: Int
    let projectionCount: Int
    let supportProjectionCount: Int
    let privateSupportProjectionCount: Int
    let redactedSupportProjectionCount: Int
    let canPrepareSupportBundle: Bool

    var hasRedactedPrivateSupportCoverage: Bool {
        privateSupportProjectionCount == redactedSupportProjectionCount
    }

    init(report: StoragePrivacySecurityBoundaryReport) {
        let supportProjections = report.projections.filter { $0.destination == .supportBundle }
        let privateSupportProjections = supportProjections.filter { $0.privacyClass.requiresRedaction }
        self.issueCount = report.issueCount
        self.projectionCount = report.projections.count
        self.supportProjectionCount = supportProjections.count
        self.privateSupportProjectionCount = privateSupportProjections.count
        self.redactedSupportProjectionCount = privateSupportProjections.filter(\.redactionApplied).count
        self.canPrepareSupportBundle = report.canPrepareSupportBundle
    }
}

struct SupportDiagnosticsBundleManifest: Codable, Sendable, Equatable, Hashable {
    let schemaVersion: String
    let generatedAt: String
    let formats: [SupportDiagnosticsExportFormat]
    let destinations: [SupportDiagnosticsBundleDestination]
    let diagnosticEntryCount: Int
    let redactedEntryCount: Int
    let requiresAttention: Bool
    let localOnly: Bool
    let userReviewed: Bool
    let thirdPartyAnalyticsEnabled: Bool
    let inspectionPath: String
    let redactionRules: [String]
}

struct SupportDiagnosticsExportPayload: Codable, Sendable, Equatable, Hashable {
    let format: SupportDiagnosticsExportFormat
    let content: String
    let lineCount: Int
    let containsPrivateDiagnosticText: Bool
}

struct SupportDiagnosticsBundle: Codable, Sendable, Equatable, Hashable {
    let manifest: SupportDiagnosticsBundleManifest
    let storageBoundary: SupportDiagnosticsStorageBoundarySummary
    let entries: [SupportDiagnosticsBundleEntry]
    let findings: [SupportDiagnosticsBundleFinding]

    var isGreen: Bool {
        findings.isEmpty
    }

    var canExportSupportAttachment: Bool {
        isGreen && manifest.destinations.contains(.supportAttachment)
    }

    func exportPayload(format: SupportDiagnosticsExportFormat) throws -> SupportDiagnosticsExportPayload {
        let content: String
        switch format {
        case .json:
            content = try Self.sortedJSONString(self)
        case .jsonLines:
            content = try entries.map(Self.sortedJSONString).joined(separator: "\n")
        case .markdownSummary:
            content = markdownSummary
        }

        return SupportDiagnosticsExportPayload(
            format: format,
            content: content,
            lineCount: content.isEmpty ? 0 : content.split(separator: "\n", omittingEmptySubsequences: false).count,
            containsPrivateDiagnosticText: entries.contains { $0.redactionApplied == false && $0.privacy != .standard }
        )
    }

    private var markdownSummary: String {
        var lines: [String] = [
            "# Support Diagnostics Bundle",
            "Schema: \(manifest.schemaVersion)",
            "Generated: \(manifest.generatedAt)",
            "Status: \(isGreen ? "Green" : "Blocked")",
            "Third-party analytics: \(manifest.thirdPartyAnalyticsEnabled ? "enabled" : "disabled")",
            "Inspection path: \(manifest.inspectionPath)",
            "Diagnostics: \(manifest.diagnosticEntryCount)",
            "Redacted entries: \(manifest.redactedEntryCount)",
            "Storage boundary issues: \(storageBoundary.issueCount)",
            ""
        ]
        lines.append("## Entries")
        lines.append(contentsOf: entries.map { entry in
            "- \(entry.severity.rawValue) / \(entry.signal.rawValue): \(entry.title) - \(entry.summary)"
        })
        if findings.isEmpty == false {
            lines.append("")
            lines.append("## Findings")
            lines.append(contentsOf: findings.map { finding in
                "- \(finding.issue.rawValue): \(finding.summary)"
            })
        }
        return lines.joined(separator: "\n")
    }

    private static func sortedJSONString<Value: Encodable>(_ value: Value) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(value)
        guard let string = String(data: data, encoding: .utf8) else {
            throw SupportDiagnosticsBundleEncodingError.invalidUTF8
        }
        return string
    }
}

enum SupportDiagnosticsBundleEncodingError: Error, Equatable {
    case invalidUTF8
}

struct SupportDiagnosticsRedactionPolicy: Sendable, Equatable, Hashable {
    let privateTitle: String
    let privateSummary: String
    let redactedAnchor: String

    init(
        privateTitle: String = "Private diagnostic",
        privateSummary: String = "Details hidden in support export; inspect locally from the diagnostics review path.",
        redactedAnchor: String = "[redacted]"
    ) {
        self.privateTitle = privateTitle
        self.privateSummary = privateSummary
        self.redactedAnchor = redactedAnchor
    }

    func entry(from diagnostic: DiagnosticLedgerEntry) -> SupportDiagnosticsBundleEntry {
        let shouldRedact = diagnostic.privacy != .standard || diagnostic.requiresReview || diagnostic.severity.requiresAttention
        return SupportDiagnosticsBundleEntry(
            id: "support.\(diagnostic.id)",
            diagnosticID: diagnostic.id,
            signal: diagnostic.signal,
            severity: diagnostic.severity,
            occurredAt: diagnostic.occurredAt,
            title: shouldRedact ? privateTitle : diagnostic.title,
            summary: shouldRedact ? privateSummary : diagnostic.summary,
            privacy: diagnostic.privacy,
            redactionApplied: shouldRedact,
            localOnly: diagnostic.localOnly,
            requiresReview: diagnostic.requiresReview,
            sourceRecordAnchor: shouldRedact ? redactedAnchor : diagnostic.sourceRecordID,
            metadataKeys: diagnostic.metadata.keys.sorted(),
            payloadKeys: diagnostic.payload.keys.sorted()
        )
    }
}

struct SupportDiagnosticsBundleBuilder: Sendable, Equatable, Hashable {
    let redactionPolicy: SupportDiagnosticsRedactionPolicy

    init(redactionPolicy: SupportDiagnosticsRedactionPolicy = SupportDiagnosticsRedactionPolicy()) {
        self.redactionPolicy = redactionPolicy
    }

    func makeBundle(
        diagnosticSnapshot: DiagnosticLedgerSnapshot,
        storageBoundaryReport: StoragePrivacySecurityBoundaryReport,
        formats: [SupportDiagnosticsExportFormat] = [.json, .jsonLines, .markdownSummary],
        destinations: [SupportDiagnosticsBundleDestination] = [.localInspection, .supportAttachment],
        generatedAt: String,
        userReviewed: Bool,
        inspectionPath: String = "You / Diagnostics / Support bundle review"
    ) -> SupportDiagnosticsBundle {
        let normalizedFormats = orderedUnique(formats)
        let normalizedDestinations = orderedUnique(destinations)
        let entries = diagnosticSnapshot.entries.map(redactionPolicy.entry(from:))
        let storageSummary = SupportDiagnosticsStorageBoundarySummary(report: storageBoundaryReport)
        let manifest = SupportDiagnosticsBundleManifest(
            schemaVersion: supportDiagnosticsBundleSchemaVersion,
            generatedAt: generatedAt.trimmingCharacters(in: .whitespacesAndNewlines),
            formats: normalizedFormats,
            destinations: normalizedDestinations,
            diagnosticEntryCount: entries.count,
            redactedEntryCount: entries.filter(\.redactionApplied).count,
            requiresAttention: diagnosticSnapshot.requiresAttention,
            localOnly: true,
            userReviewed: userReviewed,
            thirdPartyAnalyticsEnabled: normalizedDestinations.contains(.thirdPartyAnalytics),
            inspectionPath: inspectionPath.trimmingCharacters(in: .whitespacesAndNewlines),
            redactionRules: [
                "Private, review-required, warning, blocked, or critical diagnostics show safe labels only.",
                "Metadata and payload values are excluded; only sorted keys are exported.",
                "Support exports require a Green storage privacy boundary and explicit user review.",
                "Third-party analytics destinations are blocked by default."
            ]
        )

        return SupportDiagnosticsBundle(
            manifest: manifest,
            storageBoundary: storageSummary,
            entries: entries.sorted { $0.id < $1.id },
            findings: findings(
                manifest: manifest,
                storageBoundary: storageSummary,
                entries: entries
            )
        )
    }

    private func findings(
        manifest: SupportDiagnosticsBundleManifest,
        storageBoundary: SupportDiagnosticsStorageBoundarySummary,
        entries: [SupportDiagnosticsBundleEntry]
    ) -> [SupportDiagnosticsBundleFinding] {
        var findings: [SupportDiagnosticsBundleFinding] = []

        if manifest.formats.isEmpty {
            findings.append(SupportDiagnosticsBundleFinding(
                issue: .exportFormatMissing,
                summary: "Support diagnostics bundle must declare at least one deterministic export format."
            ))
        }
        if manifest.thirdPartyAnalyticsEnabled {
            findings.append(SupportDiagnosticsBundleFinding(
                issue: .thirdPartyAnalyticsDestination,
                summary: "Support diagnostics cannot use third-party analytics destinations by default."
            ))
        }
        if manifest.userReviewed == false {
            findings.append(SupportDiagnosticsBundleFinding(
                issue: .userReviewMissing,
                summary: "Support diagnostics export requires explicit user review."
            ))
        }
        if storageBoundary.issueCount > 0 {
            findings.append(SupportDiagnosticsBundleFinding(
                issue: .storageBoundaryNotGreen,
                summary: "Support diagnostics export requires a Green storage privacy boundary."
            ))
        }
        if storageBoundary.canPrepareSupportBundle == false {
            findings.append(SupportDiagnosticsBundleFinding(
                issue: .supportBoundaryMissing,
                summary: "Storage privacy boundary must explicitly allow support bundle preparation."
            ))
        }
        if storageBoundary.hasRedactedPrivateSupportCoverage == false {
            findings.append(SupportDiagnosticsBundleFinding(
                issue: .supportBoundaryRedactionMissing,
                summary: "Every private support projection must be redacted before export."
            ))
        }

        for entry in entries where entry.isSupportSafe == false {
            findings.append(SupportDiagnosticsBundleFinding(
                issue: .privateDiagnosticVisible,
                summary: "Private diagnostic entry must be redacted before support export.",
                diagnosticID: entry.diagnosticID
            ))
        }

        return findings.sorted { $0.id < $1.id }
    }

    private func orderedUnique<Value: RawRepresentable & Hashable>(_ values: [Value]) -> [Value] where Value.RawValue == String {
        var seen = Set<Value>()
        return values
            .filter { seen.insert($0).inserted }
            .sorted { $0.rawValue < $1.rawValue }
    }
}
