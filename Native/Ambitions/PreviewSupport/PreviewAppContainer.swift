import AmbitionsDesignSystem
import Foundation

enum PreviewAppContainerFactory {
    @MainActor
    static var preview: AppContainer {
        preview(todayExperience: PreviewTodayScenarios.seeded, habitsDashboard: PreviewHabitsScenarios.seeded)
    }

    @MainActor
    static func preview(
        todayExperience: TodayExperience = PreviewTodayScenarios.seeded,
        habitsDashboard: HabitsDashboard = PreviewHabitsScenarios.seeded
    ) -> AppContainer {
        let fixtures = PreviewFixtures.default
        let navigation = AppNavigationModel(selectedTab: fixtures.preferences.preferredTab)
        let externalRouter = DefaultAppExternalRouter(navigation: navigation)
        let todayService = StubTodayService(experience: todayExperience)
        let captureService = StubCaptureService(captures: fixtures.captures)
        let goalsService = StubGoalsService()
        return AppContainer(
            session: AppSession(
                source: .preview,
                userDisplayName: fixtures.preferences.userDisplayName,
                initialTab: fixtures.preferences.preferredTab,
                appearancePreference: fixtures.preferences.appearancePreference,
                launchedAt: .now,
                startupNote: "Preview bootstrap uses isolated in-memory fixtures."
            ),
            appearancePreference: fixtures.preferences.appearancePreference,
            navigation: navigation,
            todayService: todayService,
            captureService: captureService,
            goalsService: goalsService,
            habitsService: StubHabitsService(dashboard: habitsDashboard),
            insightsService: StubInsightsService(fixtures: fixtures),
            profileService: StubProfileService(fixtures: fixtures),
            notificationService: StubNotificationService(),
            calendarRemindersService: StubCalendarRemindersService(),
            actionRouter: DefaultAppActionRouter(navigation: navigation),
            externalRouter: externalRouter,
            externalActionService: DefaultExternalActionCommandService(
                todayService: todayService,
                goalsService: goalsService,
                captureService: captureService,
                externalRouter: externalRouter
            )
        )
    }
}
