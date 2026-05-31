import Foundation
#if canImport(UIKit)
import UIKit
#endif

public enum AmbitionsHapticIntent: String, CaseIterable, Sendable {
    case startNow
    case proofAttached
    case closureRecorded
    case recoverySuggested
    case trustRevealed
}

public enum AmbitionsHaptics {
    public static func perform(_ intent: AmbitionsHapticIntent, enabled: Bool = true) {
        guard enabled else { return }
        #if canImport(UIKit)
        switch intent {
        case .startNow:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .proofAttached, .closureRecorded:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .recoverySuggested:
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        case .trustRevealed:
            UISelectionFeedbackGenerator().selectionChanged()
        }
        #endif
    }
}

public enum AmbitionsExperienceEvent: String, CaseIterable, Sendable, Codable {
    case surfaceRendered
    case decisionLayerOpened
    case proofInspected
    case closureRecorded
    case recommendationAccepted
    case recommendationAdjusted
}

public struct AmbitionsLocalDiagnosticsEnvelope: Equatable, Sendable, Codable {
    public let event: AmbitionsExperienceEvent
    public let surface: AmbitionsSurface
    public let localOnly: Bool
    public let includesContent: Bool

    public init(event: AmbitionsExperienceEvent, surface: AmbitionsSurface, localOnly: Bool = true, includesContent: Bool = false) {
        self.event = event
        self.surface = surface
        self.localOnly = localOnly
        self.includesContent = includesContent
    }

    public var isAllowed: Bool {
        localOnly && !includesContent
    }
}
