import AppIntents
import Foundation

struct OpenAmbitionsCurrentStepIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Ambitions Step"
    static let description = IntentDescription("Open a current step in Ambitions without exposing step text in Shortcuts.")
    static let openAppWhenRun = true

    @Parameter(title: "Goal ID")
    var goalID: String

    @Parameter(title: "Step ID")
    var stepID: String

    init() {}

    init(goalID: String, stepID: String) {
        self.goalID = goalID
        self.stepID = stepID
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        return await Self.queue(
            .openCurrentStep,
            goalID: goalID,
            stepID: stepID,
            dialog: "Opening the step in Ambitions."
        )
    }
}

struct StartAmbitionsCurrentStepIntent: AppIntent {
    static let title: LocalizedStringResource = "Start Ambitions Step"
    static let description = IntentDescription("Open Ambitions to Start now for the current recommended step.")
    static let openAppWhenRun = true

    @Parameter(title: "Goal ID")
    var goalID: String

    @Parameter(title: "Step ID")
    var stepID: String

    init() {}

    init(goalID: String, stepID: String) {
        self.goalID = goalID
        self.stepID = stepID
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        return await Self.queue(
            .startCurrentStep,
            goalID: goalID,
            stepID: stepID,
            dialog: "Opening Start now in Ambitions."
        )
    }
}

struct GuardedCloseAmbitionsStepIntent: AppIntent {
    static let title: LocalizedStringResource = "Close Ambitions Step"
    static let description = IntentDescription("Open Ambitions to confirm step closure and record a receipt.")
    static let openAppWhenRun = true

    @Parameter(title: "Goal ID")
    var goalID: String

    @Parameter(title: "Step ID")
    var stepID: String

    init() {}

    init(goalID: String, stepID: String) {
        self.goalID = goalID
        self.stepID = stepID
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        return await Self.queue(
            .guardedCloseStep,
            goalID: goalID,
            stepID: stepID,
            dialog: "Open Ambitions to confirm closure and save the receipt."
        )
    }
}

struct ShowAmbitionsReceiptIntent: AppIntent {
    static let title: LocalizedStringResource = "Show Ambitions Receipt"
    static let description = IntentDescription("Open the local receipt inspection surface in Ambitions.")
    static let openAppWhenRun = true

    @Parameter(title: "Receipt ID")
    var receiptID: String

    init() {}

    init(receiptID: String) {
        self.receiptID = receiptID
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        return await Self.queue(
            .showReceipt,
            receiptID: receiptID,
            dialog: "Opening the receipt in Ambitions."
        )
    }
}

struct InspectAmbitionsLocalKnowledgeIntent: AppIntent {
    static let title: LocalizedStringResource = "Inspect What Ambitions Knows"
    static let description = IntentDescription("Open What Ambitions Knows for bounded local inspection.")
    static let openAppWhenRun = true

    @Parameter(title: "Topic")
    var topic: String

    init() {}

    init(topic: String) {
        self.topic = topic
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        return await Self.queue(
            .inspectLocalKnowledge,
            knowledgeQuery: topic,
            dialog: "Opening What Ambitions Knows."
        )
    }
}

private extension AppIntent {
    @MainActor
    static func queue(
        _ action: AmbitionsDeepActionShortcut,
        goalID: String? = nil,
        stepID: String? = nil,
        receiptID: String? = nil,
        knowledgeQuery: String? = nil,
        dialog: String
    ) -> some IntentResult & ProvidesDialog {
        guard let url = action.descriptor(
            goalID: goalID,
            stepID: stepID,
            receiptID: receiptID,
            knowledgeQuery: knowledgeQuery
        ).routeURL else {
            return .result(dialog: "Ambitions could not open that action.")
        }

        AppIntentLaunchRouter.shared.queue(url)
        return .result(dialog: IntentDialog(stringLiteral: dialog))
    }
}
