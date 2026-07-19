#if canImport(SwiftUI)
import SwiftUI

public struct SI16VisualQAFixtureSnapshotCard: View {
    @Environment(\.ambitionTheme) private var theme

    public let fixture: SI16VisualQAFixture

    public init(fixture: SI16VisualQAFixture) {
        self.fixture = fixture
    }

    public var body: some View {
        ZStack {
            LinearGradient(
                colors: [surfaceBase.opacity(0.96), theme.colors.canvas],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(alignment: .topTrailing) {
                Circle()
                    .fill(surfaceAccent.opacity(0.16))
                    .frame(width: 230, height: 230)
                    .offset(x: 54, y: -32)
            }
            .overlay(alignment: .bottomTrailing) {
                Path { path in
                    path.move(to: CGPoint(x: 80, y: 630))
                    path.addCurve(
                        to: CGPoint(x: 1120, y: 510),
                        control1: CGPoint(x: 300, y: 530),
                        control2: CGPoint(x: 650, y: 730)
                    )
                }
                .stroke(surfaceAccent.opacity(0.42), lineWidth: 4)
            }

            VStack(alignment: .leading, spacing: 30) {
                HStack(spacing: 14) {
                    Text("FE-11")
                        .font(theme.typography.sectionTitle)
                        .foregroundStyle(surfaceAccent)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(surfaceAccent.opacity(0.15)))

                    Text(fixture.ownerSurface)
                        .font(theme.typography.sectionTitle)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                Spacer(minLength: 28)

                VStack(alignment: .leading, spacing: 14) {
                    Text(fixture.stateFamily.title)
                        .font(theme.typography.heroDisplay)
                        .foregroundStyle(theme.colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(fixture.primaryObject)
                        .font(theme.typography.title)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text(fixture.id)
                        .font(theme.typography.titleCompact)
                        .foregroundStyle(surfaceAccent)

                    Text(fixture.screenshotName)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                }
                .padding(28)
                .frame(maxWidth: 560, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                        .fill(theme.colors.surfaceSecondary.opacity(0.48))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                        .stroke(theme.colors.strokeSubtle, lineWidth: 1)
                )

                Spacer(minLength: 30)

                Text("SwiftUI ImageRenderer snapshot from the FE-11 fixture catalog. Inventory proof only; not device proof, release proof, accessibility conformance, or human visual approval.")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(72)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
        .frame(width: 1200, height: 800)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(fixture.previewName). \(fixture.accessibilityNote)")
        .accessibilityValue("FE-11 SwiftUI snapshot. \(fixture.reduceMotionNote) \(fixture.nonColorNote)")
    }

    private var surfaceBase: Color {
        switch fixture.ownerSurface {
        case "Today": theme.shell.statusSteady
        case "Goals": theme.shell.depthAccent
        case "Capture": theme.shell.trustBadgeSurface
        case "Time": theme.shell.statusProtected
        case "You": theme.colors.surfaceSecondary
        default: theme.colors.surfacePrimary
        }
    }

    private var surfaceAccent: Color {
        switch fixture.ownerSurface {
        case "Today": theme.shell.statusRecovered
        case "Goals": theme.colors.accentPrimary
        case "Time": theme.shell.statusProtected
        case "You": theme.shell.statusClear
        default: theme.colors.textPrimary
        }
    }
}
#endif
