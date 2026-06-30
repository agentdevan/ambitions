import Foundation

enum PrivacySecurityReceiptAction: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case networkEgress = "network_egress"
    case export
    case localAuth = "local_auth"
    case encryptedVault = "encrypted_vault"
}

struct PrivacySecurityReceipt: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let action: PrivacySecurityReceiptAction
    let objectID: String
    let surface: SensitiveSurface?
    let permitted: Bool
    let redactionApplied: Bool
    let localOnlyInspectionPath: String
    let issueCodes: [String]
    let summary: String
}

struct PrivacyEgressAttempt: Codable, Sendable, Equatable, Hashable {
    let id: String
    let destination: NetworkEgressDestination
    let purpose: NetworkEgressPurpose
    let redactionRequest: PrivacyRedactionRequest

    init(
        id: String,
        destination: NetworkEgressDestination,
        purpose: NetworkEgressPurpose,
        redactionRequest: PrivacyRedactionRequest
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.destination = destination
        self.purpose = purpose
        self.redactionRequest = redactionRequest
    }
}

struct PrivacyEgressDecision: Codable, Sendable, Equatable, Hashable {
    let attemptID: String
    let permitted: Bool
    let redaction: PrivacyRedactionResult
    let networkDecision: NetworkEgressDecision
    let receipt: PrivacySecurityReceipt
}

struct EgressFirewall: Sendable, Equatable {
    let redactionEngine: RedactionEngine
    let networkPolicy: NetworkEgressPolicy

    init(
        redactionEngine: RedactionEngine = RedactionEngine(),
        networkPolicy: NetworkEgressPolicy = NetworkEgressPolicy()
    ) {
        self.redactionEngine = redactionEngine
        self.networkPolicy = networkPolicy
    }

    func evaluate(_ attempt: PrivacyEgressAttempt) -> PrivacyEgressDecision {
        let redaction = redactionEngine.redact(attempt.redactionRequest)
        let networkRequest = NetworkEgressRequest(
            destination: attempt.destination,
            purpose: attempt.purpose,
            payloadClass: payloadClass(for: attempt.destination, redaction: redaction),
            surface: .requestShape,
            identifier: attempt.id,
            inspectedValue: redaction.egressRecord.inspectedValue
        )
        let networkDecision = networkPolicy.evaluate(networkRequest)
        let surfaceIssues = redaction.decision.issues.map(\.rawValue)
        let issueCodes = orderedUnique(surfaceIssues + networkDecision.issues.map(\.rawValue))
        let permitted = redaction.decision.allowed &&
            networkDecision.permitted &&
            redaction.containsRawPrivatePayload == false &&
            publicReferenceBoundarySatisfied(destination: attempt.destination, object: attempt.redactionRequest.object)

        return PrivacyEgressDecision(
            attemptID: attempt.id,
            permitted: permitted,
            redaction: redaction,
            networkDecision: networkDecision,
            receipt: PrivacySecurityReceipt(
                id: "privacy_receipt.egress.\(attempt.id)",
                action: .networkEgress,
                objectID: attempt.redactionRequest.object.id,
                surface: attempt.redactionRequest.surface,
                permitted: permitted,
                redactionApplied: redaction.redactionApplied,
                localOnlyInspectionPath: redaction.localOnlyInspectionPath,
                issueCodes: issueCodes,
                summary: summary(permitted: permitted, destination: attempt.destination, issues: issueCodes)
            )
        )
    }

    private func payloadClass(
        for destination: NetworkEgressDestination,
        redaction: PrivacyRedactionResult
    ) -> NetworkEgressPayloadClass {
        switch destination {
        case .sourceAtlasPublicReference, .r2PublicReference:
            return redaction.privacyClass.canEnterPublicReferencePack ? .publicReference : .privateLifeGraph
        case .accountIdentity:
            return .accountCredential
        case .diagnostics:
            return redaction.containsRawPrivatePayload ? .privateRuntimeData : .diagnosticMetadata
        case .cloudKitContinuity, .hostedPrivateLifeGraph:
            return .privateLifeGraph
        case .remoteIntelligenceBackend, .externalCloudLLM:
            return .privateRuntimeData
        }
    }

    private func publicReferenceBoundarySatisfied(
        destination: NetworkEgressDestination,
        object: PrivacyClassifiedObject
    ) -> Bool {
        switch destination {
        case .sourceAtlasPublicReference, .r2PublicReference:
            return object.privacyClass.canEnterPublicReferencePack
        case .accountIdentity, .cloudKitContinuity, .hostedPrivateLifeGraph, .remoteIntelligenceBackend, .externalCloudLLM, .diagnostics:
            return true
        }
    }

    private func orderedUnique(_ values: [String]) -> [String] {
        var seen = Set<String>()
        return values.filter { seen.insert($0).inserted }
    }

    private func summary(
        permitted: Bool,
        destination: NetworkEgressDestination,
        issues: [String]
    ) -> String {
        if permitted {
            return "Privacy firewall permitted redacted \(destination.rawValue) egress."
        }
        if issues.isEmpty {
            return "Privacy firewall denied \(destination.rawValue) egress because the request is not eligible for that boundary."
        }
        return "Privacy firewall denied \(destination.rawValue) egress: \(issues.joined(separator: ", "))."
    }
}
