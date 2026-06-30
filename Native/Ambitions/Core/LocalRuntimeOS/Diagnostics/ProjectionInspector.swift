import Foundation

struct ProjectionInspector: Sendable, Equatable, Hashable {
    func inspect(
        definitions: [ProjectionDefinition] = ProjectionDefinition.allCanonical,
        storedRecords: [StoredProjectionRecord],
        generatedAt: String
    ) -> [LocalRuntimeDiagnosticRecord] {
        let definitionsByID = Dictionary(grouping: definitions, by: \.id)
        let storedByID = Dictionary(grouping: storedRecords, by: \.id)
        var diagnostics: [LocalRuntimeDiagnosticRecord] = [
            LocalRuntimeDiagnosticRecord(
                id: "projection.summary",
                area: .projection,
                componentID: "ProjectionInspector",
                severity: .healthy,
                summary: "Inspected \(definitions.count) projection definitions and \(storedRecords.count) stored projection records.",
                detail: "Projection diagnostics compare canonical definitions, stored payload checksums, privacy-filtered external outputs, and materialized cursors.",
                repairHint: "Rebuild projections from RuntimeEventStore when stored records are missing or checksums drift.",
                generatedAt: generatedAt
            )
        ]

        for projectionID in ProjectionID.allCases.sorted() {
            if let definitions = definitionsByID[projectionID], definitions.count > 1 {
                diagnostics.append(LocalRuntimeDiagnosticRecord(
                    id: "projection.definition_duplicate.\(projectionID.rawValue)",
                    area: .projection,
                    componentID: "ProjectionInspector",
                    severity: .critical,
                    summary: "Canonical projection definition is duplicated.",
                    detail: "Projection \(projectionID.rawValue) has \(definitions.count) definitions.",
                    repairHint: "Collapse projection definitions to one canonical owner before materializing read models.",
                    evidenceIDs: [projectionID.rawValue],
                    generatedAt: generatedAt
                ))
            }

            guard let definition = definitionsByID[projectionID]?.first else {
                diagnostics.append(LocalRuntimeDiagnosticRecord(
                    id: "projection.definition_missing.\(projectionID.rawValue)",
                    area: .projection,
                    componentID: "ProjectionInspector",
                    severity: .critical,
                    summary: "Canonical projection definition is missing.",
                    detail: "Projection \(projectionID.rawValue) has no canonical definition.",
                    repairHint: "Restore the projection definition before claiming materialized read-model coverage.",
                    evidenceIDs: [projectionID.rawValue],
                    generatedAt: generatedAt
                ))
                continue
            }

            if let records = storedByID[projectionID], records.count > 1 {
                diagnostics.append(LocalRuntimeDiagnosticRecord(
                    id: "projection.stored_duplicate.\(projectionID.rawValue)",
                    area: .projection,
                    componentID: "ProjectionInspector",
                    severity: .critical,
                    summary: "Stored projection record is duplicated.",
                    detail: "Projection \(projectionID.rawValue) has \(records.count) stored records.",
                    repairHint: "Discard duplicate stored projection rows and rebuild from a single event cursor.",
                    evidenceIDs: records.map { $0.cursor.eventCursor?.eventID ?? projectionID.rawValue },
                    generatedAt: generatedAt
                ))
            }

            if storedByID[projectionID]?.isEmpty ?? true {
                diagnostics.append(LocalRuntimeDiagnosticRecord(
                    id: "projection.stored_missing.\(projectionID.rawValue)",
                    area: .projection,
                    componentID: "ProjectionInspector",
                    severity: .warning,
                    summary: "Stored projection record is missing.",
                    detail: "Projection \(projectionID.rawValue) is defined as \(definition.family.rawValue) but has no stored materialized record.",
                    repairHint: "Run the ProjectionMaterializer from a valid runtime event cursor.",
                    evidenceIDs: [projectionID.rawValue],
                    generatedAt: generatedAt
                ))
            }

            if [.widget, .appIntent].contains(projectionID), definition.materializationMode != .privacyFiltered {
                diagnostics.append(LocalRuntimeDiagnosticRecord(
                    id: "projection.external_privacy.\(projectionID.rawValue)",
                    area: .projection,
                    componentID: "ProjectionInspector",
                    severity: .critical,
                    summary: "External projection is not privacy-filtered.",
                    detail: "Projection \(projectionID.rawValue) is external-facing and must be privacy filtered.",
                    repairHint: "Switch external projection materialization to privacy-filtered mode before writing snapshots.",
                    evidenceIDs: [projectionID.rawValue],
                    generatedAt: generatedAt
                ))
            }
        }

        for record in storedRecords.sorted(by: { $0.id.rawValue < $1.id.rawValue }) {
            let expectedChecksum = LocalRuntimeStorageChecksum.sha256Hex(for: record.payloadData)
            if expectedChecksum != record.payloadChecksum {
                diagnostics.append(LocalRuntimeDiagnosticRecord(
                    id: "projection.checksum.\(record.id.rawValue)",
                    area: .projection,
                    componentID: "ProjectionInspector",
                    severity: .critical,
                    summary: "Stored projection payload checksum is invalid.",
                    detail: "Projection \(record.id.rawValue) payload checksum does not match stored payload bytes.",
                    repairHint: "Discard the stored projection record and rebuild it from the event journal.",
                    evidenceIDs: [record.id.rawValue, record.cursor.eventCursor?.eventID].compactMap { $0 },
                    generatedAt: generatedAt
                ))
            }
        }

        return diagnostics.sorted { $0.id < $1.id }
    }
}
