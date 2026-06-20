import Foundation

let ambitionsOSLivingDreamPackSupplyChainSecuritySchemaVersion = "ambitionsos_living_dream_pack_supply_chain_security.native.v1"

enum AmbitionsOSLivingDreamPackChecksumAlgorithm: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case sha256

    var acceptedPrefix: String {
        switch self {
        case .sha256:
            return "sha256:"
        }
    }
}

enum AmbitionsOSLivingDreamPackSupplyChainIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case malformedEnvelope = "malformed_envelope"
    case checksumMissing = "checksum_missing"
    case checksumMismatch = "checksum_mismatch"
    case signatureMissing = "signature_missing"
    case signatureUnverified = "signature_unverified"
    case provenanceMissing = "provenance_missing"
    case rollbackMissing = "rollback_missing"
    case rollbackNotReversible = "rollback_not_reversible"
    case safeImportValidationMissing = "safe_import_validation_missing"
    case corruptionHandlingMissing = "corruption_handling_missing"
    case tamperDetectionMissing = "tamper_detection_missing"
    case packDiffIntegrityMissing = "pack_diff_integrity_missing"
    case packManifestIntegrityMissing = "pack_manifest_integrity_missing"
    case executableLogicPresent = "executable_logic_present"
    case runtimeBoundaryBroken = "runtime_boundary_broken"
    case userDataServerBoundaryBroken = "user_data_server_boundary_broken"
    case activationOrMutationForbidden = "activation_or_mutation_forbidden"
    case sourceClaimGraphNotReady = "source_claim_graph_not_ready"
}

struct AmbitionsOSLivingDreamPackChecksumProof: Codable, Sendable, Equatable, Hashable {
    let algorithm: AmbitionsOSLivingDreamPackChecksumAlgorithm
    let expectedChecksum: String
    let observedChecksum: String

    init(
        algorithm: AmbitionsOSLivingDreamPackChecksumAlgorithm = .sha256,
        expectedChecksum: String,
        observedChecksum: String
    ) {
        self.algorithm = algorithm
        self.expectedChecksum = expectedChecksum.trimmingCharacters(in: .whitespacesAndNewlines)
        self.observedChecksum = observedChecksum.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isWellFormed: Bool {
        expectedChecksum.hasPrefix(algorithm.acceptedPrefix) &&
            observedChecksum.hasPrefix(algorithm.acceptedPrefix)
    }

    var matches: Bool {
        isWellFormed && expectedChecksum == observedChecksum
    }
}

struct AmbitionsOSLivingDreamPackSignatureProof: Codable, Sendable, Equatable, Hashable {
    let signedManifestID: String
    let signerID: String
    let signatureVersion: String
    let verifiedLocally: Bool

    init(
        signedManifestID: String,
        signerID: String,
        signatureVersion: String,
        verifiedLocally: Bool
    ) {
        self.signedManifestID = signedManifestID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.signerID = signerID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.signatureVersion = signatureVersion.trimmingCharacters(in: .whitespacesAndNewlines)
        self.verifiedLocally = verifiedLocally
    }

    var isPresent: Bool {
        signedManifestID.isEmpty == false &&
            signerID.isEmpty == false &&
            signatureVersion.isEmpty == false
    }
}

struct AmbitionsOSLivingDreamPackRollbackProof: Codable, Sendable, Equatable, Hashable {
    let currentVersion: String
    let rollbackVersion: String
    let preservesPreviousManifest: Bool
    let reversibleWithoutNetwork: Bool
    let mutatesUserCommitments: Bool

    init(
        currentVersion: String,
        rollbackVersion: String,
        preservesPreviousManifest: Bool,
        reversibleWithoutNetwork: Bool,
        mutatesUserCommitments: Bool = false
    ) {
        self.currentVersion = currentVersion.trimmingCharacters(in: .whitespacesAndNewlines)
        self.rollbackVersion = rollbackVersion.trimmingCharacters(in: .whitespacesAndNewlines)
        self.preservesPreviousManifest = preservesPreviousManifest
        self.reversibleWithoutNetwork = reversibleWithoutNetwork
        self.mutatesUserCommitments = mutatesUserCommitments
    }

    var isReady: Bool {
        currentVersion.isEmpty == false &&
            rollbackVersion.isEmpty == false &&
            currentVersion != rollbackVersion &&
            preservesPreviousManifest &&
            reversibleWithoutNetwork &&
            mutatesUserCommitments == false
    }
}

struct AmbitionsOSLivingDreamPackSupplyChainEnvelope: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let schemaVersion: String
    let compilerInput: AmbitionsOSLivingDreamPackCompilerInput
    let checksumProof: AmbitionsOSLivingDreamPackChecksumProof
    let signatureProof: AmbitionsOSLivingDreamPackSignatureProof
    let rollbackProof: AmbitionsOSLivingDreamPackRollbackProof
    let provenance: String
    let safeImportValidation: Bool
    let corruptionHandling: Bool
    let tamperDetection: Bool
    let packDiffIntegrity: Bool
    let packManifestIntegrity: Bool
    let containsExecutableLogic: Bool
    let runtimeBoundary: SourceAtlasRuntimeBoundary

    init(
        id: String,
        schemaVersion: String = ambitionsOSLivingDreamPackSupplyChainSecuritySchemaVersion,
        compilerInput: AmbitionsOSLivingDreamPackCompilerInput,
        checksumProof: AmbitionsOSLivingDreamPackChecksumProof,
        signatureProof: AmbitionsOSLivingDreamPackSignatureProof,
        rollbackProof: AmbitionsOSLivingDreamPackRollbackProof,
        provenance: String,
        safeImportValidation: Bool,
        corruptionHandling: Bool,
        tamperDetection: Bool,
        packDiffIntegrity: Bool,
        packManifestIntegrity: Bool,
        containsExecutableLogic: Bool,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.schemaVersion = schemaVersion
        self.compilerInput = compilerInput
        self.checksumProof = checksumProof
        self.signatureProof = signatureProof
        self.rollbackProof = rollbackProof
        self.provenance = provenance.trimmingCharacters(in: .whitespacesAndNewlines)
        self.safeImportValidation = safeImportValidation
        self.corruptionHandling = corruptionHandling
        self.tamperDetection = tamperDetection
        self.packDiffIntegrity = packDiffIntegrity
        self.packManifestIntegrity = packManifestIntegrity
        self.containsExecutableLogic = containsExecutableLogic
        self.runtimeBoundary = runtimeBoundary
    }

    var validationIssues: [AmbitionsOSLivingDreamPackSupplyChainIssue] {
        AmbitionsOSLivingDreamPackSupplyChainValidator().validate(envelope: self)
    }

    var isTrustedForRegistry: Bool {
        validationIssues.isEmpty
    }
}

struct AmbitionsOSLivingDreamPackSupplyChainReceipt: Codable, Sendable, Equatable, Hashable {
    let packID: String
    let version: String
    let accepted: Bool
    let issues: [AmbitionsOSLivingDreamPackSupplyChainIssue]
    let activatesPlans: Bool
    let mutatesCommitments: Bool
    let usesUserDataServer: Bool

    init(
        packID: String,
        version: String,
        accepted: Bool,
        issues: [AmbitionsOSLivingDreamPackSupplyChainIssue],
        activatesPlans: Bool = false,
        mutatesCommitments: Bool = false,
        usesUserDataServer: Bool = false
    ) {
        self.packID = packID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.version = version.trimmingCharacters(in: .whitespacesAndNewlines)
        self.accepted = accepted
        self.issues = issues
        self.activatesPlans = activatesPlans
        self.mutatesCommitments = mutatesCommitments
        self.usesUserDataServer = usesUserDataServer
    }
}

struct AmbitionsOSLivingDreamPackSupplyChainValidator: Sendable, Equatable, Hashable {
    func validate(
        envelope: AmbitionsOSLivingDreamPackSupplyChainEnvelope
    ) -> [AmbitionsOSLivingDreamPackSupplyChainIssue] {
        var issues: Set<AmbitionsOSLivingDreamPackSupplyChainIssue> = []
        let manifest = envelope.compilerInput.manifest
        let proof = envelope.compilerInput.supplyChainProof

        if envelope.schemaVersion != ambitionsOSLivingDreamPackSupplyChainSecuritySchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if envelope.id.isEmpty || envelope.id != manifest.id {
            issues.insert(.malformedEnvelope)
        }
        if envelope.checksumProof.isWellFormed == false {
            issues.insert(.checksumMissing)
        }
        if envelope.checksumProof.matches == false {
            issues.insert(.checksumMismatch)
        }
        if envelope.signatureProof.isPresent == false ||
            envelope.signatureProof.signedManifestID != proof.signedManifestID {
            issues.insert(.signatureMissing)
        }
        if envelope.signatureProof.verifiedLocally == false ||
            proof.signatureVerification == false {
            issues.insert(.signatureUnverified)
        }
        if envelope.provenance.isEmpty ||
            envelope.provenance != proof.provenance ||
            proof.provenance.isEmpty {
            issues.insert(.provenanceMissing)
        }
        if envelope.rollbackProof.rollbackVersion != proof.rollbackVersion ||
            envelope.rollbackProof.currentVersion != manifest.version {
            issues.insert(.rollbackMissing)
        }
        if envelope.rollbackProof.isReady == false {
            issues.insert(.rollbackNotReversible)
        }
        if envelope.safeImportValidation == false || proof.safeImportValidation == false {
            issues.insert(.safeImportValidationMissing)
        }
        if envelope.corruptionHandling == false || proof.corruptionHandling == false {
            issues.insert(.corruptionHandlingMissing)
        }
        if envelope.tamperDetection == false || proof.tamperDetection == false {
            issues.insert(.tamperDetectionMissing)
        }
        if envelope.packDiffIntegrity == false || proof.packDiffIntegrity == false {
            issues.insert(.packDiffIntegrityMissing)
        }
        if envelope.packManifestIntegrity == false || proof.packManifestIntegrity == false {
            issues.insert(.packManifestIntegrityMissing)
        }
        if envelope.containsExecutableLogic || proof.containsExecutableLogic {
            issues.insert(.executableLogicPresent)
        }
        if envelope.runtimeBoundary.isValueModelOnly == false ||
            envelope.compilerInput.runtimeBoundary.isValueModelOnly == false {
            issues.insert(.runtimeBoundaryBroken)
        }
        if manifest.usesUserDataServer {
            issues.insert(.userDataServerBoundaryBroken)
        }
        if manifest.allowsActivation {
            issues.insert(.activationOrMutationForbidden)
        }
        if envelope.compilerInput.sourceClaimGraph.validationIssues.isEmpty == false ||
            envelope.compilerInput.sourceClaimGraph.claimsReadyForConsequentialRecommendation.isEmpty {
            issues.insert(.sourceClaimGraphNotReady)
        }

        return issues.sorted { $0.rawValue < $1.rawValue }
    }

    func receipt(
        for envelope: AmbitionsOSLivingDreamPackSupplyChainEnvelope
    ) -> AmbitionsOSLivingDreamPackSupplyChainReceipt {
        let issues = validate(envelope: envelope)
        return AmbitionsOSLivingDreamPackSupplyChainReceipt(
            packID: envelope.compilerInput.manifest.id,
            version: envelope.compilerInput.manifest.version,
            accepted: issues.isEmpty,
            issues: issues,
            activatesPlans: false,
            mutatesCommitments: false,
            usesUserDataServer: false
        )
    }
}
