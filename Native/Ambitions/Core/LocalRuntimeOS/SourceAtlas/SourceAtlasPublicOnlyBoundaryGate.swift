import Foundation

enum SourceAtlasPublicOnlyBoundarySurface: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case requestCompilation = "request_compilation"
    case remoteObjectRequest = "remote_object_request"
    case remoteEndpoint = "remote_endpoint"
    case r2GatewayRequest = "r2_gateway_request"
    case r2URLRequest = "r2_url_request"
    case manifestCacheRollback = "manifest_cache_rollback"
    case sourceAtlasProjection = "source_atlas_projection"
}

enum SourceAtlasPublicOnlyBoundaryIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case firewallRejected = "firewall_rejected"
    case remoteReferenceNotPermitted = "remote_reference_not_permitted"
    case privateRuntimeDataTouched = "private_runtime_data_touched"
    case unsafeRemoteObjectRequest = "unsafe_remote_object_request"
    case unsafeRemoteEndpoint = "unsafe_remote_endpoint"
    case unsafeR2ObjectKey = "unsafe_r2_object_key"
    case unsafeR2QueryShape = "unsafe_r2_query_shape"
    case unsafeURLRequestMethod = "unsafe_url_request_method"
    case unsafeURLRequestHeader = "unsafe_url_request_header"
    case privateEgressFinding = "private_egress_finding"
    case manifestNotVerified = "manifest_not_verified"
    case freshnessBlocksCurrentUse = "freshness_blocks_current_use"
    case cacheCannotSupportCurrentUse = "cache_cannot_support_current_use"
    case lastKnownGoodCannotUse = "last_known_good_cannot_use"
    case projectionBlocksCurrentUse = "projection_blocks_current_use"
    case projectionNotPublicReferenceOnly = "projection_not_public_reference_only"
}

struct SourceAtlasPublicOnlyBoundaryDecision: Codable, Sendable, Equatable, Hashable {
    let surface: SourceAtlasPublicOnlyBoundarySurface
    let issues: [SourceAtlasPublicOnlyBoundaryIssue]
    let firewallVerdict: PublicOnlyFirewallVerdict?
    let egressFindings: [SourceAtlasNoPrivateGraphEgressFinding]

    var isAllowed: Bool {
        issues.isEmpty &&
            egressFindings.isEmpty &&
            (firewallVerdict?.isAllowed ?? true)
    }
}

enum SourceAtlasPublicOnlyBoundaryGateError: Error, Sendable, Equatable {
    case denied(SourceAtlasPublicOnlyBoundaryDecision)
}

struct SourceAtlasPublicOnlyBoundaryGate: Sendable, Equatable, Hashable {
    private let firewall: PublicOnlyFirewall

    init(firewall: PublicOnlyFirewall = PublicOnlyFirewall()) {
        self.firewall = firewall
    }

    func evaluatePublicPackRequest(
        manifestRequest: SourceAtlasPublicManifestRequest,
        packRequest: SourceAtlasPublicPackRequest?,
        accessDecision: SourceAtlasAccessDecision,
        additionalRecords: [SourceAtlasNoPrivateGraphEgressRecord] = []
    ) -> SourceAtlasPublicOnlyBoundaryDecision {
        let verdict = firewall.validate(
            manifestRequest: manifestRequest,
            packRequest: packRequest,
            accessDecision: accessDecision,
            additionalRecords: additionalRecords
        )
        var issues: Set<SourceAtlasPublicOnlyBoundaryIssue> = []

        if verdict.isAllowed == false {
            issues.insert(.firewallRejected)
        }
        if verdict.permitsRemotePublicReference == false {
            issues.insert(.remoteReferenceNotPermitted)
        }
        if accessDecision.privateRuntimeDataTouched {
            issues.insert(.privateRuntimeDataTouched)
        }
        if verdict.egressFindings.isEmpty == false {
            issues.insert(.privateEgressFinding)
        }

        return decision(
            surface: .requestCompilation,
            issues: issues,
            firewallVerdict: verdict,
            egressFindings: verdict.egressFindings
        )
    }

    func evaluateRemoteObjectRequest(
        _ request: SourceAtlasPublicPackRemoteObjectRequest,
        manifestRequest: SourceAtlasPublicManifestRequest,
        accessDecision: SourceAtlasAccessDecision
    ) -> SourceAtlasPublicOnlyBoundaryDecision {
        let verdict = firewall.validate(
            manifestRequest: manifestRequest,
            packRequest: nil,
            accessDecision: accessDecision,
            additionalRecords: [request.egressRecord]
        )
        var issues: Set<SourceAtlasPublicOnlyBoundaryIssue> = []

        if request.validationIssues.isEmpty == false {
            issues.insert(.unsafeRemoteObjectRequest)
        }
        if request.validationIssues.contains(.privateObjectKey) {
            issues.insert(.unsafeR2ObjectKey)
        }
        if verdict.isAllowed == false {
            issues.insert(.firewallRejected)
        }
        if verdict.egressFindings.isEmpty == false {
            issues.insert(.privateEgressFinding)
        }

        return decision(
            surface: .remoteObjectRequest,
            issues: issues,
            firewallVerdict: verdict,
            egressFindings: verdict.egressFindings
        )
    }

    func evaluateRemoteObjectRequest(
        _ request: SourceAtlasPublicPackRemoteObjectRequest
    ) -> SourceAtlasPublicOnlyBoundaryDecision {
        let findings = SourceAtlasNoPrivateGraphEgressAudit.validate([request.egressRecord])
        var issues: Set<SourceAtlasPublicOnlyBoundaryIssue> = []

        if request.validationIssues.isEmpty == false {
            issues.insert(.unsafeRemoteObjectRequest)
        }
        if request.validationIssues.contains(.privateObjectKey) {
            issues.insert(.unsafeR2ObjectKey)
        }
        if findings.isEmpty == false {
            issues.insert(.privateEgressFinding)
        }

        return decision(
            surface: .remoteObjectRequest,
            issues: issues,
            egressFindings: findings
        )
    }

    func evaluateRemoteEndpoint(
        _ endpoint: SourceAtlasPublicPackRemoteEndpoint
    ) -> SourceAtlasPublicOnlyBoundaryDecision {
        let record = SourceAtlasNoPrivateGraphEgressRecord(
            surface: .requestShape,
            identifier: "source-atlas-public-r2-endpoint",
            inspectedValue: endpoint.baseURLString
        )
        let findings = SourceAtlasNoPrivateGraphEgressAudit.validate([record])
        var issues: Set<SourceAtlasPublicOnlyBoundaryIssue> = []

        if endpoint.validationIssues.isEmpty == false {
            issues.insert(.unsafeRemoteEndpoint)
        }
        if findings.isEmpty == false {
            issues.insert(.privateEgressFinding)
        }

        return decision(
            surface: .remoteEndpoint,
            issues: issues,
            egressFindings: findings
        )
    }

    func evaluateR2GatewayRequest(
        kind: R2GatewayRequestKind,
        objectKey: String,
        manifestRequest: SourceAtlasPublicManifestRequest,
        packRequest: SourceAtlasPublicPackRequest?,
        accessDecision: SourceAtlasAccessDecision
    ) -> SourceAtlasPublicOnlyBoundaryDecision {
        let objectRecord = SourceAtlasNoPrivateGraphEgressRecord(
            surface: .objectKey,
            identifier: "source-atlas-r2-\(kind.rawValue)-object-key",
            inspectedValue: objectKey
        )
        let verdict = firewall.validate(
            manifestRequest: manifestRequest,
            packRequest: packRequest,
            accessDecision: accessDecision,
            additionalRecords: [objectRecord]
        )
        var issues: Set<SourceAtlasPublicOnlyBoundaryIssue> = []

        if objectKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            SourceAtlasNoPrivateGraphEgressAudit.validate([objectRecord]).isEmpty == false {
            issues.insert(.unsafeR2ObjectKey)
        }
        if verdict.isAllowed == false {
            issues.insert(.firewallRejected)
        }
        if verdict.egressFindings.isEmpty == false {
            issues.insert(.privateEgressFinding)
        }

        return decision(
            surface: .r2GatewayRequest,
            issues: issues,
            firewallVerdict: verdict,
            egressFindings: verdict.egressFindings
        )
    }

    func evaluateCompiledR2GatewayRequest(
        _ request: R2GatewayCompiledRequest
    ) -> SourceAtlasPublicOnlyBoundaryDecision {
        let records = [
            SourceAtlasNoPrivateGraphEgressRecord(
                surface: .objectKey,
                identifier: "source-atlas-r2-compiled-object-key",
                inspectedValue: request.objectKey
            ),
            SourceAtlasNoPrivateGraphEgressRecord(
                surface: .requestShape,
                identifier: "source-atlas-r2-compiled-url",
                inspectedValue: request.url.absoluteString
            ),
            SourceAtlasNoPrivateGraphEgressRecord(
                surface: .requestShape,
                identifier: "source-atlas-r2-compiled-query",
                inspectedValue: serialized(request.queryItems)
            ),
        ]
        let findings = SourceAtlasNoPrivateGraphEgressAudit.validate(records)
        var issues: Set<SourceAtlasPublicOnlyBoundaryIssue> = []

        if request.firewallVerdict.isAllowed == false {
            issues.insert(.firewallRejected)
        }
        if findings.isEmpty == false {
            issues.insert(.unsafeR2QueryShape)
            issues.insert(.privateEgressFinding)
        }

        return decision(
            surface: .r2GatewayRequest,
            issues: issues,
            firewallVerdict: request.firewallVerdict,
            egressFindings: orderedUniqueFindings(request.firewallVerdict.egressFindings + findings)
        )
    }

    func evaluateURLRequest(_ request: URLRequest) -> SourceAtlasPublicOnlyBoundaryDecision {
        let headerFields = request.allHTTPHeaderFields ?? [:]
        let headerRecord = SourceAtlasNoPrivateGraphEgressRecord(
            surface: .requestShape,
            identifier: "source-atlas-r2-url-request-headers",
            inspectedValue: serialized(headerFields)
        )
        let findings = SourceAtlasNoPrivateGraphEgressAudit.validate([headerRecord])
        var issues: Set<SourceAtlasPublicOnlyBoundaryIssue> = []

        if request.httpMethod != "GET" {
            issues.insert(.unsafeURLRequestMethod)
        }
        if headerFields["X-Ambitions-Data-Class"] != "public-reference" {
            issues.insert(.unsafeURLRequestHeader)
        }
        if headerFields.keys.contains(where: { key in
            ["authorization", "cookie", "x-user-id", "x-account-secret"].contains(key.lowercased())
        }) {
            issues.insert(.unsafeURLRequestHeader)
        }
        if findings.isEmpty == false {
            issues.insert(.privateEgressFinding)
        }

        return decision(
            surface: .r2URLRequest,
            issues: issues,
            egressFindings: findings
        )
    }

    func evaluateManifestCacheRollbackEvidence(
        verification: ManifestVerificationResult?,
        freshness: FreshnessEngineVerdict?,
        cacheResolution: PublicPackCacheResolution?,
        lastKnownGood: LastKnownGoodSelection?
    ) -> SourceAtlasPublicOnlyBoundaryDecision {
        var issues: Set<SourceAtlasPublicOnlyBoundaryIssue> = []

        if verification?.isVerified == false {
            issues.insert(.manifestNotVerified)
        }
        if freshness?.blocksCurrentUse == true {
            issues.insert(.freshnessBlocksCurrentUse)
        }
        if cacheResolution?.canSupportCurrentUse == false {
            issues.insert(.cacheCannotSupportCurrentUse)
        }
        if let lastKnownGood, lastKnownGood.canUse == false {
            issues.insert(.lastKnownGoodCannotUse)
        }

        return decision(
            surface: .manifestCacheRollback,
            issues: issues,
            egressFindings: []
        )
    }

    func evaluateSourceAtlasProjection(
        _ projection: SourceAtlasProjectionRecord
    ) -> SourceAtlasPublicOnlyBoundaryDecision {
        var issues: Set<SourceAtlasPublicOnlyBoundaryIssue> = []

        if projection.blocksCurrentUse {
            issues.insert(.projectionBlocksCurrentUse)
        }
        let records = [
            SourceAtlasNoPrivateGraphEgressRecord(
                surface: .inspectionDetail,
                identifier: "source-atlas-projection-pack-id",
                inspectedValue: projection.packID
            ),
            SourceAtlasNoPrivateGraphEgressRecord(
                surface: .inspectionDetail,
                identifier: "source-atlas-projection-proof-ids",
                inspectedValue: projection.proofEntryIDs.joined(separator: " ")
            ),
            SourceAtlasNoPrivateGraphEgressRecord(
                surface: .inspectionDetail,
                identifier: "source-atlas-projection-provenance-ids",
                inspectedValue: projection.provenanceSourceIDs.joined(separator: " ")
            ),
        ]
        let findings = SourceAtlasNoPrivateGraphEgressAudit.validate(records)
        if findings.isEmpty == false {
            issues.insert(.projectionNotPublicReferenceOnly)
            issues.insert(.privateEgressFinding)
        }

        return decision(
            surface: .sourceAtlasProjection,
            issues: issues,
            egressFindings: findings
        )
    }

    func requireAllowed(_ decision: SourceAtlasPublicOnlyBoundaryDecision) throws {
        guard decision.isAllowed else {
            throw SourceAtlasPublicOnlyBoundaryGateError.denied(decision)
        }
    }

    private func decision(
        surface: SourceAtlasPublicOnlyBoundarySurface,
        issues: Set<SourceAtlasPublicOnlyBoundaryIssue>,
        firewallVerdict: PublicOnlyFirewallVerdict? = nil,
        egressFindings: [SourceAtlasNoPrivateGraphEgressFinding]
    ) -> SourceAtlasPublicOnlyBoundaryDecision {
        SourceAtlasPublicOnlyBoundaryDecision(
            surface: surface,
            issues: SourceAtlasPublicOnlyBoundaryIssue.allCases.filter { issues.contains($0) },
            firewallVerdict: firewallVerdict,
            egressFindings: orderedUniqueFindings(egressFindings)
        )
    }

    private func serialized(_ values: [String: String]) -> String {
        values
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: " ")
    }

    private func orderedUniqueFindings(
        _ findings: [SourceAtlasNoPrivateGraphEgressFinding]
    ) -> [SourceAtlasNoPrivateGraphEgressFinding] {
        var seen: Set<SourceAtlasNoPrivateGraphEgressFinding> = []
        return findings.filter { seen.insert($0).inserted }
    }
}
