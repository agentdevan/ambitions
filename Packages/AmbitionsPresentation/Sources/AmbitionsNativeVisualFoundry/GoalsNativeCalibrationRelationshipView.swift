import SwiftUI

public struct GoalsNativeCalibrationRelationshipPresentation: Equatable, Sendable {
    public let primaryGoalID: String
    public let primaryGoalTitle: String
    public let primaryLifeAreaTitle: String
    public let relatedGoalID: String
    public let relatedGoalTitle: String
    public let relatedLifeAreaTitle: String
    public let meaning: String
    public let practicalConsequence: String
    public let ownershipStatement: String

    public init(content: GoalsNativeCalibrationContent) {
        let relationship = content.relationship
        primaryGoalID = relationship.primaryGoalID
        primaryGoalTitle = relationship.primaryGoalTitle
        primaryLifeAreaTitle = relationship.ownerLifeAreaTitle
        relatedGoalID = relationship.relatedGoalID
        relatedGoalTitle = relationship.relatedGoalTitle
        relatedLifeAreaTitle = relationship.relatedLifeAreaTitle
        meaning = relationship.meaning
        practicalConsequence = relationship.practicalConsequence
        ownershipStatement = "\(relationship.ownerLifeAreaTitle) owns this setup decision."
    }
}

struct GoalsNativeCalibrationRelationshipView: View {
    let content: GoalsNativeCalibrationContent
    let palette: GoalsNativeCalibrationPalette

    private var presentation: GoalsNativeCalibrationRelationshipPresentation {
        GoalsNativeCalibrationRelationshipPresentation(content: content)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                goalContinuity
                meaning
                consequence
                ownership
            }
            .frame(maxWidth: 560, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 18)
            .padding(.bottom, 36)
        }
        .background(palette.canvas.ignoresSafeArea())
        .foregroundStyle(palette.primaryInk)
        .goalsNativeCalibrationDepthNavigation(title: "Relationship")
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("gnc-relationship")
    }

    private var goalContinuity: some View {
        VStack(alignment: .leading, spacing: 0) {
            goalIdentity(
                title: presentation.primaryGoalTitle,
                owner: presentation.primaryLifeAreaTitle,
                titleIdentifier: "gnc-relationship-primary-goal",
                ownerIdentifier: "gnc-relationship-primary-owner",
                markerKind: .selectedGoal
            )

            Rectangle()
                .fill(palette.separator)
                .frame(width: palette.markerWidth, height: 34)
                .padding(.leading, 13)

            goalIdentity(
                title: presentation.relatedGoalTitle,
                owner: presentation.relatedLifeAreaTitle,
                titleIdentifier: "gnc-relationship-related-goal",
                ownerIdentifier: "gnc-relationship-related-owner",
                markerKind: .lens
            )
        }
    }

    private var meaning: some View {
        GoalsNativeCalibrationOpenRelief(palette: palette) {
            VStack(alignment: .leading, spacing: 6) {
                Text("What connects them")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.accent)
                Text(presentation.meaning)
                    .font(GoalsNativeCalibrationTypographyRole.truth.font)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("gnc-relationship-meaning")
            }
        }
    }

    private var consequence: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Practical consequence")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.secondaryInk)
            Text(presentation.practicalConsequence)
                .font(GoalsNativeCalibrationTypographyRole.relationship.font)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("gnc-relationship-consequence")
        }
    }

    private var ownership: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "house")
                .foregroundStyle(palette.accent)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                Text("Decision owner")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(palette.tertiaryInk)
                Text(presentation.ownershipStatement)
                    .font(.body.weight(.medium))
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("gnc-relationship-ownership")
            }
        }
        .frame(minHeight: 44)
    }

    private func goalIdentity(
        title: String,
        owner: String,
        titleIdentifier: String,
        ownerIdentifier: String,
        markerKind: GoalsNativeCalibrationMarkerKind
    ) -> some View {
        HStack(alignment: .top, spacing: 12) {
            GoalsNativeCalibrationMarker(kind: markerKind, palette: palette)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(GoalsNativeCalibrationTypographyRole.objectIdentity.font)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .accessibilityAddTraits(titleIdentifier == "gnc-relationship-primary-goal" ? .isHeader : [])
                    .accessibilityIdentifier(titleIdentifier)
                Text(owner)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(palette.secondaryInk)
                    .accessibilityIdentifier(ownerIdentifier)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, minHeight: 54, alignment: .leading)
    }
}
