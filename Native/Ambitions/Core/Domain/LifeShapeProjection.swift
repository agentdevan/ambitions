import Foundation

struct LifeShapeProjection: Sendable, Hashable {
    let generatedAt: Date
    let currentDate: Date
    let selectedLayer: LifeShapeLayer
    let selectedHorizon: LifeShapeHorizon
    let nowBucketID: LifeShapeBucket.ID?
    let todayBuckets: [LifeShapeBucket]
    let horizonRows: [LifeShapeHorizonRow]
    let primaryCaption: String
    let primaryAction: LifeShapePrimaryAction?
    let todayAnchor: LifeShapeTodayAnchor
    let semanticSummary: String

    private init(
        generatedAt: Date,
        currentDate: Date,
        selectedLayer: LifeShapeLayer,
        selectedHorizon: LifeShapeHorizon,
        nowBucketID: LifeShapeBucket.ID?,
        todayBuckets: [LifeShapeBucket],
        horizonRows: [LifeShapeHorizonRow],
        primaryCaption: String,
        primaryAction: LifeShapePrimaryAction?,
        todayAnchor: LifeShapeTodayAnchor,
        semanticSummary: String
    ) {
        self.generatedAt = generatedAt
        self.currentDate = currentDate
        self.selectedLayer = selectedLayer
        self.selectedHorizon = selectedHorizon
        self.nowBucketID = nowBucketID
        self.todayBuckets = todayBuckets
        self.horizonRows = horizonRows
        self.primaryCaption = primaryCaption
        self.primaryAction = primaryAction
        self.todayAnchor = todayAnchor
        self.semanticSummary = semanticSummary
    }

    static func runtimeValidated(
        generatedAt: Date,
        currentDate: Date,
        selectedLayer: LifeShapeLayer,
        selectedHorizon: LifeShapeHorizon,
        nowBucketID: LifeShapeBucket.ID?,
        todayBuckets: [LifeShapeBucket],
        horizonRows: [LifeShapeHorizonRow],
        primaryCaption: String,
        primaryAction: LifeShapePrimaryAction?,
        todayAnchor: LifeShapeTodayAnchor,
        semanticSummary: String
    ) throws -> LifeShapeProjection {
        guard semanticSummary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw LifeShapeContractViolation.missingAccessibilitySummary
        }
        guard todayBuckets.allSatisfy({ $0.derivation.isCompleteForVisibleMark && $0.accessibilitySummary.isEmpty == false }) else {
            throw LifeShapeContractViolation.missingDerivation
        }

        return LifeShapeProjection(
            generatedAt: generatedAt,
            currentDate: currentDate,
            selectedLayer: selectedLayer,
            selectedHorizon: selectedHorizon,
            nowBucketID: nowBucketID,
            todayBuckets: todayBuckets,
            horizonRows: horizonRows,
            primaryCaption: primaryCaption,
            primaryAction: primaryAction,
            todayAnchor: todayAnchor,
            semanticSummary: semanticSummary
        )
    }
}

struct LifeShapeHorizonRow: Identifiable, Sendable, Hashable {
    let id: String
    let horizon: LifeShapeHorizon
    let summary: String
    let bucketIDs: [LifeShapeBucket.ID]
}

struct LifeShapeTodayAnchor: Sendable, Hashable {
    let date: Date
    let bucketID: LifeShapeBucket.ID?
    let accessibilitySummary: String
}
