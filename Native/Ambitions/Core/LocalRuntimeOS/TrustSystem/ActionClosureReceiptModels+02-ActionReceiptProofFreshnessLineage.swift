import Foundation

struct ActionReceiptProofFreshnessLineage: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let receiptID: String
    let sourceDomain: ActionReceiptSourceDomain
    let sourceObjectID: String?
    let sourceObjectKind: LifeGraphObjectKind?
    let lineageObjectIDs: [String]
    let proofReferenceIDs: [String]
    let sourceFreshnessLabel: String
    let privacyReceiptLabel: String
    let sourceEvidenceLabel: String
    let nonClaimLabel: String
    let canUseAsCurrentLocalSource: Bool
    let redactsPrivateDetail: Bool
    let requiresFreshnessReview: Bool
    let localOnly: Bool
    let publicClaimAllowed: Bool
}
