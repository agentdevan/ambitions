import SwiftUI

struct GoalsNativeCalibrationLifeAreaView: View {
    let content: GoalsNativeCalibrationContent
    let lifeAreaID: String
    let palette: GoalsNativeCalibrationPalette

    private var lifeArea: GoalsNativeCalibrationLifeArea? {
        content.lifeArea(id: lifeAreaID)
    }

    private var presentation: GoalsNativeCalibrationHomePresentation {
        GoalsNativeCalibrationHomePresentation(content: content, lifeAreaID: lifeAreaID)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                owner
                    .padding(.bottom, 14)

                ForEach(Array(presentation.goals.enumerated()), id: \.element.id) { index, goal in
                    if goal.interactionRole == .opensFocusedGoal {
                        NavigationLink(value: GoalsNativeCalibrationRoute.focusedGoal(id: goal.id)) {
                            GoalsNativeCalibrationGoalPassage(
                                goal: goal,
                                palette: palette
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(goal.title)
                        .accessibilityValue(
                            "Selected Goal. \(goal.acceptedTruth). "
                                + "\(goal.proofFoundation.count) recorded support moments. "
                                + "Current movement, \(goal.currentMovement ?? "")"
                        )
                        .accessibilityHint("Opens the focused Goal")
                        .accessibilityIdentifier("gnc-home-goal-\(goal.id)")
                    } else {
                        GoalsNativeCalibrationGoalPassage(
                            goal: goal,
                            palette: palette
                        )
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(goal.title)
                        .accessibilityValue(goal.acceptedTruth)
                        .accessibilityIdentifier("gnc-home-goal-\(goal.id)")
                    }

                    if index < presentation.goals.count - 1 {
                        Rectangle()
                            .fill(palette.separator)
                            .frame(height: 1)
                            .padding(.leading, 38)
                    }
                }
            }
            .frame(maxWidth: 560, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 56)
        }
        .background(palette.canvas.ignoresSafeArea())
        .foregroundStyle(palette.primaryInk)
        .goalsNativeCalibrationDepthNavigation(title: lifeArea?.title ?? "Life Area")
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(
            lifeAreaID == content.primaryGoal.lifeAreaID
                ? "gnc-home-life-area"
                : "gnc-life-area-detail-\(lifeAreaID)"
        )
    }

    private var owner: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(lifeArea?.title ?? "Life Area")
                .font(.title.weight(.semibold))
                .accessibilityAddTraits(.isHeader)
            Text(lifeArea?.currentTruth ?? "")
                .font(.body)
                .foregroundStyle(palette.secondaryInk)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct GoalsNativeCalibrationGoalPassage: View {
    let goal: GoalsNativeCalibrationCompactGoalPresentation
    let palette: GoalsNativeCalibrationPalette

    private var isSelected: Bool {
        goal.interactionRole == .opensFocusedGoal
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            GoalsNativeCalibrationPursuitAnchor(
                goalID: goal.id,
                resolution: isSelected ? .selected : .compact,
                palette: palette
            )
            .padding(.top, 4)

            VStack(alignment: .leading, spacing: isSelected ? 12 : 9) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(goal.title)
                        .font(isSelected ? .title3.weight(.bold) : .headline.weight(.semibold))
                        .foregroundStyle(palette.primaryInk)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 8)
                    if isSelected {
                        Image(systemName: "chevron.forward")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(palette.tertiaryInk)
                            .accessibilityHidden(true)
                    }
                }

                Text(goal.acceptedTruth)
                    .font(isSelected ? .body.weight(.medium) : .body)
                    .foregroundStyle(isSelected ? palette.primaryInk : palette.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)

                acceptedFoundation

                if let movement = goal.currentMovement {
                    HStack(alignment: .top, spacing: 10) {
                        Capsule()
                            .fill(palette.accent)
                            .frame(width: 5, height: 38)
                            .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Current movement")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(palette.secondaryInk)
                            Text(movement)
                                .font(.headline)
                                .foregroundStyle(palette.primaryInk)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: isSelected ? 218 : 142, alignment: .leading)
        .padding(.vertical, 16)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var acceptedFoundation: some View {
        if goal.proofFoundation.isEmpty {
            HStack(spacing: 5) {
                ForEach([20.0, 13.0], id: \.self) { width in
                    Capsule()
                        .fill(palette.acceptedFoundation)
                        .frame(width: width, height: 4)
                }
                Text("Accepted truth")
                    .font(.subheadline)
                    .foregroundStyle(palette.tertiaryInk)
            }
        } else {
            HStack(alignment: .center, spacing: 10) {
                GoalsNativeCalibrationProofFoundation(
                    moments: goal.proofFoundation,
                    palette: palette,
                    expanded: false
                )
                Text("\(goal.proofFoundation.count) recorded moments support this truth")
                    .font(.subheadline)
                    .foregroundStyle(palette.secondaryInk)
            }
        }
    }
}
