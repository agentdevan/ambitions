import Foundation

struct MutationUndo: Equatable, Sendable {
    let isAvailable: Bool
    let label: String
    let restoresSnapshot: MutationSnapshotReference?
    let sourceReceiptID: String?
    let unavailableReason: String?

    var isTypedContract: Bool {
        label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false &&
            (
                isAvailable &&
                    restoresSnapshot?.isTypedReference == true &&
                    sourceReceiptID?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            ||
                isAvailable == false &&
                    unavailableReason?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            )
    }

    init(
        isAvailable: Bool,
        label: String,
        restoresSnapshot: MutationSnapshotReference,
        sourceReceiptID: String
    ) {
        self.isAvailable = isAvailable
        self.label = label
        self.restoresSnapshot = restoresSnapshot
        self.sourceReceiptID = sourceReceiptID
        self.unavailableReason = nil
    }

    static func unavailable(label: String, reason: String) -> MutationUndo {
        MutationUndo(
            isAvailable: false,
            label: label,
            restoresSnapshot: nil,
            sourceReceiptID: nil,
            unavailableReason: reason
        )
    }

    private init(
        isAvailable: Bool,
        label: String,
        restoresSnapshot: MutationSnapshotReference?,
        sourceReceiptID: String?,
        unavailableReason: String?
    ) {
        self.isAvailable = isAvailable
        self.label = label
        self.restoresSnapshot = restoresSnapshot
        self.sourceReceiptID = sourceReceiptID
        self.unavailableReason = unavailableReason
    }
}
