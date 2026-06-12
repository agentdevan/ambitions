# Local Data Cloud Boundary Law

Status: Active PLOS M00 governance law
Issue: AMB-643 / PLOS-007
Parent: AMB-608 / PLOS-M00
Authority posture: Supporting PLOS law subordinate to `docs/truth/*`
Runtime implementation proof: none
CloudKit implementation proof: none
R2 implementation proof: none

This law defines the data-boundary rules for future PLOS execution. It does not implement CloudKit, R2, sync, entitlements, privacy manifest changes, source packs, sharing, or runtime behavior.

## Core Law

Private user life data stays on-device first and may sync only through user-owned Apple-native iCloud/CloudKit continuity when explicitly enabled and proven.

R2 is public-reference and source/pathing distribution only. R2 must never store, receive, or infer private user life data.

No future PLOS issue may claim data-boundary Green unless it preserves:

- local-first user data
- user-owned Apple sync only when implemented and validated
- no Ambitions-owned personal-data backend by default
- R2 as public non-personal reference/source infrastructure only
- explicit data classification
- honest release/privacy/legal proof boundaries

## Existing Authority Anchors

AMB-643 inspected current docs and source before installing this law. Existing anchors include:

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
  - core user data is local-first/local-only; Apple account or iCloud-style sync is the only user-owned sync exception; R2 may host read-only public freshness/reference data and must never receive goals, captures, calendar data, receipts, proof, personalization, or private context.
- `docs/truth/RELEASE_TRUTH.md`
  - release truth states iCloud/CloudKit sync is not validated as release truth and R2 freshness is not implemented or validated.
- `Native/Ambitions/Resources/PrivacyInfo.xcprivacy`
  - current source declares no tracking and no collected data types.
- `Native/Ambitions/Persistence/CloudKitContinuityModels.swift`
  - source-present continuity envelopes include goal, step, capture, proof, receipt, preference, tombstone, conflict review, and sync ledger concepts.
- `Native/Ambitions/Domain/AmbitionsOSPrivacySafetyModels.swift`
  - source-present privacy safety policy includes sensitive areas, permission states, projection policy, tool intent, redaction, receipts, local projection, and external projection blocking.
- `Native/Ambitions/Domain/SourceAtlasStoreModels.swift`
  - Source Atlas store models include bundled/cached/last-known-good payloads, source-needed/stale/contradicted/revoked states, quarantine, hash checks, and invalid-pack handling.
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
  - Source Atlas pack models include source kinds, claim states, freshness, risk classes, and high-risk review concepts.
- `Native/Ambitions/Support/ReleasePrivacyProtectedStorageReport.swift`
  - protected storage policy source declares local storage classes, no cloud backend dependency, no external raw projection, and no privacy/legal/release claim unlock.
- `artifacts/source-atlas-factory/SAF_HARDENING_PLAN.md`
  - R2 and Source Atlas distribution are public-reference-only; private user data in R2 is Red.

These anchors are existing-first context only. They do not prove CloudKit, R2, privacy, sync, or release behavior.

## User Data Rule

User data is on-device first.

User data includes:

- goals
- life areas
- captures
- held items
- schedule assumptions
- protected time
- closures
- receipts
- proof
- pivots
- recovery history
- personalization
- planning defaults
- user-specific learning
- private source imports
- private share artifacts
- private context and life graph state

User data may use user iCloud/CloudKit only when:

- the active issue authorizes the work
- Apple-native sync remains user-owned
- no custom Ambitions account or hosted personal-data backend is introduced
- conflict, tombstone, deletion, export, rollback, and receipt behavior are proven
- privacy copy and manifest posture are reviewed against live source
- validation and no-claim boundaries are current

Source-present CloudKit models do not prove sync works.

## R2 Boundary

Allowed R2 material:

- public source packs
- seed packs
- public goal and Step pathing metadata
- public manifests
- public freshness data
- source revocation data
- compatibility metadata
- release receipts
- non-user-specific public dates, rules, requirements, templates, and references

R2 must not store, receive, or derive:

- user goals
- schedules
- proof
- private receipts
- closure history
- local learning
- private share artifacts
- private imports
- OCR output
- photos
- private files
- personal context
- behavior patterns
- inferred priorities
- any user-identifying life graph state

R2 requests must not include private user context to personalize returned packs. A future R2 implementation must support anonymous/non-personal fetches or block.

## Data Classification

Every future PLOS data path must classify data before Green:

| Class | Meaning | Allowed destinations |
|---|---|---|
| local-only | Private user life data or private derived state. | Device local storage only unless a narrower law allows user iCloud sync. |
| user-iCloud synced | User-owned data synced across the user's Apple devices. | Apple-native iCloud/CloudKit only after proof. |
| downloaded source/pathing data | Public Source Atlas/source pack material. | Bundled cache, local cache, R2/public source mirror, last-known-good local fallback. |
| user-initiated export | User chooses to export or share. | Local rendered/exported artifact after preview and redaction. |
| collected by Ambitions | Data collected by Ambitions as a company or service. | Disallowed by default unless separately approved and privacy-reviewed. |
| never transmitted | Sensitive data that cannot leave the device. | Device local storage only; export/share blocked or redacted. |

Missing classification is Yellow for governance docs and Red for runtime behavior that can move data.

## User-Facing Wording

Allowed wording examples:

- "Ambitions downloads fresh goal and Step pathing data."
- "Your goals, schedule, proof, and life context stay on your device and iCloud."
- "This source pack is public reference data."
- "This stays local unless you choose to export it."

Forbidden wording:

- training data
- cloud learns your life
- synced to Ambitions servers
- uploaded for personalization
- R2-backed personal storage
- anonymous if private identifiers or context are sent
- privacy approved without proof

These are law examples, not shipped copy.

## Green Enforcement

Any future PLOS issue that claims local data, CloudKit/iCloud, R2, source-pack distribution, pack freshness, data lifecycle, privacy, export, deletion, or sync Green must reference this law before Green.

Green requires:

- a live `AMB-*` issue identifier
- existing-first inspection of live source, entitlements, privacy manifest, persistence, CloudKit, Source Atlas, export/share, and release truth as applicable
- explicit data classification
- no private user data in R2 or public Source Atlas objects
- no Ambitions-owned personal-data backend by default
- no cloud LLM/core server dependency
- receipts, rollback, delete, export, and conflict handling when behavior changes data
- privacy/legal/release no-claim boundary unless current proof exists

Yellow is allowed when this law is installed but future CloudKit, R2, pack, privacy, sync, export, or runtime proof remains owned. Red is required for private user data in R2, vague user data collection, custom personal backend drift, cloud training claims, entitlement/privacy manifest mutation outside scope, PLOS label Linear access, or phase-order violation.

## Non-Claims

AMB-643 does not claim:

- CloudKit implementation
- R2 implementation
- sync behavior
- privacy manifest correctness beyond source inspection
- privacy/legal approval
- App Review readiness
- release readiness
- source pack publication
- runtime feature implementation
- app source change
- PLOS-M00 completion
- PLOS-M01 or later execution
