import Foundation

struct ScheduleInstallRecord: Sendable, Equatable {
    let id: String
    let goalReferenceID: String
    let preview: ScheduleInstallPreview?
    let installReceipt: ScheduleInstallReceipt?
    let rollbackTrace: ScheduleInstallRollbackTrace?
    let trace: ScheduleInstallTrace
    let issues: [ScheduleInstallIssue]

    var canDriveScheduleInstallSegment: Bool {
        issues.isEmpty &&
            preview != nil &&
            installReceipt != nil &&
            rollbackTrace != nil
    }

    var runtimeCoreSegment: RuntimeCoreChainSegment {
        RuntimeCoreChainSegment(
            kind: .scheduleInstall,
            state: canDriveScheduleInstallSegment ? .ready : .blocked,
            sourceRecordIDs: normalizedIDs((installReceipt?.sourceRecordIDs ?? []) + (rollbackTrace?.sourceRecordIDs ?? [])),
            receiptIDs: normalizedIDs((installReceipt?.receiptIDs ?? []) + (rollbackTrace?.receiptIDs ?? [])),
            replayTraceID: canDriveScheduleInstallSegment ? trace.id : nil,
            whatAmbitionsKnowsRoute: canDriveScheduleInstallSegment ? "you://what-ambitions-knows/schedule-install/\(goalReferenceID)" : nil,
            isReversible: rollbackTrace?.reversible == true,
            canDriveVisibleExecution: canDriveScheduleInstallSegment,
            blocksDownstream: canDriveScheduleInstallSegment == false
        )
    }
}
