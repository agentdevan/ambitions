import Foundation

enum SourceAtlasPublicPackRepositoryBackedRemoteRefreshIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case repositoryLookupFailed = "repository_lookup_failed"
    case repositoryCommitFailed = "repository_commit_failed"
}

struct SourceAtlasPublicPackRepositoryBackedRemoteRefreshResolution: Sendable, Equatable, Hashable {
    let remoteResolution: SourceAtlasPublicPackRemoteFetchResolution
    let repositoryCachedPayloadUsed: Bool
    let cacheJournalRecord: SourceAtlasPublicPackCacheJournalRecord
    let cacheCommitResult: SourceAtlasPublicPackCacheRepositoryCommitResult?
    let repositoryIssues: [SourceAtlasPublicPackRepositoryBackedRemoteRefreshIssue]
    let capturedObjectKinds: [SourceAtlasPublicPackRemoteObjectKind]

    var selectedPack: SourceAtlasPack? {
        remoteResolution.selectedPack
    }

    var persistedPackPayload: Bool {
        cacheCommitResult?.persistedPackPayload == true
    }

    var coreLocalPlanningBlocked: Bool {
        false
    }
}

struct SourceAtlasPublicPackRepositoryBackedRemoteRefreshCoordinator {
    private let remoteCoordinator: SourceAtlasPublicPackRemoteFetchCoordinator
    private let journal: SourceAtlasPublicPackCacheJournal

    init(
        remoteCoordinator: SourceAtlasPublicPackRemoteFetchCoordinator = SourceAtlasPublicPackRemoteFetchCoordinator(),
        journal: SourceAtlasPublicPackCacheJournal = SourceAtlasPublicPackCacheJournal()
    ) {
        self.remoteCoordinator = remoteCoordinator
        self.journal = journal
    }

    func resolve(
        _ input: SourceAtlasPublicPackRemoteFetchInput,
        transport: SourceAtlasPublicPackRemoteTransport,
        repository: SourceAtlasPublicPackCacheFileRepository
    ) async -> SourceAtlasPublicPackRepositoryBackedRemoteRefreshResolution {
        var repositoryIssues: Set<SourceAtlasPublicPackRepositoryBackedRemoteRefreshIssue> = []
        let repositoryPayload = repositoryCachedPayload(
            for: input,
            repository: repository,
            issues: &repositoryIssues
        )
        let effectiveInput = input.replacingCachedPayloadIfNeeded(repositoryPayload.payload)
        let recordingTransport = SourceAtlasPublicPackRecordingRemoteTransport(upstream: transport)
        let remoteResolution = await remoteCoordinator.resolve(
            effectiveInput,
            transport: recordingTransport
        )
        let manifestData = await recordingTransport.firstData(for: .manifest)
        let packData = await recordingTransport.firstData(for: .pack)
        let journalRecord = journal.record(
            SourceAtlasPublicPackCacheJournalInput(
                manifestRequest: input.manifestRequest,
                targetPackID: input.targetPackID,
                objectRequests: remoteResolution.objectRequests,
                fetchResolution: remoteResolution.pipelineResolution,
                fetchedManifestData: manifestData,
                downloadedPackData: packData,
                committedAt: input.checkedAt
            )
        )

        let commitResult: SourceAtlasPublicPackCacheRepositoryCommitResult?
        do {
            commitResult = try repository.commit(
                SourceAtlasPublicPackCacheRepositoryCommitInput(
                    journalRecord: journalRecord,
                    manifestData: manifestData,
                    packData: packData
                )
            )
        } catch {
            repositoryIssues.insert(.repositoryCommitFailed)
            commitResult = nil
        }

        return SourceAtlasPublicPackRepositoryBackedRemoteRefreshResolution(
            remoteResolution: remoteResolution,
            repositoryCachedPayloadUsed: repositoryPayload.used,
            cacheJournalRecord: journalRecord,
            cacheCommitResult: commitResult,
            repositoryIssues: SourceAtlasPublicPackRepositoryBackedRemoteRefreshIssue.allCases.filter { repositoryIssues.contains($0) },
            capturedObjectKinds: await recordingTransport.capturedObjectKinds()
        )
    }
}

private actor SourceAtlasPublicPackRecordingRemoteTransport: SourceAtlasPublicPackRemoteTransport {
    private struct CapturedObject: Sendable, Equatable, Hashable {
        let request: SourceAtlasPublicPackRemoteObjectRequest
        let data: Data
    }

    private let upstream: SourceAtlasPublicPackRemoteTransport
    private var capturedObjects: [CapturedObject] = []

    init(upstream: SourceAtlasPublicPackRemoteTransport) {
        self.upstream = upstream
    }

    func fetch(_ request: SourceAtlasPublicPackRemoteObjectRequest) async throws -> Data {
        let data = try await upstream.fetch(request)
        capturedObjects.append(CapturedObject(request: request, data: data))
        return data
    }

    func firstData(for kind: SourceAtlasPublicPackRemoteObjectKind) -> Data? {
        return capturedObjects.first { $0.request.kind == kind }?.data
    }

    func capturedObjectKinds() -> [SourceAtlasPublicPackRemoteObjectKind] {
        let capturedKinds = Set(capturedObjects.map(\.request.kind))
        return SourceAtlasPublicPackRemoteObjectKind.allCases.filter { capturedKinds.contains($0) }
    }
}

private extension SourceAtlasPublicPackRepositoryBackedRemoteRefreshCoordinator {
    func repositoryCachedPayload(
        for input: SourceAtlasPublicPackRemoteFetchInput,
        repository: SourceAtlasPublicPackCacheFileRepository,
        issues: inout Set<SourceAtlasPublicPackRepositoryBackedRemoteRefreshIssue>
    ) -> (payload: SourceAtlasStorePayload?, used: Bool) {
        guard input.cachedPayload == nil,
              input.accessDecision.route != .unavailable,
              let cachedManifest = input.cachedManifest,
              let manifestEntry = cachedManifest.packIndex.first(where: { $0.packID == input.targetPackID })
        else {
            return (nil, false)
        }

        do {
            let payload = try repository.loadPayload(
                SourceAtlasPublicPackCachePayloadLookup(
                    packID: input.targetPackID,
                    manifestVersionID: cachedManifest.versionID,
                    declaredSHA256: manifestEntry.currentSHA256
                )
            )
            return (payload, payload != nil)
        } catch {
            issues.insert(.repositoryLookupFailed)
            return (nil, false)
        }
    }
}

private extension SourceAtlasPublicPackRemoteFetchInput {
    func replacingCachedPayloadIfNeeded(
        _ repositoryPayload: SourceAtlasStorePayload?
    ) -> SourceAtlasPublicPackRemoteFetchInput {
        SourceAtlasPublicPackRemoteFetchInput(
            manifestRequest: manifestRequest,
            targetPackID: targetPackID,
            environment: environment,
            cachedManifest: cachedManifest,
            cachedPayload: cachedPayload ?? repositoryPayload,
            bundledPayload: bundledPayload,
            lastKnownGoodPayload: lastKnownGoodPayload,
            accessDecision: accessDecision,
            query: query,
            checkedAt: checkedAt,
            policy: policy
        )
    }
}
