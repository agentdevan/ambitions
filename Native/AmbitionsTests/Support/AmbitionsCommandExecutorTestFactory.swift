import Foundation
@testable import Ambitions

extension AmbitionsCommandExecutor {
    static func test(
        captureService: (any CaptureServicing)? = nil,
        eventLedger: (any EventLedgerRepository)? = nil,
        actionReceiptHistory: (any ActionReceiptHistoryRepository)? = nil,
        commandExecutionRecords: (any AmbitionsCommandExecutionRecordRepository)? = nil,
        runtimeEvents: (any RuntimeEventStore)? = InMemoryRuntimeEventStore(),
        projectionStore: ProjectionStoreSQLite? = nil,
        searchIndex: FTSIndex? = nil,
        commandJournal: any CommandJournal = InMemoryCommandJournal(),
        runtimeTransactionIdempotencyStore: RuntimeIdempotencyStore = RuntimeIdempotencyStore(),
        smartAttachmentService: (any SmartAttachmentRouting)? = DefaultSmartAttachmentService(),
        validator: AmbitionsCommandValidator = AmbitionsCommandValidator(),
        runtimeValidator: RuntimeValidator? = nil,
        compiler: CommandCompiler? = nil,
        receiptFactory: CommandReceiptFactory = CommandReceiptFactory(),
        scheduleStoreFileURL: URL? = nil,
        todayActionMaterializer: (any TodayGoalStepActionMaterializing)? = nil,
        timeRitualActionMaterializer: (any TimeRitualActionMaterializing)? = nil
    ) -> AmbitionsCommandExecutor {
        AmbitionsCommandExecutor(
            captureService: captureService,
            eventLedger: eventLedger,
            actionReceiptHistory: actionReceiptHistory,
            commandExecutionRecords: commandExecutionRecords,
            runtimeEvents: runtimeEvents,
            projectionStore: projectionStore,
            searchIndex: searchIndex,
            commandJournal: commandJournal,
            runtimeTransactionIdempotencyStore: runtimeTransactionIdempotencyStore,
            smartAttachmentService: smartAttachmentService,
            validator: validator,
            runtimeValidator: runtimeValidator,
            compiler: compiler,
            receiptFactory: receiptFactory,
            scheduleStoreFileURL: scheduleStoreFileURL,
            todayActionMaterializer: todayActionMaterializer,
            timeRitualActionMaterializer: timeRitualActionMaterializer
        )
    }
}
