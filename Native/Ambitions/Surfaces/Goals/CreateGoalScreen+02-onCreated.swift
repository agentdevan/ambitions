import AmbitionsDesignSystem
import SwiftUI

extension CreateGoalScreen {
    @MainActor


    var createGoalObjectStage: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                Text(viewModel.captureID == nil ? "Goal to path" : "Capture to goal")
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.accentWarm)

                Text("Shape the first path")
                    .font(dynamicTypeSize.isAccessibilitySize ? theme.typography.bodyEmphasized : theme.typography.hero)
                    .foregroundStyle(theme.colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(dynamicTypeSize.isAccessibilitySize ? heroSubtitleAccessibility : heroSubtitle)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.leading, theme.spacing.sm)
            .overlay(alignment: .leading) {
                Rectangle()
                    .fill(theme.colors.accentWarm.opacity(0.76))
                    .frame(width: 2)
                    .accessibilityHidden(true)
            }

            firstPathObjectPreview

            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                Text("Outcome")
                    .font(theme.typography.section)
                    .foregroundStyle(theme.colors.textPrimary)

                Text("Name what should become real. The path, local save, and receipt stay visible before creation.")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                TextField("What do you want to make real?", text: $viewModel.title)
                    .textFieldStyle(.plain)
                    .disabled(viewModel.isSubmitting)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textPrimary)
                    .padding(.vertical, theme.spacing.sm)
                    .padding(.horizontal, theme.spacing.sm)
                    .background(theme.colors.surfaceOverlay.opacity(0.42))
                    .overlay(alignment: .leading) {
                        Rectangle()
                            .fill(viewModel.trimmedTitle.isEmpty ? theme.colors.strokeSubtle : theme.colors.accentWarm)
                            .frame(width: viewModel.trimmedTitle.isEmpty ? 1 : 3)
                            .accessibilityHidden(true)
                    }
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(viewModel.trimmedTitle.isEmpty ? theme.colors.strokeSubtle : theme.colors.accentWarm)
                            .frame(height: viewModel.trimmedTitle.isEmpty ? 1 : 1.5)
                            .accessibilityHidden(true)
                    }
                    .accessibilityIdentifier("create-goal.title-field")

                HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
                    Picker("Goal type", selection: Binding<GoalMode?>(
                        get: { viewModel.selectedMode },
                        set: { viewModel.selectedMode = $0 }
                    )) {
                        Text("Balanced path").tag(Optional<GoalMode>.none)
                        ForEach(goalTypeOptions, id: \.self) { mode in
                            Text(mode.displayTitle).tag(Optional(mode))
                        }
                    }
                    .pickerStyle(.menu)
                    .disabled(viewModel.isSubmitting)

                    Text(viewModel.selectedPace.rawValue.capitalized)
                        .font(theme.typography.caption.weight(.semibold))
                        .foregroundStyle(theme.colors.textSecondary)

                    if let selectedTargetDate = viewModel.selectedTargetDateLabel {
                        Text("Date \(selectedTargetDate)")
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textTertiary)
                    }
                }

                Text("First read: clarity, timing, source, local save, and receipt stay visible before creation.")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, theme.spacing.md)
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(theme.colors.strokeSubtle.opacity(0.62))
                    .frame(height: 1)
                    .accessibilityHidden(true)
            }
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(theme.colors.strokeSubtle.opacity(0.46))
                    .frame(height: 1)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("create-goal.hero-card")
    }


    var firstPathObjectPreview: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
                Text("First path preview")
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)

                Spacer(minLength: theme.spacing.sm)

                Text(viewModel.trimmedTitle.isEmpty ? "Waiting" : "Previewing")
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(viewModel.trimmedTitle.isEmpty ? theme.colors.textSecondary : theme.colors.accentWarm)
            }

            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    firstPathPreviewLine(
                        title: "Outcome",
                        value: viewModel.trimmedTitle.isEmpty
                            ? "Name it first. Recommended step and local receipt stay visible before creation."
                            : "\(viewModel.trimmedTitle). Recommended step and local receipt stay visible before creation."
                    )
                }
            } else {
                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    firstPathPreviewNode(title: "Outcome", value: viewModel.trimmedTitle.isEmpty ? "Name it first" : viewModel.trimmedTitle)
                    firstPathPreviewConnector
                    firstPathPreviewNode(title: "Step", value: "Recommended step")
                    firstPathPreviewConnector
                    firstPathPreviewNode(title: "Receipt", value: "Local receipt")
                }
            }
        }
        .padding(.vertical, theme.spacing.sm)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(theme.colors.strokeSubtle.opacity(0.54))
                .frame(height: 1)
                .accessibilityHidden(true)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(theme.colors.strokeSubtle.opacity(0.36))
                .frame(height: 1)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("First path preview")
        .accessibilityValue(viewModel.trimmedTitle.isEmpty ? "Waiting for the outcome." : "Showing outcome, recommended step, and local receipt.")
        .accessibilityIdentifier("create-goal.first-path-object-preview")
    }


    func firstPathPreviewNode(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
            Text(title)
                .font(theme.typography.micro)
                .foregroundStyle(theme.colors.accentSecondary)
            Text(value)
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textPrimary)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }


    func firstPathPreviewLine(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
            Text(title)
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.accentSecondary)
            Text(value)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }


    var firstPathPreviewConnector: some View {
        Rectangle()
            .fill(theme.colors.strokeSubtle.opacity(0.72))
            .frame(width: 12, height: 1)
            .padding(.top, theme.spacing.md)
            .accessibilityHidden(true)
    }


    var composerHeroCard: some View {
        AppCard(state: heroVisualState) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "Goal setup",
                    title: heroTitle,
                    subtitle: heroBody
                ) {
                    TagPill(heroBadgeTitle, state: heroVisualState)
                }

                HStack(spacing: theme.spacing.xs) {
                    TagPill(viewModel.selectedPace.rawValue.capitalized, icon: "dial.medium", state: .selected)
                    if let selectedTargetDate = viewModel.selectedTargetDateLabel {
                        TagPill("Date \(selectedTargetDate)", icon: "calendar", state: .default)
                    }
                    if viewModel.captureID != nil {
                        TagPill("Grow into Goal", icon: "tray.full", state: .default)
                    }
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("create-goal.hero-card")
            .padding(theme.spacing.lg)
        }
    }


    var intakeCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    title: "Describe the goal plainly",
                    subtitle: "Name the outcome in normal language. Ambitions will shape a first path before anything is saved."
                )

                TextField("What do you want to make real?", text: $viewModel.title)
                    .textFieldStyle(.roundedBorder)
                    .disabled(viewModel.isSubmitting)
                    .accessibilityIdentifier("create-goal.title-field")

                Picker("Goal type", selection: Binding<GoalMode?>(
                    get: { viewModel.selectedMode },
                    set: { viewModel.selectedMode = $0 }
                )) {
                    Text("Balanced path").tag(Optional<GoalMode>.none)
                    ForEach(goalTypeOptions, id: \.self) { mode in
                        Text(mode.displayTitle).tag(Optional(mode))
                    }
                }
                .pickerStyle(.menu)
                .disabled(viewModel.isSubmitting)

                Text("The first read keeps the goal focused on clarity, timing, and what can happen next.")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
            }
            .padding(theme.spacing.lg)
        }
    }


    func captureGoalHandoffCard(_ handoff: CaptureGoalHandoffState) -> some View {
        AppCard(state: .selected) {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                SectionHeader(
                    title: handoff.title,
                    subtitle: handoff.sourceLabel
                )

                Text(handoff.consequenceLabel)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)

                HStack(spacing: theme.spacing.xs) {
                    TagPill(handoff.confirmationLabel, icon: "checkmark.seal", state: .selected)
                    TagPill(handoff.privacyLabel, icon: "lock", state: .default)
                }
            }
            .padding(theme.spacing.lg)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("create-goal.capture-handoff")
    }
}
