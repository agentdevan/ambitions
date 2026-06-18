import AmbitionsDesignSystem
import Foundation
import Observation

@MainActor
@Observable
final class AppContainer {
    let shell: AppShellCapability
    let runtimeCapability: AppRuntimeCapability
    let persistence: AppPersistenceCapability
    let platform: AppPlatformCapability
    @ObservationIgnored
    lazy var userSystem: AppUserSystemCapability = AppUserSystemCapability(
        session: session,
        onboardingService: onboardingService,
        applyAppearancePreference: { [weak self] appearancePreference, accentFamily in
            self?.appearancePreference = appearancePreference
            self?.accentFamily = accentFamily
        }
    )
    let featureFactory: AppFeatureFactoryCapability

    let session: AppSession
    let clock: any AmbitionsClock
    let runtime: AmbitionsRuntime
    var appearancePreference: AppAppearancePreference
    var accentFamily: AmbitionAccentFamily
    let navigation: AppNavigationModel
    let todayService: any TodayServicing
    let captureService: any CaptureServicing
    let goalsService: any GoalsServicing
    let habitsService: any HabitsServicing
    let timeService: any TimeServicing
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
        bootstrapConfiguration: AppBootstrapConfiguration,
        session: AppSession,
        clock: any AmbitionsClock,
        runtime: AmbitionsRuntime,
        appearancePreference: AppAppearancePreference,
        accentFamily: AmbitionAccentFamily,
        navigation: AppNavigationModel,
        todayService: any TodayServicing,
        captureService: any CaptureServicing,
        goalsService: any GoalsServicing,
        habitsService: any HabitsServicing,
        timeService: any TimeServicing,
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
        self.shell = AppShellCapability(
            navigation: navigation,
            actionRouter: actionRouter,
            commandRouter: commandRouter,
            memoryLensService: memoryLensService
        )
        self.runtimeCapability = AppRuntimeCapability(
            runtime: runtime,
            clock: clock,
            todayService: todayService,
            captureService: runtime.captureService,
            goalsService: runtime.goalsService,
            habitsService: runtime.habitsService,
            timeService: runtime.timeService,
            insightsService: runtime.insightsService,
            youService: runtime.youService
        )
        self.persistence = AppPersistenceCapability(
            bootstrapConfiguration: bootstrapConfiguration,
            usesInMemoryStore: bootstrapConfiguration.usesInMemoryStore
        )
        self.platform = AppPlatformCapability(
            notificationService: notificationService,
            calendarRemindersService: calendarRemindersService,
            externalRouter: externalRouter,
            externalActionService: externalActionService,
            externalCreationImportService: externalCreationImportService
        )
        self.featureFactory = AppFeatureFactoryCapability(
            clock: clock,
            todayService: todayService,
            captureService: runtime.captureService,
            goalsService: runtime.goalsService,
            habitsService: runtime.habitsService,
            timeService: runtime.timeService,
            insightsService: runtime.insightsService,
            youService: runtime.youService
        )
        self.session = session
        self.clock = clock
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
