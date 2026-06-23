import AmbitionsDesignSystem
import SwiftUI

// Mutation/accessibility/proof contract: detail actions route through GoalDetailActionRequest, update visible stage state, announce the result, and retain proof receipt references.
struct GoalDetailScreen: View {
    @Environment(\.appFeatureFactoryCapability) private var appFeatureFactoryCapability
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel: GoalDetailViewModel

    @MainActor
    init(target: GoalRouteTarget, viewModel: GoalDetailViewModel? = nil) {
        _viewModel = State(initialValue: viewModel ?? GoalDetailViewModel(target: target))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                switch viewModel.state {
                case .loading:
                    DegradedStateSurface(state: DegradedStateOrchestrator.objectLoading(.missionControlTimeSpine))
                case let .failed(message):
                    DegradedStateSurface(
                        state: DegradedStateOrchestrator.objectUnavailable(.missionControlTimeSpine),
                        primaryAccessibilityIdentifier: "goal-detail.retry-button",
                        onPrimaryAction: {
                            _ = message
                            Task { await viewModel.refresh(using: featureFactory.goalsService) }
                        }
                    )
                case let .loaded(detail):
                    GoalDetailProfileSurface(detail: detail)

                    if let inlineMessage = viewModel.inlineMessage {
                        AppCard(state: inlineMessage.state) {
                            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                Text(inlineMessage.title)
                                    .font(theme.typography.section)
                                    .foregroundStyle(theme.colors.textPrimary)
                                Text(inlineMessage.body)
                                    .font(theme.typography.body)
                                    .foregroundStyle(theme.colors.textSecondary)
                            }
                        }
                    }

                    GoalDetailPathFieldSurface(detail: detail) { action in
                        Task { await viewModel.perform(action, using: featureFactory.goalsService) }
                    }

                    GoalDetailJournalSurface(detail: detail)

                    if let clarification = detail.clarification {
                        GoalDetailSectionSurface(title: clarification.title, subtitle: clarification.subtitle) {
                            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                                ForEach(clarification.questions) { question in
                                    VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                        Text(question.prompt)
                                            .font(theme.typography.bodyEmphasized)
                                            .foregroundStyle(theme.colors.textPrimary)
                                        Text(question.rationale)
                                            .font(theme.typography.caption)
                                            .foregroundStyle(theme.colors.textSecondary)
                                        Text("Safe default: \(question.gentleDefault)")
                                            .font(theme.typography.caption)
                                            .foregroundStyle(theme.colors.textTertiary)
                                        TextField(
                                            "Write the smallest real answer",
                                            text: Binding(
                                                get: { viewModel.clarificationAnswers[question.id, default: question.existingAnswer ?? ""] },
                                                set: { viewModel.clarificationAnswers[question.id] = $0 }
                                            ),
                                            axis: .vertical
                                        )
                                        .textFieldStyle(.roundedBorder)
                                        .padding(.top, theme.spacing.xs)
                                        Button("Save answer") {
                                            Task { await viewModel.saveClarificationAnswer(question, using: featureFactory.goalsService) }
                                        }
                                        .buttonStyle(AmbitionPressableButtonStyle(state: .selected))
                                        .padding(.top, theme.spacing.xs)
                                    }
                                    .padding(theme.spacing.sm)
                                    .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
                                }
                            }
                        }
                    }

                    if let blocked = detail.blocked {
                        GoalDetailSectionSurface(title: blocked.title, subtitle: blocked.subtitle) {
                            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                ForEach(blocked.blockers, id: \.self) { blocker in
                                    Label(blocker, systemImage: "exclamationmark.triangle.fill")
                                        .font(theme.typography.body)
                                        .foregroundStyle(theme.colors.textSecondary)
                                }
                            }
                        }
                    }

                    GoalDetailSectionSurface(title: "Operations", subtitle: "Only available actions are shown. Unsupported path edits stay out of the control surface.") {
                        GoalActionGrid(actions: detail.actions) { action in
                            Task { await viewModel.perform(action, using: featureFactory.goalsService) }
                        }
                    }

                    if detail.suggestions.isEmpty == false {
                        GoalDetailSectionSurface(title: "Suggested Steps", subtitle: "The calmest contained steps that still create signal.") {
                            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                                ForEach(detail.suggestions) { step in
                                    GoalSuggestionSurface(step: step)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.vertical, theme.spacing.md)
        }
        .accessibilityIdentifier("goal-detail.screen")
        .scrollIndicators(.hidden)
        .refreshable {
            await viewModel.refresh(using: featureFactory.goalsService)
        }
        .navigationTitle("Goal")
        .navigationBarTitleDisplayMode(.inline)
        .animation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: true), value: viewModel.stateKey)
        .animation(theme.motion.animation(reduceMotion: reduceMotion), value: viewModel.inlineMessage?.title)
        .animation(theme.motion.animation(reduceMotion: reduceMotion), value: viewModel.lens)
        .task {
            await viewModel.load(using: featureFactory.goalsService)
        }
    }

    var featureFactory: AppFeatureFactoryCapability {
        guard let appFeatureFactoryCapability else {
            preconditionFailure("App feature factory capability must be injected.")
        }
        return appFeatureFactoryCapability
    }
}
