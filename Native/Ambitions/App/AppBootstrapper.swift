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
            let container = try await AppContainerFactory.make(source: resolvedSource)
            phase = .ready(container)
        } catch {
            phase = .failed("Bootstrap failed: \(error.localizedDescription)")
        }
    }

    func retry() async {
        hasStarted = false
        await start()
    }

    private var resolvedSource: AppSession.BootstrapSource {
        switch mode {
        case .preview:
            .preview
        case .live:
            .live
        case .automatic:
            ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" ? .preview : .live
        }
    }
}
