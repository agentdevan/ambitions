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
        let privacyLabel: String
        let stateLabel: String
        let proofLabel: String
        let deepLinkURLString: String
        let endsAt: String

        var accessibilitySummary: String {
            "\(stateLabel). \(title). \(detail). \(proofLabel). \(privacyLabel). \(leaseLabel)."
        }

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
            pressureLevel: ExternalSurfacePressureLevel = .steady,
            privacyLabel: String = ExternalSurfacePrivacySnapshotPolicy.safeDefault.sensitiveDetailLabel,
            stateLabel: String = "Current focus window",
            proofLabel: String = "Receipt-backed local snapshot",
            deepLinkURLString: String,
            endsAt: String
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
            self.privacyLabel = privacyLabel
            self.stateLabel = stateLabel
            self.proofLabel = proofLabel
            self.deepLinkURLString = deepLinkURLString
            self.endsAt = endsAt
        }

        init?(snapshot: ExternalSurfaceSnapshot?, now: Date) {
            let glance = ExternalSurfaceGlanceState(snapshot: snapshot)
            let privacy = snapshot?.privacy ?? .safeDefault
            let contract = ExternalSurfaceContractRegistry.contract(for: .liveActivities)
            guard let reference = glance.primaryReference,
                  let stepID = reference.stepID else {
                return nil
            }

            let formatter = ISO8601DateFormatter()
            let updatedAt = formatter.string(from: now)
            let endsAt = formatter.string(from: now.addingTimeInterval(60 * 60))
            let deepLink = ExternalSurfaceActionPayload.safeDeepLinkURL(
                surface: .goalDetail,
                goalID: reference.goalID,
                origin: .liveActivity,
                fallbackTab: contract.fallbackTab ?? "time"
            )?.absoluteString ?? "ambitions://tab/time?origin=live_activity"

            self.init(
                goalID: reference.goalID,
                stepID: stepID,
                title: Self.title(for: glance),
                detail: Self.detail(for: glance),
                leaseLabel: glance.continuity.lease.freshnessLabel,
                syncLabel: glance.continuity.syncHealth.label,
                urgency: glance.urgency,
                timing: glance.timing,
                updatedAt: updatedAt,
                pressureLevel: glance.pressureLevel,
                privacyLabel: Self.privacyLabel(
                    leaseStatus: glance.continuity.lease.status,
                    privacy: privacy,
                    contract: contract
                ),
                stateLabel: Self.stateLabel(for: glance.continuity.lease.status),
                proofLabel: Self.proofLabel(for: glance),
                deepLinkURLString: deepLink,
                endsAt: endsAt
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
            case privacyLabel
            case stateLabel
            case proofLabel
            case deepLinkURLString
            case endsAt
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            goalID = try container.decode(String.self, forKey: .goalID)
            stepID = try container.decode(String.self, forKey: .stepID)
            title = try container.decodeIfPresent(String.self, forKey: .title) ?? "Focus step ready"
            detail = try container.decodeIfPresent(String.self, forKey: .detail) ?? "Return to the bounded next step."
            leaseLabel = try container.decodeIfPresent(String.self, forKey: .leaseLabel) ?? "Updated recently"
            syncLabel = try container.decodeIfPresent(String.self, forKey: .syncLabel) ?? "Local-first and stable"
            urgency = try container.decode(ExternalSurfaceUrgency.self, forKey: .urgency)
            timing = try container.decode(ExternalSurfaceTiming.self, forKey: .timing)
            updatedAt = try container.decode(String.self, forKey: .updatedAt)
            pressureLevel = try container.decodeIfPresent(ExternalSurfacePressureLevel.self, forKey: .pressureLevel) ?? .steady
            privacyLabel = try container.decodeIfPresent(String.self, forKey: .privacyLabel)
                ?? ExternalSurfacePrivacySnapshotPolicy.safeDefault.sensitiveDetailLabel
            stateLabel = try container.decodeIfPresent(String.self, forKey: .stateLabel) ?? "Current focus window"
            proofLabel = try container.decodeIfPresent(String.self, forKey: .proofLabel) ?? "Receipt-backed local snapshot"
            deepLinkURLString = try container.decodeIfPresent(String.self, forKey: .deepLinkURLString)
                ?? ExternalSurfaceActionPayload.safeDeepLinkURL(surface: .goalDetail, goalID: goalID, origin: .liveActivity, fallbackTab: "time")?.absoluteString
                ?? "ambitions://tab/time?origin=live_activity"
            endsAt = try container.decodeIfPresent(String.self, forKey: .endsAt) ?? updatedAt
        }

        private static func privacyLabel(
            leaseStatus: ExternalSurfaceLeaseStatus,
            privacy: ExternalSurfacePrivacySnapshotPolicy,
            contract: ExternalSurfaceContract
        ) -> String {
            switch leaseStatus {
            case .current:
                return contract.hidesSensitiveDetailsByDefault
                    ? privacy.sensitiveDetailLabel
                    : "Live Activity details follow your Ambitions privacy settings."
            case .stale:
                return privacy.staleLabel
            case .unavailable:
                return privacy.unavailableLabel
            }
        }

        private static func stateLabel(for leaseStatus: ExternalSurfaceLeaseStatus) -> String {
            switch leaseStatus {
            case .current:
                return "Current focus window"
            case .stale:
                return "Open Ambitions to refresh"
            case .unavailable:
                return "Open Ambitions to confirm"
            }
        }

        private static func title(for glance: ExternalSurfaceGlanceState) -> String {
            switch glance.continuity.lease.status {
            case .current:
                return glance.ambientState?.focus.title ?? "Focus step ready"
            case .stale:
                return "Open Ambitions to refresh"
            case .unavailable:
                return "Open Ambitions"
            }
        }

        private static func detail(for glance: ExternalSurfaceGlanceState) -> String {
            switch glance.continuity.lease.status {
            case .current:
                return glance.ambientState?.focus.detail ?? "Return to the bounded next step."
            case .stale, .unavailable:
                return "Confirm the latest local state in Ambitions."
            }
        }

        private static func proofLabel(for glance: ExternalSurfaceGlanceState) -> String {
            switch glance.continuity.lease.status {
            case .current:
                return "Receipt-backed local snapshot"
            case .stale:
                return "Stale snapshot; open before acting"
            case .unavailable:
                return "No local snapshot available"
            }
        }
    }

    let contextID: String
}

enum NextStepLiveActivityLifecycleDecision: Equatable {
    case end
    case requestOrUpdate(NextStepActivityAttributes.ContentState)

    static func evaluate(
        snapshot: ExternalSurfaceSnapshot?,
        now: Date
    ) -> NextStepLiveActivityLifecycleDecision {
        guard let contentState = NextStepActivityAttributes.ContentState(snapshot: snapshot, now: now) else {
            return .end
        }

        return .requestOrUpdate(contentState)
    }
}
