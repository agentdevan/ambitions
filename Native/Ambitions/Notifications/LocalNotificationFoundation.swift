import Foundation
import UserNotifications

protocol NotificationServicing: Sendable {
    func currentAuthorizationState() async -> NotificationAuthorizationState
    func registerCategories() async
    func requestAuthorizationOptIn() async -> Bool
    func refreshSchedule(now: Date) async
}

enum NotificationAuthorizationState: Sendable, Equatable {
    case notDetermined
    case denied
    case authorized
    case provisional
    case ephemeral
}

struct LocalNotificationActionDescriptor: Sendable, Equatable {
    let identifier: String
    let title: String
    let opensApp: Bool
}

struct LocalNotificationCategoryDescriptor: Sendable, Equatable {
    let identifier: String
    let actions: [LocalNotificationActionDescriptor]
}

struct LocalNotificationScheduleRequest: Sendable, Equatable {
    let identifier: String
    let title: String
    let body: String
    let categoryIdentifier: String
    let userInfo: [String: String]
    let timeInterval: TimeInterval
}

protocol LocalNotificationCenterClient: Sendable {
    func currentAuthorizationState() async -> NotificationAuthorizationState
    func requestAuthorization() async throws -> Bool
    func setCategories(_ categories: [LocalNotificationCategoryDescriptor]) async
    func replacePendingRequest(_ request: LocalNotificationScheduleRequest?) async
}

protocol ExternalSurfaceSnapshotReading: Sendable {
    func loadSnapshot() async throws -> ExternalSurfaceSnapshot?
}

actor LocalNotificationFoundation: NotificationServicing {
    private let centerClient: any LocalNotificationCenterClient
    private let snapshotReader: any ExternalSurfaceSnapshotReading
    private let planner: NextStepLocalNotificationPlanner
    private let liveActivityService: any NextStepLiveActivityServicing

    init(
        centerClient: any LocalNotificationCenterClient = UNUserNotificationCenterClient(),
        snapshotReader: any ExternalSurfaceSnapshotReading = FileExternalSurfaceSnapshotReader(),
        planner: NextStepLocalNotificationPlanner = NextStepLocalNotificationPlanner(),
        liveActivityService: any NextStepLiveActivityServicing = NextStepLiveActivityService()
    ) {
        self.centerClient = centerClient
        self.snapshotReader = snapshotReader
        self.planner = planner
        self.liveActivityService = liveActivityService
    }

    func currentAuthorizationState() async -> NotificationAuthorizationState {
        await centerClient.currentAuthorizationState()
    }

    func registerCategories() async {
        await centerClient.setCategories(Self.defaultCategories())
    }

    func requestAuthorizationOptIn() async -> Bool {
        await registerCategories()
        do {
            return try await centerClient.requestAuthorization()
        } catch {
            return false
        }
    }

    func refreshSchedule(now: Date) async {
        let state = await centerClient.currentAuthorizationState()
        guard state == .authorized || state == .provisional || state == .ephemeral else { return }

        do {
            let snapshot = try await snapshotReader.loadSnapshot()
            let request = planner.makeRequest(snapshot: snapshot, now: now)
            await centerClient.replacePendingRequest(request)
            await liveActivityService.refresh(from: snapshot, now: now)
        } catch {
            await centerClient.replacePendingRequest(nil)
            await liveActivityService.refresh(from: nil, now: now)
        }
    }

    static func defaultCategories() -> [LocalNotificationCategoryDescriptor] {
        [
            LocalNotificationCategoryDescriptor(
                identifier: AppNotificationConstants.nextStepCategoryID,
                actions: [
                    LocalNotificationActionDescriptor(
                        identifier: AppNotificationConstants.openActionID,
                        title: "Open",
                        opensApp: true
                    ),
                    LocalNotificationActionDescriptor(
                        identifier: AppNotificationConstants.snoozeActionID,
                        title: "Snooze",
                        opensApp: false
                    ),
                    LocalNotificationActionDescriptor(
                        identifier: AppNotificationConstants.completeActionID,
                        title: "Complete",
                        opensApp: false
                    ),
                ]
            )
        ]
    }
}

enum AppNotificationConstants {
    static let nextStepCategoryID = "ambitions.next-step"
    static let nextStepRequestID = "ambitions.next-step.request"
    static let openActionID = "ambitions.open"
    static let snoozeActionID = "ambitions.snooze"
    static let completeActionID = "ambitions.complete"
}

struct NextStepLocalNotificationPlanner: Sendable {
    func makeRequest(snapshot: ExternalSurfaceSnapshot?, now: Date) -> LocalNotificationScheduleRequest? {
        _ = now
        guard let next = snapshot?.nextAction else { return nil }
        var userInfo = AppExternalRouteTranslator()
            .notificationPayload(for: .openGoalDetail(goalID: next.goalID), action: "open")
            .values
        userInfo["stepID"] = next.stepID

        return LocalNotificationScheduleRequest(
            identifier: AppNotificationConstants.nextStepRequestID,
            title: title(for: snapshot?.nowState?.ritualCue),
            body: body(for: snapshot?.nowState?.ritualCue),
            categoryIdentifier: AppNotificationConstants.nextStepCategoryID,
            userInfo: userInfo,
            timeInterval: scheduleInterval(for: next.display.urgency)
        )
    }

    private func title(for ritualCue: ExternalSurfaceRitualCue?) -> String {
        guard let ritualCue else { return "Ambitions reminder" }
        switch ritualCue.kind {
        case .morningSetup:
            return "Morning setup"
        case .middayReset:
            return "Midday reset"
        case .eveningClose:
            return "Evening close"
        case .weeklyReset:
            return "Weekly reset"
        }
    }

    private func body(for ritualCue: ExternalSurfaceRitualCue?) -> String {
        guard let ritualCue else { return "Your next step is ready." }
        switch ritualCue.kind {
        case .morningSetup:
            return "One next move is ready."
        case .middayReset:
            return ritualCue.progressState == .needsReset ? "A smaller next move is ready." : "Your next move is still available."
        case .eveningClose:
            return "Close the loop from Today."
        case .weeklyReset:
            return "Review the week from Today."
        }
    }

    private func scheduleInterval(for urgency: ExternalSurfaceUrgency) -> TimeInterval {
        switch urgency {
        case .overdue:
            return 60
        case .soon:
            return 5 * 60
        case .normal:
            return 30 * 60
        case .anytime:
            return 90 * 60
        }
    }
}

actor UNUserNotificationCenterClient: LocalNotificationCenterClient {
    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func currentAuthorizationState() async -> NotificationAuthorizationState {
        await withCheckedContinuation { continuation in
            center.getNotificationSettings { settings in
                let mapped: NotificationAuthorizationState
                switch settings.authorizationStatus {
                case .notDetermined:
                    mapped = .notDetermined
                case .denied:
                    mapped = .denied
                case .authorized:
                    mapped = .authorized
                case .provisional:
                    mapped = .provisional
                case .ephemeral:
                    mapped = .ephemeral
                @unknown default:
                    mapped = .denied
                }
                continuation.resume(returning: mapped)
            }
        }
    }

    func requestAuthorization() async throws -> Bool {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) in
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: granted)
                }
            }
        }
    }

    func setCategories(_ categories: [LocalNotificationCategoryDescriptor]) async {
        let mapped = Set(categories.map { category in
            UNNotificationCategory(
                identifier: category.identifier,
                actions: category.actions.map { action in
                    let options: UNNotificationActionOptions = action.opensApp ? [.foreground] : []
                    return UNNotificationAction(
                        identifier: action.identifier,
                        title: action.title,
                        options: options
                    )
                },
                intentIdentifiers: [],
                options: []
            )
        })
        center.setNotificationCategories(mapped)
    }

    func replacePendingRequest(_ request: LocalNotificationScheduleRequest?) async {
        center.removePendingNotificationRequests(withIdentifiers: [AppNotificationConstants.nextStepRequestID])
        center.removeDeliveredNotifications(withIdentifiers: [AppNotificationConstants.nextStepRequestID])
        guard let request else { return }

        let content = UNMutableNotificationContent()
        content.title = request.title
        content.body = request.body
        content.sound = .default
        content.categoryIdentifier = request.categoryIdentifier
        content.userInfo = request.userInfo

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(60, request.timeInterval), repeats: false)
        let unRequest = UNNotificationRequest(identifier: request.identifier, content: content, trigger: trigger)
        try? await add(unRequest)
    }

    private func add(_ request: UNNotificationRequest) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            center.add(request) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
}

actor FileExternalSurfaceSnapshotReader: ExternalSurfaceSnapshotReading {
    private let fileURL: URL

    init(fileURL: URL = SharedExternalSnapshotStore.snapshotFileURL()) {
        self.fileURL = fileURL
    }

    func loadSnapshot() async throws -> ExternalSurfaceSnapshot? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        let data = try Data(contentsOf: fileURL)
        return try PersistenceCoding.decode(ExternalSurfaceSnapshot.self, from: data)
    }
}

struct StubNotificationService: NotificationServicing {
    func currentAuthorizationState() async -> NotificationAuthorizationState { .notDetermined }
    func registerCategories() async {}
    func requestAuthorizationOptIn() async -> Bool { false }
    func refreshSchedule(now: Date) async { _ = now }
}

struct NotificationSchedulingTodayService: TodayServicing {
    let base: any TodayServicing
    let notificationService: any NotificationServicing

    func loadTodayExperience(userDisplayName: String, now: Date, entryContext: TodayEntryContext) async throws -> TodayExperience {
        try await base.loadTodayExperience(userDisplayName: userDisplayName, now: now, entryContext: entryContext)
    }

    func performAction(_ action: TodayInlineAction, now: Date) async throws -> TodayActionResponse {
        let response = try await base.performAction(action, now: now)
        await notificationService.refreshSchedule(now: now)
        return response
    }
}

struct NotificationSchedulingGoalsService: GoalsServicing {
    let base: any GoalsServicing
    let notificationService: any NotificationServicing

    func loadOverview() async throws -> GoalsOverview {
        try await base.loadOverview()
    }

    func loadDetail(target: GoalRouteTarget) async throws -> GoalDetailPresentation {
        try await base.loadDetail(target: target)
    }

    func previewCreateGoal(_ request: CreateGoalPreviewRequest, now: Date) async throws -> CreateGoalPreviewState {
        try await base.previewCreateGoal(request, now: now)
    }

    func createGoal(_ request: CreateGoalRequest, now: Date) async throws -> CreateGoalResponse {
        let response = try await base.createGoal(request, now: now)
        await notificationService.refreshSchedule(now: now)
        return response
    }

    func performAction(_ request: GoalDetailActionRequest, now: Date) async throws -> GoalDetailActionResponse {
        let response = try await base.performAction(request, now: now)
        await notificationService.refreshSchedule(now: now)
        return response
    }

    func submitClarificationAnswer(_ request: GoalClarificationAnswerRequest, now: Date) async throws -> GoalDetailActionResponse {
        let response = try await base.submitClarificationAnswer(request, now: now)
        await notificationService.refreshSchedule(now: now)
        return response
    }

    func submitExplainabilityCorrection(_ request: GoalExplainabilityCorrectionRequest, now: Date) async throws -> GoalDetailActionResponse {
        let response = try await base.submitExplainabilityCorrection(request, now: now)
        await notificationService.refreshSchedule(now: now)
        return response
    }
}
