import Foundation

enum LifeShapeBucketBuilder {
    static func makeBucket(
        id: String,
        start: Date,
        end: Date,
        horizon: LifeShapeHorizon,
        layer: LifeShapeLayer,
        reading: LifeShapeReading,
        fixedPoints: [FixedPoint] = [],
        protectedBoundary: ProtectedBoundary? = nil,
        recommendedStepID: String? = nil,
        primaryAction: LifeShapePrimaryAction? = nil,
        correctionOptions: [LifeShapeCorrection] = [],
        derivation: LifeShapeDerivation,
        confidence: LifeShapeConfidence,
        accessibilitySummary: String
    ) throws -> LifeShapeBucket {
        try LifeShapeBucket.runtimeValidated(
            id: id,
            start: start,
            end: end,
            horizon: horizon,
            layer: layer,
            reading: reading,
            fixedPoints: fixedPoints,
            protectedBoundary: protectedBoundary,
            recommendedStepID: recommendedStepID,
            primaryAction: primaryAction,
            correctionOptions: correctionOptions,
            derivation: derivation,
            confidence: confidence,
            accessibilitySummary: accessibilitySummary
        )
    }

    static func makeProjection(
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
        try LifeShapeProjection.runtimeValidated(
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
