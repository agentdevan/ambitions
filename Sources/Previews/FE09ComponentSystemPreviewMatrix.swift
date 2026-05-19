#if canImport(SwiftUI)
import SwiftUI

public enum FE09ComponentSystemPreviewVariant: String, CaseIterable, Identifiable, Sendable {
    case standard = "Component System Matrix"
    case dynamicType = "Dynamic Type"
    case reduceMotion = "Reduce Motion"
    case nonColorState = "Non-Color State"
    case increasedContrast = "Increased Contrast"

    public var id: String { rawValue }
    public var title: String { rawValue }

    public var subtitle: String {
        switch self {
        case .standard:
            return "Baseline matrix for the owned Ambitions objects."
        case .dynamicType:
            return "Large text keeps the object title, source, and action readable."
        case .reduceMotion:
            return "Static equivalents keep meaning without motion dependency."
        case .nonColorState:
            return "Text, symbol, and structure carry meaning without color alone."
        case .increasedContrast:
            return "Higher contrast keeps boundaries and state readable."
        }
    }

    public var accessibilitySummary: String {
        "\(title). \(subtitle)"
    }
}

public struct FE09ComponentSystemPreviewCell: Identifiable, Equatable, Sendable {
    public let role: FE09ComponentSystemRole
    public let state: FE09ComponentSystemState

    public init(role: FE09ComponentSystemRole, state: FE09ComponentSystemState) {
        self.role = role
        self.state = state
    }

    public var id: String {
        "\(role.rawValue).\(state.rawValue)"
    }

    public var accessibilitySummary: String {
        "\(role.title). \(state.accessibilitySummary). \(role.summary)"
    }
}

public struct FE09ComponentSystemPreviewRow: Identifiable, Equatable, Sendable {
    public let role: FE09ComponentSystemRole
    public let cells: [FE09ComponentSystemPreviewCell]

    public init(role: FE09ComponentSystemRole, cells: [FE09ComponentSystemPreviewCell]) {
        self.role = role
        self.cells = cells
    }

    public var id: String { role.rawValue }

    public var accessibilitySummary: String {
        [role.accessibilitySummary, cells.map(\.accessibilitySummary).joined(separator: " ")]
            .joined(separator: ". ")
    }
}

public enum FE09ComponentSystemPreviewMatrix {
    public static let rows: [FE09ComponentSystemPreviewRow] = FE09ComponentSystemContract.roles.map { role in
        FE09ComponentSystemPreviewRow(
            role: role,
            cells: FE09ComponentSystemContract.states.map { state in
                FE09ComponentSystemPreviewCell(role: role, state: state)
            }
        )
    }

    public static let variants: [FE09ComponentSystemPreviewVariant] = FE09ComponentSystemPreviewVariant.allCases
    public static let forbiddenLanguage = FE09ComponentSystemContract.forbiddenLanguage

    public static func validationFailures() -> [String] {
        var failures: [String] = []

        if rows.count != FE09ComponentSystemContract.roles.count {
            failures.append("row count does not match role count")
        }

        for row in rows {
            if row.cells.map(\.state) != FE09ComponentSystemContract.states {
                failures.append("row state order mismatch: \(row.role.title)")
            }
            failures.append(contentsOf: validationFailures(for: row))
        }

        if variants.count != FE09ComponentSystemPreviewVariant.allCases.count {
            failures.append("variant count does not match preview variant count")
        }
        for variant in variants {
            failures.append(contentsOf: validationFailures(for: variant))
        }

        let searchable = rows
            .map(\.accessibilitySummary)
            .joined(separator: " ")
            .lowercased()

        for phrase in forbiddenLanguage where searchable.contains(phrase) {
            failures.append("forbidden language: \(phrase)")
        }

        return failures
    }

    public static func validationFailures(for variant: FE09ComponentSystemPreviewVariant) -> [String] {
        var failures: [String] = []

        if variant.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            failures.append("missing variant title")
        }
        if variant.subtitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            failures.append("missing variant subtitle")
        }
        if variant.accessibilitySummary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            failures.append("missing variant accessibility summary")
        }

        let searchable = variant.accessibilitySummary.lowercased()
        for phrase in forbiddenLanguage where searchable.contains(phrase) {
            failures.append("forbidden language: \(phrase)")
        }

        return failures
    }

    public static func validationFailures(for row: FE09ComponentSystemPreviewRow) -> [String] {
        var failures: [String] = []

        if row.role.summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            failures.append("missing row summary: \(row.role.title)")
        }
        if row.cells.count != FE09ComponentSystemContract.states.count {
            failures.append("missing cells: \(row.role.title)")
        }

        let searchable = row.accessibilitySummary.lowercased()
        for phrase in forbiddenLanguage where searchable.contains(phrase) {
            failures.append("forbidden language: \(phrase)")
        }

        return failures
    }
}

private struct FE09ComponentSystemPreviewGallery: View {
    @Environment(\.ambitionTheme) private var theme
    let variant: FE09ComponentSystemPreviewVariant

    private let columns = [GridItem(.adaptive(minimum: 180), spacing: 12, alignment: .top)]

    var body: some View {
        switch variant {
        case .standard:
            galleryBase
        case .dynamicType:
            galleryBase.environment(\.dynamicTypeSize, .accessibility3)
        case .reduceMotion:
            galleryBase.transaction { transaction in
                transaction.disablesAnimations = true
            }
        case .nonColorState:
            galleryBase
        case .increasedContrast:
            galleryBase
        }
    }

    private var galleryBase: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                SectionHeader(
                    eyebrow: "FE09",
                    title: variant.title,
                    subtitle: variant.subtitle
                )

                ForEach(FE09ComponentSystemPreviewMatrix.rows) { row in
                    AdaptiveModuleChrome(
                        title: row.role.title,
                        subtitle: row.role.primaryObject,
                        context: row.role.context,
                        state: row.role.previewState,
                        evidence: row.role.accessibilitySummary
                    ) {
                        LazyVGrid(columns: columns, alignment: .leading, spacing: theme.spacing.sm) {
                            ForEach(row.cells) { cell in
                                previewCell(cell)
                            }
                        }
                    }
                }
            }
            .padding(theme.spacing.lg)
        }
        .background(LivingSurfaceBackground(context: .trust, state: .calm).ignoresSafeArea())
        .ambitionTheme(.dark)
    }

    private func previewCell(_ cell: FE09ComponentSystemPreviewCell) -> some View {
        StateDrivenMaterialPanel(context: cell.role.context, state: cell.state.visualState) {
            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xxs) {
                    Image(systemName: cell.state.symbolName)
                        .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                        .foregroundStyle(cell.role.context.accent(in: theme))
                        .symbolRenderingMode(variant == .nonColorState ? .monochrome : .hierarchical)
                        .accessibilityHidden(true)

                    Text(cell.state.title)
                        .font(theme.typography.caption.weight(.semibold))
                        .foregroundStyle(theme.colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Text(cell.state.summary)
                    .font(theme.typography.micro)
                    .foregroundStyle(variant == .increasedContrast ? theme.colors.textPrimary : theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(cell.role.primaryObject)
                    .font(theme.typography.micro)
                    .foregroundStyle(variant == .increasedContrast ? theme.colors.textSecondary : theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .overlay {
            if variant == .increasedContrast {
                RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                    .stroke(theme.colors.textPrimary.opacity(0.55), lineWidth: 1)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(cell.accessibilitySummary)
        .accessibilityValue(cell.state.nonColorCue)
        .accessibilityIdentifier("fe09.component.\(cell.id)")
    }
}

#Preview("FE09 Component Matrix") {
    FE09ComponentSystemPreviewGallery(variant: .standard)
}

#Preview("FE09 Component Matrix Dynamic Type") {
    FE09ComponentSystemPreviewGallery(variant: .dynamicType)
}

#Preview("FE09 Component Matrix Reduce Motion") {
    FE09ComponentSystemPreviewGallery(variant: .reduceMotion)
}

#Preview("FE09 Component Matrix Non-Color State") {
    FE09ComponentSystemPreviewGallery(variant: .nonColorState)
}

#Preview("FE09 Component Matrix Increased Contrast") {
    FE09ComponentSystemPreviewGallery(variant: .increasedContrast)
}
#endif
