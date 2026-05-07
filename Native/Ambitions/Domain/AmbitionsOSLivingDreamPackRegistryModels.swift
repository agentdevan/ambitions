import Foundation

let ambitionsOSLivingDreamPackRegistrySchemaVersion = "ambitionsos_living_dream_pack_registry.native.v1"

enum AmbitionsOSLivingDreamPackTaxonomy: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case archetype
    case domain
    case jurisdiction
    case regulated
    case professionalBoundary = "professional_boundary"
    case unsafeRedirect = "unsafe_redirect"
    case northStar = "north_star"
    case sourceStale = "source_stale"
    case impossibleTimeline = "impossible_timeline"
    case crisisSupport = "crisis_support"
    case privacySensitive = "privacy_sensitive"
    case unsupportedDomainExploration = "unsupported_domain_exploration"

    var requiresStrictReview: Bool {
        switch self {
        case .regulated, .professionalBoundary, .unsafeRedirect, .sourceStale,
             .impossibleTimeline, .crisisSupport, .privacySensitive:
            return true
        case .archetype, .domain, .jurisdiction, .northStar, .unsupportedDomainExploration:
            return false
        }
    }
}

enum AmbitionsOSLivingDreamPackQualityState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case draft
    case generated
    case schemaValid = "schema_valid"
    case sourceAttached = "source_attached"
    case reviewed
    case officialSourceBacked = "official_source_backed"
    case stale
    case deprecated
    case withdrawn
    case professionalReviewRequired = "professional_review_required"
    case conflict
    case unsafeToUse = "unsafe_to_use"
    case localOnly = "local_only"

    var canEnterCompiler: Bool {
        switch self {
        case .reviewed, .officialSourceBacked:
            return true
        case .draft, .generated, .schemaValid, .sourceAttached, .stale,
             .deprecated, .withdrawn, .professionalReviewRequired, .conflict,
             .unsafeToUse, .localOnly:
            return false
        }
    }
}

enum AmbitionsOSLivingDreamPackLifecycleState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case active
    case stale
    case deprecated
    case withdrawn
    case conflict

    var blocksCompilerUse: Bool {
        switch self {
        case .active:
            return false
        case .stale, .deprecated, .withdrawn, .conflict:
            return true
        }
    }
}

enum AmbitionsOSLivingDreamPackCompilerIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case malformedManifest = "malformed_manifest"
    case missingCanonTrace = "missing_canon_trace"
    case missingSourceClaimGraph = "missing_source_claim_graph"
    case missingSupplyChainProof = "missing_supply_chain_proof"
    case generatedPackWithoutReviewProof = "generated_pack_without_review_proof"
    case officialPackOverclaim = "official_pack_overclaim"
    case unsafePackUsable = "unsafe_pack_usable"
    case staleOrConflictPackUsable = "stale_or_conflict_pack_usable"
    case unreviewedRegulatedPack = "unreviewed_regulated_pack"
    case executableLogic = "executable_logic"
    case runtimeBoundaryBroken = "runtime_boundary_broken"
    case userDataServerBoundaryBroken = "user_data_server_boundary_broken"
    case invalidCompilerInput = "invalid_compiler_input"
    case forbiddenActivation = "forbidden_activation"
}

struct AmbitionsOSLivingDreamPackSupplyChainProof: Codable, Sendable, Equatable, Hashable {
    let checksum: String
    let provenance: String
    let signedManifestID: String
    let rollbackVersion: String
    let safeImportValidation: Bool
    let corruptionHandling: Bool
    let tamperDetection: Bool
    let signatureVerification: Bool
    let packDiffIntegrity: Bool
    let packManifestIntegrity: Bool
    let containsExecutableLogic: Bool

    init(
        checksum: String,
        provenance: String,
        signedManifestID: String,
        rollbackVersion: String,
        safeImportValidation: Bool = true,
        corruptionHandling: Bool = true,
        tamperDetection: Bool = true,
        signatureVerification: Bool = true,
        packDiffIntegrity: Bool = true,
        packManifestIntegrity: Bool = true,
        containsExecutableLogic: Bool = false
    ) {
        self.checksum = checksum.trimmingCharacters(in: .whitespacesAndNewlines)
        self.provenance = provenance.trimmingCharacters(in: .whitespacesAndNewlines)
        self.signedManifestID = signedManifestID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.rollbackVersion = rollbackVersion.trimmingCharacters(in: .whitespacesAndNewlines)
        self.safeImportValidation = safeImportValidation
        self.corruptionHandling = corruptionHandling
        self.tamperDetection = tamperDetection
        self.signatureVerification = signatureVerification
        self.packDiffIntegrity = packDiffIntegrity
        self.packManifestIntegrity = packManifestIntegrity
        self.containsExecutableLogic = containsExecutableLogic
    }

    var isComplete: Bool {
        checksum.isEmpty == false &&
            provenance.isEmpty == false &&
            signedManifestID.isEmpty == false &&
            rollbackVersion.isEmpty == false &&
            safeImportValidation &&
            corruptionHandling &&
            tamperDetection &&
            signatureVerification &&
            packDiffIntegrity &&
            packManifestIntegrity
    }
}

struct AmbitionsOSLivingDreamPackManifest: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let taxonomy: AmbitionsOSLivingDreamPackTaxonomy
    let version: String
    let schemaVersion: String
    let sourceAtlasPackID: String
    let sourceClaimGraphID: String
    let sourceClaimIDs: [String]
    let qualityState: AmbitionsOSLivingDreamPackQualityState
    let reviewState: HumanProgressReviewState
    let lifecycleState: AmbitionsOSLivingDreamPackLifecycleState
    let claimsOfficialSourcePack: Bool
    let allowsActivation: Bool
    let usesUserDataServer: Bool
    let canonDocumentIDs: [String]

    init(
        id: String,
        title: String,
        taxonomy: AmbitionsOSLivingDreamPackTaxonomy,
        version: String,
        schemaVersion: String = ambitionsOSLivingDreamPackRegistrySchemaVersion,
        sourceAtlasPackID: String,
        sourceClaimGraphID: String,
        sourceClaimIDs: [String],
        qualityState: AmbitionsOSLivingDreamPackQualityState,
        reviewState: HumanProgressReviewState,
        lifecycleState: AmbitionsOSLivingDreamPackLifecycleState = .active,
        claimsOfficialSourcePack: Bool = false,
        allowsActivation: Bool = false,
        usesUserDataServer: Bool = false,
        canonDocumentIDs: [String] = [
            "docs/canon/AmbitionsOS_Source_Claim_Graph_And_Pack_System.md",
            "docs/canon/AmbitionsOS_Living_Dream_Architecture_Index.md",
            "docs/codex/LDI_BATCH_GATE_MATRIX.md"
        ]
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.taxonomy = taxonomy
        self.version = version.trimmingCharacters(in: .whitespacesAndNewlines)
        self.schemaVersion = schemaVersion
        self.sourceAtlasPackID = sourceAtlasPackID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceClaimGraphID = sourceClaimGraphID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceClaimIDs = Self.orderedUnique(sourceClaimIDs)
        self.qualityState = qualityState
        self.reviewState = reviewState
        self.lifecycleState = lifecycleState
        self.claimsOfficialSourcePack = claimsOfficialSourcePack
        self.allowsActivation = allowsActivation
        self.usesUserDataServer = usesUserDataServer
        self.canonDocumentIDs = Self.orderedUnique(canonDocumentIDs)
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            title.isEmpty == false &&
            version.isEmpty == false &&
            sourceAtlasPackID.isEmpty == false &&
            sourceClaimGraphID.isEmpty == false &&
            sourceClaimIDs.isEmpty == false &&
            schemaVersion == ambitionsOSLivingDreamPackRegistrySchemaVersion
    }

    var hasCanonTrace: Bool {
        canonDocumentIDs.contains("docs/canon/AmbitionsOS_Source_Claim_Graph_And_Pack_System.md") &&
            canonDocumentIDs.contains("docs/codex/LDI_BATCH_GATE_MATRIX.md")
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct AmbitionsOSLivingDreamPackCompilerInput: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let manifest: AmbitionsOSLivingDreamPackManifest
    let supplyChainProof: AmbitionsOSLivingDreamPackSupplyChainProof
    let sourceClaimGraph: AmbitionsOSLivingDreamSourceClaimGraph
    let runtimeBoundary: SourceAtlasRuntimeBoundary

    init(
        id: String,
        manifest: AmbitionsOSLivingDreamPackManifest,
        supplyChainProof: AmbitionsOSLivingDreamPackSupplyChainProof,
        sourceClaimGraph: AmbitionsOSLivingDreamSourceClaimGraph,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.manifest = manifest
        self.supplyChainProof = supplyChainProof
        self.sourceClaimGraph = sourceClaimGraph
        self.runtimeBoundary = runtimeBoundary
    }

    var validationIssues: [AmbitionsOSLivingDreamPackCompilerIssue] {
        AmbitionsOSLivingDreamPackRegistryValidator().validate(input: self)
    }

    var canEnterCompiler: Bool {
        validationIssues.isEmpty
    }
}

struct AmbitionsOSLivingDreamPackRegistry: Codable, Sendable, Equatable, Hashable {
    let inputs: [AmbitionsOSLivingDreamPackCompilerInput]

    var validationIssues: [AmbitionsOSLivingDreamPackCompilerIssue] {
        AmbitionsOSLivingDreamPackRegistryValidator().validate(registry: self)
    }

    var compilerReadyInputs: [AmbitionsOSLivingDreamPackCompilerInput] {
        guard validationIssues.isEmpty else { return [] }
        return inputs.filter(\.canEnterCompiler)
    }
}

struct AmbitionsOSLivingDreamCompiledPackSet: Codable, Sendable, Equatable, Hashable {
    let packIDs: [String]
    let claimIDs: [String]
    let schemaVersion: String
    let activatesPlans: Bool
    let mutatesCommitments: Bool
}

struct AmbitionsOSLivingDreamPackCompiler: Sendable, Equatable, Hashable {
    func compile(
        registry: AmbitionsOSLivingDreamPackRegistry
    ) throws -> AmbitionsOSLivingDreamCompiledPackSet {
        let issues = AmbitionsOSLivingDreamPackRegistryValidator().validate(registry: registry)
        guard issues.isEmpty else {
            throw AmbitionsOSLivingDreamPackRegistryValidator.ValidationError(issues: issues)
        }

        return AmbitionsOSLivingDreamCompiledPackSet(
            packIDs: registry.inputs.map(\.manifest.id).sorted(),
            claimIDs: Array(Set(registry.inputs.flatMap(\.manifest.sourceClaimIDs))).sorted(),
            schemaVersion: ambitionsOSLivingDreamPackRegistrySchemaVersion,
            activatesPlans: false,
            mutatesCommitments: false
        )
    }
}

struct AmbitionsOSLivingDreamPackRegistryValidator: Sendable, Equatable, Hashable {
    struct ValidationError: Error, Equatable {
        let issues: [AmbitionsOSLivingDreamPackCompilerIssue]
    }

    func validate(registry: AmbitionsOSLivingDreamPackRegistry) -> [AmbitionsOSLivingDreamPackCompilerIssue] {
        var issues: Set<AmbitionsOSLivingDreamPackCompilerIssue> = []
        let packIDs = registry.inputs.map(\.manifest.id)
        if registry.inputs.isEmpty || Set(packIDs).count != packIDs.count {
            issues.insert(.invalidCompilerInput)
        }

        for input in registry.inputs {
            validate(input: input).forEach { issues.insert($0) }
        }

        return issues.sorted { $0.rawValue < $1.rawValue }
    }

    func validate(input: AmbitionsOSLivingDreamPackCompilerInput) -> [AmbitionsOSLivingDreamPackCompilerIssue] {
        var issues: Set<AmbitionsOSLivingDreamPackCompilerIssue> = []
        let manifest = input.manifest

        if manifest.schemaVersion != ambitionsOSLivingDreamPackRegistrySchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if input.id.isEmpty || manifest.isWellFormed == false {
            issues.insert(.malformedManifest)
        }
        if manifest.hasCanonTrace == false {
            issues.insert(.missingCanonTrace)
        }
        if input.sourceClaimGraph.validationIssues.isEmpty == false ||
            input.sourceClaimGraph.claimsReadyForConsequentialRecommendation.isEmpty {
            issues.insert(.missingSourceClaimGraph)
        }
        if input.runtimeBoundary.isValueModelOnly == false {
            issues.insert(.runtimeBoundaryBroken)
        }
        if manifest.usesUserDataServer {
            issues.insert(.userDataServerBoundaryBroken)
        }
        if manifest.allowsActivation {
            issues.insert(.forbiddenActivation)
        }
        if input.supplyChainProof.isComplete == false {
            issues.insert(.missingSupplyChainProof)
        }
        if input.supplyChainProof.containsExecutableLogic {
            issues.insert(.executableLogic)
        }
        if manifest.qualityState == .generated && manifest.reviewState == .ready {
            issues.insert(.generatedPackWithoutReviewProof)
        }
        if manifest.qualityState.canEnterCompiler == false {
            issues.insert(.generatedPackWithoutReviewProof)
        }
        if manifest.claimsOfficialSourcePack {
            issues.insert(.officialPackOverclaim)
        }
        if manifest.qualityState == .unsafeToUse {
            issues.insert(.unsafePackUsable)
        }
        if manifest.lifecycleState.blocksCompilerUse ||
            manifest.qualityState == .stale ||
            manifest.qualityState == .deprecated ||
            manifest.qualityState == .withdrawn ||
            manifest.qualityState == .conflict {
            issues.insert(.staleOrConflictPackUsable)
        }
        if manifest.taxonomy.requiresStrictReview && manifest.reviewState != .ready {
            issues.insert(.unreviewedRegulatedPack)
        }

        return issues.sorted { $0.rawValue < $1.rawValue }
    }
}
