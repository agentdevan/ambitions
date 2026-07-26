import SwiftUI

struct TodayVitalityInterruptedStepView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @AccessibilityFocusState private var isInterruptionFocused: Bool

    let content: TodayFlagshipCalibrationContent
    let acceptedTruth: String
    let shouldFocusInterruption: Bool
    let onOpenRecovery: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                identity
                parentPursuit
                interruptionSeam
                acceptedTruthField
                savedProgressField
                temporalRelationship
                recoveryAction
            }
            .frame(maxWidth: 560, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 18)
            .padding(.bottom, 36)
        }
        .background(palette.canvas.ignoresSafeArea())
        .foregroundStyle(palette.labelPrimary)
        .onAppear {
            isInterruptionFocused = shouldFocusInterruption
        }
        .onChange(of: shouldFocusInterruption) { _, shouldFocus in
            guard shouldFocus else { return }
            isInterruptionFocused = true
        }
    }

    private var identity: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(content.interfaceCopy.stepTitle)
                .font(TodayVitalityTypographyRole.metadata.font.weight(.semibold))
                .foregroundStyle(palette.ambitionsAccentMuted)

            Text(content.primaryStep.title)
                .font(TodayVitalityTypographyRole.objectIdentity.font)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("tfcs-recovery-step-identity")
    }

    private var parentPursuit: some View {
        Label(content.primaryStep.parentPursuitTitle, systemImage: "house")
            .font(TodayVitalityTypographyRole.relationship.font.weight(.medium))
            .foregroundStyle(palette.ambitionsAccentMuted)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityElement(children: .combine)
    }

    private var interruptionSeam: some View {
        HStack(alignment: .center, spacing: 8) {
            TodayVitalityNode(kind: .interrupted, palette: palette)

            Text(content.interfaceCopy.interruptedStepTitle)
                .font(TodayVitalityTypographyRole.metadata.font.weight(.semibold))
                .foregroundStyle(palette.interruptedState)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(palette.interruptedState.opacity(0.55))
                .frame(height: palette.separatorStrokeWidth)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(content.interfaceCopy.interruptedStepTitle)
        .accessibilityFocused($isInterruptionFocused)
        .accessibilityIdentifier("tfcs-interruption-seam")
    }

    private var acceptedTruthField: some View {
        HStack(alignment: .top, spacing: 8) {
            TodayVitalityRailNode(kind: .current, palette: palette, extendsAfter: false)

            VStack(alignment: .leading, spacing: 8) {
                Text(content.interfaceCopy.rightNowTitle)
                    .font(TodayVitalityTypographyRole.metadata.font.weight(.semibold))
                    .foregroundStyle(palette.ambitionsAccentMuted)

                Text(acceptedTruth)
                    .font(TodayVitalityTypographyRole.stateTruth.font)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 7)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(content.interfaceCopy.currentStateAccessibilityTitle)
        .accessibilityValue(acceptedTruth)
        .accessibilityIdentifier("tfcs-recovery-current-truth")
    }

    private var savedProgressField: some View {
        TodayVitalityOpenRelief(palette: palette, truthKind: .interrupted) {
            VStack(alignment: .leading, spacing: 8) {
                Text(content.interfaceCopy.lastSavedProgressTitle)
                    .font(TodayVitalityTypographyRole.metadata.font.weight(.semibold))
                    .foregroundStyle(palette.interruptedState)

                Text(content.recovery.lastSavedProgress)
                    .font(TodayVitalityTypographyRole.relationship.font.weight(.medium))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(content.interfaceCopy.lastSavedProgressTitle)
        .accessibilityValue(content.recovery.lastSavedProgress)
        .accessibilityIdentifier("tfcs-recovery-progress-field")
    }

    private var temporalRelationship: some View {
        Label {
            Text(
                "\(content.primaryStep.temporalContext.exactTime) · "
                    + content.primaryStep.temporalContext.relationship
            )
            .fixedSize(horizontal: false, vertical: true)
        } icon: {
            Image(systemName: "clock")
                .accessibilityHidden(true)
        }
        .font(TodayVitalityTypographyRole.metadata.font.monospacedDigit())
        .foregroundStyle(palette.labelSecondary)
        .accessibilityElement(children: .combine)
    }

    private var recoveryAction: some View {
        Button(action: onOpenRecovery) {
            HStack(spacing: 12) {
                Text(content.interfaceCopy.recoveryEntryTitle)
                Spacer(minLength: 8)
                Image(systemName: "chevron.forward")
                    .accessibilityHidden(true)
            }
            .frame(minHeight: 48)
        }
        .buttonStyle(
            TodayVitalityActionStyle(
                role: .continuation,
                palette: palette
            )
        )
        .accessibilityHint(content.interfaceCopy.recoveryBody)
        .accessibilityInputLabels([content.interfaceCopy.recoveryEntryTitle])
        .accessibilityIdentifier("tfcs-open-recovery")
    }

    private var palette: TodayVitalityPalette {
        TodayVitalityPalette(
            colorScheme: colorScheme,
            contrast: colorSchemeContrast,
            differentiateWithoutColor: differentiateWithoutColor,
            reduceTransparency: reduceTransparency
        )
    }
}

struct TodayVitalityRecoverySheetView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(\.dismiss) private var dismiss
    @AccessibilityFocusState private var focusedCommandID: String?

    let content: TodayFlagshipCalibrationContent
    @Binding var state: TodayFlagshipJourneyState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    sheetHeading
                    savedProgress
                }
                .frame(maxWidth: 560, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                actionRegion
            }
            .background(palette.canvas.ignoresSafeArea())
            .foregroundStyle(palette.labelPrimary)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark") {
                        _ = state.dismissRecovery()
                        dismiss()
                    }
                    .accessibilityHint("Leaves the Step unchanged")
                }
            }
        }
        .onAppear {
            focusedCommandID = "recovery.continue-saved-progress"
        }
        .accessibilityIdentifier("tfcs-recovery-review")
    }

    private var sheetHeading: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(content.interfaceCopy.recoveryTitle)
                .font(TodayVitalityTypographyRole.objectIdentity.font)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            Text(content.interfaceCopy.recoveryBody)
                .font(TodayVitalityTypographyRole.relationship.font)
                .foregroundStyle(palette.labelSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(content.interfaceCopy.recoveryTitle)
        .accessibilityValue(
            "\(content.primaryStep.title). \(content.interfaceCopy.recoveryBody)"
        )
        .accessibilityIdentifier("tfcs-recovery-sheet-heading")
    }

    private var savedProgress: some View {
        TodayVitalityOpenRelief(palette: palette, truthKind: .interrupted) {
            HStack(alignment: .top, spacing: 8) {
                TodayVitalityNode(kind: .interrupted, palette: palette)

                VStack(alignment: .leading, spacing: 7) {
                    Text(content.interfaceCopy.lastSavedProgressTitle)
                        .font(TodayVitalityTypographyRole.metadata.font.weight(.semibold))
                        .foregroundStyle(palette.interruptedState)

                    Text(content.recovery.lastSavedProgress)
                        .font(TodayVitalityTypographyRole.relationship.font.weight(.medium))
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Saved at 10:30 AM")
                        .font(TodayVitalityTypographyRole.metadata.font.monospacedDigit())
                        .foregroundStyle(palette.labelSecondary)
                }
                .padding(.top, 6)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(content.interfaceCopy.lastSavedProgressTitle)
        .accessibilityValue("\(content.recovery.lastSavedProgress). Saved at 10:30 AM")
        .accessibilityIdentifier("tfcs-recovery-sheet-progress")
    }

    private var actionRegion: some View {
        VStack(spacing: 10) {
            recoveryButton(
                id: "recovery.continue-saved-progress",
                role: .continuation
            ) {
                _ = state.continueFromSavedProgress()
                dismiss()
            }

            recoveryButton(
                id: "recovery.keep-step",
                role: .secondary
            ) {
                _ = state.leaveForLater()
                dismiss()
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 10)
        .background {
            palette.canvas
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(palette.separator)
                        .frame(height: palette.separatorStrokeWidth)
                }
        }
    }

    private func recoveryButton(
        id: String,
        role: TodayVitalityActionRole,
        action: @escaping () -> Void
    ) -> some View {
        let choice = content.recovery.availableChoices.first { $0.id == id }

        return Button(action: action) {
            Text(choice?.title ?? id)
                .multilineTextAlignment(.center)
                .frame(minHeight: 48)
        }
        .buttonStyle(TodayVitalityActionStyle(role: role, palette: palette))
        .accessibilityHint(choice?.consequence ?? "")
        .accessibilityInputLabels([choice?.title ?? id])
        .accessibilityFocused($focusedCommandID, equals: id)
        .accessibilityIdentifier(id)
    }

    private var palette: TodayVitalityPalette {
        TodayVitalityPalette(
            colorScheme: colorScheme,
            contrast: colorSchemeContrast,
            differentiateWithoutColor: differentiateWithoutColor,
            reduceTransparency: reduceTransparency
        )
    }
}

struct TodayVitalityRecoveredProgressField: View {
    let title: String
    let progress: String
    let palette: TodayVitalityPalette

    var body: some View {
        TodayVitalityOpenRelief(palette: palette, truthKind: .interrupted) {
            HStack(alignment: .top, spacing: 8) {
                TodayVitalityNode(kind: .interrupted, palette: palette)

                VStack(alignment: .leading, spacing: 7) {
                    Text(title)
                        .font(TodayVitalityTypographyRole.metadata.font.weight(.semibold))
                        .foregroundStyle(palette.interruptedState)

                    Text(progress)
                        .font(TodayVitalityTypographyRole.relationship.font.weight(.medium))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 6)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue(progress)
        .accessibilityIdentifier("tfcs-recovered-progress")
    }
}
