import Foundation

enum RuntimeBootstrap {
    static func clock(for configuration: AppBootstrapConfiguration) -> any AmbitionsClock {
        AmbitionsClockFactory.clock(for: configuration.sessionSource)
    }

    @MainActor
    static func makeRuntime(
        repositories: AppRepositories,
        clock: any AmbitionsClock,
        notificationService: any NotificationServicing,
        calendarRemindersService: any CalendarRemindersServicing,
        scheduleStoreFileURL: URL
    ) -> AmbitionsRuntime {
        AmbitionsRuntimeFactory.make(
            repositories: repositories,
            clock: clock,
            notificationService: notificationService,
            calendarRemindersService: calendarRemindersService,
            scheduleStoreFileURL: scheduleStoreFileURL,
            publicReferenceInspectionOverride: debugPublicReferenceInspectionOverride()
        )
    }

    private static func debugPublicReferenceInspectionOverride() -> PublicReferenceInspectionProjection? {
        #if DEBUG
        guard ProcessInfo.processInfo.environment["AMBITIONS_UI_PUBLIC_REFERENCE_FIXTURE"] == "1" else {
            return nil
        }
        return .previewCurrent
        #else
        return nil
        #endif
    }

    @MainActor
    static func todayService(
        for configuration: AppBootstrapConfiguration,
        runtime: AmbitionsRuntime
    ) -> any TodayServicing {
        previewTodayServiceOverride(for: configuration.sessionSource) ?? runtime.todayService
    }

    @MainActor
    static func timeService(runtime: AmbitionsRuntime) -> any TimeServicing {
        #if DEBUG
        debugProtectedPlacementReviewTimeServiceOverride() ?? runtime.timeService
        #else
        runtime.timeService
        #endif
    }

    private static func previewTodayServiceOverride(for source: AppSession.BootstrapSource) -> (any TodayServicing)? {
        #if DEBUG
        guard source == .preview,
              let scenarioName = ProcessInfo.processInfo.environment["AMBITIONS_PREVIEW_TODAY_SCENARIO"],
              let experience = PreviewTodayScenarios.named(scenarioName) else {
            return nil
        }
        return StubTodayService(experience: experience)
        #else
        _ = source
        return nil
        #endif
    }

    #if DEBUG
    private static func debugProtectedPlacementReviewTimeServiceOverride() -> (any TimeServicing)? {
        guard ProcessInfo.processInfo.environment["AMBITIONS_UI_PROTECTED_PLACEMENT_REVIEW"] == "1" else {
            return nil
        }

        return StubTimeService(
            timeState: PreviewTimeScenarios.protectedPlacementReviewSeeded,
            weeklyReviewState: PreviewTimeScenarios.weeklyReview
        )
    }
    #endif
}
import AmbitionsTimeFoundation
