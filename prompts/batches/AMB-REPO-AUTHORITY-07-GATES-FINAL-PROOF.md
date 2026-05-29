<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

AMB-REPO-AUTHORITY-07-GATES-FINAL-PROOF

# Objective

Install and run the final repo-authority gates so Ambitions cannot drift back into active-path sprawl, obsolete canon exposure, false release claims, or confusing front-door authority.

This phase is the final proof phase. It may only report GREEN if Phases 0–6 are GREEN and the final proof report verifies that the repository front door, frontend Visual Encyclopedia, backend posture, Codex OS portal, historical boundary, and active drift rules are all correct.

# Runner command

```bash
make batch BATCH=AMB-REPO-AUTHORITY-07-GATES-FINAL-PROOF PROMPT=prompts/batches/AMB-REPO-AUTHORITY-07-GATES-FINAL-PROOF.md
```

# Active source truth to inspect

```text
docs/status/repo-authority-cleanup-baseline.md
docs/status/repo-authority-cleanup-front-door-report.md
docs/status/repo-authority-cleanup-frontend-visual-encyclopedia-report.md
docs/status/repo-authority-cleanup-backend-honesty-report.md
docs/status/repo-authority-cleanup-codex-os-report.md
docs/status/repo-authority-cleanup-historical-archive-report.md
docs/status/repo-authority-cleanup-active-drift-report.md
README.md
frontend/README.md
frontend/installed-canon.md
frontend/intended-canon.md
frontend/visual-encyclopedia/
backend/README.md
codex-os/README.md
product-canon/README.md
validation/README.md
history/README.md
docs/truth/README.md
docs/truth/IMPLEMENTATION_TRUTH.md
docs/truth/RELEASE_TRUTH.md
docs/truth/HISTORICAL_POLICY.md
.codex/OPERATING_SYSTEM.md
.codex/REPO_INVENTORY.md
scripts/
```

# Allowed scope

```text
docs/status/repo-authority-cleanup-final-report.md
docs/status/repo-authority-cleanup-active-path-allowlist.md
docs/status/repo-authority-cleanup-green-gate-spec.md
scripts/ambitions-repo-authority-validate.py
README.md
frontend/**
backend/README.md
codex-os/README.md
product-canon/README.md
validation/README.md
history/README.md
docs/README.md
.codex/REPO_INVENTORY.md
```

Only touch portal/docs files to repair final broken links or authority labels. Only create `scripts/ambitions-repo-authority-validate.py` if no existing deterministic gate covers the required checks.

# Forbidden scope

- Do not add hosted backend/provider setup.
- Do not modify UI source unless a final gate proves a user-facing active blocker remains and build/test proof can be produced.
- Do not rewrite `scripts/ambitions-codex-train.sh`.
- Do not weaken `.codex/OPERATING_SYSTEM.md`.
- Do not delete historical material.
- Do not mark GREEN with unresolved RED or YELLOW continuation.
- Do not claim TestFlight/App Store/device/accessibility/performance/privacy/legal/release proof without cited repo proof.

# Required gates

Create or update deterministic gates/checks for:

- active README link validation
- active canon path allowlist
- Visual Encyclopedia authority scan
- Plan top-level IA regression scan
- Ambitions 2.0/3.0/4.0 active-path regression scan
- external/cloud LLM core-architecture regression scan
- unproofed release claim scan
- generated artifact leakage scan
- `.codex/runs` worktree pollution scan
- broken link scan
- duplicate active canon scan
- archive disclaimer scan

# Required actions

1. Confirm Phases 0–6 are GREEN or stop RED.
2. Create/update `docs/status/repo-authority-cleanup-active-path-allowlist.md`.
3. Create/update `docs/status/repo-authority-cleanup-final-report.md`.
4. If no adequate gate exists, create `scripts/ambitions-repo-authority-validate.py`.
   - It must be deterministic.
   - It must not require network.
   - It must support historical/archive allowlists.
   - It must fail active-path obsolete language and false release/provider/core-architecture claims.
5. Run available existing validators:

```bash
python scripts/ambitions-vocabulary-drift-scan.py
python scripts/ambitions-moat-drift-scan.py
python scripts/ambitions-authority-supersession-check.py
python scripts/ambitions-codex-os-validate.py
python scripts/ambitions-repo-authority-validate.py
```

Missing optional scripts must be recorded. Missing proof for a changed scope is RED.

6. Verify final root experience:
   - root README is understandable in under 60 seconds
   - frontend routes to Visual Encyclopedia
   - backend is local-first and honest
   - Codex OS has one visible human portal
   - historical material is contained and non-authoritative
   - active source paths do not expose obsolete Ambitions 2.0/3.0/4.0 or Plan-top-level canon
7. Confirm `git status --short` is clean after final commit, except ignored runner-managed artifacts.

# Validation expectations

Run and record:

```bash
git status --short
test -f docs/status/repo-authority-cleanup-final-report.md
test -f docs/status/repo-authority-cleanup-active-path-allowlist.md
test -f README.md
test -f frontend/README.md
test -f backend/README.md
test -f codex-os/README.md
test -f product-canon/README.md
test -f validation/README.md
test -f history/README.md
grep -n "Today / Goals / Capture / Time / You" README.md
grep -n "Visual Encyclopedia" README.md frontend/README.md
```

Run `scripts/ambitions-repo-authority-validate.py` if created. Run all available existing validators listed above.

# Visual proof expectations

If UI source changed in this phase, provide build/test proof and visual proof if the repo supports deterministic preview/screenshot generation. If user-facing UI source changed and no proof can be produced, stop RED.

# Hard Red stop conditions

- Any prior phase is not GREEN.
- Final report is missing.
- Active-path allowlist is missing.
- Active front doors still route to obsolete material as active guidance.
- Plan is visible as a top-level destination.
- Ambitions 2.0/3.0/4.0 remains active guidance.
- External/cloud LLMs or hosted providers remain required core architecture.
- Unproofed release/TestFlight/App Store/device/accessibility/performance/privacy/legal claims remain active.
- Broken active links remain.
- Generated run artifacts remain dirty/unclassified.
- Source changes occur without build/test proof.
- Validation script, if created, is nondeterministic or network-dependent.
- `git status --short` is not clean after final commit except ignored runner-managed artifacts.

# Rollback expectations

If committed, rollback is:

```bash
git revert <commit>
```

If uncommitted, provide exact `git checkout --` commands and remove commands for every touched file.

# GREEN criteria

- Phases 0–6 are GREEN.
- All final gates pass.
- Final report exists and cites proof.
- Active path allowlist exists.
- Root README and portals are clear.
- Visual Encyclopedia is the frontend front door.
- Backend posture is honest and local-first.
- Codex OS has one human portal plus preserved machine authority.
- Historical archive is non-authoritative and contained.
- No active-path sprawl remains.
- Commit and rollback are documented.

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
