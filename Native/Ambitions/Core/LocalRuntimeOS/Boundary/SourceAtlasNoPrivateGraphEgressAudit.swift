import Foundation

enum SourceAtlasNoPrivateGraphEgressSurface: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case requestShape = "request_shape"
    case cacheMetadata = "cache_metadata"
    case objectKey = "object_key"
    case logLine = "log_line"
    case fixture = "fixture"
    case inspectionDetail = "inspection_detail"
}

struct SourceAtlasNoPrivateGraphEgressRecord: Codable, Sendable, Equatable, Hashable {
    let surface: SourceAtlasNoPrivateGraphEgressSurface
    let identifier: String
    let inspectedValue: String
}

struct SourceAtlasNoPrivateGraphEgressFinding: Codable, Sendable, Equatable, Hashable {
    let surface: SourceAtlasNoPrivateGraphEgressSurface
    let identifier: String
    let forbiddenToken: String
}

enum SourceAtlasNoPrivateGraphEgressAudit {
    static let forbiddenTokens = [
        "goal_text",
        "goaltext",
        "goal_id",
        "goal_ids",
        "goal_payload",
        "goals_payload",
        "capture_text",
        "capturetext",
        "capture_id",
        "capture_ids",
        "capture_payload",
        "captures_payload",
        "schedule_assumption",
        "scheduleassumption",
        "schedule_capacity",
        "capacity",
        "life_capital",
        "lifecapital",
        "proof_payload",
        "proofpayload",
        "proof_id",
        "proof_ids",
        "receipt_payload",
        "receiptpayload",
        "receipt_id",
        "receipt_ids",
        "receipts_payload",
        "private_graph",
        "privategraph",
        "private_graph_id",
        "private_life_graph",
        "account_secret",
        "accountsecret",
        "user_id",
        "userid",
        "inferred_priority",
        "inferredpriority",
        "behavior_history",
        "behaviorhistory",
        "behavior_pattern",
        "personalization",
        "personalization_signal",
        "personalization_factor",
        "personal_context",
        "private_user_context",
        "final_schedule",
        "step_list",
        "calendar_context",
        "life_area",
    ]

    static func validate(_ records: [SourceAtlasNoPrivateGraphEgressRecord]) -> [SourceAtlasNoPrivateGraphEgressFinding] {
        records.flatMap { record in
            let normalized = normalize(record.inspectedValue)
            return forbiddenTokens.compactMap { token in
                normalized.contains(token)
                    ? SourceAtlasNoPrivateGraphEgressFinding(
                        surface: record.surface,
                        identifier: record.identifier,
                        forbiddenToken: token
                    )
                    : nil
            }
        }
    }

    static func normalize(_ value: String) -> String {
        value
            .lowercased()
            .replacingOccurrences(of: "-", with: "_")
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: ".", with: "_")
    }
}
