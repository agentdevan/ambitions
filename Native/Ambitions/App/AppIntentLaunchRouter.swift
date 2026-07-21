import Foundation
import Observation

@MainActor
protocol AppIntentPendingLaunchRouting: AnyObject {
    func queue(_ url: URL)
    func consumePendingURL() -> URL?
}

@MainActor
@Observable
final class AppIntentLaunchRouter: AppIntentPendingLaunchRouting {
    static let shared = AppIntentLaunchRouter()

    private var pendingURLs: [URL] = []

    init() {}

    func queue(_ url: URL) {
        pendingURLs.append(url)
    }

    func consumePendingURL() -> URL? {
        guard pendingURLs.isEmpty == false else { return nil }
        return pendingURLs.removeFirst()
    }
}
