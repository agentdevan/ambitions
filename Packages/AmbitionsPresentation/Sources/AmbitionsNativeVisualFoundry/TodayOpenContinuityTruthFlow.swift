import SwiftUI

struct TodayOpenContinuityTruthComparison: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let currentLabel: String
    let currentTruth: String
    let proposedLabel: String
    let proposedTruth: String
    let palette: TodayFlagshipPalette
    let isSaving: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            truthRegion(
                kind: .current,
                label: currentLabel,
                truth: currentTruth,
                identifier: "tfcs-review-current-truth"
            )

            transitionSeam

            truthRegion(
                kind: .proposed,
                label: proposedLabel,
                truth: proposedTruth,
                identifier: "tfcs-proposed-truth"
            )
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tfcs-review-comparison")
    }

    private func truthRegion(
        kind: TodayOpenContinuityNodeKind,
        label: String,
        truth: String,
        identifier: String
    ) -> some View {
        HStack(alignment: .top, spacing: 12) {
            TodayOpenContinuitySpine(
                kind: kind,
                palette: palette.openContinuity,
                extendsBefore: false,
                extendsAfter: false
            )
            .frame(width: 22)
            .frame(minHeight: 72)

            VStack(alignment: .leading, spacing: 7) {
                Text(label)
                    .font(TodayOpenContinuityTypographyRole.state.font.weight(.semibold))
                    .foregroundStyle(
                        kind == .proposed ? palette.articulationAccent : palette.secondaryInk
                    )

                Text(truth)
                    .font(
                        TodayOpenContinuityTypographyRole.state.font.weight(
                            kind == .proposed ? .semibold : .regular
                        )
                    )
                    .foregroundStyle(palette.primaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 13)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                reliefShape
                    .fill(kind == .proposed ? palette.proposedTruthPlane : palette.currentTruthPlane)
            }
            .overlay {
                if differentiateWithoutColor || palette.openContinuity.contrast == .increased {
                    reliefShape.stroke(
                        kind == .proposed ? palette.articulationAccent : palette.secondaryInk,
                        style: StrokeStyle(
                            lineWidth: kind == .proposed ? 2 : 1.5,
                            dash: kind == .proposed ? [5, 4] : []
                        )
                    )
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label). \(truth)")
        .accessibilityIdentifier(identifier)
    }

    private var transitionSeam: some View {
        HStack(spacing: 12) {
            TodayOpenContinuitySpine(
                kind: isSaving ? .saving : .proposed,
                palette: palette.openContinuity
            )
            .frame(width: 22, height: 34)

            HStack(spacing: 6) {
                Capsule(style: .continuous)
                    .fill(palette.divider)
                    .frame(height: 1)
                Circle()
                    .strokeBorder(palette.articulationAccent, lineWidth: 1.5)
                    .frame(width: 8, height: 8)
                Capsule(style: .continuous)
                    .fill(palette.divider)
                    .frame(height: 1)
            }
            .accessibilityHidden(true)
        }
        .animation(motionPolicy.stateAnimation, value: isSaving)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(currentLabel). \(proposedLabel).")
        .accessibilityIdentifier("tfcs-review-transition-seam")
    }

    private var motionPolicy: TodayOpenContinuityMotionPolicy {
        TodayOpenContinuityMotionPolicy(reduceMotion: reduceMotion)
    }

    private var reliefShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: 12,
            bottomLeadingRadius: 4,
            bottomTrailingRadius: 12,
            topTrailingRadius: 4,
            style: .continuous
        )
    }
}

struct TodayOpenContinuityCommitBar: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let cancelTitle: String
    let commitTitle: String
    let savingTitle: String
    let savingBody: String
    let cancelHint: String
    let commitHint: String
    let palette: TodayFlagshipPalette
    let isSaving: Bool
    let onCancel: () -> Void
    let onCommit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if isSaving {
                TodayOpenContinuitySavingSeam(
                    title: savingTitle,
                    message: savingBody,
                    palette: palette
                )
            }

            if dynamicTypeSize.isAccessibilitySize {
                VStack(spacing: 10) {
                    cancelAction
                    commitAction
                }
            } else {
                HStack(spacing: 12) {
                    cancelAction
                        .frame(maxWidth: 126)
                    commitAction
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(palette.semanticPlane)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(palette.divider)
                .frame(height: 1)
                .accessibilityHidden(true)
        }
    }

    private var cancelAction: some View {
        Button(action: onCancel) {
            Text(cancelTitle)
                .font(TodayOpenContinuityTypographyRole.action.font)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 44)
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.roundedRectangle(radius: 8))
        // AMBitionsAllowWeakPattern(reason: "Native control blocks cancellation during active settlement commitment")
        .disabled(isSaving)
        .accessibilityHint(cancelHint)
        .accessibilityInputLabels([cancelTitle])
        .accessibilityIdentifier("tfcs-cancel-review")
    }

    private var commitAction: some View {
        Button(action: onCommit) {
            Text(commitTitle)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 44)
        }
        .buttonStyle(TodayOpenContinuityPrimaryActionStyle(palette: palette.openContinuity))
        // AMBitionsAllowWeakPattern(reason: "Native control blocks repeated settlement commitment while saving")
        .disabled(isSaving)
        .accessibilityHint(commitHint)
        .accessibilityInputLabels([commitTitle])
        .accessibilityIdentifier("tfcs-commit-still-counts")
    }
}

struct TodayOpenContinuitySavingSeam: View {
    let title: String
    let message: String
    let palette: TodayFlagshipPalette

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            TodayOpenContinuitySpine(
                kind: .saving,
                palette: palette.openContinuity,
                extendsBefore: false,
                extendsAfter: false
            )
            .frame(width: 22, height: 44)

            ProgressView()
                .controlSize(.small)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(TodayOpenContinuityTypographyRole.state.font.weight(.semibold))
                Text(message)
                    .font(TodayOpenContinuityTypographyRole.metadata.font)
                    .foregroundStyle(palette.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(message)")
        .accessibilityIdentifier("tfcs-saving-posture")
    }
}

struct TodayOpenContinuitySettlementView: View {
    @AccessibilityFocusState private var isSettledTruthFocused: Bool

    let content: TodayFlagshipCalibrationContent
    let acceptedTruth: String
    let palette: TodayFlagshipPalette
    let shouldFocusTruth: Bool
    let historyDisclosure: Binding<Bool>
    let onReturnToToday: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { viewport in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        settlementIdentity
                            .accessibilityIdentifier("tfcs-settlement-identity")

                        adaptiveSectionGap

                        TodayOpenContinuitySettledTruth(
                            label: content.interfaceCopy.rightNowTitle,
                            truth: acceptedTruth,
                            palette: palette
                        )
                        .accessibilityFocused($isSettledTruthFocused)
                        .accessibilityIdentifier("tfcs-settled-truth")

                        adaptiveSectionGap

                        parentPursuit
                            .accessibilityIdentifier("tfcs-settlement-parent-pursuit")

                        adaptiveSectionGap

                        recordedAcknowledgment
                            .accessibilityIdentifier("tfcs-recorded-acknowledgment")

                        adaptiveSectionGap

                        history
                            .accessibilityIdentifier("tfcs-view-history")
                            .accessibilityValue(
                                historyDisclosure.wrappedValue ? "Expanded" : "Collapsed"
                            )
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 30)
                    .frame(
                        maxWidth: 560,
                        minHeight: viewport.size.height,
                        alignment: .topLeading
                    )
                }
            }

            TodayOpenContinuityReturnBar(
                title: content.interfaceCopy.returnTodayTitle,
                palette: palette,
                action: onReturnToToday
            )
            .accessibilityIdentifier("tfcs-return-to-today")
        }
        .background(palette.semanticPlane.ignoresSafeArea())
        .foregroundStyle(palette.primaryInk)
        .onAppear {
            guard shouldFocusTruth else { return }
            isSettledTruthFocused = true
        }
        .onChange(of: shouldFocusTruth) { _, shouldFocus in
            guard shouldFocus else { return }
            isSettledTruthFocused = true
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tfcs-settlement-field")
    }

    private var adaptiveSectionGap: some View {
        Spacer(minLength: 28)
            .accessibilityHidden(true)
    }

    private var settlementIdentity: some View {
        HStack(alignment: .top, spacing: 14) {
            TodayOpenContinuitySpine(
                kind: .settled,
                palette: palette.openContinuity,
                extendsBefore: false,
                extendsAfter: true
            )
            .frame(width: 22)
            .frame(minHeight: 96)

            VStack(alignment: .leading, spacing: 7) {
                Text(content.interfaceCopy.settlementTitle)
                    .font(TodayOpenContinuityTypographyRole.metadata.font.weight(.semibold))
                    .foregroundStyle(palette.settledAccent)

                Text(content.primaryStep.title)
                    .font(.title.weight(.semibold))
                    .foregroundStyle(palette.primaryInk)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var parentPursuit: some View {
        HStack(alignment: .top, spacing: 12) {
            TodayOpenContinuitySpine(
                kind: .settled,
                palette: palette.openContinuity,
                extendsBefore: true,
                extendsAfter: true
            )
            .frame(width: 22)
            .frame(minHeight: 64)

            Image(systemName: "scope")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.settledAccent)
                .frame(width: 18)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(content.interfaceCopy.settlementRelationshipPrefix)
                    .font(TodayOpenContinuityTypographyRole.metadata.font.weight(.semibold))
                    .foregroundStyle(palette.tertiaryInk)

                Text(content.primaryStep.parentPursuitTitle)
                    .font(TodayOpenContinuityTypographyRole.relationship.font.weight(.semibold))
                    .foregroundStyle(palette.primaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var recordedAcknowledgment: some View {
        HStack(alignment: .center, spacing: 12) {
            TodayOpenContinuitySpine(
                kind: .settled,
                palette: palette.openContinuity,
                extendsBefore: true,
                extendsAfter: true
            )
            .frame(width: 22, height: 58)

            Image(systemName: "clock.arrow.circlepath")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(palette.secondaryInk)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(content.receipt.recordedLabel)
                    .font(TodayOpenContinuityTypographyRole.relationship.font.weight(.semibold))
                    .foregroundStyle(palette.primaryInk)

                Text(content.receipt.receiptSummary)
                    .font(TodayOpenContinuityTypographyRole.metadata.font)
                    .foregroundStyle(palette.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var history: some View {
        HStack(alignment: .top, spacing: 12) {
            TodayOpenContinuitySpine(
                kind: .settled,
                palette: palette.openContinuity,
                extendsBefore: true,
                extendsAfter: false
            )
            .frame(width: 22)
            .frame(minHeight: 60)

            DisclosureGroup(isExpanded: historyDisclosure) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(content.receipt.receiptSummary)
                    Text(content.receipt.historySummary)
                    Text(content.receipt.recordedLabel)
                    Text(
                        "\(content.interfaceCopy.recordIdentifierPrefix): "
                            + content.receipt.id
                    )
                        .font(TodayOpenContinuityTypographyRole.metadata.font.monospaced())
                        .foregroundStyle(palette.tertiaryInk)
                }
                .font(TodayOpenContinuityTypographyRole.relationship.font)
                .foregroundStyle(palette.secondaryInk)
                .padding(.top, 10)
            } label: {
                Text(content.interfaceCopy.viewHistoryTitle)
                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .font(TodayOpenContinuityTypographyRole.action.font)
            .foregroundStyle(palette.primaryInk)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityInputLabels([content.interfaceCopy.viewHistoryTitle])
        }
    }
}

struct TodayOpenContinuitySettledTruth: View {
    let label: String
    let truth: String
    let palette: TodayFlagshipPalette

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            TodayOpenContinuitySpine(
                kind: .settled,
                palette: palette.openContinuity,
                extendsBefore: true,
                extendsAfter: true
            )
            .frame(width: 22)
            .frame(minHeight: 120)

            VStack(alignment: .leading, spacing: 9) {
                Text(label)
                    .font(TodayOpenContinuityTypographyRole.state.font.weight(.semibold))
                    .foregroundStyle(palette.settledAccent)

                Text(truth)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(palette.primaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 17)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                UnevenRoundedRectangle(
                    topLeadingRadius: 14,
                    bottomLeadingRadius: 4,
                    bottomTrailingRadius: 14,
                    topTrailingRadius: 4,
                    style: .continuous
                )
                .fill(palette.currentTruthPlane)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label). \(truth)")
    }
}

struct TodayOpenContinuityReturnBar: View {
    let title: String
    let palette: TodayFlagshipPalette
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: "arrow.uturn.backward")
                .font(TodayOpenContinuityTypographyRole.action.font)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 44)
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.roundedRectangle(radius: 8))
        .controlSize(.large)
        .tint(palette.articulationAccent)
        .accessibilityInputLabels([title])
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(palette.semanticPlane)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(palette.divider)
                .frame(height: 1)
                .accessibilityHidden(true)
        }
    }
}
