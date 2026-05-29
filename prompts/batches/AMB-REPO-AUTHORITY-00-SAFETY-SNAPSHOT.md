<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

AMB-REPO-AUTHORITY-00-SAFETY-SNAPSHOT

# Objective

Establish a safe, cited baseline before any repo-authority cleanup begins. This phase must prove branch/worktree safety, identify active authority anchors, map visible front doors, and classify cleanup targets before later phases move, rewrite, archive, or delete anything.

# Runner command

```bash
make batch BATCH=AMB-REPO-AUTHORITY-00-SAFETY-SNAPSHOT PROMPT=prompts/batches/AMB-REPO-AUTHORITY-00-SAFETY-SNAPSHOT.md
```

# Active source truth to inspect

```text
README.md
AGENTS.md
docs/README.md
docs/AGENTS.md
docs/truth/README.md
docs/truth/IMPLEMENTATION_TRUTH.md
docs/truth/RELEASE_TRUTH.md
docs/truth/HISTORICAL_POLICY.md
docs/truth/PRODUCT_MOAT_TRUTH.md
docs/status/current-implementation-map.md
docs/status/repo-cleanup-index.md
docs/status/archive-and-stale-material-ledger.md
docs/status/quarantine-archive-folder-plan.md
docs/status/visual-canon-moat-installation-report.md
docs/canon/README.md
docs/canon/frontend/README.md
docs/canon/frontend/AMBITIONS_FRONT_END_ARCHITECTURE_ATLAS_AND_VISUAL_ENCYCLOPEDIA.md
.codex/OPERATING_SYSTEM.md
.codex/REPO_INVENTORY.md
.codex/SKILL_GOVERNANCE.md
docs/codex/CODEX_OS_INDEX.md
docs/codex-os/
prompts/
scripts/
build/reports/
project.yml
Package.swift
Native/Ambitions/App/AppTab.swift
Native/Ambitions/App/AmbitionsRootView.swift
Native/AmbitionsUITests/AmbitionsUITests.swift
Native/AmbitionsWidgetExtension/NextStepWidget.swift
.env.example
skills-lock.json
```

# Allowed scope

- Inspect any path.
- Create/update only `docs/status/repo-authority-cleanup-baseline.md`.
- Create temporary local notes only if they are removed before final status.

# Forbidden scope

- Do not rewrite README or portal docs.
- Do not move, delete, archive, or rename files.
- Do not modify app source.
- Do not modify runner scripts.
- Do not repair vocabulary drift in this phase.

# Required actions

1. Confirm current branch is `main`.
2. Capture `git status --short`.
3. Fail RED for unrelated dirty worktree changes.
4. Map current root-level directories and active front-door files.
5. Identify competing front doors and possible authority collisions.
6. Scan active paths and historical-looking paths for:
   - `Ambitions 2.0`, `Ambitions_2_0`
   - `Ambitions 3.0`, `Ambitions_3_0`
   - `Ambitions 4.0`, `Ambitions_4_0`
   - `Plan` as top-level destination
   - `Start now`, `Start now`, `Open Focus`
   - `Recommended step`, `Your Recommended step`, `Recommended step`
   - generic top-level chatbot framing
   - external/cloud LLM as core architecture
   - Supabase/Expo/provider setup as active architecture
   - unproofed release/TestFlight/App Store/device claims
7. Classify hits as active blocker, compatibility-only, historical-only, supporting reference, false-claim risk, or unknown.
8. Produce a cleanup target set with risk ratings.
9. Write `docs/status/repo-authority-cleanup-baseline.md`.

# Validation expectations

Run and record:

```bash
git branch --show-current
git status --short
find . -maxdepth 2 -type d | sort
find . -maxdepth 2 -type f \( -name 'README.md' -o -name 'AGENTS.md' \) | sort
test -f docs/status/repo-authority-cleanup-baseline.md
```

Run available existing validators if they are read-only or report-only. Record missing optional scripts without failing this phase.

# Visual proof expectations

None. This phase must not change UI.

# Hard Red stop conditions

- Not on `main` and cannot safely switch.
- Dirty unrelated worktree.
- Missing active truth spine with no current equivalent.
- `.codex/runs/` or generated artifact pollution cannot be classified or safely ignored.
- Baseline report cannot be written.

# Rollback expectations

If the baseline report is the only changed file, rollback is:

```bash
git checkout -- docs/status/repo-authority-cleanup-baseline.md
```

If committed, rollback is:

```bash
git revert <commit>
```

# GREEN criteria

- Branch/worktree safety proven.
- Baseline report exists.
- Current front doors are mapped.
- Stale language scan is recorded.
- Cleanup target set is classified.
- No cleanup has been executed.

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
