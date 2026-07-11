#if canImport(SwiftUI)
import SwiftUI

public struct SI16VisualQAFixture: Identifiable, Hashable, Sendable {
    public let id: String
    public let previewName: String
    public let screenshotName: String
    public let ownerSurface: String
    public let stateFamily: SI16VisualQAStateFamily
    public let primaryObject: String
    public let accessibilityNote: String
    public let reduceMotionNote: String
    public let privacyNote: String
    public let nonColorNote: String
    public let ldiHandlingLane: String?

    public init(
        id: String,
        previewName: String,
        screenshotName: String,
        ownerSurface: String,
        stateFamily: SI16VisualQAStateFamily,
        primaryObject: String,
        accessibilityNote: String,
        reduceMotionNote: String,
        privacyNote: String,
        nonColorNote: String,
        ldiHandlingLane: String? = nil
    ) {
        self.id = id
        self.previewName = previewName
        self.screenshotName = screenshotName
        self.ownerSurface = ownerSurface
        self.stateFamily = stateFamily
        self.primaryObject = primaryObject
        self.accessibilityNote = accessibilityNote
        self.reduceMotionNote = reduceMotionNote
        self.privacyNote = privacyNote
        self.nonColorNote = nonColorNote
        self.ldiHandlingLane = ldiHandlingLane
    }

    public var loadingState: AmbitionsLoadingState { stateFamily.loadingState }
    public var statusRole: AmbitionsStatusSymbolRole { loadingState.statusSymbolRole }
    public var isFutureLDIVisualHook: Bool { ldiHandlingLane != nil }
    public var claimsHumanApproval: Bool { false }
    public var claimsDeviceProof: Bool { false }
    public var changesRuntimeBehavior: Bool { false }
}
#endif
