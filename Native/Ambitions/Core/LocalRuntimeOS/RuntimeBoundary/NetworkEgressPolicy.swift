import Foundation

enum NetworkEgressDestination: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case sourceAtlasPublicReference = "source_atlas_public_reference"
    case r2PublicReference = "r2_public_reference"
    case accountIdentity = "account_identity"
    case cloudKitContinuity = "cloudkit_continuity"
    case hostedPrivateLifeGraph = "hosted_private_life_graph"
    case remoteIntelligenceBackend = "remote_intelligence_backend"
    case externalCloudLLM = "external_cloud_llm"
    case diagnostics = "diagnostics"
}

enum NetworkEgressPurpose: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case publicReferenceFreshness = "public_reference_freshness"
    case accountAuthentication = "account_authentication"
    case entitlementVerification = "entitlement_verification"
    case continuitySync = "continuity_sync"
    case diagnostics = "diagnostics"
    case privateLifeGraphStorage = "private_life_graph_storage"
    case remoteInference = "remote_inference"
}

enum NetworkEgressPayloadClass: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case none
    case publicReference = "public_reference"
    case accountCredential = "account_credential"
    case privateRuntimeData = "private_runtime_data"
    case privateLifeGraph = "private_life_graph"
    case diagnosticMetadata = "diagnostic_metadata"
}

enum NetworkEgressIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case nonLocalRuntimeBoundary = "non_local_runtime_boundary"
    case hostedPrivateGraphForbidden = "hosted_private_graph_forbidden"
    case remoteIntelligenceForbidden = "remote_intelligence_forbidden"
    case externalCloudLLMForbidden = "external_cloud_llm_forbidden"
    case privateRuntimePayloadForbidden = "private_runtime_payload_forbidden"
    case privateGraphPayloadForbidden = "private_graph_payload_forbidden"
    case publicReferencePayloadRequired = "public_reference_payload_required"
    case privateGraphMarkerDetected = "private_graph_marker_detected"
    case cloudKitContinuityNotEnabled = "cloudkit_continuity_not_enabled"
    case diagnosticsMustBeLocalOrRedacted = "diagnostics_must_be_local_or_redacted"
}

struct NetworkEgressRequest: Codable, Sendable, Equatable, Hashable {
    let destination: NetworkEgressDestination
    let purpose: NetworkEgressPurpose
    let payloadClass: NetworkEgressPayloadClass
    let surface: SourceAtlasNoPrivateGraphEgressSurface
    let identifier: String
    let inspectedValue: String

    init(
        destination: NetworkEgressDestination,
        purpose: NetworkEgressPurpose,
        payloadClass: NetworkEgressPayloadClass,
        surface: SourceAtlasNoPrivateGraphEgressSurface = .requestShape,
        identifier: String,
        inspectedValue: String
    ) {
        self.destination = destination
        self.purpose = purpose
        self.payloadClass = payloadClass
        self.surface = surface
        self.identifier = identifier
        self.inspectedValue = inspectedValue
    }

    var egressRecord: SourceAtlasNoPrivateGraphEgressRecord {
        SourceAtlasNoPrivateGraphEgressRecord(
            surface: surface,
            identifier: identifier,
            inspectedValue: inspectedValue
        )
    }
}

struct NetworkEgressDecision: Codable, Sendable, Equatable, Hashable {
    let permitted: Bool
    let destination: NetworkEgressDestination
    let purpose: NetworkEgressPurpose
    let localCoreBlocked: Bool
    let touchesPrivateLifeGraph: Bool
    let findings: [SourceAtlasNoPrivateGraphEgressFinding]
    let issues: [NetworkEgressIssue]
    let explanation: String
}

struct NetworkEgressPolicy: Sendable, Equatable {
    let runtimeBoundary: PrivateLifeRuntimeBoundary
    let cloudKitContinuityEnabled: Bool

    init(
        runtimeBoundary: PrivateLifeRuntimeBoundary = .localOnly,
        cloudKitContinuityEnabled: Bool = false
    ) {
        self.runtimeBoundary = runtimeBoundary
        self.cloudKitContinuityEnabled = cloudKitContinuityEnabled
    }

    func evaluate(_ request: NetworkEgressRequest) -> NetworkEgressDecision {
        let findings = SourceAtlasNoPrivateGraphEgressAudit.validate([request.egressRecord])
        let issues = Self.orderedUnique(boundaryIssues() + payloadIssues(request, findings: findings) + destinationIssues(request))
        let touchesPrivateLifeGraph = request.payloadClass == .privateLifeGraph ||
            request.payloadClass == .privateRuntimeData ||
            findings.isEmpty == false ||
            request.destination == .hostedPrivateLifeGraph

        return NetworkEgressDecision(
            permitted: issues.isEmpty,
            destination: request.destination,
            purpose: request.purpose,
            localCoreBlocked: false,
            touchesPrivateLifeGraph: touchesPrivateLifeGraph,
            findings: findings,
            issues: issues,
            explanation: explanation(for: request, issues: issues)
        )
    }

    private func boundaryIssues() -> [NetworkEgressIssue] {
        runtimeBoundary.isLocalOnly ? [] : [.nonLocalRuntimeBoundary]
    }

    private func payloadIssues(
        _ request: NetworkEgressRequest,
        findings: [SourceAtlasNoPrivateGraphEgressFinding]
    ) -> [NetworkEgressIssue] {
        var issues: [NetworkEgressIssue] = []
        switch request.payloadClass {
        case .none, .publicReference, .accountCredential, .diagnosticMetadata:
            break
        case .privateRuntimeData:
            issues.append(.privateRuntimePayloadForbidden)
        case .privateLifeGraph:
            issues.append(.privateGraphPayloadForbidden)
        }
        if findings.isEmpty == false {
            issues.append(.privateGraphMarkerDetected)
        }
        return issues
    }

    private func destinationIssues(_ request: NetworkEgressRequest) -> [NetworkEgressIssue] {
        switch request.destination {
        case .sourceAtlasPublicReference, .r2PublicReference:
            return request.payloadClass == .publicReference ? [] : [.publicReferencePayloadRequired]
        case .accountIdentity:
            return request.payloadClass == .accountCredential || request.payloadClass == .none ? [] : [.privateRuntimePayloadForbidden]
        case .cloudKitContinuity:
            return cloudKitContinuityEnabled ? [] : [.cloudKitContinuityNotEnabled]
        case .hostedPrivateLifeGraph:
            return [.hostedPrivateGraphForbidden]
        case .remoteIntelligenceBackend:
            return [.remoteIntelligenceForbidden]
        case .externalCloudLLM:
            return [.externalCloudLLMForbidden]
        case .diagnostics:
            return request.payloadClass == .diagnosticMetadata || request.payloadClass == .none
                ? []
                : [.diagnosticsMustBeLocalOrRedacted]
        }
    }

    private func explanation(
        for request: NetworkEgressRequest,
        issues: [NetworkEgressIssue]
    ) -> String {
        if issues.isEmpty {
            return "Network egress is permitted only for non-private \(request.payloadClass.rawValue) payloads to \(request.destination.rawValue)."
        }
        return "Network egress is denied because \(issues.map(\.rawValue).joined(separator: ", "))."
    }

    private static func orderedUnique(_ values: [NetworkEgressIssue]) -> [NetworkEgressIssue] {
        var seen = Set<NetworkEgressIssue>()
        return values.filter { seen.insert($0).inserted }
    }
}
