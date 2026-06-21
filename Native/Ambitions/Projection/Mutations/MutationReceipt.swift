import Foundation

struct MutationReceipt: Equatable, Sendable {
    let receiptID: String
    let saved: Bool
    let inspectionLabel: String
}
