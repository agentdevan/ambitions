import AmbitionsTimeFoundation
import Foundation

enum AmbitionsClockFactory {
    static func clock(
        for source: AppSession.BootstrapSource,
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) -> any AmbitionsClock {
        #if DEBUG
        if let override = PreviewClock.environmentOverride(environment) {
            return override
        }
        if source == .preview {
            return PreviewClock.default
        }
        #endif
        return SystemClock()
    }
}
