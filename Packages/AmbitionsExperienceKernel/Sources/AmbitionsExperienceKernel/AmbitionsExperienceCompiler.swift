import Foundation

public enum AmbitionsStepFit: String, CaseIterable, Sendable, Codable {
    case fitsNow
    case tightFit
    case needsBuffer
    case protectedTime
    case recoveryFirst
}

public struct AmbitionsCompilerCalibration: Equatable, Sendable, Codable {
    public let directSignalFreshMinutes: Double
    public let acceptedSignalFreshMinutes: Double
    public let calendarSignalFreshMinutes: Double
    public let inferredSignalFreshMinutes: Double
    public let minimumBufferMinutes: Int
    public let residueSoftCap: Double
    public let pressureSoftCapMinutes: Double

    public init(
        directSignalFreshMinutes: Double = 720,
        acceptedSignalFreshMinutes: Double = 540,
        calendarSignalFreshMinutes: Double = 360,
        inferredSignalFreshMinutes: Double = 180,
        minimumBufferMinutes: Int = 8,
        residueSoftCap: Double = 4,
        pressureSoftCapMinutes: Double = 90
    ) {
        self.directSignalFreshMinutes = directSignalFreshMinutes
        self.acceptedSignalFreshMinutes = acceptedSignalFreshMinutes
        self.calendarSignalFreshMinutes = calendarSignalFreshMinutes
        self.inferredSignalFreshMinutes = inferredSignalFreshMinutes
        self.minimumBufferMinutes = minimumBufferMinutes
        self.residueSoftCap = residueSoftCap
        self.pressureSoftCapMinutes = pressureSoftCapMinutes
    }

    public func freshnessWindow(for quality: AmbitionsSourceQuality) -> Double {
        switch quality {
        case .directUserCommitment:
            return directSignalFreshMinutes
        case .acceptedSchedule:
            return acceptedSignalFreshMinutes
        case .calendarEvent, .recentClosure:
            return calendarSignalFreshMinutes
        case .historicalPattern, .inferredContext, .staleSignal:
            return inferredSignalFreshMinutes
        }
    }
}

public struct AmbitionsRuntimeSnapshotInput: Equatable, Sendable, Codable {
    public let surface: AmbitionsSurface
    public let hardContext: AmbitionsHardContext
    public let availability: AmbitionsAvailabilityContext
    public let cognitiveContext: AmbitionsCognitiveContext
    public let availableMinutes: Int
    public let recommendedMinutes: Int
    public let protectedMinutesAhead: Int
    public let unclosedStepCount: Int
    public let proofCount: Int
    public let sourceAgeMinutes: Int
    public let sourceQuality: AmbitionsSourceQuality
    public let goalPull: Double
    public let recoveryNeed: Double
    public let privacyBoundaryActive: Bool

    public init(
        surface: AmbitionsSurface,
        hardContext: AmbitionsHardContext,
        availability: AmbitionsAvailabilityContext,
        cognitiveContext: AmbitionsCognitiveContext,
        availableMinutes: Int,
        recommendedMinutes: Int,
        protectedMinutesAhead: Int,
        unclosedStepCount: Int,
        proofCount: Int,
        sourceAgeMinutes: Int,
        sourceQuality: AmbitionsSourceQuality,
        goalPull: Double,
        recoveryNeed: Double,
        privacyBoundaryActive: Bool
    ) {
        self.surface = surface
        self.hardContext = hardContext
        self.availability = availability
        self.cognitiveContext = cognitiveContext
        self.availableMinutes = availableMinutes
        self.recommendedMinutes = recommendedMinutes
        self.protectedMinutesAhead = protectedMinutesAhead
        self.unclosedStepCount = unclosedStepCount
        self.proofCount = proofCount
        self.sourceAgeMinutes = sourceAgeMinutes
        self.sourceQuality = sourceQuality
        self.goalPull = goalPull
        self.recoveryNeed = recoveryNeed
        self.privacyBoundaryActive = privacyBoundaryActive
    }
}

public struct AmbitionsVisualFieldState: Equatable, Sendable, Codable {
    public let capacityGrain: Double
    public let protectedPressure: Double
    public let closureResidue: Double
    public let sourceFreshness: Double
    public let goalPull: Double
    public let proofIntensity: Double
    public let recoveryWarmth: Double
    public let privacyBoundary: Double
    public let compression: Double
    public let fit: AmbitionsStepFit
}

public enum AmbitionsExperienceCompiler {
    public static func compile(_ input: AmbitionsRuntimeSnapshotInput, calibration: AmbitionsCompilerCalibration = .init()) -> AmbitionsVisualFieldState {
        let hardContextBlocks = input.hardContext == .protected || input.hardContext == .away || input.hardContext == .commute
        let unavailable = input.availability == .unavailable
        let needsRecovery = input.recoveryNeed >= 0.55 || input.cognitiveContext == .recovery
        let fit: AmbitionsStepFit

        if hardContextBlocks || unavailable {
            fit = .protectedTime
        } else if needsRecovery {
            fit = .recoveryFirst
        } else if input.availableMinutes < input.recommendedMinutes {
            fit = .needsBuffer
        } else if input.availableMinutes < input.recommendedMinutes + calibration.minimumBufferMinutes {
            fit = .tightFit
        } else {
            fit = .fitsNow
        }

        let capacityRatio = input.recommendedMinutes <= 0 ? 0 : Double(input.recommendedMinutes) / Double(max(input.availableMinutes, 1))
        let capacityGrain = clamp01(capacityRatio)
        let protectedPressure = clamp01(Double(input.protectedMinutesAhead) / calibration.pressureSoftCapMinutes)
        let closureResidue = clamp01(Double(input.unclosedStepCount) / calibration.residueSoftCap)
        let freshnessWindow = max(calibration.freshnessWindow(for: input.sourceQuality), 1)
        let sourceFreshness = clamp01(1 - (Double(input.sourceAgeMinutes) / freshnessWindow))
        let proofIntensity = clamp01(Double(input.proofCount) / 5.0) * sourceFreshness
        let compression = max(capacityGrain, max(protectedPressure, closureResidue))

        return .init(
            capacityGrain: capacityGrain,
            protectedPressure: protectedPressure,
            closureResidue: closureResidue,
            sourceFreshness: sourceFreshness,
            goalPull: clamp01(input.goalPull),
            proofIntensity: proofIntensity,
            recoveryWarmth: clamp01(input.recoveryNeed),
            privacyBoundary: input.privacyBoundaryActive ? 1 : 0,
            compression: clamp01(compression),
            fit: fit
        )
    }

    private static func clamp01(_ value: Double) -> Double {
        min(1, max(0, value))
    }
}
