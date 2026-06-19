import AmbitionsDesignSystem
import Foundation

// Capability slices are dependency seams only; SourceRecord, Receipt, and ReplayTrace behavior stays in runtime/proof owners.
struct AppShellCapability {
    let navigation: AppNavigationModel
    let actionRouter: any AppActionRouting
    let commandRouter: any ShellCommandRouting
    let memoryLensService: any MemoryLensServicing
}

struct AppRuntimeCapability {
    let runtime: AmbitionsRuntime
    let clock: any AmbitionsClock
    let todayService: any TodayServicing
    let captureService: any CaptureServicing
    let goalsService: any GoalsServicing
    let timeRitualsService: any TimeRitualsServicing
    let timeService: any TimeServicing
    let insightsService: any InsightsServicing
    let youService: any YouServicing
}

struct AppPersistenceCapability {
    let bootstrapConfiguration: AppBootstrapConfiguration
    let usesInMemoryStore: Bool
}

struct AppPlatformCapability {
    let notificationService: any NotificationServicing
    let calendarRemindersService: any CalendarRemindersServicing
    let externalRouter: any AppExternalRouting
    let externalActionService: any ExternalActionCommandExecuting
    let externalCreationImportService: any ExternalCreationImporting
}

struct AppUserSystemCapability {
    let session: AppSession
    let onboardingService: any OnboardingServicing
    let applyAppearancePreference: @MainActor (AppAppearancePreference, AmbitionAccentFamily) -> Void
}

struct AppFeatureFactoryCapability {
    let clock: any AmbitionsClock
    let todayService: any TodayServicing
    let captureService: any CaptureServicing
    let goalsService: any GoalsServicing
    let timeRitualsService: any TimeRitualsServicing
    let timeService: any TimeServicing
    let insightsService: any InsightsServicing
    let youService: any YouServicing
}
