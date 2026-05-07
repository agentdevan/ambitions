import Foundation

let ambitionsOSLocalGoalPackSchemaVersion = "ambitionsos_local_goal_pack.native.v1"

enum AmbitionsOSLocalGoalPackQualityState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case draft
    case generated
    case reviewed
    case needsSourceReview = "needs_source_review"
    case blocked
}

enum AmbitionsOSLocalGoalPackSlotOrigin: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case authored
    case generated
    case sourceBacked = "source_backed"
    case userReviewed = "user_reviewed"
}

enum AmbitionsOSLocalGoalPackIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case missingManifestIdentity = "missing_manifest_identity"
    case missingSourceAtlasPack = "missing_source_atlas_pack"
    case onePackPerGoalRisk = "one_pack_per_goal_risk"
    case missingRequirementSlots = "missing_requirement_slots"
    case duplicateRequirementSlotID = "duplicate_requirement_slot_id"
    case malformedRequirementSlot = "malformed_requirement_slot"
    case officialRequirementOverclaim = "official_requirement_overclaim"
    case sourceReviewRequired = "source_review_required"
    case generatedBoundaryRequired = "generated_boundary_required"
    case universalScheduledStep = "universal_scheduled_step"
    case executableLogicBehavior = "executable_logic_behavior"
    case runtimeStoreBehavior = "runtime_store_behavior"
}

struct AmbitionsOSLocalGoalPackManifest: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let sourceAtlasPackID: String
    let kind: SourceAtlasPackKind
    let domainID: String
    let dependencyPackIDs: [String]
    let ownsIndividualGoalPhrase: Bool
    let schemaVersion: String

    init(
        id: String,
        title: String,
        sourceAtlasPackID: String,
        kind: SourceAtlasPackKind,
        domainID: String,
        dependencyPackIDs: [String] = [],
        ownsIndividualGoalPhrase: Bool = false,
        schemaVersion: String = ambitionsOSLocalGoalPackSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceAtlasPackID = sourceAtlasPackID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.kind = kind
        self.domainID = domainID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.dependencyPackIDs = Self.orderedUnique(dependencyPackIDs)
        self.ownsIndividualGoalPhrase = ownsIndividualGoalPhrase
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            title.isEmpty == false &&
            domainID.isEmpty == false &&
            schemaVersion == ambitionsOSLocalGoalPackSchemaVersion
    }

    var hasSourceAtlasAnchor: Bool {
        sourceAtlasPackID.isEmpty == false
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct AmbitionsOSLocalGoalPackRequirementSlotDefinition: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let kind: AmbitionsOSGoalPathRequirementKind
    let origin: AmbitionsOSLocalGoalPackSlotOrigin
    let blocking: Bool
    let sourceState: HumanProgressSourceState
    let freshnessState: HumanProgressFreshnessState
    let reviewState: HumanProgressReviewState
    let privacyClass: HumanProgressPrivacyClass
    let sourceClaimIDs: [String]
    let proofReceiptIDs: [String]
    let claimsOfficialRequirement: Bool
    let schemaVersion: String

    init(
        id: String,
        title: String,
        kind: AmbitionsOSGoalPathRequirementKind,
        origin: AmbitionsOSLocalGoalPackSlotOrigin,
        blocking: Bool,
        sourceState: HumanProgressSourceState = .sourceNeeded,
        freshnessState: HumanProgressFreshnessState = .unknown,
        reviewState: HumanProgressReviewState = .needsSourceReview,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        sourceClaimIDs: [String] = [],
        proofReceiptIDs: [String] = [],
        claimsOfficialRequirement: Bool = false,
        schemaVersion: String = ambitionsOSLocalGoalPackSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.kind = kind
        self.origin = origin
        self.blocking = blocking
        self.sourceState = sourceState
        self.freshnessState = freshnessState
        self.reviewState = reviewState
        self.privacyClass = privacyClass
        self.sourceClaimIDs = Self.orderedUnique(sourceClaimIDs)
        self.proofReceiptIDs = Self.orderedUnique(proofReceiptIDs)
        self.claimsOfficialRequirement = claimsOfficialRequirement
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            title.isEmpty == false &&
            schemaVersion == ambitionsOSLocalGoalPackSchemaVersion
    }

    var compilerSlot: AmbitionsOSGoalPathRequirementSlot {
        AmbitionsOSGoalPathRequirementSlot(
            id: id,
            title: title,
            kind: kind,
            blocking: blocking,
            sourceState: sourceState,
            freshnessState: freshnessState,
            reviewState: reviewState,
            privacyClass: privacyClass,
            sourceClaimIDs: sourceClaimIDs,
            proofReceiptIDs: proofReceiptIDs
        )
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct AmbitionsOSLocalGoalPackStarterSeed: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let stepCandidateSeed: String
    let storesFinalSchedule: Bool
    let schemaVersion: String

    init(
        id: String,
        title: String,
        stepCandidateSeed: String,
        storesFinalSchedule: Bool = false,
        schemaVersion: String = ambitionsOSLocalGoalPackSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.stepCandidateSeed = stepCandidateSeed.trimmingCharacters(in: .whitespacesAndNewlines)
        self.storesFinalSchedule = storesFinalSchedule
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            title.isEmpty == false &&
            stepCandidateSeed.isEmpty == false &&
            schemaVersion == ambitionsOSLocalGoalPackSchemaVersion
    }
}

struct AmbitionsOSLocalGoalPack: Codable, Sendable, Equatable, Hashable, Identifiable {
    var id: String { manifest.id }

    let manifest: AmbitionsOSLocalGoalPackManifest
    let qualityState: AmbitionsOSLocalGoalPackQualityState
    let requirementSlots: [AmbitionsOSLocalGoalPackRequirementSlotDefinition]
    let starterSeeds: [AmbitionsOSLocalGoalPackStarterSeed]
    let projectionRecipeIDs: [String]
    let runtimeBoundary: SourceAtlasRuntimeBoundary
    let containsExecutableLogic: Bool
    let schemaVersion: String

    init(
        manifest: AmbitionsOSLocalGoalPackManifest,
        qualityState: AmbitionsOSLocalGoalPackQualityState,
        requirementSlots: [AmbitionsOSLocalGoalPackRequirementSlotDefinition],
        starterSeeds: [AmbitionsOSLocalGoalPackStarterSeed] = [],
        projectionRecipeIDs: [String] = [],
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        containsExecutableLogic: Bool = false,
        schemaVersion: String = ambitionsOSLocalGoalPackSchemaVersion
    ) {
        self.manifest = manifest
        self.qualityState = qualityState
        self.requirementSlots = requirementSlots
        self.starterSeeds = starterSeeds
        self.projectionRecipeIDs = Self.orderedUnique(projectionRecipeIDs)
        self.runtimeBoundary = runtimeBoundary
        self.containsExecutableLogic = containsExecutableLogic
        self.schemaVersion = schemaVersion
    }

    var compilerRequirementSlots: [AmbitionsOSGoalPathRequirementSlot] {
        requirementSlots.map(\.compilerSlot)
    }

    var validationIssues: [AmbitionsOSLocalGoalPackIssue] {
        AmbitionsOSLocalGoalPackValidator().validate(self)
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct AmbitionsOSLocalGoalPackValidator: Sendable, Equatable, Hashable {
    func validate(_ pack: AmbitionsOSLocalGoalPack) -> [AmbitionsOSLocalGoalPackIssue] {
        var issues: Set<AmbitionsOSLocalGoalPackIssue> = []

        if pack.schemaVersion != ambitionsOSLocalGoalPackSchemaVersion ||
            pack.manifest.schemaVersion != ambitionsOSLocalGoalPackSchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if pack.manifest.isWellFormed == false {
            issues.insert(.missingManifestIdentity)
        }
        if pack.manifest.hasSourceAtlasAnchor == false {
            issues.insert(.missingSourceAtlasPack)
        }
        if pack.manifest.ownsIndividualGoalPhrase {
            issues.insert(.onePackPerGoalRisk)
        }
        if pack.requirementSlots.isEmpty {
            issues.insert(.missingRequirementSlots)
        }
        if pack.runtimeBoundary.isValueModelOnly == false {
            issues.insert(.runtimeStoreBehavior)
        }
        if pack.containsExecutableLogic {
            issues.insert(.executableLogicBehavior)
        }
        if pack.starterSeeds.contains(where: { $0.storesFinalSchedule || $0.isWellFormed == false }) {
            issues.insert(.universalScheduledStep)
        }

        let slotIDs = pack.requirementSlots.map(\.id)
        if Set(slotIDs).count != slotIDs.count {
            issues.insert(.duplicateRequirementSlotID)
        }

        for slot in pack.requirementSlots {
            validate(slot: slot, pack: pack, issues: &issues)
        }

        return issues.sorted { $0.rawValue < $1.rawValue }
    }

    private func validate(
        slot: AmbitionsOSLocalGoalPackRequirementSlotDefinition,
        pack: AmbitionsOSLocalGoalPack,
        issues: inout Set<AmbitionsOSLocalGoalPackIssue>
    ) {
        if slot.schemaVersion != ambitionsOSLocalGoalPackSchemaVersion || slot.isWellFormed == false {
            issues.insert(.malformedRequirementSlot)
        }
        if slot.claimsOfficialRequirement {
            issues.insert(.officialRequirementOverclaim)
        }
        if slot.origin == .generated && slot.reviewState == .ready {
            issues.insert(.generatedBoundaryRequired)
        }
        if pack.qualityState == .generated && slot.reviewState == .ready {
            issues.insert(.generatedBoundaryRequired)
        }
        if slot.kind != .sourceNeeded &&
            (slot.sourceState.canDriveSourceSensitiveRecommendation == false ||
             slot.freshnessState.blocksHighRiskUse ||
             slot.reviewState.blocksAutomaticMutation) {
            issues.insert(.sourceReviewRequired)
        }
    }
}
