import Foundation

struct RuntimeDoctorRepairProof: Identifiable, Codable, Sendable, Equatable, Hashable {
    let id: String
    let stage: RuntimeDoctorRepairProofStage
    let evidenceIDs: [String]
    let redactedSummary: String

    init(
        id: String,
        stage: RuntimeDoctorRepairProofStage,
        evidenceIDs: [String],
        summary: String,
        privacy: RuntimePrivacyClass
    ) {
        self.id = id
        self.stage = stage
        self.evidenceIDs = Array(Set(evidenceIDs.map(LocalRuntimeDiagnosticsRedactor.fingerprint).filter { $0.isEmpty == false })).sorted()
        self.redactedSummary = LocalRuntimeDiagnosticsRedactor.redact(summary, privacy: privacy)
    }
}

struct RuntimeDoctorRepairReceipt: Identifiable, Codable, Sendable, Equatable, Hashable {
    let id: String
    let schemaVersion: String
    let createdAt: String
    let domain: RuntimeDoctorHealthDomain
    let action: RuntimeDoctorRepairActionKind
    let sourceRecordID: String
    let receiptID: String
    let replayTraceID: String
    let beforeEvidenceIDs: [String]
    let expectedAfterEvidenceIDs: [String]
    let localOnly: Bool
    let privatePayloadIncluded: Bool
    let executionAllowed: Bool
    let destructiveResetAllowed: Bool
}

struct RuntimeDoctorRepairPlan: Identifiable, Codable, Sendable, Equatable, Hashable {
    let id: String
    let domain: RuntimeDoctorHealthDomain
    let action: RuntimeDoctorRepairActionKind
    let redactedSummary: String
    let previewSteps: [String]
    let beforeProof: RuntimeDoctorRepairProof
    let expectedAfterProof: RuntimeDoctorRepairProof
    let receipt: RuntimeDoctorRepairReceipt
    let localOnly: Bool
    let previewOnly: Bool
    let executionAllowed: Bool
    let requiresUserReview: Bool
    let sourceOwner: String

    var youDiagnosticLine: String {
        "You can review a local repair preview for \(domain.userFacingName): \(redactedSummary) No private details leave this device."
    }
}

struct RuntimeDoctorRepairAssessment: Codable, Sendable, Equatable, Hashable {
    let schemaVersion: String
    let generatedAt: String
    let status: LocalBackendHealthStatus
    let plans: [RuntimeDoctorRepairPlan]
    let driftSignals: [RuntimeDoctorDriftSignal]
    let missingHealthDomains: [RuntimeDoctorHealthDomain]
    let localOnly: Bool
    let releaseHealthClaimed: Bool

    var hasRepairableDrift: Bool {
        plans.isEmpty == false
    }

    var canExecuteRepairs: Bool {
        plans.allSatisfy(\.executionAllowed) && plans.isEmpty == false
    }

    var youDiagnosticLines: [String] {
        plans.map(\.youDiagnosticLine)
    }
}
