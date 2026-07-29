import SwiftUI

struct GoalsNativeCalibrationRootView: View {
    let content: GoalsNativeCalibrationContent
    @Binding var state: GoalsNativeCalibrationJourneyState
    let palette: GoalsNativeCalibrationPalette
    let usesAdaptiveNavigation: Bool

    @State private var isDockExpanded = false

    private var presentation: GoalsNativeCalibrationRootPresentation {
        GoalsNativeCalibrationRootPresentation(content: content)
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            VStack(spacing: 0) {
                crown
                lifeAreaIndex
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

            Text("The parts of life you are shaping over time")
                .font(.subheadline)
                .foregroundStyle(palette.secondaryInk)
        }
        .frame(maxWidth: 560, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 12)
        .background(palette.canvas)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Goals")
        .accessibilityValue("Ambitions. The parts of life you are shaping over time")
        .accessibilityAddTraits(.isHeader)
        .accessibilityIdentifier("gnc-goals-heading")
    }

    private var lifeAreaIndex: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(content.lifeAreas.enumerated()), id: \.element.id) { index, area in
                    NavigationLink(value: GoalsNativeCalibrationRoute.lifeArea(id: area.id)) {
                        GoalsNativeCalibrationLifeAreaPassage(
                            area: area,
                            posture: presentation.lifeAreaPostures[index].kind,
                            palette: palette
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(area.title)
                    .accessibilityValue(area.currentTruth)
                    .accessibilityHint("Opens the \(area.title) Life Area")
                    .accessibilityIdentifier("gnc-life-area-\(area.id)")

                }

                if usesAdaptiveNavigation {
                    adaptiveNavigation
                        .padding(.top, 26)
                }
            }
            .frame(maxWidth: 560, alignment: .leading)
            .padding(.leading, 24)
            .padding(.trailing, usesAdaptiveNavigation ? 24 : 68)
            .padding(.bottom, 88)
        }
        .contentMargins(.trailing, usesAdaptiveNavigation ? 0 : 52, for: .scrollIndicators)
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
                    .contentShape(Rectangle())
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(title)
                    .accessibilityValue("Global action")
                    .accessibilityIdentifier("gnc-adaptive-global-\(title.lowercased())")
            }
        }
        .padding(.vertical, 14)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Adaptive Navigation Passage")
        .accessibilityIdentifier("gnc-adaptive-navigation")
    }
}

private struct GoalsNativeCalibrationLifeAreaPassage: View {
    let area: GoalsNativeCalibrationLifeArea
    let posture: GoalsNativeCalibrationLifeAreaPostureKind
    let palette: GoalsNativeCalibrationPalette

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(area.title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(palette.primaryInk)

                Spacer(minLength: 12)

                Image(systemName: "chevron.forward")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.tertiaryInk)
                    .frame(width: 20, height: 44)
                    .accessibilityHidden(true)
            }

            postureBody
        }
        .frame(maxWidth: .infinity, minHeight: 146, alignment: .leading)
        .padding(.vertical, 14)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(palette.separator)
                .frame(height: 1)
        }
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var postureBody: some View {
        switch posture {
        case .activeConstruction:
            HStack(alignment: .bottom, spacing: 18) {
                Text(area.currentTruth)
                    .font(.body.weight(.medium))
                    .foregroundStyle(palette.primaryInk)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 8)
                signal
            }
        case .protectedBalance:
            HStack(alignment: .center, spacing: 16) {
                signal
                Text(area.currentTruth)
                    .font(.body.weight(.medium))
                    .foregroundStyle(palette.primaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
        case .containedWork:
            VStack(alignment: .leading, spacing: 12) {
                Text(area.currentTruth)
                    .font(.body.weight(.medium))
                    .foregroundStyle(palette.primaryInk)
                    .fixedSize(horizontal: false, vertical: true)
                HStack {
                    Spacer()
                    signal
                }
            }
        }
    }

    private var signal: some View {
        GoalsNativeCalibrationLifeAreaPostureSignal(
            lifeAreaID: area.id,
            kind: posture,
            palette: palette
        )
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
