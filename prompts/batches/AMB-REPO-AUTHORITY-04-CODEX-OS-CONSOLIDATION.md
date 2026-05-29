<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches
> Prior recommended actions: Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-19279448

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->
<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap
> Dispositions: merge-or-sequence-file-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

AMB-REPO-AUTHORITY-04-CODEX-OS-CONSOLIDATION

# Objective

Make Codex OS understandable from one visible human portal while preserving the active machine authority spine.

This phase must remove confusion between `.codex/`, `docs/codex/`, `docs/codex-os/`, `prompts/`, `scripts/`, `build/reports/`, generated run artifacts, and historical Codex material.

# Runner command

```bash
make batch BATCH=AMB-REPO-AUTHORITY-04-CODEX-OS-CONSOLIDATION PROMPT=prompts/batches/AMB-REPO-AUTHORITY-04-CODEX-OS-CONSOLIDATION.md
```

# Active source truth to inspect

```text
docs/status/repo-authority-cleanup-baseline.md
docs/status/repo-authority-cleanup-front-door-report.md
codex-os/README.md
.codex/OPERATING_SYSTEM.md
.codex/REPO_INVENTORY.md
.codex/SKILL_GOVERNANCE.md
docs/codex/CODEX_OS_INDEX.md
docs/codex-os/
docs/codex/
prompts/batches/
scripts/
build/reports/
docs/status/
```

# Allowed scope

```text
codex-os/README.md
.codex/REPO_INVENTORY.md
docs/codex/CODEX_OS_INDEX.md
docs/codex-os/**
docs/README.md
README.md
validation/README.md
history/README.md
docs/status/repo-authority-cleanup-codex-os-report.md
```

Move/archive only clearly historical Codex OS documentation if inbound links are updated and the historical/archive policy permits it. Otherwise classify and defer to Phase 5.

# Forbidden scope

- Do not rewrite `scripts/ambitions-codex-train.sh`.
- Do not remove `.codex/OPERATING_SYSTEM.md` or active governance.
- Do not delete proof artifacts required for traceability.
- Do not make `.codex/runs/` part of active repo content.
- Do not move active batch prompts into history.
- Do not claim cleanup execution is complete.

# Required target behavior

`codex-os/README.md` must be the human Codex OS portal and route to:

- Active machine control plane → `.codex/OPERATING_SYSTEM.md`
- Repo inventory → `.codex/REPO_INVENTORY.md`
- Supporting Codex docs → `docs/codex/`
- Batch prompts → `prompts/batches/`
- Validation scripts → `scripts/`
- Proof/status reports → `docs/status/`
- Historical Codex material → `history/` or the repo-approved archive location

`.codex/OPERATING_SYSTEM.md` remains the active machine authority.

# Required actions

1. Confirm Phases 0–3 are GREEN or stop RED.
2. Inspect Codex OS-related docs and classify them as active machine authority, active human portal, supporting docs, active prompts, generated proof/report, temporary artifact, historical, archive candidate, or unknown.
3. Update `codex-os/README.md` as the single visible human portal.
4. Update `.codex/REPO_INVENTORY.md` to reflect root portals and the new active/historical boundary.
5. Ensure `docs/codex/CODEX_OS_INDEX.md` is supporting, not a competing front door.
6. Classify `docs/codex-os/*`; move only clearly historical material if safe, otherwise defer with explicit classification.
7. Ensure generated run artifacts and `.codex/runs/` are not active repo content.
8. Write `docs/status/repo-authority-cleanup-codex-os-report.md` with classification, changes, validation, rollback, and deferred decisions.

# Validation expectations

Run and record:

```bash
git status --short
test -f codex-os/README.md
test -f .codex/OPERATING_SYSTEM.md
test -f .codex/REPO_INVENTORY.md
test -f docs/status/repo-authority-cleanup-codex-os-report.md
grep -n ".codex/OPERATING_SYSTEM.md" codex-os/README.md
grep -n "prompts/batches" codex-os/README.md
grep -n "scripts/" codex-os/README.md
grep -n "docs/status" codex-os/README.md
```

If link-check tooling exists, run it against touched Markdown. If no tool exists, manually verify touched links.

# Visual proof expectations

None. This phase must not change UI.

# Hard Red stop conditions

- Any prior phase is not GREEN.
- `.codex/OPERATING_SYSTEM.md` is weakened, moved, or contradicted.
- Multiple visible Codex OS front doors still claim primary authority.
- Historical Codex material remains presented as active.
- `.codex/runs/` becomes active content.
- Link validation fails.
- Runner script is modified.

# Rollback expectations

If committed, rollback is:

```bash
git revert <commit>
```

If uncommitted, list exact restore/move-back commands for touched files.

# GREEN criteria

- `codex-os/README.md` is the visible human portal.
- `.codex/OPERATING_SYSTEM.md` remains active machine authority.
- Supporting/historical Codex material is classified.
- Repo inventory reflects the new portal IA.
- Validation and rollback are documented.

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
