import Foundation

enum CaptureTypedRouteKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case freeCapture = "free_capture"
    case goalSeed = "goal_seed"
    case stepSeed = "step_seed"
    case proof
    case timeProtect = "time_protect"
    case noteThought = "note_thought"
    case fixedPointConstraint = "fixed_point_constraint"
    case attachmentContext = "attachment_context"

    var persistenceRoute: CaptureRoute {
        switch self {
        case .freeCapture, .noteThought:
            return .captureInbox
        case .goalSeed:
            return .goalSeed
        case .stepSeed, .timeProtect:
            return .timeSeed
        case .proof, .attachmentContext:
            return .proofItem
        case .fixedPointConstraint:
            return .constraintItem
        }
    }

    var captureKind: CaptureKind {
        switch self {
        case .freeCapture, .noteThought:
            return .raw
        case .goalSeed:
            return .goalSeed
        case .stepSeed, .timeProtect:
            return .oneTimeCommitment
        case .proof, .attachmentContext:
            return .goalSupportingTask
        case .fixedPointConstraint:
            return .deliverableSeed
        }
    }

    var accessibleDestinationLabel: String {
        switch self {
        case .freeCapture:
            return "Unplaced item"
        case .goalSeed:
            return "Goal seed"
        case .stepSeed:
            return "Step"
        case .proof:
            return "Proof"
        case .timeProtect:
            return "Protected time"
        case .noteThought:
            return "Thought"
        case .fixedPointConstraint:
            return "Fixed point"
        case .attachmentContext:
            return "Attachment context"
        }
    }
}

struct CaptureRouteContext: Codable, Sendable, Equatable, Hashable {
    let sourceSurface: String
    let goalID: String?
    let lifeAreaID: String?
    let timeWindowID: String?
    let attachmentIDs: [String]

    init(
        sourceSurface: String,
        goalID: String? = nil,
        lifeAreaID: String? = nil,
        timeWindowID: String? = nil,
        attachmentIDs: [String] = []
    ) {
        self.sourceSurface = sourceSurface
        self.goalID = goalID
        self.lifeAreaID = lifeAreaID
        self.timeWindowID = timeWindowID
        self.attachmentIDs = attachmentIDs
    }
}

struct CaptureTypedRoute: Codable, Sendable, Equatable, Hashable, Identifiable {
    let kind: CaptureTypedRouteKind
    let context: CaptureRouteContext

    var id: String {
        [
            kind.rawValue,
            context.sourceSurface,
            context.goalID ?? "goal:none",
            context.lifeAreaID ?? "area:none",
            context.timeWindowID ?? "time:none",
            context.attachmentIDs.joined(separator: ",")
        ].joined(separator: "|")
    }

    var persistenceRoute: CaptureRoute { kind.persistenceRoute }
    var captureKind: CaptureKind { kind.captureKind }
    var skipsContextDepth: Bool {
        context.goalID != nil || context.lifeAreaID != nil || context.timeWindowID != nil || context.attachmentIDs.isEmpty == false
    }

    static func globalBlank(sourceSurface: String = "Capture") -> CaptureTypedRoute {
        CaptureTypedRoute(kind: .freeCapture, context: CaptureRouteContext(sourceSurface: sourceSurface))
    }
}
