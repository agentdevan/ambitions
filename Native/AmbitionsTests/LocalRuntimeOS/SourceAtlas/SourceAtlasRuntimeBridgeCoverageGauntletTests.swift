import XCTest
@testable import Ambitions

final class SourceAtlasRuntimeBridgeCoverageGauntletTests: XCTestCase {
    func testCoverageCatalogIncludesTheRequiredDimensionCountsAndGoalFamilies() throws {
        let catalog = CoverageCatalog.make(using: self)

        XCTAssertEqual(catalog.intents.count, 100)
        XCTAssertEqual(catalog.lifeContextProfiles.count, 20)
        XCTAssertEqual(catalog.scheduleRealities.count, 10)
        XCTAssertEqual(catalog.accessStates.count, 10)
        XCTAssertEqual(catalog.historyStates.count, 10)
        XCTAssertEqual(catalog.riskClasses.count, 5)
        XCTAssertEqual(catalog.permutations.count, 10)
        XCTAssertEqual(catalog.intents.count * catalog.permutations.count, 1000)

        let families = Set(catalog.intents.map(\.family))
        let requiredFamilies: Set<String> = [
            "sports performance",
            "creative release",
            "music production",
            "app launch",
            "coding skill",
            "job search",
            "education/test prep",
            "debt payoff",
            "saving money",
            "fitness",
            "strength",
            "weight loss",
            "sleep",
            "home organization",
            "relationship repair habit",
            "relocation/move",
            "travel planning",
            "social life",
            "certification",
            "business launch",
            "writing/book",
            "portfolio building",
            "mountain biking/outdoor skill",
            "mental recovery / burnout-safe planning",
            "instrument learning"
        ]

        XCTAssertEqual(families, requiredFamilies)
    }

    func testLaunchFloorGoldenCorpusSlicesBridgeIntoLocalRuntimeWithoutPrivateEgressOrFinalOutputs() throws {
        let catalog = CoverageCatalog.make(using: self)
        let launchFloorCorpus = try LaunchFloorGoldenIntentCorpus.loadFromRepo()
        let countedRecords = launchFloorCorpus.intents.filter { $0.countsTowardGoldenIntent }
        let launchFloorSamples = try launchFloorCorpus.bridgeSamples()
        let launchFloorLocalPermutations = [catalog.permutations[0], catalog.permutations[4]]
        let expectedCoverageLabels: Set<String> = [
            "covered",
            "source_needed",
            "stale_source",
            "candidate_only",
            "insufficient_source",
            "private_blocked",
            "illegal_out_of_scope"
        ]

        XCTAssertEqual(launchFloorCorpus.intents.count, 51_000)
        XCTAssertEqual(countedRecords.count, 50_000)
        XCTAssertEqual(Set(countedRecords.map(\.domainID)).count, 500)
        XCTAssertEqual(Set(countedRecords.map(\.subdomainID)).count, 5_000)
        XCTAssertEqual(Set(launchFloorSamples.map(\.coverageLabel)), expectedCoverageLabels)
        XCTAssertEqual(launchFloorSamples.count, 7)
        XCTAssertEqual(launchFloorLocalPermutations.count, 2)
        XCTAssertEqual(launchFloorSamples.count * launchFloorLocalPermutations.count, 14)

        for (sampleIndex, sample) in launchFloorSamples.enumerated() {
            var sourceSelectionFingerprints: Set<String> = []
            var localPersonalizationFingerprints: Set<String> = []
            var replayIDs: Set<String> = []

            for permutation in launchFloorLocalPermutations {
                let bridgePack = sample.canDriveRuntime
                    ? makeLaunchFloorPack(for: sample, generatedAt: catalog.generatedAt)
                    : catalog.emptyPack
                let match = launchFloorIntentMatch(for: sample, pack: bridgePack)
                let selection = launchFloorPackSelection(for: sample, pack: bridgePack)
                let goalID = "goal.launch-floor.\(sample.safeID).\(permutation.index)"
                let bundle = catalog.lifeContextBundle(
                    profileIndex: sampleIndex + permutation.index,
                    permutation: permutation
                )
                let projection = bundle.projection(asOf: catalog.generatedAtDate)
                let factorLedger = PersonalizationFactorLedgerBuilder().build(
                    PersonalizationFactorLedgerInput(
                        goalID: goalID,
                        goalText: sample.localRuntimeIntentText,
                        projection: projection,
                        generatedAt: catalog.generatedAtDate,
                        userContextVersion: "\(catalog.userContextVersion).launch-floor"
                    )
                )
                let composition = SourceAtlasCapabilityPathComposer(
                    goalID: goalID,
                    userContextVersion: "\(catalog.userContextVersion).launch-floor",
                    sourceAtlasProjectionID: "source-atlas.launch-floor.\(sample.safeID)",
                    packs: [bridgePack],
                    match: match,
                    selection: selection,
                    lifeContextProjection: projection,
                    factorLedger: factorLedger
                )
                .compose()
                let field = SourceAtlasStepCandidateFieldBridge().expand(
                    goalID: goalID,
                    composition: composition,
                    pack: bridgePack,
                    generatedAt: catalog.generatedAt,
                    deadlineTargetDate: permutation.deadlineTargetDate,
                    factorLedger: factorLedger,
                    lifeContextProjection: projection,
                    candidateLimit: 8,
                    localOnly: true
                )
                let replay = SourceAtlasRuntimeBridgeReplay(
                    intentMatch: match,
                    packSelection: selection,
                    pathComposition: composition,
                    stepCandidateField: field,
                    factorLedger: factorLedger,
                    generatedAt: catalog.generatedAt,
                    localOnly: true
                )
                let encoded = try encodedJSONString(replay)

                sourceSelectionFingerprints.insert(sourceSelectionFingerprint(selection))
                localPersonalizationFingerprints.insert(replay.factorLedgerFingerprint)
                replayIDs.insert(replay.id)

                XCTAssertTrue(sample.publicReferenceOnly)
                XCTAssertFalse(sample.finalOutputAllowed)
                XCTAssertEqual(field.localOnly, true)
                XCTAssertEqual(replay.localOnly, true)
                XCTAssertEqual(replay.schemaVersion, sourceAtlasBridgeReplaySchemaVersion)
                XCTAssertEqual(replay.packSelection.canDriveRuntime, sample.canDriveRuntime)
                XCTAssertEqual(replay.receiptKinds.last, .sourceAtlasReplayGenerated)
                XCTAssertTrue(bridgePack.starterItems.allSatisfy { $0.storesFinalSchedule == false })

                if sample.canDriveRuntime {
                    XCTAssertFalse(selection.selectedPackIDs.isEmpty)
                    XCTAssertTrue(selection.canDriveRuntime)
                    XCTAssertFalse(composition.pathInstances.isEmpty)
                    XCTAssertNotEqual(field.selectedCandidate?.kind, StepCandidateKind.fallback)
                    XCTAssertTrue(replay.receiptKinds.contains(.sourceAtlasPackSelected))
                    XCTAssertFalse(replay.receiptKinds.contains(.sourceAtlasUnsupportedGoalFallback))
                } else {
                    XCTAssertTrue(selection.selectedPackIDs.isEmpty)
                    XCTAssertFalse(selection.canDriveRuntime)
                    XCTAssertEqual(composition.selectedPath.capabilityGraphID, "source-atlas.graph.fallback")
                    XCTAssertEqual(field.selectedCandidate?.kind, StepCandidateKind.fallback)
                    XCTAssertTrue(replay.receiptKinds.contains(.sourceAtlasUnsupportedGoalFallback))
                }

                if sample.requiresRawIntentRedaction {
                    XCTAssertTrue(replay.intent.rawGoalTextWasRedacted)
                    XCTAssertFalse(encoded.contains(sample.sanitizedIntentClass))
                    XCTAssertTrue(encoded.contains("[redacted]"))
                } else {
                    XCTAssertFalse(replay.intent.rawGoalTextWasRedacted)
                }

                XCTAssertFalse(encoded.contains("PRIVATE-RAW-TEXT-LEAK-MARKER"))
                XCTAssertFalse(encoded.contains("PRIVATE-CUSTOM-REASON-LEAK-MARKER"))
                XCTAssertFalse(encoded.localizedCaseInsensitiveContains("account_id"))
                XCTAssertFalse(encoded.localizedCaseInsensitiveContains("device_id"))
                XCTAssertFalse(encoded.localizedCaseInsensitiveContains("goal_text"))
                XCTAssertFalse(encoded.localizedCaseInsensitiveContains("final personalized plan"))
                XCTAssertFalse(encoded.localizedCaseInsensitiveContains("final schedule"))
                XCTAssertFalse(encoded.localizedCaseInsensitiveContains("final step"))
            }

            XCTAssertEqual(sourceSelectionFingerprints.count, 1)
            XCTAssertEqual(localPersonalizationFingerprints.count, launchFloorLocalPermutations.count)
            XCTAssertEqual(replayIDs.count, launchFloorLocalPermutations.count)
        }
    }

    func testCoverageGauntletAcrossHundredIntentsAndTenContextPermutations() throws {
        let catalog = CoverageCatalog.make(using: self)
        let packLookup = Dictionary(uniqueKeysWithValues: catalog.packs.map { ($0.manifest.id, $0) })
        let matcher = SourceAtlasIntentMatcher(packs: catalog.packs)

        var supportedScenarioCount = 0
        var unsupportedScenarioCount = 0
        var redactedScenarioCount = 0
        var impossibleTimelineCount = 0
        var pathIDs: Set<String> = []
        var replayIDs: Set<String> = []
        var replayFingerprints: Set<String> = []

        for intent in catalog.intents {
            for permutation in catalog.permutations {
                let evaluation = matcher.evaluate(rawGoalText: intent.rawGoalText)
                let selectedPack = evaluation.selection.selectedPackIDs.first.flatMap { packLookup[$0] } ?? catalog.emptyPack
                let bundle = catalog.lifeContextBundle(
                    profileIndex: intent.index % catalog.lifeContextProfiles.count,
                    permutation: permutation
                )
                let projection = bundle.projection(asOf: catalog.generatedAtDate)
                let factorLedger = PersonalizationFactorLedgerBuilder().build(
                    PersonalizationFactorLedgerInput(
                        goalID: intent.goalID,
                        goalText: intent.rawGoalText,
                        projection: projection,
                        generatedAt: catalog.generatedAtDate,
                        userContextVersion: catalog.userContextVersion
                    )
                )
                let composition = SourceAtlasCapabilityPathComposer(
                    goalID: intent.goalID,
                    userContextVersion: catalog.userContextVersion,
                    sourceAtlasProjectionID: catalog.sourceAtlasProjectionID,
                    packs: evaluation.selection.selectedPackIDs.isEmpty ? [catalog.emptyPack] : [selectedPack],
                    match: evaluation.match,
                    selection: evaluation.selection,
                    lifeContextProjection: projection,
                    factorLedger: factorLedger
                )
                .compose()
                let bridgePack = evaluation.selection.selectedPackIDs.isEmpty ? catalog.emptyPack : selectedPack
                let correctionInput = catalog.correctionInputIfNeeded(
                    for: intent,
                    selection: evaluation.selection,
                    selectedCandidateID: nil
                )
                let field = SourceAtlasStepCandidateFieldBridge().expand(
                    goalID: intent.goalID,
                    composition: composition,
                    pack: bridgePack,
                    generatedAt: catalog.generatedAt,
                    deadlineTargetDate: permutation.deadlineTargetDate,
                    factorLedger: factorLedger,
                    lifeContextProjection: projection,
                    candidateLimit: 12,
                    localOnly: true
                )
                let replay = SourceAtlasRuntimeBridgeReplay(
                    intentMatch: evaluation.match,
                    packSelection: evaluation.selection,
                    pathComposition: composition,
                    stepCandidateField: field,
                    factorLedger: factorLedger,
                    correctionInput: correctionInput,
                    generatedAt: catalog.generatedAt,
                    localOnly: true
                )
                let replayAgain = SourceAtlasRuntimeBridgeReplay(
                    intentMatch: evaluation.match,
                    packSelection: evaluation.selection,
                    pathComposition: composition,
                    stepCandidateField: field,
                    factorLedger: factorLedger,
                    correctionInput: correctionInput,
                    generatedAt: catalog.generatedAt,
                    localOnly: true
                )

                pathIDs.insert(composition.selectedPath.id)
                replayIDs.insert(replay.id)
                replayFingerprints.insert(replay.factorLedgerFingerprint)

                if intent.expectedSupported {
                    supportedScenarioCount += 1
                } else {
                    unsupportedScenarioCount += 1
                }
                if replay.intent.rawGoalTextWasRedacted || replay.receipts.contains(where: \.isRedacted) {
                    redactedScenarioCount += 1
                }
                if intent.expectedSupported &&
                    field.selectedCandidate?.impactSimulation.goalTimeline.planRisk.isImpossible == true {
                    impossibleTimelineCount += 1
                }

                assertScenario(
                    intent: intent,
                    permutation: permutation,
                    evaluation: evaluation,
                    selectedPack: bridgePack,
                    projection: projection,
                    factorLedger: factorLedger,
                    composition: composition,
                    field: field,
                    replay: replay,
                    replayAgain: replayAgain,
                    generatedAt: catalog.generatedAt,
                    userContextVersion: catalog.userContextVersion
                )
            }
        }

        XCTAssertEqual(supportedScenarioCount + unsupportedScenarioCount, 1000)
        XCTAssertGreaterThan(supportedScenarioCount, 0)
        XCTAssertGreaterThan(unsupportedScenarioCount, 0)
        XCTAssertGreaterThan(redactedScenarioCount, 0)
        XCTAssertEqual(impossibleTimelineCount, 0)
        XCTAssertGreaterThan(pathIDs.count, 1)
        XCTAssertGreaterThan(replayIDs.count, 1)
        XCTAssertGreaterThan(replayFingerprints.count, 1)
    }
}

private extension SourceAtlasRuntimeBridgeCoverageGauntletTests {
    struct LaunchFloorGoldenIntentCorpus: Decodable {
        let intents: [LaunchFloorGoldenIntentRecord]

        static func loadFromRepo() throws -> LaunchFloorGoldenIntentCorpus {
            let data = try Data(contentsOf: SourceAtlasRuntimeBridgeCoverageGauntletTests.repoRoot().appendingPathComponent(
                "tools/source-atlas/generated/source-atlas-launch-floor-golden-intent-corpus/lff-m03-l02-current/launch-floor-golden-intent-corpus.json"
            ))
            return try JSONDecoder().decode(LaunchFloorGoldenIntentCorpus.self, from: data)
        }

        func bridgeSamples() throws -> [LaunchFloorGoldenIntentRecord] {
            let requiredLabels = [
                "covered",
                "source_needed",
                "stale_source",
                "candidate_only",
                "insufficient_source",
                "private_blocked",
                "illegal_out_of_scope"
            ]
            var samplesByLabel: [String: LaunchFloorGoldenIntentRecord] = [:]
            for record in intents where requiredLabels.contains(record.coverageLabel) && samplesByLabel[record.coverageLabel] == nil {
                samplesByLabel[record.coverageLabel] = record
            }
            return try requiredLabels.map { label in
                guard let sample = samplesByLabel[label] else {
                    throw LaunchFloorGoldenIntentCorpusIssue.missingCoverageLabel(label)
                }
                return sample
            }
        }
    }

    enum LaunchFloorGoldenIntentCorpusIssue: Error, Equatable {
        case missingCoverageLabel(String)
    }

    struct LaunchFloorGoldenIntentRecord: Decodable, Hashable {
        let intentID: String
        let domainID: String
        let subdomainID: String
        let sanitizedIntentClass: String
        let coverageLabel: String
        let expectedRoutingState: String
        let sourceNeededCause: String
        let sourceRefs: [String]
        let lawfulIntent: Bool
        let countsTowardGoldenIntent: Bool
        let publicReferenceOnly: Bool
        let privateContextAllowed: Bool
        let finalOutputAllowed: Bool

        var safeID: String {
            intentID
                .replacingOccurrences(of: ".", with: "-")
                .replacingOccurrences(of: "_", with: "-")
        }

        var canDriveRuntime: Bool {
            lawfulIntent &&
                countsTowardGoldenIntent &&
                publicReferenceOnly &&
                privateContextAllowed == false &&
                finalOutputAllowed == false &&
                coverageLabel == "covered" &&
                expectedRoutingState == "launch_floor_public_reference_supported" &&
                sourceNeededCause == "not_required"
        }

        var requiresRawIntentRedaction: Bool {
            sanitizedIntentClass.localizedCaseInsensitiveContains("private") ||
                sanitizedIntentClass.localizedCaseInsensitiveContains("secret")
        }

        var sourceAtlasNormalizedIntent: String {
            requiresRawIntentRedaction ? "launch-floor-redacted-control" : normalizedIntent(sanitizedIntentClass)
        }

        var localRuntimeIntentText: String {
            requiresRawIntentRedaction ? "launch floor redacted control" : sanitizedIntentClass
        }

        var routeLabel: String {
            switch coverageLabel {
            case "private_blocked":
                return "blocked-control"
            case "illegal_out_of_scope":
                return "out-of-scope-control"
            default:
                return coverageLabel
            }
        }

        var skillSliceID: String {
            "skill.launch-floor.\(safeID)"
        }

        var roleID: String {
            "role.launch-floor.public-reference"
        }

        private static func normalizedIntent(_ text: String) -> String {
            let lowercased = text
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased()
            let scalarParts = lowercased.unicodeScalars.map { scalar -> String in
                if CharacterSet.alphanumerics.contains(scalar) {
                    return String(scalar)
                }
                return " "
            }
            return scalarParts
                .joined()
                .split(whereSeparator: \.isWhitespace)
                .joined(separator: "-")
        }

        private func normalizedIntent(_ text: String) -> String {
            Self.normalizedIntent(text)
        }
    }

    struct GoalIntentScenario {
        let index: Int
        let family: String
        let rawGoalText: String
        let goalID: String
        let expectedSupported: Bool
    }

    struct ScheduleReality {
        let label: String
        let deadlineTargetDate: String?
    }

    struct AccessState {
        let label: String
        let facility: LifeContextFacility
        let transportationAccess: LifeContextTransportationAccess
        let locationPrecision: LifeContextLocationPrecision
        let travelRadiusMinutes: Int?
    }

    struct HistoryState {
        let label: String
        let freshness: HistoricalContextFactFreshness
        let sourceType: HistoricalContextFactSourceType
        let usedFor: [HistoricalContextFactUse]
        let runtimeUseAllowed: Bool
    }

    struct ScenarioPermutation {
        let index: Int
        let schedule: ScheduleReality
        let access: AccessState
        let history: HistoryState
        let riskClass: SourceAtlasRiskClass
        let deadlineTargetDate: String?
    }

    struct CoverageCatalog {
        let generatedAt: String
        let generatedAtDate: Date
        let userContextVersion: String
        let sourceAtlasProjectionID: String
        let emptyPack: SourceAtlasPack
        let packs: [SourceAtlasPack]
        let intents: [GoalIntentScenario]
        let lifeContextProfiles: [LifeContextProfile]
        let scheduleRealities: [ScheduleReality]
        let accessStates: [AccessState]
        let historyStates: [HistoryState]
        let riskClasses: [SourceAtlasRiskClass]
        let permutations: [ScenarioPermutation]

        static func make(using owner: SourceAtlasRuntimeBridgeCoverageGauntletTests) -> CoverageCatalog {
            let generatedAt = "2026-05-23T18:13:20Z"
            let generatedAtDate = DomainTimestamp.date(from: generatedAt) ?? Date(timeIntervalSince1970: 1_748_000_000)
            let userContextVersion = "life-context.coverage-gauntlet.v1"
            let sourceAtlasProjectionID = "source-atlas.coverage-gauntlet.v1"

            let lifeContextProfiles = owner.makeLifeContextProfiles()
            let scheduleRealities = owner.makeScheduleRealities()
            let accessStates = owner.makeAccessStates()
            let historyStates = owner.makeHistoryStates()
            let riskClasses: [SourceAtlasRiskClass] = [.lowRiskSkill, .hobby, .sportRules, .careerContext, .financial]
            let permutations = owner.makePermutations(
                scheduleRealities: scheduleRealities,
                accessStates: accessStates,
                historyStates: historyStates,
                riskClasses: riskClasses
            )

            let packs = [
                owner.makePack(
                    id: "pack.coverage.sports",
                    generatedAt: generatedAt,
                    title: "Coverage sports pack",
                    domainID: "sports",
                    specificDomainID: "sports.coverage",
                    graphID: "graph.coverage.sports",
                    roleID: "role.coverage.sports",
                    skillSliceID: "sports.coverage.skill",
                    pathPrefix: "path.sports",
                    claimRiskClass: .sportRules,
                    goalIntents: [
                        "football speed block",
                        "football recovery block",
                        "football practice block",
                        "football review block"
                    ]
                ),
                owner.makePack(
                    id: "pack.coverage.creative",
                    generatedAt: generatedAt,
                    title: "Coverage creative pack",
                    domainID: "creative",
                    specificDomainID: "creative.coverage",
                    graphID: "graph.coverage.creative",
                    roleID: "role.coverage.creator",
                    skillSliceID: "creative.coverage.skill",
                    pathPrefix: "path.creative",
                    claimRiskClass: .hobby,
                    goalIntents: [
                        "music release mix",
                        "music release art",
                        "music release rollout",
                        "music release final",
                        "song draft session",
                        "song arrangement pass",
                        "song mix review",
                        "song master delivery"
                    ]
                ),
                owner.makePack(
                    id: "pack.coverage.financial",
                    generatedAt: generatedAt,
                    title: "Coverage financial pack",
                    domainID: "financial",
                    specificDomainID: "financial.coverage",
                    graphID: "graph.coverage.financial",
                    roleID: "role.coverage.financial",
                    skillSliceID: "financial.coverage.skill",
                    pathPrefix: "path.financial",
                    claimRiskClass: .careerContext,
                    goalIntents: [
                        "debt repayment sprint",
                        "debt repayment review",
                        "debt repayment budget",
                        "debt repayment plan"
                    ]
                )
            ]

            let intents = owner.makeGoalIntents()

            return CoverageCatalog(
                generatedAt: generatedAt,
                generatedAtDate: generatedAtDate,
                userContextVersion: userContextVersion,
                sourceAtlasProjectionID: sourceAtlasProjectionID,
                emptyPack: owner.makeEmptyPack(),
                packs: packs,
                intents: intents,
                lifeContextProfiles: lifeContextProfiles,
                scheduleRealities: scheduleRealities,
                accessStates: accessStates,
                historyStates: historyStates,
                riskClasses: riskClasses,
                permutations: permutations
            )
        }

        func lifeContextBundle(profileIndex: Int, permutation: ScenarioPermutation) -> LifeContextBundle {
            let profile = lifeContextProfiles[profileIndex % lifeContextProfiles.count]
            let access = permutation.access
            let history = permutation.history
            let source = LifeContextSource(
                id: "life-source.\(profileIndex).\(permutation.index)",
                label: "Coverage source \(profileIndex)",
                kind: .userConfirmed,
                timestamp: generatedAt,
                visibleExplanation: "Seeded from the coverage gauntlet."
            )
            let opportunity = OpportunityContext(
                id: "opportunity.\(profileIndex).\(permutation.index)",
                facilities: [access.facility],
                equipmentAccess: [access.label],
                coachingMentorAccess: access.label.localizedCaseInsensitiveContains("mentor") ? "mentor" : nil,
                localOrganizations: [profile.schoolOrWorkContext ?? profile.generalLocationLabel ?? "local"],
                eventExposureAccess: access.label.localizedCaseInsensitiveContains("event"),
                remoteAccess: access.label.localizedCaseInsensitiveContains("remote"),
                travelRequirement: access.label,
                costRequirement: history.runtimeUseAllowed ? nil : "Review needed before use.",
                seasonalAvailability: SourceAtlasRuntimeBridgeCoverageGauntletTests.scheduleAvailabilityLabel(for: permutation.schedule),
                verificationStatus: .verified
            )
            let fact = HistoricalContextFact(
                id: "history.\(profileIndex).\(permutation.index)",
                category: SourceAtlasRuntimeBridgeCoverageGauntletTests.historyCategory(for: permutation.history),
                title: permutation.history.label,
                detail: permutation.history.label,
                dateRange: LifeContextDateRange(start: "2025-01-01", end: "2026-01-01"),
                confidence: 0.8,
                sourceType: permutation.history.sourceType,
                freshness: permutation.history.freshness,
                sensitivity: .normal,
                runtimeUseAllowed: permutation.history.runtimeUseAllowed,
                usedFor: permutation.history.usedFor,
                createdAt: generatedAt,
                updatedAt: generatedAt,
                confirmedAt: generatedAt
            )

            return LifeContextBundle(
                id: "bundle.\(profileIndex).\(permutation.index)",
                profile: profile,
                eligibilityPathways: [
                    LifeContextEligibilityPathway(
                        id: "eligibility.\(profileIndex).\(permutation.index)",
                        pathwayType: .custom,
                        eligibilityRulesSummary: permutation.history.label,
                        source: source,
                        freshness: .current,
                        userConfirmed: true
                    )
                ],
                opportunityContexts: [opportunity],
                historicalFacts: [fact],
                sources: [source],
                createdAt: generatedAt,
                updatedAt: generatedAt
            )
        }

        func correctionInputIfNeeded(
            for intent: GoalIntentScenario,
            selection: SourceAtlasPackSelection,
            selectedCandidateID: String?
        ) -> SourceAtlasBridgeCorrectionInput? {
            guard intent.index % 11 == 0 || intent.index % 17 == 0 else {
                return nil
            }

            let sourceStepID = selectedCandidateID ?? "source-atlas-fallback-step"
            let rejection = StepCandidateRejectionRecord(
                candidateID: selectedCandidateID ?? "fallback.candidate",
                sourceCandidateID: selectedCandidateID,
                sourceStepID: sourceStepID,
                contextFingerprint: "coverage-gauntlet.\(intent.goalID)",
                reason: StepCandidateRejectionReason(
                    code: .custom,
                    customText: "PRIVATE-CUSTOM-REASON-LEAK-MARKER"
                ),
                skippedReason: false,
                recordedAt: generatedAt
            )

            return SourceAtlasBridgeCorrectionInput(
                rejectedPathIDs: selection.selectedPackIDs.isEmpty ? [] : ["coverage.rejected.\(intent.goalID)"],
                rejectedCandidateHistory: [rejection]
            )
        }
    }

    func assertScenario(
        intent: GoalIntentScenario,
        permutation: ScenarioPermutation,
        evaluation: (match: SourceAtlasIntentMatch, selection: SourceAtlasPackSelection),
        selectedPack: SourceAtlasPack,
        projection: LifeContextRuntimeProjection,
        factorLedger: PersonalizationFactorLedger,
        composition: PersonalPathComposition,
        field: StepCandidateField,
        replay: SourceAtlasRuntimeBridgeReplay,
        replayAgain: SourceAtlasRuntimeBridgeReplay,
        generatedAt: String,
        userContextVersion: String
    ) {
        let encoded = try? encodedJSONString(replay)

        XCTAssertEqual(replay, replayAgain)
        XCTAssertEqual(replay.id, replayAgain.id)
        XCTAssertEqual(replay.factorLedgerFingerprint, factorLedger.replayProjection.stableFingerprint)
        XCTAssertEqual(field.rankingTrace.replayFingerprint, factorLedger.replayProjection.stableFingerprint)
        XCTAssertNil(field.rankingTrace.replayReferenceID)
        XCTAssertFalse(replay.selectedRecommendation.title.isEmpty)
        XCTAssertFalse(replay.selectedRecommendation.summary.isEmpty)
        XCTAssertFalse(replay.simulationSummary.summary.isEmpty)
        XCTAssertFalse(replay.receipts.isEmpty)
        XCTAssertEqual(replay.localOnly, true)
        XCTAssertEqual(replay.schemaVersion, sourceAtlasBridgeReplaySchemaVersion)
        XCTAssertEqual(replay.intent.normalizedGoalIntent, evaluation.match.normalizedGoalIntent)
        XCTAssertEqual(replay.packSelection, evaluation.selection)
        XCTAssertEqual(composition.goalID, intent.goalID)
        XCTAssertEqual(composition.userContextVersion, userContextVersion)
        XCTAssertFalse(selectedPack.manifest.id.isEmpty)
        XCTAssertEqual(field.goalID, intent.goalID)
        XCTAssertEqual(field.generatedAt, generatedAt)
        XCTAssertEqual(field.rankingTrace.replayFingerprint, factorLedger.replayProjection.stableFingerprint)
        XCTAssertEqual(field.selectedCandidate?.impactSimulation.candidateID, field.selectedCandidateID)
        XCTAssertFalse(field.candidates.isEmpty)
        XCTAssertFalse(field.selectedCandidateID.isEmpty)
        XCTAssertFalse(field.selectedCandidate?.impactSimulation.summary.isEmpty ?? true)
        if field.selectedCandidate?.validity == .fallback {
            XCTAssertTrue(field.selectedCandidate?.impactSimulation.goalTimeline.planRisk.isImpossible ?? false)
        } else {
            XCTAssertFalse(field.selectedCandidate?.impactSimulation.goalTimeline.planRisk.isImpossible ?? true)
        }
        XCTAssertEqual(replay.receiptKinds.last, .sourceAtlasReplayGenerated)

        if evaluation.selection.selectedPackIDs.isEmpty {
            XCTAssertEqual(evaluation.selection.sourceState, .sourceNeeded)
            XCTAssertEqual(evaluation.selection.freshnessState, .unknown)
            XCTAssertEqual(evaluation.selection.riskState, .unknown)
            XCTAssertEqual(evaluation.selection.reviewState, .required)
            XCTAssertTrue(evaluation.selection.requiredUserReview)
            XCTAssertFalse(evaluation.selection.canDriveRuntime)
            XCTAssertEqual(selectedPack.manifest.id, "pack.coverage.empty")
            XCTAssertTrue(replay.receiptKinds.contains(.sourceAtlasIntentMatched))
            if field.selectedCandidate?.kind == .fallback {
                XCTAssertEqual(replay.receiptKinds.contains(.sourceAtlasUnsupportedGoalFallback), true)
            }
        } else {
            XCTAssertEqual(evaluation.selection.sourceState, .officialCurrent)
            XCTAssertEqual(evaluation.selection.freshnessState, .current)
            XCTAssertEqual(evaluation.selection.riskState, .low)
            XCTAssertEqual(evaluation.selection.reviewState, .approved)
            XCTAssertTrue(evaluation.selection.canDriveRuntime)
            XCTAssertFalse(evaluation.selection.requiredUserReview)
            XCTAssertNotEqual(field.selectedCandidate?.kind, .fallback)
            XCTAssertFalse(replay.receiptKinds.contains(.sourceAtlasUnsupportedGoalFallback))
            XCTAssertFalse(composition.pathInstances.isEmpty)
            XCTAssertFalse(composition.selectedPath.requirementProjection.allRequirements.isEmpty)
            XCTAssertGreaterThan(field.candidates.count, 1)
        }

        if intent.expectedSupported {
            XCTAssertFalse(evaluation.selection.selectedPackIDs.isEmpty)
            XCTAssertEqual(replay.intent.rawGoalTextWasRedacted, false)
        } else {
            XCTAssertTrue(evaluation.selection.selectedPackIDs.isEmpty)
            XCTAssertEqual(replay.intent.rawGoalTextWasRedacted, intent.rawGoalText.localizedCaseInsensitiveContains("private") || intent.rawGoalText.localizedCaseInsensitiveContains("secret"))
        }

        if let encoded {
            XCTAssertFalse(encoded.contains("PRIVATE-RAW-TEXT-LEAK-MARKER"))
            XCTAssertFalse(encoded.contains("PRIVATE-CUSTOM-REASON-LEAK-MARKER"))
            if intent.rawGoalText.localizedCaseInsensitiveContains("private") || intent.rawGoalText.localizedCaseInsensitiveContains("secret") {
                XCTAssertTrue(encoded.contains("[redacted]"))
            }
        }

        if intent.index % 11 == 0 || intent.index % 17 == 0 {
            XCTAssertTrue(replay.receipts.contains(where: { $0.kind == .sourceAtlasUserCorrectionApplied }))
            XCTAssertTrue(replay.receipts.contains(where: \.isRedacted))
        }

        if permutation.deadlineTargetDate?.isEmpty == false {
            XCTAssertFalse(replay.simulationSummary.summary.isEmpty)
        }

        XCTAssertFalse(replay.id.isEmpty)
        XCTAssertFalse(replay.factorLedgerFingerprint.isEmpty)
        XCTAssertFalse(replay.intent.matchTrace.isEmpty)
        XCTAssertFalse(replay.receipts.contains(where: { $0.summary.localizedCaseInsensitiveContains("private") || $0.summary.localizedCaseInsensitiveContains("secret") }))
    }

    func encodedJSONString<T: Encodable>(_ value: T) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(value)
        return String(decoding: data, as: UTF8.self)
    }

    static func repoRoot() -> URL {
        let current = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        let candidates = sequence(first: current) { url in
            let parent = url.deletingLastPathComponent()
            return parent.path == url.path ? nil : parent
        }
        for candidate in candidates {
            if FileManager.default.fileExists(atPath: candidate.appendingPathComponent("project.yml").path) {
                return candidate
            }
        }
        return current
    }

    func makeLaunchFloorPack(for sample: LaunchFloorGoldenIntentRecord, generatedAt: String) -> SourceAtlasPack {
        makePack(
            id: "pack.launch-floor.\(sample.safeID)",
            generatedAt: generatedAt,
            title: "Launch floor \(sample.domainID) pack",
            domainID: sample.domainID,
            specificDomainID: sample.subdomainID,
            graphID: "graph.launch-floor.\(sample.safeID)",
            roleID: sample.roleID,
            skillSliceID: sample.skillSliceID,
            pathPrefix: "path.launch-floor.\(sample.safeID)",
            claimRiskClass: .careerContext,
            goalIntents: [sample.sanitizedIntentClass]
        )
    }

    func sourceSelectionFingerprint(_ selection: SourceAtlasPackSelection) -> String {
        [
            selection.selectedPackIDs.joined(separator: ","),
            selection.rejectedPackIDs.joined(separator: ","),
            selection.sourceState.rawValue,
            selection.freshnessState.rawValue,
            selection.riskState.rawValue,
            selection.reviewState.rawValue,
            "\(selection.canDriveRuntime)",
            "\(selection.requiredUserReview)"
        ].joined(separator: "|")
    }

    func launchFloorIntentMatch(
        for sample: LaunchFloorGoldenIntentRecord,
        pack: SourceAtlasPack
    ) -> SourceAtlasIntentMatch {
        SourceAtlasIntentMatch(
            rawGoalText: sample.sanitizedIntentClass,
            normalizedGoalIntent: sample.sourceAtlasNormalizedIntent,
            matchedDomainIDs: sample.canDriveRuntime ? [sample.domainID] : [],
            matchedSpecificDomainIDs: sample.canDriveRuntime ? [sample.subdomainID] : [],
            matchedSkillSliceIDs: sample.canDriveRuntime ? [sample.skillSliceID] : [],
            matchedRoleIDs: sample.canDriveRuntime ? [sample.roleID] : [],
            confidenceBand: sample.canDriveRuntime ? .high : .unknown,
            missingClarifications: sample.canDriveRuntime ? [] : ["Public reference expansion required."],
            sourceAtlasPackIDs: sample.canDriveRuntime ? [pack.id] : [],
            rejectedPackIDs: sample.canDriveRuntime ? [] : ["rejected.launch-floor.\(sample.routeLabel)"],
            matchTrace: [
                "source=launch-floor-golden-corpus",
                "intent-id=\(sample.intentID)",
                "route=\(sample.routeLabel)",
                "raw=\(sample.requiresRawIntentRedaction ? "[redacted]" : sample.sanitizedIntentClass)"
            ]
        )
    }

    func launchFloorPackSelection(
        for sample: LaunchFloorGoldenIntentRecord,
        pack: SourceAtlasPack
    ) -> SourceAtlasPackSelection {
        guard sample.canDriveRuntime else {
            let rejectedPackID = "rejected.launch-floor.\(sample.routeLabel)"
            return SourceAtlasPackSelection(
                selectedPackIDs: [],
                rejectedPackIDs: [rejectedPackID],
                rejectionReasons: [
                    rejectedPackID: [
                        sample.routeLabel,
                        sample.sourceNeededCause,
                        sample.expectedRoutingState
                    ]
                ],
                sourceState: sample.coverageLabel == "stale_source" ? .stale : .sourceNeeded,
                freshnessState: sample.coverageLabel == "stale_source" ? .stale : .unknown,
                riskState: sample.coverageLabel == "illegal_out_of_scope" ? .high : .unknown,
                reviewState: ["private_blocked", "illegal_out_of_scope"].contains(sample.coverageLabel) ? .blocked : .required,
                canDriveRuntime: false,
                requiredUserReview: true
            )
        }

        return SourceAtlasPackSelection(
            selectedPackIDs: [pack.id],
            rejectedPackIDs: [],
            rejectionReasons: [:],
            sourceState: .officialCurrent,
            freshnessState: .current,
            riskState: .low,
            reviewState: .approved,
            canDriveRuntime: true,
            requiredUserReview: false
        )
    }

    func makeGoalIntents() -> [GoalIntentScenario] {
        let families: [(String, [String], Bool)] = [
            ("sports performance", [
                "football speed block",
                "football recovery block",
                "football practice block",
                "football review block"
            ], true),
            ("creative release", [
                "music release mix",
                "music release art",
                "music release rollout",
                "music release final"
            ], true),
            ("music production", [
                "song draft session",
                "song arrangement pass",
                "song mix review",
                "song master delivery"
            ], true),
            ("app launch", [
                "private launch beta build",
                "launch preview flow",
                "launch onboarding check",
                "launch store readiness"
            ], false),
            ("coding skill", [
                "secret code kata session",
                "code review practice",
                "algorithm drill",
                "debugging practice"
            ], false),
            ("job search", [
                "job search sprint",
                "resume update",
                "networking follow-up",
                "interview rehearsal"
            ], false),
            ("education/test prep", [
                "exam prep sprint",
                "study block",
                "practice test review",
                "quiz drill"
            ], false),
            ("debt payoff", [
                "debt repayment sprint",
                "debt repayment review",
                "debt repayment budget",
                "debt repayment plan"
            ], true),
            ("saving money", [
                "cash buffer plan",
                "spending review",
                "savings habit",
                "budget cleanup"
            ], false),
            ("fitness", [
                "fitness block",
                "fitness recovery",
                "fitness routine",
                "fitness check-in"
            ], false),
            ("strength", [
                "strength block",
                "strength recovery",
                "strength routine",
                "strength check-in"
            ], false),
            ("weight loss", [
                "weight loss block",
                "weight loss recovery",
                "weight loss routine",
                "weight loss check-in"
            ], false),
            ("sleep", [
                "sleep block",
                "sleep recovery",
                "sleep routine",
                "sleep check-in"
            ], false),
            ("home organization", [
                "home reset block",
                "closet reset",
                "room reset",
                "drawer reset"
            ], false),
            ("relationship repair habit", [
                "relationship repair block",
                "repair conversation",
                "repair check-in",
                "repair habit"
            ], false),
            ("relocation/move", [
                "move prep block",
                "move packing",
                "move logistics",
                "move checklist"
            ], false),
            ("travel planning", [
                "travel plan block",
                "trip planning",
                "itinerary block",
                "packing review"
            ], false),
            ("social life", [
                "social plan block",
                "social invite list",
                "social check-in",
                "social follow-up"
            ], false),
            ("certification", [
                "certification prep",
                "certification review",
                "certification practice",
                "certification plan"
            ], false),
            ("business launch", [
                "business launch block",
                "business launch review",
                "business launch checklist",
                "business launch planning"
            ], false),
            ("writing/book", [
                "writing block",
                "book draft",
                "chapter review",
                "manuscript pass"
            ], false),
            ("portfolio building", [
                "portfolio block",
                "portfolio review",
                "portfolio update",
                "portfolio polish"
            ], false),
            ("mountain biking/outdoor skill", [
                "trail skill block",
                "bike skill block",
                "outdoor skill review",
                "ride prep"
            ], false),
            ("mental recovery / burnout-safe planning", [
                "recovery-safe block",
                "burnout-safe review",
                "rest planning",
                "gentle reset"
            ], false),
            ("instrument learning", [
                "instrument practice",
                "instrument drills",
                "instrument review",
                "instrument session"
            ], false)
        ]

        var scenarios: [GoalIntentScenario] = []
        var index = 0
        for family in families {
            for rawGoalText in family.1 {
                scenarios.append(
                    GoalIntentScenario(
                        index: index,
                        family: family.0,
                        rawGoalText: rawGoalText,
                        goalID: "goal.coverage.\(index)",
                        expectedSupported: family.2
                    )
                )
                index += 1
            }
        }
        return scenarios
    }

    func makeLifeContextProfiles() -> [LifeContextProfile] {
        let lifeStages = LifeContextLifeStage.allCases
        let transportation = LifeContextTransportationAccess.allCases
        let precisions = LifeContextLocationPrecision.allCases
        let budgetBands = LifeContextBudgetConstraintBand.allCases
        let energies = LifeContextEnergyPattern.allCases

        return (0..<20).map { index in
            let anchors = ["after school", "weekend", "evening"]
            let dependencyConstraints = index.isMultiple(of: 4) ? ["Care pickup"] : []
            let recoveryConstraints = index.isMultiple(of: 5) ? ["Protect recovery"] : []
            let accessibilityNeeds = index.isMultiple(of: 6) ? ["Low motion"] : []
            return LifeContextProfile(
                id: "profile.coverage.\(index)",
                exactAgeYears: 16 + index,
                timezone: "America/New_York",
                locale: "en_US",
                generalLocationLabel: "Coverage region \(index)",
                locationPrecision: precisions[index % precisions.count],
                sexOrEligibilityContext: index.isMultiple(of: 2) ? "self-reported" : "noted",
                lifeStage: lifeStages[index % lifeStages.count],
                schoolOrWorkContext: index.isMultiple(of: 3) ? "School or work \(index)" : "Independent practice",
                travelRadiusMinutes: 20 + (index % 5) * 10,
                travelRadiusMiles: Double(8 + index),
                transportationAccess: transportation[index % transportation.count],
                scheduleAnchors: anchors,
                dependencyConstraints: dependencyConstraints,
                budgetConstraintBand: budgetBands[index % budgetBands.count],
                energyPattern: energies[index % energies.count],
                recoveryConstraints: recoveryConstraints,
                accessibilityNeeds: accessibilityNeeds,
                userNotes: "Coverage profile \(index)"
            )
        }
    }

    func makeScheduleRealities() -> [ScheduleReality] {
        [
            ScheduleReality(label: "past due", deadlineTargetDate: "2026-05-21T12:00:00Z"),
            ScheduleReality(label: "same day", deadlineTargetDate: "2026-05-23T12:00:00Z"),
            ScheduleReality(label: "next day", deadlineTargetDate: "2026-05-24T12:00:00Z"),
            ScheduleReality(label: "two days", deadlineTargetDate: "2026-05-25T12:00:00Z"),
            ScheduleReality(label: "three days", deadlineTargetDate: "2026-05-26T12:00:00Z"),
            ScheduleReality(label: "five days", deadlineTargetDate: "2026-05-28T12:00:00Z"),
            ScheduleReality(label: "one week", deadlineTargetDate: "2026-05-30T12:00:00Z"),
            ScheduleReality(label: "two weeks", deadlineTargetDate: "2026-06-06T12:00:00Z"),
            ScheduleReality(label: "floating", deadlineTargetDate: nil),
            ScheduleReality(label: "review only", deadlineTargetDate: "2026-05-29T18:00:00Z")
        ]
    }

    func makeAccessStates() -> [AccessState] {
        [
            AccessState(label: "field access", facility: .field, transportationAccess: .car, locationPrecision: .precisePermissioned, travelRadiusMinutes: 40),
            AccessState(label: "home access", facility: .home, transportationAccess: .walk, locationPrecision: .userEnteredPlace, travelRadiusMinutes: 10),
            AccessState(label: "gym access", facility: .gym, transportationAccess: .bike, locationPrecision: .cityRegion, travelRadiusMinutes: 25),
            AccessState(label: "studio access", facility: .studio, transportationAccess: .transit, locationPrecision: .cityRegion, travelRadiusMinutes: 35),
            AccessState(label: "library access", facility: .library, transportationAccess: .walk, locationPrecision: .timezone, travelRadiusMinutes: 5),
            AccessState(label: "trail access", facility: .trail, transportationAccess: .car, locationPrecision: .userEnteredPlace, travelRadiusMinutes: 50),
            AccessState(label: "court access", facility: .court, transportationAccess: .rideshare, locationPrecision: .precisePermissioned, travelRadiusMinutes: 30),
            AccessState(label: "maker space access", facility: .makerSpace, transportationAccess: .car, locationPrecision: .cityRegion, travelRadiusMinutes: 45),
            AccessState(label: "pool access", facility: .pool, transportationAccess: .car, locationPrecision: .precisePermissioned, travelRadiusMinutes: 30),
            AccessState(label: "park access", facility: .park, transportationAccess: .walk, locationPrecision: .timezone, travelRadiusMinutes: 15)
        ]
    }

    func makeHistoryStates() -> [HistoryState] {
        [
            HistoryState(label: "fresh training win", freshness: .current, sourceType: .userToldAmbitions, usedFor: [.feasibility, .explanation], runtimeUseAllowed: true),
            HistoryState(label: "older attempt", freshness: .basedOnOlderContext, sourceType: .imported, usedFor: [.sequencing], runtimeUseAllowed: true),
            HistoryState(label: "needs review", freshness: .mayNeedReview, sourceType: .correctedByUser, usedFor: [.recovery, .explanation], runtimeUseAllowed: true),
            HistoryState(label: "stale history", freshness: .stale, sourceType: .inferredFromLocalAction, usedFor: [.opportunity], runtimeUseAllowed: false),
            HistoryState(label: "paused note", freshness: .current, sourceType: .paused, usedFor: [.feasibility], runtimeUseAllowed: false),
            HistoryState(label: "deleted note", freshness: .current, sourceType: .deleted, usedFor: [.travel], runtimeUseAllowed: false),
            HistoryState(label: "travel history", freshness: .basedOnOlderContext, sourceType: .userToldAmbitions, usedFor: [.travel], runtimeUseAllowed: true),
            HistoryState(label: "eligibility history", freshness: .mayNeedReview, sourceType: .imported, usedFor: [.eligibility], runtimeUseAllowed: true),
            HistoryState(label: "safety history", freshness: .current, sourceType: .correctedByUser, usedFor: [.safety], runtimeUseAllowed: true),
            HistoryState(label: "recovery history", freshness: .stale, sourceType: .inferredFromLocalAction, usedFor: [.recovery], runtimeUseAllowed: false)
        ]
    }

    func makePermutations(
        scheduleRealities: [ScheduleReality],
        accessStates: [AccessState],
        historyStates: [HistoryState],
        riskClasses: [SourceAtlasRiskClass]
    ) -> [ScenarioPermutation] {
        (0..<10).map { index in
            ScenarioPermutation(
                index: index,
                schedule: scheduleRealities[index],
                access: accessStates[index],
                history: historyStates[index],
                riskClass: riskClasses[index % riskClasses.count],
                deadlineTargetDate: scheduleRealities[index].deadlineTargetDate
            )
        }
    }

    func makeEmptyPack() -> SourceAtlasPack {
        SourceAtlasPack(
            manifest: SourceAtlasPackManifest(
                id: "pack.coverage.empty",
                title: "Coverage empty pack",
                kind: .userMiniPack,
                version: "1.0.0",
                domainID: "coverage.empty"
            ),
            sources: [],
            claims: [],
            requirements: [],
            starterItems: [],
            proofMap: [],
            projections: [],
            freshnessPolicy: .conservativeFreshness,
            riskPolicy: .conservative,
            disclosureCopy: SourceAtlasDisclosureCopy(
                sourceNeeded: "Context needed.",
                reviewRequired: "Review required.",
                notProfessionalAdvice: "Not professional advice."
            ),
            runtimeBoundary: .valueModelOnly,
            composition: SourceAtlasCompositionContract(
                dependencyPackIDs: [],
                reusableNodeIDs: [],
                overlayDependencyIDs: [],
                projectionRecipeIDs: [],
                ownsIndividualGoalPhrase: false
            ),
            domainPacks: [],
            specificDomainPacks: [],
            capabilityGraphs: []
        )
    }

    func makePack(
        id: String,
        generatedAt: String,
        title: String,
        domainID: String,
        specificDomainID: String,
        graphID: String,
        roleID: String,
        skillSliceID: String,
        pathPrefix: String,
        claimRiskClass: SourceAtlasRiskClass,
        goalIntents: [String]
    ) -> SourceAtlasPack {
        let source = SourceAtlasSourceRecord(
            id: "source.\(id)",
            title: "\(title) source",
            kind: .official,
            locator: "https://example.test/\(id)",
            retrievedAt: generatedAt,
            contentHash: "hash.\(id)",
            approvedForOfficialClaims: true
        )
        let claim = SourceAtlasClaim(
            id: "claim.\(id)",
            text: "\(title) claim",
            state: .official,
            freshness: .current,
            riskClass: claimRiskClass,
            sourceIDs: [source.id],
            reviewRequired: false
        )
        let requirement = SourceAtlasRequirement(
            id: "requirement.\(id)",
            claimID: claim.id,
            title: "\(title) requirement",
            kind: .proof,
            required: true,
            sourceState: .officialCurrent,
            freshnessState: .current,
            riskState: .low,
            reviewState: .approved
        )

        let setupNode = SourceAtlasCapabilityNode(
            id: "\(pathPrefix).setup",
            capabilityGraphID: graphID,
            title: "\(title) setup",
            summary: "Setup for \(title).",
            sourceRecordIDs: [source.id],
            state: .official,
            freshness: .current,
            riskClass: claimRiskClass,
            reviewRequired: false
        )
        let practiceNode = SourceAtlasCapabilityNode(
            id: "\(pathPrefix).practice",
            capabilityGraphID: graphID,
            title: "\(title) practice",
            summary: "Practice for \(title).",
            sourceRecordIDs: [source.id],
            state: .official,
            freshness: .current,
            riskClass: claimRiskClass,
            reviewRequired: false
        )
        let proofNode = SourceAtlasCapabilityNode(
            id: "\(pathPrefix).proof",
            capabilityGraphID: graphID,
            title: "\(title) proof",
            summary: "Proof for \(title).",
            sourceRecordIDs: [source.id],
            state: .official,
            freshness: .current,
            riskClass: claimRiskClass,
            reviewRequired: false
        )
        let roleOverlay = SourceAtlasRoleOverlay(
            id: roleID,
            roleID: roleID,
            skillSliceID: skillSliceID,
            reusableNodeIDs: [setupNode.id, practiceNode.id, proofNode.id],
            state: .official,
            freshness: .current,
            riskClass: claimRiskClass,
            sourceIDs: [source.id],
            reviewRequired: false
        )
        let fieldOverlay = SourceAtlasPathOverlay(
            id: "\(pathPrefix).field",
            title: "\(title) field route",
            skillSliceID: skillSliceID,
            capabilityNodeIDs: [setupNode.id, practiceNode.id, proofNode.id],
            pathPriority: 3,
            roleID: roleID,
            claimIDs: [claim.id],
            sourceRecordIDs: [source.id],
            state: .official,
            freshness: .current,
            riskClass: claimRiskClass,
            reviewRequired: false
        )
        let homeOverlay = SourceAtlasPathOverlay(
            id: "\(pathPrefix).home",
            title: "\(title) home route",
            skillSliceID: skillSliceID,
            capabilityNodeIDs: [setupNode.id, practiceNode.id, proofNode.id],
            pathPriority: 2,
            roleID: roleID,
            claimIDs: [claim.id],
            sourceRecordIDs: [source.id],
            state: .official,
            freshness: .current,
            riskClass: claimRiskClass,
            reviewRequired: false
        )
        let reviewOverlay = SourceAtlasPathOverlay(
            id: "\(pathPrefix).review",
            title: "\(title) review route",
            skillSliceID: skillSliceID,
            capabilityNodeIDs: [setupNode.id, practiceNode.id, proofNode.id],
            pathPriority: 4,
            roleID: roleID,
            claimIDs: [claim.id],
            sourceRecordIDs: [source.id],
            state: .official,
            freshness: .current,
            riskClass: claimRiskClass,
            reviewRequired: false
        )
        let graph = SourceAtlasCapabilityGraph(
            id: graphID,
            title: "\(title) capability graph",
            domainPackID: "domain.\(id)",
            capabilityNodeIDs: [setupNode.id, practiceNode.id, proofNode.id],
            capabilityEdgeIDs: [
                "\(pathPrefix).edge.setup.practice",
                "\(pathPrefix).edge.practice.proof"
            ],
            levelLadderIDs: ["ladder.\(id)"],
            roleOverlayIDs: [roleID],
            nodes: [setupNode, practiceNode, proofNode],
            edges: [
                SourceAtlasCapabilityEdge(
                    id: "\(pathPrefix).edge.setup.practice",
                    capabilityGraphID: graphID,
                    sourceNodeID: setupNode.id,
                    targetNodeID: practiceNode.id,
                    kind: .prerequisite,
                    state: .official,
                    freshness: .current,
                    riskClass: claimRiskClass,
                    reviewRequired: false,
                    roleOverlayIDs: [roleID],
                    pathOverlayIDs: [fieldOverlay.id, homeOverlay.id, reviewOverlay.id],
                    sourceRecordIDs: [source.id]
                ),
                SourceAtlasCapabilityEdge(
                    id: "\(pathPrefix).edge.practice.proof",
                    capabilityGraphID: graphID,
                    sourceNodeID: practiceNode.id,
                    targetNodeID: proofNode.id,
                    kind: .unlocks,
                    state: .official,
                    freshness: .current,
                    riskClass: claimRiskClass,
                    reviewRequired: false,
                    roleOverlayIDs: [roleID],
                    pathOverlayIDs: [fieldOverlay.id, homeOverlay.id, reviewOverlay.id],
                    sourceRecordIDs: [source.id]
                )
            ],
            ladders: [
                SourceAtlasLevelLadder(
                    id: "ladder.\(id)",
                    title: "\(title) ladder",
                    capabilityGraphID: graphID,
                    pathOverlays: [fieldOverlay, homeOverlay, reviewOverlay],
                    levelLabels: ["setup", "practice", "proof"]
                )
            ],
            roleOverlays: [roleOverlay],
            state: .official,
            freshness: .current,
            riskClass: claimRiskClass,
            reviewRequired: false
        )
        let domainPack = SourceAtlasDomainPack(
            id: "domain.\(id)",
            title: "\(title) domain pack",
            domainID: domainID,
            capabilityGraphIDs: [graphID],
            specificDomainPackIDs: [specificDomainID],
            reusableNodeIDs: graph.capabilityNodeIDs,
            sourceSliceIDs: [source.id],
            state: .official,
            freshness: .current,
            riskClass: claimRiskClass,
            reviewRequired: false
        )
        let specificPack = SourceAtlasSpecificDomainPack(
            id: specificDomainID,
            title: "\(title) specific pack",
            domainPackID: domainPack.id,
            capabilityGraphID: graphID,
            skillSliceIDs: [skillSliceID],
            roleOverlayIDs: [roleID],
            pathOverlayIDs: [fieldOverlay.id, homeOverlay.id, reviewOverlay.id],
            state: .official,
            freshness: .current,
            riskClass: claimRiskClass,
            reviewRequired: false,
            sourceSliceIDs: [source.id]
        )
        let projections = goalIntents.enumerated().map { index, goalIntent in
            SourceAtlasGoalProjection(
                id: "projection.\(id).\(index)",
                goalIntent: normalizedGoalIntent(goalIntent),
                requiredPackIDs: [id],
                projectionProfiles: [
                    SourceAtlasProjectionProfile(
                        id: "projection-profile.\(id).\(index)",
                        profileTitle: "\(title) profile \(index)",
                        sourceState: .officialCurrent,
                        freshnessState: .current,
                        riskState: .low,
                        reviewState: .approved,
                        producesPersonalPathInstance: true,
                        producesProjectionReceipt: true,
                        optionValueMap: SourceAtlasOptionValueMap(
                            id: "option.\(id).\(index)",
                            values: ["goal": normalizedGoalIntent(goalIntent)],
                            sourceState: .officialCurrent,
                            freshnessState: .current,
                            reviewState: .approved,
                            riskState: .low
                        ),
                        personalPathInstances: [
                            SourceAtlasPersonalPathInstance(
                                id: "path-instance.\(id).\(index)",
                                personalPathTemplateID: "template.\(id).\(index)",
                                stepCandidateSeeds: [
                                    SourceAtlasStepCandidateSeed(
                                        id: "seed.\(id).\(index)",
                                        stepCandidate: "Start the \(normalizedGoalIntent(goalIntent)) path."
                                    )
                                ],
                                sourceState: .officialCurrent,
                                freshnessState: .current,
                                reviewState: .approved,
                                riskState: .low,
                                sourceRecordIDs: [source.id]
                            )
                        ]
                    )
                ]
            )
        }

        return SourceAtlasPack(
            manifest: SourceAtlasPackManifest(
                id: id,
                title: title,
                kind: .capabilityGraph,
                version: "1.0.0",
                domainID: domainID,
                specificDomainID: specificDomainID
            ),
            sources: [source],
            claims: [claim],
            requirements: [requirement],
            starterItems: [
                SourceAtlasStarterItem(
                    id: "starter.\(id)",
                    title: "\(title) starter",
                    stepCandidateSeed: "Start the path with a safe local step.",
                    storesFinalSchedule: false
                )
            ],
            proofMap: [
                SourceAtlasProofMapEntry(
                    id: "proof.\(id)",
                    requirementID: requirement.id,
                    proofDescription: "\(title) proof",
                    privacyClass: .privateLife,
                    proofCandidate: .sourceEvidence,
                    proofStrength: .officialCertified,
                    capabilityNodeID: proofNode.id,
                    sourceRecordIDs: [source.id],
                    sourceClaimIDs: [claim.id],
                    correctionHookIDs: ["hook.\(id).correct"],
                    revocationHookIDs: ["hook.\(id).revoke"],
                    evidenceLedgerBridgeIDs: ["ledger.\(id)"]
                )
            ],
            projections: projections,
            freshnessPolicy: .conservativeFreshness,
            riskPolicy: .conservative,
            disclosureCopy: SourceAtlasDisclosureCopy(
                sourceNeeded: "Context needed.",
                reviewRequired: "Review required.",
                notProfessionalAdvice: "Not professional advice."
            ),
            runtimeBoundary: .valueModelOnly,
            composition: SourceAtlasCompositionContract(
                dependencyPackIDs: [],
                reusableNodeIDs: graph.capabilityNodeIDs,
                overlayDependencyIDs: [roleID],
                projectionRecipeIDs: projections.map { $0.id },
                ownsIndividualGoalPhrase: false
            ),
            domainPacks: [domainPack],
            specificDomainPacks: [specificPack],
            capabilityGraphs: [graph]
        )
    }

    func normalizedGoalIntent(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return "" }

        let lowercased = trimmed
            .lowercased()
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "$", with: "")

        let scalarParts = lowercased.unicodeScalars.map { scalar -> String in
            if CharacterSet.alphanumerics.contains(scalar) {
                return String(scalar)
            }
            return " "
        }

        return scalarParts
            .joined()
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: "-")
    }

    static func scheduleAvailabilityLabel(for reality: ScheduleReality) -> String {
        reality.label
    }

    static func historyCategory(for history: HistoryState) -> HistoricalContextFactCategory {
        switch history.usedFor.first {
        case .some(.feasibility):
            return .trainingHistory
        case .some(.eligibility):
            return .educationHistory
        case .some(.travel):
            return .locationHistory
        case .some(.safety):
            return .healthBaseline
        case .some(.recovery):
            return .healthBaseline
        case .some(.duration):
            return .priorExperience
        case .some(.sequencing):
            return .priorAttempt
        case .some(.opportunity):
            return .pastAchievement
        case .some(.explanation):
            return .creativeCatalog
        case .none:
            return .custom
        }
    }
}
