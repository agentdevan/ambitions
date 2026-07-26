import SwiftUI

struct TodayVitalityContextSeam: View {
    let seam: TodayFlagshipContextSeamSnapshot
    let palette: TodayVitalityPalette

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            TodayVitalityNode(kind: nodeKind, palette: palette)

            VStack(alignment: .leading, spacing: 4) {
                Text(seam.title)
                    .font(TodayVitalityTypographyRole.relationship.font)
                    .foregroundStyle(titleColor)
                Text(seam.body)
                    .font(TodayVitalityTypographyRole.metadata.font)
                    .foregroundStyle(palette.labelSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, 8)
        }
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(palette.separator)
                .frame(height: palette.separatorStrokeWidth)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(seam.accessibilityLabel)
        .accessibilityIdentifier("tfcs-context-seam-\(seam.condition.rawValue)")
    }

    private var nodeKind: TodayVitalityNodeKind {
        switch seam.condition {
        case .offlineLocalTruth: .current
        case .staleExternalContext: .external
        case .conflictTransfer: .interrupted
        }
    }

    private var titleColor: Color {
        seam.condition == .conflictTransfer ? palette.interruptedState : palette.labelPrimary
    }
}

struct TodayVitalityUndoReviewView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    let content: TodayFlagshipCalibrationContent
    let onUndo: () -> Void
    let onKeep: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(content.supporting.inverse.title)
                            .font(TodayVitalityTypographyRole.objectIdentity.font)
                        Text(content.primaryStep.title)
                            .font(TodayVitalityTypographyRole.relationship.font)
                            .foregroundStyle(palette.labelSecondary)
                            .accessibilityIdentifier("r13-undo-step-identity")
                    }

                    HStack(alignment: .top, spacing: 10) {
                        TodayVitalityNode(kind: .settled, palette: palette)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Right now")
                                .font(TodayVitalityTypographyRole.relationship.font)
                                .foregroundStyle(palette.settledState)
                            Text(content.primaryStep.stillCountsProposal.settledTruth)
                                .font(TodayVitalityTypographyRole.stateTruth.font)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.vertical, 12)
                    .overlay(alignment: .leading) {
                        Rectangle()
                            .fill(palette.settledState)
                            .frame(width: palette.separatorStrokeWidth)
                    }
                    .accessibilityIdentifier("r13-undo-current-truth")

                    VStack(alignment: .leading, spacing: 6) {
                        Text("What will change")
                            .font(TodayVitalityTypographyRole.relationship.font)
                        Text("This Step will reopen with its earlier status: \(content.primaryStep.currentAcceptedTruth)")
                            .font(TodayVitalityTypographyRole.stateTruth.font)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .accessibilityIdentifier("r13-undo-effect")

                    Label("Your local history will remain available.", systemImage: "clock.arrow.circlepath")
                        .font(TodayVitalityTypographyRole.metadata.font)
                        .foregroundStyle(palette.labelSecondary)
                        .accessibilityIdentifier("r13-undo-history-preserved")

                    Button("Keep", action: onKeep)
                        .buttonStyle(TodayVitalityActionStyle(role: .secondary, palette: palette))
                        .accessibilityIdentifier("r13-undo-keep")

                    Button("Undo", action: onUndo)
                        .buttonStyle(TodayVitalityActionStyle(role: .commitment, palette: palette))
                        .accessibilityIdentifier("r13-undo-commit")
                }
                .frame(maxWidth: 560, alignment: .leading)
                .padding(24)
            }
            .background(palette.canvas.ignoresSafeArea())
            .foregroundStyle(palette.labelPrimary)
            .navigationTitle("Review Undo")
            .todayFlagshipInlineNavigationTitle()
        }
        .accessibilityIdentifier("r13-undo-review")
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
