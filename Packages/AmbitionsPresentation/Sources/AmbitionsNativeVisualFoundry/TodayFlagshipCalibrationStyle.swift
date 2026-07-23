import SwiftUI

struct TodayFlagshipPalette {
    let colorScheme: ColorScheme
    let contrast: ColorSchemeContrast

    var semanticPlane: Color {
        colorScheme == .dark
            ? Color(red: 0.070, green: 0.073, blue: 0.081)
            : Color(red: 0.945, green: 0.937, blue: 0.910)
    }

    var recessedPlane: Color {
        colorScheme == .dark
            ? Color(red: 0.105, green: 0.108, blue: 0.118)
            : Color(red: 0.918, green: 0.908, blue: 0.880)
    }

    var primaryInk: Color {
        colorScheme == .dark
            ? Color(red: 0.95, green: 0.94, blue: 0.91)
            : Color(red: 0.11, green: 0.11, blue: 0.12)
    }

    var secondaryInk: Color {
        colorScheme == .dark
            ? Color(red: 0.74, green: 0.73, blue: 0.70)
            : Color(red: 0.30, green: 0.29, blue: 0.28)
    }

    var tertiaryInk: Color {
        colorScheme == .dark
            ? Color(red: 0.59, green: 0.58, blue: 0.56)
            : Color(red: 0.43, green: 0.42, blue: 0.40)
    }

    var actionAccent: Color {
        colorScheme == .dark
            ? Color(red: 0.42, green: 0.40, blue: 0.67)
            : Color(red: 0.30, green: 0.27, blue: 0.55)
    }

    var articulationAccent: Color {
        colorScheme == .dark
            ? Color(red: 0.69, green: 0.67, blue: 0.91)
            : Color(red: 0.35, green: 0.30, blue: 0.60)
    }

    var actionInk: Color { .white }

    var localArticulation: Color {
        primaryInk.opacity(contrast == .increased ? 0.35 : colorScheme == .dark ? 0.22 : 0.16)
    }

    var divider: Color {
        primaryInk.opacity(contrast == .increased ? 0.36 : colorScheme == .dark ? 0.20 : 0.14)
    }

    var opaqueChrome: Color {
        colorScheme == .dark
            ? Color(red: 0.14, green: 0.14, blue: 0.16)
            : Color(red: 0.89, green: 0.88, blue: 0.84)
    }

    var selectedChrome: Color {
        colorScheme == .dark
            ? Color(red: 0.24, green: 0.23, blue: 0.29)
            : Color(red: 0.83, green: 0.82, blue: 0.78)
    }

    var warningPlane: Color {
        colorScheme == .dark
            ? Color(red: 0.16, green: 0.145, blue: 0.13)
            : Color(red: 0.91, green: 0.87, blue: 0.79)
    }

    var successPlane: Color {
        colorScheme == .dark
            ? Color(red: 0.12, green: 0.145, blue: 0.135)
            : Color(red: 0.86, green: 0.89, blue: 0.84)
    }
}

struct TodayFlagshipSectionLabel: View {
    let title: String
    let symbol: String?
    let palette: TodayFlagshipPalette

    init(
        _ title: String,
        symbol: String? = nil,
        palette: TodayFlagshipPalette
    ) {
        self.title = title
        self.symbol = symbol
        self.palette = palette
    }

    var body: some View {
        HStack(spacing: 7) {
            if let symbol {
                Image(systemName: symbol)
                    .font(.caption.weight(.semibold))
                    .accessibilityHidden(true)
            }
            Text(title)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(palette.secondaryInk)
        .textCase(.uppercase)
        .tracking(0.4)
        .accessibilityAddTraits(.isHeader)
    }
}

struct TodayFlagshipLocalSeam<Content: View>: View {
    let palette: TodayFlagshipPalette
    let content: Content

    init(
        palette: TodayFlagshipPalette,
        @ViewBuilder content: () -> Content
    ) {
        self.palette = palette
        self.content = content()
    }

    var body: some View {
        content
            .padding(.leading, 13)
            .overlay(alignment: .leading) {
                RoundedRectangle(cornerRadius: 1)
                    .fill(palette.localArticulation)
                    .frame(width: 2)
                    .padding(.vertical, 3)
                    .accessibilityHidden(true)
            }
    }
}

struct TodayFlagshipTruthBlock: View {
    let label: String
    let symbol: String
    let truth: String
    let supportingText: String?
    let isProposed: Bool
    let palette: TodayFlagshipPalette

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 7) {
                Image(systemName: symbol)
                    .font(.caption.weight(.bold))
                    .accessibilityHidden(true)
                Text(label)
                    .font(.caption.weight(.bold))
                    .tracking(0.35)
            }
            .foregroundStyle(isProposed ? palette.articulationAccent : palette.secondaryInk)

            Text(truth)
                .font(.body.weight(isProposed ? .semibold : .regular))
                .fixedSize(horizontal: false, vertical: true)

            if let supportingText {
                Text(supportingText)
                    .font(.footnote)
                    .foregroundStyle(palette.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(isProposed ? palette.recessedPlane : palette.semanticPlane)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(isProposed ? palette.articulationAccent : palette.localArticulation)
                .frame(height: isProposed ? 2 : 1)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
    }
}

extension View {
    @ViewBuilder
    func todayFlagshipConsequentialReview<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        #if os(iOS)
        fullScreenCover(isPresented: isPresented, content: content)
        #else
        sheet(isPresented: isPresented, content: content)
        #endif
    }

    @ViewBuilder
    func todayFlagshipHideRootNavigationBar() -> some View {
        #if os(iOS)
        toolbar(.hidden, for: .navigationBar)
        #else
        self
        #endif
    }

    @ViewBuilder
    func todayFlagshipInlineNavigationTitle() -> some View {
        #if os(iOS)
        navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }

    @ViewBuilder
    func todayFlagshipBackButtonHidden(_ hidden: Bool) -> some View {
        #if os(iOS)
        navigationBarBackButtonHidden(hidden)
        #else
        self
        #endif
    }
}
