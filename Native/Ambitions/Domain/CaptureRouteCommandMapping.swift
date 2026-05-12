import Foundation

extension CaptureRoute {
    static func commandDestinationRoute(_ destinationRoute: String?) -> CaptureRoute? {
        guard let destinationRoute = destinationRoute?.trimmingCharacters(in: .whitespacesAndNewlines),
              destinationRoute.isEmpty == false else {
            return nil
        }

        switch destinationRoute {
        case "plan", CaptureRoute.planSeed.rawValue:
            return .planSeed
        case "goal", CaptureRoute.goalSeed.rawValue:
            return .goalSeed
        case CaptureRoute.goalAttachment.rawValue:
            return .goalAttachment
        case CaptureRoute.deliverableSeed.rawValue:
            return .deliverableSeed
        case CaptureRoute.proofItem.rawValue:
            return .proofItem
        case CaptureRoute.constraintItem.rawValue:
            return .constraintItem
        case CaptureRoute.waiting.rawValue:
            return .waiting
        case CaptureRoute.optionalSomeday.rawValue:
            return .optionalSomeday
        case CaptureRoute.archive.rawValue:
            return .archive
        case CaptureRoute.captureInbox.rawValue:
            return .captureInbox
        default:
            return .captureInbox
        }
    }
}
