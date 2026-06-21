import Foundation

struct MotionSemanticModel: Equatable, Sendable {
    let behaviorName: String
    let crownSummary: String
    let sourceSummary: String
    let proofSummary: String
    let receiptSummary: String
    let reductionSummary: String

    init(
        projection: MotionCurrentProjection,
        reductionPolicy: StageMotionReductionPolicy
    ) {
        self.behaviorName = UserFacingLanguage.Object.stageMotion
        self.crownSummary = projection.crown.summary
        self.sourceSummary = projection.field.source
        self.proofSummary = projection.field.proof
        self.receiptSummary = projection.field.receipt
        self.reductionSummary = reductionPolicy.rhythmSpacingDescription
    }

    var provesBehaviorNotDestination: Bool {
        behaviorName == UserFacingLanguage.Object.stageMotion &&
            sourceSummary.isEmpty == false &&
            proofSummary.isEmpty == false &&
            receiptSummary.isEmpty == false &&
            reductionSummary.isEmpty == false
    }
}
