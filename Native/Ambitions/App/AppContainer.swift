import AmbitionsDesignSystem
import Foundation
import Observation

@MainActor
@Observable
final class AppContainer {
    let session: AppSession
    let runtime: AmbitionsRuntime
    var appearancePreference: AppAppearancePreference
    let navigation: AppNavigationModel
    let todayService: any TodayServicing
    let captureService: any CaptureServicing
    let goalsService: any GoalsServicing
    let habitsService: any HabitsServicing
    let insightsService: any InsightsServicing
    let profileService: any ProfileServicing
    let notificationService: any NotificationServicing
    let calendarRemindersService: any CalendarRemindersServicing
    let actionRouter: any AppActionRouting
    let externalRouter: any AppExternalRouting
    let externalActionService: any ExternalActionCommandExecuting

    init(
        session: AppSession,
        runtime: AmbitionsRuntime,
        appearancePreference: AppAppearancePreference,
        navigation: AppNavigationModel,
        todayService: any TodayServicing,
        captureService: any CaptureServicing,
        goalsService: any GoalsServicing,
        habitsService: any HabitsServicing,
        insightsService: any InsightsServicing,
        profileService: any ProfileServicing,
        notificationService: any NotificationServicing,
        calendarRemindersService: any CalendarRemindersServicing,
        actionRouter: any AppActionRouting,
        externalRouter: any AppExternalRouting,
        externalActionService: any ExternalActionCommandExecuting
    ) {
        self.session = session
        self.runtime = runtime
        self.appearancePreference = appearancePreference
        self.navigation = navigation
        self.todayService = todayService
        self.captureService = captureService
        self.goalsService = goalsService
        self.habitsService = habitsService
        self.insightsService = insightsService
        self.profileService = profileService
        self.notificationService = notificationService
        self.calendarRemindersService = calendarRemindersService
        self.actionRouter = actionRouter
        self.externalRouter = externalRouter
        self.externalActionService = externalActionService
    }
}
