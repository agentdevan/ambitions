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

    init(mode: BootstrapMode = .automatic) {
        self.mode = mode
    }

    func start() async {
        guard hasStarted == false else { return }
        hasStarted = true
        phase = .launching

        do {
            let container = try await AppContainerFactory.make(configuration: resolvedConfiguration)
            phase = .ready(container)
            flushPendingDeepLinks(using: container)
        } catch {
            phase = .failed("Bootstrap failed: \(error.localizedDescription)")
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
        container.externalRouter.handleWidgetPayload(payload)
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
        guard let rawValue = ProcessInfo.processInfo.environment["AMBITIONS_BOOTSTRAP_MODE"]?.lowercased() else {
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

    func requestNotificationAuthorizationOptIn() async -> Bool {
        guard case let .ready(container) = phase else { return false }
        let granted = await container.notificationService.requestAuthorizationOptIn()
        if granted {
            await container.notificationService.refreshSchedule(now: .now)
        }
        return granted
    }
}
