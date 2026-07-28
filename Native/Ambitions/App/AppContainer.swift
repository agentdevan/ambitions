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
    let runtimeAuthority: RuntimeMutationAuthorityComposition
    var appearancePreference: AppAppearancePreference
    var accentFamily: AmbitionAccentFamily
    #if DEBUG
    var debugSystemThemeModeOverride: AmbitionThemeMode?
    #endif
    let navigation: StageStore
    let todayService: any TodayServicing
    let todayReceiptCommands: any TodayReceiptCommanding
    let captureService: any CaptureServicing
    let goalsService: any GoalsServicing
    let timeRitualsService: any TimeRitualsServicing
    let timeService: any TimeServicing
    let insightsService: any InsightsServicing
    let youService: any YouServicing
    let youPreferencesCommands: any YouPreferencesCommanding
    let notificationService: any NotificationServicing
    let calendarRemindersService: any CalendarRemindersServicing
    let actionRouter: any AppActionRouting
    let externalRouter: any AppExternalRouting
    let externalActionService: any ExternalActionCommandExecuting
    let externalCreationImportService: any ExternalCreationImporting
    let sourceAtlasLifecycleRefreshService: any SourceAtlasPublicPackLifecycleRefreshing
    let commandRouter: any ShellCommandRouting
    let memoryLensService: any MemoryLensServicing
    let onboardingService: any OnboardingServicing

    init(
        bootstrapConfiguration: AppBootstrapConfiguration,
        session: AppSession,
        clock: any AmbitionsClock,
        runtimeCommandClient: RuntimeCommandClient,
        runtimeAuthority: RuntimeMutationAuthorityComposition,
        appearancePreference: AppAppearancePreference,
        accentFamily: AmbitionAccentFamily,
        navigation: StageStore,
        todayService: any TodayServicing,
        todayReceiptCommands: any TodayReceiptCommanding,
        captureService: any CaptureServicing,
        goalsService: any GoalsServicing,
        timeRitualsService: any TimeRitualsServicing,
        timeService: any TimeServicing,
        insightsService: any InsightsServicing,
        youService: any YouServicing,
        youPreferencesCommands: any YouPreferencesCommanding,
        systemSettingsOpener: SystemSettingsOpeningClient,
        notificationService: any NotificationServicing,
        calendarRemindersService: any CalendarRemindersServicing,
        actionRouter: any AppActionRouting,
        externalRouter: any AppExternalRouting,
        externalActionService: any ExternalActionCommandExecuting,
        externalCreationImportService: any ExternalCreationImporting,
        sourceAtlasLifecycleRefreshService: any SourceAtlasPublicPackLifecycleRefreshing = SourceAtlasPublicPackLifecycleRefreshService(
            registry: SourceAtlasPublicPackRefreshTargetRegistryArtifactLoader.defaultAppRegistry()
        ),
        commandRouter: any ShellCommandRouting,
        memoryLensService: any MemoryLensServicing,
        onboardingService: any OnboardingServicing,
        captureGoalHandoffCommands: CaptureGoalHandoffService
    ) {
        self.shell = AppShellCapability(
            navigation: navigation,
            actionRouter: actionRouter,
            commandRouter: commandRouter,
            memoryLensService: memoryLensService
        )
        self.runtimeCapability = AppRuntimeCapability(
            clock: clock,
            todayService: todayService,
            todayReceiptCommands: todayReceiptCommands,
            captureService: captureService,
            goalsService: goalsService,
            timeRitualsService: timeRitualsService,
            timeService: timeService,
            insightsService: insightsService,
            youService: youService,
            youPreferencesCommands: youPreferencesCommands,
            captureGoalHandoffCommands: captureGoalHandoffCommands
        )
        self.persistence = AppPersistenceCapability(
            bootstrapConfiguration: bootstrapConfiguration,
            usesInMemoryStore: bootstrapConfiguration.usesInMemoryStore
        )
        self.platform = AppPlatformCapability(
            systemSettingsOpener: systemSettingsOpener,
            notificationService: notificationService,
            calendarRemindersService: calendarRemindersService,
            externalRouter: externalRouter,
            externalActionService: externalActionService,
            externalCreationImportService: externalCreationImportService,
            sourceAtlasLifecycleRefreshService: sourceAtlasLifecycleRefreshService
        )
        self.featureFactory = AppFeatureFactoryCapability(
            clock: clock,
            runtimeCommandClient: runtimeCommandClient,
            todayService: todayService,
            todayReceiptCommands: todayReceiptCommands,
            captureService: captureService,
            goalsService: goalsService,
            timeRitualsService: timeRitualsService,
            timeService: timeService,
            insightsService: insightsService,
            youService: youService,
            youPreferencesCommands: youPreferencesCommands,
            captureGoalHandoffCommands: captureGoalHandoffCommands
        )
        self.session = session
        self.clock = clock
        self.runtimeAuthority = runtimeAuthority
        self.appearancePreference = appearancePreference
        self.accentFamily = accentFamily
        self.navigation = navigation
        self.todayService = todayService
        self.todayReceiptCommands = todayReceiptCommands
        self.captureService = captureService
        self.goalsService = goalsService
        self.timeRitualsService = timeRitualsService
        self.timeService = timeService
        self.insightsService = insightsService
        self.youService = youService
        self.youPreferencesCommands = youPreferencesCommands
        self.notificationService = notificationService
        self.calendarRemindersService = calendarRemindersService
        self.actionRouter = actionRouter
        self.externalRouter = externalRouter
        self.externalActionService = externalActionService
        self.externalCreationImportService = externalCreationImportService
        self.sourceAtlasLifecycleRefreshService = sourceAtlasLifecycleRefreshService
        self.commandRouter = commandRouter
        self.memoryLensService = memoryLensService
        self.onboardingService = onboardingService
    }
}
import AmbitionsTimeFoundation
