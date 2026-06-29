import Foundation

struct SourceAtlasPublicPackRequestValidator: Sendable, Equatable, Hashable {
    func validate(_ request: SourceAtlasPublicPackRequest) -> [SourceAtlasPublicPackRequestIssue] {
        var issues: Set<SourceAtlasPublicPackRequestIssue> = []

        if request.packID.isEmpty {
            issues.insert(.missingPackID)
        }
        if request.manifestVersionID.isEmpty {
            issues.insert(.missingManifestVersion)
        }
        if Self.isSHA256Hex(request.declaredSHA256) == false {
            issues.insert(.invalidDeclaredHash)
        }

        var inspectedPairs = request.queryItems
        inspectedPairs["route"] = request.routePath
        inspectedPairs["pack_id"] = request.packID
        inspectedPairs["manifest_version"] = request.manifestVersionID
        inspectedPairs["declared_sha256"] = request.declaredSHA256
        if let channel = request.channel {
            inspectedPairs["channel"] = channel
        }
        if let artifactVersionID = request.artifactVersionID {
            inspectedPairs["artifact_version"] = artifactVersionID
        }
        if let sourceState = request.sourceState {
            inspectedPairs["source_state"] = sourceState.rawValue
        }
        if let freshnessState = request.freshnessState {
            inspectedPairs["freshness_state"] = freshnessState.rawValue
        }
        if let publicJurisdiction = request.publicJurisdiction {
            inspectedPairs["public_jurisdiction"] = publicJurisdiction
        }
        if let publicLocale = request.publicLocale {
            inspectedPairs["public_locale"] = publicLocale
        }
        for (key, value) in inspectedPairs {
            let lowered = "\(key)=\(value)".lowercased()
            if Self.containsPrivatePlanningToken(lowered),
               Self.isReviewedPublicSourceAtlasLocator(key: key, value: value) == false {
                issues.insert(.privatePlanningParameter)
            }
            if Self.containsSecretToken(lowered) {
                issues.insert(.secretParameter)
            }
            if Self.containsPrivateLocator(lowered) {
                issues.insert(.privateLocator)
            }
        }

        return SourceAtlasPublicPackRequestIssue.allCases.filter { issues.contains($0) }
    }

    private static func isSHA256Hex(_ value: String) -> Bool {
        value.count == 64 && value.allSatisfy { character in
            character.isNumber || ("a"..."f").contains(character)
        }
    }

    private static func containsPrivatePlanningToken(_ value: String) -> Bool {
        let tokens = [
            "user",
            "account",
            "account_id",
            "email",
            "phone",
            "address",
            "location",
            "goal",
            "capture",
            "calendar",
            "schedule",
            "capacity",
            "life_capital",
            "lifecapital",
            "proof",
            "receipt",
            "priority",
            "profile",
            "personal",
            "private",
            "context",
            "journal",
            "history",
            "event",
            "task",
            "life_graph",
            "private_graph"
        ]
        return tokens.contains { value.contains($0) }
    }

    private static func containsSecretToken(_ value: String) -> Bool {
        let tokens = [
            "token",
            "secret",
            "api_key",
            "apikey",
            "authorization",
            "cookie"
        ]
        return tokens.contains { value.contains($0) }
    }

    private static func containsPrivateLocator(_ value: String) -> Bool {
        value.contains("file://") ||
            value.contains("/users/") ||
            value.contains("/private/")
    }

    private static func isReviewedPublicSourceAtlasLocator(key: String, value: String) -> Bool {
        let normalizedKey = key.lowercased()
        guard ["artifact_id", "artifact_version", "manifest_version", "pack_id"].contains(normalizedKey) else {
            return false
        }
        let normalizedValue = value.lowercased()
        let publicPrefixes = [
            "source-atlas/v1/domain/",
            "source-atlas/v1/production/stable/",
            "source-atlas/v1/staging/candidate/",
        ]
        guard publicPrefixes.contains(where: normalizedValue.hasPrefix) else {
            return false
        }
        let blockedTokens = [
            "account_id",
            "account-secret",
            "account_secret",
            "capture_text",
            "device_id",
            "goal_text",
            "private_graph",
            "private-goal",
            "private_goal",
            "proof_payload",
            "receipt_payload",
            "user_id",
        ]
        return blockedTokens.contains { normalizedValue.contains($0) } == false
    }
}
