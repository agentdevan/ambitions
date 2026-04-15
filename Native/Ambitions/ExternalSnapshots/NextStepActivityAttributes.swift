import ActivityKit
import Foundation

struct NextStepActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        let goalID: String
        let stepID: String
        let urgency: ExternalSurfaceUrgency
        let timing: ExternalSurfaceTiming
        let updatedAt: String
    }

    let contextID: String
}
