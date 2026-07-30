import SwiftUI

enum TimeNativeCalibrationPalette {
    static let background = Color(red: 0.035, green: 0.04, blue: 0.055)
    static let plane = Color(red: 0.075, green: 0.08, blue: 0.105)
    static let raised = Color(red: 0.115, green: 0.12, blue: 0.15)
    static let accepted = Color(red: 0.17, green: 0.18, blue: 0.22)
    static let accent = Color(red: 0.50, green: 0.43, blue: 0.96)
    static let protected = Color(red: 0.20, green: 0.16, blue: 0.29)
    static let external = Color(red: 0.12, green: 0.16, blue: 0.20)
    static let proposal = Color(red: 0.64, green: 0.58, blue: 0.98)
    static let now = Color(red: 0.98, green: 0.35, blue: 0.28)
    static let rule = Color.white.opacity(0.16)
    static let secondary = Color.white.opacity(0.68)
}

struct TimeNativeCalibrationSectionLabel: View {
    let title: String
    let detail: String?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.headline)
            Spacer(minLength: 12)
            if let detail {
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(TimeNativeCalibrationPalette.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

struct TimeNativeCalibrationTruthLabel: View {
    let truth: TimeNativeCalibrationTruth

    var body: some View {
        Label(truth.stateLabel, systemImage: symbolName)
            .font(.caption.weight(.semibold))
            .foregroundStyle(foreground)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(background, in: Capsule())
            .overlay {
                if truth == .proposedPlacement {
                    Capsule()
                        .stroke(
                            foreground,
                            style: StrokeStyle(lineWidth: 1, dash: [4, 3])
                        )
                }
            }
    }

    private var symbolName: String {
        switch truth {
        case .acceptedFixed:
            "pin.fill"
        case .acceptedProtected:
            "lock.fill"
        case .externalObservation:
            "arrow.down.left.circle"
        case .proposedPlacement:
            "circle.dashed"
        case .openCapacity:
            "arrow.right"
        }
    }

    private var foreground: Color {
        switch truth {
        case .acceptedFixed, .acceptedProtected:
            .white
        case .externalObservation:
            .cyan.opacity(0.9)
        case .proposedPlacement:
            TimeNativeCalibrationPalette.proposal
        case .openCapacity:
            TimeNativeCalibrationPalette.secondary
        }
    }

    private var background: Color {
        switch truth {
        case .acceptedFixed:
            TimeNativeCalibrationPalette.accepted
        case .acceptedProtected:
            TimeNativeCalibrationPalette.protected
        case .externalObservation:
            TimeNativeCalibrationPalette.external
        case .proposedPlacement, .openCapacity:
            .clear
        }
    }
}

extension View {
    @ViewBuilder
    func timeNativeCalibrationHideRootNavigationBar() -> some View {
        #if os(iOS)
        toolbar(.hidden, for: .navigationBar)
        #else
        self
        #endif
    }

    @ViewBuilder
    func timeNativeCalibrationNavigationTitleDisplayMode() -> some View {
        #if os(iOS)
        navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }

    @ViewBuilder
    func timeNativeCalibrationSheetPresentation() -> some View {
        #if os(iOS)
        presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        #else
        frame(minWidth: 420, minHeight: 460)
        #endif
    }
}
