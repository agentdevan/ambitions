import Foundation

enum QualityGateID: String, CaseIterable, Sendable, Hashable {
    case architecture
    case fileSize
    case forbiddenLanguage
    case designTokens
    case shellChrome
    case safeArea
    case dynamicType
    case motionReduction
    case performanceBudget
    case visualRegression
    case scenarioMatrix
    case actionMutationProof
    case lifeShapeFixture
    case lifeShapeConstruction
    case lifeShapeDerivation
    case lifeShapeFakePrecision
    case lifeShapeMutation
    case lifeShapeTodayCoupling
    case lifeShapeSemantic
    case singleOwner
    case productObjectDominance
    case rootReportPanel
    case projectionTruth
    case userLanguageCategory
    case testStrength
    case visualTargetArtifact
    case deviceEvidence
}

struct QualityGateContract: Identifiable, Sendable, Hashable {
    let id: QualityGateID
    let owner: String
    let executableCheck: String
    let failureIsGreenBlocker: Bool
}

enum QualityGateChecklist {
    static let executableScript = ".github/workflows/code-quality.yml"

    static let contracts: [QualityGateContract] = [
        QualityGateContract(id: .architecture, owner: "Quality/Architecture", executableCheck: executableScript, failureIsGreenBlocker: true),
        QualityGateContract(id: .fileSize, owner: "Quality/FileSize", executableCheck: executableScript, failureIsGreenBlocker: true),
        QualityGateContract(id: .forbiddenLanguage, owner: "Language/ForbiddenTopLevelTerms", executableCheck: executableScript, failureIsGreenBlocker: true),
        QualityGateContract(id: .designTokens, owner: "DesignSystem/Foundations", executableCheck: executableScript, failureIsGreenBlocker: true),
        QualityGateContract(id: .shellChrome, owner: "Stage/Chrome", executableCheck: executableScript, failureIsGreenBlocker: true),
        QualityGateContract(id: .safeArea, owner: "Stage/StageSafeAreaPolicy", executableCheck: executableScript, failureIsGreenBlocker: true),
        QualityGateContract(id: .dynamicType, owner: "DesignSystem/Accessibility/DynamicTypePolicy", executableCheck: executableScript, failureIsGreenBlocker: true),
        QualityGateContract(id: .motionReduction, owner: "DesignSystem/Accessibility/ReduceMotionPolicy", executableCheck: executableScript, failureIsGreenBlocker: true),
        QualityGateContract(id: .performanceBudget, owner: "Quality/PerformanceBudgets", executableCheck: executableScript, failureIsGreenBlocker: true),
        QualityGateContract(id: .visualRegression, owner: "Quality/VisualRegressionHarness", executableCheck: executableScript, failureIsGreenBlocker: true),
        QualityGateContract(id: .scenarioMatrix, owner: "Scenarios/ScenarioMatrix", executableCheck: executableScript, failureIsGreenBlocker: true),
        QualityGateContract(id: .actionMutationProof, owner: "Projection/Mutations", executableCheck: executableScript, failureIsGreenBlocker: true),
        QualityGateContract(id: .lifeShapeFixture, owner: LifeShapeFixtureAudit.owner, executableCheck: executableScript, failureIsGreenBlocker: true),
        QualityGateContract(id: .lifeShapeConstruction, owner: LifeShapeConstructionAudit.owner, executableCheck: executableScript, failureIsGreenBlocker: true),
        QualityGateContract(id: .lifeShapeDerivation, owner: LifeShapeDerivationAudit.owner, executableCheck: executableScript, failureIsGreenBlocker: true),
        QualityGateContract(id: .lifeShapeFakePrecision, owner: LifeShapeFakePrecisionAudit.owner, executableCheck: executableScript, failureIsGreenBlocker: true),
        QualityGateContract(id: .lifeShapeMutation, owner: LifeShapeMutationAudit.owner, executableCheck: executableScript, failureIsGreenBlocker: true),
        QualityGateContract(id: .lifeShapeTodayCoupling, owner: LifeShapeTodayCouplingAudit.owner, executableCheck: executableScript, failureIsGreenBlocker: true),
        QualityGateContract(id: .lifeShapeSemantic, owner: LifeShapeSemanticAudit.owner, executableCheck: executableScript, failureIsGreenBlocker: true),
        QualityGateContract(id: .singleOwner, owner: SingleOwnerAudit.owner, executableCheck: executableScript, failureIsGreenBlocker: true),
        QualityGateContract(id: .productObjectDominance, owner: ProductObjectDominanceAudit.owner, executableCheck: executableScript, failureIsGreenBlocker: true),
        QualityGateContract(id: .rootReportPanel, owner: RootReportPanelAudit.owner, executableCheck: executableScript, failureIsGreenBlocker: true),
        QualityGateContract(id: .projectionTruth, owner: ProjectionTruthAudit.owner, executableCheck: executableScript, failureIsGreenBlocker: true),
        QualityGateContract(id: .userLanguageCategory, owner: UserLanguageCategoryAudit.owner, executableCheck: executableScript, failureIsGreenBlocker: true),
        QualityGateContract(id: .testStrength, owner: TestStrengthAudit.owner, executableCheck: executableScript, failureIsGreenBlocker: true),
        QualityGateContract(id: .visualTargetArtifact, owner: VisualTargetArtifactAudit.owner, executableCheck: executableScript, failureIsGreenBlocker: true),
        QualityGateContract(id: .deviceEvidence, owner: DeviceEvidenceAudit.owner, executableCheck: executableScript, failureIsGreenBlocker: true)
    ]

    static func validationIssues(_ contracts: [QualityGateContract] = contracts) -> [String] {
        var issues: [String] = []
        let ids = contracts.map(\.id)

        for required in QualityGateID.allCases where ids.contains(required) == false {
            issues.append("Missing quality gate: \(required.rawValue).")
        }
        if Set(ids).count != ids.count {
            issues.append("Quality gate ids must be unique.")
        }
        for contract in contracts where contract.failureIsGreenBlocker == false {
            issues.append("\(contract.id.rawValue) must block Green when failing.")
        }
        for contract in contracts where contract.executableCheck != executableScript {
            issues.append("\(contract.id.rawValue) must run through \(executableScript).")
        }

        return issues
    }
}
