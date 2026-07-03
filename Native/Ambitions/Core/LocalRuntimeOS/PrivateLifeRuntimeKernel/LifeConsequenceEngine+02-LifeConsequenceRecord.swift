import Foundation

struct LifeConsequenceRecord: Sendable, Equatable {
    let id: String
    let goalReferenceID: String
    let receipts: [LifeConsequenceReceipt]
    let treatyOutputs: [LifeConsequenceTreatyOutput]
    let trace: LifeConsequenceTrace
    let issues: [LifeConsequenceIssue]
    let highestSeverity: LifeConsequenceSeverity

    var canDriveConsequenceReflowSegment: Bool {
        issues.isEmpty &&
            trace.localOnly &&
            highestSeverity.blocksDownstream == false &&
            materialReceiptCoverageComplete
    }

    var runtimeCoreSegment: RuntimeCoreChainSegment {
        RuntimeCoreChainSegment(
            kind: .consequenceReflow,
            state: canDriveConsequenceReflowSegment ? .ready : .blocked,
            sourceRecordIDs: normalizedIDs(receipts.flatMap(\.sourceRecordIDs) + treatyOutputs.flatMap(\.sourceRecordIDs)),
            receiptIDs: normalizedIDs(receipts.flatMap(\.receiptIDs) + treatyOutputs.flatMap(\.receiptIDs)),
            replayTraceID: canDriveConsequenceReflowSegment ? trace.id : nil,
            whatAmbitionsKnowsRoute: canDriveConsequenceReflowSegment ? "you://what-ambitions-knows/life-consequence/\(goalReferenceID)" : nil,
            isReversible: receipts.allSatisfy(\.reversible),
            canDriveVisibleExecution: canDriveConsequenceReflowSegment,
            blocksDownstream: canDriveConsequenceReflowSegment == false
        )
    }

    var materialReceiptCoverageComplete: Bool {
        highestSeverity == .silent || receipts.isEmpty == false
    }
}
