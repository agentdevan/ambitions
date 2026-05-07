import Foundation

let ambitionsOSLivingDreamEligibilityDeadlineSchemaVersion = "ambitionsos_living_dream_eligibility_deadline.native.v1"

enum AmbitionsOSLivingDreamEligibilityDeadlineKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case minimumAge = "minimum_age"
    case maximumAge = "maximum_age"
    case dateOnOrAfter = "date_on_or_after"
    case dateOnOrBefore = "date_on_or_before"
    case applicationWindow = "application_window"
    case deadline
    case minimumLeadTime = "minimum_lead_time"
}

enum AmbitionsOSLivingDreamEligibilityDeadlineState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case satisfied
    case notSatisfied = "not_satisfied"
    case unknown
    case needsSourceReview = "needs_source_review"
    case stale
    case conflict

    var canDriveEligibility: Bool {
        switch self {
        case .satisfied:
            return true
        case .notSatisfied, .unknown, .needsSourceReview, .stale, .conflict:
            return false
        }
    }
}

enum AmbitionsOSLivingDreamEligibilityDeadlineIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case malformedCondition = "malformed_condition"
    case duplicateConditionID = "duplicate_condition_id"
    case missingRequirement = "missing_requirement"
    case requirementGraphNotReady = "requirement_graph_not_ready"
    case missingSourceClaim = "missing_source_claim"
    case sourceClaimNotReady = "source_claim_not_ready"
    case staleCriticalSource = "stale_critical_source"
    case unresolvedSourceConflict = "unresolved_source_conflict"
    case ageBelowMinimum = "age_below_minimum"
    case ageAboveMaximum = "age_above_maximum"
    case beforeWindow = "before_window"
    case afterWindow = "after_window"
    case deadlinePassed = "deadline_passed"
    case insufficientLeadTime = "insufficient_lead_time"
    case professionalBoundaryNeedsReview = "professional_boundary_needs_review"
    case runtimeBoundaryBroken = "runtime_boundary_broken"
    case userDataServerBoundaryBroken = "user_data_server_boundary_broken"
    case activationForbidden = "activation_forbidden"
}

struct AmbitionsOSLivingDreamEligibilityDeadlineCondition: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let kind: AmbitionsOSLivingDreamEligibilityDeadlineKind
    let state: AmbitionsOSLivingDreamEligibilityDeadlineState
    let sourceClaimIDs: [String]
    let requirementIDs: [String]
    let jurisdiction: String
    let currentDate: String
    let windowStartDate: String?
    let windowEndDate: String?
    let deadlineDate: String?
    let minimumAge: Int?
    let maximumAge: Int?
    let observedAge: Int?
    let minimumLeadDays: Int?
    let observedLeadDays: Int?
    let professionalBoundary: Bool
    let reviewState: HumanProgressReviewState
    let schemaVersion: String

    init(
        id: String,
        title: String,
        kind: AmbitionsOSLivingDreamEligibilityDeadlineKind,
        state: AmbitionsOSLivingDreamEligibilityDeadlineState,
        sourceClaimIDs: [String],
        requirementIDs: [String],
        jurisdiction: String,
        currentDate: String,
        windowStartDate: String? = nil,
        windowEndDate: String? = nil,
        deadlineDate: String? = nil,
        minimumAge: Int? = nil,
        maximumAge: Int? = nil,
        observedAge: Int? = nil,
        minimumLeadDays: Int? = nil,
        observedLeadDays: Int? = nil,
        professionalBoundary: Bool = false,
        reviewState: HumanProgressReviewState = .ready,
        schemaVersion: String = ambitionsOSLivingDreamEligibilityDeadlineSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.kind = kind
        self.state = state
        self.sourceClaimIDs = Self.orderedUnique(sourceClaimIDs)
        self.requirementIDs = Self.orderedUnique(requirementIDs)
        self.jurisdiction = jurisdiction.trimmingCharacters(in: .whitespacesAndNewlines)
        self.currentDate = currentDate.trimmingCharacters(in: .whitespacesAndNewlines)
        self.windowStartDate = windowStartDate?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.windowEndDate = windowEndDate?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.deadlineDate = deadlineDate?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.minimumAge = minimumAge
        self.maximumAge = maximumAge
        self.observedAge = observedAge
        self.minimumLeadDays = minimumLeadDays
        self.observedLeadDays = observedLeadDays
        self.professionalBoundary = professionalBoundary
        self.reviewState = reviewState
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            title.isEmpty == false &&
            sourceClaimIDs.isEmpty == false &&
            requirementIDs.isEmpty == false &&
            jurisdiction.isEmpty == false &&
            Self.isISODate(currentDate) &&
            schemaVersion == ambitionsOSLivingDreamEligibilityDeadlineSchemaVersion &&
            kindHasRequiredValues
    }

    var blocksEligibility: Bool {
        state.canDriveEligibility == false ||
            violatesAge ||
            violatesWindow ||
            violatesDeadline ||
            violatesLeadTime ||
            (professionalBoundary && reviewState != .ready)
    }

    private var kindHasRequiredValues: Bool {
        switch kind {
        case .minimumAge:
            return minimumAge != nil && observedAge != nil
        case .maximumAge:
            return maximumAge != nil && observedAge != nil
        case .dateOnOrAfter:
            return windowStartDate.map(Self.isISODate) == true
        case .dateOnOrBefore:
            return windowEndDate.map(Self.isISODate) == true
        case .applicationWindow:
            return windowStartDate.map(Self.isISODate) == true &&
                windowEndDate.map(Self.isISODate) == true
        case .deadline:
            return deadlineDate.map(Self.isISODate) == true
        case .minimumLeadTime:
            return minimumLeadDays != nil && observedLeadDays != nil
        }
    }

    var violatesAge: Bool {
        switch kind {
        case .minimumAge:
            return observedAge.map { age in minimumAge.map { age < $0 } ?? true } ?? true
        case .maximumAge:
            return observedAge.map { age in maximumAge.map { age > $0 } ?? true } ?? true
        case .dateOnOrAfter, .dateOnOrBefore, .applicationWindow, .deadline, .minimumLeadTime:
            return false
        }
    }

    var violatesWindow: Bool {
        switch kind {
        case .dateOnOrAfter:
            return windowStartDate.map { currentDate < $0 } ?? true
        case .dateOnOrBefore:
            return windowEndDate.map { currentDate > $0 } ?? true
        case .applicationWindow:
            return windowStartDate.map { currentDate < $0 } ?? true ||
                windowEndDate.map { currentDate > $0 } ?? true
        case .minimumAge, .maximumAge, .deadline, .minimumLeadTime:
            return false
        }
    }

    var violatesDeadline: Bool {
        guard kind == .deadline else { return false }
        return deadlineDate.map { currentDate > $0 } ?? true
    }

    var violatesLeadTime: Bool {
        guard kind == .minimumLeadTime else { return false }
        return observedLeadDays.map { lead in minimumLeadDays.map { lead < $0 } ?? true } ?? true
    }

    static func isISODate(_ value: String) -> Bool {
        let pattern = #"^\d{4}-\d{2}-\d{2}$"#
        return value.range(of: pattern, options: .regularExpression) != nil
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct AmbitionsOSLivingDreamEligibilityDeadlineRuntime: Codable, Sendable, Equatable, Hashable {
    let id: String
    let conditions: [AmbitionsOSLivingDreamEligibilityDeadlineCondition]
    let requirementGraph: AmbitionsOSLivingDreamRequirementGraph
    let runtimeBoundary: SourceAtlasRuntimeBoundary
    let allowsActivation: Bool
    let usesUserDataServer: Bool

    init(
        id: String,
        conditions: [AmbitionsOSLivingDreamEligibilityDeadlineCondition],
        requirementGraph: AmbitionsOSLivingDreamRequirementGraph,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        allowsActivation: Bool = false,
        usesUserDataServer: Bool = false
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.conditions = conditions
        self.requirementGraph = requirementGraph
        self.runtimeBoundary = runtimeBoundary
        self.allowsActivation = allowsActivation
        self.usesUserDataServer = usesUserDataServer
    }
}

struct AmbitionsOSLivingDreamEligibilityDeadlineEvaluation: Codable, Sendable, Equatable, Hashable {
    let runtimeID: String
    let eligibleConditionIDs: [String]
    let blockedConditionIDs: [String]
    let issues: [AmbitionsOSLivingDreamEligibilityDeadlineIssue]
    let activatesPlans: Bool
    let mutatesCommitments: Bool

    var canProceedToPathPortfolio: Bool {
        issues.isEmpty && blockedConditionIDs.isEmpty
    }
}

struct AmbitionsOSLivingDreamEligibilityDeadlineValidator: Sendable, Equatable, Hashable {
    func validate(
        runtime: AmbitionsOSLivingDreamEligibilityDeadlineRuntime
    ) -> [AmbitionsOSLivingDreamEligibilityDeadlineIssue] {
        var issues: Set<AmbitionsOSLivingDreamEligibilityDeadlineIssue> = []
        let conditionIDs = runtime.conditions.map(\.id)
        let requirementIDs = Set(runtime.requirementGraph.requirements.map(\.id))
        let claimsByID = runtime.requirementGraph.sourceClaimGraph.claims.reduce(into: [String: AmbitionsOSLivingDreamSourceClaim]()) { result, claim in
            result[claim.id] = claim
        }

        if runtime.id.isEmpty || runtime.conditions.isEmpty {
            issues.insert(.malformedCondition)
        }
        if Set(conditionIDs).count != conditionIDs.count {
            issues.insert(.duplicateConditionID)
        }
        if runtime.requirementGraph.validationIssues.isEmpty == false {
            issues.insert(.requirementGraphNotReady)
        }
        if runtime.runtimeBoundary.isValueModelOnly == false {
            issues.insert(.runtimeBoundaryBroken)
        }
        if runtime.usesUserDataServer {
            issues.insert(.userDataServerBoundaryBroken)
        }
        if runtime.allowsActivation {
            issues.insert(.activationForbidden)
        }

        for condition in runtime.conditions {
            validate(
                condition: condition,
                requirementIDs: requirementIDs,
                claimsByID: claimsByID,
                issues: &issues
            )
        }

        return issues.sorted { $0.rawValue < $1.rawValue }
    }

    func evaluate(
        runtime: AmbitionsOSLivingDreamEligibilityDeadlineRuntime
    ) -> AmbitionsOSLivingDreamEligibilityDeadlineEvaluation {
        let issues = validate(runtime: runtime)
        return AmbitionsOSLivingDreamEligibilityDeadlineEvaluation(
            runtimeID: runtime.id,
            eligibleConditionIDs: runtime.conditions.filter { $0.blocksEligibility == false }.map(\.id).sorted(),
            blockedConditionIDs: runtime.conditions.filter(\.blocksEligibility).map(\.id).sorted(),
            issues: issues,
            activatesPlans: false,
            mutatesCommitments: false
        )
    }

    private func validate(
        condition: AmbitionsOSLivingDreamEligibilityDeadlineCondition,
        requirementIDs: Set<String>,
        claimsByID: [String: AmbitionsOSLivingDreamSourceClaim],
        issues: inout Set<AmbitionsOSLivingDreamEligibilityDeadlineIssue>
    ) {
        if condition.schemaVersion != ambitionsOSLivingDreamEligibilityDeadlineSchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if condition.isWellFormed == false {
            issues.insert(.malformedCondition)
        }
        if condition.requirementIDs.contains(where: { requirementIDs.contains($0) == false }) {
            issues.insert(.missingRequirement)
        }
        for claimID in condition.sourceClaimIDs {
            guard let claim = claimsByID[claimID] else {
                issues.insert(.missingSourceClaim)
                continue
            }
            if claim.canDriveConsequentialRecommendation == false {
                issues.insert(.sourceClaimNotReady)
            }
            if claim.freshnessState == .staleCritical || claim.freshnessState == .sourceChanged {
                issues.insert(.staleCriticalSource)
            }
            if claim.sourceConflictState.blocksConsequentialUse {
                issues.insert(.unresolvedSourceConflict)
            }
        }
        if condition.violatesAge {
            issues.insert(condition.kind == .maximumAge ? .ageAboveMaximum : .ageBelowMinimum)
        }
        if condition.violatesWindow {
            if let start = condition.windowStartDate, condition.currentDate < start {
                issues.insert(.beforeWindow)
            }
            if let end = condition.windowEndDate, condition.currentDate > end {
                issues.insert(.afterWindow)
            }
        }
        if condition.violatesDeadline {
            issues.insert(.deadlinePassed)
        }
        if condition.violatesLeadTime {
            issues.insert(.insufficientLeadTime)
        }
        if condition.professionalBoundary && condition.reviewState != .ready {
            issues.insert(.professionalBoundaryNeedsReview)
        }
    }
}
