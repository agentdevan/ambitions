import Foundation
import Observation

@MainActor
@Observable
final class AppIntentLaunchRouter {
    static let shared = AppIntentLaunchRouter()

    private(set) var pendingURL: URL?

    private init() {}

    func queue(_ url: URL) {
        pendingURL = url
    }

    func consumePendingURL() -> URL? {
        defer { pendingURL = nil }
        return pendingURL
    }
}
