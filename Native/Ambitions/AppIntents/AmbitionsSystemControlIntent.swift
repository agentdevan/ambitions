import AppIntents
import Foundation

enum AmbitionsSystemControlShortcut: String, CaseIterable, AppEnum {
    case startNow = "start_now"
    case capture
    case stillCounts = "still_counts"
    case addProof = "add_proof"
    case openCurrentStep = "open_current_step"

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "System Control"
    static var typeDisplayName: LocalizedStringResource = "System Control"

    static var caseDisplayRepresentations: [AmbitionsSystemControlShortcut: DisplayRepresentation] {
        [
            .startNow: DisplayRepresentation(title: "Start now"),
            .capture: DisplayRepresentation(title: "Capture"),
            .stillCounts: DisplayRepresentation(title: "Still counts"),
            .addProof: DisplayRepresentation(title: "Add proof"),
            .openCurrentStep: DisplayRepresentation(title: "Open current step"),
        ]
    }

    var contractID: ExternalSurfaceControlID {
        switch self {
        case .startNow:
            return .startNow
        case .capture:
            return .capture
        case .stillCounts:
            return .stillCounts
        case .addProof:
            return .addProof
        case .openCurrentStep:
            return .openCurrentStep
        }
    }

    var contract: ExternalSurfaceControlContract {
        ExternalSurfaceControlContract.contract(for: contractID)
    }
}

struct OpenAmbitionsSystemControlIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Ambitions Control"
    static let description = IntentDescription("Open a privacy-safe Ambitions system control such as Start now, Capture, Still counts, Add proof, or Open current step.")
    static let openAppWhenRun = true

    @Parameter(title: "Control")
    var control: AmbitionsSystemControlShortcut

    init() {}

    init(control: AmbitionsSystemControlShortcut) {
        self.control = control
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let contract = control.contract
        guard let url = contract.deepLinkURL(origin: .appIntent) else {
            return .result(dialog: "Ambitions could not open that control.")
        }

        await MainActor.run {
            AppIntentLaunchRouter.shared.queue(url)
        }
        return .result(dialog: IntentDialog(stringLiteral: "Opening \(contract.title) in Ambitions."))
    }
}
