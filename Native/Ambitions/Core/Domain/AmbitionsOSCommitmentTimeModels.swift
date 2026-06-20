import Foundation

let ambitionsOSCommitmentTimeSchemaVersion = "ambitionsos_commitment_time.native.v1"

enum AmbitionsOSCommitmentTimeKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case step
    case oneStepGoal = "one_step_goal"
    case deadline
    case appointment
    case travel
    case prep
    case recovery
    case waiting
    case blocked
    case protectedTime = "protected_time"
    case recurringResponsibility = "recurring_responsibility"
    case reviewWindow = "review_window"
}

enum AmbitionsOSCommitmentFlexibility: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case fixed
    case movableSameDay = "movable_same_day"
    case movableThisWeek = "movable_this_week"
    case interruptible
    case protected
}

enum AmbitionsOSCapacityFit: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case fits
    case tight
    case overCapacity = "over_capacity"
    case needsReview = "needs_review"
}

enum AmbitionsOSCommitmentTimeIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case malformedCommitment = "malformed_commitment"
    case malformedCapacityWindow = "malformed_capacity_window"
    case invalidDuration = "invalid_duration"
    case protectedTimeViolation = "protected_time_violation"
    case overCapacity = "over_capacity"
    case sourceReviewRequired = "source_review_required"
    case staleDeadlineSource = "stale_deadline_source"
    case silentRescheduleRisk = "silent_reschedule_risk"
    case privateExternalProjectionRisk = "private_external_projection_risk"
    case platformCalendarImplementation = "platform_calendar_implementation"
    case runtimeStoreBehavior = "runtime_store_behavior"
}

struct AmbitionsOSCommitmentTimeItem: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let kind: AmbitionsOSCommitmentTimeKind
    let durationMinutes: Int
    let sourceState: HumanProgressSourceState
    let freshnessState: HumanProgressFreshnessState
    let reviewState: HumanProgressReviewState
    let privacyClass: HumanProgressPrivacyClass
    let flexibility: AmbitionsOSCommitmentFlexibility
    let sourceClaimIDs: [String]
    let receiptIDs: [String]
    let requiresUserReviewBeforeMove: Bool
    let schemaVersion: String

    init(
        id: String,
        title: String,
        kind: AmbitionsOSCommitmentTimeKind,
        durationMinutes: Int,
        sourceState: HumanProgressSourceState = .userConfirmed,
        freshnessState: HumanProgressFreshnessState = .notApplicable,
        reviewState: HumanProgressReviewState = .ready,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        flexibility: AmbitionsOSCommitmentFlexibility,
        sourceClaimIDs: [String] = [],
        receiptIDs: [String] = [],
        requiresUserReviewBeforeMove: Bool = true,
        schemaVersion: String = ambitionsOSCommitmentTimeSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.kind = kind
        self.durationMinutes = durationMinutes
        self.sourceState = sourceState
        self.freshnessState = freshnessState
        self.reviewState = reviewState
        self.privacyClass = privacyClass
        self.flexibility = flexibility
        self.sourceClaimIDs = Self.orderedUnique(sourceClaimIDs)
        self.receiptIDs = Self.orderedUnique(receiptIDs)
        self.requiresUserReviewBeforeMove = requiresUserReviewBeforeMove
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            title.isEmpty == false &&
            schemaVersion == ambitionsOSCommitmentTimeSchemaVersion
    }

    var canContributeToCapacityFit: Bool {
        isWellFormed &&
            durationMinutes > 0 &&
            reviewState == .ready &&
            sourceState.canDriveSourceSensitiveRecommendation &&
            freshnessState.blocksHighRiskUse == false &&
            privacyClass != .deletePending
    }

    var isExternalProjectionSafe: Bool {
        privacyClass == .externalRedacted || privacyClass == .shareableByUser
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct AmbitionsOSCapacityWindow: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let availableMinutes: Int
    let protected: Bool
    let privacyClass: HumanProgressPrivacyClass
    let reviewState: HumanProgressReviewState
    let schemaVersion: String

    init(
        id: String,
        title: String,
        availableMinutes: Int,
        protected: Bool = false,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        reviewState: HumanProgressReviewState = .ready,
        schemaVersion: String = ambitionsOSCommitmentTimeSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.availableMinutes = availableMinutes
        self.protected = protected
        self.privacyClass = privacyClass
        self.reviewState = reviewState
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            title.isEmpty == false &&
            availableMinutes >= 0 &&
            schemaVersion == ambitionsOSCommitmentTimeSchemaVersion
    }
}

struct AmbitionsOSCommitmentTimeProjection: Codable, Sendable, Equatable, Hashable {
    let commitments: [AmbitionsOSCommitmentTimeItem]
    let capacityWindows: [AmbitionsOSCapacityWindow]
    let runtimeBoundary: SourceAtlasRuntimeBoundary
    let performsPlatformCalendarWork: Bool
    let writesScheduleAutomatically: Bool

    init(
        commitments: [AmbitionsOSCommitmentTimeItem],
        capacityWindows: [AmbitionsOSCapacityWindow],
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        performsPlatformCalendarWork: Bool = false,
        writesScheduleAutomatically: Bool = false
    ) {
        self.commitments = commitments
        self.capacityWindows = capacityWindows
        self.runtimeBoundary = runtimeBoundary
        self.performsPlatformCalendarWork = performsPlatformCalendarWork
        self.writesScheduleAutomatically = writesScheduleAutomatically
    }

    var requestedMinutes: Int {
        commitments.reduce(0) { $0 + max($1.durationMinutes, 0) }
    }

    var regularRequestedMinutes: Int {
        commitments
            .filter { $0.kind != .protectedTime && $0.flexibility != .protected }
            .reduce(0) { $0 + max($1.durationMinutes, 0) }
    }

    var protectedRequestedMinutes: Int {
        commitments
            .filter { $0.kind == .protectedTime || $0.flexibility == .protected }
            .reduce(0) { $0 + max($1.durationMinutes, 0) }
    }

    var availableMinutes: Int {
        capacityWindows.filter { $0.protected == false }.reduce(0) { $0 + $1.availableMinutes }
    }

    var protectedAvailableMinutes: Int {
        capacityWindows.filter(\.protected).reduce(0) { $0 + $1.availableMinutes }
    }

    var capacityFit: AmbitionsOSCapacityFit {
        let issues = AmbitionsOSCommitmentTimeValidator().validate(self)
        if issues.contains(.sourceReviewRequired) || issues.contains(.staleDeadlineSource) {
            return .needsReview
        }
        if issues.contains(.overCapacity) {
            return .overCapacity
        }
        let totalRequestedMinutes = regularRequestedMinutes + protectedRequestedMinutes
        let totalAvailableMinutes = availableMinutes + protectedAvailableMinutes
        if totalRequestedMinutes > Int(Double(max(totalAvailableMinutes, 1)) * 0.8) {
            return .tight
        }
        return .fits
    }
}

struct AmbitionsOSCommitmentTimeValidator: Sendable, Equatable, Hashable {
    func validate(_ projection: AmbitionsOSCommitmentTimeProjection) -> [AmbitionsOSCommitmentTimeIssue] {
        var issues: Set<AmbitionsOSCommitmentTimeIssue> = []

        if projection.runtimeBoundary.isValueModelOnly == false {
            issues.insert(.runtimeStoreBehavior)
        }
        if projection.performsPlatformCalendarWork {
            issues.insert(.platformCalendarImplementation)
        }
        if projection.writesScheduleAutomatically {
            issues.insert(.silentRescheduleRisk)
        }

        for window in projection.capacityWindows {
            if window.schemaVersion != ambitionsOSCommitmentTimeSchemaVersion {
                issues.insert(.unsupportedSchema)
            }
            if window.isWellFormed == false {
                issues.insert(.malformedCapacityWindow)
            }
        }

        for item in projection.commitments {
            validate(item: item, issues: &issues)
        }

        if projection.regularRequestedMinutes > projection.availableMinutes ||
            projection.protectedRequestedMinutes > projection.protectedAvailableMinutes {
            issues.insert(.overCapacity)
        }
        if projection.capacityWindows.contains(where: \.protected) &&
            projection.commitments.contains(where: { $0.flexibility != .protected && $0.kind != .protectedTime }) {
            issues.insert(.protectedTimeViolation)
        }

        return issues.sorted { $0.rawValue < $1.rawValue }
    }

    private func validate(
        item: AmbitionsOSCommitmentTimeItem,
        issues: inout Set<AmbitionsOSCommitmentTimeIssue>
    ) {
        if item.schemaVersion != ambitionsOSCommitmentTimeSchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if item.isWellFormed == false {
            issues.insert(.malformedCommitment)
        }
        if item.durationMinutes <= 0 {
            issues.insert(.invalidDuration)
        }
        if item.sourceState.canDriveSourceSensitiveRecommendation == false ||
            item.reviewState.blocksAutomaticMutation {
            issues.insert(.sourceReviewRequired)
        }
        if item.kind == .deadline && item.freshnessState.blocksHighRiskUse {
            issues.insert(.staleDeadlineSource)
        }
        if item.requiresUserReviewBeforeMove == false && item.flexibility != .interruptible {
            issues.insert(.silentRescheduleRisk)
        }
        if item.privacyClass == .sensitive && item.isExternalProjectionSafe == false {
            issues.insert(.privateExternalProjectionRisk)
        }
    }
}
