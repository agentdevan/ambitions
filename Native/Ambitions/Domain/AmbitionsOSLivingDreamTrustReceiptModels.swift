import Foundation

let ambitionsOSLivingDreamTrustReceiptSchemaVersion =
    "ambitionsos_living_dream_trust_receipt.native.v1"

enum AmbitionsOSLivingDreamTrustReceiptKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case handling
    case sourceReview = "source_review"
    case userConfirmation = "user_confirmation"
    case staleSourceReview = "stale_source_review"
    case unverifiedSourceReview = "unverified_source_review"
    case mutationReview = "mutation_review"
    case refusal
    case safeTranslation = "safe_translation"
    case userImportedSource = "user_imported_source"
    case ocrReview = "ocr_review"
    case packUpdate = "pack_update"
}

enum AmbitionsOSLivingDreamTrustReceiptIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case malformedReceipt = "malformed_receipt"
    case malformedBundle = "malformed_bundle"
    case missingHandlingLane = "missing_handling_lane"
    case missingSourceReference = "missing_source_reference"
    case sourceReviewRequired = "source_review_required"
    case staleSourceReviewRequired = "stale_source_review_required"
    case unverifiedSourceReviewRequired = "unverified_source_review_required"
    case mutationMissingUserApproval = "mutation_missing_user_approval"
    case silentMutationRisk = "silent_mutation_risk"
    case refusalMissingSafeAlternative = "refusal_missing_safe_alternative"
    case unsafeTranslationClaim = "unsafe_translation_claim"
    case ocrReviewRequired = "ocr_review_required"
    case missingUserControl = "missing_user_control"
    case hiddenReceipt = "hidden_receipt"
    case professionalBoundaryReviewRequired = "professional_boundary_review_required"
    case userDataServerBoundaryBroken = "user_data_server_boundary_broken"
    case runtimeBoundaryBroken = "runtime_boundary_broken"
}

enum AmbitionsOSLivingDreamTrustReceiptReadiness: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case ready
    case needsSourceReview = "needs_source_review"
    case needsUserReview = "needs_user_review"
    case needsMutationReview = "needs_mutation_review"
    case needsProfessionalReview = "needs_professional_review"
    case blocked
}

enum AmbitionsOSLivingDreamMutationPermission: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case none
    case reviewOnly = "review_only"
    case userApproved = "user_approved"
    case rejected

    var permitsMutation: Bool {
        self == .userApproved
    }
}

struct AmbitionsOSLivingDreamTrustReceipt: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: AmbitionsOSLivingDreamTrustReceiptKind
    let surface: AmbitionsOSControlPlaneSurface
    let occurredAt: String
    let affectedObjectIDs: [String]
    let handlingLane: AmbitionsOSLivingDreamHandlingLane?
    let assumptionIDs: [String]
    let sourceClaimIDs: [String]
    let sourceReferenceIDs: [String]
    let sourcePackIDs: [String]
    let proofReceiptIDs: [String]
    let changedFactSummaries: [String]
    let originalTextSummary: String?
    let translatedTextSummary: String?
    let refusalReason: String?
    let safeAlternativeSummary: String?
    let sourceState: HumanProgressSourceState
    let freshnessState: HumanProgressFreshnessState
    let reviewState: HumanProgressReviewState
    let privacyClass: HumanProgressPrivacyClass
    let mutationPermission: AmbitionsOSLivingDreamMutationPermission
    let mutatesCommitments: Bool
    let reversible: Bool
    let visibleToUser: Bool
    let userControlIDs: [String]
    let professionalBoundaryReviewRequired: Bool
    let usesUserDataServer: Bool
    let runtimeBoundary: SourceAtlasRuntimeBoundary
    let surfaceLanguageSamples: [String]
    let schemaVersion: String

    init(
        id: String,
        kind: AmbitionsOSLivingDreamTrustReceiptKind,
        surface: AmbitionsOSControlPlaneSurface,
        occurredAt: String,
        affectedObjectIDs: [String],
        handlingLane: AmbitionsOSLivingDreamHandlingLane? = nil,
        assumptionIDs: [String] = [],
        sourceClaimIDs: [String] = [],
        sourceReferenceIDs: [String] = [],
        sourcePackIDs: [String] = [],
        proofReceiptIDs: [String] = [],
        changedFactSummaries: [String] = [],
        originalTextSummary: String? = nil,
        translatedTextSummary: String? = nil,
        refusalReason: String? = nil,
        safeAlternativeSummary: String? = nil,
        sourceState: HumanProgressSourceState = .userConfirmed,
        freshnessState: HumanProgressFreshnessState = .notApplicable,
        reviewState: HumanProgressReviewState = .ready,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        mutationPermission: AmbitionsOSLivingDreamMutationPermission = .none,
        mutatesCommitments: Bool = false,
        reversible: Bool = true,
        visibleToUser: Bool = true,
        userControlIDs: [String] = ["review", "correct"],
        professionalBoundaryReviewRequired: Bool = false,
        usesUserDataServer: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        surfaceLanguageSamples: [String] = [],
        schemaVersion: String = ambitionsOSLivingDreamTrustReceiptSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.kind = kind
        self.surface = surface
        self.occurredAt = occurredAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.affectedObjectIDs = Self.orderedUnique(affectedObjectIDs)
        self.handlingLane = handlingLane
        self.assumptionIDs = Self.orderedUnique(assumptionIDs)
        self.sourceClaimIDs = Self.orderedUnique(sourceClaimIDs)
        self.sourceReferenceIDs = Self.orderedUnique(sourceReferenceIDs)
        self.sourcePackIDs = Self.orderedUnique(sourcePackIDs)
        self.proofReceiptIDs = Self.orderedUnique(proofReceiptIDs)
        self.changedFactSummaries = Self.orderedUnique(changedFactSummaries)
        self.originalTextSummary = originalTextSummary?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.translatedTextSummary = translatedTextSummary?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.refusalReason = refusalReason?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.safeAlternativeSummary = safeAlternativeSummary?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceState = sourceState
        self.freshnessState = freshnessState
        self.reviewState = reviewState
        self.privacyClass = privacyClass
        self.mutationPermission = mutationPermission
        self.mutatesCommitments = mutatesCommitments
        self.reversible = reversible
        self.visibleToUser = visibleToUser
        self.userControlIDs = Self.orderedUnique(userControlIDs)
        self.professionalBoundaryReviewRequired = professionalBoundaryReviewRequired
        self.usesUserDataServer = usesUserDataServer
        self.runtimeBoundary = runtimeBoundary
        self.surfaceLanguageSamples = Self.orderedUnique(surfaceLanguageSamples)
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            occurredAt.isEmpty == false &&
            affectedObjectIDs.isEmpty == false &&
            schemaVersion == ambitionsOSLivingDreamTrustReceiptSchemaVersion
    }

    var hasSourceReference: Bool {
        sourceClaimIDs.isEmpty == false ||
            sourceReferenceIDs.isEmpty == false ||
            sourcePackIDs.isEmpty == false
    }

    var hasUserControl: Bool {
        visibleToUser && userControlIDs.isEmpty == false
    }

    var containsUnsafeTranslationLanguage: Bool {
        let blocked = [
            "guaranteed",
            "officially verified",
            "legally approved",
            "medically safe",
            "always accurate",
            "no review needed"
        ]
        let combined = surfaceLanguageSamples.joined(separator: " ").lowercased()
        return blocked.contains { combined.contains($0) }
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct AmbitionsOSLivingDreamTrustReceiptBundle: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let todayBridgeID: String?
    let receipts: [AmbitionsOSLivingDreamTrustReceipt]
    let allowsActivation: Bool
    let mutatesCommitments: Bool
    let usesUserDataServer: Bool
    let runtimeBoundary: SourceAtlasRuntimeBoundary
    let schemaVersion: String

    init(
        id: String,
        todayBridgeID: String? = nil,
        receipts: [AmbitionsOSLivingDreamTrustReceipt],
        allowsActivation: Bool = false,
        mutatesCommitments: Bool = false,
        usesUserDataServer: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        schemaVersion: String = ambitionsOSLivingDreamTrustReceiptSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.todayBridgeID = todayBridgeID?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.receipts = receipts.sorted { $0.id < $1.id }
        self.allowsActivation = allowsActivation
        self.mutatesCommitments = mutatesCommitments
        self.usesUserDataServer = usesUserDataServer
        self.runtimeBoundary = runtimeBoundary
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            receipts.isEmpty == false &&
            schemaVersion == ambitionsOSLivingDreamTrustReceiptSchemaVersion
    }
}

struct AmbitionsOSLivingDreamTrustReceiptEvaluation: Codable, Sendable, Equatable, Hashable {
    let bundleID: String
    let receiptIDs: [String]
    let receiptKinds: [AmbitionsOSLivingDreamTrustReceiptKind]
    let sourceReviewReceiptIDs: [String]
    let mutationReceiptIDs: [String]
    let refusalReceiptIDs: [String]
    let issues: [AmbitionsOSLivingDreamTrustReceiptIssue]

    var readiness: AmbitionsOSLivingDreamTrustReceiptReadiness {
        if issues.contains(.runtimeBoundaryBroken) ||
            issues.contains(.userDataServerBoundaryBroken) ||
            issues.contains(.hiddenReceipt) ||
            issues.contains(.unsafeTranslationClaim) {
            return .blocked
        }
        if issues.contains(.professionalBoundaryReviewRequired) {
            return .needsProfessionalReview
        }
        if issues.contains(.silentMutationRisk) ||
            issues.contains(.mutationMissingUserApproval) {
            return .needsMutationReview
        }
        if issues.contains(.sourceReviewRequired) ||
            issues.contains(.staleSourceReviewRequired) ||
            issues.contains(.unverifiedSourceReviewRequired) ||
            issues.contains(.missingSourceReference) ||
            issues.contains(.ocrReviewRequired) {
            return .needsSourceReview
        }
        if issues.contains(.missingUserControl) ||
            issues.contains(.missingHandlingLane) ||
            issues.contains(.refusalMissingSafeAlternative) ||
            issues.contains(.malformedReceipt) ||
            issues.contains(.malformedBundle) ||
            issues.contains(.unsupportedSchema) {
            return .needsUserReview
        }
        return .ready
    }
}

struct AmbitionsOSLivingDreamTrustReceiptValidator: Sendable, Equatable, Hashable {
    func validate(
        bundle: AmbitionsOSLivingDreamTrustReceiptBundle
    ) -> [AmbitionsOSLivingDreamTrustReceiptIssue] {
        var issues: Set<AmbitionsOSLivingDreamTrustReceiptIssue> = []

        if bundle.schemaVersion != ambitionsOSLivingDreamTrustReceiptSchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if bundle.isWellFormed == false {
            issues.insert(.malformedBundle)
        }
        if bundle.allowsActivation || bundle.mutatesCommitments {
            issues.insert(.silentMutationRisk)
        }
        if bundle.usesUserDataServer {
            issues.insert(.userDataServerBoundaryBroken)
        }
        if bundle.runtimeBoundary.isValueModelOnly == false {
            issues.insert(.runtimeBoundaryBroken)
        }

        for receipt in bundle.receipts {
            validate(receipt: receipt, issues: &issues)
        }

        return issues.sorted { $0.rawValue < $1.rawValue }
    }

    func evaluate(
        bundle: AmbitionsOSLivingDreamTrustReceiptBundle
    ) -> AmbitionsOSLivingDreamTrustReceiptEvaluation {
        AmbitionsOSLivingDreamTrustReceiptEvaluation(
            bundleID: bundle.id,
            receiptIDs: bundle.receipts.map(\.id),
            receiptKinds: Array(Set(bundle.receipts.map(\.kind))).sorted { $0.rawValue < $1.rawValue },
            sourceReviewReceiptIDs: bundle.receipts
                .filter { [.sourceReview, .staleSourceReview, .unverifiedSourceReview, .userImportedSource, .ocrReview, .packUpdate].contains($0.kind) }
                .map(\.id),
            mutationReceiptIDs: bundle.receipts
                .filter { [.mutationReview, .packUpdate].contains($0.kind) || $0.mutatesCommitments }
                .map(\.id),
            refusalReceiptIDs: bundle.receipts
                .filter { $0.kind == .refusal }
                .map(\.id),
            issues: validate(bundle: bundle)
        )
    }

    private func validate(
        receipt: AmbitionsOSLivingDreamTrustReceipt,
        issues: inout Set<AmbitionsOSLivingDreamTrustReceiptIssue>
    ) {
        if receipt.schemaVersion != ambitionsOSLivingDreamTrustReceiptSchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if receipt.isWellFormed == false {
            issues.insert(.malformedReceipt)
        }
        if receipt.kind == .handling && receipt.handlingLane == nil {
            issues.insert(.missingHandlingLane)
        }
        if requiresSourceReference(receipt.kind) && receipt.hasSourceReference == false {
            issues.insert(.missingSourceReference)
        }
        if receipt.sourceState.canDriveSourceSensitiveRecommendation == false ||
            receipt.reviewState.blocksAutomaticMutation {
            issues.insert(.sourceReviewRequired)
        }
        if receipt.freshnessState.blocksHighRiskUse {
            issues.insert(.staleSourceReviewRequired)
        }
        if receipt.kind == .unverifiedSourceReview && receipt.reviewState != .ready {
            issues.insert(.unverifiedSourceReviewRequired)
        }
        if receipt.kind == .ocrReview && receipt.reviewState != .ready {
            issues.insert(.ocrReviewRequired)
        }
        if receipt.kind == .mutationReview || receipt.kind == .packUpdate || receipt.mutatesCommitments {
            validateMutation(receipt, issues: &issues)
        }
        if receipt.kind == .refusal && receipt.safeAlternativeSummary?.isEmpty != false {
            issues.insert(.refusalMissingSafeAlternative)
        }
        if receipt.kind == .safeTranslation {
            if receipt.originalTextSummary?.isEmpty != false ||
                receipt.translatedTextSummary?.isEmpty != false ||
                receipt.containsUnsafeTranslationLanguage {
                issues.insert(.unsafeTranslationClaim)
            }
        }
        if receipt.hasUserControl == false {
            issues.insert(.missingUserControl)
        }
        if receipt.visibleToUser == false {
            issues.insert(.hiddenReceipt)
        }
        if receipt.professionalBoundaryReviewRequired {
            issues.insert(.professionalBoundaryReviewRequired)
        }
        if receipt.usesUserDataServer {
            issues.insert(.userDataServerBoundaryBroken)
        }
        if receipt.runtimeBoundary.isValueModelOnly == false {
            issues.insert(.runtimeBoundaryBroken)
        }
    }

    private func validateMutation(
        _ receipt: AmbitionsOSLivingDreamTrustReceipt,
        issues: inout Set<AmbitionsOSLivingDreamTrustReceiptIssue>
    ) {
        if receipt.mutationPermission.permitsMutation == false ||
            receipt.reviewState != .ready ||
            receipt.changedFactSummaries.isEmpty {
            issues.insert(.mutationMissingUserApproval)
        }
        if receipt.mutatesCommitments && (receipt.reversible == false || receipt.mutationPermission.permitsMutation == false) {
            issues.insert(.silentMutationRisk)
        }
    }

    private func requiresSourceReference(_ kind: AmbitionsOSLivingDreamTrustReceiptKind) -> Bool {
        switch kind {
        case .sourceReview, .staleSourceReview, .unverifiedSourceReview,
             .userImportedSource, .ocrReview, .packUpdate, .safeTranslation:
            return true
        case .handling, .userConfirmation, .mutationReview, .refusal:
            return false
        }
    }
}
