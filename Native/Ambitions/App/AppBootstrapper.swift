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
        } catch {
            phase = .failed("Bootstrap failed: \(error.localizedDescription)")
        }
    }

    func retry() async {
        hasStarted = false
        await start()
    }

    private var resolvedConfiguration: AppBootstrapConfiguration {
        #if DEBUG
        if let override = debugOverrideConfiguration {
            return override
        }
        #endif

        switch mode {
        case .preview:
            .preview
        case .live:
            .live
        #if DEBUG
        case .demo:
            .demo
        #endif
        case .automatic:
            ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" ? .preview : .live
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
}
