import Foundation

struct AmbitionsSurfaceContract: Hashable, Sendable {
    let tab: AmbitionsSurface
    let title: String
    let primaryObject: SurfacePrimaryObject
    let actionContract: SurfaceActionContract
    let disclosureContract: SurfaceDisclosureContract
    let runtimeInspectionRequirements: [String]

    var primaryObjectTitle: String {
        primaryObject.rawValue
    }

    init(
        tab: AmbitionsSurface,
        title: String,
        primaryObject: SurfacePrimaryObject,
        actionContract: SurfaceActionContract? = nil,
        disclosureContract: SurfaceDisclosureContract? = nil,
        runtimeInspectionRequirements: [String] = AmbitionsSurfaceContractRegistry.runtimeInspectionRequirements
    ) {
        self.tab = tab
        self.title = title
        self.primaryObject = primaryObject
        self.actionContract = actionContract ?? SurfaceActionContract.contract(for: tab)
        self.disclosureContract = disclosureContract ?? SurfaceDisclosureContract.contract(for: tab)
        self.runtimeInspectionRequirements = runtimeInspectionRequirements
    }

    init(
        tab: AmbitionsSurface,
        title: String,
        primaryObjectTitle: String,
        runtimeInspectionRequirements: [String] = AmbitionsSurfaceContractRegistry.runtimeInspectionRequirements
    ) {
        self.init(
            tab: tab,
            title: title,
            primaryObject: SurfacePrimaryObject.allCases.first { $0.rawValue == primaryObjectTitle } ?? SurfacePrimaryObject.primary(for: tab),
            runtimeInspectionRequirements: runtimeInspectionRequirements
        )
    }
}

enum AmbitionsSurfaceContractRegistry {
    static let runtimeInspectionRequirements = [
        "SourceRecord",
        "Receipt",
        "ReplayTrace",
        "You / Search Ambitions"
    ]

    static let canonicalContracts: [AmbitionsSurfaceContract] = AmbitionsSurface.allCases.map { surface in
        AmbitionsSurfaceContract(
            tab: surface,
            title: surface.title,
            primaryObject: SurfacePrimaryObject.primary(for: surface)
        )
    }

    static func contract(for tab: AmbitionsSurface) -> AmbitionsSurfaceContract {
        guard let contract = canonicalContracts.first(where: { $0.tab == tab }) else {
            preconditionFailure("Missing Ambitions surface contract for \(tab.rawValue)")
        }
        return contract
    }

    static func validate(_ contracts: [AmbitionsSurfaceContract] = canonicalContracts) -> [String] {
        SurfaceLawAudit.audit(contracts: contracts)
    }
}
