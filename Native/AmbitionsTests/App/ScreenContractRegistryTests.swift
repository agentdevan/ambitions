import XCTest
@testable import Ambitions

final class ScreenContractRegistryTests: XCTestCase {
    func testD10RegistryCoversScreenMatrixRowsInOrder() {
        XCTAssertEqual(
            ScreenContractRegistry.contracts.map(\.id),
            [
                .today,
                .goals,
                .goalDetail,
                .capture,
                .time,
                .you,
                .lifeAreasOverview,
                .northStarDetail,
                .oneStepGoalDetail,
                .review,
                .trustCenter,
                .whatAmbitionsKnows,
                .archive,
                .externalSurfaces
            ]
        )

        XCTAssertEqual(
            ScreenContractRegistry.contracts.map(\.title),
            [
                "Today",
                "Goals",
                "Goal Detail",
                "Capture Composer",
                "Time",
                "You",
                "Life Areas Overview",
                "North Star Detail",
                "Task / One-Step Goal Detail",
                "Review",
                "Trust Center",
                "What Ambitions Knows",
                "Archive",
                "External Surfaces"
            ]
        )
    }

    func testD10TopLevelContractsMatchCanonicalFourSurfaceShell() {
        XCTAssertEqual(AppTab.allCases.map(\.title), ScreenContractValidator.canonicalTopLevelTabs)
        XCTAssertEqual(
            ScreenContractRegistry.contracts.compactMap(\.canonicalTopLevelTitle),
            ScreenContractValidator.canonicalTopLevelTabs
        )
        XCTAssertTrue(ScreenContractValidator.validateRegistry(ScreenContractRegistry.contracts).isEmpty)
        XCTAssertNil(ScreenContractRegistry.contract(for: .capture).canonicalTopLevelTitle)
    }

    func testD10RegistryHasUniqueIDsImplementationAnchorsAndRootGuardrails() {
        let ids = ScreenContractRegistry.contracts.map(\.id)
        XCTAssertEqual(Set(ids).count, ids.count)

        for contract in ScreenContractRegistry.contracts {
            XCTAssertFalse(contract.requiredFirstScreenContent.isEmpty, "\(contract.id) has no first-screen content contract.")
            XCTAssertFalse(contract.requiredPanels.isEmpty, "\(contract.id) has no required panel contract.")
            XCTAssertFalse(contract.primaryActions.isEmpty, "\(contract.id) has no primary action contract.")
            XCTAssertFalse(contract.densityBehavior.isEmpty, "\(contract.id) has no density behavior.")
            XCTAssertFalse(contract.panelSizeBehavior.isEmpty, "\(contract.id) has no panel size behavior.")
            XCTAssertFalse(contract.accessibilityRequirements.isEmpty, "\(contract.id) has no accessibility requirements.")
            XCTAssertFalse(contract.trustPrivacyRequirements.isEmpty, "\(contract.id) has no trust/privacy requirements.")
            XCTAssertFalse(contract.evidenceAnchors.isEmpty, "\(contract.id) has no implementation evidence anchors.")
            XCTAssertTrue(contract.guardrails.contains(.noAIWrapperLanguage), "\(contract.id) can reintroduce AI-wrapper copy.")
            XCTAssertTrue(contract.guardrails.contains(.noColorOnlyMeaning), "\(contract.id) can rely on color only.")
            XCTAssertTrue(contract.guardrails.contains(.noGestureOnlyNavigation), "\(contract.id) can rely on gesture-only navigation.")
            XCTAssertTrue(contract.guardrails.contains(.privacySafeByDefault), "\(contract.id) lacks privacy default.")
        }

        XCTAssertEqual(ScreenContractValidator.canonicalTopLevelTabs, ["Today", "Goals", "Time", "You"])
        XCTAssertFalse(ScreenContractValidator.canonicalTopLevelTabs.contains("Capture"))
        XCTAssertFalse(ScreenContractValidator.canonicalTopLevelTabs.contains("Motion"))
    }

    func testD10DependenciesConnectD03ThroughD09Foundations() {
        let representedDependencies = Set(ScreenContractRegistry.contracts.flatMap(\.dependencies))

        XCTAssertTrue(representedDependencies.isSuperset(of: Set(ScreenContractDependency.allCases)))

        XCTAssertTrue(ScreenContractRegistry.contract(for: .capture).dependencies.contains(.d06SmartAttachment))
        XCTAssertEqual(ScreenContractRegistry.contract(for: .capture).implementationStatus, .composerOverlay)
        XCTAssertTrue(ScreenContractRegistry.contract(for: .goals).dependencies.contains(.d07LifeAreasAtlas))
        XCTAssertTrue(ScreenContractRegistry.contract(for: .goals).dependencies.contains(.d08NorthStars))
        XCTAssertTrue(ScreenContractRegistry.contract(for: .goals).dependencies.contains(.d09OneStepGoals))
        XCTAssertTrue(ScreenContractRegistry.contract(for: .you).dependencies.contains(.d03GroupedNavigationList))
        XCTAssertTrue(ScreenContractRegistry.contract(for: .today).dependencies.contains(.d04PanelDensitySize))
        XCTAssertTrue(ScreenContractRegistry.contract(for: .trustCenter).dependencies.contains(.d05ReceiptsActionClosure))
    }

    func testD10FoundationOnlyDetailContractsDoNotPretendToBeTopLevelSurfaces() {
        let northStar = ScreenContractRegistry.contract(for: .northStarDetail)
        let oneStepGoal = ScreenContractRegistry.contract(for: .oneStepGoalDetail)
        let lifeAreas = ScreenContractRegistry.contract(for: .lifeAreasOverview)

        XCTAssertEqual(northStar.implementationStatus, .foundationReady)
        XCTAssertEqual(oneStepGoal.implementationStatus, .foundationReady)
        XCTAssertEqual(lifeAreas.implementationStatus, .foundationReady)
        XCTAssertNil(northStar.canonicalTopLevelTitle)
        XCTAssertNil(oneStepGoal.canonicalTopLevelTitle)
        XCTAssertNil(lifeAreas.canonicalTopLevelTitle)
        XCTAssertTrue(oneStepGoal.guardrails.contains(.noTopLevelTasksTab))
    }

    func testD10ValidatorAcceptsCompleteScreenSnapshot() {
        let contract = ScreenContractRegistry.contract(for: .today)
        let snapshot = ScreenContractImplementationSnapshot(
            screenID: .today,
            firstScreenContent: contract.requiredFirstScreenContent,
            panels: contract.requiredPanels,
            actions: contract.primaryActions,
            drillDowns: contract.drillDowns,
            copySamples: ["Save the Day", "Park / Not Today"],
            topLevelTabTitles: ScreenContractValidator.canonicalTopLevelTabs,
            supportsDensityBehavior: true,
            supportsPanelSizeBehavior: true,
            hasAccessibilitySummary: true,
            hasPrivacySafeState: true,
            hasGestureAlternative: true
        )

        XCTAssertTrue(ScreenContractValidator.validate(snapshot: snapshot, against: contract).isEmpty)
    }

    func testD10ValidatorFindsMissingMatrixPieces() {
        let contract = ScreenContractRegistry.contract(for: .today)
        let snapshot = ScreenContractImplementationSnapshot(
            screenID: .today,
            firstScreenContent: ["Reality Meridian", "Now Layer"],
            panels: [.heroDecision, .nowLayer],
            actions: [.start],
            copySamples: ["What matters now?"],
            topLevelTabTitles: ScreenContractValidator.canonicalTopLevelTabs
        )

        let issueKinds = Set(ScreenContractValidator.validate(snapshot: snapshot, against: contract).map(\.kind))

        XCTAssertTrue(issueKinds.contains(.missingFirstScreenContent))
        XCTAssertTrue(issueKinds.contains(.missingRequiredPanel))
        XCTAssertTrue(issueKinds.contains(.missingPrimaryAction))
        XCTAssertTrue(issueKinds.contains(.missingDensityBehavior))
        XCTAssertTrue(issueKinds.contains(.missingPanelSizeBehavior))
        XCTAssertTrue(issueKinds.contains(.missingAccessibilitySummary))
        XCTAssertTrue(issueKinds.contains(.missingPrivacySafeState))
        XCTAssertTrue(issueKinds.contains(.missingGestureAlternative))
    }

    func testD10ValidatorFlagsForbiddenCopyAndOldTopLevelTabs() {
        let contract = ScreenContractRegistry.contract(for: .goals)
        let snapshot = ScreenContractImplementationSnapshot(
            screenID: .goals,
            firstScreenContent: contract.requiredFirstScreenContent + ["Standalone task board"],
            panels: contract.requiredPanels,
            actions: contract.primaryActions,
            copySamples: ["AI " + "Confidence says you are behind."],
            topLevelTabTitles: ["Today", "Goals", "Tasks", "Plan", "Profile"],
            supportsDensityBehavior: true,
            supportsPanelSizeBehavior: true,
            hasAccessibilitySummary: true,
            hasPrivacySafeState: true,
            hasGestureAlternative: true
        )

        let issues = ScreenContractValidator.validate(snapshot: snapshot, against: contract)
        let issueKinds = Set(issues.map(\.kind))

        XCTAssertTrue(issueKinds.contains(.forbiddenFirstScreenContent))
        XCTAssertTrue(issueKinds.contains(.forbiddenCopy))
        XCTAssertTrue(issueKinds.contains(.invalidTopLevelTabs))
    }

    func testD10ValidatorFlagsCaptureAndMotionAsInvalidTopLevelTabs() {
        let contract = ScreenContractRegistry.contract(for: .capture)
        let snapshot = ScreenContractImplementationSnapshot(
            screenID: .capture,
            firstScreenContent: contract.requiredFirstScreenContent,
            panels: contract.requiredPanels,
            actions: contract.primaryActions,
            copySamples: ["Capture remains a composer overlay."],
            topLevelTabTitles: ["Today", "Goals", "Capture", "Time", "Motion", "You"],
            supportsDensityBehavior: true,
            supportsPanelSizeBehavior: true,
            hasAccessibilitySummary: true,
            hasPrivacySafeState: true,
            hasGestureAlternative: true
        )

        let issues = ScreenContractValidator.validate(snapshot: snapshot, against: contract)

        XCTAssertTrue(issues.contains { $0.kind == .invalidTopLevelTabs })
    }

    func testD20ScreenContractsUseHumanStateLanguage() {
        let forbidden = [
            "AI Confidence",
            "AI Explanation",
            "Model Reasoning",
            "Fix AI",
            "Mission Control",
            "Personal System Center",
            "Action Closure",
            "Proof Rail",
            "Believability hero",
            "Confidence score"
        ]
        var contractCopy: [String] = []
        for contract in ScreenContractRegistry.contracts {
            contractCopy.append(contract.dominantQuestion)
            contractCopy.append(contract.densityBehavior)
            contractCopy.append(contract.panelSizeBehavior)
            contractCopy.append(contentsOf: contract.requiredFirstScreenContent)
            contractCopy.append(contentsOf: contract.forbiddenFirstScreenContent)
            contractCopy.append(contentsOf: contract.drillDowns)
            contractCopy.append(contentsOf: contract.accessibilityRequirements)
            contractCopy.append(contentsOf: contract.trustPrivacyRequirements)
            contractCopy.append(contentsOf: contract.evidenceAnchors.map(\.note))
        }

        for term in forbidden {
            XCTAssertFalse(contractCopy.contains { $0.localizedCaseInsensitiveContains(term) }, "Screen contracts still expose stale D20 copy: \(term)")
        }

        XCTAssertEqual(ScreenContractRegistry.contract(for: .goalDetail).requiredFirstScreenContent[1], "Goal detail lanes")
        XCTAssertTrue(ScreenContractRegistry.contract(for: .time).requiredFirstScreenContent.contains("LifeShape Field"))
        XCTAssertTrue(ScreenContractRegistry.contract(for: .capture).requiredFirstScreenContent.contains("Changeable route receipt"))
        XCTAssertFalse(ScreenContractRegistry.contract(for: .capture).requiredFirstScreenContent.contains("Capture Anything"))
    }

    func testD10ExternalSurfacesRemainContractOnlyUntilD22() {
        let external = ScreenContractRegistry.contract(for: .externalSurfaces)

        XCTAssertEqual(external.implementationStatus, .contractOnly)
        XCTAssertEqual(external.owningBatch, "D22")
        XCTAssertTrue(external.dependencies.contains(.d05ReceiptsActionClosure))
        XCTAssertTrue(external.guardrails.contains(.privacySafeByDefault))
        XCTAssertTrue(external.guardrails.contains(.receiptsForMeaningfulChanges))
    }

    func testD10ContractsHandOffToD11ThroughD19WithoutImplementingThoseSurfaces() {
        let ownersByScreen = Dictionary(
            uniqueKeysWithValues: ScreenContractRegistry.contracts.map { ($0.id, $0.owningBatch) }
        )

        XCTAssertEqual(ownersByScreen[.today], "D11")
        XCTAssertEqual(ownersByScreen[.capture], "D12")
        XCTAssertEqual(ownersByScreen[.goals], "D13")
        XCTAssertEqual(ownersByScreen[.goalDetail], "D14")
        XCTAssertEqual(ownersByScreen[.time], "D15")
        XCTAssertEqual(ownersByScreen[.you], "D17")
        XCTAssertEqual(ownersByScreen[.trustCenter], "D18")
        XCTAssertEqual(ownersByScreen[.whatAmbitionsKnows], "D19")
    }
}
