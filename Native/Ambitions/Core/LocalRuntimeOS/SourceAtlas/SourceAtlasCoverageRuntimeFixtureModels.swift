import Foundation

let sourceAtlasCoverageRuntimeFixtureSchemaVersion = "runtime_fixture.v1"

enum SourceAtlasCoverageRuntimeFixtureFamily: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case runtime
    case startHere = "start-here"
    case realityMeridian = "reality-meridian"
    case closure
    case recovery
    case freshness
    case privacy
    case replay
}

enum SourceAtlasCoverageRuntimeFixtureIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case invalidFixtureIdentity = "invalid_fixture_identity"
    case invalidCandidateIdentity = "invalid_candidate_identity"
    case missingScenarioLink = "missing_scenario_link"
    case invalidInputHash = "invalid_input_hash"
    case lowCandidateScore = "low_candidate_score"
    case missingDerivativeNotice = "missing_derivative_notice"
    case missingProofBoundary = "missing_proof_boundary"
    case missingExpectedTestBehavior = "missing_expected_test_behavior"
    case missingPrivacyBoundary = "missing_privacy_boundary"
    case missingLocalOnlyRequirement = "missing_local_only_requirement"
    case unsafeNetworkOrProviderBoundary = "unsafe_network_or_provider_boundary"
}

struct SourceAtlasCoverageRuntimeFixture: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let version: String
    let family: SourceAtlasCoverageRuntimeFixtureFamily
    let candidateID: String
    let scenarioIDs: [String]
    let inputHash: String
    let candidateScore: Int
    let generatedDerivativeNotice: Bool
    let cannotSatisfyProofAlone: Bool
    let expectedTestBehavior: String
    let privacyBoundary: String
    let localOnlyRequirement: String

    enum CodingKeys: String, CodingKey {
        case id
        case version
        case family
        case candidateID = "candidate_id"
        case scenarioIDs = "scenario_ids"
        case inputHash = "input_hash"
        case candidateScore = "candidate_score"
        case generatedDerivativeNotice = "generated_derivative_notice"
        case cannotSatisfyProofAlone = "cannot_satisfy_proof_alone"
        case expectedTestBehavior = "expected_test_behavior"
        case privacyBoundary = "privacy_boundary"
        case localOnlyRequirement = "local_only_requirement"
    }

    var runtimeBoundary: SourceAtlasRuntimeBoundary {
        .valueModelOnly
    }

    var canDriveRuntimeProofAlone: Bool {
        false
    }

    var validationIssues: [SourceAtlasCoverageRuntimeFixtureIssue] {
        SourceAtlasCoverageRuntimeFixtureValidator().validate(self)
    }

    var isValidRuntimeFixtureInput: Bool {
        validationIssues.isEmpty
    }

    func validatedForRuntimeFixtureUse() throws -> SourceAtlasCoverageRuntimeFixture {
        try SourceAtlasCoverageRuntimeFixtureValidator().validated(self)
    }
}

struct SourceAtlasCoverageRuntimeFixtureValidator: Sendable, Equatable, Hashable {
    struct ValidationError: Error, Equatable {
        let issues: [SourceAtlasCoverageRuntimeFixtureIssue]
    }

    func validate(_ fixture: SourceAtlasCoverageRuntimeFixture) -> [SourceAtlasCoverageRuntimeFixtureIssue] {
        var issues: Set<SourceAtlasCoverageRuntimeFixtureIssue> = []

        if fixture.version != sourceAtlasCoverageRuntimeFixtureSchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if fixture.id.hasPrefix("fixture.") == false {
            issues.insert(.invalidFixtureIdentity)
        }
        if fixture.candidateID.hasPrefix("candidate.") == false {
            issues.insert(.invalidCandidateIdentity)
        }
        if fixture.scenarioIDs.isEmpty || fixture.scenarioIDs.contains(where: { $0.hasPrefix("scenario.") == false }) {
            issues.insert(.missingScenarioLink)
        }
        if Self.isSHA256Hex(fixture.inputHash) == false {
            issues.insert(.invalidInputHash)
        }
        if fixture.candidateScore < 85 {
            issues.insert(.lowCandidateScore)
        }
        if fixture.generatedDerivativeNotice == false {
            issues.insert(.missingDerivativeNotice)
        }
        if fixture.cannotSatisfyProofAlone == false || fixture.canDriveRuntimeProofAlone {
            issues.insert(.missingProofBoundary)
        }
        if fixture.expectedTestBehavior.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            issues.insert(.missingExpectedTestBehavior)
        }
        if fixture.privacyBoundary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            issues.insert(.missingPrivacyBoundary)
        }
        if fixture.localOnlyRequirement.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            issues.insert(.missingLocalOnlyRequirement)
        }
        if Self.hasUnsafeBoundaryLanguage(fixture.localOnlyRequirement) ||
            Self.hasUnsafeBoundaryLanguage(fixture.privacyBoundary) {
            issues.insert(.unsafeNetworkOrProviderBoundary)
        }

        return SourceAtlasCoverageRuntimeFixtureIssue.allCases.filter { issues.contains($0) }
    }

    func validated(_ fixture: SourceAtlasCoverageRuntimeFixture) throws -> SourceAtlasCoverageRuntimeFixture {
        let issues = validate(fixture)
        guard issues.isEmpty else {
            throw ValidationError(issues: issues)
        }
        return fixture
    }

    private static func isSHA256Hex(_ value: String) -> Bool {
        value.count == 64 && value.allSatisfy { character in
            character.isNumber ||
                ("a"..."f").contains(character) ||
                ("A"..."F").contains(character)
        }
    }

    private static func hasUnsafeBoundaryLanguage(_ value: String) -> Bool {
        let lowered = value.lowercased()
        let forbidden = [
            "requires network",
            "requires api key",
            "requires hosted inference",
            "requires external service",
            "send personal data",
            "external model required",
            "generated pack is proof"
        ]
        return forbidden.contains { lowered.contains($0) }
    }
}
