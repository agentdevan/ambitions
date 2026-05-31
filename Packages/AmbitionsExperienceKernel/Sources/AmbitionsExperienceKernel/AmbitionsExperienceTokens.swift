import SwiftUI

public enum AmbitionsTypeToken: String, CaseIterable, Sendable {
    case heroDisplay
    case surfaceTitle
    case objectHead
    case bodyPrimary
    case bodyCompact
    case captionProof
}

public enum AmbitionsSpaceToken: CGFloat, CaseIterable, Sendable {
    case micro = 2
    case xxs = 4
    case xs = 8
    case sm = 12
    case md = 16
    case lg = 24
    case xl = 32
    case xxl = 48
    case surface = 64
}

public enum AmbitionsRadiusToken: CGFloat, CaseIterable, Sendable {
    case none = 0
    case sm = 6
    case md = 12
    case lg = 18
    case xl = 24
    case xxl = 32
    case continuous = 36
    case pill = 999
}

public enum AmbitionsMotionToken: String, CaseIterable, Sendable {
    case semanticSettle
    case proofAttach
    case objectBreathe
    case closureMorph
    case trustReveal
}

public struct AmbitionsMotionSpec: Sendable {
    public let duration: TimeInterval
    public let reducedDuration: TimeInterval
    public let makeAnimation: @Sendable (_ reducedMotion: Bool) -> Animation?

    public init(duration: TimeInterval, reducedDuration: TimeInterval, makeAnimation: @escaping @Sendable (_ reducedMotion: Bool) -> Animation?) {
        self.duration = duration
        self.reducedDuration = reducedDuration
        self.makeAnimation = makeAnimation
    }
}

public enum AmbitionsTokens {
    public static func color(_ token: AmbitionsColorToken) -> Color {
        color(token, bundle: .module)
    }

    public static func color(_ token: AmbitionsColorToken, bundle: Bundle) -> Color {
        Color(token.rawValue, bundle: bundle)
    }

    public static func font(_ token: AmbitionsTypeToken) -> Font {
        switch token {
        case .heroDisplay:
            return .system(size: 38, weight: .semibold, design: .default)
        case .surfaceTitle:
            return .system(size: 28, weight: .semibold, design: .default)
        case .objectHead:
            return .system(size: 22, weight: .semibold, design: .default)
        case .bodyPrimary:
            return .system(size: 17, weight: .regular, design: .default)
        case .bodyCompact:
            return .system(size: 15, weight: .regular, design: .default)
        case .captionProof:
            return .system(size: 12, weight: .medium, design: .default)
        }
    }

    public static func space(_ token: AmbitionsSpaceToken) -> CGFloat {
        token.rawValue
    }

    public static func radius(_ token: AmbitionsRadiusToken) -> CGFloat {
        token.rawValue
    }

    public static func motion(_ token: AmbitionsMotionToken) -> AmbitionsMotionSpec {
        switch token {
        case .semanticSettle:
            return .init(duration: 0.260, reducedDuration: 0.120) { reduced in
                reduced ? .easeOut(duration: 0.120) : .timingCurve(0.2, 0.8, 0.2, 1.0, duration: 0.260)
            }
        case .proofAttach:
            return .init(duration: 0.220, reducedDuration: 0.100) { reduced in
                reduced ? .easeOut(duration: 0.100) : .timingCurve(0.3, 0.9, 0.2, 1.0, duration: 0.220)
            }
        case .objectBreathe:
            return .init(duration: 1.200, reducedDuration: 0.0) { reduced in
                reduced ? nil : .spring(response: 0.60, dampingFraction: 0.92)
            }
        case .closureMorph:
            return .init(duration: 0.420, reducedDuration: 0.160) { reduced in
                reduced ? .easeOut(duration: 0.160) : .spring(response: 0.42, dampingFraction: 0.86)
            }
        case .trustReveal:
            return .init(duration: 0.180, reducedDuration: 0.0) { reduced in
                reduced ? nil : .easeOut(duration: 0.180)
            }
        }
    }
}
