# Program Execution Contract

Status: Active PLOS M00 governance law
Issue: AMB-644 / PLOS-008
Parent: AMB-608 / PLOS-M00
Authority posture: Supporting Codex/PLOS execution contract subordinate to `docs/truth/*` and `docs/codex-os/*`
Runtime implementation proof: none

This contract tells Codex how to execute PLOS and other Goal Mode program issues without inventing per-issue process. It extends existing Goal Mode standards instead of creating a parallel governance system.

## Core Contract

Codex must work existing-first, repair evidence-backed Red/Yellow gaps when the active issue allows it, preserve non-waivable safety gates, and close issues only with proof artifacts and honest no-claim boundaries.

Human review is not a Green acceptance gate for ordinary Goal Mode issue execution unless the active issue explicitly says owner/human approval is required for that issue. Codex may still record Yellow for owner/device/release/legal proof that is not available.

## Existing-First Rule

Before adding process, docs, scripts, validators, or proof artifacts, Codex must inspect existing repo authority:

- truth files
- `AGENTS.md`
- program GOAL file
- program run-state file
- program skill
- existing Codex OS standards
- existing scripts and validators
- existing proof ledger and reports
- live source/test/script ownership when source work is in scope
- actual Linear `AMB-*` issue text

Rules:

- extend existing systems before creating new systems
- do not create parallel governance unless the gap is proven and recorded
- use deterministic scripts and structured validators before ad hoc prose
- never let stale docs override truth files or live source
- never use PLOS labels as Linear issue identifiers

## Source-Changing Guard

No source-changing work may begin until the active issue authorizes source changes and the active runtime/source ownership is proven.

Required source-changing posture:

- no source edit before runtime path proof where relevant
- no preview-only edits unless scoped
- no UI work before the active runtime path is known
- no app source/test/project/package/privacy/entitlement edits during governance-only issues
- no new runtime dependency, hosted service, cloud AI path, telemetry, analytics, signing automation, or write-capable tooling without explicit approval
- use relevant source ownership, concept lock, parallel implementation, privacy/source/safety, and release gates before Green

Docs/scripts/artifacts issues may inspect source without changing it.

## Codex Authority Model

Inside an active issue scope, Codex may:

- resolve Red and Yellow through evidence-based repair
- split work into narrower commits when the issue remains coherent
- create follow-up issue recommendations
- create follow-up issues only when the user or issue allows it and Linear identifiers remain `AMB-*`
- resequence safe work inside the same phase when dependency proof requires it
- continue through safe Yellow when all continuation rules pass
- update run-state, changelog, decisions, risk register, and proof ledger as evidence changes
- validate closeout locally before Linear writes

Codex must stop on unresolved Red, non-waivable gate failure, unresolved `AMB-*` binding, phase-order violation, private data/R2 boundary risk, app source mutation outside scope, or a required approval that the active issue explicitly makes blocking.

## Non-Waivable Gates

These gates cannot be waived by issue convenience, prompt wording, time pressure, or local partial proof:

- privacy
- safety
- source authority
- high-risk legal/medical/financial/jurisdiction
- App Review and release readiness
- signing/security
- data boundary
- local-first architecture
- private user data in R2
- cloud LLM/core server exclusion
- proof artifact and receipt requirements
- phase order
- actual `AMB-*` Linear identifiers

If a non-waivable gate fails, the issue is Red until repaired or explicitly rescoped by owner authority.

## Yellow Continuation Rules

Codex may continue through Yellow only when all conditions hold:

- fallback behavior exists or the gap is governance-only
- no unsafe user-facing claim exists
- no release/privacy/accessibility/device/performance/owner approval claim is made
- follow-up owns the gap
- the gap has a named owner or phase
- non-waivable gates pass
- run-state and closeout record the Yellow limit
- Green claims are narrowed to the evidence-supported scope

Yellow cannot authorize runtime implementation claims, release readiness, private data movement, high-risk unsafe behavior, or phase-order bypass.

## Issue Closure Report

Every PLOS child/phase closeout must include:

- Status
- Summary
- Files changed
- Linear changes
- Validation
- Proof artifacts
- Runtime path proof
- Privacy/safety/source checks
- Accessibility checks
- Performance notes
- Rollback/failure behavior
- Remaining Yellow/Red
- Follow-up issues created
- Next issue to run

Closeout must also state:

- actual `AMB-*` issue covered
- parent `AMB-*` issue when applicable
- pushed hash
- whether app source changed
- whether runtime features were implemented
- whether PLOS-M00 is complete or parent gate remains in progress
- owner approval claim status
- release/TestFlight/App Store readiness claim status

Use `python3 scripts/codex/linear-closeout-validate.py --program plos --scope child` before posting PLOS child closeout.

## Token Optimization Rules

Long repeated instructions live in docs and skills.

Issues should reference:

- this contract
- program GOAL
- program run-state
- phase gates
- relevant laws
- relevant validator commands
- closeout template

Avoid:

- duplicating the full master plan in every issue
- pasting massive search logs into Linear
- reprinting truth files in reports
- creating new process docs when a current doc can be extended
- verbose architecture summaries without proof decisions

Reports must be concise but complete: enough to reproduce the claim, not enough to drown the next run.

## No Architecture Theater

No model-only Green unless the issue is explicitly model-only and future runtime owner is named.

User-visible maturity requires user-visible proof. UI maturity requires screenshot review and accessibility evidence. Runtime maturity requires source, validation, receipts, and replay/rollback evidence. Privacy/legal/release maturity requires current proof and approval artifacts.

Governance-only issues may be Green for governance scope, but must not imply app behavior changed.

## Green / Yellow / Red

Green:

- scoped work complete
- existing-first inspection performed
- changed files stay in allowed scope
- required validation passes or is truly not applicable
- proof artifacts exist
- run-state/proof ledger updated
- Linear closeout uses actual `AMB-*`
- no claim exceeds proof

Yellow:

- scoped work is structurally correct but a named external/manual/future proof gap remains
- non-waivable gates pass
- no unsafe user-facing claim exists
- owner/phase/follow-up is recorded

Red:

- PLOS label used as Linear identifier
- unresolved phase-order violation
- privacy/safety/source/security/data-boundary gate failure
- private user data in R2 or public Source Atlas object
- app source mutation outside scope
- release/accessibility/privacy/legal/device/performance/owner claim without evidence
- issue closure without proof artifacts
- token-heavy duplication encouraged as the process

## Cross-Links

- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/codex-os/GOAL_MODE_EXECUTION_POLICY.md`
- `docs/codex-os/RUN_STATE_STANDARD.md`
- `docs/codex-os/PROOF_ARTIFACT_STANDARD.md`
- `docs/codex-os/SCRIPT_OUTPUT_STANDARD.md`
- `docs/codex-os/LINEAR_CLOSEOUT_STANDARD.md`
- `artifacts/plos-runtime/PLOS_GOAL.md`
- `artifacts/plos-runtime/PLOS-run-state.md`
- `artifacts/plos-runtime/PLOS_PHASE_GATES.md`
- `.agents/skills/plos-runtime-master-build/SKILL.md`

## Non-Claims

AMB-644 does not claim:

- product runtime implementation
- app source change
- issue rewrite across all children
- new Linear issues created
- release readiness
- TestFlight readiness
- App Store readiness
- owner approval
- accessibility certification
- privacy/legal approval
- PLOS-M00 completion
- PLOS-M01 or later execution
