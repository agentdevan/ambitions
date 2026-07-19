import Foundation

let localBackendHealthSchemaVersion = "local_backend_health.native.v1"

enum LocalBackendHealthStatus: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case green
    case yellow
    case red
}

enum LocalRuntimeDiagnosticSeverity: String, Codable, Sendable, Equatable, Hashable, CaseIterable, Comparable {
    case healthy
    case notice
    case warning
    case critical

    static func < (lhs: LocalRuntimeDiagnosticSeverity, rhs: LocalRuntimeDiagnosticSeverity) -> Bool {
        order(lhs) < order(rhs)
    }

    private static func order(_ severity: LocalRuntimeDiagnosticSeverity) -> Int {
        switch severity {
        case .healthy:
            return 0
        case .notice:
            return 1
        case .warning:
            return 2
        case .critical:
            return 3
        }
    }
}

enum LocalRuntimeDiagnosticArea: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case command
    case runtimeTrace = "runtime_trace"
    case projection
    case privacy
    case sync
    case store
    case performance
}

struct LocalRuntimeDiagnosticRecord: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let area: LocalRuntimeDiagnosticArea
    let componentID: String
    let severity: LocalRuntimeDiagnosticSeverity
    let summary: String
    let redactedDetail: String
    let repairHint: String
    let evidenceIDs: [String]
    let localOnly: Bool
    let privacy: RuntimePrivacyClass
    let generatedAt: String
    let sourceOwner: String
    let schemaVersion: String

    init(
        id: String,
        area: LocalRuntimeDiagnosticArea,
        componentID: String,
        severity: LocalRuntimeDiagnosticSeverity,
        summary: String,
        detail: String,
        repairHint: String,
        evidenceIDs: [String] = [],
        localOnly: Bool = true,
        privacy: RuntimePrivacyClass = .systemOwned,
        generatedAt: String,
        sourceOwner: String = "Core/LocalRuntimeOS/Diagnostics",
        schemaVersion: String = localBackendHealthSchemaVersion
    ) {
        self.id = Self.normalizedID(id)
        self.area = area
        self.componentID = Self.normalized(componentID, fallback: area.rawValue)
        self.severity = severity
        self.summary = LocalRuntimeDiagnosticsRedactor.redact(summary, privacy: privacy)
        self.redactedDetail = LocalRuntimeDiagnosticsRedactor.redact(detail, privacy: privacy)
        self.repairHint = LocalRuntimeDiagnosticsRedactor.redact(repairHint, privacy: .systemOwned)
        self.evidenceIDs = Self.orderedUnique(evidenceIDs.map(LocalRuntimeDiagnosticsRedactor.fingerprint))
        self.localOnly = localOnly
        self.privacy = privacy
        self.generatedAt = Self.normalized(generatedAt, fallback: "unknown")
        self.sourceOwner = Self.normalized(sourceOwner, fallback: "Core/LocalRuntimeOS/Diagnostics")
        self.schemaVersion = schemaVersion
    }

    var requiresAttention: Bool {
        severity == .warning || severity == .critical
    }

    private static func normalizedID(_ value: String) -> String {
        normalized(value, fallback: "diagnostic.unknown")
            .replacingOccurrences(of: #"[^a-zA-Z0-9_.-]+"#, with: "_", options: .regularExpression)
    }

    private static func normalized(_ value: String, fallback: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? fallback : trimmed
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.filter { $0.isEmpty == false })).sorted()
    }
}

struct LocalBackendHealth: Codable, Sendable, Equatable, Hashable {
    let schemaVersion: String
    let generatedAt: String
    let records: [LocalRuntimeDiagnosticRecord]
    let commandEventProjectionReceiptReplayRequired: Bool
    let releaseHealthClaimed: Bool

    init(
        schemaVersion: String = localBackendHealthSchemaVersion,
        generatedAt: String,
        records: [LocalRuntimeDiagnosticRecord],
        commandEventProjectionReceiptReplayRequired: Bool = true,
        releaseHealthClaimed: Bool = false
    ) {
        self.schemaVersion = schemaVersion
        self.generatedAt = generatedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.records = records.sorted {
            if $0.severity != $1.severity {
                return $0.severity > $1.severity
            }
            if $0.area != $1.area {
                return $0.area.rawValue < $1.area.rawValue
            }
            return $0.id < $1.id
        }
        self.commandEventProjectionReceiptReplayRequired = commandEventProjectionReceiptReplayRequired
        self.releaseHealthClaimed = releaseHealthClaimed
    }

    var status: LocalBackendHealthStatus {
        if records.contains(where: { $0.severity == .critical }) {
            return .red
        }
        if records.contains(where: { $0.severity == .warning }) {
            return .yellow
        }
        return .green
    }

    var attentionRecords: [LocalRuntimeDiagnosticRecord] {
        records.filter(\.requiresAttention)
    }

    var redactedLocalSummaryLines: [String] {
        records.map { record in
            "\(record.area.rawValue): \(record.severity.rawValue) - \(record.summary)"
        }
    }
}

enum LocalRuntimeDiagnosticsRedactor {
    static func redact(_ value: String, privacy: RuntimePrivacyClass) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            return "No diagnostic detail provided."
        }
        var output = trimmed
        output = output.replacingOccurrences(
            of: #"[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}"#,
            with: "[redacted-email]",
            options: [.regularExpression, .caseInsensitive]
        )
        output = output.replacingOccurrences(
            of: #"\b(?:\+?1[-.\s]?)?(?:\(?\d{3}\)?[-.\s]?)\d{3}[-.\s]?\d{4}\b"#,
            with: "[redacted-phone]",
            options: .regularExpression
        )
        output = output.replacingOccurrences(
            of: #"\b[A-Fa-f0-9]{8}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{12}\b"#,
            with: "[redacted-uuid]",
            options: .regularExpression
        )
        output = output.replacingOccurrences(
            of: #"\b(goal|step|capture|receipt|event|command|user|proof)[._:-][A-Za-z0-9._:-]{4,}\b"#,
            with: "$1.[redacted-id]",
            options: [.regularExpression, .caseInsensitive]
        )

        if privacy.requiresRedaction, output.contains("Private diagnostic values redacted.") == false {
            output += " Private diagnostic values redacted."
        }

        return output
    }

    static func fingerprint(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            return ""
        }
        return String(LocalRuntimeStorageChecksum.sha256Hex(for: trimmed).prefix(16))
    }

    static func containsLikelyPrivateMaterial(_ value: String) -> Bool {
        value.range(
            of: #"[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}"#,
            options: [.regularExpression, .caseInsensitive]
        ) != nil
    }
}
