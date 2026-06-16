
#if canImport(SwiftUI)
import SwiftUI

/// Root-level object surface without default card chrome.
///
/// Use for Today / Goals / Time / Motion first viewports when the product object
/// should own the screen rather than sit inside a generic rounded card stack.
public struct ObjectStageSurface<Content: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private let content: Content

    public init(
        state: AmbitionVisualState = .default,
        accent: Color? = nil,
        @ViewBuilder content: () -> Content
    ) {
        _ = state
        _ = accent
        self.content = content()
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            AmbitionsIOS26SemanticTokens.Graphite.base
            content
        }
        .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: reduceMotion)
    }
}

/// Compact object-stage glance without AppCard/WidgetCard chrome.
public struct ObjectStageGlance<Content: View>: View {
    private let state: AmbitionVisualState
    private let accent: Color?
    private let content: Content

    public init(
        state: AmbitionVisualState = .default,
        accent: Color? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.state = state
        self.accent = accent
        self.content = content()
    }

    public var body: some View {
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

/// Dominant object-stage hero without HeroCard chrome.
public struct ObjectStageHero<Content: View>: View {
    private let state: AmbitionVisualState
    private let accent: Color?
    private let content: Content

    public init(
        state: AmbitionVisualState = .default,
        accent: Color? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.state = state
        self.accent = accent
        self.content = content()
    }

    public var body: some View {
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

/// Instrument field surface for stateful product meaning.
public struct InstrumentField<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(AmbitionsIOS26SemanticTokens.Fill.quaternaryDark)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(AmbitionsIOS26SemanticTokens.Separator.darkNonOpaque)
                    .frame(height: 1)
                    .accessibilityHidden(true)
            }
    }
}

/// Progressive disclosure seam for Why this? detail.
public struct TrustSeamDisclosure<Content: View>: View {
    private let title: String
    private let content: Content

    public init(_ title: String = "Why this?", @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    public var body: some View {
        DisclosureGroup(title) {
            content
                .padding(.top, 8)
        }
        .font(AmbitionsIOS26SemanticTokens.Typography.footnote)
    }
}

/// Native grouped control surface for You and detail settings flows.
public struct NativeGroupedControlSurface<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .background(AmbitionsIOS26SemanticTokens.Graphite.base)
    }
}
#endif
