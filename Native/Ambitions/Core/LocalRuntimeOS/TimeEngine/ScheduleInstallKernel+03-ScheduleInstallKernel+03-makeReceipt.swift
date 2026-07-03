import Foundation

extension ScheduleInstallKernel {

    func makeReceipt(
        input: ScheduleInstallInput,
        preview: ScheduleInstallPreview?,
        selectedWindow: ScheduleInstallTimeWindow?,
        rollbackTrace: ScheduleInstallRollbackTrace?
    ) -> ScheduleInstallReceipt? {
        guard
            let preview,
            let decision = input.decision,
            let selectedWindow,
            let decisionReceiptID = decision.decisionReceiptID,
            let rollbackTrace
        else {
            return nil
        }
        let receiptID = stableIdentifier(
            prefix: "schedule-install.receipt",
            components: [
                input.elasticityRecord.goalReferenceID,
                preview.id,
                selectedWindow.id,
                decisionReceiptID
            ]
        )
        let sourceRecordIDs = normalizedIDs(preview.sourceRecordIDs + selectedWindow.sourceRecordIDs + decision.sourceRecordIDs + rollbackTrace.sourceRecordIDs)
        let receiptIDs = normalizedIDs(preview.receiptIDs + selectedWindow.receiptIDs + decision.receiptIDs + [decisionReceiptID, receiptID])
        return ScheduleInstallReceipt(
            id: receiptID,
            previewID: preview.id,
            selectedVariantID: preview.selectedVariantID,
            selectedWindowID: selectedWindow.id,
            decisionReceiptID: decisionReceiptID,
            sourceRecordIDs: sourceRecordIDs,
            receiptIDs: receiptIDs,
            replayTraceID: decision.replayTraceID ?? selectedWindow.replayTraceID ?? rollbackTrace.replayTraceID,
            whatAmbitionsKnowsRoute: decision.whatAmbitionsKnowsRoute ?? selectedWindow.whatAmbitionsKnowsRoute ?? rollbackTrace.whatAmbitionsKnowsRoute,
            rollbackTraceID: rollbackTrace.id,
            createdAt: input.evaluatedAt,
            reversible: true,
            localOnly: true
        )
    }


    func makeRollbackTrace(
        input: ScheduleInstallInput,
        preview: ScheduleInstallPreview?
    ) -> ScheduleInstallRollbackTrace? {
        guard let preview, let rollbackPlan = input.rollbackPlan else {
            return nil
        }
        let installReceiptID = stableIdentifier(
            prefix: "schedule-install.receipt",
            components: [
                input.elasticityRecord.goalReferenceID,
                preview.id,
                input.decision?.selectedWindowID ?? "missing-window",
                input.decision?.decisionReceiptID ?? "missing-decision-receipt"
            ]
        )
        return ScheduleInstallRollbackTrace(
            id: stableIdentifier(
                prefix: "schedule-install.rollback",
                components: [
                    preview.id,
                    rollbackPlan.id,
                    rollbackPlan.previousScheduleSnapshotID
                ]
            ),
            previewID: preview.id,
            installReceiptID: installReceiptID,
            previousScheduleSnapshotID: rollbackPlan.previousScheduleSnapshotID,
            rollbackReceiptID: rollbackPlan.rollbackReceiptID,
            sourceRecordIDs: rollbackPlan.sourceRecordIDs,
            receiptIDs: normalizedIDs(rollbackPlan.receiptIDs + [rollbackPlan.rollbackReceiptID]),
            replayTraceID: rollbackPlan.replayTraceID ?? "missing-ReplayTrace",
            whatAmbitionsKnowsRoute: rollbackPlan.whatAmbitionsKnowsRoute ?? "you://what-ambitions-knows/schedule-install/\(input.elasticityRecord.goalReferenceID)",
            reversible: rollbackPlan.reversible,
            localOnly: rollbackPlan.localOnly
        )
    }


    func makeRecord(
        input: ScheduleInstallInput,
        preview: ScheduleInstallPreview?,
        installReceipt: ScheduleInstallReceipt?,
        rollbackTrace: ScheduleInstallRollbackTrace?,
        issues: Set<ScheduleInstallIssue>
    ) -> ScheduleInstallRecord {
        let sortedIssues = sortedIssues(issues)
        let trace = makeTrace(input: input, preview: preview, installReceipt: installReceipt, rollbackTrace: rollbackTrace, issues: sortedIssues)
        return ScheduleInstallRecord(
            id: stableIdentifier(
                prefix: "schedule-install.record",
                components: [
                    input.elasticityRecord.goalReferenceID,
                    preview?.id ?? "missing-preview",
                    installReceipt?.id ?? "missing-install-receipt",
                    rollbackTrace?.id ?? "missing-rollback",
                    sortedIssues.map(\.rawValue).joined(separator: ",")
                ]
            ),
            goalReferenceID: input.elasticityRecord.goalReferenceID,
            preview: preview,
            installReceipt: installReceipt,
            rollbackTrace: rollbackTrace,
            trace: trace,
            issues: sortedIssues
        )
    }


    func makeTrace(
        input: ScheduleInstallInput,
        preview: ScheduleInstallPreview?,
        installReceipt: ScheduleInstallReceipt?,
        rollbackTrace: ScheduleInstallRollbackTrace?,
        issues: [ScheduleInstallIssue]
    ) -> ScheduleInstallTrace {
        let issueIDs = issues.map(\.rawValue)
        let replayTraceIDs = normalizedIDs(
            (preview?.replayTraceIDs ?? []) +
                [installReceipt?.replayTraceID, rollbackTrace?.replayTraceID].compactMap { $0 }
        )
        let fingerprint = stableIdentifier(
            prefix: "schedule-install.fingerprint",
            components: [
                preview?.id ?? "missing-preview",
                installReceipt?.id ?? "missing-install-receipt",
                rollbackTrace?.id ?? "missing-rollback",
                replayTraceIDs.joined(separator: ","),
                issueIDs.joined(separator: ",")
            ]
        )
        return ScheduleInstallTrace(
            id: stableIdentifier(
                prefix: "schedule-install.trace",
                components: [
                    input.elasticityRecord.goalReferenceID,
                    fingerprint
                ]
            ),
            goalReferenceID: input.elasticityRecord.goalReferenceID,
            previewID: preview?.id,
            installReceiptID: installReceipt?.id,
            rollbackTraceID: rollbackTrace?.id,
            issueIDs: issueIDs,
            replayTraceIDs: replayTraceIDs,
            fingerprint: fingerprint,
            localOnly: input.localOnly
        )
    }


    func sortedIssues(_ issues: Set<ScheduleInstallIssue>) -> [ScheduleInstallIssue] {
        issues.sorted { $0.rawValue < $1.rawValue }
    }


    func stableIdentifier(prefix: String, components: [String]) -> String {
        ([prefix] + components.map { normalizedToken($0) })
            .filter { $0.isEmpty == false }
            .joined(separator: ".")
    }


    func normalizedToken(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.isEmpty == false }
            .joined(separator: "-")
    }


    func normalizedIDs(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}
