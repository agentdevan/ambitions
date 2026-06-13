# Source Atlas Contradiction / Freshness Scan

Status: Green for AMB-681 / PLOS-055 contradiction and freshness scan documentation scope; Yellow for scanner implementation, freshness evaluator implementation, schema migration, release tooling, pack publication, runtime eligibility proof, live R2 promotion, privacy/legal approval, release readiness, device proof, accessibility proof, and measured performance proof.
Updated: 2026-06-12 America/New_York
Owning issue: AMB-681 / PLOS-055
Parent issue: AMB-613 / PLOS-M05

## Boundary

This artifact defines how Source Atlas claim sets, requirements, packs, and manifests must detect contradictions, stale source material, source changes, revocations, and freshness gaps before later validation or release lanes.

It does not implement a scanner, freshness evaluator, schema migration, pack publication, Cloudflare/R2 setup, credential creation, live R2 writes, runtime eligibility, or runtime pack consumption.

Freshness and contradiction scanning are safety/source authority controls. They are not production release proof.

## Scan Inputs

The scan requires:

- source import records and source hash lineage
- extracted claims and duplicate groups
- claim source ids and source authority class
- claim state, freshness state, risk class, and review requirement
- requirement source/freshness/risk/review state
- freshness manifest version, pack SHA, signature, changed claim ids, and claim state buckets
- revocation and rollback pointers
- prior released/superseded claim lineage
- reviewer decisions for high-risk, jurisdiction-sensitive, near-duplicate, stale, or contradictory claims

Claims or requirements missing source lineage are routed to `source_needed` or `review_needed` before contradiction/freshness scan can pass.

## Contradiction Classes

| Class | Meaning | Required route |
|---|---|---|
| `value_conflict` | same subject/scope has incompatible facts, thresholds, dates, permissions, costs, or deadlines | contradiction review |
| `authority_conflict` | source authority classes disagree or official source conflicts with lower-authority source | review; official/current does not silently erase conflict |
| `freshness_conflict` | current and stale sources disagree, or a source changed after extraction | review-needed or source-changed |
| `jurisdiction_conflict` | claims differ by geography, institution, age, program, or legal context | jurisdiction review |
| `risk_conflict` | safety/professional/high-risk boundary differs across claims | high-risk review |
| `revocation_conflict` | released/current claim is revoked or superseded by revocation manifest | revoked/quarantined |
| `private_public_conflict` | local/private user material conflicts with public source material | keep local/private separate; never publish private data |

Contradictions are not duplicates. They must not be merged away by AMB-680 duplicate handling.

## Freshness Outcomes

| Outcome | Meaning | Runtime/release posture |
|---|---|---|
| `current` | source is within allowed freshness window and no newer contradictory/revoking source exists | may proceed if other gates pass |
| `aging` | source is nearing stale window but still within allowed use for low-risk contexts | review cadence required |
| `stale` | source is beyond freshness window or newer source may exist | review-needed; not current-authoritative |
| `stale_critical` | stale source affects high-risk, deadline, legal, financial, health, certification, safety, or minor-related content | blocked until refreshed/reviewed |
| `source_changed` | source content hash, source text, or official source state changed after extraction | source-needed or review-needed |
| `disputed` | source or claim is disputed but not finally revoked | blocked from current use |
| `contradicted` | incompatible source-backed claim exists | contradiction review or quarantine |
| `revoked` | source, claim, pack, signer, or manifest is revoked | revoked/quarantined |
| `unknown` | freshness cannot be established | source-needed/review-needed |

Freshness is stricter than convenience. A fresher remote artifact cannot become eligible if signature, source authority, revocation, compatibility, rollback, release receipt, or privacy gates fail.

## Precedence

Blocking precedence:

1. private user data leak
2. revocation, compromised signer, or unsafe source
3. contradicted or disputed source-backed claim
4. stale-critical or source-changed high-risk content
5. unsupported or unknown source authority
6. missing source/hash lineage
7. ordinary stale or aging source
8. low-risk current source

Lower-severity freshness states cannot override higher-severity contradiction, revocation, source authority, privacy, or risk states.

## Existing Source Anchors

AMB-681 inspected these anchors:

- `SourceAtlasClaimState` includes stale, stale-critical, source-changed, disputed, contradicted, revoked, unsupported, and unknown states.
- `SourceAtlasFreshnessState` includes current, aging, stale, stale-critical, source-changed, disputed, revoked, unknown, user-provided, and needs-review states.
- `SourceAtlasFreshnessBrokerClaimState` and `SourceAtlasFreshnessManifest` carry claim state buckets, pack SHA, signatures, rollback pointers, and changed claim ids.
- `SourceAtlasStore` quarantines revoked and contradicted packs and marks last-known-good fallback as stale.
- `KnowledgeClaimSet` and `KnowledgeUncertaintyFlag` model conflicting/stale external knowledge inputs.
- AMB-679 defines source hash binding and AMB-680 defines duplicate/contradiction separation.

These anchors are source/control-plane evidence only. AMB-681 does not claim scanner implementation or runtime consumption exists.

## Failure Handling

Route to review-needed, source-needed, stale, stale-critical, source-changed, contradicted, revoked, quarantine, or rollback when:

- source hash changes after extraction
- official source withdraws or supersedes a claim
- source freshness window expires
- high-risk claim is stale, unknown, disputed, or source-changed
- contradictory claim appears in another source or pack
- duplicate merge hides contradiction evidence
- revocation manifest affects source, claim, pack, signer, or path
- freshness manifest is missing, unsigned, incompatible, stale, or hash-mismatched
- private/local user material is required to resolve a public-source conflict

Prefer blocked/review-needed over false current.

## Scaling Hotspots

Future implementation should bound:

- cross-pack contradiction graph recalculation
- freshness manifest fan-out
- stale-window checks for large claim sets
- high-risk review queue growth
- revocation propagation latency
- rollback lookup cost
- local/offline stale disclosure cost

No measured performance, storage, network, CPU, or battery proof is claimed by AMB-681.

## Non-Claims

This artifact does not implement contradiction scanners, freshness evaluators, revocation evaluators, schema migration, validators, release tooling, pack publication, Cloudflare/R2 setup, credential creation, live R2 writes, runtime fetch/cache/quarantine, runtime eligibility, runtime pack consumption, privacy/legal approval, release readiness, device proof, accessibility proof, security certification, or measured performance proof.
