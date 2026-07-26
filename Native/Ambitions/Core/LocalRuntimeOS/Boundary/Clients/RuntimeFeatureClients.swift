import Foundation

struct RuntimeMutationFeatureClients: Sendable {
    let capture: CaptureRuntimeMutationClient
    let goalStep: GoalStepRuntimeMutationClient
    let scheduleReminder: ScheduleReminderRuntimeMutationClient
    let profile: ProfileRuntimeMutationClient
    let historyRepair: HistoryRepairRuntimeMutationClient
    let importDeletion: ImportDeletionRuntimeMutationClient
    let externalOperation: ExternalOperationRuntimeMutationClient
    let compensation: CompensationRuntimeMutationClient
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
    let history: LegacyProjectionHistoryRuntimeQueryClient
    let recovery: LegacyProjectionRecoveryRuntimeQueryClient
}

struct RuntimeFeatureClients: Sendable {
    let mutations: RuntimeMutationFeatureClients
    let projections: RuntimeProjectionFeatureClients
    let inspection: RuntimeInspectionFeatureClients
    let navigation: RuntimeNavigationClient
}
