import Foundation

struct LifeShapeEngineInput: Sendable, Hashable {
    let generatedAt: Date
    let currentDate: Date
    let horizon: LifeShapeHorizon
    let open: OpenCapacityInput
    let protected: ProtectionEngineInput

    init(
        generatedAt: Date,
        currentDate: Date,
        horizon: LifeShapeHorizon = .day,
        open: OpenCapacityInput,
        protected: ProtectionEngineInput
    ) {
        self.generatedAt = generatedAt
        self.currentDate = currentDate
        self.horizon = horizon
        self.open = open
        self.protected = protected
    }
}

struct LifeShapeEngine: Sendable {
    let openCapacityEngine: OpenCapacityEngine
    let protectionEngine: ProtectionEngine
    let bucketizer: LifeShapeBucketizer

    init(
        openCapacityEngine: OpenCapacityEngine = OpenCapacityEngine(),
        protectionEngine: ProtectionEngine = ProtectionEngine(),
        bucketizer: LifeShapeBucketizer = LifeShapeBucketizer()
    ) {
        self.openCapacityEngine = openCapacityEngine
        self.protectionEngine = protectionEngine
        self.bucketizer = bucketizer
    }

    func project(_ input: LifeShapeEngineInput) throws -> LifeShapeProjection {
        let protectedProjection = protectionEngine.project(input.protected)
        let openProjection = openCapacityEngine.project(input.open)
        return try bucketizer.projection(from: LifeShapeBucketizerInput(
            generatedAt: input.generatedAt,
            currentDate: input.currentDate,
            selectedHorizon: input.horizon,
            openProjection: openProjection,
            protectionProjection: protectedProjection
        ))
    }
}
