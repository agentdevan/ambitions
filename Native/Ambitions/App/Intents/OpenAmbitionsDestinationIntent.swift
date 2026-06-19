import AppIntents
import Foundation

struct OpenAmbitionsDestinationIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Ambitions"
    static let description = IntentDescription("Open Today, Goals, Time, You, global Capture, or another Ambitions route.")
    static let openAppWhenRun = true

    @Parameter(title: "Destination")
    var destination: AmbitionsAppShortcutDestination

    init() {}

    init(destination: AmbitionsAppShortcutDestination) {
        self.destination = destination
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let url = destination.routeURL else {
            return .result(dialog: "Ambitions could not open that destination.")
        }

        await MainActor.run {
            AppIntentLaunchRouter.shared.queue(url)
        }
        return .result(dialog: IntentDialog(stringLiteral: destination.d25CommandDescriptor.dialog))
    }
}
