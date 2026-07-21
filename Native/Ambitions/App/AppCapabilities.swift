import AmbitionsDesignSystem
import Foundation
#if canImport(UIKit)
    import UIKit
#endif

struct SystemSettingsOpeningClient {
    private let openAction: @MainActor () -> Void

    init(openAction: @escaping @MainActor () -> Void) {
        self.openAction = openAction
    }

    @MainActor
    func openSystemSettings() {
        openAction()
    }

    static let unavailable = SystemSettingsOpeningClient(openAction: {})

    #if canImport(UIKit)
        static let live = SystemSettingsOpeningClient {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(url)
        }
    #endif
}

// Capability slices are dependency seams only; SourceRecord, Receipt, and ReplayTrace behavior stays in runtime/proof owners.
struct AppShellCapability {
    let navigation: StageStore
    let actionRouter: any AppActionRouting
    let commandRouter: any ShellCommandRouting
    let memoryLensService: any MemoryLensServicing
}

struct AppRuntimeCapability {
    let runtime: AmbitionsRuntime
    let clock: any AmbitionsClock
    let todayService: any TodayServicing
    let todayReceiptCommands: any TodayReceiptCommanding
    let captureService: any CaptureServicing
    let goalsService: any GoalsServicing
    let timeRitualsService: any TimeRitualsServicing
    let timeService: any TimeServicing
    let insightsService: any InsightsServicing
    let youService: any YouServicing
    let youPreferencesCommands: any YouPreferencesCommanding
    let captureGoalHandoffCommands: CaptureGoalHandoffService
}

struct AppPersistenceCapability {
    let bootstrapConfiguration: AppBootstrapConfiguration
    let usesInMemoryStore: Bool
}

struct AppPlatformCapability {
    let systemSettingsOpener: SystemSettingsOpeningClient
    let notificationService: any NotificationServicing
    let calendarRemindersService: any CalendarRemindersServicing
    let externalRouter: any AppExternalRouting
    let externalActionService: any ExternalActionCommandExecuting
    let externalCreationImportService: any ExternalCreationImporting
    let sourceAtlasLifecycleRefreshService: any SourceAtlasPublicPackLifecycleRefreshing
}

struct AppUserSystemCapability {
    let session: AppSession
    let onboardingService: any OnboardingServicing
    let applyAppearancePreference: @MainActor (AppAppearancePreference, AmbitionAccentFamily) -> Void
}

struct AppFeatureFactoryCapability {
    let clock: any AmbitionsClock
    let runtimeCommandClient: RuntimeCommandClient
    let todayService: any TodayServicing
    let todayReceiptCommands: any TodayReceiptCommanding
    let captureService: any CaptureServicing
    let goalsService: any GoalsServicing
    let timeRitualsService: any TimeRitualsServicing
    let timeService: any TimeServicing
    let insightsService: any InsightsServicing
    let youService: any YouServicing
    let youPreferencesCommands: any YouPreferencesCommanding
}
import AmbitionsTimeFoundation
