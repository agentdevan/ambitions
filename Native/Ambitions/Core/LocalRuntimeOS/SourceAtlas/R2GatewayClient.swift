import Foundation

enum R2GatewayRequestKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case currentPointer = "current_pointer"
    case manifest
    case pack
    case revocation
    case lastKnownGood = "last_known_good"
}

enum R2GatewayClientIssue: String, Codable, Sendable, Equatable, Hashable, Error, CaseIterable {
    case invalidBaseURL = "invalid_base_url"
    case firewallRejected = "firewall_rejected"
    case missingPackRequest = "missing_pack_request"
    case privateObjectKey = "private_object_key"
}

struct R2GatewayCompiledRequest: Codable, Sendable, Equatable, Hashable {
    let kind: R2GatewayRequestKind
    let url: URL
    let objectKey: String
    let queryItems: [String: String]
    let firewallVerdict: PublicOnlyFirewallVerdict
}

struct R2GatewayClient: Sendable, Equatable, Hashable {
    private let baseURL: URL
    private let firewall: PublicOnlyFirewall

    init(
        baseURL: URL,
        firewall: PublicOnlyFirewall = PublicOnlyFirewall()
    ) {
        self.baseURL = baseURL
        self.firewall = firewall
    }

    func compile(
        kind: R2GatewayRequestKind,
        objectKey: String,
        manifestRequest: SourceAtlasPublicManifestRequest,
        packRequest: SourceAtlasPublicPackRequest?,
        accessDecision: SourceAtlasAccessDecision
    ) throws -> R2GatewayCompiledRequest {
        guard baseURL.scheme == "https", baseURL.host?.isEmpty == false else {
            throw R2GatewayClientIssue.invalidBaseURL
        }
        let trimmedObjectKey = objectKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let objectRecord = SourceAtlasNoPrivateGraphEgressRecord(
            surface: .objectKey,
            identifier: "source-atlas-r2-object-key",
            inspectedValue: trimmedObjectKey
        )
        if SourceAtlasNoPrivateGraphEgressAudit.validate([objectRecord]).isEmpty == false {
            throw R2GatewayClientIssue.privateObjectKey
        }

        let verdict = firewall.validate(
            manifestRequest: manifestRequest,
            packRequest: packRequest,
            accessDecision: accessDecision,
            additionalRecords: [objectRecord]
        )
        guard verdict.isAllowed else {
            throw R2GatewayClientIssue.firewallRejected
        }
        if kind == .pack && packRequest == nil {
            throw R2GatewayClientIssue.missingPackRequest
        }

        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        let basePath = components?.path.trimmingCharacters(in: CharacterSet(charactersIn: "/")) ?? ""
        let objectPath = trimmedObjectKey.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        components?.path = "/" + ([basePath, objectPath].filter { $0.isEmpty == false }.joined(separator: "/"))
        components?.queryItems = queryItems(
            for: kind,
            manifestRequest: manifestRequest,
            packRequest: packRequest
        ).sorted { $0.key < $1.key }.map { URLQueryItem(name: $0.key, value: $0.value) }

        guard let url = components?.url else {
            throw R2GatewayClientIssue.invalidBaseURL
        }
        return R2GatewayCompiledRequest(
            kind: kind,
            url: url,
            objectKey: trimmedObjectKey,
            queryItems: Dictionary(uniqueKeysWithValues: components?.queryItems?.map { ($0.name, $0.value ?? "") } ?? []),
            firewallVerdict: verdict
        )
    }

    func urlRequest(for compiled: R2GatewayCompiledRequest) -> URLRequest {
        var request = URLRequest(url: compiled.url)
        request.httpMethod = "GET"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("public-reference", forHTTPHeaderField: "X-Ambitions-Data-Class")
        return request
    }

    private func queryItems(
        for kind: R2GatewayRequestKind,
        manifestRequest: SourceAtlasPublicManifestRequest,
        packRequest: SourceAtlasPublicPackRequest?
    ) -> [String: String] {
        var values = manifestRequest.queryItems
        values["request_kind"] = kind.rawValue
        if let packRequest {
            values.merge(packRequest.queryItems, uniquingKeysWith: { current, _ in current })
            values["pack_id"] = packRequest.packID
            values["manifest_version"] = packRequest.manifestVersionID
            values["sha256"] = packRequest.declaredSHA256
        }
        return values
    }
}
