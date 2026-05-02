# AOS30 AmbitionsOS Beyond Roadmap Prompt

Status: Future batch prompt; do not run automatically

Objective: AmbitionsOS Beyond Roadmap.
Owning kernel: Governance.
Affected surface: roadmap.
Precondition: runs only after AOS28 or explicit user decision.
Boundary: only after AOS28 or explicit decision.
Allowed files: only files named by the future approved prompt.
Forbidden files: .github/workflows, runtime dependencies, unscoped app code, persistence/schema unless explicitly in scope, release claim edits without evidence.

## Required Codex OS Gates

- Required skills: aos-train-orchestrator, aos-invariant-enforcer, runtime-contract-reviewer, validation-evidence-auditor, release-claim-truth-enforcer, plus kernel-specific reviewers.
- Required review board: AmbitionsOS architecture/product/privacy/performance/accessibility/release/maintainability/compatibility board as applicable.
- Required validation packs: AOS dependency graph, invariant ledger, fixture coverage, model boundary, privacy projection, source-truth claim, release-claim boundary, plus focused implementation proof where applicable.
- Required fixtures: named fixture group from `docs/codex/AMBITIONSOS_AOS_FIXTURE_STRATEGY.md`.
- Required evidence ledger entry: command, timestamp, log path, pass/fail/partial status, proof scope, and what it does not claim.
- Required traceability matrix update: canon requirement, owning kernel, code/test/fixture evidence, gaps.
- Required test impact matrix update.
- Required source-truth claim ledger update if source-sensitive.
- Required privacy projection review if sensitive or external-surface data is involved.
- Required performance budget review if runtime/projection work is involved.
- Required compatibility review if routes, raw values, widgets, App Intents, import/export, or persistence are involved.
- Required maintainability review if touching large files or extraction candidates.
- Required release-claim review before any claim language changes.
- Stop conditions: dependency violation, forbidden files, unclassified failure, release overclaim, source overclaim, privacy leak, performance risk, hidden model mutation, app behavior outside scope.
- Repair/failure-forensics path: classify failure, preserve logs, run focused proof first, then broad proof, and update registry only after evidence.


Closeout must report files, validation, evidence, risks, release-claim impact, rollback, and next allowed batch.
