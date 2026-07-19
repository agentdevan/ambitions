#if canImport(SwiftUI)
import AmbitionsDesignSystem
import SwiftUI

public struct WidgetFeedItem: Identifiable {
    public let id: String
    public let priority: WidgetDisplayPriority
    public let variant: WidgetDisplayVariant
    private let builder: () -> AnyView

    public init<Content: View>(
        id: String,
        priority: WidgetDisplayPriority,
        variant: WidgetDisplayVariant,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.id = id
        self.priority = priority
        self.variant = variant
        self.builder = { AnyView(content()) }
    }

    fileprivate func makeView() -> AnyView { builder() }
}

/// Reusable vertical feed for stacking mixed-size widgets inside screens such
/// as Today, Goals, Rituals, contextual inspection, and You.
public struct WidgetFeed: View {
    private let items: [WidgetFeedItem]

    public init(items: [WidgetFeedItem]) {
        self.items = items.sorted {
            if $0.priority == $1.priority {
                return $0.id < $1.id
            }
            return $0.priority > $1.priority
        }
    }

    public var body: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                item.makeView()
                    .padding(.bottom, spacing(after: item, next: index < items.count - 1 ? items[index + 1] : nil))
            }
        }
    }

    private func spacing(after current: WidgetFeedItem, next: WidgetFeedItem?) -> CGFloat {
        guard let next else { return 0 }
        return max(spacing(for: current.variant), spacing(for: next.variant))
    }

    private func spacing(for variant: WidgetDisplayVariant) -> CGFloat {
        switch variant {
        case .compact: 12
        case .medium: 18
        case .expanded: 24
        }
    }
}

struct WidgetSurface<Content: View>: View {
    let chrome: WidgetChromeStyle
    let state: AmbitionVisualState
    let accent: Color?
    let content: Content

    init(
        chrome: WidgetChromeStyle,
        state: AmbitionVisualState = .default,
        accent: Color? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.chrome = chrome
        self.state = state
        self.accent = accent
        self.content = content()
    }

    var body: some View {
        switch chrome {
        case .widgetCard:
            WidgetCard(state: state, accent: accent) { content }
        case .appCard:
            AppCard(state: state, accent: accent) { content }
        case .heroCard:
            HeroCard(state: state, accent: accent) { content }
        }
    }
}
#endif
