#if DEBUG

import SwiftUI

#Preview("Capture Empty") {
    NavigationStack {
        CaptureComposerSurface(shellMode: .globalComposer, viewModel: CapturePreviewFactory.empty())
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("Capture Route Suggestions") {
    NavigationStack {
        CaptureComposerSurface(shellMode: .globalComposer, viewModel: CapturePreviewFactory.routeSuggestions())
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("Capture Needs placement") {
    NavigationStack {
        CaptureComposerSurface(shellMode: .globalComposer, viewModel: CapturePreviewFactory.needsPlace())
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("Capture Manual Route") {
    NavigationStack {
        CaptureComposerSurface(shellMode: .globalComposer, viewModel: CapturePreviewFactory.manualRoute())
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("Capture Dynamic Type") {
    NavigationStack {
        CaptureComposerSurface(shellMode: .globalComposer, viewModel: CapturePreviewFactory.routeSuggestions())
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
    .environment(\.dynamicTypeSize, .accessibility2)
}

#Preview("Capture Reduce Motion") {
    NavigationStack {
        CaptureComposerSurface(shellMode: .globalComposer, viewModel: CapturePreviewFactory.routeSuggestions())
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("Capture Receipt") {
    NavigationStack {
        CaptureComposerSurface(shellMode: .globalComposer, viewModel: CapturePreviewFactory.receipt())
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("Capture Light") {
    NavigationStack {
        CaptureComposerSurface(shellMode: .globalComposer, viewModel: CapturePreviewFactory.routeSuggestions())
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.light)
    .preferredColorScheme(.light)
}

@MainActor
private enum CapturePreviewFactory {
    static func empty() -> CaptureViewModel {
        CaptureViewModel(state: .loaded(CaptureViewState(captures: [], activeGoalOptions: [])))
    }

    static func routeSuggestions() -> CaptureViewModel {
        let viewModel = CaptureViewModel(state: .loaded(CaptureViewState(captures: [], activeGoalOptions: [
            CaptureGoalOption(id: "goal-music", title: "Music Goal", subtitle: "Creative")
        ])))
        viewModel.updateDraftText("Finish lyrics before rehearsal")
        return viewModel
    }

    static func needsPlace() -> CaptureViewModel {
        let viewModel = CaptureViewModel(state: .loaded(CaptureViewState(captures: [], activeGoalOptions: [])))
        viewModel.updateDraftText("NASA")
        return viewModel
    }

    static func manualRoute() -> CaptureViewModel {
        let viewModel = CaptureViewModel(state: .loaded(CaptureViewState(captures: [], activeGoalOptions: [])))
        viewModel.updateDraftText("NASA")
        viewModel.selectDraftRoute(.task)
        return viewModel
    }

    static func receipt() -> CaptureViewModel {
        let viewModel = CaptureViewModel(state: .loaded(CaptureViewState(captures: [], activeGoalOptions: [])))
        viewModel.actionMessage = CaptureActionMessage(
            title: "Saved for Today",
            body: "This can become Time work later; no calendar event was created."
        )
        return viewModel
    }
}

#endif
