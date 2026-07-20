+++
spec_id = "STANDARD-VALIDATION-RELEASE"
title = "Validation and Release"
kind = "standard"
status = "normative"
owner_domain = "standard-validation-release"
canon_revision = 2
profile = "standard-v1"
owns_concepts = [
  "standard.validation.changed-scope",
  "standard.validation.build",
  "standard.validation.behavior",
  "standard.validation.ui-accessibility",
  "standard.validation.data-safety",
  "standard.validation.concurrency",
  "standard.validation.security-privacy",
  "standard.validation.performance",
  "engineering.release.identity",
  "engineering.release.domains",
  "engineering.release.rollback",
  "standard.validation.no-ceremony",
]
inherits = ["CONST-PROOF-EVIDENCE-001", "LAW-DATA-LOSS-STOP-SHIP-001"]
depends_on = ["CONSTITUTION", "STANDARD-ACCESSIBILITY", "STANDARD-TESTING-FIXTURES"]
source_owners = ["Native/Ambitions/Quality/", ".github/workflows/code-quality.yml", "scripts/"]
+++

# Validation and Release

Validation exists to detect concrete defects in source code, compilation,
tests, generated project state, security, privacy, persistence, migration,
replay, concurrency, accessibility, performance, and data integrity. It does
not authorize work or require process artifacts.

## STANDARD-VALIDATION-CHANGED-SCOPE-001 — Changed-scope routing

- **Concept:** `standard.validation.changed-scope`
- **Modality:** `MUST`
- **Scope:** Every tracked change
- **Status:** `normative`
- **Verification:** `CI-CODE-QUALITY-001`
- **Supersedes:** none

Every change MUST pass `git diff --check`, secrets scanning, and the applicable
changed-file route. SwiftLint and meaningful static analysis remain enabled.
Run broader lanes only when dependency impact or release scope requires them;
changed-file routing must never skip a test that covers affected behavior.

## STANDARD-VALIDATION-BUILD-001 — Build and generated-project integrity

- **Concept:** `standard.validation.build`
- **Modality:** `MUST`
- **Scope:** Swift, package, project, build-setting, asset, and generated-project changes
- **Status:** `normative`
- **Verification:** `BUILD-NO-SIGN-001`, `XCODEGEN-DRIFT-001`
- **Supersedes:** none

Applicable changes MUST compile with the supported Swift/Xcode toolchain and a
no-sign build or build-for-testing lane. `project.yml` remains XcodeGen source
authority; regeneration MUST leave no unexplained `Ambitions.xcodeproj` drift.
Dependency locks and generated project state must match the source revision
being built.

## STANDARD-VALIDATION-BEHAVIOR-001 — Behavioral unit and integration tests

- **Concept:** `standard.validation.behavior`
- **Modality:** `MUST`
- **Scope:** Domain logic, commands, projections, integrations, failure handling, and recovery
- **Status:** `normative`
- **Verification:** Applicable focused unit and integration suites
- **Supersedes:** none

Changed logic MUST have focused tests for its successful path, invalid inputs,
meaningful failure paths, cancellation, retry/idempotency, and recovery where
applicable. Tests must assert observable state and durable effects rather than
source strings, filenames, or the presence of declarations. A failing test may
be fixed only by correcting the product or the test's genuinely stale contract;
tests must not be weakened merely to make CI pass.

## STANDARD-VALIDATION-UI-ACCESSIBILITY-001 — UI and accessibility behavior

- **Concept:** `standard.validation.ui-accessibility`
- **Modality:** `MUST`
- **Scope:** Changed visible hierarchy, navigation, interaction, motion, copy, and accessibility behavior
- **Status:** `normative`
- **Verification:** Applicable UI, screenshot, hierarchy, and accessibility suites
- **Supersedes:** none

UI changes MUST test affected navigation, interaction, focus, state, and
degraded behavior. Visual changes must be inspected against the relevant design
reference at representative light/dark and content states. Dynamic Type,
VoiceOver semantics and order, hit targets, contrast, Reduce Motion, Reduce
Transparency, and non-color state communication are required when the changed
scope affects them. Screenshots alone cannot certify nonvisual behavior.

## STANDARD-VALIDATION-DATA-SAFETY-001 — Persistence, migration, and replay

- **Concept:** `standard.validation.data-safety`
- **Modality:** `MUST`
- **Scope:** Persistence, schemas, imports, exports, sync, repair, deletion, commands, events, projections, receipts, and replay
- **Status:** `normative`
- **Verification:** Applicable persistence, migration, replay, rollback, and corruption suites
- **Supersedes:** none

Data-affecting changes MUST test prior-version migration, default values,
atomic failure, restart/replay convergence, duplicate delivery, interruption,
rollback or forward repair, deletion/restore, and corruption handling as
applicable. Accepted local state must not become visible before its durable
authority commits. Command, Event, Projection, Receipt, and Replay identity must
remain deterministic and idempotent.

## STANDARD-VALIDATION-CONCURRENCY-001 — Concurrency correctness

- **Concept:** `standard.validation.concurrency`
- **Modality:** `MUST`
- **Scope:** Actor isolation, tasks, cancellation, ordering, shared state, and concurrent persistence
- **Status:** `normative`
- **Verification:** Applicable concurrency and race suites plus strict-concurrency compilation
- **Supersedes:** none

Concurrency changes MUST compile under the repository's strict-concurrency
settings and test cancellation, reentrancy, ordering, duplicate execution,
stale revisions, and race-prone boundaries where applicable. Production code
must not add unchecked isolation or `Sendable` escapes merely to silence the
compiler.

## STANDARD-VALIDATION-SECURITY-PRIVACY-001 — Security and privacy boundaries

- **Concept:** `standard.validation.security-privacy`
- **Modality:** `MUST`
- **Scope:** Secrets, private data, network egress, permissions, account state, R2, Source Atlas, extensions, logs, and exports
- **Status:** `normative`
- **Verification:** Secrets scan plus applicable security, privacy, and request-shape suites
- **Supersedes:** none

Secrets scanning remains mandatory. Changes touching private data, network
requests, permissions, logging, account behavior, extensions, exports, R2, or
Source Atlas MUST test allowlisted fields, rejection of private-graph data,
least-privilege behavior, denial/recovery paths, redaction, and offline behavior
as applicable. Source Atlas and R2 remain public/reference-only.

## STANDARD-VALIDATION-PERFORMANCE-001 — Performance and energy

- **Concept:** `standard.validation.performance`
- **Modality:** `MUST`
- **Scope:** Changed hot paths, launch, scrolling, rendering, search, persistence, migration, background work, and memory
- **Status:** `normative`
- **Verification:** Applicable benchmark, signpost, Instruments, memory, or energy suite
- **Supersedes:** none

Changes likely to affect latency, frame pacing, memory, storage, energy, or
background execution MUST run the relevant measured lane on a stable fixture
and environment. A regression outside the declared tolerance is a product
defect and blocks the affected change until repaired or the budget is changed
for a concrete user-facing reason.

## RELEASE-001 — Exact release identity

- **Concept:** `engineering.release.identity`
- **Modality:** `MUST`
- **Scope:** Release candidates
- **Status:** `normative`
- **Verification:** Release build and archive checks
- **Supersedes:** none

A release candidate MUST identify one source revision, generated project state,
dependency lock state, build number, configuration, signing context, and target
environment so failures and rollback refer to the same binary.

## RELEASE-002 — Required release domains

- **Concept:** `engineering.release.domains`
- **Modality:** `MUST`
- **Scope:** Release acceptance
- **Status:** `normative`
- **Verification:** Applicable release test matrix
- **Supersedes:** none

Release validation MUST cover compilation, focused and broad behavioral tests,
data migration and restore, accessibility, privacy manifest and required-reason
APIs, secrets/security, performance, supported devices, extensions, account and
entitlement behavior, import/export, and store/archive configuration wherever
the release includes those capabilities.

## RELEASE-003 — Rollout and rollback

- **Concept:** `engineering.release.rollback`
- **Modality:** `MUST`
- **Scope:** Distribution
- **Status:** `normative`
- **Verification:** Release rollback or forward-repair procedure
- **Supersedes:** none

Distribution MUST have a concrete rollback or forward-repair path that respects
schema compatibility and preserves user data. Staged rollout and monitoring are
used when the release risk warrants them.

## STANDARD-VALIDATION-NO-CEREMONY-001 — No process-only gates

- **Concept:** `standard.validation.no-ceremony`
- **Modality:** `MUST NOT`
- **Scope:** Ordinary repository changes
- **Status:** `normative`
- **Verification:** Canon integrity check and workflow review
- **Supersedes:** none

Validation MUST NOT require task starts or finalizations, signatures, intake
packs, path authorization, environment approvals, attestations, receipts,
ledgers, bot reactions, owner self-approval, issue links, proof packs, or status
wording. A gate remains only when its failure identifies a concrete product,
source, build, generated-project, test, security, privacy, accessibility,
performance, persistence, migration, replay, concurrency, or data-integrity
defect.
