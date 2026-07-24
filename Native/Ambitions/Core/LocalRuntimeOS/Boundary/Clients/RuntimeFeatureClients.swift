import Foundation

struct RuntimeMutationFeatureClients: Sendable {
    let capture: CaptureRuntimeMutationClient
    let goalStep: GoalStepRuntimeMutationClient
    let scheduleReminder: ScheduleReminderRuntimeMutationClient
    let profile: ProfileRuntimeMutationClient
    let historyRepair: HistoryRepairRuntimeMutationClient
    let importDeletion: ImportDeletionRuntimeMutationClient
    let externalOperation: ExternalOperationRuntimeMutationClient
}

struct RuntimeProjectionFeatureClients: Sendable {
    let today: TodayRuntimeQueryClient
    let goals: GoalsRuntimeQueryClient
    let time: TimeRuntimeQueryClient
    let you: YouRuntimeQueryClient
    let search: SearchRuntimeQueryClient
}

struct RuntimeInspectionFeatureClients: Sendable {
    let objectInspection: ObjectInspectionRuntimeQueryClient
    let history: HistoryRuntimeQueryClient
    let recovery: RecoveryRuntimeQueryClient
}

struct RuntimeFeatureClients: Sendable {
    let mutations: RuntimeMutationFeatureClients
    let projections: RuntimeProjectionFeatureClients
    let inspection: RuntimeInspectionFeatureClients
    let navigation: RuntimeNavigationClient
}
