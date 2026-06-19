import Foundation

extension ProgressMetricKind {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        switch rawValue {
        case Self.stepCompletion.rawValue:
            self = .stepCompletion
        case Self.evidenceCount.rawValue:
            self = .evidenceCount
        case Self.ritualRhythm.rawValue, "streak":
            self = .ritualRhythm
        case Self.timeInvested.rawValue:
            self = .timeInvested
        case Self.confidenceGain.rawValue:
            self = .confidenceGain
        case Self.observationLog.rawValue:
            self = .observationLog
        default:
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unknown progress metric kind: \(rawValue)"
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension ProgressRollupMethod {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        switch rawValue {
        case Self.sum.rawValue:
            self = .sum
        case Self.ratio.rawValue:
            self = .ratio
        case Self.latest.rawValue:
            self = .latest
        case Self.weightedRatio.rawValue:
            self = .weightedRatio
        case Self.rhythmLength.rawValue, "streak_length":
            self = .rhythmLength
        default:
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unknown progress rollup method: \(rawValue)"
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
