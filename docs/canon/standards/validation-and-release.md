+++
spec_id = "STANDARD-VALIDATION-RELEASE"
title = "Validation and Release"
kind = "standard"
status = "normative"
owner_domain = "standard-validation-release"
canon_revision = 1
profile = "standard-v1"
owns_concepts = [
  "standard.visual-proof.screenshot-matrix",
  "standard.acceptance.ia",
  "standard.acceptance.object-model",
  "standard.acceptance.first-viewports",
  "standard.acceptance.interaction",
  "standard.acceptance.visual-copy",
  "standard.acceptance.proof",
  "engineering.release.identity",
  "engineering.release.domains",
  "engineering.release.rollout",
  "engineering.release.claim-ceiling",
  "engineering.governance.role-separation",
  "engineering.governance.independent-acceptance",
  "engineering.governance.handoff",
  "engineering.governance.stop-conditions",
  "engineering.governance.registry",
  "engineering.governance.registry-integrity",
  "engineering.governance.audit",
  "engineering.governance.change-manifest",
  "engineering.governance.amendment",
  "engineering.governance.stable-ids",
  "engineering.governance.periodic-audit",
  "engineering.governance.evidence-amendment",
  "standard.acceptance.scenario-proof",
  "standard.acceptance.build",
  "standard.acceptance.status",
  "standard.acceptance.documentation",
  "standard.acceptance.source",
  "engineering.codex.issue-readiness",
  "engineering.governance.architecture-ownership",
  "engineering.governance.validation-state",
  "engineering.codex.preflight",
  "standard.acceptance.replacement",
  "engineering.governance.evolution-horizon",
  "standard.acceptance.visual",
]
inherits = ["CONST-PROOF-EVIDENCE-001", "CONST-HISTORY-SUPERSESSION-001", "AUTHORITY-AMENDMENT-001"]
depends_on = ["CONSTITUTION", "STANDARD-ACCESSIBILITY", "STANDARD-TESTING-FIXTURES"]
source_owners = ["Native/Ambitions/Quality/", "docs/canon/", "scripts/"]
+++

# Validation and Release

This shadow standard owns cross-cutting acceptance, evidence, independent-review, release-identity, and amendment controls. It changes no release state.

## STANDARD-SCREENSHOT-MATRIX-001 — Reviewable visual matrix
- **Concept:** `standard.visual-proof.screenshot-matrix`
- **Modality:** `MUST`
- **Scope:** Visual and surface acceptance
- **Status:** `normative`
- **Verification:** `AUDIT-SCREENSHOT-MATRIX-001`
- **Supersedes:** none

Visual evidence MUST bind exact commit, approved stable target IDs, actual renders, named states/data, device/OS, appearance, Dynamic Type, reduced effects, contrast, critique, reviewer, gaps, and claim ceiling.

## STANDARD-ACCEPTANCE-IA-001 — IA acceptance
- **Concept:** `standard.acceptance.ia`
- **Modality:** `MUST`
- **Scope:** Root and global navigation
- **Status:** `normative`
- **Verification:** `SCENARIO-ACCEPTANCE-IA-001`
- **Supersedes:** none

IA acceptance MUST prove exactly Today, Goals, Time, You roots; Capture global composition; Motion behavior; Trust inspection; correct routing/restoration; and no legacy root authority.

## STANDARD-ACCEPTANCE-OBJECTS-001 — Object-model acceptance
- **Concept:** `standard.acceptance.object-model`
- **Modality:** `MUST`
- **Scope:** Canonical objects and projections
- **Status:** `normative`
- **Verification:** `SCENARIO-ACCEPTANCE-OBJECTS-001`
- **Supersedes:** none

Object acceptance MUST prove stable identity, one mutation owner, valid/invalid lifecycle, relationships, deletion/restore/archive, history/receipts, privacy/sync class, import/export, projections, accessibility, and migration.

## STANDARD-ACCEPTANCE-VIEWPORTS-001 — First-viewport acceptance
- **Concept:** `standard.acceptance.first-viewports`
- **Modality:** `MUST`
- **Scope:** Flagship and global presented surfaces
- **Status:** `normative`
- **Verification:** `PROOF-ACCEPTANCE-VIEWPORTS-001`
- **Supersedes:** none

First viewports MUST foreground the owning object/question, useful state and action, calm hierarchy, integrated shell, and truthful empty/degraded/failure behavior without exposing architecture taxonomy.

A root surface MUST show one dominant object in the first viewport.

## STANDARD-ACCEPTANCE-INTERACTION-001 — Interaction acceptance
- **Concept:** `standard.acceptance.interaction`
- **Modality:** `MUST`
- **Scope:** Material actions and transitions
- **Status:** `normative`
- **Verification:** `SCENARIO-ACCEPTANCE-INTERACTION-001`
- **Supersedes:** none

Interaction acceptance MUST prove preview/validation where material, deterministic durable effect, Receipt/History, cancellation, interruption/resume, failure/recovery, undo/rollback, accessibility, offline behavior, and focus continuity.

## STANDARD-ACCEPTANCE-VISUAL-COPY-001 — Visual and copy acceptance
- **Concept:** `standard.acceptance.visual-copy`
- **Modality:** `MUST`
- **Scope:** Rendered product and user language
- **Status:** `normative`
- **Verification:** `REVIEW-ACCEPTANCE-VISUAL-COPY-001`
- **Supersedes:** none

Visual/copy acceptance MUST compare current renders with stable approved authority, preserve semantic tokens and locked language, cover accessibility states, and record independent findings without turning target existence into parity proof.

## STANDARD-ACCEPTANCE-PROOF-001 — Exact-scope proof ceiling
- **Concept:** `standard.acceptance.proof`
- **Modality:** `MUST NOT`
- **Scope:** Governance and readiness claims
- **Status:** `normative`
- **Verification:** `AUDIT-ACCEPTANCE-CLAIM-CEILING-001`
- **Supersedes:** none

Governance completion MUST NOT claim Product, Runtime, Visual, Accessibility, Privacy/legal, Device, TestFlight, App Store, or Release Green. Each claim requires current exact-scope evidence, environment, command/result, artifact, owner/reviewer where required, gaps, rollback, and ceiling.

Product and IA MUST NOT be declared Spec Ready from decisions alone.

The launch bar MUST NOT be that Ambitions has screens for these areas.

Future intelligence, product, runtime, and launch-readiness claims SHOULD be tested against the canonical orchestration scenarios defined by mission law.

Ambitions MUST be successful when the user can enjoy today while knowing that today is connected to a future they are actively building.

A service-and-repository runtime scaffold MUST NOT prove the Private Life Runtime until user-visible canonical state changes are inspectable, replayable, projected, receipted, and locally bounded.

Canon MUST NOT be proof.

A Feature MUST NOT be Green because source exists or a screen renders.

The exact-scope proof ceiling MUST use current build and test logs.

Product canon MUST prevail over conflicting visual guidance.

Acceptance law MUST define the source-versus-rendered boundary, split status model, visual-proof limits, product-object dominance, and prohibition on self-certified Visual or Release Green.

Rendered UI tests, frame and hierarchy checks, current-build screenshots, accessibility evidence, and independent review MUST set the scoped visual acceptance ceiling.

Exact-scope proof ceiling MUST NOT use one unqualified `Green`.

A component MUST be first-class only when its rendered state shows dominant-object or clear-child hierarchy, one hierarchy owner, no duplicate shell or global ownership, product behavior without explanatory prose, passing screenshot and frame hierarchy gates, passing Dynamic Type, VoiceOver, reduced-effects and contrast checks, comparison with an approved visual target, and removal or replacement without reachable fallback UI.

Every visible shell/control concept MUST have one owner.

Every visual closeout MUST provide reviewable image artifacts.

A test that only checks source strings MUST NOT certify UI.

The UI lane MUST complete with zero unexpected failures.

Root product objects MUST NOT be text reports.

Accepted Yellow MUST NOT be implementation acceptance for incomplete required scope.

`Independent visual reviewer` MUST be required for Visual Green.

Screenshots are useful proof artifacts, but screenshots alone MUST NOT prove accessibility, performance, privacy, release readiness, or device correctness.

Current scripts, logs, artifacts, and required owner approvals MUST set release claim status.

A proof-status label MUST NOT make its claim true; linked evidence MUST determine the claim ceiling.

Forbidden claims MAY become allowed only when current proof exists and this file is updated.

Build success MUST require current build proof.

Expected failures MUST count as failures for the scoped claim.

Yellow MAY be allowed when source or process exists but validation is incomplete, unavailable, environment-limited, or not current.

A release claim MUST NOT exceed its current proof.

Current checks, logs, proof packs, and accepted artifacts MUST set the claim ceiling.

Required lanes MUST finish with zero unexpected failures, zero expected failures, zero unreviewed skips, and a readable `.xcresult` or log summary before any Green claim.

Proof-sensitive claims MUST NOT use one unqualified `Green` label.

A Codex report MUST NOT claim build, device, release, privacy, account, R2, accessibility, performance, TestFlight, App Store, or production readiness without current evidence.

Documentation and governance proof MUST provide the truth-file diff, preserved authority relationship, absence of new canon conflicts, relevant script or check output, and `git diff --check`.

Source, Visual, Runtime, Accessibility, Device, TestFlight, App Store, Account, R2, Privacy, and Release claims MUST NOT use one unqualified Green label.

Documentation, plans, source names, screenshot paths, and string scans MUST NOT be treated as implementation, product, or release proof.

Proof artifacts, scripts, logs, and accepted evidence MUST set the closeout ceiling; prose MUST NOT upgrade missing, failed, stale, or not-run proof.

Each implementation project MUST add focused domain, projection, UI, accessibility, migration, recurrence, time-zone, import/diff, sync, and extension tests relevant to its scope.

Command validation, idempotency, receipt, replay, and rollback MUST be proven.

A launch-required opportunity MUST be First-Class Green only when every applicable dimension is Green.

Truth files MUST define authority and standards.

Constitution and Atlas text MUST NOT by themselves prove implementation completeness, local build success, test success, visual quality, accessibility conformance, performance validation, physical-device validation, TestFlight or App Store readiness, or release approval.

Source work and closeout MUST use Implemented Green, Implemented Yellow, Partial, Aspirational, Deprecated, Blocked, or Unknown from `CODEX_START_HERE.md`.

When evidence is missing, closeout MUST report the narrower status and next follow-up and MUST NOT turn canon, plans, source names, screenshots, or generated reports into fake Green.

Source proof MUST provide canonical owner paths, compiled code, focused unit and UI tests, and evidence that forbidden IA drift is absent.

Old batch reports, generated proof ledgers, screenshots, prompts, train closeouts, and deleted control-plane material MUST NOT be implementation proof.

## RELEASE-001 — Exact release identity
- **Concept:** `engineering.release.identity`
- **Modality:** `MUST`
- **Scope:** Release candidates
- **Status:** `normative`
- **Verification:** `AUDIT-RELEASE-IDENTITY-001`
- **Supersedes:** none

A release candidate MUST bind one commit, generated project state, dependency locks, build number, configuration, signing identity, environments, and evidence manifest.

## RELEASE-002 — Required release domains
- **Concept:** `engineering.release.domains`
- **Modality:** `MUST`
- **Scope:** Release acceptance
- **Status:** `normative`
- **Verification:** `AUDIT-RELEASE-DOMAINS-001`
- **Supersedes:** none

Release review MUST cover build, tests, migration, accessibility, privacy manifest and required-reason APIs, security, performance, device matrix, extensions, account/entitlement, archive/export, store metadata/URLs/notes, and rollback.

## RELEASE-003 — Rollout and rollback
- **Concept:** `engineering.release.rollout`
- **Modality:** `MUST`
- **Scope:** Distribution
- **Status:** `normative`
- **Verification:** `REVIEW-ROLLOUT-ROLLBACK-001`
- **Supersedes:** none

Distribution MUST define staged rollout, monitoring, stop criteria, rollback/forward-fix, migration constraints, and emergency path.

## RELEASE-004 — No unsupported readiness
- **Concept:** `engineering.release.claim-ceiling`
- **Modality:** `MUST NOT`
- **Scope:** Readiness status
- **Status:** `normative`
- **Verification:** `AUDIT-NO-UNSUPPORTED-READINESS-001`
- **Supersedes:** none

TestFlight, App Store, privacy, accessibility, performance, CloudKit, R2, account, device, Product, Runtime, or Visual readiness MUST NOT be claimed without exact current evidence and required independent/owner approval.

A simulator screenshot MUST have a Yellow maximum visual claim ceiling.

Release claim governance MUST define the proof standard, permitted and forbidden release claims, release status, and evidence requirements.

Local-first product truth MUST NOT prove privacy readiness.

Release claim MAY be Green only when the exact claim has current proof.

Visual Green MUST require current physical-device screenshots or video.

Ambitions Account, Sign in with Apple, Google Sign-In, account recovery, entitlements, account-gated R2 access, and account private-graph behavior MUST NOT be claimed implemented unless current source and proof establish them.

R2 freshness, production updates, Source Atlas pack readiness, entitlement gating, and privacy validation MUST NOT be claimed without current source and proof.

TestFlight, App Store, privacy, accessibility, performance, CloudKit, R2, account, or device readiness claims MUST require current exact-commit evidence and required independent approval.

## CODEX-DEPT-001 — Independent role separation
- **Concept:** `engineering.governance.role-separation`
- **Modality:** `MUST`
- **Scope:** Implementation and governance review
- **Status:** `normative`
- **Verification:** `AUDIT-ROLE-SEPARATION-001`
- **Supersedes:** none

Applicable product, frontend, runtime, persistence, privacy/security, QA/reliability, accessibility, performance, release, and governance responsibilities MUST have named owners and independent review boundaries.

Codex MAY be autonomous only inside evidence-bound, truth-file-bound, user-approved limits.

## CODEX-DEPT-002 — Author cannot self-accept
- **Concept:** `engineering.governance.independent-acceptance`
- **Modality:** `MUST NOT`
- **Scope:** Visual, security-sensitive, data-migration, destructive, and release acceptance
- **Status:** `normative`
- **Verification:** `AUDIT-INDEPENDENT-ACCEPTANCE-001`
- **Supersedes:** none

An author MUST NOT self-accept a scope requiring independent or owner approval.

An authoring implementation pass MAY produce Source, Runtime, or Interaction evidence but MUST NOT self-certify Visual Green, security-sensitive acceptance, data-migration acceptance, or release acceptance; an independent reviewer MUST decide those claims from current exact-scope evidence.

## CODEX-DEPT-003 — Complete handoff
- **Concept:** `engineering.governance.handoff`
- **Modality:** `MUST`
- **Scope:** Task, train, and release handoff
- **Status:** `normative`
- **Verification:** `AUDIT-HANDOFF-001`
- **Supersedes:** none

Handoffs MUST state laws/specs, source owners, source readback, changes, invariants, tests run/not run, proof, unsupported claims, risks, external actions, rollback, and claim ceiling.

A resumed handoff MUST treat the newest user-visible instruction as authoritative over summaries.

Complete handoff MUST re-run repo orientation.

## CODEX-DEPT-004 — Stop conditions
- **Concept:** `engineering.governance.stop-conditions`
- **Modality:** `MUST`
- **Scope:** Execution
- **Status:** `normative`
- **Verification:** `AUDIT-STOP-CONDITIONS-001`
- **Supersedes:** none

Work MUST stop on data-loss risk, privacy breach, unresolved duplicate authority/material conflict, failing required lane, unreviewable required evidence, unapproved destructive migration, or unsupported readiness claim.

A master fold-in, release branch, `implementation complete` claim, product Green claim, or next-surface handoff MUST NOT occur until the active umbrella proof gate is complete and accepted.

Codex MUST stop and report Red for data-loss risk, a privacy-boundary breach, unresolved duplicate authority, a failing required lane, unreviewable visual evidence, an unapproved destructive migration, or an unsupported release claim.

## ENFORCEMENT-001 — One normative registry graph
- **Concept:** `engineering.governance.registry`
- **Modality:** `MUST`
- **Scope:** Canon registries and generated projections
- **Status:** `normative`
- **Verification:** `AUDIT-NORMATIVE-REGISTRY-001`
- **Supersedes:** none

Normative Markdown, manifest, schemas, mappings, ledgers, and deterministic projections MUST form one closed graph and MUST NOT create a parallel engineering constitution.

The parent Constitution MUST remain supreme for product/design law.

Engineering specificity MAY extend the Compact Constitution but MUST NOT weaken it.

## ENFORCEMENT-002 — Registry integrity
- **Concept:** `engineering.governance.registry-integrity`
- **Modality:** `MUST`
- **Scope:** Requirements and concepts
- **Status:** `normative`
- **Verification:** `AUDIT-REGISTRY-INTEGRITY-001`
- **Supersedes:** none

Every requirement MUST have stable identity, one concept owner, modality/priority, dependencies, source/test/proof ownership, status, and claim ceiling where applicable.

A future issue SHOULD NOT be accepted as Codex-ready unless it explains its relationship to canon; a narrow cleanup, security, or build issue MUST explicitly state that it does not affect product mission and preserves repository health.

A Codex leaf MUST NOT be vague.

Codex MUST NOT receive vague issues such as “fix Capture” or “make Goals better”.

`Features/` MUST NOT be a canonical owner for new Ambitions architecture.

The final architecture tree MUST be binding path ownership, not a suggestion.

## ENFORCEMENT-003 — Deterministic offline audit
- **Concept:** `engineering.governance.audit`
- **Modality:** `MUST`
- **Scope:** Canon compiler and CI
- **Status:** `normative`
- **Verification:** `TEST-CANON-AUDIT-001`
- **Supersedes:** none

Audit/build MUST run offline on Python 3.12 standard library, fail closed on graph/coverage/semantic-loss defects, and emit sorted atomic newline-terminated output without volatile timestamps.

Local/generated state MAY be created for active validation.

Historical material MUST remain ignored unless explicitly scoped as current release proof.

Deterministic offline audit MUST NOT prevent vague "AI behavior", architecture lore, or prose-only proof from replacing deterministic local contract engineering.

## ENFORCEMENT-004 — Change compliance manifest
- **Concept:** `engineering.governance.change-manifest`
- **Modality:** `MUST`
- **Scope:** Substantive changes
- **Status:** `normative`
- **Verification:** `AUDIT-CHANGE-MANIFEST-001`
- **Supersedes:** none

Substantive changes MUST report affected IDs/concepts, owners, migrations, data classes, tests, proof, gaps, external impact, rollback, and exact claim ceiling.

Before editing, Codex MUST read truth files, inspect live source, identify task type, define narrow scope, list likely touched files, list validation commands, identify rollback, identify hard-red risks, and classify the claim being made.

A change compliance manifest MUST record baseline and final SHAs.

Future trains that touch product-experience behavior MUST update the relevant gate status as Existing, Partial, Missing, or Unknown and attach evidence paths only when current evidence exists.

New UI MUST NOT delete old canonical behavior until replacement reachability, migration, tests, screenshots, and rollback are proven.

Change compliance manifest MUST use this manifest for every substantive Ambitions PR.

Change compliance manifest MUST remove sections only when explicitly inapplicable and state why.

Implementation evidence MAY come from current Swift source, project configuration, package manifests, resources, entitlements, privacy manifest, scripts, tests, current validation logs, checked-in current proof artifacts, and current repo tree evidence.

## EVOLUTION-001 — Amendment process
- **Concept:** `engineering.governance.amendment`
- **Modality:** `MUST`
- **Scope:** Normative amendment
- **Status:** `normative`
- **Verification:** `AUDIT-AMENDMENT-001`
- **Supersedes:** none

Amendments MUST state problem, current/proposed law, rationale, supersession, affected product/source/tests, migration, privacy/accessibility/performance/proof impact, owner decision, and rollback.

Every product-experience scenario MUST be testable.

A constitutional amendment MUST state its exact law changes, rationale, impact, migration, validation, approval, and rollback.

## EVOLUTION-002 — Stable IDs are never reused
- **Concept:** `engineering.governance.stable-ids`
- **Modality:** `MUST NOT`
- **Scope:** Retired requirement and concept identity
- **Status:** `normative`
- **Verification:** `AUDIT-ID-REUSE-001`
- **Supersedes:** none

Retired IDs MUST NOT be reused; replacement and provenance MUST remain in the supersession ledger and Git history.

Law and opportunity IDs MUST NOT be reused.

Removed laws MUST remain in a supersession ledger.

## EVOLUTION-003 — Periodic authority audit
- **Concept:** `engineering.governance.periodic-audit`
- **Modality:** `MUST`
- **Scope:** At least annual and pre-first-release governance
- **Status:** `normative`
- **Verification:** `AUDIT-PERIODIC-AUTHORITY-001`
- **Supersedes:** none

Audit MUST cover law/profile completeness, registry/source-owner drift, semantic loss, tests/proof, dependency/security, accessibility, performance, privacy, and stale or contradictory authority.

An authority audit MUST run at least annually and before the first App Store release.

## EVOLUTION-004 — Evidence-driven amendment
- **Concept:** `engineering.governance.evidence-amendment`
- **Modality:** `MUST NOT`
- **Scope:** Law weakening
- **Status:** `normative`
- **Verification:** `REVIEW-EVIDENCE-AMENDMENT-001`
- **Supersedes:** none

Implementation difficulty alone MUST NOT weaken law; amendment requires product, safety, user-consequence, compatibility, evidence, migration, and rollback reasoning.

Every major Ambitions capability MUST be classified by implementation horizon.

A change MUST require product, safety, and evidence reasoning.

<!-- canon-section: purpose -->
Exact acceptance binds stable identities, current evidence, independent roles, distribution state, deterministic enforcement, owner gates, amendment impact, and rollback.
<!-- canon-section: scope -->
Applies to governance, implementation, proof, review, distribution, and canon evolution while product behavior remains with exact owners.
<!-- canon-section: requirements -->
The requirements consolidate useful Articles 36 and 41–43 plus accepted v3 acceptance standards without preserving fixed article topology.
<!-- canon-section: exceptions -->
No exception may self-approve, bypass an owner gate, relabel failed/not-run proof, weaken data/privacy/accessibility law, or authorize destructive action; narrower exceptions require explicit approval and rollback.
<!-- canon-section: verification -->
Verify with deterministic compiler gates, exact evidence manifests, independent reviews, owner approvals, distribution checks, semantic-loss audit, and rollback proof.
<!-- canon-section: source-ownership -->
`Quality/`, exact source owners, `docs/canon/`, and retained scripts own their artifacts; governance completion does not prove production conformance.
<!-- canon-section: proof -->
Exact-commit evidence includes commands/exits, generated comparisons, semantic-loss counts, independent verdicts, owner approvals, candidate identity where applicable, findings, artifacts, rollback, and claim ceiling.
<!-- canon-section: amendment-impact -->
Amendments identify every affected ID/concept, owner, product/source/test/proof/external impact, semantic-loss disposition, approval, claim ceiling, migration, destruction, and rollback.

## STANDARD-ACCEPTANCE-SCENARIOS-001 — Scenario acceptance

- **Concept:** `standard.acceptance.scenario-proof`
- **Modality:** `MUST`
- **Scope:** Canonical orchestration scenarios
- **Status:** `normative`
- **Verification:** `SCENARIO-ACCEPTANCE-CANONICAL-001`
- **Supersedes:** none

Scenario acceptance MUST exercise the canonical orchestration scenarios and preserve their explicit claim ceiling.

## STANDARD-ACCEPTANCE-VISUAL-001 — Visual acceptance

- **Concept:** `standard.acceptance.visual`
- **Modality:** `MUST`
- **Scope:** Rendered visual acceptance
- **Status:** `normative`
- **Verification:** `REVIEW-ACCEPTANCE-VISUAL-001`
- **Supersedes:** none

Visual acceptance MUST bind approved authority, current rendered evidence, accessibility variants, critique, and independent review without allowing screenshots alone to certify nonvisual claims.

## STANDARD-ACCEPTANCE-BUILD-001 — Build acceptance

- **Concept:** `standard.acceptance.build`
- **Modality:** `MUST`
- **Scope:** Build evidence
- **Status:** `normative`
- **Verification:** `AUDIT-ACCEPTANCE-BUILD-001`
- **Supersedes:** none

Build acceptance MUST bind the exact commit, generated project state, configuration, command, result, readable logs, and unexpected-failure count.

## STANDARD-ACCEPTANCE-STATUS-001 — Status acceptance

- **Concept:** `standard.acceptance.status`
- **Modality:** `MUST`
- **Scope:** Scoped status claims
- **Status:** `normative`
- **Verification:** `AUDIT-ACCEPTANCE-STATUS-001`
- **Supersedes:** none

Status acceptance MUST use the approved scoped taxonomy and MUST NOT upgrade missing, stale, failed, or not-run evidence.

## STANDARD-ACCEPTANCE-DOCS-001 — Documentation acceptance

- **Concept:** `standard.acceptance.documentation`
- **Modality:** `MUST`
- **Scope:** Documentation and governance
- **Status:** `normative`
- **Verification:** `AUDIT-ACCEPTANCE-DOCS-001`
- **Supersedes:** none

Documentation acceptance MUST prove authority consistency, exact diffs, relevant checks, and clean patch state while remaining below implementation and release claims.

## STANDARD-ACCEPTANCE-SOURCE-001 — Source acceptance

- **Concept:** `standard.acceptance.source`
- **Modality:** `MUST`
- **Scope:** Source implementation claims
- **Status:** `normative`
- **Verification:** `AUDIT-ACCEPTANCE-SOURCE-001`
- **Supersedes:** none

Source acceptance MUST bind canonical owner paths, compiled code, focused tests, and absence of forbidden authority drift.

## CODEX-ISSUE-READINESS-001 — Codex issue readiness

- **Concept:** `engineering.codex.issue-readiness`
- **Modality:** `MUST`
- **Scope:** Implementation issue intake
- **Status:** `normative`
- **Verification:** `AUDIT-CODEX-ISSUE-READINESS-001`
- **Supersedes:** none

A Codex implementation issue MUST bind current canon scope, source ownership, required tests, forbidden changes, proof ceiling, and rollback before source edits are authorized.

## ENFORCEMENT-ARCHITECTURE-OWNERSHIP-001 — Architecture ownership enforcement

- **Concept:** `engineering.governance.architecture-ownership`
- **Modality:** `MUST`
- **Scope:** Canonical source ownership
- **Status:** `normative`
- **Verification:** `AUDIT-ARCHITECTURE-OWNERSHIP-001`
- **Supersedes:** none

Architecture enforcement MUST reject new or moved authority outside its exact canonical owner and MUST expose unresolved compatibility debt.

## ENFORCEMENT-VALIDATION-STATE-001 — Validation-state enforcement

- **Concept:** `engineering.governance.validation-state`
- **Modality:** `MUST`
- **Scope:** Validation reporting
- **Status:** `normative`
- **Verification:** `AUDIT-VALIDATION-STATE-001`
- **Supersedes:** none

Validation reporting MUST record exact command, exit code, output artifact, not-run reason, failure disposition, and claim ceiling.

## CODEX-PREFLIGHT-001 — Codex preflight

- **Concept:** `engineering.codex.preflight`
- **Modality:** `MUST`
- **Scope:** Source-edit authorization
- **Status:** `normative`
- **Verification:** `AUDIT-CODEX-PREFLIGHT-001`
- **Supersedes:** none

Codex MUST refresh canon revision, Git state, issue scope, ownership, known gaps, and proof posture before source edits or resumed work.

## STANDARD-ACCEPTANCE-REPLACEMENT-001 — Replacement acceptance

- **Concept:** `standard.acceptance.replacement`
- **Modality:** `MUST`
- **Scope:** Authority replacement
- **Status:** `normative`
- **Verification:** `AUDIT-ACCEPTANCE-REPLACEMENT-001`
- **Supersedes:** none

Replacement acceptance MUST prove disposition of every prior authority, preservation of accepted unique concepts, inbound-reference rewrites, reproducibility, and rollback.

## EVOLUTION-HORIZON-001 — Evolution horizon

- **Concept:** `engineering.governance.evolution-horizon`
- **Modality:** `MUST`
- **Scope:** Canon amendments
- **Status:** `normative`
- **Verification:** `AUDIT-EVOLUTION-HORIZON-001`
- **Supersedes:** none

A canon amendment MUST state its compatibility horizon, supersession effects, migration obligations, validation plan, and rollback.
