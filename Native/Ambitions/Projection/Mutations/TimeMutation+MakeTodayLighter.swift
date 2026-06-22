import Foundation

extension TimeMutation {
    static func lighterPressureBucket(
        from bucket: LifeShapeBucket,
        command: AmbitionsCommand
    ) throws -> LifeShapeBucket {
        let accessibilitySummary = "Pressure lightened. Today recomputed Start here and Later Today."
        return try LifeShapeBucketBuilder.makeBucket(
            id: bucket.id,
            start: bucket.start,
            end: bucket.end,
            horizon: bucket.horizon,
            layer: .pressure,
            reading: LifeShapeReading(
                horizon: bucket.horizon,
                kind: .pressure,
                title: "Light",
                summary: "One ask was narrowed so Today has more room.",
                capacityStatement: "Light",
                sourceDetail: "Changed from a local Time correction.",
                fallbackState: bucket.reading.fallbackState,
                accessibilitySummary: accessibilitySummary
            ),
            fixedPoints: bucket.fixedPoints,
            protectedBoundary: bucket.protectedBoundary,
            recommendedStepID: nil,
            primaryAction: nil,
            correctionOptions: bucket.correctionOptions,
            derivation: derivation(from: bucket, command: command, rule: "lifeshape.time-mutation.make-today-lighter"),
            confidence: LifeShapeConfidence(level: .grounded, explanation: "Pressure was lightened from an explicit local Time action."),
            accessibilitySummary: accessibilitySummary
        )
    }
}
