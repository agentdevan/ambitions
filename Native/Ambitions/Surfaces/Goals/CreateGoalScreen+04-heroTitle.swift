import AmbitionsDesignSystem
import SwiftUI

// Accessibility contract: split hero helpers provide semantic labels through the root CreateGoalScreen accessibility tree.
extension CreateGoalScreen {

    var heroTitle: String {
        switch viewModel.previewState {
        case .idle:
            return "Name the outcome first"
        case .loading:
            return "Shaping the first path"
        case let .failed(message):
            return message
        case let .loaded(preview):
            switch preview.resultKind {
            case .planned, .starterPlanned:
                return "A first path is visible"
            case .clarificationRequired:
                return "One clarification keeps the path honest"
            case .blocked:
                return "A blocker is visible before the goal goes live"
            }
        }
    }


    var heroBody: String {
        switch viewModel.previewState {
        case .idle:
            return "Start with the goal in plain language. Ambitions will keep the first read focused on clarity, timing, and what can happen next."
        case .loading:
            return "Ambitions is shaping the setup without saving anything yet."
        case let .failed(message):
            return message
        case let .loaded(preview):
            if let feasibility = preview.feasibility {
                return feasibility.summary
            }
            if let clarification = preview.clarification {
                return clarification.subtitle
            }
            if let blocked = preview.blocked {
                return blocked.subtitle
            }
            return preview.summary
        }
    }


    var heroBadgeTitle: String {
        switch viewModel.previewState {
        case .idle:
            return "Intake"
        case .loading:
            return "Preview"
        case .failed:
            return "Paused"
        case let .loaded(preview):
            return preview.renderState.title
        }
    }


    var heroVisualState: AmbitionVisualState {
        switch viewModel.previewState {
        case .idle, .loading:
            return .selected
        case .failed:
            return .warning
        case let .loaded(preview):
            return preview.renderState.visualState
        }
    }


    var submitButtonTitle: String {
        guard case let .loaded(preview) = viewModel.previewState else {
            return viewModel.isSubmitting ? "Saving..." : "Create Goal"
        }

        if viewModel.isSubmitting {
            return preview.resultKind == .planned || preview.resultKind == .starterPlanned ? "Creating Goal..." : "Saving Draft..."
        }

        switch preview.resultKind {
        case .planned, .starterPlanned:
            return "Create Goal"
        case .clarificationRequired, .blocked:
            return "Save Draft"
        }
    }


    var goalTypeOptions: [GoalMode] {
        [.project, .achievement, .learning, .exploration, .maintenance]
    }


    var featureFactory: AppFeatureFactoryCapability {
        guard let appFeatureFactoryCapability else {
            preconditionFailure("App feature factory capability must be injected.")
        }
        return appFeatureFactoryCapability
    }
}
