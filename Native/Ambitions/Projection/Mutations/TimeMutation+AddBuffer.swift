import Foundation

extension TimeMutation {
    static func bufferBucket(
        from bucket: LifeShapeBucket,
        command: AmbitionsCommand
    ) throws -> LifeShapeBucket {
        let accessibilitySummary = "Buffer added. Today recomputed the current window and next fixed-point context."
        return try LifeShapeBucketBuilder.makeBucket(
            id: bucket.id,
            start: bucket.start,
            end: bucket.end,
            horizon: bucket.horizon,
            layer: .buffer,
            reading: LifeShapeReading(
                horizon: bucket.horizon,
                kind: .buffer,
                title: "Buffer added",
                summary: "Room was added around this fixed point.",
                capacityStatement: "Add room",
                sourceDetail: "Changed from a local Time correction.",
                fallbackState: bucket.reading.fallbackState,
                accessibilitySummary: accessibilitySummary
            ),
            fixedPoints: bucket.fixedPoints,
            protectedBoundary: bucket.protectedBoundary,
            recommendedStepID: nil,
            primaryAction: nil,
            correctionOptions: bucket.correctionOptions,
            derivation: derivation(from: bucket, command: command, rule: "lifeshape.time-mutation.add-buffer"),
            confidence: LifeShapeConfidence(level: .grounded, explanation: "Buffer was added from an explicit local Time action."),
            accessibilitySummary: accessibilitySummary
        )
    }
}
