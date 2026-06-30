import Foundation

struct PerformanceBudgetMeasurement: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let scope: AFEPQueryBudgetScope
    let operationID: String
    let observedReads: Int
    let measuredAt: String

    init(
        scope: AFEPQueryBudgetScope,
        operationID: String,
        observedReads: Int,
        measuredAt: String
    ) {
        self.scope = scope
        self.operationID = operationID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.observedReads = max(0, observedReads)
        self.measuredAt = measuredAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.id = "performance.measurement.\(scope.rawValue).\(LocalRuntimeDiagnosticsRedactor.fingerprint(self.operationID))"
    }
}

struct PerformanceBudgetLedgerEntry: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let scope: AFEPQueryBudgetScope
    let operationID: String
    let observedReads: Int?
    let maximumReads: Int
    let measurementEvidenceState: AFEPMeasurementEvidenceState
    let severity: LocalRuntimeDiagnosticSeverity
    let summary: String
    let measuredAt: String?

    var isOverBudget: Bool {
        guard let observedReads else {
            return false
        }
        return observedReads > maximumReads
    }
}

struct PerformanceBudgetLedger: Codable, Sendable, Equatable, Hashable {
    let schemaVersion: String
    let generatedAt: String
    let entries: [PerformanceBudgetLedgerEntry]

    init(
        schemaVersion: String = localBackendHealthSchemaVersion,
        generatedAt: String,
        budgets: [AFEPQueryBudgetDescriptor] = AFEPQueryBudgetCatalog.all,
        measurements: [PerformanceBudgetMeasurement]
    ) {
        let measurementsByScope = Dictionary(grouping: measurements, by: \.scope)
        self.schemaVersion = schemaVersion
        self.generatedAt = generatedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.entries = budgets.flatMap { budget -> [PerformanceBudgetLedgerEntry] in
            let scopedMeasurements = measurementsByScope[budget.scope] ?? []
            if scopedMeasurements.isEmpty {
                return [
                    PerformanceBudgetLedgerEntry(
                        id: "performance.unmeasured.\(budget.scope.rawValue)",
                        scope: budget.scope,
                        operationID: "unmeasured",
                        observedReads: nil,
                        maximumReads: budget.maximumReads,
                        measurementEvidenceState: budget.measurementEvidenceState,
                        severity: .notice,
                        summary: "No current measurement supplied for \(budget.scope.rawValue); budget remains contract-only.",
                        measuredAt: nil
                    )
                ]
            }

            return scopedMeasurements.sorted { $0.id < $1.id }.map { measurement in
                let overBudget = measurement.observedReads > budget.maximumReads
                return PerformanceBudgetLedgerEntry(
                    id: "performance.\(budget.scope.rawValue).\(LocalRuntimeDiagnosticsRedactor.fingerprint(measurement.operationID))",
                    scope: budget.scope,
                    operationID: measurement.operationID,
                    observedReads: measurement.observedReads,
                    maximumReads: budget.maximumReads,
                    measurementEvidenceState: budget.measurementEvidenceState,
                    severity: overBudget ? .warning : .healthy,
                    summary: overBudget
                        ? "\(budget.scope.rawValue) used \(measurement.observedReads) reads over budget \(budget.maximumReads)."
                        : "\(budget.scope.rawValue) used \(measurement.observedReads) reads within budget \(budget.maximumReads).",
                    measuredAt: measurement.measuredAt
                )
            }
        }
        .sorted { $0.id < $1.id }
    }

    var overBudgetEntries: [PerformanceBudgetLedgerEntry] {
        entries.filter(\.isOverBudget)
    }

    func diagnosticRecords(generatedAt: String? = nil) -> [LocalRuntimeDiagnosticRecord] {
        entries.map { entry in
            LocalRuntimeDiagnosticRecord(
                id: entry.id,
                area: .performance,
                componentID: "PerformanceBudgetLedger",
                severity: entry.severity,
                summary: entry.summary,
                detail: "Scope \(entry.scope.rawValue), operation \(entry.operationID), observed reads \(entry.observedReads.map(String.init) ?? "unmeasured"), maximum reads \(entry.maximumReads), evidence \(entry.measurementEvidenceState.rawValue).",
                repairHint: entry.isOverBudget
                    ? "Materialize projections or tighten repository reads before widening runtime health claims."
                    : "Keep measuring this path before upgrading performance proof.",
                evidenceIDs: [entry.id, entry.operationID],
                generatedAt: generatedAt ?? self.generatedAt
            )
        }
        .sorted { $0.id < $1.id }
    }
}
