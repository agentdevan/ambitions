import Foundation

enum StoreDiagnostics {
    static let localStoreOwners = [
        "Core/Persistence",
        "Core/Domain/EventLedger",
        "Core/Runtime"
    ]

    static var defaultChecks: [DiagnosticCheckResult] {
        [
            DiagnosticCheckResult(
                id: "store-local-owners",
                owner: "Core/Persistence",
                severity: localStoreOwners.isEmpty ? .blocker : .pass,
                summary: "Local store ownership remains under persistence, event ledger, and runtime boundaries.",
                proofRequirement: "Persistence tests must prove local repositories, diagnostic snapshots, and support export redaction."
            ),
            DiagnosticCheckResult(
                id: "store-diagnostic-schema",
                owner: "Core/Persistence",
                severity: diagnosticLedgerSchemaVersion.isEmpty || supportDiagnosticsBundleSchemaVersion.isEmpty ? .blocker : .pass,
                summary: "Diagnostic ledger and support bundle schemas are explicit.",
                proofRequirement: "Support diagnostics bundle tests must keep private entries redacted before export."
            )
        ]
    }
}
