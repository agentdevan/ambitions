import Foundation

enum MutationReceiptState: String, Equatable, Sendable {
    case saved
    case unavailable
}

struct MutationReceipt: Equatable, Sendable {
    let receiptID: String
    let saved: Bool
    let inspectionLabel: String
    let state: MutationReceiptState
    let proofArtifactID: String?
    let action: MutationActionReference?
    let fallbackReason: String?

    var isTypedSaved: Bool {
        state == .saved &&
            saved &&
            receiptID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false &&
            inspectionLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false &&
            proofArtifactID?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false &&
            action?.isTypedReference == true
    }

    var isTypedUnavailableFallback: Bool {
        state == .unavailable &&
            saved == false &&
            inspectionLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false &&
            action?.isTypedReference == true &&
            fallbackReason?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    init(
        receiptID: String,
        saved: Bool,
        inspectionLabel: String,
        proofArtifactID: String,
        action: MutationActionReference
    ) {
        self.receiptID = receiptID
        self.saved = saved
        self.inspectionLabel = inspectionLabel
        self.state = saved ? .saved : .unavailable
        self.proofArtifactID = proofArtifactID
        self.action = action
        self.fallbackReason = saved ? nil : "Receipt was not saved."
    }

    static func unavailable(
        inspectionLabel: String,
        action: MutationActionReference?,
        fallbackReason: String
    ) -> MutationReceipt {
        MutationReceipt(
            receiptID: "",
            saved: false,
            inspectionLabel: inspectionLabel,
            state: .unavailable,
            proofArtifactID: nil,
            action: action,
            fallbackReason: fallbackReason
        )
    }

    private init(
        receiptID: String,
        saved: Bool,
        inspectionLabel: String,
        state: MutationReceiptState,
        proofArtifactID: String?,
        action: MutationActionReference?,
        fallbackReason: String?
    ) {
        self.receiptID = receiptID
        self.saved = saved
        self.inspectionLabel = inspectionLabel
        self.state = state
        self.proofArtifactID = proofArtifactID
        self.action = action
        self.fallbackReason = fallbackReason
    }
}
