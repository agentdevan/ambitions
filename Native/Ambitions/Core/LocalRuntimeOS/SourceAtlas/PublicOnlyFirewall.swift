import Foundation

enum PublicOnlyFirewallIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsafeManifestRequest = "unsafe_manifest_request"
    case unsafePackRequest = "unsafe_pack_request"
    case privateEgressFinding = "private_egress_finding"
    case privateRuntimeDataTouched = "private_runtime_data_touched"
    case coreLocalPlanningBlocked = "core_local_planning_blocked"
    case remoteRouteNotPermitted = "remote_route_not_permitted"
}

struct PublicOnlyFirewallVerdict: Codable, Sendable, Equatable, Hashable {
    let issues: [PublicOnlyFirewallIssue]
    let manifestRequestIssues: [SourceAtlasPublicManifestRequestIssue]
    let packRequestIssues: [SourceAtlasPublicPackRequestIssue]
    let egressFindings: [SourceAtlasNoPrivateGraphEgressFinding]
    let permitsRemotePublicReference: Bool

    var isAllowed: Bool {
        issues.isEmpty &&
            manifestRequestIssues.isEmpty &&
            packRequestIssues.isEmpty &&
            egressFindings.isEmpty &&
            permitsRemotePublicReference
    }
}

struct PublicOnlyFirewall: Sendable, Equatable, Hashable {
    func validate(
        manifestRequest: SourceAtlasPublicManifestRequest,
        packRequest: SourceAtlasPublicPackRequest?,
        accessDecision: SourceAtlasAccessDecision,
        additionalRecords: [SourceAtlasNoPrivateGraphEgressRecord] = []
    ) -> PublicOnlyFirewallVerdict {
        let manifestIssues = SourceAtlasPublicManifestRequestValidator().validate(manifestRequest)
        let packIssues = packRequest.map { SourceAtlasPublicPackRequestValidator().validate($0) } ?? []
        let records = [manifestRequest.egressRecord] +
            (packRequest.map { [egressRecord(for: $0)] } ?? []) +
            additionalRecords
        let findings = SourceAtlasNoPrivateGraphEgressAudit.validate(records)

        var issues: Set<PublicOnlyFirewallIssue> = []
        if manifestIssues.isEmpty == false {
            issues.insert(.unsafeManifestRequest)
        }
        if packIssues.isEmpty == false {
            issues.insert(.unsafePackRequest)
        }
        if findings.isEmpty == false {
            issues.insert(.privateEgressFinding)
        }
        if accessDecision.privateRuntimeDataTouched {
            issues.insert(.privateRuntimeDataTouched)
        }
        if accessDecision.coreLocalPlanningBlocked {
            issues.insert(.coreLocalPlanningBlocked)
        }
        if accessDecision.permitsRemotePublicReference == false {
            issues.insert(.remoteRouteNotPermitted)
        }

        return PublicOnlyFirewallVerdict(
            issues: PublicOnlyFirewallIssue.allCases.filter { issues.contains($0) },
            manifestRequestIssues: manifestIssues,
            packRequestIssues: packIssues,
            egressFindings: findings,
            permitsRemotePublicReference: accessDecision.permitsRemotePublicReference
        )
    }

    func egressRecord(for request: SourceAtlasPublicPackRequest) -> SourceAtlasNoPrivateGraphEgressRecord {
        var values = request.queryItems
        values["route"] = request.routePath
        values["pack_id"] = request.packID
        values["manifest_version"] = request.manifestVersionID
        values["declared_sha256"] = request.declaredSHA256
        if let channel = request.channel {
            values["channel"] = channel
        }
        if let artifactVersionID = request.artifactVersionID {
            values["artifact_version"] = artifactVersionID
        }
        if let sourceState = request.sourceState {
            values["source_state"] = sourceState.rawValue
        }
        if let freshnessState = request.freshnessState {
            values["freshness_state"] = freshnessState.rawValue
        }
        if let publicJurisdiction = request.publicJurisdiction {
            values["public_jurisdiction"] = publicJurisdiction
        }
        if let publicLocale = request.publicLocale {
            values["public_locale"] = publicLocale
        }

        return SourceAtlasNoPrivateGraphEgressRecord(
            surface: .requestShape,
            identifier: "source-atlas-pack-request",
            inspectedValue: values
                .sorted { $0.key < $1.key }
                .map { "\($0.key)=\($0.value)" }
                .joined(separator: " ")
        )
    }
}
