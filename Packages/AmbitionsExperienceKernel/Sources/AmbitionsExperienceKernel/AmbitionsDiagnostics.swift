import Foundation

public enum AmbitionsReadinessColor: String, Sendable, Codable {
    case green
    case yellow
    case red
}

public struct AmbitionsReadinessFinding: Equatable, Sendable, Codable {
    public let color: AmbitionsReadinessColor
    public let title: String
    public let detail: String

    public init(color: AmbitionsReadinessColor, title: String, detail: String) {
        self.color = color
        self.title = title
        self.detail = detail
    }
}

public struct AmbitionsReadinessReport: Equatable, Sendable, Codable {
    public let color: AmbitionsReadinessColor
    public let findings: [AmbitionsReadinessFinding]

    public init(color: AmbitionsReadinessColor, findings: [AmbitionsReadinessFinding]) {
        self.color = color
        self.findings = findings
    }
}

public enum AmbitionsSurfaceVerifier {
    public static func verify(_ contracts: [AmbitionsSurface: AmbitionsSurfaceContract] = AmbitionsSurfaceContracts.canonical) -> AmbitionsReadinessReport {
        var findings: [AmbitionsReadinessFinding] = []
        if contracts[.today]?.primaryObject != .realityMeridian {
            findings.append(.init(color: .red, title: "Today primary object mismatch", detail: "Today must resolve to Reality Meridian."))
        }
        if contracts[.today]?.decisionLayers.contains(.startHere) != true {
            findings.append(.init(color: .red, title: "Start here hierarchy mismatch", detail: "Start here must be a decision layer inside Today."))
        }
        for surface in AmbitionsSurface.allCases where contracts[surface] == nil {
            findings.append(.init(color: .red, title: "Missing surface contract", detail: surface.rawValue))
        }
        let color: AmbitionsReadinessColor = findings.contains(where: { $0.color == .red }) ? .red : .green
        return .init(color: color, findings: findings)
    }
}

public enum AmbitionsDesignAuthority {
    public static func evaluate(sourceText: String) -> [String] {
        let blockedTerms = [String(["p","a","n","e","l"]), String(["c","a","r","d"]), String(["d","a","s","h","b","o","a","r","d"]), String(["c","h","a","t","b","o","t"])]
        let blockedAPIs = [
            ".buttonStyle(" + ".bordered",
            ".navigationBarTitleDisplayMode(" + ".large)",
            "Color(" + "#"
        ]
        return (blockedTerms + blockedAPIs).filter { sourceText.localizedCaseInsensitiveContains($0) }
    }
}

public struct AmbitionsPerformanceBudget: Equatable, Sendable, Codable {
    public let maxAnimatedLayersPerSurface: Int
    public let maxBlurSurfaces: Int
    public let targetFrameRate: Int
    public let maxReceiptRowsInline: Int

    public init(maxAnimatedLayersPerSurface: Int = 4, maxBlurSurfaces: Int = 2, targetFrameRate: Int = 60, maxReceiptRowsInline: Int = 3) {
        self.maxAnimatedLayersPerSurface = maxAnimatedLayersPerSurface
        self.maxBlurSurfaces = maxBlurSurfaces
        self.targetFrameRate = targetFrameRate
        self.maxReceiptRowsInline = maxReceiptRowsInline
    }
}
