import Foundation
import UserNotifications

protocol NotificationServicing: Sendable {
    func currentAuthorizationState() async -> NotificationAuthorizationState
    func currentRequestLifecycleState(identifier: String) async -> LocalNotificationRequestLifecycleState
    func registerCategories() async
    func requestAuthorizationOptIn() async -> Bool
    func refreshSchedule(now: Date) async
}

extension NotificationServicing {
    func currentRequestLifecycleState(identifier: String) async -> LocalNotificationRequestLifecycleState {
        _ = identifier
        return .unavailable
    }
}

enum NotificationAuthorizationState: Sendable, Equatable {
    case notDetermined
    case denied
    case authorized
    case provisional
    case ephemeral
}

enum LocalNotificationRequestLifecycleState: Sendable, Equatable {
    case pending
    case delivered
    case cancelled
    case unavailable
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
    func currentRequestLifecycleState(identifier: String) async -> LocalNotificationRequestLifecycleState
    func requestAuthorization() async throws -> Bool
    func setCategories(_ categories: [LocalNotificationCategoryDescriptor]) async
    func replacePendingRequest(_ request: LocalNotificationScheduleRequest?) async throws
}

protocol ExternalSurfaceSnapshotReading: Sendable {
    func loadSnapshot() async throws -> ExternalSurfaceSnapshot?
}

actor LocalNotificationFoundation: NotificationServicing {
    private let centerClient: any LocalNotificationCenterClient
    private let snapshotReader: any ExternalSurfaceSnapshotReading
    private let planner: NextStepLocalNotificationPlanner
    private let liveActivityService: any NextStepLiveActivityServicing
    private let sideEffectLedger: (any SideEffectLedgerRepository)?

    init(
        centerClient: any LocalNotificationCenterClient = UNUserNotificationCenterClient(),
        snapshotReader: any ExternalSurfaceSnapshotReading = FileExternalSurfaceSnapshotReader(),
        planner: NextStepLocalNotificationPlanner = NextStepLocalNotificationPlanner(),
        liveActivityService: any NextStepLiveActivityServicing = NextStepLiveActivityService(),
        sideEffectLedger: (any SideEffectLedgerRepository)? = nil
    ) {
        self.centerClient = centerClient
        self.snapshotReader = snapshotReader
        self.planner = planner
        self.liveActivityService = liveActivityService
        self.sideEffectLedger = sideEffectLedger
    }

    func currentAuthorizationState() async -> NotificationAuthorizationState {
        await centerClient.currentAuthorizationState()
    }

    func currentRequestLifecycleState(identifier: String) async -> LocalNotificationRequestLifecycleState {
        await centerClient.currentRequestLifecycleState(identifier: identifier)
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
        guard state == .authorized || state == .provisional || state == .ephemeral else {
            await logNotificationSideEffect(outcome: .authorizationMissing, now: now)
            return
        }

        do {
            let snapshot = try await snapshotReader.loadSnapshot()
            let request = planner.makeRequest(snapshot: snapshot, now: now)
            try await centerClient.replacePendingRequest(request)
            await liveActivityService.refresh(from: snapshot, now: now)
            await logNotificationSideEffect(
                outcome: request == nil ? .cleared : .scheduled,
                now: now,
                request: request
            )
        } catch {
            try? await centerClient.replacePendingRequest(nil)
            await liveActivityService.refresh(from: nil, now: now)
            await logNotificationSideEffect(
                outcome: .refreshFailed,
                now: now
            )
        }
    }

    private func logNotificationSideEffect(
        outcome: NotificationSideEffectOutcome,
        now: Date,
        request: LocalNotificationScheduleRequest? = nil
    ) async {
        guard let sideEffectLedger else { return }

        let occurredAt = DomainTimestamp.string(from: now)
        let record = SideEffectLedgerRecord(
            id: "notification.\(outcome.rawValue).\(Int(now.timeIntervalSince1970))",
            effectKind: .notification,
            status: outcome.status,
            boundary: .localOnly,
            actionKind: .noOp,
            sourceDomain: .system,
            commandID: nil,
            occurredAt: occurredAt,
            localOnly: true,
            requiresConfirmation: outcome.requiresConfirmation,
            externalEffect: false,
            reasons: outcome.reasons(request: request),
            blockedFacts: outcome.blockedFacts,
            degradedFacts: outcome.degradedFacts
        )
        do {
            try await sideEffectLedger.append(record)
        } catch {}
    }

    private enum NotificationSideEffectOutcome: String {
        case authorizationMissing
        case scheduled
        case cleared
        case refreshFailed

        var status: SideEffectLedgerStatus {
            switch self {
            case .scheduled, .cleared:
                .recordedLocalOnly
            case .authorizationMissing:
                .blocked
            case .refreshFailed:
                .failedSafely
            }
        }

        var requiresConfirmation: Bool {
            self == .authorizationMissing
        }

        func reasons(request: LocalNotificationScheduleRequest?) -> [SafeAutomationPolicyReason] {
            guard self == .scheduled || self == .cleared else {
                return self == .authorizationMissing ? [] : [.noChangeNeeded]
            }

            if request == nil {
                return [.noChangeNeeded]
            }
            return []
        }

        var blockedFacts: [String] {
            switch self {
            case .authorizationMissing:
                ["Notification authorization is required to refresh local reminders."]
            default:
                []
            }
        }

        var degradedFacts: [String] {
            switch self {
            case .refreshFailed:
                ["Notification snapshot could not be loaded; no schedule refresh was applied."]
            default:
                []
            }
        }
    }

    static func defaultCategories() -> [LocalNotificationCategoryDescriptor] {
        [
            LocalNotificationCategoryDescriptor(
                identifier: AppNotificationConstants.nextStepCategoryID,
                actions: [
                    LocalNotificationActionDescriptor(
                        identifier: AppNotificationConstants.openActionID,
                        title: "Open Today",
                        opensApp: true
                    ),
                    LocalNotificationActionDescriptor(
                        identifier: AppNotificationConstants.snoozeActionID,
                        title: "Not now",
                        opensApp: false
                    ),
                    LocalNotificationActionDescriptor(
                        identifier: AppNotificationConstants.completeActionID,
                        title: "Close the loop",
                        opensApp: true
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
        userInfo["origin"] = ExternalSurfaceOrigin.notification.rawValue
        userInfo["continuity"] = snapshot?.continuity.syncHealth.state.rawValue ?? ExternalSurfaceSyncHealthState.localFirst.rawValue
        userInfo["lease"] = snapshot?.continuity.lease.status.rawValue ?? ExternalSurfaceLeaseStatus.current.rawValue

        return LocalNotificationScheduleRequest(
            identifier: AppNotificationConstants.nextStepRequestID,
            title: title(for: snapshot),
            body: body(for: snapshot),
            categoryIdentifier: AppNotificationConstants.nextStepCategoryID,
            userInfo: userInfo,
            timeInterval: scheduleInterval(for: next.display.urgency)
        )
    }

    private func title(for snapshot: ExternalSurfaceSnapshot?) -> String {
        guard let ritualCue = snapshot?.nowState?.ritualCue else { return "Next step ready" }
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

    private func body(for snapshot: ExternalSurfaceSnapshot?) -> String {
        _ = snapshot?.ambientState
        _ = snapshot?.continuity
        guard let ritualCue = snapshot?.nowState?.ritualCue else {
            return "Details stay private until you open Ambitions."
        }
        switch ritualCue.kind {
        case .morningSetup:
            return "One next step is ready. Details stay private until you open Ambitions."
        case .middayReset:
            return ritualCue.progressState == .needsReset
                ? "A smaller next step is ready. Details stay private until you open Ambitions."
                : "Your next step is still available. Details stay private until you open Ambitions."
        case .eveningClose:
            return "Close the loop from Today. Details stay private until you open Ambitions."
        case .weeklyReset:
            return "Review the week from Today. Details stay private until you open Ambitions."
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
    private var trackedLifecycleStateByID: [String: LocalNotificationRequestLifecycleState] = [:]

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

    func currentRequestLifecycleState(identifier: String) async -> LocalNotificationRequestLifecycleState {
        let pendingIDs = await pendingRequestIdentifiers()
        if pendingIDs.contains(identifier) {
            trackedLifecycleStateByID[identifier] = .pending
            return .pending
        }

        let deliveredIDs = await deliveredRequestIdentifiers()
        if deliveredIDs.contains(identifier) {
            trackedLifecycleStateByID[identifier] = .delivered
            return .delivered
        }

        if let trackedState = trackedLifecycleStateByID[identifier], trackedState != .unavailable {
            trackedLifecycleStateByID[identifier] = .cancelled
            return .cancelled
        }

        return .unavailable
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

    func replacePendingRequest(_ request: LocalNotificationScheduleRequest?) async throws {
        let identifier = request?.identifier ?? AppNotificationConstants.nextStepRequestID
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        center.removeDeliveredNotifications(withIdentifiers: [identifier])
        guard let request else {
            trackedLifecycleStateByID[identifier] = .cancelled
            return
        }

        let content = UNMutableNotificationContent()
        content.title = request.title
        content.body = request.body
        content.sound = .default
        content.categoryIdentifier = request.categoryIdentifier
        content.userInfo = request.userInfo

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(60, request.timeInterval), repeats: false)
        let unRequest = UNNotificationRequest(identifier: request.identifier, content: content, trigger: trigger)
        try await add(unRequest)
        trackedLifecycleStateByID[request.identifier] = .pending
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

    private func pendingRequestIdentifiers() async -> Set<String> {
        await withCheckedContinuation { continuation in
            center.getPendingNotificationRequests { requests in
                continuation.resume(returning: Set(requests.map(\.identifier)))
            }
        }
    }

    private func deliveredRequestIdentifiers() async -> Set<String> {
        await withCheckedContinuation { continuation in
            center.getDeliveredNotifications { notifications in
                continuation.resume(returning: Set(notifications.map(\.request.identifier)))
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
    func currentRequestLifecycleState(identifier: String) async -> LocalNotificationRequestLifecycleState {
        _ = identifier
        return .unavailable
    }
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

struct NotificationSchedulingGoalsService: GoalsServicing, GoalCreationPreparing {
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

    func prepareGoalCreation(_ request: CreateGoalRequest, now: Date) async throws -> PreparedGoalCreation {
        guard let base = base as? any GoalCreationPreparing else {
            throw GoalsFeatureError.notActionable
        }
        return try await base.prepareGoalCreation(request, now: now)
    }

    func didCommitPreparedGoalCreation(now: Date) async {
        if let base = base as? any GoalCreationPreparing {
            await base.didCommitPreparedGoalCreation(now: now)
        }
        await notificationService.refreshSchedule(now: now)
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
