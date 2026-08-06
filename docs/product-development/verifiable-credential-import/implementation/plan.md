# Implementation Plan

## Outcome and boundary

Import one supported signed credential artifact locally, separate artifact
integrity, issuer identity, claimed achievement/evidence, endorsement or
accreditation context, current validity, Capability/Proof relationships, and
receiver acceptance. A valid signature proves only the issuer-authored artifact.
Ambitions never infers competence, equivalency, admission, licensing, employment,
or current acceptance, and never overwrites Proof or Capability.

## Affected components and exact files

- Add `docs/canon/specifications/objects/credential.md`; update
  `objects/proof.md`, `objects/source-reference.md`,
  `systems/import-export-repair.md`, and `surfaces/you.md`.
- Add `Native/Ambitions/Core/Domain/Credential/CredentialModels.swift`,
  `CredentialArtifactModels.swift`, and `CredentialRelationshipModels.swift`.
- Add `Native/Ambitions/Core/LocalRuntimeOS/Attachments/CredentialArtifactStagingService.swift`
  and
  `Native/Ambitions/Core/LocalRuntimeOS/Repair/CredentialImport/CredentialArtifactVerifier.swift`.
- Add `Commands/CredentialCommandService.swift`,
  `State/CredentialStateStore.swift`, `Storage/CredentialStoreSchema.swift`,
  `Repair/CredentialSchemaMigration.swift`, and
  `Inspection/CredentialInspectionProjection.swift`.
- Add `Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/CredentialStatusRequestPolicy.swift`
  and
  `Native/Ambitions/Core/LocalRuntimeOS/ExternalOperations/CredentialStatusCheckService.swift`.
- Add `Native/Ambitions/Surfaces/You/CredentialImportView.swift` and
  `CredentialInspectionView.swift`.

## Data flow, persistence, and migration

Document-picker bytes enter an encrypted staging area, pass bounded parsing,
signature/issuer/schema validation, expiry/revocation status evaluation, and a
full local preview. Explicit acceptance creates one Credential with immutable
artifact/source lineage; separately confirmed ID-only edges may relate it to
Proof or Capability. Artifact bytes remain encrypted and content-addressed.
Commands use expected revisions/idempotency; supersession, archive/Trash/
restore/delete, Receipt/History, and replay preserve prior truth. A separate,
user-invoked **Check current status** flow builds a no-contact plan from only
supported signed proof/status locators, previews every normalized host and
resource class, and requires confirmation before a bounded external operation.
Its network policy blocks private/reserved/local/authenticated or unreviewed
targets, unsafe redirects, cookies/referrers, and private request fields; an
ambiguous result remains indeterminate and ordinary replay never reissues it.
Migration creates empty credential/artifact/relationship stores and never
upgrades existing attachments, Proof, or profile claims into Credentials.

## Dependencies, order, and rollout

Depend on Capability continuity, public-reference knowledge, existing Proof,
attachment security, and import-repair owners. Implement canon/models, secure
parser/verifier, storage/migration, commands/relationships, explicit status
operation, inspection/UI, then adversarial and device proof. Support exactly
Open Badges 3.0 `OpenBadgeCredential` JSON/JSON-LD with the Design's allowlisted
profile/proof/status mechanisms in v1. The allowlist is the W3C VC 2.0 context
plus Open Badges context `context-3.0.3.json`, JSON/JSON-LD file form only,
`DataIntegrityProof` using the EdDSA Cryptosuites v1.0 conformance path, locally
resolvable Multikey/`did:key` verification material, and
`BitstringStatusListEntry`. VC-JWT, baked PNG/SVG, remote key dereference during
import, and every other proof/status mechanism are reported as unsupported.
Wallet sync, issuer login, hosted verification, automatic equivalence, and
receiver acceptance are excluded.

The standards pins above come from the official
[Open Badges 3.0 specification](https://www.imsglobal.org/spec/ob/v3p0) and
[1EdTech implementation guide](https://standards.1edtech.org/open-badges/guides/standards/v3p0/impl).
Implementation must record exact retrieved revisions and licensed conformance-
fixture hashes before accepting real artifacts.
