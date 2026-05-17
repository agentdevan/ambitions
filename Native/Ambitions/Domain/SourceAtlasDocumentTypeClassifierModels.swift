import Foundation

let sourceAtlasDocumentTypeClassifierSchemaVersion = "source_atlas_document_type_classifier.native.v1"

enum SourceAtlasDocumentType: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case rulebook
    case schoolProgramPage = "school_program_page"
    case jobPosting = "job_posting"
    case certificationHandbook = "certification_handbook"
    case officialPage = "official_page"
    case genericText = "generic_text"
    case legalCivicProfessionalSource = "legal_civic_professional_source"
}

struct SourceAtlasDocumentTypeClassifierInput: Codable, Sendable, Equatable, Hashable {
    let title: String
    let bodyText: String
    let sourceLocator: String?
    let hasOfficialSourceProof: Bool
    let hasLocalProof: Bool
    let declaredSourceState: SourceAtlasRequirementSourceState
    let declaredFreshnessState: SourceAtlasFreshnessState

    init(
        title: String,
        bodyText: String,
        sourceLocator: String? = nil,
        hasOfficialSourceProof: Bool = false,
        hasLocalProof: Bool = false,
        declaredSourceState: SourceAtlasRequirementSourceState = .unknown,
        declaredFreshnessState: SourceAtlasFreshnessState = .unknown
    ) {
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.bodyText = bodyText.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceLocator = sourceLocator?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.hasOfficialSourceProof = hasOfficialSourceProof
        self.hasLocalProof = hasLocalProof
        self.declaredSourceState = declaredSourceState
        self.declaredFreshnessState = declaredFreshnessState
    }
}

struct SourceAtlasDocumentTypeClassifierBehavior: Codable, Sendable, Equatable, Hashable {
    let performsNetworkAccess: Bool
    let persistsState: Bool
    let mutatesState: Bool
    let makesReleaseClaims: Bool

    static let valueModelOnly = SourceAtlasDocumentTypeClassifierBehavior(
        performsNetworkAccess: false,
        persistsState: false,
        mutatesState: false,
        makesReleaseClaims: false
    )
}

struct SourceAtlasDocumentClaimBoundary: Codable, Sendable, Equatable, Hashable {
    let allowsOfficialLabel: Bool
    let allowsCurrentLabel: Bool
    let requiresStrictReview: Bool
    let treatsAsExampleOnly: Bool
    let requiresExplicitSourceProof: Bool
    let canSupportOfficialCurrentClaim: Bool
    let canSupportLocalProofClaim: Bool
}

struct SourceAtlasDocumentTypeClassifierDecision: Codable, Sendable, Equatable, Hashable {
    let documentType: SourceAtlasDocumentType
    let sourceKindRecommendation: SourceAtlasSourceKind
    let provenanceRecommendation: SourceAtlasSourceContainerProvenanceState
    let riskClass: SourceAtlasRiskClass
    let reviewState: HumanProgressReviewState
    let requirementSourceState: SourceAtlasRequirementSourceState
    let freshnessState: SourceAtlasFreshnessState
    let claimBoundary: SourceAtlasDocumentClaimBoundary
    let behavior: SourceAtlasDocumentTypeClassifierBehavior
    let schemaVersion: String
}

struct SourceAtlasDocumentTypeClassifier: Sendable, Equatable, Hashable {
    func classify(_ input: SourceAtlasDocumentTypeClassifierInput) -> SourceAtlasDocumentTypeClassifierDecision {
        let corpus = Self.normalizedCorpus(title: input.title, bodyText: input.bodyText, sourceLocator: input.sourceLocator)
        let documentType = Self.documentType(for: corpus, hasOfficialSourceProof: input.hasOfficialSourceProof)
        let riskClass = Self.riskClass(for: documentType, corpus: corpus)
        let freshnessState = Self.freshnessState(
            for: documentType,
            corpus: corpus,
            declaredFreshnessState: input.declaredFreshnessState,
            hasOfficialSourceProof: input.hasOfficialSourceProof
        )
        let requirementSourceState = Self.requirementSourceState(
            for: documentType,
            declaredSourceState: input.declaredSourceState,
            declaredFreshnessState: freshnessState,
            hasOfficialSourceProof: input.hasOfficialSourceProof,
            hasLocalProof: input.hasLocalProof
        )
        let sourceKindRecommendation = Self.sourceKindRecommendation(
            for: documentType,
            hasOfficialSourceProof: input.hasOfficialSourceProof,
            hasLocalProof: input.hasLocalProof
        )
        let provenanceRecommendation = Self.provenanceRecommendation(
            for: documentType,
            hasOfficialSourceProof: input.hasOfficialSourceProof,
            hasLocalProof: input.hasLocalProof
        )
        let reviewState = Self.reviewState(
            documentType: documentType,
            riskClass: riskClass,
            requirementSourceState: requirementSourceState,
            freshnessState: freshnessState,
            hasOfficialSourceProof: input.hasOfficialSourceProof,
            hasLocalProof: input.hasLocalProof
        )
        let claimBoundary = Self.claimBoundary(
            documentType: documentType,
            sourceKindRecommendation: sourceKindRecommendation,
            provenanceRecommendation: provenanceRecommendation,
            riskClass: riskClass,
            reviewState: reviewState,
            requirementSourceState: requirementSourceState,
            freshnessState: freshnessState,
            hasOfficialSourceProof: input.hasOfficialSourceProof,
            hasLocalProof: input.hasLocalProof
        )

        return SourceAtlasDocumentTypeClassifierDecision(
            documentType: documentType,
            sourceKindRecommendation: sourceKindRecommendation,
            provenanceRecommendation: provenanceRecommendation,
            riskClass: riskClass,
            reviewState: reviewState,
            requirementSourceState: requirementSourceState,
            freshnessState: freshnessState,
            claimBoundary: claimBoundary,
            behavior: .valueModelOnly,
            schemaVersion: sourceAtlasDocumentTypeClassifierSchemaVersion
        )
    }

    private static func documentType(
        for corpus: String,
        hasOfficialSourceProof: Bool
    ) -> SourceAtlasDocumentType {
        if Self.matchesLegalCivicProfessional(corpus) {
            return .legalCivicProfessionalSource
        }
        if Self.matchesCertificationHandbook(corpus) {
            return .certificationHandbook
        }
        if Self.matchesSchoolProgramPage(corpus) {
            return .schoolProgramPage
        }
        if Self.matchesJobPosting(corpus) {
            return .jobPosting
        }
        if Self.matchesRulebook(corpus) {
            return .rulebook
        }
        if hasOfficialSourceProof || Self.matchesOfficialPage(corpus) {
            return .officialPage
        }
        return .genericText
    }

    private static func riskClass(
        for documentType: SourceAtlasDocumentType,
        corpus: String
    ) -> SourceAtlasRiskClass {
        switch documentType {
        case .rulebook:
            return corpus.contains("legal") || corpus.contains("compliance") ? .professionalBoundary : .sportRules
        case .schoolProgramPage:
            return .educationEligibility
        case .jobPosting:
            return .careerContext
        case .certificationHandbook:
            return .certificationEligibility
        case .officialPage:
            if corpus.contains("law") || corpus.contains("regulation") || corpus.contains("court") || corpus.contains("statute") {
                return .legalCivic
            }
            return .professionalBoundary
        case .genericText:
            return .lowRiskSkill
        case .legalCivicProfessionalSource:
            if corpus.contains("law") || corpus.contains("regulation") || corpus.contains("court") || corpus.contains("statute") {
                return .legalCivic
            }
            return .professionalBoundary
        }
    }

    private static func freshnessState(
        for documentType: SourceAtlasDocumentType,
        corpus: String,
        declaredFreshnessState: SourceAtlasFreshnessState,
        hasOfficialSourceProof: Bool
    ) -> SourceAtlasFreshnessState {
        switch declaredFreshnessState {
        case .stale, .staleCritical, .sourceChanged, .disputed, .revoked, .unknown, .userProvided, .needsReview, .aging:
            return declaredFreshnessState
        case .current:
            return hasOfficialSourceProof && Self.hasCurrentSignal(corpus) ? .current : .needsReview
        }
    }

    private static func requirementSourceState(
        for documentType: SourceAtlasDocumentType,
        declaredSourceState: SourceAtlasRequirementSourceState,
        declaredFreshnessState: SourceAtlasFreshnessState,
        hasOfficialSourceProof: Bool,
        hasLocalProof: Bool
    ) -> SourceAtlasRequirementSourceState {
        switch declaredSourceState {
        case .unknown:
            if hasLocalProof {
                return .locallyProven
            }
            if hasOfficialSourceProof {
                return declaredFreshnessState == .current ? .officialCurrent : .official
            }
            switch documentType {
            case .genericText:
                return .unknown
            case .rulebook, .schoolProgramPage, .jobPosting, .certificationHandbook, .officialPage, .legalCivicProfessionalSource:
                return .sourceNeeded
            }
        case .sourceNeeded:
            if hasLocalProof {
                return .locallyProven
            }
            if hasOfficialSourceProof {
                return declaredFreshnessState == .current ? .officialCurrent : .official
            }
            return .sourceNeeded
        case .stale, .contradicted, .revoked, .locallyProven:
            return declaredSourceState
        case .official, .officialCurrent, .current:
            return hasOfficialSourceProof && declaredFreshnessState == .current ? .officialCurrent : .sourceNeeded
        }
    }

    private static func sourceKindRecommendation(
        for documentType: SourceAtlasDocumentType,
        hasOfficialSourceProof: Bool,
        hasLocalProof: Bool
    ) -> SourceAtlasSourceKind {
        if hasOfficialSourceProof {
            return .official
        }
        if hasLocalProof {
            return .userProvided
        }
        switch documentType {
        case .genericText:
            return .userProvided
        case .rulebook, .schoolProgramPage, .jobPosting, .certificationHandbook, .officialPage, .legalCivicProfessionalSource:
            return .candidate
        }
    }

    private static func provenanceRecommendation(
        for documentType: SourceAtlasDocumentType,
        hasOfficialSourceProof: Bool,
        hasLocalProof: Bool
    ) -> SourceAtlasSourceContainerProvenanceState {
        if hasOfficialSourceProof {
            return .approvedOfficial
        }
        if hasLocalProof {
            return .localFile
        }
        switch documentType {
        case .genericText:
            return .copiedContent
        case .rulebook, .schoolProgramPage, .jobPosting, .certificationHandbook, .officialPage, .legalCivicProfessionalSource:
            return .sourceAttached
        }
    }

    private static func reviewState(
        documentType: SourceAtlasDocumentType,
        riskClass: SourceAtlasRiskClass,
        requirementSourceState: SourceAtlasRequirementSourceState,
        freshnessState: SourceAtlasFreshnessState,
        hasOfficialSourceProof: Bool,
        hasLocalProof: Bool
    ) -> HumanProgressReviewState {
        if requirementSourceState == .revoked || requirementSourceState == .contradicted {
            return .needsCorrection
        }
        if requirementSourceState == .stale || freshnessState == .stale || freshnessState == .staleCritical || freshnessState == .sourceChanged {
            return .needsSourceReview
        }
        if hasOfficialSourceProof && freshnessState == .current && requirementSourceState == .officialCurrent {
            return .ready
        }
        if hasLocalProof && requirementSourceState == .locallyProven {
            return .ready
        }

        switch documentType {
        case .genericText:
            return .needsUserReview
        case .rulebook, .schoolProgramPage, .jobPosting, .certificationHandbook, .officialPage, .legalCivicProfessionalSource:
            return .needsSourceReview
        }
    }

    private static func claimBoundary(
        documentType: SourceAtlasDocumentType,
        sourceKindRecommendation: SourceAtlasSourceKind,
        provenanceRecommendation: SourceAtlasSourceContainerProvenanceState,
        riskClass: SourceAtlasRiskClass,
        reviewState: HumanProgressReviewState,
        requirementSourceState: SourceAtlasRequirementSourceState,
        freshnessState: SourceAtlasFreshnessState,
        hasOfficialSourceProof: Bool,
        hasLocalProof: Bool
    ) -> SourceAtlasDocumentClaimBoundary {
        let requiresStrictReview = riskClass.requiresStrictReview ||
            documentType == .legalCivicProfessionalSource ||
            documentType == .rulebook ||
            documentType == .schoolProgramPage ||
            documentType == .jobPosting ||
            documentType == .certificationHandbook
        let allowsOfficialLabel = hasOfficialSourceProof &&
            sourceKindRecommendation == .official &&
            provenanceRecommendation == .approvedOfficial &&
            requirementSourceState == .officialCurrent &&
            freshnessState == .current
        let allowsCurrentLabel = allowsOfficialLabel
        let canSupportOfficialCurrentClaim = allowsOfficialLabel && reviewState == .ready
        let canSupportLocalProofClaim = hasLocalProof &&
            requirementSourceState == .locallyProven &&
            reviewState == .ready
        let treatsAsExampleOnly = documentType == .jobPosting

        return SourceAtlasDocumentClaimBoundary(
            allowsOfficialLabel: allowsOfficialLabel,
            allowsCurrentLabel: allowsCurrentLabel,
            requiresStrictReview: requiresStrictReview,
            treatsAsExampleOnly: treatsAsExampleOnly,
            requiresExplicitSourceProof: hasOfficialSourceProof == false,
            canSupportOfficialCurrentClaim: canSupportOfficialCurrentClaim,
            canSupportLocalProofClaim: canSupportLocalProofClaim
        )
    }

    private static func normalizedCorpus(
        title: String,
        bodyText: String,
        sourceLocator: String?
    ) -> String {
        [title, bodyText, sourceLocator ?? ""]
            .joined(separator: " ")
            .lowercased()
    }

    private static func matchesRulebook(_ corpus: String) -> Bool {
        corpus.contains("rulebook") ||
            corpus.contains("rules") ||
            corpus.contains("scoring") ||
            corpus.contains("equipment") ||
            corpus.contains("eligibility") ||
            corpus.contains("governing body")
    }

    private static func matchesSchoolProgramPage(_ corpus: String) -> Bool {
        corpus.contains("school") ||
            corpus.contains("program") ||
            corpus.contains("admissions") ||
            corpus.contains("tuition") ||
            corpus.contains("credits") ||
            corpus.contains("degree") ||
            corpus.contains("certificate") ||
            corpus.contains("residency") ||
            corpus.contains("accreditation")
    }

    private static func matchesJobPosting(_ corpus: String) -> Bool {
        corpus.contains("job posting") ||
            corpus.contains("position") ||
            corpus.contains("role") ||
            corpus.contains("employer") ||
            corpus.contains("responsibilities") ||
            corpus.contains("required") ||
            corpus.contains("preferred") ||
            corpus.contains("salary") ||
            corpus.contains("apply")
    }

    private static func matchesCertificationHandbook(_ corpus: String) -> Bool {
        corpus.contains("certification") ||
            corpus.contains("handbook") ||
            corpus.contains("exam") ||
            corpus.contains("renewal") ||
            corpus.contains("continuing education") ||
            corpus.contains("credential") ||
            corpus.contains("issuing body")
    }

    private static func matchesLegalCivicProfessional(_ corpus: String) -> Bool {
        corpus.contains("statute") ||
            corpus.contains("ordinance") ||
            corpus.contains("regulation") ||
            corpus.contains("court") ||
            corpus.contains("law") ||
            corpus.contains("jurisdiction") ||
            corpus.contains("bar association") ||
            corpus.contains("professional code") ||
            corpus.contains("compliance")
    }

    private static func matchesOfficialPage(_ corpus: String) -> Bool {
        corpus.contains("official page") ||
            corpus.contains("official website") ||
            corpus.contains("published by") ||
            corpus.contains("agency") ||
            corpus.contains("department")
    }

    private static func hasCurrentSignal(_ corpus: String) -> Bool {
        corpus.contains("effective") ||
            corpus.contains("current") ||
            corpus.contains("updated") ||
            corpus.contains("revised") ||
            corpus.contains("as of") ||
            corpus.contains("published")
    }

    private static func hasStaleSignal(_ corpus: String) -> Bool {
        corpus.contains("stale") ||
            corpus.contains("archived") ||
            corpus.contains("outdated") ||
            corpus.contains("expired") ||
            corpus.contains("superseded") ||
            corpus.contains("older version")
    }

    private static func hasContradictionSignal(_ corpus: String) -> Bool {
        corpus.contains("contradicted") ||
            corpus.contains("conflicts with") ||
            corpus.contains("inconsistent") ||
            corpus.contains("retracted")
    }

    private static func hasRevokedSignal(_ corpus: String) -> Bool {
        corpus.contains("revoked") ||
            corpus.contains("withdrawn") ||
            corpus.contains("rescinded")
    }
}
