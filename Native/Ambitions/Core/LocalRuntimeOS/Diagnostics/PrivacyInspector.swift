import Foundation

struct PrivacyInspector: Sendable, Equatable, Hashable {
    func inspect(
        objects: [PrivacyClassifiedObject],
        diagnosticRecords: [LocalRuntimeDiagnosticRecord] = [],
        generatedAt: String
    ) -> [LocalRuntimeDiagnosticRecord] {
        var diagnostics: [LocalRuntimeDiagnosticRecord] = [
            LocalRuntimeDiagnosticRecord(
                id: "privacy.summary",
                area: .privacy,
                componentID: "PrivacyInspector",
                severity: objects.isEmpty ? .notice : .healthy,
                summary: objects.isEmpty ? "No privacy-classified runtime objects supplied." : "Inspected \(objects.count) privacy-classified runtime objects.",
                detail: "Privacy diagnostics check redaction requirements, public-pack eligibility, and local-auth-sensitive classes without exporting private values.",
                repairHint: "Classify runtime objects before they enter diagnostics, export, widgets, or public-reference paths.",
                generatedAt: generatedAt
            )
        ]

        for object in objects.sorted(by: { $0.id < $1.id }) {
            let fingerprint = LocalRuntimeDiagnosticsRedactor.fingerprint(object.id)
            if object.containsUserText && object.privacyClass.requiresRedaction == false {
                diagnostics.append(LocalRuntimeDiagnosticRecord(
                    id: "privacy.unredacted_user_text.\(fingerprint)",
                    area: .privacy,
                    componentID: "PrivacyInspector",
                    severity: .critical,
                    summary: "Object with user text does not require redaction.",
                    detail: "Object \(fingerprint) in family \(object.family) is marked \(object.privacyClass.rawValue) while containing user text.",
                    repairHint: "Reclassify the object as private user text, private sensitive, proof restricted, or local-only before diagnostics/export.",
                    evidenceIDs: [object.id],
                    privacy: object.privacyClass,
                    generatedAt: generatedAt
                ))
            }

            if object.privacyClass.canEnterPublicReferencePack, object.containsUserText {
                diagnostics.append(LocalRuntimeDiagnosticRecord(
                    id: "privacy.public_pack_user_text.\(fingerprint)",
                    area: .privacy,
                    componentID: "PrivacyInspector",
                    severity: .critical,
                    summary: "User text is eligible for public-reference pack entry.",
                    detail: "Object \(fingerprint) is public-pack eligible but contains user text.",
                    repairHint: "Block this object from Source Atlas/public-reference paths and reclassify it as private runtime data.",
                    evidenceIDs: [object.id],
                    privacy: object.privacyClass,
                    generatedAt: generatedAt
                ))
            }

            if object.privacyClass.requiresLocalAuthentication {
                diagnostics.append(LocalRuntimeDiagnosticRecord(
                    id: "privacy.local_auth.\(fingerprint)",
                    area: .privacy,
                    componentID: "PrivacyInspector",
                    severity: .notice,
                    summary: "Object requires local authentication before sensitive inspection.",
                    detail: "Object \(fingerprint) uses privacy class \(object.privacyClass.rawValue).",
                    repairHint: "Gate direct detail inspection with LocalAuthGate; keep diagnostics redacted.",
                    evidenceIDs: [object.id],
                    privacy: object.privacyClass,
                    generatedAt: generatedAt
                ))
            }
        }

        for record in diagnosticRecords where LocalRuntimeDiagnosticsRedactor.containsLikelyPrivateMaterial(record.redactedDetail) {
            diagnostics.append(LocalRuntimeDiagnosticRecord(
                id: "privacy.diagnostic_redaction.\(record.id)",
                area: .privacy,
                componentID: "PrivacyInspector",
                severity: .critical,
                summary: "Diagnostic record contains likely private material after redaction.",
                detail: "Diagnostic \(record.id) still contains likely private material.",
                repairHint: "Regenerate diagnostics through LocalRuntimeDiagnosticsRedactor before surfacing or exporting.",
                evidenceIDs: [record.id],
                privacy: .privateSensitive,
                generatedAt: generatedAt
            ))
        }

        return diagnostics.sorted { $0.id < $1.id }
    }
}
