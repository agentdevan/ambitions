import SwiftUI

struct GoalsNativeCalibrationRootView: View {
    let content: GoalsNativeCalibrationContent
    @Binding var state: GoalsNativeCalibrationJourneyState
    let palette: GoalsNativeCalibrationPalette
    let usesAdaptiveNavigation: Bool

    @State private var isDockExpanded = false

    var body: some View {
        ZStack(alignment: .trailing) {
            VStack(spacing: 0) {
                crown
                rootContent
            }
            .allowsHitTesting(isDockExpanded == false)
            .accessibilityHidden(isDockExpanded)

            if isDockExpanded && usesAdaptiveNavigation == false {
                palette.canvas.opacity(0.94)
                    .ignoresSafeArea()
                    .onTapGesture { isDockExpanded = false }
                    .accessibilityHidden(true)
            }

            if usesAdaptiveNavigation == false {
                dock
            }
        }
        .background(palette.canvas.ignoresSafeArea())
        .foregroundStyle(palette.primaryInk)
        .goalsNativeCalibrationHideRootNavigationBar()
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("gnc-goals-root")
    }

    private var crown: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 7) {
                Image(systemName: "crown.fill")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(palette.secondaryInk)
                    .accessibilityHidden(true)
                Text("Ambitions")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(palette.secondaryInk)
            }

            Text("Goals")
                .font(.title.weight(.semibold))
                .accessibilityAddTraits(.isHeader)

            Text(content.presentContext)
                .font(.subheadline)
                .foregroundStyle(palette.secondaryInk)
        }
        .frame(maxWidth: 560, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 13)
        .background(palette.canvas)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Goals")
        .accessibilityValue("Ambitions, \(content.presentContext)")
        .accessibilityAddTraits(.isHeader)
        .accessibilityIdentifier("gnc-goals-heading")
    }

    private var rootContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(content.lifeAreas) { area in
                    lifeArea(area)
                }

                if usesAdaptiveNavigation {
                    adaptiveNavigation
                }
            }
            .frame(maxWidth: 560, alignment: .leading)
            .padding(.leading, 24)
            .padding(.trailing, usesAdaptiveNavigation ? 24 : 68)
            .padding(.bottom, 80)
        }
        .contentMargins(.trailing, usesAdaptiveNavigation ? 0 : 52, for: .scrollIndicators)
    }

    @ViewBuilder
    private func lifeArea(_ area: GoalsNativeCalibrationLifeArea) -> some View {
        if state.isLifeAreaExpanded(id: area.id) {
            VStack(alignment: .leading, spacing: 12) {
                Button {
                    _ = state.selectLifeArea(id: area.id)
                } label: {
                    HStack(spacing: 10) {
                        GoalsNativeCalibrationMarker(kind: .lifeArea, palette: palette)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(area.title)
                                .font(.title2.weight(.semibold))
                                .foregroundStyle(palette.primaryInk)
                            Text(area.currentTruth)
                                .font(.subheadline)
                                .foregroundStyle(palette.secondaryInk)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 8)
                        Image(systemName: "chevron.up")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(palette.secondaryInk)
                            .accessibilityHidden(true)
                    }
                    .frame(minHeight: 54)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(area.title)
                .accessibilityValue("Selected Life Area, expanded")
                .accessibilityIdentifier("gnc-life-area-\(area.id)")

                VStack(alignment: .leading, spacing: 0) {
                    ForEach(area.goals) { goal in
                        goalRow(goal)
                    }
                }
            }
            .padding(.bottom, 8)
        } else {
            Button {
                _ = state.selectLifeArea(id: area.id)
            } label: {
                HStack(spacing: 10) {
                    GoalsNativeCalibrationMarker(kind: .lifeArea, palette: palette)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(area.title)
                            .font(.headline)
                            .foregroundStyle(palette.primaryInk)
                        Text(area.currentTruth)
                            .font(.subheadline)
                            .foregroundStyle(palette.secondaryInk)
                            .lineLimit(2)
                    }
                    Spacer(minLength: 8)
                    Image(systemName: "chevron.down")
                        .foregroundStyle(palette.secondaryInk)
                        .accessibilityHidden(true)
                }
                .frame(minHeight: 54)
                .padding(.vertical, 6)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(area.title)
            .accessibilityValue("Compact Life Area")
            .accessibilityIdentifier("gnc-life-area-\(area.id)")
            .overlay(alignment: .bottom) {
                Rectangle().fill(palette.separator).frame(height: 1)
            }
        }
    }

    private func goalRow(_ goal: GoalsNativeCalibrationGoalSummary) -> some View {
        let isSelected = state.isGoalSelected(id: goal.id)

        return VStack(alignment: .leading, spacing: 0) {
            Button {
                _ = state.selectGoal(id: goal.id)
            } label: {
                HStack(alignment: .top, spacing: 10) {
                    GoalsNativeCalibrationMarker(
                        kind: isSelected ? .selectedGoal : .compactGoal,
                        palette: palette
                    )
                    VStack(alignment: .leading, spacing: 4) {
                        Text(goal.title)
                            .font(
                                isSelected
                                    ? GoalsNativeCalibrationTypographyRole.objectIdentity.font
                                    : .body.weight(.medium)
                            )
                            .foregroundStyle(palette.primaryInk)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(goal.acceptedPosture)
                            .font(GoalsNativeCalibrationTypographyRole.metadata.font)
                            .foregroundStyle(palette.secondaryInk)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 8)
                    if isSelected {
                        Text("Selected")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(palette.accent)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
                .padding(.vertical, isSelected ? 12 : 9)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(goal.title)
            .accessibilityValue(isSelected ? "Selected" : goal.acceptedPosture)
            .accessibilityAddTraits(isSelected ? .isSelected : [])
            .accessibilityIdentifier("gnc-goal-\(goal.id)")

            if isSelected && goal.id == content.primaryGoal.id {
                linkedLensRegion
            }

            Rectangle()
                .fill(palette.separator)
                .frame(height: 1)
                .padding(.leading, 38)
        }
    }

    @ViewBuilder
    private var linkedLensRegion: some View {
        if state.isLinkedLensExpanded {
            linkedLens
        } else {
            Button {
                _ = state.openLinkedLens()
            } label: {
                HStack(spacing: 10) {
                    GoalsNativeCalibrationMarker(kind: .lens, palette: palette)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Linked Goal Lens")
                            .font(.headline)
                        Text("See current truth, consequence, and the movement now in focus.")
                            .font(.subheadline)
                            .foregroundStyle(palette.secondaryInk)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 8)
                    Image(systemName: "chevron.down")
                        .accessibilityHidden(true)
                }
                .frame(minHeight: 52)
                .padding(.vertical, 8)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityHint("Reveals the Goal’s current pursuit truth in place")
            .accessibilityIdentifier("gnc-linked-lens-disclosure")
        }
    }

    private var linkedLens: some View {
        GoalsNativeCalibrationOpenRelief(palette: palette) {
            VStack(alignment: .leading, spacing: 13) {
                HStack(spacing: 9) {
                    GoalsNativeCalibrationMarker(kind: .lens, palette: palette)
                    Text("Linked Goal Lens")
                        .font(.headline)
                        .foregroundStyle(palette.accent)
                    Spacer(minLength: 8)
                    Button("Hide") {
                        _ = state.closeLinkedLens()
                    }
                    .font(.subheadline.weight(.medium))
                    .frame(minHeight: 44)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text("Current truth")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(palette.secondaryInk)
                    Text(content.linkedLens.currentTruth)
                        .font(GoalsNativeCalibrationTypographyRole.truth.font)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("gnc-lens-current-truth")
                }

                Text(content.linkedLens.consequence)
                    .font(GoalsNativeCalibrationTypographyRole.relationship.font)
                    .foregroundStyle(palette.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "point.forward.to.point.capsulepath")
                        .foregroundStyle(palette.accent)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Active thread")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(palette.tertiaryInk)
                        Text(content.linkedLens.activeThread)
                            .font(.body.weight(.medium))
                        Text("Next · \(content.linkedLens.nextMovement)")
                            .font(.subheadline)
                            .foregroundStyle(palette.secondaryInk)
                    }
                }

                HStack(spacing: 8) {
                    GoalsNativeCalibrationMarker(kind: .proof, palette: palette)
                    Text(content.linkedLens.proofPosture.joined(separator: " · "))
                        .font(.caption)
                        .foregroundStyle(palette.secondaryInk)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Button {
                    _ = state.openSelectedGoal()
                } label: {
                    ZStack {
                        Text(content.linkedLens.openActionTitle)
                        HStack {
                            Spacer()
                            Image(systemName: "chevron.forward")
                                .accessibilityHidden(true)
                        }
                    }
                }
                .buttonStyle(
                    GoalsNativeCalibrationNavigationButtonStyle(
                        palette: palette,
                        isProminent: true
                    )
                )
                .accessibilityHint("Opens the focused Goal without changing it")
                .accessibilityIdentifier("gnc-open-goal")
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Linked Goal Lens, \(content.primaryGoal.title)")
        .accessibilityIdentifier("gnc-linked-lens-\(content.primaryGoal.id)")
    }

    private var dock: some View {
        VStack(spacing: 0) {
            Spacer()
            Button {
                isDockExpanded.toggle()
            } label: {
                GoalsNativeCalibrationFunctionalChrome(palette: palette) {
                    VStack(spacing: 4) {
                        Image(systemName: "scope")
                            .font(.subheadline.weight(.semibold))
                        Text("Goals")
                            .font(.caption2.weight(.semibold))
                    }
                    .frame(width: 44, height: 56)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isDockExpanded ? "Close navigation" : "Open navigation")
            .accessibilityValue("Goals selected")
            .accessibilityIdentifier("gnc-dock-peek")
            Spacer().frame(height: 128)
        }
        .padding(.trailing, 2)
    }

    private var adaptiveNavigation: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Navigation")
                .font(.headline)
            ForEach(["Today", "Goals", "Time", "You"], id: \.self) { title in
                HStack {
                    Image(systemName: title == "Goals" ? "scope" : "circle")
                    Text(title)
                    Spacer()
                    if title == "Goals" {
                        Text("Selected")
                            .font(.caption.weight(.semibold))
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(Color.clear)
                .contentShape(Rectangle())
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(title)
                .accessibilityValue(title == "Goals" ? "Selected root" : "Root")
                .accessibilityIdentifier("gnc-adaptive-root-\(title.lowercased())")
            }
            Divider()
            ForEach(["Search", "Capture"], id: \.self) { title in
                Text(title)
                    .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
                    .background(Color.clear)
                    .contentShape(Rectangle())
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(title)
                    .accessibilityValue("Global action")
                    .accessibilityIdentifier("gnc-adaptive-global-\(title.lowercased())")
            }
        }
        .padding(14)
        .background(palette.relief)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Adaptive Navigation Passage")
        .accessibilityIdentifier("gnc-adaptive-navigation")
    }
}

private extension View {
    @ViewBuilder
    func goalsNativeCalibrationHideRootNavigationBar() -> some View {
        #if os(iOS)
        toolbar(.hidden, for: .navigationBar)
        #else
        self
        #endif
    }
}
