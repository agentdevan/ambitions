#if canImport(SwiftUI)
import SwiftUI

public enum AmbitionDisplayDensity: String, CaseIterable, Codable, Sendable, Identifiable {
    case minimal
    case balanced
    case detailed

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .minimal: "Minimal"
        case .balanced: "Balanced"
        case .detailed: "Detailed"
        }
    }

    public var showsSupportingDetailByDefault: Bool {
        switch self {
        case .minimal: false
        case .balanced, .detailed: true
        }
    }
}

public enum AmbitionPanelSize: String, CaseIterable, Codable, Sendable, Identifiable {
    case compact
    case comfortable
    case large

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .compact: "Compact"
        case .comfortable: "Comfortable"
        case .large: "Large"
        }
    }
}

public struct AmbitionPanelDisplayConfiguration: Hashable, Codable, Sendable {
    public static let `default` = AmbitionPanelDisplayConfiguration(
        density: .balanced,
        size: .comfortable
    )

    public let density: AmbitionDisplayDensity
    public let size: AmbitionPanelSize

    public init(
        density: AmbitionDisplayDensity = .balanced,
        size: AmbitionPanelSize = .comfortable
    ) {
        self.density = density
        self.size = size
    }

    public func resolved(
        for contentSizeCategory: ContentSizeCategory,
        reduceMotion: Bool = false
    ) -> AmbitionPanelDisplayConfiguration {
        let saferDensity: AmbitionDisplayDensity
        if contentSizeCategory.isAccessibilityCategory {
            saferDensity = .minimal
        } else if contentSizeCategory.isLargeComfortCategory, density == .detailed {
            saferDensity = .balanced
        } else {
            saferDensity = density
        }

        return AmbitionPanelDisplayConfiguration(
            density: AmbitionPanelDisplayConfiguration.effectiveDensity(
                requested: saferDensity,
                size: size
            ),
            size: size
        )
    }

    public var effectiveDensity: AmbitionDisplayDensity {
        Self.effectiveDensity(requested: density, size: size)
    }

    public var shouldCollapseOptionalPanels: Bool {
        switch (effectiveDensity, size) {
        case (.minimal, _), (_, .compact), (_, .large):
            return true
        case (.balanced, .comfortable), (.detailed, .comfortable):
            return false
        }
    }

    public var maximumNeighboringPanels: Int {
        switch size {
        case .compact: 3
        case .comfortable: 4
        case .large: 2
        }
    }

    private static func effectiveDensity(
        requested: AmbitionDisplayDensity,
        size: AmbitionPanelSize
    ) -> AmbitionDisplayDensity {
        if requested == .detailed, size == .compact {
            return .balanced
        }
        return requested
    }
}

public enum AmbitionPanelImportance: String, CaseIterable, Codable, Sendable, Identifiable {
    case heroDecision
    case todayPlan
    case activeRecovery
    case trustActionNeeded
    case meaningfulReceipt
    case supporting
    case optional

    public var id: String { rawValue }

    public var isCritical: Bool {
        switch self {
        case .heroDecision, .todayPlan, .activeRecovery, .trustActionNeeded, .meaningfulReceipt:
            return true
        case .supporting, .optional:
            return false
        }
    }

    public var isAnchored: Bool {
        self == .heroDecision
    }

    public var accessibilitySummaryMustStandAlone: Bool {
        true
    }
}

public enum AmbitionPanelVisibility: String, Codable, Sendable {
    case full
    case summarized
    case collapsedSignal
    case hidden
}

public struct AmbitionPanelDisplayMetrics: Hashable, Sendable {
    public let panelPadding: CGFloat
    public let verticalSpacing: CGFloat
    public let controlScale: CGFloat
    public let minimumTapTarget: CGFloat
    public let visualSlotMinimumHeight: CGFloat

    public init(
        panelPadding: CGFloat,
        verticalSpacing: CGFloat,
        controlScale: CGFloat,
        minimumTapTarget: CGFloat,
        visualSlotMinimumHeight: CGFloat
    ) {
        self.panelPadding = panelPadding
        self.verticalSpacing = verticalSpacing
        self.controlScale = controlScale
        self.minimumTapTarget = minimumTapTarget
        self.visualSlotMinimumHeight = visualSlotMinimumHeight
    }
}

public struct AmbitionPanelDisplayDecision: Hashable, Sendable {
    public let visibility: AmbitionPanelVisibility
    public let showsSupportingDetail: Bool
    public let preservesPrimaryAction: Bool
    public let preservesCriticalState: Bool
    public let allowsDetailedInformation: Bool
    public let shouldUseCollapsedSignal: Bool
    public let metrics: AmbitionPanelDisplayMetrics
    public let voiceOverSummaryRequired: Bool
    public let colorOnlyMeaningAllowed: Bool
    public let motionRequiredForStateClarity: Bool

    public init(
        visibility: AmbitionPanelVisibility,
        showsSupportingDetail: Bool,
        preservesPrimaryAction: Bool,
        preservesCriticalState: Bool,
        allowsDetailedInformation: Bool,
        shouldUseCollapsedSignal: Bool,
        metrics: AmbitionPanelDisplayMetrics,
        voiceOverSummaryRequired: Bool = true,
        colorOnlyMeaningAllowed: Bool = false,
        motionRequiredForStateClarity: Bool = false
    ) {
        self.visibility = visibility
        self.showsSupportingDetail = showsSupportingDetail
        self.preservesPrimaryAction = preservesPrimaryAction
        self.preservesCriticalState = preservesCriticalState
        self.allowsDetailedInformation = allowsDetailedInformation
        self.shouldUseCollapsedSignal = shouldUseCollapsedSignal
        self.metrics = metrics
        self.voiceOverSummaryRequired = voiceOverSummaryRequired
        self.colorOnlyMeaningAllowed = colorOnlyMeaningAllowed
        self.motionRequiredForStateClarity = motionRequiredForStateClarity
    }
}

public extension AmbitionTheme {
    func panelDisplayMetrics(
        for configuration: AmbitionPanelDisplayConfiguration
    ) -> AmbitionPanelDisplayMetrics {
        let resolved = configuration.effectiveDensity

        let basePadding: CGFloat
        let controlScale: CGFloat
        let visualSlotHeight: CGFloat

        switch configuration.size {
        case .compact:
            basePadding = panel.compactPadding
            controlScale = 0.94
            visualSlotHeight = panel.visualSlotMinimumHeight * 0.82
        case .comfortable:
            basePadding = panel.standardPadding
            controlScale = 1.0
            visualSlotHeight = panel.visualSlotMinimumHeight
        case .large:
            basePadding = panel.heroPadding
            controlScale = 1.04
            visualSlotHeight = panel.visualSlotMinimumHeight * 1.12
        }

        let spacingValue: CGFloat
        switch resolved {
        case .minimal:
            spacingValue = spacing.xs
        case .balanced:
            spacingValue = spacing.sm
        case .detailed:
            spacingValue = spacing.md
        }

        return AmbitionPanelDisplayMetrics(
            panelPadding: basePadding,
            verticalSpacing: spacingValue,
            controlScale: controlScale,
            minimumTapTarget: max(panel.minimumTapTarget, 44),
            visualSlotMinimumHeight: visualSlotHeight
        )
    }

    func panelDisplayDecision(
        for importance: AmbitionPanelImportance,
        configuration: AmbitionPanelDisplayConfiguration
    ) -> AmbitionPanelDisplayDecision {
        let resolvedDensity = configuration.effectiveDensity
        let metrics = panelDisplayMetrics(for: configuration)
        let visibility = panelVisibility(
            for: importance,
            density: resolvedDensity,
            size: configuration.size
        )
        let supportsDetail = shouldShowSupportingDetail(
            for: importance,
            configuration: configuration
        )

        return AmbitionPanelDisplayDecision(
            visibility: visibility,
            showsSupportingDetail: supportsDetail,
            preservesPrimaryAction: importance.isCritical || visibility != .hidden,
            preservesCriticalState: importance.isCritical,
            allowsDetailedInformation: resolvedDensity == .detailed && configuration.size != .compact,
            shouldUseCollapsedSignal: visibility == .collapsedSignal,
            metrics: metrics
        )
    }

    func shouldShowSupportingDetail(
        for importance: AmbitionPanelImportance,
        configuration: AmbitionPanelDisplayConfiguration
    ) -> Bool {
        let density = configuration.effectiveDensity
        guard configuration.size != .compact else { return false }

        switch (importance, density) {
        case (.optional, .minimal):
            return false
        case (.optional, .balanced):
            return false
        case (_, .minimal):
            return importance.isCritical && configuration.size == .comfortable
        case (_, .balanced):
            return importance != .optional
        case (_, .detailed):
            return true
        }
    }

    private func panelVisibility(
        for importance: AmbitionPanelImportance,
        density: AmbitionDisplayDensity,
        size: AmbitionPanelSize
    ) -> AmbitionPanelVisibility {
        if importance.isAnchored { return .full }

        if importance.isCritical {
            switch (density, size) {
            case (.minimal, .compact), (.minimal, .large):
                return .collapsedSignal
            case (.minimal, .comfortable), (.balanced, .compact):
                return .summarized
            case (.balanced, _), (.detailed, _):
                return .full
            }
        }

        if importance == .optional {
            switch (density, size) {
            case (.minimal, _), (.balanced, .compact), (.balanced, .large):
                return .hidden
            case (.balanced, .comfortable), (.detailed, .compact), (.detailed, .large):
                return .summarized
            case (.detailed, .comfortable):
                return .full
            }
        }

        switch (density, size) {
        case (.minimal, .compact), (.minimal, .large):
            return .hidden
        case (.minimal, .comfortable), (.balanced, .compact), (.balanced, .large):
            return .summarized
        case (.balanced, .comfortable), (.detailed, _):
            return .full
        }
    }
}

private extension ContentSizeCategory {
    var isLargeComfortCategory: Bool {
        switch self {
        case .extraExtraLarge, .extraExtraExtraLarge:
            return true
        default:
            return false
        }
    }
}

private struct AmbitionPanelDisplayConfigurationKey: EnvironmentKey {
    static let defaultValue: AmbitionPanelDisplayConfiguration = .default
}

public extension EnvironmentValues {
    var ambitionPanelDisplayConfiguration: AmbitionPanelDisplayConfiguration {
        get { self[AmbitionPanelDisplayConfigurationKey.self] }
        set { self[AmbitionPanelDisplayConfigurationKey.self] = newValue }
    }
}

public extension View {
    func ambitionPanelDisplayConfiguration(
        _ configuration: AmbitionPanelDisplayConfiguration
    ) -> some View {
        environment(\.ambitionPanelDisplayConfiguration, configuration)
    }
}
#endif
