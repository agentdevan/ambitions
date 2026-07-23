import SwiftUI

struct TodayFlagshipRecoveryReviewView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @AccessibilityFocusState private var accessibilityFocus: TodayFlagshipFocusAnchor?

    let content: TodayFlagshipCalibrationContent
    @Binding var state: TodayFlagshipJourneyState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 7) {
                        Text(content.primaryStep.title)
                            .font(.title3.weight(.semibold))
                            .fixedSize(horizontal: false, vertical: true)
                        Text(content.interfaceCopy.recoveryBody)
                            .font(.subheadline)
                            .foregroundStyle(palette.secondaryInk)
                    }

                    TodayFlagshipLocalSeam(palette: palette) {
                        VStack(alignment: .leading, spacing: 7) {
                            TodayFlagshipSectionLabel(
                                "Last saved progress",
                                symbol: "externaldrive.badge.checkmark",
                                palette: palette
                            )
                            Text(content.recovery.lastSavedProgress)
                                .font(.body)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(content.recovery.availableChoices) { choice in
                            recoveryChoice(choice)
                        }
                    }
                }
                .frame(maxWidth: 560, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 18)
                .padding(.bottom, 44)
            }
            .scrollIndicators(.hidden)
            .background(palette.semanticPlane.ignoresSafeArea())
            .foregroundStyle(palette.primaryInk)
            .navigationTitle(content.interfaceCopy.recoveryTitle)
            .todayFlagshipInlineNavigationTitle()
        }
        .onAppear {
            accessibilityFocus = .recoveryReview
        }
        .accessibilityFocused($accessibilityFocus, equals: .recoveryReview)
        .accessibilityIdentifier("tfcs-recovery-review")
    }

    private func recoveryChoice(_ choice: TodayFlagshipRecoveryChoice) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            if choice.id == "recovery.continue-saved-progress" {
                recoveryButton(choice)
                    .buttonStyle(.borderedProminent)
                    .foregroundStyle(palette.actionInk)
            } else {
                recoveryButton(choice)
                    .buttonStyle(.bordered)
            }

            Text(choice.consequence)
                .font(.footnote)
                .foregroundStyle(palette.secondaryInk)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func recoveryButton(_ choice: TodayFlagshipRecoveryChoice) -> some View {
        Button(choice.title) {
            if choice.id == "recovery.continue-saved-progress" {
                _ = state.continueFromSavedProgress()
            } else {
                _ = state.dismissRecovery()
            }
        }
        .buttonBorderShape(.roundedRectangle(radius: 8))
        .controlSize(.large)
        .frame(minHeight: 44, alignment: .leading)
        .accessibilityHint(choice.consequence)
        .accessibilityIdentifier(choice.id)
    }

    private var palette: TodayFlagshipPalette {
        TodayFlagshipPalette(
            colorScheme: colorScheme,
            contrast: colorSchemeContrast
        )
    }
}
