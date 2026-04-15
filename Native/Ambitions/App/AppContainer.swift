import AmbitionsDesignSystem
import Foundation
import Observation

@MainActor
@Observable
final class AppContainer {
    let session: AppSession
    var appearancePreference: AppAppearancePreference
    let navigation: AppNavigationModel
    let todayService: any TodayServicing
    let goalsService: any GoalsServicing
    let habitsService: any HabitsServicing
    let insightsService: any InsightsServicing
    let profileService: any ProfileServicing
    let actionRouter: any AppActionRouting
    let externalRouter: any AppExternalRouting

    init(
        session: AppSession,
        appearancePreference: AppAppearancePreference,
        navigation: AppNavigationModel,
        todayService: any TodayServicing,
        goalsService: any GoalsServicing,
        habitsService: any HabitsServicing,
        insightsService: any InsightsServicing,
        profileService: any ProfileServicing,
        actionRouter: any AppActionRouting,
        externalRouter: any AppExternalRouting
    ) {
        self.session = session
        self.appearancePreference = appearancePreference
        self.navigation = navigation
        self.todayService = todayService
        self.goalsService = goalsService
        self.habitsService = habitsService
        self.insightsService = insightsService
        self.profileService = profileService
        self.actionRouter = actionRouter
        self.externalRouter = externalRouter
    }
}
