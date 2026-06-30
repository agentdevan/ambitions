import Foundation

struct CaptureRouteGraphServices: Sendable {
    let intakeJournal: CaptureIntakeJournal
    let draftStore: CaptureDraftStore
    let routeResolver: CaptureRouteResolver
    let attachmentVault: CaptureAttachmentVault
    let promotionTransaction: CapturePromotionTransaction
    let correctionLedger: CaptureCorrectionLedger
    let directLookupIndex: CaptureDirectLookupIndex

    init(
        intakeJournal: CaptureIntakeJournal = CaptureIntakeJournal(),
        draftStore: CaptureDraftStore = CaptureDraftStore(),
        routeResolver: CaptureRouteResolver = CaptureRouteResolver(),
        attachmentVault: CaptureAttachmentVault = CaptureAttachmentVault(),
        promotionTransaction: CapturePromotionTransaction = CapturePromotionTransaction(),
        correctionLedger: CaptureCorrectionLedger = CaptureCorrectionLedger(),
        directLookupIndex: CaptureDirectLookupIndex = CaptureDirectLookupIndex()
    ) {
        self.intakeJournal = intakeJournal
        self.draftStore = draftStore
        self.routeResolver = routeResolver
        self.attachmentVault = attachmentVault
        self.promotionTransaction = promotionTransaction
        self.correctionLedger = correctionLedger
        self.directLookupIndex = directLookupIndex
    }

    static func inMemory() -> CaptureRouteGraphServices {
        CaptureRouteGraphServices()
    }

    static func live(rootDirectory: URL = CaptureRouteGraphJSONFileStore<[CaptureIntakeJournalRecord]>.defaultRootDirectory()) -> CaptureRouteGraphServices {
        fileBacked(rootDirectory: rootDirectory)
    }

    static func fileBacked(rootDirectory: URL) -> CaptureRouteGraphServices {
        CaptureRouteGraphServices(
            intakeJournal: CaptureIntakeJournal.fileBacked(rootDirectory: rootDirectory),
            draftStore: CaptureDraftStore.fileBacked(rootDirectory: rootDirectory),
            routeResolver: CaptureRouteResolver(),
            attachmentVault: CaptureAttachmentVault.fileBacked(rootDirectory: rootDirectory),
            promotionTransaction: CapturePromotionTransaction.fileBacked(rootDirectory: rootDirectory),
            correctionLedger: CaptureCorrectionLedger.fileBacked(rootDirectory: rootDirectory),
            directLookupIndex: CaptureDirectLookupIndex.fileBacked(rootDirectory: rootDirectory)
        )
    }
}
