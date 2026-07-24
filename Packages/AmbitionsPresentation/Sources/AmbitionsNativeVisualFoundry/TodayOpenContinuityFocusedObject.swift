import SwiftUI

struct TodayOpenContinuityFocusedObject: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @AccessibilityFocusState private var isIdentityFocused: Bool
    @AccessibilityFocusState private var isRecoveredProgressFocused: Bool

    let content: TodayFlagshipCalibrationContent
    let acceptedTruth: String
    let palette: TodayFlagshipPalette
    let shouldFocusIdentity: Bool
    let recoveredProgress: String?
    let shouldFocusRecoveredProgress: Bool
    let isOutcomeEnabled: Bool
    let onSelectStillCounts: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    objectIdentity
                        .accessibilityIdentifier("tfcs-focused-identity")

                    parentPursuit
                        .accessibilityIdentifier("tfcs-focused-parent-pursuit")

                    if let recoveredProgress {
                        recoveredContinuity(recoveredProgress)
                            .accessibilityIdentifier("tfcs-recovered-progress")
                    }

                    currentTruth
                        .accessibilityIdentifier("tfcs-focused-current-truth")

                    relationship(
                        title: content.interfaceCopy.whyItFitsTitle,
                        value: content.primaryStep.whyItFitsNow,
                        symbol: "scope",
                        kind: .current
                    )
                    .accessibilityIdentifier("tfcs-focused-why-now")

                    relationship(
                        title: content.interfaceCopy.consequenceTitle,
                        value: content.primaryStep.materialConsequence,
                        symbol: "shield",
                        kind: .protected
                    )
                    .accessibilityIdentifier("tfcs-focused-protected-consequence")

                    relationship(
                        title: content.primaryStep.temporalContext.relationship,
                        value: content.primaryStep.temporalContext.exactTime,
                        symbol: "clock",
                        kind: .fixed
                    )
                    .accessibilityIdentifier("tfcs-focused-temporal-anchor")

                    if dynamicTypeSize.isAccessibilitySize {
                        outcomeAction
                    }
                }
                .frame(maxWidth: 560, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 18)
                .padding(.bottom, 28)
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("tfcs-focused-object-field")
            }
            .scrollIndicators(.hidden)

            if dynamicTypeSize.isAccessibilitySize == false {
                outcomeAction
            }
        }
        .background(palette.semanticPlane.ignoresSafeArea())
        .foregroundStyle(palette.primaryInk)
        .onAppear {
            if shouldFocusIdentity {
                isIdentityFocused = true
            }
            if shouldFocusRecoveredProgress {
                isRecoveredProgressFocused = true
            }
        }
        .onChange(of: shouldFocusIdentity) { _, shouldFocus in
            guard shouldFocus else { return }
            isIdentityFocused = true
        }
        .onChange(of: shouldFocusRecoveredProgress) { _, shouldFocus in
            guard shouldFocus else { return }
            isRecoveredProgressFocused = true
        }
    }

    private var objectIdentity: some View {
        HStack(alignment: .top, spacing: 14) {
            TodayOpenContinuitySpine(
                kind: .current,
                palette: palette.openContinuity,
                extendsBefore: false,
                extendsAfter: true
            )
            .frame(width: 22)
            .frame(minHeight: 82)

            VStack(alignment: .leading, spacing: 7) {
                Label(content.interfaceCopy.stepTitle, systemImage: "circle.dashed")
                    .font(TodayOpenContinuityTypographyRole.metadata.font.weight(.semibold))
                    .foregroundStyle(palette.secondaryInk)

                Text(content.primaryStep.title)
                    .font(.title.weight(.semibold))
                    .foregroundStyle(palette.primaryInk)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityFocused($isIdentityFocused)
    }

    private var parentPursuit: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                accessibilityParentPursuit
            } else {
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    parentPursuitLabel
                    parentPursuitTitle
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var accessibilityParentPursuit: some View {
        VStack(alignment: .leading, spacing: 10) {
            parentPursuitLabel
            parentPursuitTitle
                .padding(.leading, 34)
        }
    }

    private var parentPursuitLabel: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Image(systemName: "scope")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.articulationAccent)
                .frame(width: 22)
                .accessibilityHidden(true)

            Text(content.interfaceCopy.partOfRelationshipPrefix)
                .font(TodayOpenContinuityTypographyRole.metadata.font.weight(.semibold))
                .foregroundStyle(palette.tertiaryInk)
        }
    }

    private var parentPursuitTitle: some View {
        Text(content.primaryStep.parentPursuitTitle)
            .font(TodayOpenContinuityTypographyRole.relationship.font.weight(.semibold))
            .foregroundStyle(palette.primaryInk)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var currentTruth: some View {
        HStack(alignment: .top, spacing: 12) {
            TodayOpenContinuitySpine(
                kind: .current,
                palette: palette.openContinuity,
                extendsBefore: false,
                extendsAfter: false
            )
            .frame(width: 22)
            .frame(minHeight: 78)

            VStack(alignment: .leading, spacing: 8) {
                Text(content.interfaceCopy.rightNowTitle)
                    .font(TodayOpenContinuityTypographyRole.state.font.weight(.semibold))
                    .foregroundStyle(palette.secondaryInk)

                Text(acceptedTruth)
                    .font(TodayOpenContinuityTypographyRole.state.font)
                    .foregroundStyle(palette.primaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                UnevenRoundedRectangle(
                    topLeadingRadius: 12,
                    bottomLeadingRadius: 4,
                    bottomTrailingRadius: 12,
                    topTrailingRadius: 4,
                    style: .continuous
                )
                .fill(palette.currentTruthPlane)
            }
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("tfcs-current-truth")
        }
        .accessibilityElement(children: .contain)
    }

    private func recoveredContinuity(_ progress: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            TodayOpenContinuitySpine(
                kind: .current,
                palette: palette.openContinuity,
                extendsBefore: true,
                extendsAfter: true
            )
            .frame(width: 22)
            .frame(minHeight: 64)

            Image(systemName: "arrow.clockwise")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.articulationAccent)
                .frame(width: 18)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(content.interfaceCopy.recoveryTitle)
                    .font(TodayOpenContinuityTypographyRole.metadata.font.weight(.semibold))
                    .foregroundStyle(palette.articulationAccent)

                Text(progress)
                    .font(TodayOpenContinuityTypographyRole.state.font)
                    .foregroundStyle(palette.primaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityFocused($isRecoveredProgressFocused)
    }

    private func relationship(
        title: String,
        value: String,
        symbol: String,
        kind: TodayOpenContinuityNodeKind
    ) -> some View {
        HStack(alignment: .top, spacing: 12) {
            TodayOpenContinuitySpine(
                kind: kind,
                palette: palette.openContinuity,
                extendsBefore: true,
                extendsAfter: true
            )
            .frame(width: 22)
            .frame(minHeight: 62)

            Image(systemName: symbol)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(relationshipTint(for: kind))
                .frame(width: 18)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(TodayOpenContinuityTypographyRole.metadata.font.weight(.semibold))
                    .foregroundStyle(palette.tertiaryInk)

                Text(value)
                    .font(TodayOpenContinuityTypographyRole.relationship.font)
                    .foregroundStyle(palette.primaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }

    private var outcomeAction: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(content.interfaceCopy.stillCountsRationale)
                .font(TodayOpenContinuityTypographyRole.relationship.font)
                .foregroundStyle(palette.secondaryInk)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                onSelectStillCounts()
            } label: {
                Text(content.primaryStep.stillCountsProposal.outcomeTitle)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 44)
            }
            .buttonStyle(TodayOpenContinuityPrimaryActionStyle(palette: palette.openContinuity))
            .disabled(isOutcomeEnabled == false)
            .accessibilityHint(content.interfaceCopy.reviewStillCountsHint)
            .accessibilityIdentifier("tfcs-select-still-counts")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 10)
        .background {
            palette.semanticPlane
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(palette.openContinuity.separator)
                        .frame(height: 1)
                }
        }
    }

    private func relationshipTint(for kind: TodayOpenContinuityNodeKind) -> Color {
        switch kind {
        case .protected:
            palette.settledAccent
        case .fixed:
            palette.articulationAccent
        default:
            palette.secondaryInk
        }
    }
}
