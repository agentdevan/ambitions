import XCTest
@testable import Ambitions

@MainActor
final class PublicReferenceRecheckViewModelTests: XCTestCase {
    func testFailurePreservesLoadedDashboard() async {
        let dashboard = PreviewFixtures.default.youDashboard
        let service = ScriptedPublicReferenceYouService(
            dashboard: dashboard,
            checkResult: .failure(.unavailable),
            acceptanceResult: .success(.accepted(dashboard))
        )
        let viewModel = YouViewModel(state: .loaded(dashboard))

        let outcome = await viewModel.recheckPublicReference(
            using: service,
            observedSourceRevision: dashboard.publicReferenceInspection.sourceRevision,
            updateToken: nil,
            selectedClaimID: nil
        )

        XCTAssertEqual(outcome, .failed)
        XCTAssertEqual(viewModel.loadedDashboard, dashboard)
    }

    func testDetectedUpdatePreservesOldProjectionUntilAccepted() async throws {
        let dashboard = PreviewFixtures.default.youDashboard
        let token = try Self.token(hash: "new-r1")
        let service = ScriptedPublicReferenceYouService(
            dashboard: dashboard,
            checkResult: .success(.updateAvailable(token)),
            acceptanceResult: .success(.accepted(dashboard))
        )
        let viewModel = YouViewModel(state: .loaded(dashboard))

        let outcome = await viewModel.recheckPublicReference(
            using: service,
            observedSourceRevision: dashboard.publicReferenceInspection.sourceRevision,
            updateToken: nil,
            selectedClaimID: nil
        )

        XCTAssertEqual(outcome, .updateAvailable(token))
        XCTAssertEqual(viewModel.loadedDashboard, dashboard)
        let counts = await service.counts()
        XCTAssertEqual(counts, .init(checks: 1, acceptances: 0))
    }

    func testAcceptanceUsesDetectedRevisionWithoutSecondFetchAndForwardsSelectedClaim() async throws {
        let oldDashboard = Self.dashboard(
            replacing: PreviewFixtures.default.youDashboard,
            publicReferenceInspection: .unavailable
        )
        let acceptedDashboard = PreviewFixtures.default.youDashboard
        let token = try Self.token(hash: "accepted")
        let selectedClaimID = acceptedDashboard.publicReferenceInspection.claims.first?.id
        let service = ScriptedPublicReferenceYouService(
            dashboard: oldDashboard,
            checkResult: .success(.updateAvailable(token)),
            acceptanceResult: .success(.accepted(acceptedDashboard))
        )
        let viewModel = YouViewModel(state: .loaded(oldDashboard))

        let detected = await viewModel.recheckPublicReference(
            using: service,
            observedSourceRevision: oldDashboard.publicReferenceInspection.sourceRevision,
            updateToken: nil,
            selectedClaimID: selectedClaimID
        )
        let accepted = await viewModel.recheckPublicReference(
            using: service,
            observedSourceRevision: oldDashboard.publicReferenceInspection.sourceRevision,
            updateToken: token,
            selectedClaimID: selectedClaimID
        )

        XCTAssertEqual(detected, .updateAvailable(token))
        XCTAssertEqual(accepted, .current)
        XCTAssertEqual(viewModel.loadedDashboard, acceptedDashboard)
        let counts = await service.counts()
        let acceptedClaimID = await service.lastAcceptedClaimID()
        XCTAssertEqual(counts, .init(checks: 1, acceptances: 1))
        XCTAssertEqual(acceptedClaimID, selectedClaimID)
    }

    func testInterveningRevisionRequiresAnotherExplicitReview() async throws {
        let dashboard = PreviewFixtures.default.youDashboard
        let detected = try Self.token(hash: "new-r1")
        let service = ScriptedPublicReferenceYouService(
            dashboard: dashboard,
            checkResult: .success(.updateAvailable(detected)),
            acceptanceResult: .success(.stale)
        )
        let viewModel = YouViewModel(state: .loaded(dashboard))

        let outcome = await viewModel.recheckPublicReference(
            using: service,
            observedSourceRevision: dashboard.publicReferenceInspection.sourceRevision,
            updateToken: detected,
            selectedClaimID: PublicReferenceClaimID("withdrawn-direct-link")
        )

        XCTAssertEqual(outcome, .stale)
        XCTAssertEqual(viewModel.loadedDashboard, dashboard)
        let counts = await service.counts()
        XCTAssertEqual(counts, .init(checks: 0, acceptances: 1))
    }

    private static func token(hash: String) throws -> PublicReferenceUpdateToken {
        let verified = try PublicReferenceRepositoryTests.verifiedArtifact(hash: hash)
        let artifact = try XCTUnwrap(verified.publicReferencePackArtifact())
        let release = try XCTUnwrap(PublicReferencePackAdapter().adapt(artifact).release)
        return PublicReferenceUpdateToken(pointer: PublicReferenceVerifiedReleasePointer(
            artifact: artifact,
            release: release
        ))
    }

    private static func dashboard(
        replacing dashboard: YouDashboard,
        publicReferenceInspection: PublicReferenceInspectionProjection
    ) -> YouDashboard {
        YouDashboard(
            hero: dashboard.hero,
            systemCenter: dashboard.systemCenter,
            controlRoom: dashboard.controlRoom,
            constitution: dashboard.constitution,
            memoryControls: dashboard.memoryControls,
            personalVault: dashboard.personalVault,
            everythingSearch: dashboard.everythingSearch,
            assumptionCorrections: dashboard.assumptionCorrections,
            automationBoundary: dashboard.automationBoundary,
            planningDefaultsCenter: dashboard.planningDefaultsCenter,
            availabilityCenter: dashboard.availabilityCenter,
            receiptAudit: dashboard.receiptAudit,
            trustHistoryCenter: dashboard.trustHistoryCenter,
            crossSurfaceProofReview: dashboard.crossSurfaceProofReview,
            reviews: dashboard.reviews,
            appearanceStudio: dashboard.appearanceStudio,
            trustCenter: dashboard.trustCenter,
            contextVault: dashboard.contextVault,
            sourceAtlasKnowledge: dashboard.sourceAtlasKnowledge,
            publicReferenceInspection: publicReferenceInspection,
            lifeContext: dashboard.lifeContext,
            integrationsSection: dashboard.integrationsSection,
            defaultsSection: dashboard.defaultsSection,
            accountSection: dashboard.accountSection,
            notificationAuthorization: dashboard.notificationAuthorization,
            preferences: dashboard.preferences
        )
    }
}

private enum PublicReferenceRecheckTestError: Error {
    case unavailable
}

private actor ScriptedPublicReferenceYouService: YouServicing {
    struct Counts: Equatable {
        let checks: Int
        let acceptances: Int
    }

    let dashboard: YouDashboard
    let checkResult: Result<PublicReferenceUpdateCheck, PublicReferenceRecheckTestError>
    let acceptanceResult: Result<PublicReferenceUpdateAcceptance, PublicReferenceRecheckTestError>
    private var checkCount = 0
    private var acceptanceCount = 0
    private var acceptedClaimID: PublicReferenceClaimID?

    init(
        dashboard: YouDashboard,
        checkResult: Result<PublicReferenceUpdateCheck, PublicReferenceRecheckTestError>,
        acceptanceResult: Result<PublicReferenceUpdateAcceptance, PublicReferenceRecheckTestError>
    ) {
        self.dashboard = dashboard
        self.checkResult = checkResult
        self.acceptanceResult = acceptanceResult
    }

    func loadYouDashboard() async throws -> YouDashboard { dashboard }

    func checkPublicReferenceUpdate(since observedSourceRevision: String) async throws -> PublicReferenceUpdateCheck {
        _ = observedSourceRevision
        checkCount += 1
        return try checkResult.get()
    }

    func acceptPublicReferenceUpdate(
        _ token: PublicReferenceUpdateToken,
        selectedClaimID: PublicReferenceClaimID?
    ) async throws -> PublicReferenceUpdateAcceptance {
        _ = token
        acceptanceCount += 1
        acceptedClaimID = selectedClaimID
        return try acceptanceResult.get()
    }

    func saveYouPreferences(_ preferences: YouPreferencesUpdate) async throws -> YouDashboard {
        _ = preferences
        return dashboard
    }

    func counts() -> Counts {
        Counts(checks: checkCount, acceptances: acceptanceCount)
    }

    func lastAcceptedClaimID() -> PublicReferenceClaimID? {
        acceptedClaimID
    }
}
