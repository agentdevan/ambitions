# Codex Prompt — FAANG Handoff Repo Cleanup And Readiness

Use this prompt in Codex from the repository root.

---

```markdown
You are Codex acting as a principal-level FAANG product-engineering handoff owner, senior iOS engineer, technical program manager, documentation architect, and repo hygiene lead for the Ambitions native iOS repo.

Your job is to make this repository as close as possible to FAANG-handoff ready: clean, navigable, buildable, audited, and executable by an external world-class team without founder explanation.

Do not ask me questions unless you are truly blocked by missing credentials or unavailable local tooling. Make intelligent decisions, document them, and preserve evidence.

## Non-negotiable source docs

Read these first:

1. `README.md`
2. `docs/README.md`
3. `docs/canon/README.md`
4. `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
5. `docs/canon/Ambitions_3_0_Documentation_System_Index.md`
6. `docs/canon/Ambitions_3_0_FAANG_Handoff_Readiness_Gate.md`
7. `docs/canon/Ambitions_3_0_Repo_Hygiene_And_Active_Canon_Policy.md`
8. `docs/canon/Ambitions_3_0_Product_Language_System.md`
9. `docs/canon/Ambitions_3_0_Content_QA_And_Copy_Guard.md`
10. `docs/canon/Ambitions_3_0_Migration_And_Deprecation_Plan.md`
11. `docs/canon/Ambitions_3_0_Front_End_Implementation_Batch_Plan.md`
12. `docs/canon/Ambitions_3_0_Current_Implementation_Gap_Audit.md`
13. `docs/canon/Ambitions_3_0_Release_Readiness_And_Evidence_Gates.md`
14. `docs/codex/BATCH_REGISTRY.md`
15. `docs/codex/CONTEXT_INDEX.md`

Ambitions 3.0 is the active product/build source of truth. Older v2 or historical docs are supporting context unless explicitly kept binding by the 3.0 source override.

## Primary outcome

Bring the repo to the highest possible handoff-readiness state in one complete pass.

The final result must include:

1. A complete tracked-file inventory.
2. Removal or relocation of generated/scratch junk.
3. No orphan active docs.
4. 3.0-first README/docs/canon indexes.
5. Controlled legacy language only in approved migration/copy-guard locations.
6. Clear internal identifier migration status.
7. Build/test evidence or exact reason each command could not run.
8. A final handoff-readiness report with pass/fail for every gate.

## Operating rules

- Be aggressive about removing generated junk, but not reckless with product history.
- Do not delete useful historical evidence if it belongs in `docs/archive/` or supports roadmap/build provenance.
- Do not delete tests to make the repo appear cleaner.
- Do not rewrite product direction away from Ambitions 3.0.
- Do not invent new top-level destinations.
- Do not claim readiness without evidence.
- Do not leave a dirty tree unless you are mid-task and explain why.
- Do not preserve files merely because they exist. Every tracked file needs a purpose.

## Phase 0 — Baseline

Run:

```bash
git status --short
git branch --show-current
git rev-parse HEAD
git ls-files > /tmp/ambitions-tracked-files.txt
find . -path ./.git -prune -o -type f | sed 's#^./##' | sort > /tmp/ambitions-all-files.txt
```

Create `docs/audits/` if missing.

## Phase 1 — Complete file inventory

Create:

```text
docs/audits/faang-handoff-file-inventory.csv
```

CSV columns:

```csv
path,class,owner,purpose,active_indexed,action,status,notes
```

Class must be exactly one of:

- `active-code`
- `active-canon`
- `implementation-control`
- `test-fixture`
- `archived-evidence`
- `generated-remove`
- `migrate-or-rename`
- `delete`

Rules:

- Every `git ls-files` path must appear exactly once.
- No blank purpose fields.
- No vague purposes like "misc" or "old".
- Any `delete` or `generated-remove` row must be acted on in this batch unless deletion is unsafe; if unsafe, explain why.
- Any `migrate-or-rename` row must have a proposed target.

## Phase 2 — Generated artifact purge

Identify and remove tracked generated artifacts.

Likely candidates include:

```text
tmp/
output/
*.ndjson
*.log
*.tmp
*.xcresult
DerivedData/
local scratch builders
inspection dumps
```

Run:

```bash
git ls-files | grep -E '(^tmp/|^output/|\.ndjson$|\.log$|\.tmp$|\.xcresult$|DerivedData)' || true
```

For each match:

- delete if generated/scratch
- move only if it is a permanent artifact that belongs under `docs/`, `docs/presentations/`, or `docs/audits/`
- update `.gitignore` if a missing ignore rule allowed it

## Phase 3 — Active index integrity

Ensure these are consistent and 3.0-first:

- `README.md`
- `docs/README.md`
- `docs/canon/README.md`
- `docs/canon/Ambitions_3_0_Documentation_System_Index.md`
- `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
- `docs/codex/CONTEXT_INDEX.md`

Run a link/orphan check:

```bash
python3 - <<'PY'
from pathlib import Path
import re
mds = sorted(Path('.').glob('**/*.md'))
mds = [p for p in mds if '.git' not in p.parts]
text = '\n'.join(p.read_text(errors='ignore') for p in mds)
for p in mds:
    s = str(p)
    if s.startswith('docs/archive/'):
        continue
    if s in {'README.md','docs/README.md','docs/canon/README.md'}:
        continue
    if s not in text:
        print('UNLINKED_MD', s)
PY
```

Fix active orphan docs by linking, archiving, or deleting. Historical docs should not be linked as active unless explicitly still binding.

## Phase 4 — Legacy language scan

Run scans for deprecated user-facing language.

Start with:

```bash
rg -n --hidden --glob '!/.git/**' \
  'Start Focus|Focus Session|best next move|next best move|AI confidence|productivity score|profile tab|insights tab|habits tab|overdue|failed|missed' . || true
```

Allowed locations:

- `docs/canon/Ambitions_3_0_Product_Language_System.md`
- `docs/canon/Ambitions_3_0_Content_QA_And_Copy_Guard.md`
- `docs/canon/Ambitions_3_0_Migration_And_Deprecation_Plan.md`
- `docs/canon/Ambitions_3_0_Repo_Hygiene_And_Active_Canon_Policy.md`
- `docs/canon/Ambitions_3_0_FAANG_Handoff_Readiness_Gate.md`
- `docs/archive/**`
- compatibility tests explicitly documenting compatibility intent

All other occurrences must be corrected or explicitly justified in the report.

## Phase 5 — Internal identifier migration audit

Run:

```bash
rg -n --hidden --glob '!/.git/**' 'startFocus|TodayFocus|activeFocus|bestNextMove|capturesInbox|Insights|Profile|Habits' Native Sources AppUI docs .github project.yml || true
```

For each result:

- decide whether it is user-facing, internal compatibility, archive/history, test, or active debt
- fix user-facing copy immediately
- do not perform risky enum/model renames unless you can update all call sites and tests cleanly
- document remaining internal migration debt in the handoff report

If safe and scoped, migrate:

- `startFocus` toward `startStepSession`
- execution-session `focus` toward `stepSession`
- `TodayFocus*` toward `TodayStepSession*`
- `activeFocus` toward `activeStepSession`
- `bestNextMove` toward `recommendedStep`

Preserve compatibility adapters only where existing persisted values, deep links, App Intents, widgets, or tests require them.

## Phase 6 — Duplicate / stale docs review

Find likely duplicate or superseded docs:

```bash
find docs -name '*.md' | sort
rg -n '^# ' docs/canon docs/codex docs/archive | sort > docs/audits/faang-handoff-doc-headings.txt
```

For each older doc:

- if active 3.0 replaced it, move it to `docs/archive/` or mark it as supporting older canon from an index
- if it is still binding, link it from the proper 3.0 index with a reason
- if it is duplicate generated prompt junk, delete it

Do not let historical docs remain in active paths without an explicit purpose.

## Phase 7 — Traceability matrix

Create:

```text
docs/audits/faang-handoff-traceability-matrix.md
```

Include at least these rows:

- Ambitions product thesis
- five canonical destinations
- Capture → Place → Plan → Do Today → Close / Recover → Save Proof loop
- Today / Start here
- Capture / What needs a place?
- Placement Resolver
- Plan Life Suite
- Action Closure / Still Counts
- Proof / Receipts / Reviews
- You / trust / personalization
- Evidence hierarchy
- Recommendation eligibility
- privacy consent model
- accessibility conformance
- release evidence gates
- build/test pipeline

Columns:

```markdown
| Canon claim | Owning doc | Owning code path | Test/preview evidence | Status | Gap / next action |
```

Status values:

- `implemented`
- `partial`
- `planned`
- `blocked`
- `not-started`

## Phase 8 — Build and test

Run what the environment supports.

Preferred commands:

```bash
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 16' build CODE_SIGNING_ALLOWED=NO
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 16' test CODE_SIGNING_ALLOWED=NO
```

If simulator name differs, list devices and choose a deterministic available iPhone simulator.

Also run any repo-supported validation commands found in docs or package files.

If a command cannot run, record:

- command
- failure reason
- whether it is environment/tooling or repo failure
- exact next fix

## Phase 9 — Final report

Create:

```text
docs/audits/faang-handoff-readiness-report.md
```

Must include:

1. Executive readiness verdict: `PASS`, `PARTIAL`, or `FAIL`.
2. Gate-by-gate result for all ten gates in `Ambitions_3_0_FAANG_Handoff_Readiness_Gate.md`.
3. Files deleted.
4. Files moved.
5. Files edited.
6. Files intentionally retained despite legacy/historical status.
7. Remaining internal migration debt.
8. Legacy language scan result.
9. Generated artifact scan result.
10. Active source-of-truth confirmation.
11. Build/test evidence.
12. Remaining risks.
13. Exact next Codex batch to run.

## Phase 10 — Commit

Review diff carefully:

```bash
git status --short
git diff --stat
git diff -- . ':(exclude)docs/audits/faang-handoff-file-inventory.csv'
```

Then commit:

```bash
git add .
git commit -m "Complete FAANG handoff repo cleanup audit"
```

If deletion/migration is too large, use multiple commits:

1. `Purge generated repo artifacts`
2. `Reconcile active Ambitions 3.0 documentation indexes`
3. `Add FAANG handoff file inventory and traceability audit`
4. `Migrate safe legacy user-facing language`
5. `Document remaining handoff readiness gaps`

## Final response format

When done, report:

```markdown
## Result
PASS / PARTIAL / FAIL

## Commits
- <sha> <message>

## Deleted
- ...

## Moved
- ...

## Edited
- ...

## Tests
- ...

## Remaining risks
- ...

## Next exact batch
<copy/paste command or prompt>
```
```
