import ActivityKit
import Foundation

struct NextStepActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        let goalID: String
        let stepID: String
        let urgency: ExternalSurfaceUrgency
        let timing: ExternalSurfaceTiming
        let updatedAt: String
        let pressureLevel: ExternalSurfacePressureLevel

        init(
            goalID: String,
            stepID: String,
            urgency: ExternalSurfaceUrgency,
            timing: ExternalSurfaceTiming,
            updatedAt: String,
            pressureLevel: ExternalSurfacePressureLevel = .steady
        ) {
            self.goalID = goalID
            self.stepID = stepID
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
                urgency: glance.urgency,
                timing: glance.timing,
                updatedAt: ISO8601DateFormatter().string(from: now),
                pressureLevel: glance.pressureLevel
            )
        }

        enum CodingKeys: String, CodingKey {
            case goalID
            case stepID
            case urgency
            case timing
            case updatedAt
            case pressureLevel
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            goalID = try container.decode(String.self, forKey: .goalID)
            stepID = try container.decode(String.self, forKey: .stepID)
            urgency = try container.decode(ExternalSurfaceUrgency.self, forKey: .urgency)
            timing = try container.decode(ExternalSurfaceTiming.self, forKey: .timing)
            updatedAt = try container.decode(String.self, forKey: .updatedAt)
            pressureLevel = try container.decodeIfPresent(ExternalSurfacePressureLevel.self, forKey: .pressureLevel) ?? .steady
        }
    }

    let contextID: String
}
