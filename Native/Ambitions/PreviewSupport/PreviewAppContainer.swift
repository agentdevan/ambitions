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
            todayService: StubTodayService(experience: todayExperience),
            captureService: StubCaptureService(captures: fixtures.captures),
            goalsService: StubGoalsService(),
            habitsService: StubHabitsService(dashboard: habitsDashboard),
            insightsService: StubInsightsService(fixtures: fixtures),
            profileService: StubProfileService(fixtures: fixtures),
            notificationService: StubNotificationService(),
            calendarRemindersService: StubCalendarRemindersService(),
            actionRouter: DefaultAppActionRouter(navigation: navigation),
            externalRouter: externalRouter
        )
    }
}
