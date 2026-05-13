import Foundation

enum ExternalSurfaceControlID: String, CaseIterable, Codable, Sendable, Equatable, Hashable {
    case startNow = "start-now"
    case capture = "capture"
    case stillCounts = "still-counts"
    case addProof = "add-proof"
    case openCurrentStep = "open-current-step"
}

enum ExternalSurfaceControlAvailability: String, Codable, Sendable, Equatable, Hashable {
    case always
    case requiresCurrentStep = "requires-current-step"
    case requiresProofTarget = "requires-proof-target"
}

enum ExternalSurfaceControlExecutionMode: String, Codable, Sendable, Equatable, Hashable {
    case opensAppOnly = "opens-app-only"
    case queuesLocalCreation = "queues-local-creation"
    case requiresInAppConfirmation = "requires-in-app-confirmation"
}

struct ExternalSurfaceControlContract: Identifiable, Codable, Sendable, Equatable, Hashable {
    let id: ExternalSurfaceControlID
    let title: String
    let shortTitle: String
    let systemImageName: String
    let privacySummary: String
    let actionName: ExternalSurfaceActionName
    let payloadSurface: ExternalSurfacePayloadSurface
    let preferredTab: String?
    let fallbackTab: String
    let availability: ExternalSurfaceControlAvailability
    let executionMode: ExternalSurfaceControlExecutionMode
    let producesReceipt: Bool
    let requiresGoalID: Bool
    let requiresStepID: Bool

    init(
        id: ExternalSurfaceControlID,
        title: String,
        shortTitle: String,
        systemImageName: String,
        privacySummary: String,
        actionName: ExternalSurfaceActionName,
        payloadSurface: ExternalSurfacePayloadSurface,
        preferredTab: String? = nil,
        fallbackTab: String = "today",
        availability: ExternalSurfaceControlAvailability,
        executionMode: ExternalSurfaceControlExecutionMode,
        producesReceipt: Bool,
        requiresGoalID: Bool = false,
        requiresStepID: Bool = false
    ) {
        self.id = id
        self.title = title
        self.shortTitle = shortTitle
        self.systemImageName = systemImageName
        self.privacySummary = privacySummary
        self.actionName = actionName
        self.payloadSurface = payloadSurface
        self.preferredTab = preferredTab
        self.fallbackTab = fallbackTab
        self.availability = availability
        self.executionMode = executionMode
        self.producesReceipt = producesReceipt
        self.requiresGoalID = requiresGoalID
        self.requiresStepID = requiresStepID
    }

    var isSafeForSystemControlSurface: Bool {
        switch executionMode {
        case .opensAppOnly:
            return true
        case .queuesLocalCreation, .requiresInAppConfirmation:
            return producesReceipt
        }
    }

    func commandPayload(reference: ExternalSurfaceActionReference? = nil) -> [String: String] {
        ExternalSurfaceActionPayload.commandPayload(
            action: actionName,
            surface: payloadSurface,
            goalID: reference?.goalID,
            stepID: reference?.stepID,
            tab: preferredTab
        )
    }

    func deepLinkURL(
        reference: ExternalSurfaceActionReference? = nil,
        origin: ExternalSurfaceOrigin = .widget
    ) -> URL? {
        ExternalSurfaceActionPayload.safeDeepLinkURL(
            surface: payloadSurface,
            goalID: reference?.goalID,
            tab: preferredTab,
            origin: origin,
            fallbackTab: fallbackTab
        )
    }
}

extension ExternalSurfaceControlContract {
    static let systemControlSet: [ExternalSurfaceControlContract] = [
        ExternalSurfaceControlContract(
            id: .startNow,
            title: "Start now",
            shortTitle: "Start",
            systemImageName: "play.circle",
            privacySummary: "Opens Ambitions to the recommended step without exposing private step details in the system surface.",
            actionName: .openToday,
            payloadSurface: .tab,
            preferredTab: "today",
            availability: .always,
            executionMode: .opensAppOnly,
            producesReceipt: false
        ),
        ExternalSurfaceControlContract(
            id: .capture,
            title: "Capture",
            shortTitle: "Capture",
            systemImageName: "square.and.pencil",
            privacySummary: "Opens local Capture so the user can save text intentionally; no hidden capture is created from the control alone.",
            actionName: .openCapturesInbox,
            payloadSurface: .captureInbox,
            availability: .always,
            executionMode: .opensAppOnly,
            producesReceipt: false
        ),
        ExternalSurfaceControlContract(
            id: .stillCounts,
            title: "Still counts",
            shortTitle: "Counts",
            systemImageName: "checkmark.seal",
            privacySummary: "Routes to in-app closure confirmation so progress can be counted with a receipt instead of silently mutating a step.",
            actionName: .complete,
            payloadSurface: .goalDetail,
            availability: .requiresCurrentStep,
            executionMode: .requiresInAppConfirmation,
            producesReceipt: true,
            requiresGoalID: true,
            requiresStepID: true
        ),
        ExternalSurfaceControlContract(
            id: .addProof,
            title: "Add proof",
            shortTitle: "Proof",
            systemImageName: "doc.badge.plus",
            privacySummary: "Opens the proof target in Ambitions; proof content remains user-confirmed in app before it becomes durable.",
            actionName: .open,
            payloadSurface: .goalDetail,
            availability: .requiresProofTarget,
            executionMode: .requiresInAppConfirmation,
            producesReceipt: true,
            requiresGoalID: true
        ),
        ExternalSurfaceControlContract(
            id: .openCurrentStep,
            title: "Open current step",
            shortTitle: "Step",
            systemImageName: "scope",
            privacySummary: "Opens the current step in Ambitions without showing sensitive goal or step text in the system surface.",
            actionName: .openToday,
            payloadSurface: .goalDetail,
            availability: .requiresCurrentStep,
            executionMode: .opensAppOnly,
            producesReceipt: false,
            requiresGoalID: true,
            requiresStepID: true
        )
    ]

    static func contract(for id: ExternalSurfaceControlID) -> ExternalSurfaceControlContract {
        systemControlSet.first { $0.id == id } ?? systemControlSet[0]
    }
}
