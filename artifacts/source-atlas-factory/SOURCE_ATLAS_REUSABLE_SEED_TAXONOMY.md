# Source Atlas Reusable Seed Taxonomy

Status: Green for AMB-677 / PLOS-051 taxonomy documentation scope; Yellow for seed generation implementation, schema migration, release tooling, pack publication, runtime eligibility proof, live R2 promotion, privacy/legal approval, release readiness, device proof, accessibility proof, and measured performance proof.
Updated: 2026-06-12 America/New_York
Owning issue: AMB-677 / PLOS-051
Parent issue: AMB-613 / PLOS-M05

## Boundary

This artifact defines reusable Source Atlas seed classes, families, traits, and differentiation rules.

It does not implement seed generation, change Swift models, migrate schema, publish packs, provision Cloudflare/R2, create credentials, perform live R2 writes, change runtime eligibility, or implement runtime Step composition.

Seeds are reusable source-backed structures. They are not finished user-specific Steps, not schedules, not private user data, not proof/receipt stores, and not a shortcut around source authority, risk, jurisdiction, freshness, revocation, rollback, release receipt, or Step Quality gates.

## Taxonomy Classes

| Seed class | Purpose | Required traits | Red stop |
|---|---|---|---|
| `starter_seed` | Low-risk first action when full path authority is incomplete. | source ids, applicability envelope, starter-only label, blocked/full-path distinction. | Presents itself as full source-backed pathing. |
| `capability_seed` | Reusable skill, capability, or practice building block. | source claim ids, requirement ids, capability node, freshness state. | Drops source/requirement linkage. |
| `proof_seed` | Evidence, receipt, or verification requirement before/during/after execution. | proof candidate, proof strength, privacy class, receipt expectation. | Stores private proof or claims proof completion. |
| `requirement_seed` | Required condition, document, rule, equipment, access, or constraint. | requirement id, source/review/freshness/risk states, blocker behavior. | Treats unknown requirement state as pass. |
| `prerequisite_seed` | Before-you-start dependency or sequencing gate. | dependency ids, source state, missing-state route. | Generates a Step when dependency is missing but blocking. |
| `recovery_seed` | Safe recovery route after interruption, failure, fatigue, or changed reality. | recovery reason, proof/reflow receipt expectation, non-shame copy. | Frames recovery as failure or erases proof/reflow. |
| `replacement_seed` | Alternative path when a Step or path no longer fits. | replacement reason, preserved source authority, rollback/review link. | Silently swaps source or safety constraints. |
| `elasticity_seed` | Shrink, extend, defer, split, merge, or re-scope behavior. | mutation type, source/risk/deadline envelope, receipt requirement. | Mutates material scope without inspectable receipt. |
| `path_overlay_seed` | Reusable overlay for role, path, requirement, proof, or projection variants. | overlay id, dependency pack ids, overlay conflict rule. | Overrides base pack authority without conflict handling. |
| `momentum_tail_seed` | Optional follow-through after completion or closure. | optional flag, no score/streak dependency, continuity rationale. | Creates streak, shame, score, or fake urgency pressure. |
| `jurisdiction_seed` | Jurisdiction, age, eligibility, school, legal, travel, certification, or rule constraint. | jurisdiction key, risk class, blocked/unknown handling. | Allows authoritative pathing when jurisdiction is unknown. |
| `deadline_protection_seed` | Action/reflow pattern that protects a date or deadline. | deadline source, time window, consequence/reflow boundary. | Uses productivity pressure instead of source/deadline proof. |
| `resource_light_seed` | Lower-capacity alternative when time, energy, money, attention, mobility, or access is constrained. | resource constraint type, proof/safety preservation, eligibility rule. | Removes required proof/safety/source constraints for convenience. |
| `location_compatible_seed` | Location, access, mobility, environment, or device-compatible variant. | local context slot, privacy boundary, availability condition. | Embeds private location or assumes persistent tracking. |
| `split_merge_seed` | Decompose or combine Steps when scale changes. | split/merge reason, source trace, receipt continuity rule. | Loses traceability or proof lineage during split/merge. |

## Cross-Cutting Traits

Every reusable seed must carry:

- stable seed id and seed class
- source record ids and source claim or requirement ids when source-backed
- applicability envelope and explicit non-applicability states
- freshness, review, risk, and jurisdiction posture
- privacy class and no-private-user-data boundary
- proof or receipt expectation when the seed can affect execution
- runtime eligibility state that defaults to `not_eligible`
- hardcoded-finished-Step check result
- rollback, revocation, or quarantine route

## Family Rules

Seed families group compatible seed classes, not finished user plans:

- `entry_family`: starter and prerequisite seeds that help begin safely.
- `capability_family`: capability and requirement seeds that shape reusable path structure.
- `proof_family`: proof and receipt seeds that preserve trust.
- `adaptation_family`: recovery, replacement, elasticity, resource-light, split/merge, and deadline-protection seeds.
- `context_family`: jurisdiction, location-compatible, and path-overlay seeds.
- `continuity_family`: momentum-tail seeds and optional closure follow-through.

A family can be released only when each member seed has source binding, no-private-data proof, duplicate/contradiction handling, rollback/revocation route, and release receipt coverage.

## Differentiation Rules

- Starter seeds can suggest a safe beginning but cannot claim complete path authority.
- Capability seeds describe reusable capability structure; requirement seeds describe required conditions.
- Proof seeds describe what evidence is needed; they do not store private proof or mark proof complete.
- Recovery seeds restore continuity; replacement seeds choose a different path; elasticity seeds alter size, timing, or shape.
- Jurisdiction seeds can block or guard pathing; location-compatible seeds can only consume local context at runtime.
- Momentum-tail seeds are optional continuity aids, never streak, score, or shame mechanics.
- Split/merge seeds preserve source traceability and receipt lineage across shape changes.

## Release Eligibility

Reusable seeds remain `not_eligible` for runtime use until future active issues prove:

- schema compatibility
- source authority and immutable source binding
- duplicate and contradiction handling
- freshness and revocation posture
- risk and jurisdiction review
- private-data leak scan
- hardcoded-finished-Step scan
- Step Quality preflight readiness
- release receipt and rollback readiness

AMB-677 does not make any seed runtime-eligible.

## Existing Source Anchors

AMB-677 inspected these anchors:

- `docs/codex/SEED_BASED_PLANNING_LAW.md` defines the existing seed taxonomy and hardcoded-Step prohibition.
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift` defines `SourceAtlasStarterItem`, proof candidates, proof strength, pack starter items, validation issues, and the `storesFinalSchedule` hardcoded schedule guard.
- `artifacts/source-atlas-factory/SOURCE_ATLAS_PACK_SEED_FOUNDRY_PIPELINE.md` defines the pipeline stage that turns source-backed structure into reusable seed families.

These are source/control-plane anchors, not proof that production seed generation, release tooling, or runtime composition exists.

## Scaling Hotspots

Future implementation should bound:

- seed class fan-out across broad source packs
- duplicate seed detection
- contradiction scans between seed families
- cross-jurisdiction seed variants
- replacement/recovery/elasticity combinatorics
- release receipt size for large seed sets
- local runtime composition cost

No measured performance, storage, network, or battery proof is claimed by AMB-677.

## Non-Claims

This artifact does not implement seed generation, schema changes, validators, scanners, release tooling, pack publication, Cloudflare/R2 setup, credential creation, live R2 writes, runtime fetch/cache/quarantine, runtime eligibility, runtime Step composition, privacy/legal approval, release readiness, device proof, accessibility proof, or measured performance proof.
