import SwiftUI

public struct YouNativeCalibrationView: View {
    private let fixture: YouNativeCalibrationFixture
    @Binding private var state: YouNativeCalibrationJourneyState

    public init(
        fixture: YouNativeCalibrationFixture,
        state: Binding<YouNativeCalibrationJourneyState>
    ) {
        self.fixture = fixture
        _state = state
    }

    public var body: some View {
        NavigationStack(path: navigationPath) {
            YouNativeCalibrationRoot(
                fixture: fixture,
                state: $state
            )
            .navigationDestination(for: YouNativeCalibrationRoute.self) { route in
                destination(for: route)
            }
        }
    }

    private var navigationPath: Binding<[YouNativeCalibrationRoute]> {
        Binding(
            get: { state.navigationPath },
            set: { state.restoreNavigationPath($0) }
        )
    }

    private var appearanceSelection: Binding<YouNativeCalibrationAppearanceMode> {
        Binding(
            get: { state.previewAppearance },
            set: { _ = state.selectAppearance($0) }
        )
    }

    @ViewBuilder
    private func destination(for route: YouNativeCalibrationRoute) -> some View {
        switch route {
        case .appearance:
            YouNativeCalibrationAppearanceDepth(
                fixture: fixture,
                selection: appearanceSelection
            )
        }
    }
}

private struct YouNativeCalibrationRoot: View {
    let fixture: YouNativeCalibrationFixture
    @Binding var state: YouNativeCalibrationJourneyState

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @AccessibilityFocusState private var focusedDomainID: YouNativeCalibrationDomainID?

    private var palette: YouNativeCalibrationPalette {
        YouNativeCalibrationPalette(colorScheme: colorScheme, contrast: contrast)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                crown
                ForEach(fixture.domains) { domain in
                    domainPassage(domain)
                }
            }
        }
        .scrollIndicators(.hidden)
        .background(palette.canvas.ignoresSafeArea())
        .foregroundStyle(palette.primary)
        .youNativeCalibrationHideRootNavigationBar()
        .accessibilityIdentifier("ync-d07-root")
        .onChange(of: state.focusAnchor, initial: true) { _, anchor in
            if case let .domain(domainID) = anchor {
                focusedDomainID = domainID
            }
        }
    }

    private var crown: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 7) {
                Image(systemName: "crown.fill")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(palette.secondary)
                    .accessibilityHidden(true)
                Text("Ambitions")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(palette.secondary)
            }

            Text(fixture.title)
                .font(.title.weight(.semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("You")
        .accessibilityAddTraits(.isHeader)
        .accessibilityIdentifier("ync-d07-crown")
    }

    @ViewBuilder
    private func domainPassage(_ domain: YouNativeCalibrationDomain) -> some View {
        if domain.id == .appearance {
            NavigationLink(value: YouNativeCalibrationRoute.appearance) {
                rowContent(domain, showsDisclosure: true)
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(domain.title)
            .accessibilityValue(accessibilityValue(for: domain))
            .accessibilityHint("Opens Appearance controls")
            .accessibilityFocused($focusedDomainID, equals: domain.id)
            .accessibilityIdentifier("ync-d07-domain-\(domain.id.rawValue)")
        } else {
            rowContent(domain, showsDisclosure: false)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(domain.title)
                .accessibilityValue(domain.summary)
                .accessibilityIdentifier("ync-d07-domain-\(domain.id.rawValue)")
        }
    }

    private func rowContent(
        _ domain: YouNativeCalibrationDomain,
        showsDisclosure: Bool
    ) -> some View {
        HStack(alignment: dynamicTypeSize.isAccessibilitySize ? .top : .center, spacing: 14) {
            if dynamicTypeSize.isAccessibilitySize == false {
                Image(systemName: domain.symbolName)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(palette.secondary)
                    .frame(width: 26)
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(domain.title)
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)
                Text(domain.summary)
                    .font(.subheadline)
                    .foregroundStyle(palette.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 12)

            if showsDisclosure {
                Image(systemName: "chevron.forward")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.tertiary)
                    .frame(width: 20, height: 44)
                    .accessibilityHidden(true)
            }
        }
        .frame(
            maxWidth: .infinity,
            minHeight: dynamicTypeSize.isAccessibilitySize ? 116 : 148,
            alignment: .leading
        )
        .padding(.horizontal, 24)
        .contentShape(Rectangle())
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(palette.separator)
                .frame(height: 1)
                .padding(.leading, dynamicTypeSize.isAccessibilitySize ? 0 : 40)
        }
    }

    private func accessibilityValue(for domain: YouNativeCalibrationDomain) -> String {
        guard state.focusAnchor == .domain(domain.id) else { return domain.summary }
        return "\(domain.summary), Return target"
    }
}

private struct YouNativeCalibrationAppearanceDepth: View {
    let fixture: YouNativeCalibrationFixture
    @Binding var selection: YouNativeCalibrationAppearanceMode

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var palette: YouNativeCalibrationPalette {
        YouNativeCalibrationPalette(colorScheme: colorScheme, contrast: contrast)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                currentTruth
                supportedControls
                accentChoice
                specimen
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
        .scrollIndicators(.hidden)
        .background(palette.canvas.ignoresSafeArea())
        .foregroundStyle(palette.primary)
        .navigationTitle("Appearance")
        .youNativeCalibrationInlineNavigationTitle()
        .accessibilityIdentifier("ync-d07-appearance-depth")
    }

    private var currentTruth: some View {
        VStack(alignment: .leading, spacing: 10) {
            phaseLabel("Current truth")
            HStack(alignment: .firstTextBaseline) {
                Text(selection.title)
                    .font(.title2.weight(.semibold))
                Spacer(minLength: 16)
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(palette.accent)
                    .accessibilityHidden(true)
            }
            Text(systemExplanation)
                .font(.body)
                .foregroundStyle(palette.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.bottom, 22)
        .overlay(alignment: .bottom) {
            Rectangle().fill(palette.separator).frame(height: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("ync-d07-appearance-current")
    }

    private var supportedControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            phaseLabel("Supported controls")
            if dynamicTypeSize.isAccessibilitySize {
                appearancePicker.pickerStyle(.inline)
            } else {
                appearancePicker.pickerStyle(.segmented)
            }
        }
        .accessibilityIdentifier("ync-d07-appearance-controls")
    }

    private var appearancePicker: some View {
        Picker("Appearance", selection: $selection) {
            ForEach(fixture.appearance.availableModes) { mode in
                Text(mode.title).tag(mode)
            }
        }
        .frame(minHeight: 44)
        .accessibilityIdentifier("ync-d07-appearance-mode-picker")
    }

    private var accentChoice: some View {
        VStack(alignment: .leading, spacing: 12) {
            phaseLabel("Action accent")
            HStack(spacing: 14) {
                HStack(spacing: 0) {
                    Circle().fill(palette.accent).frame(width: 18, height: 18)
                    Circle().fill(palette.accentSecondary).frame(width: 18, height: 18)
                }
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(fixture.appearance.provisionalAccent.name)
                        .font(.headline)
                    Text(fixture.appearance.provisionalAccent.posture)
                        .font(.subheadline)
                        .foregroundStyle(palette.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                Image(systemName: "checkmark")
                    .font(.headline)
                    .foregroundStyle(palette.accent)
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Action accent")
        .accessibilityValue(
            "\(fixture.appearance.provisionalAccent.name), selected provisional target; production enum unresolved"
        )
        .accessibilityIdentifier("ync-d07-appearance-accent")
    }

    private var specimen: some View {
        VStack(alignment: .leading, spacing: 14) {
            phaseLabel("Controlled specimen")
            Text("A clear next action")
                .font(.title3.weight(.semibold))
            Text("Hierarchy, selection, and contrast remain legible without changing semantic state.")
                .font(.body)
                .foregroundStyle(palette.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Text("Review")
                .font(.headline)
                .foregroundStyle(palette.accent)
                .frame(minHeight: 44, alignment: .leading)
        }
        .padding(.vertical, 22)
        .overlay(alignment: .top) {
            Rectangle().fill(palette.separator).frame(height: 1)
        }
        .overlay(alignment: .bottom) {
            Rectangle().fill(palette.separator).frame(height: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Controlled Ambitions appearance specimen")
        .accessibilityIdentifier("ync-d07-appearance-specimen")
    }

    private func phaseLabel(_ title: String) -> some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(palette.secondary)
    }

    private var systemExplanation: String {
        switch selection {
        case .system:
            "System follows the iPhone appearance. This fixture does not persist a change."
        case .light:
            "Light is a fixture-only preview. Production persistence is not proven here."
        case .dark:
            "Dark is a fixture-only preview. Production persistence is not proven here."
        }
    }
}
