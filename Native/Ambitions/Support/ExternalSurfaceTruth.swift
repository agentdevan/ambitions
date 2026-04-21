import Foundation

enum ExternalSurfaceTruth {
    static let verifiedRoutingTruth = "Canonical routing verified in repo validation"
    static let availableButNeedsManualVerification = "Available in this build, manual verification still required"
    static let notShippedInThisBuild = "Not shipped in this build"
    static let deferredForLaterProductization = "Deferred for later productization"
}
