import Foundation

enum SensitiveSurface: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case localInspection = "local_inspection"
    case widgetSnapshot = "widget_snapshot"
    case shareExtensionPayload = "share_extension_payload"
    case notificationContent = "notification_content"
    case appIntentOutput = "app_intent_output"
    case diagnosticsExport = "diagnostics_export"
    case portableExport = "portable_export"
    case sourceAtlasPublicReference = "source_atlas_public_reference"
    case searchIndex = "search_index"
    case encryptedVault = "encrypted_vault"

    var canExposePrivateDetails: Bool {
        switch self {
        case .localInspection, .encryptedVault:
            return true
        case .widgetSnapshot, .shareExtensionPayload, .notificationContent, .appIntentOutput, .diagnosticsExport, .portableExport, .sourceAtlasPublicReference, .searchIndex:
            return false
        }
    }

    var leavesAppProcess: Bool {
        switch self {
        case .widgetSnapshot, .shareExtensionPayload, .notificationContent, .appIntentOutput, .diagnosticsExport, .portableExport, .sourceAtlasPublicReference:
            return true
        case .localInspection, .searchIndex, .encryptedVault:
            return false
        }
    }
}

enum SensitiveSurfaceIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case redactionRequired = "redaction_required"
    case reviewRequired = "review_required"
    case localAuthenticationRequired = "local_authentication_required"
    case publicReferenceForbidden = "public_reference_forbidden"
    case indexingForbidden = "indexing_forbidden"
    case privateGraphEgressForbidden = "private_graph_egress_forbidden"
}

struct SensitiveSurfaceDecision: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let surface: SensitiveSurface
    let privacyClass: RuntimePrivacyClass
    let allowed: Bool
    let requiresRedaction: Bool
    let requiresUserReview: Bool
    let requiresLocalAuthentication: Bool
    let issues: [SensitiveSurfaceIssue]
    let explanation: String
}

struct SensitiveSurfacePolicy: Sendable, Equatable, Hashable {
    func decision(
        for object: PrivacyClassifiedObject,
        surface: SensitiveSurface,
        userReviewed: Bool = false,
        localAuthenticationSatisfied: Bool = false
    ) -> SensitiveSurfaceDecision {
        var issues: [SensitiveSurfaceIssue] = []
        let requiresRedaction = object.privacyClass.requiresRedaction && surface.canExposePrivateDetails == false
        let requiresReview = object.privacyClass.canLeaveDeviceWithoutReview == false && surface.leavesAppProcess
        let requiresAuth = object.privacyClass.requiresLocalAuthentication && surface == .localInspection

        if requiresRedaction {
            issues.append(.redactionRequired)
        }
        if requiresReview && userReviewed == false {
            issues.append(.reviewRequired)
        }
        if requiresAuth && localAuthenticationSatisfied == false {
            issues.append(.localAuthenticationRequired)
        }
        if surface == .sourceAtlasPublicReference && object.privacyClass.canEnterPublicReferencePack == false {
            issues.append(.publicReferenceForbidden)
        }
        if surface == .searchIndex && object.storagePrivacy.requiresRedaction {
            issues.append(.indexingForbidden)
        }
        let normalizedIssues = orderedUnique(issues)
        let allowed = normalizedIssues.allSatisfy { issue in
            switch issue {
            case .redactionRequired:
                return true
            case .reviewRequired, .localAuthenticationRequired, .publicReferenceForbidden, .indexingForbidden, .privateGraphEgressForbidden:
                return false
            }
        }

        return SensitiveSurfaceDecision(
            id: "\(object.id).\(surface.rawValue)",
            surface: surface,
            privacyClass: object.privacyClass,
            allowed: allowed,
            requiresRedaction: requiresRedaction,
            requiresUserReview: requiresReview,
            requiresLocalAuthentication: requiresAuth,
            issues: normalizedIssues,
            explanation: explanation(surface: surface, object: object, issues: normalizedIssues)
        )
    }

    private func orderedUnique(_ values: [SensitiveSurfaceIssue]) -> [SensitiveSurfaceIssue] {
        var seen = Set<SensitiveSurfaceIssue>()
        return values.filter { seen.insert($0).inserted }
    }

    private func explanation(
        surface: SensitiveSurface,
        object: PrivacyClassifiedObject,
        issues: [SensitiveSurfaceIssue]
    ) -> String {
        if issues.isEmpty {
            return "\(surface.rawValue) may use \(object.privacyClass.rawValue) data under the current local privacy policy."
        }
        return "\(surface.rawValue) is constrained for \(object.privacyClass.rawValue): \(issues.map(\.rawValue).joined(separator: ", "))."
    }
}
