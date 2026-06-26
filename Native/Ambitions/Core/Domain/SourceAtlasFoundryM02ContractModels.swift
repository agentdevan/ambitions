import Foundation

struct SourceAtlasFoundryM02Pack: Decodable, Equatable {
    let schemaVersion: Int
    let kind: String
    let id: String
    let versionID: String
    let dataClass: String?
    let metadata: SourceAtlasFoundryM02Metadata
    let sources: [SourceAtlasFoundryM02Source]
    let claims: [SourceAtlasFoundryM02Claim]
    let requirements: [SourceAtlasFoundryM02Requirement]
    let pathways: [SourceAtlasFoundryM02Pathway]
    let inspectionContract: SourceAtlasFoundryM02InspectionContract
    let nonClaims: [String]

    var isPublicReferenceOnly: Bool {
        kind == "ambitions.sourceAtlas.foundryPack" &&
            metadata.runtimeRole == "reference_enrichment_only" &&
            metadata.localPersonalizationRequired &&
            metadata.sourceAtlasInvisibleByDefault &&
            metadata.privacyBoundary.localizedCaseInsensitiveContains("public/reference/freshness only")
    }

    var preservesFoundryClaimStates: Bool {
        claims.allSatisfy { $0.state != SourceAtlasClaimState.official.rawValue && $0.state != SourceAtlasClaimState.officialCurrentCompatibilityRawValue }
    }
}

struct SourceAtlasFoundryM02Metadata: Decodable, Equatable {
    let freshnessState: String
    let privacyBoundary: String
    let runtimeRole: String
    let localPersonalizationRequired: Bool
    let sourceAtlasInvisibleByDefault: Bool
    let harvestRunID: String?
}

struct SourceAtlasFoundryM02Source: Decodable, Equatable, Identifiable {
    let id: String
    let title: String
    let publisher: String
    let url: String
    let authorityTier: String
    let freshnessCadence: String
    let license: String
}

struct SourceAtlasFoundryM02Claim: Decodable, Equatable, Identifiable {
    let id: String
    let text: String
    let claimType: String
    let state: String
    let freshness: String
    let sourceIDs: [String]

    var isFoundrySourceBacked: Bool {
        state == "source_backed"
    }

    var requiresExplicitNativePromotion: Bool {
        isFoundrySourceBacked || freshness.hasSuffix("_watch")
    }
}

struct SourceAtlasFoundryM02Requirement: Decodable, Equatable, Identifiable {
    let id: String
    let claimID: String
    let gateType: String
    let structuredRule: [String: SourceAtlasFoundryM02JSONValue]
}

struct SourceAtlasFoundryM02Pathway: Decodable, Equatable, Identifiable {
    let id: String
    let title: String
    let domain: String
    let runtimeBehavior: SourceAtlasFoundryM02RuntimeBehavior
}

struct SourceAtlasFoundryM02RuntimeBehavior: Decodable, Equatable {
    let canEnrichLocalPath: Bool
    let mustJoinWithPrivateRuntimeLocally: Bool
    let mustNotUploadPrivateContext: Bool
    let inspectionVisibleOnlyWhenUseful: Bool
    let freshnessChangeMayTriggerReview: Bool
}

struct SourceAtlasFoundryM02InspectionContract: Decodable, Equatable {
    let defaultVisibility: String
    let showWhen: [String]
    let mustInclude: [String]
}

enum SourceAtlasFoundryM02JSONValue: Decodable, Equatable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case object([String: SourceAtlasFoundryM02JSONValue])
    case array([SourceAtlasFoundryM02JSONValue])
    case null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Double.self) {
            self = .number(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode([String: SourceAtlasFoundryM02JSONValue].self) {
            self = .object(value)
        } else {
            self = .array(try container.decode([SourceAtlasFoundryM02JSONValue].self))
        }
    }
}

enum SourceAtlasFoundryM02BoundaryIssue: String, Equatable, Hashable, Comparable {
    case goalText = "goal_text"
    case captureText = "capture_text"
    case scheduleOrCapacity = "schedule_or_capacity"
    case lifeCapital = "life_capital"
    case proofPayload = "proof_payload"
    case receiptPayload = "receipt_payload"
    case accountSecret = "account_secret"
    case userIdentifier = "user_identifier"
    case privateLifeGraph = "private_life_graph"
    case privateText = "private_text"
    case userMiniPack = "user_mini_pack"
    case privatePrivacyClass = "private_privacy_class"
    case userProvidedSource = "user_provided_source"

    static func < (lhs: SourceAtlasFoundryM02BoundaryIssue, rhs: SourceAtlasFoundryM02BoundaryIssue) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

struct SourceAtlasFoundryM02BoundaryValidator {
    func validate(jsonObject: Any) -> [SourceAtlasFoundryM02BoundaryIssue] {
        var issues: Set<SourceAtlasFoundryM02BoundaryIssue> = []
        scan(jsonObject, keyPath: [], issues: &issues)
        return issues.sorted()
    }

    private func scan(_ value: Any, keyPath: [String], issues: inout Set<SourceAtlasFoundryM02BoundaryIssue>) {
        if let dictionary = value as? [String: Any] {
            if dictionary["kind"] as? String == "ambitions.sourceAtlas.userMiniPack" {
                issues.insert(.userMiniPack)
            }
            for (key, child) in dictionary {
                classify(key: key, value: child, issues: &issues)
                scan(child, keyPath: keyPath + [key], issues: &issues)
            }
        } else if let array = value as? [Any] {
            for child in array {
                scan(child, keyPath: keyPath, issues: &issues)
            }
        } else if let string = value as? String {
            classify(text: string, keyPath: keyPath, issues: &issues)
        }
    }

    private func classify(key: String, value: Any, issues: inout Set<SourceAtlasFoundryM02BoundaryIssue>) {
        let normalized = key.lowercased()
        switch normalized {
        case "goaltext", "goaltitle", "goaldescription":
            issues.insert(.goalText)
        case "capturetext", "capturebody", "capturetranscript":
            issues.insert(.captureText)
        case "schedule", "calendardata", "calendarevents", "capacity", "capacitywindow":
            issues.insert(.scheduleOrCapacity)
        case "lifecapital":
            issues.insert(.lifeCapital)
        case "proofpayload":
            issues.insert(.proofPayload)
        case "receiptpayload":
            issues.insert(.receiptPayload)
        case "accountsecret", "apikey", "apitoken", "accesstoken", "refreshtoken":
            issues.insert(.accountSecret)
        case "userid", "accountid":
            issues.insert(.userIdentifier)
        case "privatelifegraph", "personalizationdata", "behaviorhistory":
            issues.insert(.privateLifeGraph)
        default:
            break
        }

        if let string = value as? String {
            let lowered = string.lowercased()
            if normalized == "privacyclass", ["privatelife", "private_life", "private"].contains(lowered) {
                issues.insert(.privatePrivacyClass)
            }
            if normalized == "sourcekind", ["userprovided", "user_provided"].contains(lowered) {
                issues.insert(.userProvidedSource)
            }
            if normalized == "kind", lowered == "ambitions.sourceatlas.userminipack" {
                issues.insert(.userMiniPack)
            }
        }
    }

    private func classify(text: String, keyPath: [String], issues: inout Set<SourceAtlasFoundryM02BoundaryIssue>) {
        if keyPath.last == "privacyBoundary" || keyPath.last == "nonClaims" {
            return
        }
        let lowered = text.lowercased()
        if text.range(of: #"[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}"#, options: [.regularExpression, .caseInsensitive]) != nil ||
            text.range(of: #"\b\d{3}[-.]?\d{3}[-.]?\d{4}\b"#, options: .regularExpression) != nil ||
            text.range(of: #"\b(?:sk|pk|rk|ak)-[A-Za-z0-9_-]{12,}\b"#, options: .regularExpression) != nil ||
            lowered.contains("my goal") ||
            lowered.contains("my schedule") ||
            lowered.contains("my calendar") {
            issues.insert(.privateText)
        }
    }
}

private extension SourceAtlasClaimState {
    static var officialCurrentCompatibilityRawValue: String {
        "official_current"
    }
}
