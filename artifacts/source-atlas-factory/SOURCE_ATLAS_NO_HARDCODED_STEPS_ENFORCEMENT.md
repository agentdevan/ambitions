# Source Atlas No-Hardcoded-Steps Enforcement

Status: Green for AMB-685 / PLOS-059 no-hardcoded-Steps enforcement documentation scope; Yellow for lint/scanner implementation, schema migration, release tooling, pack publication, live Cloudflare/R2 staging proof, runtime fetch/cache/quarantine implementation, computed runtime eligibility, runtime consumption, privacy/legal approval, release readiness, device proof, accessibility proof, security certification, and measured performance proof.
Updated: 2026-06-13 America/New_York
Owning issue: AMB-685 / PLOS-059
Parent issue: AMB-613 / PLOS-M05

## Boundary

This artifact defines what counts as an impermissible hardcoded finished Step in Source Atlas packs, reusable seed packs, manifests, validation reports, release receipts, generated seed drafts, and future runtime pathing inputs.

It does not implement a lint or scanner, change Swift models, migrate schemas, publish packs, provision Cloudflare/R2, create credentials, perform live R2 writes, create canary objects, compute runtime eligibility, compose runtime Steps, or prove runtime consumption.

Source Atlas packs may contain reusable source-backed seeds, requirements, proof expectations, starter guidance, applicability envelopes, and Step physics constraints. They must not contain finished exact-user Steps that bypass local context, source authority, privacy boundaries, Step Quality, receipts, or user-specific runtime composition.

## Core Enforcement Rule

Production Source Atlas packs must store reusable seeds and source/proof/requirement/envelope metadata, not finished user-specific Steps.

A Step is the local runtime-composed result for a specific user, moment, capacity, proof state, source envelope, deadline, risk/jurisdiction state, and life context. A public Source Atlas pack can only provide reusable ingredients and constraints for that composition.

Any pack, seed, manifest, validation report, release receipt, or runtime path that violates this rule is blocked from release, R2 promotion, runtime eligibility, current-manifest selection, and runtime consumption.

## Forbidden Patterns

| Pattern | Why it is forbidden | Required routing |
|---|---|---|
| Exact private goal Step | Stores a finished Step for one user's private goal. | Block; route to local-only user mini-pack if user-owned and private. |
| Finished schedule Step | Contains exact dates, times, recurrence, or calendar placement as public source truth. | Block; schedule must be composed locally. |
| Profile-dependent Step | Encodes private energy, location, health, capacity, preferences, disability, family, work, or identity facts. | Block from public pack; keep as local personalization slot only. |
| Proof-complete Step | Claims the user has already supplied or completed proof. | Block; proof seeds may define proof needed only. |
| Source-free recommendation | Presents a Step as source-backed without source record, claim, requirement, freshness, review, and applicability envelope. | `source_needed` or `review_needed`. |
| Universal action command | Uses generic productivity commands as if they fit every user and context. | Convert to reusable seed or reject. |
| Unsafe high-risk instruction | Emits legal, medical, financial, crisis, age-sensitive, jurisdiction-sensitive, or regulated finished action without review and jurisdiction gates. | Block or guarded review-needed state. |
| Hidden replacement Step | Silently swaps source, safety, proof, deadline, or jurisdiction constraints. | Block; replacement seed must preserve reason and receipt. |
| Elasticity-as-task-resize | Shrinks/extends/splits/merges without preserving source, proof, deadline, consequence, and receipt lineage. | Block until Step Quality/reflow gates pass. |
| R2 personal Step | Places private or exact-user Step content in R2-bound object, path, metadata, manifest, log, screenshot, release receipt, or validation report. | Red quarantine and revocation. |
| Current-manifest shortcut | Lets a pack become current/runtime-eligible because it has nice Step copy but lacks release receipt, rollback, revocation, freshness, and Step Quality evidence. | Block runtime eligibility. |

## Allowed Patterns

| Pattern | Allowed when |
|---|---|
| Reusable seed | It carries source ids, claim/requirement ids, applicability envelope, risk/jurisdiction state, freshness/revocation state, privacy class, proof/receipt expectation, rollback route, and `not_eligible` default. |
| Starter guidance | It is labeled starter-only, low-risk, bounded, not full path authority, and does not claim source-backed completion. |
| Requirement seed | It names conditions, documents, equipment, access, jurisdiction, or prerequisite gates without generating a finished user action. |
| Proof seed | It defines evidence needed without storing private proof or claiming proof completion. |
| Recovery/replacement/elasticity seed | It preserves source, proof, deadline, risk/jurisdiction, consequence, rollback, and receipt lineage and waits for local runtime composition. |
| Local user mini-pack value model | It is explicitly local-only, user-owned, not public Source Atlas truth, not R2-bound, not default-shareable, correctable/deletable, and excluded from source-backed runtime authority. |
| Test/fixture Step | It remains clearly test/fixture/demo-only and is not treated as production Source Atlas pack truth or release proof. |

## Enforcement Checks

Future automation should fail a candidate pack, seed, manifest, or release receipt when:

- a public pack contains a `Step`, `CompiledStep`, final action command, exact schedule, or exact private goal as its primary payload
- a seed lacks source binding, applicability envelope, freshness/revocation state, risk/jurisdiction state, proof/receipt expectation, rollback route, or runtime eligibility state
- a seed claims `eligible` before source binding, freshness, revocation, review/risk/jurisdiction, release receipt, rollback, Step Quality, computed runtime eligibility, and runtime consumption gates are proven
- a validation report or release receipt lacks no-hardcoded-Step result
- a pack uses approved copy such as `Recommended step`, `Start now`, or `Open step` to mask a finished user-specific Step
- private user data appears in pack body, object path, metadata, manifest, validation report, release receipt, log, screenshot, Linear comment, or support artifact
- high-risk, jurisdiction-sensitive, stale, contradicted, revoked, unsupported, or unknown states generate executable finished Steps instead of guarded, source-needed, review-needed, blocked, recovery, replacement, or proof-needed routes

## Required Evidence In Release Receipts

Every release receipt for a pack or seed set must include:

- no-hardcoded-Step validation result
- any detected forbidden pattern ids and disposition
- confirmation that public artifacts contain no private user data
- source binding, freshness, revocation, risk, jurisdiction, review, rollback, and Step Quality preflight status
- runtime eligibility result, defaulting to `not_eligible`
- non-claims for lint/scanner implementation, runtime composition, runtime consumption, live R2 staging, production readiness, privacy/legal approval, and release readiness when not proven

Missing no-hardcoded-Step evidence blocks staged/released/R2 promotion Green.

## Failure Handling

Failures route as follows:

- exact private/user Step in public pack: quarantine and block release
- private data in R2-bound artifact or proof: Red quarantine, revocation path, and replacement receipt
- source-free finished recommendation: source-needed or review-needed
- high-risk finished instruction: blocked or guarded review-needed
- missing no-hardcoded-Step evidence: block release and runtime eligibility
- fixture/test Step confused as production: classify as fixture/test and block production claim
- local user mini-pack confused as source truth: local-only downgrade and source-truth block

No failure may be repaired by renaming a finished Step as a seed, moving private context into metadata, hiding exact schedule details in a receipt, or claiming runtime eligibility from clean copy alone.

## Existing Anchors

AMB-685 inspected and extends:

- `docs/codex/SEED_BASED_PLANNING_LAW.md`
- `docs/codex/SOURCE_ATLAS_AUTHORITY_LAW.md`
- `docs/codex/STEP_ELASTICITY_RUNTIME_LAW.md`
- `artifacts/source-atlas-factory/SOURCE_ATLAS_PACK_SEED_FOUNDRY_PIPELINE.md`
- `artifacts/source-atlas-factory/SOURCE_ATLAS_REUSABLE_SEED_TAXONOMY.md`
- `artifacts/source-atlas-factory/SOURCE_ATLAS_SEED_FAMILY_GENERATION.md`
- `artifacts/source-atlas-factory/SOURCE_ATLAS_RELEASE_RECEIPT_REQUIREMENTS.md`
- `Native/Ambitions/Domain/AmbitionsOSLocalGoalPackModels.swift`
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`

These anchors are source/control-plane evidence only. AMB-685 does not claim scanner implementation or runtime enforcement exists.

## Non-Claims

This artifact does not implement lint/scanner automation, schema migration, release tooling, pack publication, Cloudflare/R2 setup, credential creation, live R2 writes, canary objects, runtime fetch/cache/quarantine, computed runtime eligibility, runtime Step composition, runtime pack consumption, app source changes, privacy/legal approval, release readiness, device proof, accessibility proof, measured performance proof, AMB-973 execution, AMB-617 runtime consumption, AMB-635 production certification, or AMB-613 parent completion.
