import Foundation

/// The one authority selected for production mutation admission at process
/// bootstrap. `generationV8` intentionally does not pretend that the legacy
/// command executor can write a generation-owned store: a v8 command bridge
/// must be injected explicitly before ordinary mutations are admitted there.
enum RuntimeMutationAuthorityMode: String, Sendable, Equatable {
    case legacyRuntime
    case generationV8
    case unavailable
}

/// A process-lifetime capability for the recovery operations that are actually
/// implemented by the generation-owned runtime. It is deliberately narrower
/// than `RuntimeCommandClient`; generic product mutations have no v8 adapter
/// yet and therefore cannot accidentally fall back to legacy persistence.
struct RuntimeGenerationRecoveryClient: Sendable {
    let beginDerivedStateRebuild: @Sendable (
        _ planID: String
    ) async throws -> RuntimeGenerationDerivedStateRebuildExecutionResult

    let close: @Sendable () async throws -> Void
}

enum RuntimeMutationAuthorityBridgeError: Error, Sendable, Equatable {
    case generationAuthorityNotActive
    case generationAuthorityUnavailable
    case generationCommandBridgeRequired
    case generationProjectionBridgeUnavailable
}

/// Production-injectable result of authority selection. It carries the single
/// command client used by product services and, only for a resolved v8 store,
/// the narrowly scoped recovery capability bound to that same control lock.
struct RuntimeMutationAuthorityComposition: Sendable {
    let mode: RuntimeMutationAuthorityMode
    let commandClient: RuntimeCommandClient
    let generationRecovery: RuntimeGenerationRecoveryClient?
    let session: RuntimeMutationAuthoritySession

    static func legacy(
        commandClient: RuntimeCommandClient
    ) -> RuntimeMutationAuthorityComposition {
        let session = RuntimeMutationAuthoritySession.legacy()
        return RuntimeMutationAuthorityRouter.makeLegacy(
            commandClient: commandClient,
            session: session
        )
    }
}

/// App-lifetime ownership of the selected persistence authority. It is opened
/// before legacy repositories or product services are constructed, so a live
/// v8 selector can never coexist with an instantiated legacy service graph.
/// The selection is intentionally immutable for the process lifetime.
actor RuntimeMutationAuthoritySession {
    private enum Selection: Sendable {
        case legacy(RuntimeGenerationControlStore?)
        case generationV8(RuntimeGenerationRecoveryRuntime)
        /// Retains a failed-bootstrap control authority until the caller has
        /// performed explicit retirement; dropping it would make a failed
        /// close look like safe authority release.
        case unavailable(RuntimeGenerationControlStore?)
    }

    private let selection: Selection

    private init(selection: Selection) {
        self.selection = selection
    }

    nonisolated static func legacy() -> RuntimeMutationAuthoritySession {
        RuntimeMutationAuthoritySession(selection: .legacy(nil))
    }

    /// Reads durable generation state and, when selected, acquires the sole
    /// v8 control authority before any legacy repository construction begins.
    static func bootstrap(
        persistenceMode: AppBootstrapConfiguration.PersistenceMode,
        fileManager: FileManager = .default
    ) async -> RuntimeMutationAuthoritySession {
        guard persistenceMode == .persistent else {
            return legacy()
        }

        let rootAuthority: RuntimeStoreRootAuthority
        do {
            rootAuthority = try RuntimeStoreRootAuthority.appPrivate(
                fileManager: fileManager
            )
        } catch {
            return RuntimeMutationAuthoritySession(selection: .unavailable(nil))
        }
        let controlStore: RuntimeGenerationControlStore
        do {
            controlStore = try await RuntimeGenerationControlStore.open(
                rootAuthority: rootAuthority,
                environment: .live,
                fileManager: fileManager
            )
        } catch {
            return RuntimeMutationAuthoritySession(selection: .unavailable(nil))
        }
        let locations = RuntimeStoreLocations(applicationSupportURL: rootAuthority.applicationSupportURL)
        let selectorBytes: Data?
        do {
            selectorBytes = try RuntimeStoreManifestDescriptorReader.readIfPresent(
                at: locations.activeManifestURL
            )
        } catch {
            return RuntimeMutationAuthoritySession(
                selection: .unavailable(controlStore)
            )
        }
        guard selectorBytes != nil else {
            return RuntimeMutationAuthoritySession(selection: .legacy(controlStore))
        }

        do {
            return RuntimeMutationAuthoritySession(
                selection: .generationV8(
                    try await RuntimeGenerationRecoveryRuntime.openActive(
                        rootAuthority: rootAuthority,
                        controlStore: controlStore,
                        environment: .live,
                        fileManager: fileManager
                    )
                )
            )
        } catch {
            return RuntimeMutationAuthoritySession(
                selection: .unavailable(controlStore)
            )
        }
    }

    func mode() -> RuntimeMutationAuthorityMode {
        switch selection {
        case .legacy: .legacyRuntime
        case .generationV8: .generationV8
        case .unavailable: .unavailable
        }
    }

    /// The current application service graph is legacy-persistence-backed.
    /// Calling this before that graph is built makes the missing v8 product
    /// command bridge an explicit boot boundary rather than a dual-writer bug.
    func requireLegacyServiceAuthority() throws {
        switch selection {
        case .legacy:
            return
        case .generationV8:
            throw RuntimeMutationAuthorityBridgeError.generationCommandBridgeRequired
        case .unavailable:
            throw RuntimeMutationAuthorityBridgeError.generationAuthorityUnavailable
        }
    }

    func composition(
        legacyCommandClient: RuntimeCommandClient
    ) -> RuntimeMutationAuthorityComposition {
        switch selection {
        case .legacy:
            return RuntimeMutationAuthorityRouter.makeLegacy(
                commandClient: legacyCommandClient,
                session: self
            )
        case let .generationV8(recoveryRuntime):
            return RuntimeMutationAuthorityRouter.makeGenerationV8(
                legacyCommandClient: legacyCommandClient,
                recoveryRuntime: recoveryRuntime,
                session: self
            )
        case .unavailable:
            return RuntimeMutationAuthorityRouter.makeUnavailable(
                legacyCommandClient: legacyCommandClient,
                session: self
            )
        }
    }

    func beginDerivedStateRebuild(
        planID: String
    ) async throws -> RuntimeGenerationDerivedStateRebuildExecutionResult {
        guard case let .generationV8(recoveryRuntime) = selection else {
            throw RuntimeMutationAuthorityBridgeError.generationAuthorityNotActive
        }
        return try await recoveryRuntime.beginDerivedStateRebuild(planID: planID)
    }

    func close() async throws {
        switch selection {
        case let .legacy(controlStore):
            if let controlStore {
                try await controlStore.close()
            }
        case let .generationV8(recoveryRuntime):
            try await recoveryRuntime.close()
        case let .unavailable(controlStore):
            if let controlStore {
                try await controlStore.close()
            }
        }
    }
}

/// Serializes authority routing and keeps a resolved v8 recovery runtime alive
/// for exactly as long as its injected composition is retained. The actor is
/// also the negative capability boundary that prevents concurrent legacy
/// writes after a durable v8 selector has been observed.
private actor RuntimeMutationAuthorityRouter {
    private enum Selection: Sendable {
        case legacy(RuntimeCommandClient)
        case generationV8(RuntimeGenerationRecoveryRuntime)
        case unavailable
    }

    private let selection: Selection

    private init(selection: Selection) {
        self.selection = selection
    }

    nonisolated static func makeLegacy(
        commandClient: RuntimeCommandClient,
        session: RuntimeMutationAuthoritySession
    ) -> RuntimeMutationAuthorityComposition {
        makeComposition(
            mode: .legacyRuntime,
            selection: .legacy(commandClient),
            generationRecovery: nil,
            session: session
        )
    }

    nonisolated static func makeGenerationV8(
        legacyCommandClient: RuntimeCommandClient,
        recoveryRuntime: RuntimeGenerationRecoveryRuntime,
        session: RuntimeMutationAuthoritySession
    ) -> RuntimeMutationAuthorityComposition {
        _ = legacyCommandClient
        let recovery = RuntimeGenerationRecoveryClient(
            beginDerivedStateRebuild: { planID in
                try await session.beginDerivedStateRebuild(planID: planID)
            },
            close: {
                try await session.close()
            }
        )
        return makeComposition(
            mode: .generationV8,
            selection: .generationV8(recoveryRuntime),
            generationRecovery: recovery,
            session: session
        )
    }

    nonisolated static func makeUnavailable(
        legacyCommandClient: RuntimeCommandClient,
        session: RuntimeMutationAuthoritySession
    ) -> RuntimeMutationAuthorityComposition {
        _ = legacyCommandClient
        return makeComposition(
            mode: .unavailable,
            selection: .unavailable,
            generationRecovery: nil,
            session: session
        )
    }

    nonisolated private static func makeComposition(
        mode: RuntimeMutationAuthorityMode,
        selection: Selection,
        generationRecovery: RuntimeGenerationRecoveryClient?,
        session: RuntimeMutationAuthoritySession
    ) -> RuntimeMutationAuthorityComposition {
        let router = RuntimeMutationAuthorityRouter(selection: selection)
        return RuntimeMutationAuthorityComposition(
            mode: mode,
            commandClient: RuntimeCommandClient(
                execute: { command, context in
                    await router.execute(command, context: context)
                },
                projection: { request in
                    try await router.projection(request)
                }
            ),
            generationRecovery: generationRecovery,
            session: session
        )
    }

    private func execute(
        _ command: AmbitionsCommand,
        context: CommandExecutionContext
    ) async -> AmbitionsCommandExecutionResult {
        switch selection {
        case let .legacy(commandClient):
            return await commandClient.execute(command, context)
        case .generationV8:
            return blockedResult(
                command: command,
                reason: "generation_v8_command_bridge_required"
            )
        case .unavailable:
            return blockedResult(
                command: command,
                reason: "generation_authority_unavailable"
            )
        }
    }

    private func projection(
        _ request: RuntimeProjectionRequest
    ) async throws -> RuntimeProjectionSnapshot {
        switch selection {
        case let .legacy(commandClient):
            return try await commandClient.projection(request)
        case .generationV8:
            throw RuntimeMutationAuthorityBridgeError.generationProjectionBridgeUnavailable
        case .unavailable:
            throw RuntimeMutationAuthorityBridgeError.generationAuthorityUnavailable
        }
    }

    private func blockedResult(
        command: AmbitionsCommand,
        reason: String
    ) -> AmbitionsCommandExecutionResult {
        AmbitionsCommandExecutionResult(
            status: .blocked,
            summary: "Mutation is unavailable until its selected runtime authority provides a command bridge.",
            target: command.target,
            recommendationExplanationIDs: command.relations.recommendationExplanationIDs,
            metadata: [
                "blockedBy": reason,
                "runtimeMutationAuthority": "fail_closed"
            ]
        )
    }
}
