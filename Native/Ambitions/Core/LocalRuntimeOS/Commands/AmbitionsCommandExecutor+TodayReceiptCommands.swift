import Foundation

extension AmbitionsCommand {
    var isTodayReceiptMutation: Bool {
        payload.metadata[TodayReceiptDomainEvent.mutationMarkerKey] == "true"
    }
}

extension AmbitionsCommandExecutor {
    func executeTodayReceipt(_ command: AmbitionsCommand) -> AmbitionsCommandExecutionResult {
        guard let event = TodayReceiptDomainEvent.decode(command: command),
              event.receipt.isWellFormed,
              event.receipt.sourceDomain == .today,
              event.receipt.affectedObjects.contains(where: { object in
                  object.id == command.target.stepID || object.id == command.target.recommendationID
              }) else {
            return AmbitionsCommandExecutionResult(
                status: .blocked,
                summary: "Today receipt input is incomplete or does not match its command target.",
                route: .today,
                target: command.target,
                metadata: ["blockedBy": "today_receipt_payload_invalid"]
            )
        }

        return AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: event.kind == .closure
                ? "Today closure receipt committed."
                : "Today recommendation rejection committed.",
            route: .today,
            target: command.target,
            recommendationExplanationIDs: command.relations.recommendationExplanationIDs,
            metadata: [
                "receiptID": event.receipt.id,
                "todayReceiptKind": event.kind.rawValue,
                "todayReceiptMaterialization": "pending_authority_commit",
                "projectionReloadRequired": "true",
            ]
        )
    }

    func materializeTodayReceipt(
        _ command: AmbitionsCommand,
        committedResult: AmbitionsCommandExecutionResult
    ) async -> AmbitionsCommandExecutionResult {
        guard let actionReceiptHistory else {
            return committedResult.mergingMetadata([
                "todayReceiptMaterialization": "needs_recovery",
                "todayReceiptMaterializationError": "action_receipt_history_unavailable",
            ])
        }

        do {
            let envelopes = try await runtimeEvents?.fetchEvents(matching: .commandID(command.id), limit: nil) ?? []
            guard let semantic = try envelopes.compactMap({ envelope -> TodayReceiptDomainEvent? in
                guard case let .domainMutation(record) = envelope.event.payload,
                      case let .todayReceiptRecorded(value) = try record.decodedEvent() else { return nil }
                return value
            }).first else {
                return committedResult.mergingMetadata([
                    "todayReceiptMaterialization": "needs_recovery",
                    "todayReceiptMaterializationError": "semantic_today_receipt_missing",
                ])
            }

            let authorityReceipt = try await (runtimeEvents as? EventStoreSQLite)?.authorityReceipt(commandID: command.id)
            let record = ActionReceiptHistoryRecord(
                receipt: semantic.receipt,
                privacyLevel: semantic.privacyLevel,
                localOnly: semantic.localOnly,
                proofRelevance: semantic.proofRelevance,
                requiresConfirmationBeforeBroaderUse: semantic.requiresConfirmationBeforeBroaderUse,
                runtimeLineage: authorityReceipt.map(RuntimeTrustLineage.init(runtimeCommitReceipt:))
            )
            try await actionReceiptHistory.save([record])
            var materializationMetadata = [
                "todayReceiptMaterialization": "saved_post_authority",
                "todayReceiptHistoryID": record.id,
            ]
            if committedResult.metadata["runtimeMaterializedProjectionCursorIDs"] == nil,
               let projection = try await projectionStore?.fetchRecord(id: .today) {
                materializationMetadata.merge([
                    "runtimeMaterializedProjectionCursorIDs": ProjectionID.today.rawValue,
                    "runtimeMaterializedProjectionCursorSequences": String(projection.cursor.sequence),
                    "runtimeMaterializedProjectionCursorChecksums": projection.cursor.checksum,
                    "runtimeProjectionStoreStatus": "saved",
                ]) { _, current in current }
            }
            return committedResult.mergingMetadata(materializationMetadata)
        } catch {
            return committedResult.mergingMetadata([
                "todayReceiptMaterialization": "needs_recovery",
                "todayReceiptMaterializationError": String(describing: error),
            ])
        }
    }
}
