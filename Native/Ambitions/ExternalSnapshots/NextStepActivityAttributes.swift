import ActivityKit
import Foundation

struct NextStepActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        let goalID: String
        let stepID: String
        let title: String
        let detail: String
        let leaseLabel: String
        let syncLabel: String
        let urgency: ExternalSurfaceUrgency
        let timing: ExternalSurfaceTiming
        let updatedAt: String
        let pressureLevel: ExternalSurfacePressureLevel

        init(
            goalID: String,
            stepID: String,
            title: String,
            detail: String,
            leaseLabel: String,
            syncLabel: String,
            urgency: ExternalSurfaceUrgency,
            timing: ExternalSurfaceTiming,
            updatedAt: String,
            pressureLevel: ExternalSurfacePressureLevel = .steady
        ) {
            self.goalID = goalID
            self.stepID = stepID
            self.title = title
            self.detail = detail
            self.leaseLabel = leaseLabel
            self.syncLabel = syncLabel
            self.urgency = urgency
            self.timing = timing
            self.updatedAt = updatedAt
            self.pressureLevel = pressureLevel
        }

        init?(snapshot: ExternalSurfaceSnapshot?, now: Date) {
            let glance = ExternalSurfaceGlanceState(snapshot: snapshot)
            guard let reference = glance.primaryReference,
                  let stepID = reference.stepID else {
                return nil
            }

            self.init(
                goalID: reference.goalID,
                stepID: stepID,
                title: glance.ambientState?.focus.title ?? "Focus step ready",
                detail: glance.ambientState?.focus.detail ?? "Return to the bounded next move.",
                leaseLabel: glance.continuity.lease.freshnessLabel,
                syncLabel: glance.continuity.syncHealth.label,
                urgency: glance.urgency,
                timing: glance.timing,
                updatedAt: ISO8601DateFormatter().string(from: now),
                pressureLevel: glance.pressureLevel
            )
        }

        enum CodingKeys: String, CodingKey {
            case goalID
            case stepID
            case title
            case detail
            case leaseLabel
            case syncLabel
            case urgency
            case timing
            case updatedAt
            case pressureLevel
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            goalID = try container.decode(String.self, forKey: .goalID)
            stepID = try container.decode(String.self, forKey: .stepID)
            title = try container.decodeIfPresent(String.self, forKey: .title) ?? "Focus step ready"
            detail = try container.decodeIfPresent(String.self, forKey: .detail) ?? "Return to the bounded next move."
            leaseLabel = try container.decodeIfPresent(String.self, forKey: .leaseLabel) ?? "Updated recently"
            syncLabel = try container.decodeIfPresent(String.self, forKey: .syncLabel) ?? "Local-first and stable"
            urgency = try container.decode(ExternalSurfaceUrgency.self, forKey: .urgency)
            timing = try container.decode(ExternalSurfaceTiming.self, forKey: .timing)
            updatedAt = try container.decode(String.self, forKey: .updatedAt)
            pressureLevel = try container.decodeIfPresent(ExternalSurfacePressureLevel.self, forKey: .pressureLevel) ?? .steady
        }
    }

    let contextID: String
}
