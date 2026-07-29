import SwiftUI

struct GoalsNativeCalibrationLifeAreaView: View {
    let content: GoalsNativeCalibrationContent
    let lifeAreaID: String
    let palette: GoalsNativeCalibrationPalette

    private var lifeArea: GoalsNativeCalibrationLifeArea? {
        content.lifeArea(id: lifeAreaID)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                owner
                    .padding(.bottom, 14)

                ForEach(Array((lifeArea?.goals ?? []).enumerated()), id: \.element.id) { index, goal in
                    if lifeAreaID == content.primaryGoal.lifeAreaID && goal.id == content.primaryGoal.id {
                        NavigationLink(value: GoalsNativeCalibrationRoute.focusedGoal(id: goal.id)) {
                            GoalsNativeCalibrationGoalPassage(
                                goal: goal,
                                truth: content.primaryGoal.currentAcceptedTruth,
                                movement: content.primaryGoal.nextMeaningfulMovement,
                                proofCount: content.linkedLens.proofPosture.count,
                                isSelected: true,
                                palette: palette
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(goal.title)
                        .accessibilityValue("Selected")
                        .accessibilityHint("Opens the focused Goal")
                        .accessibilityIdentifier("gnc-home-goal-\(goal.id)")
                    } else {
                        GoalsNativeCalibrationGoalPassage(
                            goal: goal,
                            truth: goal.acceptedPosture,
                            movement: nil,
                            proofCount: nil,
                            isSelected: false,
                            palette: palette
                        )
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(goal.title)
                        .accessibilityValue(goal.acceptedPosture)
                        .accessibilityIdentifier("gnc-home-goal-\(goal.id)")
                    }

                    if index < (lifeArea?.goals.count ?? 0) - 1 {
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
    let goal: GoalsNativeCalibrationGoalSummary
    let truth: String
    let movement: String?
    let proofCount: Int?
    let isSelected: Bool
    let palette: GoalsNativeCalibrationPalette

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            GoalsNativeCalibrationGoalSeam(
                palette: palette,
                emphasis: isSelected ? .selected : .quiet
            )
            .padding(.top, 4)

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(goal.title)
                        .font(isSelected ? .title3.weight(.semibold) : .headline)
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

                Text(truth)
                    .font(.subheadline)
                    .foregroundStyle(isSelected ? palette.primaryInk : palette.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)

                if let proofCount {
                    Label("Supported by \(proofCount) recorded moments", systemImage: "checkmark.circle")
                        .font(.caption)
                        .foregroundStyle(palette.secondaryInk)
                }

                if let movement {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("Now")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(palette.accent)
                        Text(movement)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(palette.primaryInk)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: isSelected ? 168 : 112, alignment: .leading)
        .padding(.vertical, 16)
        .contentShape(Rectangle())
    }
}
