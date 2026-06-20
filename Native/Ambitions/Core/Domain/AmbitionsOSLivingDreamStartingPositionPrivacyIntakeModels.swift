import Foundation

let ambitionsOSLivingDreamStartingPositionPrivacyIntakeSchemaVersion =
    "ambitionsos_living_dream_starting_position_privacy_intake.native.v1"

enum AmbitionsOSLivingDreamIntakeAnswerState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unanswered
    case answered
    case askLater = "ask_later"
    case rejected
    case sourceReviewNeeded = "source_review_needed"
    case privacyReviewNeeded = "privacy_review_needed"
}

enum AmbitionsOSLivingDreamIntakeRetentionPolicy: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case sessionOnly = "session_only"
    case localPrivate = "local_private"
    case localOnlySensitive = "local_only_sensitive"
    case excludedFromExternalProjection = "excluded_from_external_projection"

    var isLocalOnly: Bool {
        switch self {
        case .sessionOnly, .localPrivate, .localOnlySensitive, .excludedFromExternalProjection:
            return true
        }
    }
}

enum AmbitionsOSLivingDreamIntakeReadiness: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case readyForPathPortfolio = "ready_for_path_portfolio"
    case needsUserAnswer = "needs_user_answer"
    case needsSourceReview = "needs_source_review"
    case needsPrivacyReview = "needs_privacy_review"
    case eligibilityBlocked = "eligibility_blocked"
    case blocked
}

enum AmbitionsOSLivingDreamIntakeIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case malformedPacket = "malformed_packet"
    case malformedQuestion = "malformed_question"
    case duplicateQuestionID = "duplicate_question_id"
    case unnecessaryQuestion = "unnecessary_question"
    case unnecessarySensitiveIntake = "unnecessary_sensitive_intake"
    case missingStartingPositionUnknown = "missing_starting_position_unknown"
    case startingPositionNotReady = "starting_position_not_ready"
    case eligibilityNotReady = "eligibility_not_ready"
    case missingPrivacyPolicy = "missing_privacy_policy"
    case privacyPolicyNotReady = "privacy_policy_not_ready"
    case sensitiveAreaNeedsReview = "sensitive_area_needs_review"
    case localStorageBoundaryBroken = "local_storage_boundary_broken"
    case externalProjectionRisk = "external_projection_risk"
    case hiddenMutationRisk = "hidden_mutation_risk"
    case userDataServerBoundaryBroken = "user_data_server_boundary_broken"
    case runtimeBoundaryBroken = "runtime_boundary_broken"
}

struct AmbitionsOSLivingDreamIntakeQuestion: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let prompt: String
    let reason: String
    let dimension: AmbitionsOSStartingPositionDimension
    let answerState: AmbitionsOSLivingDreamIntakeAnswerState
    let requiredForPathFit: Bool
    let privacyClass: HumanProgressPrivacyClass
    let sensitiveAreas: [AmbitionsOSPrivacySensitiveArea]
    let linkedStartingSignalIDs: [String]
    let linkedEligibilityConditionIDs: [String]
    let sourceClaimIDs: [String]
    let retentionPolicy: AmbitionsOSLivingDreamIntakeRetentionPolicy
    let reviewState: HumanProgressReviewState
    let schemaVersion: String

    init(
        id: String,
        prompt: String,
        reason: String,
        dimension: AmbitionsOSStartingPositionDimension,
        answerState: AmbitionsOSLivingDreamIntakeAnswerState = .unanswered,
        requiredForPathFit: Bool,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        sensitiveAreas: [AmbitionsOSPrivacySensitiveArea] = [],
        linkedStartingSignalIDs: [String] = [],
        linkedEligibilityConditionIDs: [String] = [],
        sourceClaimIDs: [String] = [],
        retentionPolicy: AmbitionsOSLivingDreamIntakeRetentionPolicy = .sessionOnly,
        reviewState: HumanProgressReviewState = .ready,
        schemaVersion: String = ambitionsOSLivingDreamStartingPositionPrivacyIntakeSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.prompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.reason = reason.trimmingCharacters(in: .whitespacesAndNewlines)
        self.dimension = dimension
        self.answerState = answerState
        self.requiredForPathFit = requiredForPathFit
        self.privacyClass = privacyClass
        self.sensitiveAreas = Array(Set(sensitiveAreas)).sorted { $0.rawValue < $1.rawValue }
        self.linkedStartingSignalIDs = Self.orderedUnique(linkedStartingSignalIDs)
        self.linkedEligibilityConditionIDs = Self.orderedUnique(linkedEligibilityConditionIDs)
        self.sourceClaimIDs = Self.orderedUnique(sourceClaimIDs)
        self.retentionPolicy = retentionPolicy
        self.reviewState = reviewState
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            prompt.isEmpty == false &&
            reason.isEmpty == false &&
            schemaVersion == ambitionsOSLivingDreamStartingPositionPrivacyIntakeSchemaVersion
    }

    var isSensitive: Bool {
        privacyClass == .sensitive ||
            privacyClass == .deletePending ||
            sensitiveAreas.isEmpty == false
    }

    var isNeeded: Bool {
        requiredForPathFit ||
            linkedStartingSignalIDs.isEmpty == false ||
            linkedEligibilityConditionIDs.isEmpty == false ||
            sourceClaimIDs.isEmpty == false
    }

    var needsUserAnswer: Bool {
        switch answerState {
        case .unanswered, .askLater, .sourceReviewNeeded, .privacyReviewNeeded:
            return requiredForPathFit
        case .answered, .rejected:
            return false
        }
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct AmbitionsOSLivingDreamStartingPositionPrivacyIntakePacket: Codable, Sendable, Equatable, Hashable {
    let id: String
    let startingPosition: AmbitionsOSStartingPositionSnapshot
    let eligibilityEvaluation: AmbitionsOSLivingDreamEligibilityDeadlineEvaluation
    let questions: [AmbitionsOSLivingDreamIntakeQuestion]
    let privacyPolicies: [AmbitionsOSPrivacySafetyPolicy]
    let allowsExternalProjection: Bool
    let writesPersistence: Bool
    let mutatesCommitments: Bool
    let usesUserDataServer: Bool
    let runtimeBoundary: SourceAtlasRuntimeBoundary
    let schemaVersion: String

    init(
        id: String,
        startingPosition: AmbitionsOSStartingPositionSnapshot,
        eligibilityEvaluation: AmbitionsOSLivingDreamEligibilityDeadlineEvaluation,
        questions: [AmbitionsOSLivingDreamIntakeQuestion],
        privacyPolicies: [AmbitionsOSPrivacySafetyPolicy],
        allowsExternalProjection: Bool = false,
        writesPersistence: Bool = false,
        mutatesCommitments: Bool = false,
        usesUserDataServer: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        schemaVersion: String = ambitionsOSLivingDreamStartingPositionPrivacyIntakeSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.startingPosition = startingPosition
        self.eligibilityEvaluation = eligibilityEvaluation
        self.questions = questions.sorted { $0.id < $1.id }
        self.privacyPolicies = privacyPolicies.sorted { $0.objectID < $1.objectID }
        self.allowsExternalProjection = allowsExternalProjection
        self.writesPersistence = writesPersistence
        self.mutatesCommitments = mutatesCommitments
        self.usesUserDataServer = usesUserDataServer
        self.runtimeBoundary = runtimeBoundary
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            schemaVersion == ambitionsOSLivingDreamStartingPositionPrivacyIntakeSchemaVersion
    }
}

struct AmbitionsOSLivingDreamStartingPositionPrivacyIntakeEvaluation: Codable, Sendable, Equatable, Hashable {
    let packetID: String
    let requiredQuestionIDs: [String]
    let answeredQuestionIDs: [String]
    let blockedQuestionIDs: [String]
    let issues: [AmbitionsOSLivingDreamIntakeIssue]
    let storesUserData: Bool
    let mutatesCommitments: Bool
    let projectsExternally: Bool

    var readiness: AmbitionsOSLivingDreamIntakeReadiness {
        if issues.contains(.runtimeBoundaryBroken) ||
            issues.contains(.userDataServerBoundaryBroken) ||
            issues.contains(.hiddenMutationRisk) ||
            issues.contains(.localStorageBoundaryBroken) {
            return .blocked
        }
        if issues.contains(.eligibilityNotReady) {
            return .eligibilityBlocked
        }
        if issues.contains(.startingPositionNotReady) ||
            requiredQuestionIDs.count > answeredQuestionIDs.count {
            return .needsUserAnswer
        }
        if issues.contains(.privacyPolicyNotReady) ||
            issues.contains(.sensitiveAreaNeedsReview) ||
            issues.contains(.unnecessarySensitiveIntake) ||
            issues.contains(.externalProjectionRisk) {
            return .needsPrivacyReview
        }
        if issues.contains(.missingStartingPositionUnknown) {
            return .needsSourceReview
        }
        return .readyForPathPortfolio
    }
}

struct AmbitionsOSLivingDreamStartingPositionPrivacyIntakeValidator: Sendable, Equatable, Hashable {
    private let startingPositionValidator = AmbitionsOSStartingPositionValidator()
    private let privacyValidator = AmbitionsOSPrivacySafetyValidator()

    func validate(
        packet: AmbitionsOSLivingDreamStartingPositionPrivacyIntakePacket
    ) -> [AmbitionsOSLivingDreamIntakeIssue] {
        var issues: Set<AmbitionsOSLivingDreamIntakeIssue> = []
        let questionIDs = packet.questions.map(\.id)
        let startingSignalIDs = Set(packet.startingPosition.signals.map(\.id))
        let privacyPoliciesByObjectID = packet.privacyPolicies.reduce(into: [String: AmbitionsOSPrivacySafetyPolicy]()) {
            result, policy in
            result[policy.objectID] = policy
        }

        validateShape(packet, questionIDs: questionIDs, issues: &issues)
        validateStartingPosition(packet.startingPosition, issues: &issues)
        validateEligibility(packet.eligibilityEvaluation, issues: &issues)
        validateRuntime(packet, issues: &issues)

        for question in packet.questions {
            validate(
                question: question,
                startingSignalIDs: startingSignalIDs,
                privacyPoliciesByObjectID: privacyPoliciesByObjectID,
                allowsExternalProjection: packet.allowsExternalProjection,
                issues: &issues
            )
        }

        return issues.sorted { $0.rawValue < $1.rawValue }
    }

    func evaluate(
        packet: AmbitionsOSLivingDreamStartingPositionPrivacyIntakePacket
    ) -> AmbitionsOSLivingDreamStartingPositionPrivacyIntakeEvaluation {
        let issues = validate(packet: packet)
        return AmbitionsOSLivingDreamStartingPositionPrivacyIntakeEvaluation(
            packetID: packet.id,
            requiredQuestionIDs: packet.questions.filter(\.requiredForPathFit).map(\.id).sorted(),
            answeredQuestionIDs: packet.questions.filter { $0.answerState == .answered }.map(\.id).sorted(),
            blockedQuestionIDs: packet.questions.filter { $0.answerState == .rejected }.map(\.id).sorted(),
            issues: issues,
            storesUserData: packet.writesPersistence,
            mutatesCommitments: packet.mutatesCommitments,
            projectsExternally: packet.allowsExternalProjection
        )
    }

    private func validateShape(
        _ packet: AmbitionsOSLivingDreamStartingPositionPrivacyIntakePacket,
        questionIDs: [String],
        issues: inout Set<AmbitionsOSLivingDreamIntakeIssue>
    ) {
        if packet.schemaVersion != ambitionsOSLivingDreamStartingPositionPrivacyIntakeSchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if packet.isWellFormed == false {
            issues.insert(.malformedPacket)
        }
        if Set(questionIDs).count != questionIDs.count {
            issues.insert(.duplicateQuestionID)
        }
    }

    private func validateStartingPosition(
        _ startingPosition: AmbitionsOSStartingPositionSnapshot,
        issues: inout Set<AmbitionsOSLivingDreamIntakeIssue>
    ) {
        let startingIssues = startingPositionValidator.validate(startingPosition)
        if startingIssues.contains(.missingUnknowns) {
            issues.insert(.missingStartingPositionUnknown)
        }
        if startingPosition.pathFit == .blocked ||
            startingIssues.contains(.sourceReviewRequired) ||
            startingIssues.contains(.privacyReviewRequired) {
            issues.insert(.startingPositionNotReady)
        }
    }

    private func validateEligibility(
        _ evaluation: AmbitionsOSLivingDreamEligibilityDeadlineEvaluation,
        issues: inout Set<AmbitionsOSLivingDreamIntakeIssue>
    ) {
        if evaluation.canProceedToPathPortfolio == false ||
            evaluation.activatesPlans ||
            evaluation.mutatesCommitments {
            issues.insert(.eligibilityNotReady)
        }
    }

    private func validateRuntime(
        _ packet: AmbitionsOSLivingDreamStartingPositionPrivacyIntakePacket,
        issues: inout Set<AmbitionsOSLivingDreamIntakeIssue>
    ) {
        if packet.runtimeBoundary.isValueModelOnly == false {
            issues.insert(.runtimeBoundaryBroken)
        }
        if packet.writesPersistence {
            issues.insert(.localStorageBoundaryBroken)
        }
        if packet.mutatesCommitments {
            issues.insert(.hiddenMutationRisk)
        }
        if packet.usesUserDataServer {
            issues.insert(.userDataServerBoundaryBroken)
        }
    }

    private func validate(
        question: AmbitionsOSLivingDreamIntakeQuestion,
        startingSignalIDs: Set<String>,
        privacyPoliciesByObjectID: [String: AmbitionsOSPrivacySafetyPolicy],
        allowsExternalProjection: Bool,
        issues: inout Set<AmbitionsOSLivingDreamIntakeIssue>
    ) {
        if question.schemaVersion != ambitionsOSLivingDreamStartingPositionPrivacyIntakeSchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if question.isWellFormed == false {
            issues.insert(.malformedQuestion)
        }
        if question.isNeeded == false {
            issues.insert(.unnecessaryQuestion)
        }
        if question.linkedStartingSignalIDs.contains(where: { startingSignalIDs.contains($0) == false }) {
            issues.insert(.missingStartingPositionUnknown)
        }
        if question.isSensitive && question.requiredForPathFit == false {
            issues.insert(.unnecessarySensitiveIntake)
        }
        if question.isSensitive && question.reviewState != .ready {
            issues.insert(.sensitiveAreaNeedsReview)
        }
        if question.isSensitive && question.retentionPolicy == .localPrivate {
            issues.insert(.localStorageBoundaryBroken)
        }
        if question.retentionPolicy.isLocalOnly == false {
            issues.insert(.localStorageBoundaryBroken)
        }
        if allowsExternalProjection && question.isSensitive {
            issues.insert(.externalProjectionRisk)
        }
        validatePrivacyPolicy(for: question, privacyPoliciesByObjectID: privacyPoliciesByObjectID, issues: &issues)
    }

    private func validatePrivacyPolicy(
        for question: AmbitionsOSLivingDreamIntakeQuestion,
        privacyPoliciesByObjectID: [String: AmbitionsOSPrivacySafetyPolicy],
        issues: inout Set<AmbitionsOSLivingDreamIntakeIssue>
    ) {
        guard question.isSensitive else { return }
        guard let policy = privacyPoliciesByObjectID[question.id] else {
            issues.insert(.missingPrivacyPolicy)
            return
        }
        let privacyIssues = privacyValidator.validate(policy)
        if privacyIssues.isEmpty == false ||
            policy.permissionState.blocksProjection ||
            policy.reviewState != .ready {
            issues.insert(.privacyPolicyNotReady)
        }
    }
}
