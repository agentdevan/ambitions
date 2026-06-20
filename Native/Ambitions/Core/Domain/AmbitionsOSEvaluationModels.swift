import Foundation

let ambitionsOSEvaluationSchemaVersion = "ambitionsos_evaluation.native.v1"

enum AmbitionsOSEvaluationScenarioKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case golden
    case redTeam = "red_team"
    case regressionOracle = "regression_oracle"
    case claimTruth = "claim_truth"
    case privacyLeak = "privacy_leak"
    case sourceProfessionalBoundary = "source_professional_boundary"
    case ldiRedTeam = "ldi_red_team"
}

enum AmbitionsOSEvaluationRiskClass: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case low
    case medium
    case high
    case critical
}

enum AmbitionsOSEvaluationValidationStatus: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case draft
    case ready
    case passed
    case yellow
    case failed
    case blocked
}

enum AmbitionsOSEvaluationProfessionalBoundaryState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case notApplicable = "not_applicable"
    case reviewRequired = "review_required"
    case reviewReady = "review_ready"
    case blocked
}

enum AmbitionsOSEvaluationClaimBoundaryState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case noClaim = "no_claim"
    case evidenceRequired = "evidence_required"
    case evidenceBacked = "evidence_backed"
    case unsupportedClaim = "unsupported_claim"
}

enum AmbitionsOSEvaluationIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case malformedSuite = "malformed_suite"
    case malformedScenario = "malformed_scenario"
    case minimumGoldenScenarioMissing = "minimum_golden_scenario_missing"
    case minimumRedTeamScenarioMissing = "minimum_red_team_scenario_missing"
    case minimumClaimTruthScenarioMissing = "minimum_claim_truth_scenario_missing"
    case minimumPrivacyLeakScenarioMissing = "minimum_privacy_leak_scenario_missing"
    case fixtureCoverageMissing = "fixture_coverage_missing"
    case deterministicOracleMissing = "deterministic_oracle_missing"
    case sourceSensitiveWithoutReview = "source_sensitive_without_review"
    case privacyProjectionMissing = "privacy_projection_missing"
    case professionalBoundaryOwnerMissing = "professional_boundary_owner_missing"
    case unsupportedClaimBoundary = "unsupported_claim_boundary"
    case missingRepairOwnerForYellow = "missing_repair_owner_for_yellow"
    case passedWithoutEvidence = "passed_without_evidence"
    case modelRequiredCorePath = "model_required_core_path"
    case hiddenMutationRisk = "hidden_mutation_risk"
    case runtimeStoreBehavior = "runtime_store_behavior"
}

struct AmbitionsOSEvaluationReceipt: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let commandOrReview: String
    let occurredAt: String
    let passed: Bool
    let evidenceLink: String

    init(
        id: String,
        commandOrReview: String,
        occurredAt: String,
        passed: Bool,
        evidenceLink: String
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.commandOrReview = commandOrReview.trimmingCharacters(in: .whitespacesAndNewlines)
        self.occurredAt = occurredAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.passed = passed
        self.evidenceLink = evidenceLink.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            commandOrReview.isEmpty == false &&
            occurredAt.isEmpty == false &&
            evidenceLink.isEmpty == false
    }
}

struct AmbitionsOSEvaluationScenario: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let kind: AmbitionsOSEvaluationScenarioKind
    let surface: AmbitionsOSControlPlaneSurface
    let kernelOwner: String
    let fixtureFamilies: [String]
    let riskClass: AmbitionsOSEvaluationRiskClass
    let sourceState: HumanProgressSourceState
    let freshnessState: HumanProgressFreshnessState
    let reviewState: HumanProgressReviewState
    let privacyClass: HumanProgressPrivacyClass
    let sensitiveAreas: [AmbitionsOSPrivacySensitiveArea]
    let projectionPolicy: AmbitionsOSPrivacyProjectionPolicy
    let professionalBoundaryState: AmbitionsOSEvaluationProfessionalBoundaryState
    let claimBoundaryState: AmbitionsOSEvaluationClaimBoundaryState
    let expectedSafeBehavior: String
    let forbiddenBehaviors: [String]
    let deterministicOracleIDs: [String]
    let validationStatus: AmbitionsOSEvaluationValidationStatus
    let repairOwner: String
    let evidenceLinks: [String]
    let ldiRedTeamFamilyIDs: [String]
    let deterministicFallbackAvailable: Bool
    let changesAppState: Bool
    let runtimeBoundary: SourceAtlasRuntimeBoundary
    let schemaVersion: String

    init(
        id: String,
        title: String,
        kind: AmbitionsOSEvaluationScenarioKind,
        surface: AmbitionsOSControlPlaneSurface,
        kernelOwner: String = "Evaluation Kernel",
        fixtureFamilies: [String],
        riskClass: AmbitionsOSEvaluationRiskClass,
        sourceState: HumanProgressSourceState = .userConfirmed,
        freshnessState: HumanProgressFreshnessState = .notApplicable,
        reviewState: HumanProgressReviewState = .ready,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        sensitiveAreas: [AmbitionsOSPrivacySensitiveArea] = [],
        projectionPolicy: AmbitionsOSPrivacyProjectionPolicy = .redactedLocal,
        professionalBoundaryState: AmbitionsOSEvaluationProfessionalBoundaryState = .notApplicable,
        claimBoundaryState: AmbitionsOSEvaluationClaimBoundaryState = .noClaim,
        expectedSafeBehavior: String,
        forbiddenBehaviors: [String],
        deterministicOracleIDs: [String],
        validationStatus: AmbitionsOSEvaluationValidationStatus = .ready,
        repairOwner: String = "",
        evidenceLinks: [String] = [],
        ldiRedTeamFamilyIDs: [String] = [],
        deterministicFallbackAvailable: Bool = true,
        changesAppState: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        schemaVersion: String = ambitionsOSEvaluationSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.kind = kind
        self.surface = surface
        self.kernelOwner = kernelOwner.trimmingCharacters(in: .whitespacesAndNewlines)
        self.fixtureFamilies = Self.orderedUnique(fixtureFamilies)
        self.riskClass = riskClass
        self.sourceState = sourceState
        self.freshnessState = freshnessState
        self.reviewState = reviewState
        self.privacyClass = privacyClass
        self.sensitiveAreas = Array(Set(sensitiveAreas)).sorted { $0.rawValue < $1.rawValue }
        self.projectionPolicy = projectionPolicy
        self.professionalBoundaryState = professionalBoundaryState
        self.claimBoundaryState = claimBoundaryState
        self.expectedSafeBehavior = expectedSafeBehavior.trimmingCharacters(in: .whitespacesAndNewlines)
        self.forbiddenBehaviors = Self.orderedUnique(forbiddenBehaviors)
        self.deterministicOracleIDs = Self.orderedUnique(deterministicOracleIDs)
        self.validationStatus = validationStatus
        self.repairOwner = repairOwner.trimmingCharacters(in: .whitespacesAndNewlines)
        self.evidenceLinks = Self.orderedUnique(evidenceLinks)
        self.ldiRedTeamFamilyIDs = Self.orderedUnique(ldiRedTeamFamilyIDs)
        self.deterministicFallbackAvailable = deterministicFallbackAvailable
        self.changesAppState = changesAppState
        self.runtimeBoundary = runtimeBoundary
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            title.isEmpty == false &&
            kernelOwner.isEmpty == false &&
            fixtureFamilies.isEmpty == false &&
            expectedSafeBehavior.isEmpty == false &&
            forbiddenBehaviors.isEmpty == false &&
            schemaVersion == ambitionsOSEvaluationSchemaVersion
    }

    var isSourceSensitive: Bool {
        sourceState.canDriveSourceSensitiveRecommendation == false ||
            freshnessState.blocksHighRiskUse ||
            riskClass == .high ||
            riskClass == .critical
    }

    var isPrivacySensitive: Bool {
        privacyClass == .sensitive ||
            privacyClass == .deletePending ||
            sensitiveAreas.isEmpty == false ||
            kind == .privacyLeak
    }

    var projectsExternally: Bool {
        surface == .externalProjection ||
            fixtureFamilies.contains("external-surface-redaction") ||
            fixtureFamilies.contains("widget-privacy-projection") ||
            fixtureFamilies.contains("app-intent-privacy-projection")
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct AmbitionsOSEvaluationSuite: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let requiredFixtureFamilies: [String]
    let scenarios: [AmbitionsOSEvaluationScenario]
    let receipts: [AmbitionsOSEvaluationReceipt]
    let schemaVersion: String

    init(
        id: String,
        title: String,
        requiredFixtureFamilies: [String],
        scenarios: [AmbitionsOSEvaluationScenario],
        receipts: [AmbitionsOSEvaluationReceipt] = [],
        schemaVersion: String = ambitionsOSEvaluationSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.requiredFixtureFamilies = Self.orderedUnique(requiredFixtureFamilies)
        self.scenarios = scenarios.sorted { $0.id < $1.id }
        self.receipts = receipts.sorted { $0.id < $1.id }
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            title.isEmpty == false &&
            requiredFixtureFamilies.isEmpty == false &&
            scenarios.isEmpty == false &&
            schemaVersion == ambitionsOSEvaluationSchemaVersion &&
            receipts.allSatisfy(\.isWellFormed)
    }

    var coveredFixtureFamilies: Set<String> {
        Set(scenarios.flatMap(\.fixtureFamilies))
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct AmbitionsOSEvaluationValidator: Sendable, Equatable, Hashable {
    func validate(_ suite: AmbitionsOSEvaluationSuite) -> [AmbitionsOSEvaluationIssue] {
        var issues: Set<AmbitionsOSEvaluationIssue> = []

        validateSuiteShape(suite, issues: &issues)
        validateMinimumScenarioKinds(suite, issues: &issues)
        validateFixtureCoverage(suite, issues: &issues)
        suite.scenarios.forEach { validate($0, suite: suite, issues: &issues) }

        return issues.sorted { $0.rawValue < $1.rawValue }
    }

    private func validateSuiteShape(
        _ suite: AmbitionsOSEvaluationSuite,
        issues: inout Set<AmbitionsOSEvaluationIssue>
    ) {
        if suite.schemaVersion != ambitionsOSEvaluationSchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if suite.isWellFormed == false {
            issues.insert(.malformedSuite)
        }
    }

    private func validateMinimumScenarioKinds(
        _ suite: AmbitionsOSEvaluationSuite,
        issues: inout Set<AmbitionsOSEvaluationIssue>
    ) {
        let kinds = Set(suite.scenarios.map(\.kind))
        if kinds.contains(.golden) == false {
            issues.insert(.minimumGoldenScenarioMissing)
        }
        if kinds.contains(.redTeam) == false && kinds.contains(.ldiRedTeam) == false {
            issues.insert(.minimumRedTeamScenarioMissing)
        }
        if kinds.contains(.claimTruth) == false {
            issues.insert(.minimumClaimTruthScenarioMissing)
        }
        if kinds.contains(.privacyLeak) == false {
            issues.insert(.minimumPrivacyLeakScenarioMissing)
        }
    }

    private func validateFixtureCoverage(
        _ suite: AmbitionsOSEvaluationSuite,
        issues: inout Set<AmbitionsOSEvaluationIssue>
    ) {
        if Set(suite.requiredFixtureFamilies).isSubset(of: suite.coveredFixtureFamilies) == false {
            issues.insert(.fixtureCoverageMissing)
        }
    }

    private func validate(
        _ scenario: AmbitionsOSEvaluationScenario,
        suite: AmbitionsOSEvaluationSuite,
        issues: inout Set<AmbitionsOSEvaluationIssue>
    ) {
        if scenario.schemaVersion != ambitionsOSEvaluationSchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if scenario.isWellFormed == false {
            issues.insert(.malformedScenario)
        }
        if scenario.deterministicOracleIDs.isEmpty {
            issues.insert(.deterministicOracleMissing)
        }
        if scenario.isSourceSensitive &&
            (scenario.reviewState != .ready || scenario.freshnessState.blocksHighRiskUse) {
            issues.insert(.sourceSensitiveWithoutReview)
        }
        if scenario.isPrivacySensitive &&
            scenario.projectsExternally &&
            scenario.projectionPolicy != .externalRedacted &&
            scenario.projectionPolicy != .hidden {
            issues.insert(.privacyProjectionMissing)
        }
        if scenario.professionalBoundaryState == .reviewRequired && scenario.repairOwner.isEmpty {
            issues.insert(.professionalBoundaryOwnerMissing)
        }
        if scenario.claimBoundaryState == .unsupportedClaim {
            issues.insert(.unsupportedClaimBoundary)
        }
        if scenario.validationStatus == .yellow && scenario.repairOwner.isEmpty {
            issues.insert(.missingRepairOwnerForYellow)
        }
        if scenario.validationStatus == .passed &&
            scenario.evidenceLinks.isEmpty &&
            suite.receipts.isEmpty {
            issues.insert(.passedWithoutEvidence)
        }
        if scenario.deterministicFallbackAvailable == false {
            issues.insert(.modelRequiredCorePath)
        }
        if scenario.changesAppState {
            issues.insert(.hiddenMutationRisk)
        }
        if scenario.runtimeBoundary != .valueModelOnly {
            issues.insert(.runtimeStoreBehavior)
        }
    }
}
