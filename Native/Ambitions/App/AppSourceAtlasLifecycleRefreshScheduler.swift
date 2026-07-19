import Foundation

@MainActor
final class AppSourceAtlasLifecycleRefreshScheduler {
    private(set) var latestInput: SourceAtlasPublicPackLifecycleRefreshInput?
    private(set) var latestResolution: SourceAtlasPublicPackLifecycleRefreshResolution?
    private(set) var scheduledRefreshCount = 0
    private(set) var cancelledRefreshCount = 0

    private var refreshGeneration = 0
    private var refreshTask: Task<Void, Never>?

    var hasInFlightRefresh: Bool {
        refreshTask != nil
    }

    deinit {
        refreshTask?.cancel()
    }

    func scheduleRefresh(
        using service: any SourceAtlasPublicPackLifecycleRefreshing,
        mode: SourceAtlasPublicPackLifecycleRefreshMode,
        networkReachability: SourceAtlasNetworkReachability,
        checkedAt: Date
    ) {
        scheduleRefresh(
            SourceAtlasPublicPackLifecycleRefreshInput(
                mode: mode,
                networkReachability: networkReachability,
                checkedAt: checkedAt
            ),
            using: service
        )
    }

    func scheduleRefresh(
        _ input: SourceAtlasPublicPackLifecycleRefreshInput,
        using service: any SourceAtlasPublicPackLifecycleRefreshing
    ) {
        cancelCurrentRefreshIfNeeded()
        refreshGeneration += 1
        scheduledRefreshCount += 1
        latestInput = input

        let generation = refreshGeneration
        refreshTask = Task { @MainActor [weak self, service, input] in
            let resolution = await service.refreshPublicSourceAtlasPacks(input)
            guard Task.isCancelled == false,
                  let self,
                  self.refreshGeneration == generation
            else {
                return
            }
            self.latestResolution = resolution
            self.refreshTask = nil
        }
    }

    func cancelInFlightRefresh() {
        cancelCurrentRefreshIfNeeded()
        refreshGeneration += 1
    }

    private func cancelCurrentRefreshIfNeeded() {
        guard let refreshTask else { return }
        refreshTask.cancel()
        self.refreshTask = nil
        cancelledRefreshCount += 1
    }
}
