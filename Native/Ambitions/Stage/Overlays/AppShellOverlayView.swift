import AmbitionsDesignSystem
import SwiftUI

@MainActor
struct ShellOverlayActions {
    private let navigation: StageStore
    private let commandRouter: any ShellCommandRouting
    private let searchService: any MemoryLensServicing

    init(
        navigation: StageStore,
        commandRouter: any ShellCommandRouting,
        searchService: any MemoryLensServicing
    ) {
        self.navigation = navigation
        self.commandRouter = commandRouter
        self.searchService = searchService
    }

    func presentCreateGoal(source: ShellCommandEntrySource, seedText: String = "", captureID: String? = nil) {
        commandRouter.presentCreateGoal(source: source, seedText: seedText, captureID: captureID)
    }

    func selectToday(entryContext: TodayEntryContext) {
        navigation.selectToday(entryContext: entryContext)
    }

    func route(to destination: ShellCommandDestination, source: ShellCommandEntrySource) {
        commandRouter.route(to: destination, source: source)
    }

    func presentGlobalCapture(source: ShellCommandEntrySource) {
        navigation.presentGlobalCaptureComposer(source: source)
    }

    func presentNoteCapture(source: ShellCommandEntrySource, seedText: String) {
        navigation.presentTypedCaptureComposer(kind: .noteThought, source: source, seedText: seedText)
    }

    func route(searchResult: MemoryLensResult, source: ShellCommandEntrySource) -> ShellTrustedSearchHandoff {
        commandRouter.route(searchResult: searchResult, source: source)
    }

    func search(
        query: String,
        seedIntent: ShellCommandIntent?,
        origin: AmbitionsSurface?
    ) async -> [MemoryLensResult] {
        await searchService.search(query: query, seedIntent: seedIntent, origin: origin)
    }
}

struct AppShellOverlayView: View {
    let overlay: ShellOverlayState
    let actions: ShellOverlayActions
    let onDismiss: () -> Void
    let onGoalCreated: (ShellOverlayState, CreateGoalResponse) -> Void

    var body: some View {
        switch overlay.kind {
        case .quietCommandSheet, .memoryLens:
            QuietCommandSheetView(overlay: overlay, actions: actions, onDismiss: onDismiss)
        case .createGoal:
            NavigationStack {
                CreateGoalScreen(
                    viewModel: CreateGoalViewModel(
                        title: overlay.query,
                        entrySource: overlay.entrySource,
                        captureID: overlay.captureID
                    )
                ) { response in
                    onGoalCreated(overlay, response)
                }
            }
        }
    }
}
