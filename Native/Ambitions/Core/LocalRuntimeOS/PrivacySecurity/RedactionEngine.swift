import Foundation

struct PrivacyRedactionRequest: Codable, Sendable, Equatable, Hashable {
    let object: PrivacyClassifiedObject
    let surface: SensitiveSurface
    let title: String
    let summary: String
    let metadata: [String: String]
    let payload: [String: String]
    let userReviewed: Bool
    let localAuthenticationSatisfied: Bool

    init(
        object: PrivacyClassifiedObject,
        surface: SensitiveSurface,
        title: String,
        summary: String,
        metadata: [String: String] = [:],
        payload: [String: String] = [:],
        userReviewed: Bool = false,
        localAuthenticationSatisfied: Bool = false
    ) {
        self.object = object
        self.surface = surface
        self.title = title
        self.summary = summary
        self.metadata = metadata
        self.payload = payload
        self.userReviewed = userReviewed
        self.localAuthenticationSatisfied = localAuthenticationSatisfied
    }
}

struct PrivacyRedactionResult: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let surface: SensitiveSurface
    let privacyClass: RuntimePrivacyClass
    let visibleTitle: String
    let visibleSummary: String
    let metadataKeys: [String]
    let payloadKeys: [String]
    let redactionApplied: Bool
    let localOnlyInspectionPath: String
    let decision: SensitiveSurfaceDecision
    let egressRecord: SourceAtlasNoPrivateGraphEgressRecord

    var containsRawPrivatePayload: Bool {
        redactionApplied == false && privacyClass.requiresRedaction
    }
}

struct RedactionEngine: Sendable, Equatable, Hashable {
    let surfacePolicy: SensitiveSurfacePolicy

    init(surfacePolicy: SensitiveSurfacePolicy = SensitiveSurfacePolicy()) {
        self.surfacePolicy = surfacePolicy
    }

    func redact(_ request: PrivacyRedactionRequest) -> PrivacyRedactionResult {
        let decision = surfacePolicy.decision(
            for: request.object,
            surface: request.surface,
            userReviewed: request.userReviewed,
            localAuthenticationSatisfied: request.localAuthenticationSatisfied
        )
        let shouldRedact = decision.requiresRedaction
        let visibleTitle = shouldRedact ? title(for: request.object.privacyClass) : request.title
        let visibleSummary = shouldRedact ? summary(for: request.surface) : request.summary
        let egressValue = [
            "surface=\(request.surface.rawValue)",
            "object_id=\(request.object.id)",
            "privacy=\(request.object.privacyClass.rawValue)",
            "title=\(visibleTitle)",
            "summary=\(visibleSummary)",
            "metadata_keys=\(request.metadata.keys.sorted().joined(separator: ","))",
            "payload_keys=\(request.payload.keys.sorted().joined(separator: ","))"
        ].joined(separator: " ")

        return PrivacyRedactionResult(
            id: "\(request.object.id).\(request.surface.rawValue).redaction",
            surface: request.surface,
            privacyClass: request.object.privacyClass,
            visibleTitle: visibleTitle,
            visibleSummary: visibleSummary,
            metadataKeys: request.metadata.keys.sorted(),
            payloadKeys: request.payload.keys.sorted(),
            redactionApplied: shouldRedact,
            localOnlyInspectionPath: "You / Privacy / \(request.object.family) / \(request.object.id)",
            decision: decision,
            egressRecord: SourceAtlasNoPrivateGraphEgressRecord(
                surface: .inspectionDetail,
                identifier: "\(request.object.id).\(request.surface.rawValue)",
                inspectedValue: egressValue
            )
        )
    }

    private func title(for privacyClass: RuntimePrivacyClass) -> String {
        switch privacyClass {
        case .publicMetadata:
            return "Public metadata"
        case .systemOwned:
            return "System-owned setting"
        case .standard:
            return "Local item"
        case .sensitive:
            return "Sensitive local item"
        case .privateUserText, .privateSensitive:
            return "Private life item"
        case .localOnly:
            return "Local-only private item"
        case .proofRestricted:
            return "Private proof item"
        case .replayRestricted:
            return "Private replay item"
        case .lineageRestricted:
            return "Private lineage item"
        case .calendarDerived:
            return "Calendar-derived private item"
        case .syncMetadata:
            return "Sync metadata"
        }
    }

    private func summary(for surface: SensitiveSurface) -> String {
        switch surface {
        case .notificationContent:
            return "Details hidden. Open Ambitions to inspect locally."
        case .widgetSnapshot:
            return "Private details hidden in this external snapshot."
        case .shareExtensionPayload:
            return "Private details stay in Ambitions until reviewed."
        case .appIntentOutput:
            return "Private details hidden from App Intent output."
        case .diagnosticsExport:
            return "Diagnostic details redacted; inspect locally for full context."
        case .portableExport:
            return "Export review required before private details are included."
        case .sourceAtlasPublicReference:
            return "Private details cannot enter public reference material."
        case .searchIndex:
            return "Private details excluded from local search indexing."
        case .localInspection, .encryptedVault:
            return "Private details remain local."
        }
    }
}
