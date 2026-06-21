import Foundation

struct RepoTruthAuditEntry: Identifiable, Codable, Equatable, Sendable {
    var id: String
    var path: String
    var currentResponsibility: String
    var canonicalLayer: RepoTruthCanonicalLayer
    var productOwner: RepoTruthProductOwner
    var implementationStatus: RepoTruthImplementationStatus
    var designTruthViolations: [String]
    var languageViolations: [String]
    var runtimeMutationBehavior: RepoTruthMutationBehavior
    var accessibilityCoverage: RepoTruthAccessibilityCoverage
    var chromeSafeAreaRisk: RepoTruthChromeSafeAreaRisk
    var splitRecommendation: RepoTruthSplitRecommendation
    var proofRequired: [RepoTruthProofArtifactRequirement]
    var status: RepoTruthAuditStatus

    init(
        id: String,
        path: String,
        currentResponsibility: String,
        canonicalLayer: RepoTruthCanonicalLayer,
        productOwner: RepoTruthProductOwner,
        implementationStatus: RepoTruthImplementationStatus,
        designTruthViolations: [String] = [],
        languageViolations: [String] = [],
        runtimeMutationBehavior: RepoTruthMutationBehavior,
        accessibilityCoverage: RepoTruthAccessibilityCoverage,
        chromeSafeAreaRisk: RepoTruthChromeSafeAreaRisk,
        splitRecommendation: RepoTruthSplitRecommendation,
        proofRequired: [RepoTruthProofArtifactRequirement],
        status: RepoTruthAuditStatus
    ) {
        self.id = id
        self.path = path
        self.currentResponsibility = currentResponsibility
        self.canonicalLayer = canonicalLayer
        self.productOwner = productOwner
        self.implementationStatus = implementationStatus
        self.designTruthViolations = designTruthViolations
        self.languageViolations = languageViolations
        self.runtimeMutationBehavior = runtimeMutationBehavior
        self.accessibilityCoverage = accessibilityCoverage
        self.chromeSafeAreaRisk = chromeSafeAreaRisk
        self.splitRecommendation = splitRecommendation
        self.proofRequired = proofRequired
        self.status = status
    }
}

enum RepoTruthCanonicalLayer: String, Codable, CaseIterable, Sendable {
    case app
    case stage
    case coreDomain
    case runtime
    case persistence
    case permissions
    case projection
    case rendering
    case designSystem
    case language
    case trust
    case interaction
    case surface
    case composer
    case scenario
    case diagnostics
    case quality
    case sourceAtlas
    case externalSurface
    case widget
    case shareExtension
    case previewSupport
    case tests
    case truthDocs
    case auditDocs
    case validationDocs
    case codexGovernance
    case scripts
    case resources
    case projectConfig
    case supportingDocs
    case repoSupport
}

enum RepoTruthProductOwner: String, Codable, CaseIterable, Sendable {
    case today
    case goals
    case time
    case you
    case capture
    case motion
    case trustInspection
    case privateLifeRuntime
    case sourceAtlasR2
    case account
    case stageShell
    case designSystem
    case accessibility
    case releaseProof
    case codexGovernance
    case externalSurface
    case widget
    case shareExtension
    case broadRepo
}

enum RepoTruthImplementationStatus: String, Codable, CaseIterable, Sendable {
    case realImplementation = "real implementation"
    case realBoundaryBridge = "real boundary bridge"
    case stub
    case fixture
    case previewOnly = "preview-only"
    case testOnly = "test-only"
    case deadCode = "dead code"
    case obsoleteCanon = "obsolete canon"
    case obsoleteArchitecture = "obsolete architecture"
    case duplicateResponsibility = "duplicate responsibility"
    case mixedResponsibility = "mixed responsibility"
    case oversized
    case needsSplit = "needs split"
    case needsHardening = "needs hardening"
    case deleteCandidate = "delete candidate"
}

enum RepoTruthMutationBehavior: String, Codable, CaseIterable, Sendable {
    case mutatingRuntimePath = "mutating runtime path"
    case projectionOnly = "projection only"
    case displayOnly = "display only"
    case nonMutatingControlRisk = "non-mutating control risk"
    case diagnosticOnly = "diagnostic only"
    case documentationOnly = "documentation only"
    case testOnly = "test only"
    case notApplicable = "not applicable"
}

enum RepoTruthAccessibilityCoverage: String, Codable, CaseIterable, Sendable {
    case explicitCoverage = "explicit coverage"
    case partialCoverage = "partial coverage"
    case semanticMirrorPresent = "semantic mirror present"
    case testCoverage = "test coverage"
    case documentationOnly = "documentation only"
    case notFound = "not found"
    case notApplicable = "not applicable"
}

enum RepoTruthChromeSafeAreaRisk: String, Codable, CaseIterable, Sendable {
    case none
    case rootShellRisk = "root shell risk"
    case drilldownDockRisk = "drilldown dock risk"
    case keyboardOverlayRisk = "keyboard overlay risk"
    case duplicateNavigationRisk = "duplicate navigation risk"
    case dynamicTypeRisk = "dynamic type risk"
    case notApplicable = "not applicable"
}

enum RepoTruthSplitRecommendation: String, Codable, CaseIterable, Sendable {
    case keep
    case split
    case harden
    case replace
    case moveToTests = "move to tests"
    case moveToPreviews = "move to previews"
    case delete
    case generatedException = "generated exception"
    case notApplicable = "not applicable"
}

enum RepoTruthProofArtifactRequirement: String, Codable, CaseIterable, Sendable {
    case build
    case focusedTests = "focused tests"
    case auditCheck = "audit check"
    case forbiddenLanguageScan = "forbidden language scan"
    case architectureConformanceScan = "architecture conformance scan"
    case largeFileAudit = "large file audit"
    case stubBridgeAudit = "stub bridge audit"
    case screenshotMatrix = "screenshot matrix"
    case accessibilityNotes = "accessibility notes"
    case mutationProof = "mutation proof"
    case authorityReadback = "authority readback"
    case notApplicable = "not applicable"
}

enum RepoTruthAuditStatus: String, Codable, CaseIterable, Sendable {
    case green = "Green"
    case yellow = "Yellow"
    case red = "Red"
    case delete = "Delete"
    case keep = "Keep"
    case split = "Split"
    case replace = "Replace"
    case testOnly = "Test-only"
}
