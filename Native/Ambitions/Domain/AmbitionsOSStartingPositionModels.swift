import Foundation

let ambitionsOSStartingPositionSchemaVersion = "ambitionsos_starting_position.native.v1"

enum AmbitionsOSStartingPositionDimension: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case ageBand = "age_band"
    case lifeStage = "life_stage"
    case schoolWorkStatus = "school_work_status"
    case locationJurisdiction = "location_jurisdiction"
    case availability
    case energyPattern = "energy_pattern"
    case moneyResources = "money_resources"
    case educationLevel = "education_level"
    case skills
    case proof
    case commitments
    case healthPhysicalConstraint = "health_physical_constraint"
    case transportation
    case internetDeviceReliability = "internet_device_reliability"
    case supportSystem = "support_system"
    case privacyNeeds = "privacy_needs"
    case riskTolerance = "risk_tolerance"
    case deadlinePressure = "deadline_pressure"

    var isSourceSensitive: Bool {
        switch self {
        case .locationJurisdiction, .educationLevel, .schoolWorkStatus,
             .deadlinePressure, .ageBand:
            return true
        case .lifeStage, .availability, .energyPattern, .moneyResources,
             .skills, .proof, .commitments, .healthPhysicalConstraint,
             .transportation, .internetDeviceReliability, .supportSystem,
             .privacyNeeds, .riskTolerance:
            return false
        }
    }
}

enum AmbitionsOSStartingPositionSignalKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case advantage
    case constraint
    case unknown
    case proof
    case access
    case privacyNeed = "privacy_need"
}

enum AmbitionsOSStartingPositionFit: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case reviewReady = "review_ready"
    case needsSourceReview = "needs_source_review"
    case needsUserReview = "needs_user_review"
    case missingUnknowns = "missing_unknowns"
    case blocked
}

enum AmbitionsOSStartingPositionIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case malformedSnapshot = "malformed_snapshot"
    case malformedSignal = "malformed_signal"
    case malformedIntakeQuestion = "malformed_intake_question"
    case sourceReviewRequired = "source_review_required"
    case privacyReviewRequired = "privacy_review_required"
    case unnecessarySensitiveIntake = "unnecessary_sensitive_intake"
    case missingUnknowns = "missing_unknowns"
    case certificationOverclaim = "certification_overclaim"
    case behindLanguage = "behind_language"
    case externalProjectionRisk = "external_projection_risk"
    case runtimeStoreBehavior = "runtime_store_behavior"
}

struct AmbitionsOSStartingPositionSignal: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let dimension: AmbitionsOSStartingPositionDimension
    let kind: AmbitionsOSStartingPositionSignalKind
    let sourceState: HumanProgressSourceState
    let freshnessState: HumanProgressFreshnessState
    let reviewState: HumanProgressReviewState
    let privacyClass: HumanProgressPrivacyClass
    let sourceClaimIDs: [String]
    let receiptIDs: [String]
    let schemaVersion: String

    init(
        id: String,
        title: String,
        dimension: AmbitionsOSStartingPositionDimension,
        kind: AmbitionsOSStartingPositionSignalKind,
        sourceState: HumanProgressSourceState = .userConfirmed,
        freshnessState: HumanProgressFreshnessState = .current,
        reviewState: HumanProgressReviewState = .ready,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        sourceClaimIDs: [String] = [],
        receiptIDs: [String] = [],
        schemaVersion: String = ambitionsOSStartingPositionSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.dimension = dimension
        self.kind = kind
        self.sourceState = sourceState
        self.freshnessState = freshnessState
        self.reviewState = reviewState
        self.privacyClass = privacyClass
        self.sourceClaimIDs = Self.orderedUnique(sourceClaimIDs)
        self.receiptIDs = Self.orderedUnique(receiptIDs)
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            title.isEmpty == false &&
            schemaVersion == ambitionsOSStartingPositionSchemaVersion
    }

    var canDrivePathFit: Bool {
        isWellFormed &&
            reviewState == .ready &&
            privacyClass != .deletePending &&
            freshnessState.blocksHighRiskUse == false &&
            (dimension.isSourceSensitive == false || sourceState.canDriveSourceSensitiveRecommendation)
    }

    var isExternalProjectionSafe: Bool {
        privacyClass == .externalRedacted || privacyClass == .shareableByUser
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct AmbitionsOSStartingPositionIntakeQuestion: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let prompt: String
    let dimension: AmbitionsOSStartingPositionDimension
    let reason: String
    let isRequiredForPathFit: Bool
    let privacyClass: HumanProgressPrivacyClass
    let reviewState: HumanProgressReviewState
    let schemaVersion: String

    init(
        id: String,
        prompt: String,
        dimension: AmbitionsOSStartingPositionDimension,
        reason: String,
        isRequiredForPathFit: Bool,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        reviewState: HumanProgressReviewState = .ready,
        schemaVersion: String = ambitionsOSStartingPositionSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.prompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.dimension = dimension
        self.reason = reason.trimmingCharacters(in: .whitespacesAndNewlines)
        self.isRequiredForPathFit = isRequiredForPathFit
        self.privacyClass = privacyClass
        self.reviewState = reviewState
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            prompt.isEmpty == false &&
            reason.isEmpty == false &&
            schemaVersion == ambitionsOSStartingPositionSchemaVersion
    }
}

struct AmbitionsOSStartingPositionSnapshot: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let signals: [AmbitionsOSStartingPositionSignal]
    let intakeQuestions: [AmbitionsOSStartingPositionIntakeQuestion]
    let surfaceLanguageSamples: [String]
    let claimsEligibilityAsCertified: Bool
    let externalProjectionRequested: Bool
    let runtimeBoundary: SourceAtlasRuntimeBoundary
    let schemaVersion: String

    init(
        id: String,
        title: String,
        signals: [AmbitionsOSStartingPositionSignal],
        intakeQuestions: [AmbitionsOSStartingPositionIntakeQuestion] = [],
        surfaceLanguageSamples: [String] = ["This is where the path starts."],
        claimsEligibilityAsCertified: Bool = false,
        externalProjectionRequested: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        schemaVersion: String = ambitionsOSStartingPositionSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.signals = signals
        self.intakeQuestions = intakeQuestions
        self.surfaceLanguageSamples = surfaceLanguageSamples
        self.claimsEligibilityAsCertified = claimsEligibilityAsCertified
        self.externalProjectionRequested = externalProjectionRequested
        self.runtimeBoundary = runtimeBoundary
        self.schemaVersion = schemaVersion
    }

    var advantages: [AmbitionsOSStartingPositionSignal] {
        signals.filter { $0.kind == .advantage || $0.kind == .proof || $0.kind == .access }
    }

    var constraints: [AmbitionsOSStartingPositionSignal] {
        signals.filter { $0.kind == .constraint || $0.kind == .privacyNeed }
    }

    var unknowns: [AmbitionsOSStartingPositionSignal] {
        signals.filter { $0.kind == .unknown }
    }

    var dignityLanguage: String {
        "This is where the path starts."
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            title.isEmpty == false &&
            schemaVersion == ambitionsOSStartingPositionSchemaVersion
    }

    var pathFit: AmbitionsOSStartingPositionFit {
        let issues = AmbitionsOSStartingPositionValidator().validate(self)
        if issues.contains(.runtimeStoreBehavior) || issues.contains(.certificationOverclaim) {
            return .blocked
        }
        if issues.contains(.sourceReviewRequired) {
            return .needsSourceReview
        }
        if issues.contains(.privacyReviewRequired) || issues.contains(.unnecessarySensitiveIntake) {
            return .needsUserReview
        }
        if issues.contains(.missingUnknowns) {
            return .missingUnknowns
        }
        return .reviewReady
    }
}

struct AmbitionsOSStartingPositionValidator: Sendable, Equatable, Hashable {
    func validate(_ snapshot: AmbitionsOSStartingPositionSnapshot) -> [AmbitionsOSStartingPositionIssue] {
        var issues: Set<AmbitionsOSStartingPositionIssue> = []

        if snapshot.runtimeBoundary.isValueModelOnly == false {
            issues.insert(.runtimeStoreBehavior)
        }
        if snapshot.schemaVersion != ambitionsOSStartingPositionSchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if snapshot.isWellFormed == false {
            issues.insert(.malformedSnapshot)
        }
        if snapshot.claimsEligibilityAsCertified {
            issues.insert(.certificationOverclaim)
        }
        if snapshot.signals.contains(where: { $0.kind == .unknown }) == false {
            issues.insert(.missingUnknowns)
        }
        if snapshot.surfaceLanguageSamples.contains(where: Self.usesBehindLanguage) {
            issues.insert(.behindLanguage)
        }

        for signal in snapshot.signals {
            validate(signal: signal, externalProjectionRequested: snapshot.externalProjectionRequested, issues: &issues)
        }
        for question in snapshot.intakeQuestions {
            validate(question: question, issues: &issues)
        }

        return issues.sorted { $0.rawValue < $1.rawValue }
    }

    private func validate(
        signal: AmbitionsOSStartingPositionSignal,
        externalProjectionRequested: Bool,
        issues: inout Set<AmbitionsOSStartingPositionIssue>
    ) {
        if signal.schemaVersion != ambitionsOSStartingPositionSchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if signal.isWellFormed == false {
            issues.insert(.malformedSignal)
        }
        if signal.dimension.isSourceSensitive &&
            (signal.sourceState.canDriveSourceSensitiveRecommendation == false ||
             signal.freshnessState.blocksHighRiskUse) {
            issues.insert(.sourceReviewRequired)
        }
        if signal.reviewState.blocksAutomaticMutation {
            issues.insert(.privacyReviewRequired)
        }
        if externalProjectionRequested &&
            signal.privacyClass == .sensitive &&
            signal.isExternalProjectionSafe == false {
            issues.insert(.externalProjectionRisk)
        }
    }

    private func validate(
        question: AmbitionsOSStartingPositionIntakeQuestion,
        issues: inout Set<AmbitionsOSStartingPositionIssue>
    ) {
        if question.schemaVersion != ambitionsOSStartingPositionSchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if question.isWellFormed == false {
            issues.insert(.malformedIntakeQuestion)
        }
        if question.reviewState.blocksAutomaticMutation {
            issues.insert(.privacyReviewRequired)
        }
        if question.privacyClass == .sensitive && question.isRequiredForPathFit == false {
            issues.insert(.unnecessarySensitiveIntake)
        }
    }

    private static func usesBehindLanguage(_ sample: String) -> Bool {
        let lowercased = sample.lowercased()
        return lowercased.contains("behind") ||
            lowercased.contains("too late") ||
            lowercased.contains("catch up")
    }
}
