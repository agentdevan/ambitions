
#if canImport(SwiftUI)
import SwiftUI

/// Ambitions-owned bridge from the supplied iOS 26 token atlas into product semantics.
///
/// This is not an Apple UI-kit mirror. It translates SF Pro scale, graphite labels,
/// grouped backgrounds, separators, fills, materials, and Liquid Glass dock behavior
/// into Ambitions semantic language for native iPhone surfaces.
public enum AmbitionsIOS26SemanticTokens {
    public enum Typography {
        public static let largeTitle = Font.system(size: 34, weight: .regular, design: .default)
        public static let title1 = Font.system(size: 28, weight: .regular, design: .default)
        public static let title2 = Font.system(size: 22, weight: .regular, design: .default)
        public static let title3 = Font.system(size: 20, weight: .regular, design: .default)
        public static let headline = Font.system(size: 17, weight: .semibold, design: .default)
        public static let body = Font.system(size: 17, weight: .regular, design: .default)
        public static let callout = Font.system(size: 16, weight: .regular, design: .default)
        public static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
        public static let footnote = Font.system(size: 13, weight: .regular, design: .default)
        public static let caption1 = Font.system(size: 12, weight: .regular, design: .default)
        public static let caption2 = Font.system(size: 11, weight: .regular, design: .default)
    }

    public enum Graphite {
        public static let base = Color.black
        public static let secondary = Color(red: 0.1098, green: 0.1098, blue: 0.1176)
        public static let tertiary = Color(red: 0.1725, green: 0.1725, blue: 0.1804)
        public static let elevated = Color(red: 0.1098, green: 0.1098, blue: 0.1176)
        public static let elevatedSecondary = Color(red: 0.1725, green: 0.1725, blue: 0.1804)
        public static let elevatedTertiary = Color(red: 0.2275, green: 0.2275, blue: 0.2353)
    }

    public enum Label {
        public static let primaryDark = Color.white
        public static let secondaryDark = Color(red: 0.9216, green: 0.9216, blue: 0.9608).opacity(0.60)
        public static let tertiaryDark = Color(red: 0.9216, green: 0.9216, blue: 0.9608).opacity(0.30)
        public static let quaternaryDark = Color(red: 0.9216, green: 0.9216, blue: 0.9608).opacity(0.16)
    }

    public enum Fill {
        public static let primaryDark = Color(red: 0.4706, green: 0.4706, blue: 0.5020).opacity(0.36)
        public static let secondaryDark = Color(red: 0.4706, green: 0.4706, blue: 0.5020).opacity(0.32)
        public static let tertiaryDark = Color(red: 0.4627, green: 0.4627, blue: 0.5020).opacity(0.24)
        public static let quaternaryDark = Color(red: 0.4627, green: 0.4627, blue: 0.5020).opacity(0.18)
    }

    public enum Separator {
        public static let darkNonOpaque = Color.white.opacity(0.12)
        public static let darkOpaque = Color(red: 0.2196, green: 0.2196, blue: 0.2275)
    }

    public enum Accent {
        public static let yellowDark = Color(red: 1.0, green: 0.8392, blue: 0.0)
        public static let blueDark = Color(red: 0.0, green: 0.5686, blue: 1.0)
        public static let greenDark = Color(red: 0.1882, green: 0.8196, blue: 0.3451)
        public static let indigoDark = Color(red: 0.4275, green: 0.4863, blue: 1.0)
        public static let cyanDark = Color(red: 0.2353, green: 0.8275, blue: 0.9961)
    }

    public enum LiquidGlass {
        public static let clearFill = Color.white.opacity(0.25)
        public static let darkDockBase = Color.black.opacity(0.10)
        public static let darkDockCore = Color(red: 0.102, green: 0.102, blue: 0.102)
        public static let darkRegularLargeBase = Color.black.opacity(0.40)
        public static let darkRegularLargeCore = Color(red: 0.102, green: 0.102, blue: 0.102)
    }
}
#endif
