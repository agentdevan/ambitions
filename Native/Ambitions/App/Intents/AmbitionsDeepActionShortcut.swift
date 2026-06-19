import AppIntents
import Foundation

enum AmbitionsDeepActionShortcut: String, CaseIterable, AppEnum {
    case capture
    case goalDraft = "goal_draft"
    case openCurrentStep = "open_current_step"
    case startCurrentStep = "start_current_step"
    case guardedCloseStep = "guarded_close_step"
    case showReceipt = "show_receipt"
    case inspectLocalKnowledge = "inspect_local_knowledge"

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Ambitions Action"
    static let typeDisplayName: LocalizedStringResource = "Ambitions Action"

    static var caseDisplayRepresentations: [AmbitionsDeepActionShortcut: DisplayRepresentation] {
        [
            .capture: DisplayRepresentation(title: "Capture"),
            .goalDraft: DisplayRepresentation(title: "Draft goal"),
            .openCurrentStep: DisplayRepresentation(title: "Open step"),
            .startCurrentStep: DisplayRepresentation(title: "Start now"),
            .guardedCloseStep: DisplayRepresentation(title: "Close step"),
            .showReceipt: DisplayRepresentation(title: "Show receipt"),
            .inspectLocalKnowledge: DisplayRepresentation(title: "What Ambitions Knows"),
        ]
    }
}

struct AmbitionsDeepActionDescriptor: Sendable, Equatable {
    let action: AmbitionsDeepActionShortcut
    let commandKind: AmbitionsCommandKind
    let routeURL: URL?
    let executionPosture: AmbitionsShortcutExecutionPosture
    let producesReceipt: Bool
    let privacySummary: String

    var requiresConfirmation: Bool {
        executionPosture == .requiresInAppConfirmation
    }
}

extension AmbitionsDeepActionShortcut {
    func descriptor(
        goalID: String? = nil,
        stepID: String? = nil,
        receiptID: String? = nil,
        knowledgeQuery: String? = nil
    ) -> AmbitionsDeepActionDescriptor {
        let contract = ExternalSurfaceContractRegistry.contract(for: .appIntents)
        return AmbitionsDeepActionDescriptor(
            action: self,
            commandKind: commandKind,
            routeURL: routeURL(goalID: goalID, stepID: stepID, receiptID: receiptID, knowledgeQuery: knowledgeQuery),
            executionPosture: executionPosture,
            producesReceipt: producesReceipt,
            privacySummary: contract.hidesSensitiveDetailsByDefault
                ? ExternalSurfacePrivacySnapshotPolicy.safeDefault.sensitiveDetailLabel
                : "Shortcut details follow your Ambitions privacy settings."
        )
    }

    private var commandKind: AmbitionsCommandKind {
        switch self {
        case .capture:
            return .quickCapture
        case .goalDraft:
            return .createGoal
        case .openCurrentStep, .showReceipt, .inspectLocalKnowledge:
            return .openDestination
        case .startCurrentStep:
            return .startStepSession
        case .guardedCloseStep:
            return .completeAction
        }
    }

    private var executionPosture: AmbitionsShortcutExecutionPosture {
        switch self {
        case .capture, .goalDraft:
            return .queuesLocalCapture
        case .guardedCloseStep:
            return .requiresInAppConfirmation
        case .openCurrentStep, .startCurrentStep, .showReceipt, .inspectLocalKnowledge:
            return .opensAppOnly
        }
    }

    private var producesReceipt: Bool {
        switch self {
        case .capture, .goalDraft, .guardedCloseStep:
            return true
        case .openCurrentStep, .startCurrentStep, .showReceipt, .inspectLocalKnowledge:
            return false
        }
    }

    private func routeURL(
        goalID: String?,
        stepID: String?,
        receiptID: String?,
        knowledgeQuery: String?
    ) -> URL? {
        switch self {
        case .capture:
            return Self.url(for: .openCaptureComposer)
        case .goalDraft:
            return Self.url(for: .presentOverlay(.commandSheet(entrySource: .appIntent)))
        case .openCurrentStep, .guardedCloseStep:
            return Self.stepRouteURL(goalID: goalID, stepID: stepID) ?? Self.url(for: .openToday(.focus))
        case .startCurrentStep:
            return Self.url(for: .openToday(.focus))
        case .showReceipt:
            return Self.url(
                for: .presentOverlay(.memoryLens(
                    entrySource: .appIntent,
                    query: receiptID.map { "receipt:\($0)" } ?? ""
                ))
            )
        case .inspectLocalKnowledge:
            return Self.url(
                for: .presentOverlay(.memoryLens(
                    entrySource: .appIntent,
                    query: knowledgeQuery ?? ""
                ))
            )
        }
    }

    private static func stepRouteURL(goalID: String?, stepID: String?) -> URL? {
        guard let goalID = nonEmpty(goalID),
              let url = url(for: .openGoalDetail(goalID: goalID)),
              var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }
        var queryItems = components.queryItems ?? []
        if let stepID = nonEmpty(stepID) {
            queryItems.append(URLQueryItem(name: "stepID", value: stepID))
        }
        components.queryItems = queryItems
        return components.url
    }

    private static func url(for appRoute: AppExternalRoute) -> URL? {
        guard var components = AppExternalRouteTranslator().deepLinkURL(for: appRoute).flatMap({
            URLComponents(url: $0, resolvingAgainstBaseURL: false)
        }) else {
            return nil
        }
        var queryItems = components.queryItems ?? []
        if queryItems.contains(where: { $0.name == "origin" }) == false {
            queryItems.append(URLQueryItem(name: "origin", value: ExternalSurfaceOrigin.appIntent.rawValue))
        }
        components.queryItems = queryItems
        return components.url
    }

    private static func nonEmpty(_ value: String?) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed?.isEmpty == false ? trimmed : nil
    }
}
