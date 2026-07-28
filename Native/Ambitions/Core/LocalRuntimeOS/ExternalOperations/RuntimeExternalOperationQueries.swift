import AmbitionsRuntimeSQLite
import Foundation

struct RuntimeExternalOperationQueryCursor: RawRepresentable, Codable, Sendable, Equatable, Hashable {
    let rawValue: String
    init?(rawValue: String) {
        guard let normalized = RuntimeIdentityNormalizer.normalize(rawValue) else { return nil }
        self.rawValue = normalized
    }
}

struct RuntimeExternalOperationSummary: Sendable, Equatable {
    let operationID: RuntimeExternalOperationID
    let kind: RuntimeExternalEffectKind
    let workflowStatus: RuntimeExternalWorkflowStatus
    let effectDisposition: RuntimeExternalEffectDisposition
    let attemptCount: Int
    let nextAttemptAt: Date?
    let updatedAt: Date
    let blocksCompensation: Bool
}

extension CanonicalRuntimeStore {
    func externalOperations(
        statuses: Set<RuntimeExternalWorkflowStatus>,
        after cursor: RuntimeExternalOperationQueryCursor?,
        limit: Int
    ) async throws -> CanonicalRuntimePage<RuntimeExternalOperationSummary, RuntimeExternalOperationQueryCursor> {
        guard statuses.isEmpty == false,
              limit > 0,
              limit <= RuntimeExternalOperationLimits.maximumPageSize else {
            throw RuntimeCanonicalExternalOperationError.firstRowExceedsBound
        }
        return try await withCanonicalReadTransaction { database in
            try CanonicalRuntimeExternalOperationStore.requireSchema(database)
            let orderedStatuses = statuses.map(\.rawValue).sorted()
            let placeholders = Array(repeating: "?", count: orderedStatuses.count).joined(separator: ",")
            let cursorClause = cursor == nil ? "" : "AND s.operation_id > ?"
            var bindings = orderedStatuses.map(SQLiteBinding.text)
            if let cursor { bindings.append(.text(cursor.rawValue)) }
            bindings.append(.integer(Int64(limit + 1)))
            let rows = try database.query(
                """
                SELECT s.operation_id
                FROM runtime_external_operation_current AS s
                WHERE s.workflow_status IN (\(placeholders)) \(cursorClause)
                ORDER BY s.operation_id LIMIT ?
                """,
                bindings: bindings,
                maximumDecodedBytes: 64_000
            )
            guard rows.count <= limit + 1 else {
                throw RuntimeCanonicalExternalOperationError.firstRowExceedsBound
            }
            var graphBudget = RuntimeExternalOperationDecodedByteBudget(
                maximumBytes: RuntimeExternalOperationLimits.maximumPageGraphBytes
            )
            let authenticated = try rows.map { row -> RuntimeExternalOperationSummary in
                try Task.checkCancellation()
                guard case let .text(rawID)? = row.value(named: "operation_id"),
                      let operationID = RuntimeExternalOperationID(rawValue: rawID),
                      let graph = try RuntimeExternalOperationGraphAuthority.loadAuthenticated(
                          operationID: operationID,
                          budget: &graphBudget,
                          database: database
                      ),
                      statuses.contains(graph.current.workflowStatus) else {
                    throw RuntimeCanonicalExternalOperationError.corruptAuthority
                }
                return RuntimeExternalOperationSummary(
                    operationID: operationID,
                    kind: graph.creation.kind,
                    workflowStatus: graph.current.workflowStatus,
                    effectDisposition: graph.current.effectDisposition,
                    attemptCount: graph.current.attemptCount,
                    nextAttemptAt: graph.current.nextAttemptAt,
                    updatedAt: graph.current.updatedAt,
                    blocksCompensation: graph.current.blocksCompensation
                )
            }
            let nextCursor: RuntimeExternalOperationQueryCursor?
            let values = Array(authenticated.prefix(limit))
            if authenticated.count > limit, let last = values.last {
                nextCursor = RuntimeExternalOperationQueryCursor(rawValue: last.operationID.rawValue)
            } else {
                nextCursor = nil
            }
            return CanonicalRuntimePage(items: values, nextCursor: nextCursor)
        }
    }
}
