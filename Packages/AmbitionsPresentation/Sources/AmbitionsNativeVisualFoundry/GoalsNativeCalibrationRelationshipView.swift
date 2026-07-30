import SwiftUI

public struct GoalsNativeCalibrationRelationshipPresentation: Equatable, Sendable {
    public let relationshipID: String
    public let primaryGoalID: String
    public let primaryGoalTitle: String
    public let primaryLifeAreaTitle: String
    public let relatedGoalID: String
    public let relatedGoalTitle: String
    public let relatedLifeAreaTitle: String
    public let meaning: String
    public let practicalConsequence: String
    public let consequence: String
    public let protectedBoundary: String
    public let ownershipStatement: String
    public let accessibilityReadingOrder: [String]
    public let isInspectionOnly: Bool

    public init(content: GoalsNativeCalibrationContent) {
        let relationship = content.relationship
        relationshipID = relationship.id
        primaryGoalID = relationship.primaryGoalID
        primaryGoalTitle = relationship.primaryGoalTitle
        primaryLifeAreaTitle = relationship.ownerLifeAreaTitle
        relatedGoalID = relationship.relatedGoalID
        relatedGoalTitle = relationship.relatedGoalTitle
        relatedLifeAreaTitle = relationship.relatedLifeAreaTitle
        meaning = relationship.meaning
        practicalConsequence = relationship.practicalConsequence
        consequence = relationship.consequence
        protectedBoundary = relationship.protectedBoundary
        ownershipStatement = "\(relationship.ownerLifeAreaTitle) owns this setup decision."
        accessibilityReadingOrder = [
            relationship.primaryGoalTitle,
            relationship.consequence,
            relationship.protectedBoundary,
            relationship.relatedGoalTitle,
            "\(relationship.ownerLifeAreaTitle) and \(relationship.relatedLifeAreaTitle)"
        ]
        isInspectionOnly = true
    }
}

struct GoalsNativeCalibrationRelationshipView: View {
    @AccessibilityFocusState private var primaryGoalFocused: Bool

    let content: GoalsNativeCalibrationContent
    let palette: GoalsNativeCalibrationPalette

    private var presentation: GoalsNativeCalibrationRelationshipPresentation {
        GoalsNativeCalibrationRelationshipPresentation(content: content)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                primaryGoal
                    .accessibilitySortPriority(6)
                practicalConsequence
                    .accessibilitySortPriority(5)
                protectedBoundary
                    .accessibilitySortPriority(4)
                relatedGoal
                    .accessibilitySortPriority(3)
                ownership
                    .accessibilitySortPriority(2)
            }
            .frame(maxWidth: 560, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 42)
        }
        .background(palette.canvas.ignoresSafeArea())
        .foregroundStyle(palette.primaryInk)
        .goalsNativeCalibrationDepthNavigation(title: "Relationship")
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("gnc-r03-relationship")
        .onAppear { primaryGoalFocused = true }
    }

    private var primaryGoal: some View {
        HStack(alignment: .top, spacing: 14) {
            GoalsNativeCalibrationPursuitAnchor(
                goalID: presentation.primaryGoalID,
                resolution: .focused,
                palette: palette
            )
            .padding(.top, 3)

            VStack(alignment: .leading, spacing: 5) {
                Text(presentation.primaryGoalTitle)
                    .font(GoalsNativeCalibrationTypographyRole.objectIdentity.font)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("gnc-relationship-primary-goal")
        .accessibilityFocused($primaryGoalFocused)
                Text(presentation.primaryLifeAreaTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.secondaryInk)
                    .accessibilityIdentifier("gnc-relationship-primary-owner")
            }
        }
        .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
        .accessibilityElement(children: .contain)
    }

    private var practicalConsequence: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("What changes for you")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.secondaryInk)
            Text(presentation.consequence)
                .font(.title3.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 10)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("gnc-r03-relationship-consequence")
    }

    private var protectedBoundary: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 5) {
                Capsule()
                    .fill(palette.protectedBoundary)
                    .frame(width: max(3, palette.markerWidth + 1), height: 30)
                Capsule()
                    .fill(palette.primaryInk.opacity(0.48))
                    .frame(width: max(3, palette.markerWidth + 1))
            }
            .frame(width: 10)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 7) {
                Text("Protected boundary")
                    .font(.subheadline.weight(.semibold))
                Text(presentation.protectedBoundary)
                    .font(GoalsNativeCalibrationTypographyRole.relationship.font)
                    .foregroundStyle(palette.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 14)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(palette.separator)
                .frame(height: palette.markerWidth)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Protected boundary. \(presentation.protectedBoundary)")
        .accessibilityIdentifier("gnc-r03-relationship-boundary")
    }

    private var relatedGoal: some View {
        HStack(alignment: .top, spacing: 14) {
            GoalsNativeCalibrationPursuitAnchor(
                goalID: presentation.relatedGoalID,
                resolution: .compact,
                palette: palette
            )
            .padding(.top, 3)

            VStack(alignment: .leading, spacing: 5) {
                Text("Related pursuit")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.secondaryInk)
                Text(presentation.relatedGoalTitle)
                    .font(.title3.weight(.semibold))
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("gnc-relationship-related-goal")
                Text(presentation.relatedLifeAreaTitle)
                    .font(.subheadline)
                    .foregroundStyle(palette.secondaryInk)
                    .accessibilityIdentifier("gnc-relationship-related-owner")
            }
        }
        .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
        .accessibilityElement(children: .contain)
    }

    private var ownership: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Life Area ownership")
                .font(.caption.weight(.semibold))
                .foregroundStyle(palette.tertiaryInk)
            Text("\(presentation.primaryLifeAreaTitle) · \(presentation.relatedLifeAreaTitle)")
                .font(.subheadline.weight(.semibold))
        }
        .foregroundStyle(palette.secondaryInk)
        .frame(minHeight: 44)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Life Areas. \(presentation.primaryLifeAreaTitle) and \(presentation.relatedLifeAreaTitle)")
        .accessibilityIdentifier("gnc-relationship-ownership")
    }
}
