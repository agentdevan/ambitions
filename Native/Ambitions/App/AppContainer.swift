import AmbitionsDesignSystem
import Foundation

final class AppContainer {
    let session: AppSession
    let theme: AmbitionTheme
    let navigation: AppNavigationModel
    let todayService: any TodayServicing
    let goalsService: any GoalsServicing
    let habitsService: any HabitsServicing
    let insightsService: any InsightsServicing
    let profileService: any ProfileServicing
    let actionRouter: any AppActionRouting

    init(
        session: AppSession,
        theme: AmbitionTheme,
        navigation: AppNavigationModel,
        todayService: any TodayServicing,
        goalsService: any GoalsServicing,
        habitsService: any HabitsServicing,
        insightsService: any InsightsServicing,
        profileService: any ProfileServicing,
        actionRouter: any AppActionRouting
    ) {
        self.session = session
        self.theme = theme
        self.navigation = navigation
        self.todayService = todayService
        self.goalsService = goalsService
        self.habitsService = habitsService
        self.insightsService = insightsService
        self.profileService = profileService
        self.actionRouter = actionRouter
    }
}
