import SwiftUI

struct TodayOpenContinuityInterruptedField: View {
    let content: TodayFlagshipCalibrationContent
    let acceptedTruth: String
    let palette: TodayFlagshipPalette
    var showsRecoveryAction: Bool
    var onOpenRecovery: (() -> Void)?

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            TodayOpenContinuitySpine(
                kind: .interrupted,
                palette: palette.openContinuity,
                extendsBefore: true,
                extendsAfter: true
            )
            .frame(width: 28)
            .frame(minHeight: 252)

            VStack(alignment: .leading, spacing: 15) {
                TodayFlagshipLandmarkLabel(
                    title: content.interfaceCopy.interruptedStepTitle,
                    symbol: "pause.circle",
                    tint: palette.interruptionAccent
                )

                VStack(alignment: .leading, spacing: 6) {
                    Text(content.primaryStep.title)
                        .font(TodayOpenContinuityTypographyRole.objectIdentity.font)
                        .foregroundStyle(palette.primaryInk)
                        .fixedSize(horizontal: false, vertical: true)

                    Label(content.primaryStep.parentPursuitTitle, systemImage: "scope")
                        .font(TodayOpenContinuityTypographyRole.relationship.font)
                        .foregroundStyle(palette.secondaryInk)
                }
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("tfcs-recovery-step-identity")

                VStack(alignment: .leading, spacing: 4) {
                    Text(content.interfaceCopy.rightNowTitle)
                        .font(TodayOpenContinuityTypographyRole.metadata.font.weight(.semibold))
                        .foregroundStyle(palette.secondaryInk)

                    Text(acceptedTruth)
                        .font(TodayOpenContinuityTypographyRole.state.font)
                        .foregroundStyle(palette.primaryInk)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background {
                    UnevenRoundedRectangle(
                        topLeadingRadius: 9,
                        bottomLeadingRadius: 3,
                        bottomTrailingRadius: 9,
                        topTrailingRadius: 3,
                        style: .continuous
                    )
                    .fill(palette.currentTruthPlane)
                }
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("tfcs-recovery-current-truth")

                VStack(alignment: .leading, spacing: 5) {
                    Label(
                        content.interfaceCopy.lastSavedProgressTitle,
                        systemImage: "externaldrive.badge.checkmark"
                    )
                    .font(TodayOpenContinuityTypographyRole.metadata.font.weight(.semibold))
                    .foregroundStyle(palette.interruptionAccent)

                    Text(content.recovery.lastSavedProgress)
                        .font(TodayOpenContinuityTypographyRole.state.font)
                        .foregroundStyle(palette.primaryInk)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .accessibilityElement(children: .combine)

                Text(content.interfaceCopy.recoveryBody)
                    .font(TodayOpenContinuityTypographyRole.relationship.font)
                    .foregroundStyle(palette.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)

                if showsRecoveryAction, let onOpenRecovery {
                    Button(content.interfaceCopy.recoveryEntryTitle, action: onOpenRecovery)
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.roundedRectangle(radius: 8))
                        .controlSize(.large)
                        .frame(minHeight: 44)
                        .accessibilityHint(content.recovery.interruptionDetail)
                        .accessibilityIdentifier("tfcs-open-recovery")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tfcs-recovery-progress-field")
    }
}

struct TodayOpenContinuityContextSeam: View {
    let seam: TodayFlagshipContextSeamSnapshot
    let palette: TodayFlagshipPalette

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            TodayOpenContinuitySpine(
                kind: nodeKind,
                palette: palette.openContinuity,
                extendsBefore: true,
                extendsAfter: true
            )
            .frame(width: 28)
            .frame(minHeight: 78)

            VStack(alignment: .leading, spacing: 4) {
                Label(seam.title, systemImage: symbolName)
                    .font(TodayOpenContinuityTypographyRole.relationship.font.weight(.semibold))
                    .foregroundStyle(accent)

                Text(seam.body)
                    .font(TodayOpenContinuityTypographyRole.relationship.font)
                    .foregroundStyle(palette.primaryInk)
                    .fixedSize(horizontal: false, vertical: true)

                Text(seam.ownerTitle)
                    .font(TodayOpenContinuityTypographyRole.metadata.font)
                    .foregroundStyle(palette.tertiaryInk)
            }
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(seam.accessibilityLabel)
        .accessibilityIdentifier("tfcs-context-seam-\(seam.condition.rawValue)")
    }

    private var nodeKind: TodayOpenContinuityNodeKind {
        switch seam.condition {
        case .offlineLocalTruth:
            .current
        case .staleExternalContext:
            .external
        case .conflictTransfer:
            .interrupted
        }
    }

    private var symbolName: String {
        switch seam.condition {
        case .offlineLocalTruth:
            "iphone"
        case .staleExternalContext:
            "clock.badge.exclamationmark"
        case .conflictTransfer:
            "arrow.triangle.branch"
        }
    }

    private var accent: Color {
        switch seam.condition {
        case .offlineLocalTruth:
            palette.secondaryInk
        case .staleExternalContext:
            palette.tertiaryInk
        case .conflictTransfer:
            palette.interruptionAccent
        }
    }
}
