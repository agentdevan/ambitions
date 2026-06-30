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
        "capture_text",
        "capturetext",
        "schedule_assumption",
        "scheduleassumption",
        "schedule_capacity",
        "capacity",
        "life_capital",
        "lifecapital",
        "proof_payload",
        "proofpayload",
        "receipt_payload",
        "receiptpayload",
        "private_graph",
        "privategraph",
        "private_graph_id",
        "account_secret",
        "accountsecret",
        "user_id",
        "userid",
        "inferred_priority",
        "inferredpriority",
        "behavior_history",
        "behaviorhistory",
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
