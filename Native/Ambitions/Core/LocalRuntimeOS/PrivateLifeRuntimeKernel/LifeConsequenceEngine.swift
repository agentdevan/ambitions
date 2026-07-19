import Foundation

enum LifeConsequenceTrigger: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case scheduleInstall = "schedule_install"
    case skipStep = "skip_step"
    case shrinkStep = "shrink_step"
    case replaceStep = "replace_step"
    case extendStep = "extend_step"
    case deadlineChange = "deadline_change"
    case sourceChange = "source_change"
    case availabilityChange = "availability_change"
    case protectedTimeChange = "protected_time_change"
    case highRiskReview = "high_risk_review"
    case unsafeState = "unsafe_state"
}

enum LifeConsequenceSeverity: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case silent
    case inform
    case confirm
    case warn
    case block
    case impossible

    var isMaterial: Bool {
        self != .silent
    }

    var blocksDownstream: Bool {
        self == .block || self == .impossible
    }

    var order: Int {
        switch self {
        case .silent: return 0
        case .inform: return 1
        case .confirm: return 2
        case .warn: return 3
        case .block: return 4
        case .impossible: return 5
        }
    }
}

enum LifeConsequenceVisibilityPreference: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case quiet
    case balanced
    case detailed
    case expert
}

enum LifeConsequenceVisibilityState: String, Codable, Sendable, Equatable, Hashable {
    case compressed
    case visible
    case reviewRequired = "review_required"
    case blocked
}

enum LifeConsequenceSourceAuthorityState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case current
    case stale
    case reviewRequired = "review_required"
    case revoked
    case contradicted
}

enum LifeConsequenceRecoveryImpact: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case none
    case light
    case review
    case heavy
}

enum LifeConsequenceIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case scheduleInstallBlocked = "schedule_install_blocked"
    case missingScheduleInstallReceipt = "missing_schedule_install_receipt"
    case missingRollbackTrace = "missing_rollback_trace"
    case missingConsequenceInput = "missing_consequence_input"
    case missingAffectedGoal = "missing_affected_goal"
    case missingSourceRecord = "missing_source_record"
    case missingReceipt = "missing_receipt"
    case missingReplayTrace = "missing_replay_trace"
    case missingInspectionRoute = "missing_inspection_route"
    case treatyOutputMissing = "treaty_output_missing"
    case treatyViolationHidden = "treaty_violation_hidden"
    case treatyBlocked = "treaty_blocked"
    case nonSuppressibleEventHidden = "non_suppressible_event_hidden"
    case hiddenConsequenceMutation = "hidden_consequence_mutation"
    case irreversibleReflow = "irreversible_reflow"
    case nonLocalRuntimeBoundary = "non_local_runtime_boundary"
    case protectedTimeBroken = "protected_time_broken"
    case deadlineImpossible = "deadline_impossible"
    case sourceRevoked = "source_revoked"
    case unsafeState = "unsafe_state"
    case highRiskReviewRequired = "high_risk_review_required"
    case scheduleInstallFailure = "schedule_install_failure"
}

struct LifeConsequenceGoalTreaty: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let participatingGoalIDs: [String]
    let protectedGoalID: String?
    let constraintSummary: String
    let violationSeverity: LifeConsequenceSeverity
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceID: String?
    let whatAmbitionsKnowsRoute: String?
    let localOnly: Bool

    init(
        id: String,
        title: String,
        participatingGoalIDs: [String],
        protectedGoalID: String?,
        constraintSummary: String,
        violationSeverity: LifeConsequenceSeverity,
        sourceRecordIDs: [String],
        receiptIDs: [String],
        replayTraceID: String?,
        whatAmbitionsKnowsRoute: String?,
        localOnly: Bool = true
    ) {
        self.id = Self.normalized(id)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.participatingGoalIDs = Self.normalizedIDs(participatingGoalIDs)
        self.protectedGoalID = Self.normalizedOptional(protectedGoalID)
        self.constraintSummary = constraintSummary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.violationSeverity = violationSeverity
        self.sourceRecordIDs = Self.normalizedIDs(sourceRecordIDs)
        self.receiptIDs = Self.normalizedIDs(receiptIDs)
        self.replayTraceID = Self.normalizedOptional(replayTraceID)
        self.whatAmbitionsKnowsRoute = Self.normalizedOptional(whatAmbitionsKnowsRoute)
        self.localOnly = localOnly
    }

    var isInspectable: Bool {
        id.isEmpty == false &&
            title.isEmpty == false &&
            participatingGoalIDs.isEmpty == false &&
            constraintSummary.isEmpty == false &&
            sourceRecordIDs.isEmpty == false &&
            receiptIDs.isEmpty == false &&
            replayTraceID != nil &&
            whatAmbitionsKnowsRoute != nil &&
            localOnly
    }

    func participates(in goalID: String) -> Bool {
        participatingGoalIDs.contains(goalID) || protectedGoalID == goalID
    }

    static func normalized(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func normalizedIDs(_ values: [String]) -> [String] {
        Array(Set(values.map(normalized).filter { $0.isEmpty == false })).sorted()
    }

    static func normalizedOptional(_ value: String?) -> String? {
        guard let normalized = value?.trimmingCharacters(in: .whitespacesAndNewlines), normalized.isEmpty == false else {
            return nil
        }
        return normalized
    }
}

struct LifeConsequenceImpact: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let affectedGoalID: String
    let affectedGoalTitle: String
    let trigger: LifeConsequenceTrigger
    let deadlineMinutesDelta: Int
    let densityMinutesDelta: Int
    let proofValueDelta: Int
    let dependencyIDs: [String]
    let protectedTimeBroken: Bool
    let sourceAuthority: LifeConsequenceSourceAuthorityState
    let recoveryImpact: LifeConsequenceRecoveryImpact
    let materialDisplacement: Bool
    let highRiskReviewRequired: Bool
    let unsafeState: Bool
    let scheduleInstallFailure: Bool
    let treatyIDs: [String]
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceID: String?
    let whatAmbitionsKnowsRoute: String?
    let userVisible: Bool
    let localOnly: Bool
    let reversible: Bool

    init(
        id: String,
        affectedGoalID: String,
        affectedGoalTitle: String,
        trigger: LifeConsequenceTrigger,
        deadlineMinutesDelta: Int = 0,
        densityMinutesDelta: Int = 0,
        proofValueDelta: Int = 0,
        dependencyIDs: [String] = [],
        protectedTimeBroken: Bool = false,
        sourceAuthority: LifeConsequenceSourceAuthorityState = .current,
        recoveryImpact: LifeConsequenceRecoveryImpact = .none,
        materialDisplacement: Bool = false,
        highRiskReviewRequired: Bool = false,
        unsafeState: Bool = false,
        scheduleInstallFailure: Bool = false,
        treatyIDs: [String] = [],
        sourceRecordIDs: [String],
        receiptIDs: [String],
        replayTraceID: String?,
        whatAmbitionsKnowsRoute: String?,
        userVisible: Bool = true,
        localOnly: Bool = true,
        reversible: Bool = true
    ) {
        self.id = Self.normalized(id)
        self.affectedGoalID = Self.normalized(affectedGoalID)
        self.affectedGoalTitle = affectedGoalTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        self.trigger = trigger
        self.deadlineMinutesDelta = deadlineMinutesDelta
        self.densityMinutesDelta = densityMinutesDelta
        self.proofValueDelta = proofValueDelta
        self.dependencyIDs = Self.normalizedIDs(dependencyIDs)
        self.protectedTimeBroken = protectedTimeBroken
        self.sourceAuthority = sourceAuthority
        self.recoveryImpact = recoveryImpact
        self.materialDisplacement = materialDisplacement
        self.highRiskReviewRequired = highRiskReviewRequired
        self.unsafeState = unsafeState
        self.scheduleInstallFailure = scheduleInstallFailure
        self.treatyIDs = Self.normalizedIDs(treatyIDs)
        self.sourceRecordIDs = Self.normalizedIDs(sourceRecordIDs)
        self.receiptIDs = Self.normalizedIDs(receiptIDs)
        self.replayTraceID = Self.normalizedOptional(replayTraceID)
        self.whatAmbitionsKnowsRoute = Self.normalizedOptional(whatAmbitionsKnowsRoute)
        self.userVisible = userVisible
        self.localOnly = localOnly
        self.reversible = reversible
    }

    var isInspectable: Bool {
        id.isEmpty == false &&
            affectedGoalID.isEmpty == false &&
            affectedGoalTitle.isEmpty == false &&
            sourceRecordIDs.isEmpty == false &&
            receiptIDs.isEmpty == false &&
            replayTraceID != nil &&
            whatAmbitionsKnowsRoute != nil &&
            localOnly
    }

    static func normalized(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func normalizedIDs(_ values: [String]) -> [String] {
        Array(Set(values.map(normalized).filter { $0.isEmpty == false })).sorted()
    }

    static func normalizedOptional(_ value: String?) -> String? {
        guard let normalized = value?.trimmingCharacters(in: .whitespacesAndNewlines), normalized.isEmpty == false else {
            return nil
        }
        return normalized
    }
}

struct LifeConsequenceTreatyOutput: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let treatyID: String
    let affectedGoalIDs: [String]
    let severity: LifeConsequenceSeverity
    let violated: Bool
    let consequencePhrase: String
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceID: String
    let whatAmbitionsKnowsRoute: String
}

struct LifeConsequenceReceipt: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let impactID: String
    let affectedGoalID: String
    let trigger: LifeConsequenceTrigger
    let severity: LifeConsequenceSeverity
    let visibility: LifeConsequenceVisibilityState
    let changedSummary: String
    let consequencePhrase: String
    let rollbackState: String
    let treatyIDs: [String]
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceID: String
    let whatAmbitionsKnowsRoute: String
    let reversible: Bool
    let localOnly: Bool
}

struct LifeConsequenceTrace: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let goalReferenceID: String
    let scheduleInstallTraceID: String?
    let receiptIDs: [String]
    let treatyOutputIDs: [String]
    let issueIDs: [String]
    let replayTraceIDs: [String]
    let fingerprint: String
    let localOnly: Bool
}

struct LifeConsequenceEngineInput: Sendable, Equatable {
    let scheduleInstallRecord: ScheduleInstallRecord
    let impacts: [LifeConsequenceImpact]
    let treaties: [LifeConsequenceGoalTreaty]
    let visibilityPreference: LifeConsequenceVisibilityPreference
    let evaluatedAt: String
    let localOnly: Bool

    init(
        scheduleInstallRecord: ScheduleInstallRecord,
        impacts: [LifeConsequenceImpact],
        treaties: [LifeConsequenceGoalTreaty],
        visibilityPreference: LifeConsequenceVisibilityPreference,
        evaluatedAt: String,
        localOnly: Bool = true
    ) {
        self.scheduleInstallRecord = scheduleInstallRecord
        self.impacts = impacts
        self.treaties = treaties
        self.visibilityPreference = visibilityPreference
        self.evaluatedAt = evaluatedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.localOnly = localOnly
    }
}
