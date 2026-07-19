import AmbitionsDesignSystem
import SwiftUI

extension CreateGoalScreen {

    func goalSeedReviewSection(_ review: GoalSeedReviewState) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    Text("Local save checkpoint")
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text("Review the goal seed before anything is saved.")
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: theme.spacing.sm)

                TagPill("Confirm first", icon: "checkmark.seal", state: review.state)
                    .fixedSize(horizontal: true, vertical: false)
            }

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Label(review.whyGoalLabel, systemImage: "questionmark.circle")
                Label(review.startingPositionLabel, systemImage: "location")
                Label(review.firstMilestoneLabel, systemImage: "flag")
                Label(review.firstStepLabel, systemImage: "arrow.forward.circle")
                Label(review.proofSourceSeedLabel, systemImage: "doc.text.magnifyingglass")
                Label(review.confirmationLabel, systemImage: "hand.raised")
            }
            .font(theme.typography.caption)
            .foregroundStyle(theme.colors.textSecondary)
        }
        .padding(.vertical, theme.spacing.md)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(theme.colors.strokeSubtle.opacity(0.54))
                .frame(height: 1)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Local save checkpoint")
        .accessibilityValue(review.accessibilityValue)
        .accessibilityIdentifier("create-goal.seed-review")
    }


    func clarificationCard(_ clarification: GoalClarificationState) -> some View {
        AppCard(state: .warning) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    title: clarification.title,
                    subtitle: clarification.subtitle
                )

                ForEach(clarification.questions) { question in
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        Text(question.prompt)
                            .font(theme.typography.bodyEmphasized)
                            .foregroundStyle(theme.colors.textPrimary)

                        Text(question.rationale)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)

                        TextField(
                            question.gentleDefault,
                            text: Binding(
                                get: { viewModel.answer(for: question.field) },
                                set: { viewModel.setAnswer($0, for: question.field) }
                            )
                        )
                        .textFieldStyle(.roundedBorder)
                    }
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("create-goal.clarification-card")
            .padding(theme.spacing.lg)
        }
    }


    func strategyCard(_ preview: CreateGoalPreviewState) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
                    Text("Goal to path")
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.accentSecondary)

                    Spacer(minLength: theme.spacing.sm)

                    TagPill(preview.renderState.title, state: preview.renderState.visualState)
                        .fixedSize(horizontal: true, vertical: false)
                }

                Text(preview.normalizedTitle)
                    .font(theme.typography.section)
                    .foregroundStyle(theme.colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(preview.summary)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                TagPill(preview.modeLabel, state: .default)
            }

            if preview.blocked == nil {
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    Text("What the path looks like")
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)

                    if preview.pathStages.isEmpty {
                        Text("Ambitions is holding off on a path until the goal is clearer.")
                            .font(theme.typography.body)
                            .foregroundStyle(theme.colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    } else {
                        ForEach(preview.pathStages.prefix(3)) { stage in
                            HStack(alignment: .top, spacing: theme.spacing.sm) {
                                Circle()
                                    .fill(theme.stateStyle(for: stage.state).accent)
                                    .frame(width: 8, height: 8)
                                    .padding(.top, theme.spacing.xs)

                                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                                    Text(stage.title)
                                        .font(theme.typography.bodyEmphasized)
                                        .foregroundStyle(theme.colors.textPrimary)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Text(stage.highlight ?? stage.summary)
                                        .font(theme.typography.caption)
                                        .foregroundStyle(theme.colors.textSecondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }

                                Spacer(minLength: theme.spacing.sm)

                                TagPill(stage.stepCountLabel, state: stage.state)
                                    .fixedSize(horizontal: true, vertical: false)
                            }
                        }
                    }
                }
            }
        }
        .padding(.vertical, theme.spacing.md)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(theme.colors.strokeSubtle.opacity(0.54))
                .frame(height: 1)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("create-goal.strategy-card")
    }


    func feasibilityCard(
        _ feasibility: StrategyComposerFeasibilityState,
        preview: CreateGoalPreviewState
    ) -> some View {
        AppCard(state: feasibility.state) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    title: feasibility.title,
                    subtitle: feasibility.summary
                ) {
                    TagPill(preview.selectedPace.rawValue.capitalized, state: .selected)
                }

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    Text("Pacing")
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)

                    ForEach(preview.paceOptions) { option in
                        Button {
                            viewModel.selectPace(option.choice)
                        } label: {
                            HStack(alignment: .top, spacing: theme.spacing.md) {
                                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                                    Text(option.title)
                                        .font(theme.typography.bodyEmphasized)
                                        .foregroundStyle(theme.colors.textPrimary)
                                    Text(option.subtitle)
                                        .font(theme.typography.caption)
                                        .foregroundStyle(theme.colors.textSecondary)
                                        .multilineTextAlignment(.leading)
                                }

                                Spacer(minLength: theme.spacing.sm)
                                TagPill(option.badgeTitle, state: option.state)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(theme.spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                                    .fill(theme.stateStyle(for: option.state).fill)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                                    .stroke(theme.stateStyle(for: option.state).stroke, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                if feasibility.details.isEmpty == false {
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        Text("Why it looks this way")
                            .font(theme.typography.bodyEmphasized)
                            .foregroundStyle(theme.colors.textPrimary)
                        ForEach(Array(feasibility.details.prefix(3).enumerated()), id: \.offset) { entry in
                            Text("• \(entry.element)")
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                        }
                    }
                }

                if let deadlineGuidance = preview.deadlineGuidance {
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        Text(deadlineGuidance.title)
                            .font(theme.typography.bodyEmphasized)
                            .foregroundStyle(theme.colors.textPrimary)
                        Text(deadlineGuidance.body)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)

                        Button {
                            viewModel.applySuggestedDeadline(deadlineGuidance.suggestedDate)
                        } label: {
                            HStack {
                                Text("Use \(deadlineGuidance.suggestedDate)")
                                Spacer()
                                TagPill(deadlineGuidance.badgeTitle, state: deadlineGuidance.state)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(AmbitionPressableButtonStyle(state: .warning))
                    }
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("create-goal.feasibility-card")
            .padding(theme.spacing.lg)
        }
    }


    func milestoneCard(_ preview: CreateGoalPreviewState) -> some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    title: "Phase and milestone preview",
                    subtitle: "The first pass stays small enough to act on while still showing the shape of the path."
                )

                ForEach(preview.milestonePreview) { item in
                    HStack(alignment: .top, spacing: theme.spacing.md) {
                        VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                            Text(item.title)
                                .font(theme.typography.bodyEmphasized)
                                .foregroundStyle(theme.colors.textPrimary)
                            Text(item.summary)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                        }
                        Spacer(minLength: theme.spacing.sm)
                        TagPill(item.timingLabel, state: .default)
                    }
                    .padding(.vertical, theme.spacing.xxs)
                }
            }
            .padding(theme.spacing.lg)
        }
    }


    func trustCard(_ trust: StrategyComposerTrustState) -> some View {
        AppCard(state: trust.state) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    title: trust.title,
                    subtitle: "A calm first read on what Ambitions is using and what it is not pretending to know."
                ) {
                    TagPill(trust.badgeTitle, state: trust.state)
                }

                ForEach(Array(trust.lines.enumerated()), id: \.offset) { entry in
                    Text("• \(entry.element)")
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("create-goal.trust-card")
            .padding(theme.spacing.lg)
        }
    }


    var heroSubtitle: String {
        viewModel.captureID == nil
            ? "Shape a first path before you save the goal."
            : "Grow the capture into a goal only after you confirm the setup."
    }


    var heroSubtitleAccessibility: String {
        viewModel.captureID == nil
            ? "First path before save."
            : "Confirm before the capture becomes a goal."
    }
}
