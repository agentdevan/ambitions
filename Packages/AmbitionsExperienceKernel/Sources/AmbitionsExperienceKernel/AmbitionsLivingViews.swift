import SwiftUI

public struct AmbitionsSurfaceRoot<Content: View>: View {
    private let contract: AmbitionsSurfaceContract
    private let field: AmbitionsVisualFieldState
    private let content: Content

    public init(surface: AmbitionsSurface, field: AmbitionsVisualFieldState, @ViewBuilder content: () -> Content) {
        self.contract = AmbitionsSurfaceContracts.contract(for: surface)
        self.field = field
        self.content = content()
    }

    public var body: some View {
        ZStack {
            LivingGraphiteField(field: field, surface: contract.surface)
            content
        }
        .environment(\.ambitionsSurfaceContract, contract)
        .accessibilityElement(children: .contain)
    }
}

private struct AmbitionsSurfaceContractKey: EnvironmentKey {
    static let defaultValue = AmbitionsSurfaceContracts.contract(for: .today)
}

public extension EnvironmentValues {
    var ambitionsSurfaceContract: AmbitionsSurfaceContract {
        get { self[AmbitionsSurfaceContractKey.self] }
        set { self[AmbitionsSurfaceContractKey.self] = newValue }
    }
}

public struct LivingGraphiteField: View {
    private let field: AmbitionsVisualFieldState
    private let surface: AmbitionsSurface
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    public init(field: AmbitionsVisualFieldState, surface: AmbitionsSurface) {
        self.field = field
        self.surface = surface
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                baseColor.ignoresSafeArea()
                RadialGradient(
                    colors: [fieldColor.opacity(reduceTransparency ? 0.08 : fieldOpacity), .clear],
                    center: .topTrailing,
                    startRadius: 8,
                    endRadius: max(proxy.size.width, proxy.size.height)
                )
                .ignoresSafeArea()
                LinearGradient(
                    colors: [AmbitionsTokens.color(.fieldClosureResidue).opacity(field.closureResidue * 0.28), .clear],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .ignoresSafeArea()
            }
            .animation(AmbitionsTokens.motion(.semanticSettle).makeAnimation(reduceMotion), value: field)
        }
    }

    private var baseColor: Color {
        switch surface {
        case .today: return AmbitionsTokens.color(.surfaceTodayBase)
        case .goals: return AmbitionsTokens.color(.surfaceGoalsBase)
        case .capture: return AmbitionsTokens.color(.surfaceCaptureBase)
        case .time: return AmbitionsTokens.color(.surfaceTimeBase)
        case .you: return AmbitionsTokens.color(.surfaceYouBase)
        }
    }

    private var fieldColor: Color {
        switch field.fit {
        case .fitsNow: return AmbitionsTokens.color(.stateFitNow)
        case .tightFit: return AmbitionsTokens.color(.stateFitTight)
        case .needsBuffer: return AmbitionsTokens.color(.stateFitBuffer)
        case .protectedTime: return AmbitionsTokens.color(.stateFitProtected)
        case .recoveryFirst: return AmbitionsTokens.color(.stateFitRecovery)
        }
    }

    private var fieldOpacity: Double {
        0.08 + (field.compression * 0.14) + (field.goalPull * 0.06)
    }
}

public struct RealityMeridianObject: View {
    private let nodes: [MeridianNode]
    private let field: AmbitionsVisualFieldState

    public init(nodes: [MeridianNode], field: AmbitionsVisualFieldState) {
        self.nodes = nodes
        self.field = field
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: AmbitionsTokens.space(.sm)) {
            ForEach(nodes) { node in
                HStack(spacing: AmbitionsTokens.space(.sm)) {
                    MeridianNodeGlyph(state: node.state, isCurrent: node.isCurrent)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(node.title)
                            .font(AmbitionsTokens.font(.bodyPrimary))
                            .foregroundStyle(AmbitionsTokens.color(.textPrimary))
                        if let detail = node.detail {
                            Text(detail)
                                .font(AmbitionsTokens.font(.captionProof))
                                .foregroundStyle(AmbitionsTokens.color(.textSecondary))
                        }
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(AmbitionsAccessibility.meridianSummary(nodes: nodes, field: field))
    }
}

public struct MeridianNode: Identifiable, Equatable, Sendable {
    public enum State: String, CaseIterable, Sendable {
        case now
        case closed
        case stillCounts
        case protected
        case waiting
        case recoveryNeeded
        case blocked
        case proofAttached
    }

    public let id: UUID
    public let title: String
    public let detail: String?
    public let state: State
    public let isCurrent: Bool

    public init(id: UUID = UUID(), title: String, detail: String?, state: State, isCurrent: Bool) {
        self.id = id
        self.title = title
        self.detail = detail
        self.state = state
        self.isCurrent = isCurrent
    }
}

public struct MeridianNodeGlyph: View {
    private let state: MeridianNode.State
    private let isCurrent: Bool

    public init(state: MeridianNode.State, isCurrent: Bool) {
        self.state = state
        self.isCurrent = isCurrent
    }

    public var body: some View {
        Circle()
            .fill(color)
            .frame(width: isCurrent ? 14 : 9, height: isCurrent ? 14 : 9)
            .overlay(Circle().stroke(AmbitionsTokens.color(.graphiteRecess0), lineWidth: 2))
            .shadow(color: color.opacity(isCurrent ? 0.44 : 0.18), radius: isCurrent ? 10 : 4, y: 1)
            .accessibilityLabel(Text(state.rawValue))
    }

    private var color: Color {
        switch state {
        case .now: return AmbitionsTokens.color(.objectRealityMeridianNow)
        case .closed: return AmbitionsTokens.color(.objectRealityMeridianClosed)
        case .stillCounts: return AmbitionsTokens.color(.objectRealityMeridianStillCounts)
        case .protected: return AmbitionsTokens.color(.objectRealityMeridianProtected)
        case .waiting: return AmbitionsTokens.color(.objectRealityMeridianWaiting)
        case .recoveryNeeded: return AmbitionsTokens.color(.objectRealityMeridianRecovery)
        case .blocked: return AmbitionsTokens.color(.objectRealityMeridianBlocked)
        case .proofAttached: return AmbitionsTokens.color(.objectRealityMeridianProof)
        }
    }
}

public struct StartHereDecisionLayerView: View {
    private let title: String
    private let whyNow: String
    private let fit: AmbitionsStepFit
    private let receipts: [AmbitionsProofReceipt]
    private let startAction: () -> Void
    private let adjustAction: () -> Void

    public init(title: String, whyNow: String, fit: AmbitionsStepFit, receipts: [AmbitionsProofReceipt], startAction: @escaping () -> Void, adjustAction: @escaping () -> Void) {
        self.title = title
        self.whyNow = whyNow
        self.fit = fit
        self.receipts = receipts
        self.startAction = startAction
        self.adjustAction = adjustAction
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: AmbitionsTokens.space(.md)) {
            Text("Start here")
                .font(AmbitionsTokens.font(.captionProof))
                .foregroundStyle(AmbitionsTokens.color(.textSecondary))
            Text(title)
                .font(AmbitionsTokens.font(.objectHead))
                .foregroundStyle(AmbitionsTokens.color(.textPrimary))
            Text(whyNow)
                .font(AmbitionsTokens.font(.bodyCompact))
                .foregroundStyle(AmbitionsTokens.color(.textSecondary))
            HStack(spacing: AmbitionsTokens.space(.sm)) {
                Button("Start now", action: startAction)
                    .buttonStyle(AmbitionsCommandStyle(role: .primary))
                Button("Adjust", action: adjustAction)
                    .buttonStyle(AmbitionsCommandStyle(role: .secondary))
            }
            ReceiptLayer(receipts: receipts)
        }
        .padding(AmbitionsTokens.space(.lg))
        .background {
            RoundedRectangle(cornerRadius: AmbitionsTokens.radius(.xl), style: .continuous)
                .fill(AmbitionsTokens.color(.objectStartHereBody))
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(AmbitionsTokens.color(.objectStartHereSeam))
                        .frame(height: 1)
                        .padding(.horizontal, AmbitionsTokens.space(.lg))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: AmbitionsTokens.radius(.xl), style: .continuous)
                        .stroke(AmbitionsTokens.color(.objectStartHereRim), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.28), radius: 26, y: 8)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(AmbitionsAccessibility.startHereSummary(title: title, whyNow: whyNow, fit: fit, receiptCount: receipts.count))
    }
}

public struct AmbitionsCommandStyle: ButtonStyle {
    public enum Role: Sendable {
        case primary
        case secondary
    }

    private let role: Role

    public init(role: Role) {
        self.role = role
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AmbitionsTokens.font(.bodyCompact))
            .foregroundStyle(role == .primary ? AmbitionsTokens.color(.textInverse) : AmbitionsTokens.color(.textPrimary))
            .padding(.horizontal, AmbitionsTokens.space(.md))
            .padding(.vertical, AmbitionsTokens.space(.sm))
            .background {
                Capsule(style: .continuous)
                    .fill(role == .primary ? AmbitionsTokens.color(.commandPrimary) : AmbitionsTokens.color(.commandSecondary))
                    .overlay(Capsule(style: .continuous).stroke(AmbitionsTokens.color(.strokeSubtle), lineWidth: role == .primary ? 0 : 1))
            }
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
    }
}

public struct ReceiptLayer: View {
    private let receipts: [AmbitionsProofReceipt]

    public init(receipts: [AmbitionsProofReceipt]) {
        self.receipts = receipts
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: AmbitionsTokens.space(.xs)) {
            ForEach(receipts.prefix(3)) { receipt in
                HStack(spacing: AmbitionsTokens.space(.xs)) {
                    Circle()
                        .fill(AmbitionsTokens.color(.stateProofStrong))
                        .frame(width: 5, height: 5)
                    Text(receipt.title)
                        .font(AmbitionsTokens.font(.captionProof))
                        .foregroundStyle(AmbitionsTokens.color(.textTertiary))
                }
            }
        }
        .accessibilityLabel(AmbitionsAccessibility.receiptSummary(receipts))
    }
}

public struct ActionClosureObject: View {
    private let state: AmbitionsActionClosureState
    private let title: String

    public init(state: AmbitionsActionClosureState, title: String) {
        self.state = state
        self.title = title
    }

    public var body: some View {
        HStack(spacing: AmbitionsTokens.space(.sm)) {
            Circle().fill(color).frame(width: 10, height: 10)
            Text(title)
                .font(AmbitionsTokens.font(.bodyPrimary))
                .foregroundStyle(AmbitionsTokens.color(.textPrimary))
        }
        .accessibilityLabel(AmbitionsAccessibility.closureSummary(state: state, title: title))
    }

    private var color: Color {
        switch state {
        case .completed: return AmbitionsTokens.color(.accentSuccess)
        case .stillCounts: return AmbitionsTokens.color(.accentBrand)
        case .moved: return AmbitionsTokens.color(.accentInfo)
        case .skippedNotNeeded: return AmbitionsTokens.color(.textTertiary)
        case .blocked: return AmbitionsTokens.color(.accentDanger)
        case .waiting: return AmbitionsTokens.color(.accentInfo)
        case .needsRecovery: return AmbitionsTokens.color(.accentRecovery)
        case .needsReview: return AmbitionsTokens.color(.accentCaution)
        }
    }
}

public struct ConstellationAtlasObject: View {
    public init() {}
    public var body: some View {
        Circle()
            .stroke(AmbitionsTokens.color(.objectConstellationOrbit), lineWidth: 1)
            .overlay(Circle().fill(AmbitionsTokens.color(.objectConstellationNode)).frame(width: 8, height: 8))
            .accessibilityLabel(Text("Constellation Atlas"))
    }
}

public struct AtmosphereComposerObject: View {
    public init() {}
    public var body: some View {
        RoundedRectangle(cornerRadius: AmbitionsTokens.radius(.continuous), style: .continuous)
            .fill(AmbitionsTokens.color(.objectAtmosphereComposer))
            .overlay(RoundedRectangle(cornerRadius: AmbitionsTokens.radius(.continuous), style: .continuous).stroke(AmbitionsTokens.color(.objectAtmosphereRoute), lineWidth: 1))
            .accessibilityLabel(Text("Atmosphere Composer"))
    }
}

public struct LifeShapeFieldObject: View {
    public init() {}
    public var body: some View {
        Capsule(style: .continuous)
            .fill(AmbitionsTokens.color(.objectLifeShapeBody))
            .overlay(Capsule(style: .continuous).stroke(AmbitionsTokens.color(.objectLifeShapeProtected), lineWidth: 1))
            .accessibilityLabel(Text("LifeShape Field"))
    }
}

public struct UserSystemProfileObject: View {
    public init() {}
    public var body: some View {
        Circle()
            .fill(AmbitionsTokens.color(.objectUserSystemIdentity))
            .overlay(Circle().stroke(AmbitionsTokens.color(.objectUserSystemBoundary), lineWidth: 1))
            .accessibilityLabel(Text("User System Profile"))
    }
}
