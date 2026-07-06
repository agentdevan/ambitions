import AmbitionsDesignSystem
import SwiftUI

enum ProductObjectFrameRole: String, CaseIterable, Sendable {
    case rootPrimaryObject
    case detailObject
    case overlayObject
}

struct ProductObjectFrame<Content: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let role: ProductObjectFrameRole
    let state: AmbitionVisualState
    let accent: Color?
    let accessibilityIdentifier: String?
    let content: Content

    init(
        role: ProductObjectFrameRole = .rootPrimaryObject,
        state: AmbitionVisualState = .default,
        accent: Color? = nil,
        accessibilityIdentifier: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.role = role
        self.state = state
        self.accent = accent
        self.accessibilityIdentifier = accessibilityIdentifier
        self.content = content()
    }

    var body: some View {
        framedContent
            .accessibilityElement(children: .contain)
            .productObjectAccessibilityIdentifier(accessibilityIdentifier)
    }

    @ViewBuilder
    private var framedContent: some View {
        switch role {
        case .rootPrimaryObject:
            ZStack(alignment: .topLeading) {
                AmbitionsIOS26SemanticTokens.Graphite.base
                content
            }
            .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: reduceMotion)
        case .detailObject:
            content
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(AmbitionsIOS26SemanticTokens.Fill.quaternaryDark)
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(stateAccent.opacity(state == .selected ? 0.82 : 0.42))
                        .frame(height: state == .selected ? 1.5 : 1)
                        .accessibilityHidden(true)
                }
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(AmbitionsIOS26SemanticTokens.Separator.darkNonOpaque.opacity(0.72))
                        .frame(height: 1)
                        .accessibilityHidden(true)
                }
        case .overlayObject:
            content
                .padding(.vertical, 18)
                .padding(.horizontal, 18)
                .background(
                    LinearGradient(
                        colors: [
                            AmbitionsIOS26SemanticTokens.Graphite.elevated.opacity(0.92),
                            AmbitionsIOS26SemanticTokens.Graphite.secondary.opacity(0.58),
                            AmbitionsIOS26SemanticTokens.Graphite.base.opacity(0.18)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(AmbitionsIOS26SemanticTokens.Separator.darkNonOpaque)
                        .frame(height: 1)
                        .accessibilityHidden(true)
                }
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill((accent ?? AmbitionsIOS26SemanticTokens.Accent.yellowDark).opacity(state == .selected ? 0.72 : 0.42))
                        .frame(width: state == .selected ? 3 : 2)
                        .accessibilityHidden(true)
                }
        }
    }

    private var stateAccent: Color {
        accent ?? {
            switch state {
            case .selected, .success, .celebration:
                return AmbitionsIOS26SemanticTokens.Accent.yellowDark
            case .warning:
                return AmbitionsIOS26SemanticTokens.Accent.greenDark
            case .loading:
                return AmbitionsIOS26SemanticTokens.Accent.blueDark
            case .disabled:
                return AmbitionsIOS26SemanticTokens.Label.tertiaryDark
            default:
                return AmbitionsIOS26SemanticTokens.Separator.darkNonOpaque
            }
        }()
    }
}

private extension View {
    @ViewBuilder
    func productObjectAccessibilityIdentifier(_ identifier: String?) -> some View {
        if let identifier {
            accessibilityIdentifier(identifier)
        } else {
            self
        }
    }
}
