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
                TodayOpenContinuityInterruptedField(
                    content: content,
                    acceptedTruth: state.acceptedTruth,
                    palette: palette,
                    showsRecoveryAction: false
                )
                .frame(maxWidth: 560, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 18)
                .padding(.bottom, 28)
            }
            .background(palette.semanticPlane.ignoresSafeArea())
            .foregroundStyle(palette.primaryInk)
            .navigationTitle(content.interfaceCopy.recoveryTitle)
            .todayFlagshipInlineNavigationTitle()
            .safeAreaInset(edge: .bottom, spacing: 0) {
                recoveryActions
            }
        }
        .onAppear {
            accessibilityFocus = .recoveryReview
        }
        .accessibilityFocused($accessibilityFocus, equals: .recoveryReview)
        .accessibilityIdentifier("tfcs-recovery-review")
    }

    private var recoveryActions: some View {
        VStack(alignment: .leading, spacing: 11) {
            ForEach(content.recovery.availableChoices) { choice in
                recoveryChoice(choice)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 14)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity)
        .background(palette.semanticPlane)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(palette.divider)
                .frame(height: 1)
        }
    }

    private func recoveryChoice(_ choice: TodayFlagshipRecoveryChoice) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            if choice.id == "recovery.continue-saved-progress" {
                recoveryButton(choice)
                    .buttonStyle(
                        TodayOpenContinuityPrimaryActionStyle(
                            palette: palette.openContinuity
                        )
                    )
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
                _ = state.leaveForLater()
            }
        }
        .buttonBorderShape(.roundedRectangle(radius: 8))
        .controlSize(.large)
        .frame(minHeight: 44, alignment: .leading)
        .accessibilityHint(choice.consequence)
        .accessibilityInputLabels([choice.title])
        .accessibilityIdentifier(choice.id)
    }

    private var palette: TodayFlagshipPalette {
        TodayFlagshipPalette(
            colorScheme: colorScheme,
            contrast: colorSchemeContrast
        )
    }
}
