import AmbitionsDesignSystem
import Foundation
import Observation

@MainActor
@Observable
final class AppBootstrapper {
    enum Phase {
        case idle
        case launching
        case ready(AppContainer)
        case failed(String)
    }

    enum BootstrapMode {
        case automatic
        case preview
        case live
        #if DEBUG
        case demo
        #endif
    }

    var phase: Phase = .idle

    private let mode: BootstrapMode
    private var hasStarted = false
    private var pendingDeepLinks: [URL] = []
    private var didQueueConfiguredLaunchURL = false

    init(mode: BootstrapMode = .automatic) {
        self.mode = mode
    }

    func start() async {
        guard hasStarted == false else { return }
        hasStarted = true
        phase = .launching
        queueConfiguredLaunchURLIfNeeded()

        do {
            let container = try await AppContainerFactory.make(configuration: resolvedConfiguration)
            phase = .ready(container)
            await importPendingExternalCreations(using: container)
            flushPendingDeepLinks(using: container)
        } catch {
            phase = .failed("Ambitions could not finish launching: \(error.localizedDescription)")
        }
    }

    func retry() async {
        hasStarted = false
        await start()
    }

    func handleDeepLink(_ url: URL) {
        switch phase {
        case let .ready(container):
            container.externalRouter.handleDeepLink(url)
        case .idle, .launching, .failed:
            pendingDeepLinks.append(url)
        }
    }

    func consumePendingAppIntentLaunchIfNeeded() {
        guard let url = AppIntentLaunchRouter.shared.consumePendingURL() else { return }
        handleDeepLink(url)
    }

    func consumePendingExternalCreationsIfNeeded() {
        guard case let .ready(container) = phase else { return }
        Task {
            await importPendingExternalCreations(using: container)
        }
    }

    func handleNotificationPayload(_ payload: AppNotificationRoutingPayload) {
        guard case let .ready(container) = phase else { return }
        Task {
            _ = await container.externalActionService.execute(
                ExternalActionCommand(notificationPayload: payload),
                now: .now
            )
            container.externalRouter.handleNotificationPayload(payload)
        }
    }

    func handleWidgetPayload(_ payload: AppWidgetRoutingPayload) {
        guard case let .ready(container) = phase else { return }
        Task {
            _ = await container.externalActionService.execute(
                ExternalActionCommand(widgetPayload: payload),
                now: .now
            )
            container.externalRouter.handleWidgetPayload(payload)
        }
    }

    private var resolvedConfiguration: AppBootstrapConfiguration {
        #if DEBUG
        if let override = debugOverrideConfiguration {
            return override
        }
        #endif

        switch mode {
        case .preview:
            return .preview
        case .live:
            return .live
        #if DEBUG
        case .demo:
            return .demo
        #endif
        case .automatic:
            return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" ? .preview : .live
        }
    }

    #if DEBUG
    private var debugOverrideConfiguration: AppBootstrapConfiguration? {
        guard let rawValue = configuredValue(for: "AMBITIONS_BOOTSTRAP_MODE")?.lowercased() else {
            return nil
        }

        switch rawValue {
        case "preview":
            return .preview
        case "live":
            return .live
        case "demo":
            return .demo
        default:
            return nil
        }
    }
    #endif

    private func flushPendingDeepLinks(using container: AppContainer) {
        guard pendingDeepLinks.isEmpty == false else { return }
        let queued = pendingDeepLinks
        pendingDeepLinks.removeAll(keepingCapacity: false)
        for url in queued {
            container.externalRouter.handleDeepLink(url)
        }
    }

    private func importPendingExternalCreations(using container: AppContainer) async {
        let result = await container.externalCreationImportService.importPendingCreations(now: .now)
        guard result.importedCount > 0 else { return }
        let routeSource: AppExternalRouteSource = result.source == .appIntent ? .appIntent : .shareExtension
        let entrySource: ShellCommandEntrySource = result.source == .appIntent ? .appIntent : .shareExtension

        switch result.preferredLanding {
        case .createGoal:
            container.externalRouter.dispatch(
                .presentOverlay(.createGoal(entrySource: entrySource)),
                source: routeSource
            )
        case .captureInbox, .none:
            container.externalRouter.dispatch(
                .openTimeRoute(.captureInbox),
                source: routeSource
            )
        }
    }

    private func queueConfiguredLaunchURLIfNeeded() {
        guard didQueueConfiguredLaunchURL == false else { return }
        didQueueConfiguredLaunchURL = true
        guard let rawValue = configuredValue(for: "AMBITIONS_LAUNCH_URL"),
              let url = URL(string: rawValue) else {
            return
        }
        pendingDeepLinks.append(url)
    }

    private func configuredValue(for key: String) -> String? {
        if let environmentValue = ProcessInfo.processInfo.environment[key], environmentValue.isEmpty == false {
            return environmentValue
        }

        let arguments = ProcessInfo.processInfo.arguments
        if let index = arguments.firstIndex(of: "-\(key)"), arguments.indices.contains(index + 1) {
            let argumentValue = arguments[index + 1]
            return argumentValue.isEmpty ? nil : argumentValue
        }

        return nil
    }

    func requestNotificationAuthorizationOptIn() async -> Bool {
        guard case let .ready(container) = phase else { return false }
        let granted = await container.notificationService.requestAuthorizationOptIn()
        if granted {
            await container.notificationService.refreshSchedule(now: .now)
        }
        return granted
    }
}
