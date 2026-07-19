import Foundation

enum LifeShapeContractViolation: Error, Equatable {
    case missingDerivation
    case missingAccessibilitySummary
    case invalidDateRange
}

struct LifeShapeBucket: Identifiable, Sendable, Hashable {
    let id: String
    let start: Date
    let end: Date
    let horizon: LifeShapeHorizon
    let layer: LifeShapeLayer
    let reading: LifeShapeReading
    let fixedPoints: [FixedPoint]
    let protectedBoundary: ProtectedBoundary?
    let recommendedStepID: String?
    let primaryAction: LifeShapePrimaryAction?
    let correctionOptions: [LifeShapeCorrection]
    let derivation: LifeShapeDerivation
    let confidence: LifeShapeConfidence
    let accessibilitySummary: String

    private init(
        id: String,
        start: Date,
        end: Date,
        horizon: LifeShapeHorizon,
        layer: LifeShapeLayer,
        reading: LifeShapeReading,
        fixedPoints: [FixedPoint],
        protectedBoundary: ProtectedBoundary?,
        recommendedStepID: String?,
        primaryAction: LifeShapePrimaryAction?,
        correctionOptions: [LifeShapeCorrection],
        derivation: LifeShapeDerivation,
        confidence: LifeShapeConfidence,
        accessibilitySummary: String
    ) {
        self.id = id
        self.start = start
        self.end = end
        self.horizon = horizon
        self.layer = layer
        self.reading = reading
        self.fixedPoints = fixedPoints
        self.protectedBoundary = protectedBoundary
        self.recommendedStepID = recommendedStepID
        self.primaryAction = primaryAction
        self.correctionOptions = correctionOptions
        self.derivation = derivation
        self.confidence = confidence
        self.accessibilitySummary = accessibilitySummary
    }

    static func runtimeValidated(
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
        guard end >= start else { throw LifeShapeContractViolation.invalidDateRange }
        guard derivation.isCompleteForVisibleMark else { throw LifeShapeContractViolation.missingDerivation }
        guard accessibilitySummary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw LifeShapeContractViolation.missingAccessibilitySummary
        }

        return LifeShapeBucket(
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
}

struct LifeShapePrimaryAction: Identifiable, Sendable, Hashable {
    let id: String
    let title: String
    let actionKind: String

    init(id: String, title: String, actionKind: String) {
        self.id = id
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.actionKind = actionKind.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
