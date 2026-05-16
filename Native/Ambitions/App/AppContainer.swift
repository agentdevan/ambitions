import AmbitionsDesignSystem
import Foundation
import Observation

@MainActor
@Observable
final class AppContainer {
    let session: AppSession
    let runtime: AmbitionsRuntime
    var appearancePreference: AppAppearancePreference
    var accentFamily: AmbitionAccentFamily
    let navigation: AppNavigationModel
    let todayService: any TodayServicing
    let captureService: any CaptureServicing
    let goalsService: any GoalsServicing
    let habitsService: any HabitsServicing
    let timeService: any PlanServicing
    let insightsService: any InsightsServicing
    let youService: any YouServicing
    let notificationService: any NotificationServicing
    let calendarRemindersService: any CalendarRemindersServicing
    let actionRouter: any AppActionRouting
    let externalRouter: any AppExternalRouting
    let externalActionService: any ExternalActionCommandExecuting
    let externalCreationImportService: any ExternalCreationImporting
    let commandRouter: any ShellCommandRouting
    let memoryLensService: any MemoryLensServicing
    let onboardingService: any OnboardingServicing

    init(
        session: AppSession,
        runtime: AmbitionsRuntime,
        appearancePreference: AppAppearancePreference,
        accentFamily: AmbitionAccentFamily,
        navigation: AppNavigationModel,
        todayService: any TodayServicing,
        captureService: any CaptureServicing,
        goalsService: any GoalsServicing,
        habitsService: any HabitsServicing,
        timeService: any PlanServicing,
        insightsService: any InsightsServicing,
        youService: any YouServicing,
        notificationService: any NotificationServicing,
        calendarRemindersService: any CalendarRemindersServicing,
        actionRouter: any AppActionRouting,
        externalRouter: any AppExternalRouting,
        externalActionService: any ExternalActionCommandExecuting,
        externalCreationImportService: any ExternalCreationImporting,
        commandRouter: any ShellCommandRouting,
        memoryLensService: any MemoryLensServicing,
        onboardingService: any OnboardingServicing
    ) {
        self.session = session
        self.runtime = runtime
        self.appearancePreference = appearancePreference
        self.accentFamily = accentFamily
        self.navigation = navigation
        self.todayService = todayService
        self.captureService = captureService
        self.goalsService = goalsService
        self.habitsService = habitsService
        self.timeService = timeService
        self.insightsService = insightsService
        self.youService = youService
        self.notificationService = notificationService
        self.calendarRemindersService = calendarRemindersService
        self.actionRouter = actionRouter
        self.externalRouter = externalRouter
        self.externalActionService = externalActionService
        self.externalCreationImportService = externalCreationImportService
        self.commandRouter = commandRouter
        self.memoryLensService = memoryLensService
        self.onboardingService = onboardingService
    }
}
