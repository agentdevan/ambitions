import Foundation

struct RuntimeCommandCaseID: RawRepresentable, Sendable, Equatable, Hashable, Comparable {
    let rawValue: String

    init?(rawValue: String) {
        guard rawValue.isEmpty == false,
              rawValue == rawValue.trimmingCharacters(in: .whitespacesAndNewlines) else { return nil }
        self.rawValue = rawValue
    }

    private init(canonicalRawValue: String) {
        rawValue = canonicalRawValue
    }

    static func < (lhs: RuntimeCommandCaseID, rhs: RuntimeCommandCaseID) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var feature: RuntimePreparationFeature? {
        let family = rawValue.split(separator: ".", maxSplits: 1).first.map(String.init)
        switch family {
        case "capture": .capture
        case "goal", "step": .goalStep
        case "schedule", "reminder": .scheduleReminder
        case "profile": .profile
        case "history", "repair": .historyRepair
        case "importDeletion": .importDeletion
        case "externalOperation": .externalOperation
        default: nil
        }
    }

    var route: RuntimeCommandCaseRoute {
        switch rawValue {
        case "history.openDestination", "repair.openDestination": .navigation
        default: .mutation
        }
    }

    static let all: Set<RuntimeCommandCaseID> = Set([
        "capture.quickCapture", "capture.routeCommitment", "capture.attachToGoal", "capture.markWaiting", "capture.archive",
        "goal.create", "goal.update", "goal.setPriority", "goal.setUrgency", "goal.setDeadline", "goal.setContextLens",
        "goal.clearContextLens", "goal.addDeliverable", "goal.removeDeliverable", "goal.addScopeItem", "goal.removeScopeItem",
        "step.startSession", "step.complete", "step.delay", "step.split", "step.recover", "step.todayGoalStep",
        "schedule.createItem", "schedule.schedule", "schedule.placeStep", "schedule.protectWindow", "schedule.correctWindow",
        "schedule.undo", "schedule.ritual", "schedule.calendarWrite",
        "reminder.create", "reminder.update", "reminder.delete",
        "profile.updatePreferences",
        "history.openDestination", "history.askWhy", "history.dismissRecommendation", "history.todayReceipt",
        "repair.recover", "repair.openDestination",
        "importDeletion.prepareExport", "importDeletion.performExport", "importDeletion.deleteObject", "importDeletion.forgetMemory",
        "externalOperation.reminder", "externalOperation.calendar_event",
    ].compactMap(RuntimeCommandCaseID.init(rawValue:)))
}

enum RuntimeCommandCaseRoute: String, Sendable, Equatable, Hashable {
    case mutation
    case navigation
}

struct RuntimeCommandCaseOwnership: Sendable, Equatable, Hashable {
    let caseID: RuntimeCommandCaseID
    let route: RuntimeCommandCaseRoute
}

extension RuntimeCommandPayload {
    var registrationCaseID: RuntimeCommandCaseID {
        let rawValue: String = switch self {
        case let .capture(value):
            switch value.action {
            case .quickCapture: "capture.quickCapture"
            case .routeCommitment: "capture.routeCommitment"
            case .attachToGoal: "capture.attachToGoal"
            case .markWaiting: "capture.markWaiting"
            case .archive: "capture.archive"
            }
        case let .goal(value): "goal.\(value.action.rawValue)"
        case let .step(value):
            switch value.action {
            case .startSession: "step.startSession"
            case .complete: "step.complete"
            case .delay: "step.delay"
            case .split: "step.split"
            case .recover: "step.recover"
            case .todayGoalStep: "step.todayGoalStep"
            }
        case let .schedule(value):
            switch value.action {
            case .createItem: "schedule.createItem"
            case .schedule: "schedule.schedule"
            case .placeStep: "schedule.placeStep"
            case .protectWindow: "schedule.protectWindow"
            case .correctWindow: "schedule.correctWindow"
            case .undo: "schedule.undo"
            case .ritual: "schedule.ritual"
            case .calendarWrite: "schedule.calendarWrite"
            }
        case let .reminder(value): "reminder.\(value.action.rawValue)"
        case let .profile(value): "profile.\(value.action.rawValue)"
        case let .history(value):
            switch value.action {
            case .openDestination: "history.openDestination"
            case .askWhy: "history.askWhy"
            case .dismissRecommendation: "history.dismissRecommendation"
            case .todayReceipt: "history.todayReceipt"
            }
        case let .repair(value): "repair.\(value.action.rawValue)"
        case let .importDeletion(value): "importDeletion.\(value.action.rawValue)"
        case let .externalOperation(value): "externalOperation.\(value.kind.rawValue)"
        }
        return RuntimeCommandCaseID(canonicalRawValue: rawValue)
    }
}

struct RuntimeFeatureHandlerRegistration: Sendable, Equatable {
    let feature: RuntimePreparationFeature
    let reducerType: String
    let cases: [RuntimeCommandCaseOwnership]

    init(
        feature: RuntimePreparationFeature,
        reducerType: String,
        cases: [RuntimeCommandCaseOwnership]
    ) {
        self.feature = feature
        self.reducerType = reducerType
        self.cases = cases.sorted { $0.caseID < $1.caseID }
    }
}

struct RuntimeProjectorRegistration: Sendable, Equatable, Hashable {
    let projectionID: ProjectionID
    let owner: RuntimePreparationFeature
    let order: Int
}

struct RuntimeMaterializerRegistration: Sendable, Equatable, Hashable {
    let projectionID: ProjectionID
    let owner: RuntimePreparationFeature
    let order: Int
}

enum RuntimeFeatureQueryID: String, Sendable, Equatable, Hashable, CaseIterable {
    case today, goals, time, you, search, objectInspection, history, recovery
}

struct RuntimeFeatureQueryRegistration: Sendable, Equatable, Hashable {
    let queryID: RuntimeFeatureQueryID
    let owner: RuntimePreparationFeature
}

struct RuntimeFeatureMutationClientRegistration: Sendable, Equatable, Hashable {
    let feature: RuntimePreparationFeature
    let clientType: String
}

protocol RuntimeFeatureRegistrationModule: Sendable {
    associatedtype MutationClient: Sendable
    var mutationClient: MutationClient { get }
    var featureID: RuntimePreparationFeature { get }
    var order: Int { get }
    var handler: RuntimeFeatureHandlerRegistration { get }
    var mutationClientRegistration: RuntimeFeatureMutationClientRegistration { get }
    var projectorRegistrations: [RuntimeProjectorRegistration] { get }
    var materializerRegistrations: [RuntimeMaterializerRegistration] { get }
    var queryRegistrations: [RuntimeFeatureQueryRegistration] { get }
}

private func ownership(
    _ names: [String],
    navigation: Set<String> = []
) -> [RuntimeCommandCaseOwnership] {
    names.compactMap { name in
        RuntimeCommandCaseID(rawValue: name).map {
            RuntimeCommandCaseOwnership(
                caseID: $0,
                route: navigation.contains(name) ? .navigation : .mutation
            )
        }
    }
}

struct CaptureRuntimeFeatureModule: RuntimeFeatureRegistrationModule {
    let mutationClient: CaptureRuntimeMutationClient
    let featureID = RuntimePreparationFeature.capture
    let order = 0
    let handler = RuntimeFeatureHandlerRegistration(
        feature: .capture,
        reducerType: "CaptureMutationReducer",
        cases: ownership(["capture.quickCapture", "capture.routeCommitment", "capture.attachToGoal", "capture.markWaiting", "capture.archive"])
    )
    let mutationClientRegistration = RuntimeFeatureMutationClientRegistration(feature: .capture, clientType: "CaptureRuntimeMutationClient")
    let projectorRegistrations = [
        RuntimeProjectorRegistration(projectionID: .today, owner: .capture, order: 0),
        RuntimeProjectorRegistration(projectionID: .goals, owner: .capture, order: 1),
        RuntimeProjectorRegistration(projectionID: .search, owner: .capture, order: 2),
    ]
    let materializerRegistrations = [
        RuntimeMaterializerRegistration(projectionID: .today, owner: .capture, order: 0),
        RuntimeMaterializerRegistration(projectionID: .goals, owner: .capture, order: 1),
        RuntimeMaterializerRegistration(projectionID: .search, owner: .capture, order: 2),
    ]
    let queryRegistrations = [
        RuntimeFeatureQueryRegistration(queryID: .today, owner: .capture),
        RuntimeFeatureQueryRegistration(queryID: .goals, owner: .capture),
        RuntimeFeatureQueryRegistration(queryID: .search, owner: .capture),
    ]
}

struct GoalStepRuntimeFeatureModule: RuntimeFeatureRegistrationModule {
    let mutationClient: GoalStepRuntimeMutationClient
    let featureID = RuntimePreparationFeature.goalStep
    let order = 1
    let handler = RuntimeFeatureHandlerRegistration(
        feature: .goalStep,
        reducerType: "GoalStepMutationReducer",
        cases: ownership([
            "goal.create", "goal.update", "goal.setPriority", "goal.setUrgency", "goal.setDeadline", "goal.setContextLens",
            "goal.clearContextLens", "goal.addDeliverable", "goal.removeDeliverable", "goal.addScopeItem", "goal.removeScopeItem",
            "step.startSession", "step.complete", "step.delay", "step.split", "step.recover", "step.todayGoalStep",
        ])
    )
    let mutationClientRegistration = RuntimeFeatureMutationClientRegistration(feature: .goalStep, clientType: "GoalStepRuntimeMutationClient")
    let projectorRegistrations = [
        RuntimeProjectorRegistration(projectionID: .today, owner: .goalStep, order: 0),
        RuntimeProjectorRegistration(projectionID: .goals, owner: .goalStep, order: 1),
        RuntimeProjectorRegistration(projectionID: .search, owner: .goalStep, order: 2),
    ]
    let materializerRegistrations = [
        RuntimeMaterializerRegistration(projectionID: .today, owner: .goalStep, order: 0),
        RuntimeMaterializerRegistration(projectionID: .goals, owner: .goalStep, order: 1),
        RuntimeMaterializerRegistration(projectionID: .search, owner: .goalStep, order: 2),
    ]
    let queryRegistrations = [
        RuntimeFeatureQueryRegistration(queryID: .today, owner: .goalStep),
        RuntimeFeatureQueryRegistration(queryID: .goals, owner: .goalStep),
        RuntimeFeatureQueryRegistration(queryID: .search, owner: .goalStep),
    ]
}

struct ScheduleReminderRuntimeFeatureModule: RuntimeFeatureRegistrationModule {
    let mutationClient: ScheduleReminderRuntimeMutationClient
    let featureID = RuntimePreparationFeature.scheduleReminder
    let order = 2
    let handler = RuntimeFeatureHandlerRegistration(
        feature: .scheduleReminder,
        reducerType: "ScheduleReminderMutationReducer",
        cases: ownership([
            "schedule.createItem", "schedule.schedule", "schedule.placeStep", "schedule.protectWindow", "schedule.correctWindow",
            "schedule.undo", "schedule.ritual", "schedule.calendarWrite", "reminder.create", "reminder.update", "reminder.delete",
        ])
    )
    let mutationClientRegistration = RuntimeFeatureMutationClientRegistration(feature: .scheduleReminder, clientType: "ScheduleReminderRuntimeMutationClient")
    let projectorRegistrations = [
        RuntimeProjectorRegistration(projectionID: .today, owner: .scheduleReminder, order: 0),
        RuntimeProjectorRegistration(projectionID: .time, owner: .scheduleReminder, order: 1),
        RuntimeProjectorRegistration(projectionID: .search, owner: .scheduleReminder, order: 2),
    ]
    let materializerRegistrations = [
        RuntimeMaterializerRegistration(projectionID: .today, owner: .scheduleReminder, order: 0),
        RuntimeMaterializerRegistration(projectionID: .time, owner: .scheduleReminder, order: 1),
        RuntimeMaterializerRegistration(projectionID: .search, owner: .scheduleReminder, order: 2),
    ]
    let queryRegistrations = [
        RuntimeFeatureQueryRegistration(queryID: .today, owner: .scheduleReminder),
        RuntimeFeatureQueryRegistration(queryID: .time, owner: .scheduleReminder),
        RuntimeFeatureQueryRegistration(queryID: .search, owner: .scheduleReminder),
    ]
}

struct ProfileRuntimeFeatureModule: RuntimeFeatureRegistrationModule {
    let mutationClient: ProfileRuntimeMutationClient
    let featureID = RuntimePreparationFeature.profile
    let order = 3
    let handler = RuntimeFeatureHandlerRegistration(
        feature: .profile,
        reducerType: "ProfileMutationReducer",
        cases: ownership(["profile.updatePreferences"])
    )
    let mutationClientRegistration = RuntimeFeatureMutationClientRegistration(feature: .profile, clientType: "ProfileRuntimeMutationClient")
    let projectorRegistrations = [RuntimeProjectorRegistration(projectionID: .you, owner: .profile, order: 0)]
    let materializerRegistrations = [RuntimeMaterializerRegistration(projectionID: .you, owner: .profile, order: 0)]
    let queryRegistrations = [RuntimeFeatureQueryRegistration(queryID: .you, owner: .profile)]
}

struct HistoryRepairRuntimeFeatureModule: RuntimeFeatureRegistrationModule {
    let mutationClient: HistoryRepairRuntimeMutationClient
    let featureID = RuntimePreparationFeature.historyRepair
    let order = 4
    let handler = RuntimeFeatureHandlerRegistration(
        feature: .historyRepair,
        reducerType: "HistoryRepairMutationReducer",
        cases: ownership(
            ["history.openDestination", "history.askWhy", "history.dismissRecommendation", "history.todayReceipt", "repair.recover", "repair.openDestination"],
            navigation: ["history.openDestination", "repair.openDestination"]
        )
    )
    let mutationClientRegistration = RuntimeFeatureMutationClientRegistration(feature: .historyRepair, clientType: "HistoryRepairRuntimeMutationClient")
    let projectorRegistrations = [RuntimeProjectorRegistration(projectionID: .receipt, owner: .historyRepair, order: 0)]
    let materializerRegistrations = [RuntimeMaterializerRegistration(projectionID: .receipt, owner: .historyRepair, order: 0)]
    let queryRegistrations = [
        RuntimeFeatureQueryRegistration(queryID: .objectInspection, owner: .historyRepair),
        RuntimeFeatureQueryRegistration(queryID: .history, owner: .historyRepair),
        RuntimeFeatureQueryRegistration(queryID: .recovery, owner: .historyRepair),
    ]
}

struct ImportDeletionRuntimeFeatureModule: RuntimeFeatureRegistrationModule {
    let mutationClient: ImportDeletionRuntimeMutationClient
    let featureID = RuntimePreparationFeature.importDeletion
    let order = 5
    let handler = RuntimeFeatureHandlerRegistration(
        feature: .importDeletion,
        reducerType: "ImportDeletionMutationReducer",
        cases: ownership(["importDeletion.prepareExport", "importDeletion.performExport", "importDeletion.deleteObject", "importDeletion.forgetMemory"])
    )
    let mutationClientRegistration = RuntimeFeatureMutationClientRegistration(feature: .importDeletion, clientType: "ImportDeletionRuntimeMutationClient")
    let projectorRegistrations = [
        RuntimeProjectorRegistration(projectionID: .privacy, owner: .importDeletion, order: 0),
        RuntimeProjectorRegistration(projectionID: .receipt, owner: .importDeletion, order: 1),
    ]
    let materializerRegistrations = [
        RuntimeMaterializerRegistration(projectionID: .privacy, owner: .importDeletion, order: 0),
        RuntimeMaterializerRegistration(projectionID: .receipt, owner: .importDeletion, order: 1),
    ]
    let queryRegistrations = [
        RuntimeFeatureQueryRegistration(queryID: .objectInspection, owner: .importDeletion),
        RuntimeFeatureQueryRegistration(queryID: .history, owner: .importDeletion),
    ]
}

struct ExternalOperationRuntimeFeatureModule: RuntimeFeatureRegistrationModule {
    let mutationClient: ExternalOperationRuntimeMutationClient
    let featureID = RuntimePreparationFeature.externalOperation
    let order = 6
    let handler = RuntimeFeatureHandlerRegistration(
        feature: .externalOperation,
        reducerType: "ExternalOperationMutationReducer",
        cases: ownership(["externalOperation.reminder", "externalOperation.calendar_event"])
    )
    let mutationClientRegistration = RuntimeFeatureMutationClientRegistration(feature: .externalOperation, clientType: "ExternalOperationRuntimeMutationClient")
    let projectorRegistrations = [
        RuntimeProjectorRegistration(projectionID: .time, owner: .externalOperation, order: 0),
        RuntimeProjectorRegistration(projectionID: .receipt, owner: .externalOperation, order: 1),
    ]
    let materializerRegistrations = [
        RuntimeMaterializerRegistration(projectionID: .time, owner: .externalOperation, order: 0),
        RuntimeMaterializerRegistration(projectionID: .receipt, owner: .externalOperation, order: 1),
    ]
    let queryRegistrations = [
        RuntimeFeatureQueryRegistration(queryID: .time, owner: .externalOperation),
        RuntimeFeatureQueryRegistration(queryID: .history, owner: .externalOperation),
    ]
}

struct AnyRuntimeFeatureRegistrationModule: RuntimeFeatureRegistrationModule {
    let mutationClient: RuntimeFeatureMutationClientRegistration
    let featureID: RuntimePreparationFeature
    let order: Int
    let handler: RuntimeFeatureHandlerRegistration
    let mutationClientRegistration: RuntimeFeatureMutationClientRegistration
    let projectorRegistrations: [RuntimeProjectorRegistration]
    let materializerRegistrations: [RuntimeMaterializerRegistration]
    let queryRegistrations: [RuntimeFeatureQueryRegistration]

    init(_ module: any RuntimeFeatureRegistrationModule) {
        mutationClient = module.mutationClientRegistration
        featureID = module.featureID
        order = module.order
        handler = module.handler
        mutationClientRegistration = module.mutationClientRegistration
        projectorRegistrations = module.projectorRegistrations
        materializerRegistrations = module.materializerRegistrations
        queryRegistrations = module.queryRegistrations
    }
}

enum RuntimeFeatureRegistrationError: Error, Sendable, Equatable {
    case duplicateFeature(RuntimePreparationFeature)
    case missingFeature(RuntimePreparationFeature)
    case duplicateOrder(Int)
    case duplicateCommandCase(RuntimeCommandCaseID)
    case missingCommandCase(RuntimeCommandCaseID)
    case unexpectedCommandCase(RuntimeCommandCaseID)
    case inconsistentModule(RuntimePreparationFeature)
}

struct RuntimeFeatureRegistrationRegistry: Sendable {
    let modules: [AnyRuntimeFeatureRegistrationModule]

    init(_ modules: [AnyRuntimeFeatureRegistrationModule]) throws {
        var features = Set<RuntimePreparationFeature>()
        var orders = Set<Int>()
        var cases = Set<RuntimeCommandCaseID>()
        for module in modules {
            guard features.insert(module.featureID).inserted else {
                throw RuntimeFeatureRegistrationError.duplicateFeature(module.featureID)
            }
            guard orders.insert(module.order).inserted else {
                throw RuntimeFeatureRegistrationError.duplicateOrder(module.order)
            }
            guard module.handler.feature == module.featureID,
                  module.mutationClientRegistration.feature == module.featureID,
                  module.projectorRegistrations.isEmpty == false,
                  module.materializerRegistrations.isEmpty == false,
                  module.queryRegistrations.isEmpty == false,
                  module.projectorRegistrations.allSatisfy({ $0.owner == module.featureID }),
                  module.materializerRegistrations.allSatisfy({ $0.owner == module.featureID }),
                  module.queryRegistrations.allSatisfy({ $0.owner == module.featureID }) else {
                throw RuntimeFeatureRegistrationError.inconsistentModule(module.featureID)
            }
            for ownership in module.handler.cases {
                guard RuntimeCommandCaseID.all.contains(ownership.caseID) else {
                    throw RuntimeFeatureRegistrationError.unexpectedCommandCase(ownership.caseID)
                }
                guard ownership.caseID.feature == module.featureID,
                      ownership.route == ownership.caseID.route else {
                    throw RuntimeFeatureRegistrationError.inconsistentModule(module.featureID)
                }
                guard cases.insert(ownership.caseID).inserted else {
                    throw RuntimeFeatureRegistrationError.duplicateCommandCase(ownership.caseID)
                }
            }
        }
        for feature in RuntimePreparationFeature.allCases where features.contains(feature) == false {
            throw RuntimeFeatureRegistrationError.missingFeature(feature)
        }
        for caseID in RuntimeCommandCaseID.all.sorted() where cases.contains(caseID) == false {
            throw RuntimeFeatureRegistrationError.missingCommandCase(caseID)
        }
        self.modules = modules.sorted {
            if $0.order != $1.order { return $0.order < $1.order }
            return $0.featureID.rawValue < $1.featureID.rawValue
        }
    }
}

extension RuntimeFeatureHandlerAvailability {
    init(registry: RuntimeFeatureRegistrationRegistry) {
        self.init(features: Set(registry.modules.map(\.featureID)))
    }
}
