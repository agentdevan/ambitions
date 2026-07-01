import Foundation

enum PublicPackRequestCompilationIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case missingPackEntry = "missing_pack_entry"
    case firewallRejected = "firewall_rejected"
}

struct PublicPackRequestCompilation: Codable, Sendable, Equatable, Hashable {
    let manifestRequest: SourceAtlasPublicManifestRequest
    let packRequest: SourceAtlasPublicPackRequest?
    let selectedEntry: SourceAtlasFreshnessPackEntry?
    let firewallVerdict: PublicOnlyFirewallVerdict
    let issues: [PublicPackRequestCompilationIssue]

    var canFetchRemotePublicReference: Bool {
        issues.isEmpty && firewallVerdict.isAllowed && packRequest != nil
    }
}

struct PublicPackRequestCompiler: Sendable, Equatable, Hashable {
    private let publicOnlyGate: SourceAtlasPublicOnlyBoundaryGate

    init(firewall: PublicOnlyFirewall = PublicOnlyFirewall()) {
        self.publicOnlyGate = SourceAtlasPublicOnlyBoundaryGate(firewall: firewall)
    }

    func compile(
        manifest: SourceAtlasFreshnessManifest,
        packID: String,
        channel: String,
        appVersion: String,
        accessDecision: SourceAtlasAccessDecision,
        schemaVersion: String = "1",
        publicLocale: String? = nil,
        publicJurisdiction: String? = nil
    ) -> PublicPackRequestCompilation {
        let trimmedPackID = packID.trimmingCharacters(in: .whitespacesAndNewlines)
        let manifestRequest = SourceAtlasPublicManifestRequest(
            domainID: trimmedPackID,
            channel: channel,
            schemaVersion: schemaVersion,
            appVersion: appVersion,
            publicLocale: publicLocale
        )
        let selectedEntry = manifest.packIndex.first { $0.packID == trimmedPackID }
        let packRequest = selectedEntry.map {
            SourceAtlasPublicPackRequest.runtimeArtifact(
                manifestVersionID: manifest.versionID,
                entry: $0,
                channel: channel,
                artifactVersionID: manifest.versionID,
                sourceState: .current,
                freshnessState: .current,
                publicJurisdiction: publicJurisdiction,
                publicLocale: publicLocale
            )
        }
        let publicOnlyDecision = publicOnlyGate.evaluatePublicPackRequest(
            manifestRequest: manifestRequest,
            packRequest: packRequest,
            accessDecision: accessDecision
        )
        let verdict = publicOnlyDecision.firewallVerdict ?? PublicOnlyFirewallVerdict(
            issues: [],
            manifestRequestIssues: [],
            packRequestIssues: [],
            egressFindings: [],
            permitsRemotePublicReference: false
        )

        var issues: Set<PublicPackRequestCompilationIssue> = []
        if selectedEntry == nil {
            issues.insert(.missingPackEntry)
        }
        if publicOnlyDecision.isAllowed == false {
            issues.insert(.firewallRejected)
        }

        return PublicPackRequestCompilation(
            manifestRequest: manifestRequest,
            packRequest: packRequest,
            selectedEntry: selectedEntry,
            firewallVerdict: verdict,
            issues: PublicPackRequestCompilationIssue.allCases.filter { issues.contains($0) }
        )
    }
}
