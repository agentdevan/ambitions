<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

AMB-REPO-AUTHORITY-CLEANUP-RUN-ALL

# Objective

Execute the Ambitions repo-authority cleanup train sequentially until the repository front door, frontend Visual Encyclopedia, backend posture, Codex OS portal, historical archive boundary, active vocabulary, and final validation gates are ruthlessly GREEN.

This is the preferred execution prompt. It must run all phases in one controlled Codex runner session. Individual phase prompts are installed for replay/repair only.

# Runner command

```bash
make batch BATCH=AMB-REPO-AUTHORITY-CLEANUP-RUN-ALL PROMPT=prompts/batches/AMB-REPO-AUTHORITY-CLEANUP-RUN-ALL.md
```

# Non-negotiable operating rule

No phase may proceed unless the current phase is GREEN.

- GREEN: all required validations pass; no unresolved active contradiction; no unproofed claim; no broken active link; no unclassified dirty generated artifact; rollback path documented.
- YELLOW: may only describe optional non-executed improvements. YELLOW may not permit phase continuation.
- RED: stop immediately, preserve work, document blocker, rollback path, and exact repair command.

# Active source truth to inspect before Phase 0

Inspect the current repo state and these authority anchors before making changes:

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
docs/AmbitionsCanon/README.md
docs/AmbitionsCanon/20_Visual_Canon_Moat_Implementation_Spec.md
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

Missing optional files must be recorded. Missing active truth spine files are RED unless an equivalent current authority is proven.

# Current Ambitions canon to enforce

- Ambitions is a premium native iPhone-first, local-first life operating system.
- Active top-level IA is exactly: Today / Goals / Capture / Time / You.
- Plan is superseded as a top-level destination.
- Primary objects: Today → Reality Meridian; Goals → Constellation Atlas; Capture → Atmosphere Composer; Time → LifeShape Field; You → User System Profile.
- The Visual Encyclopedia is the frontend front door.
- The Visual Encyclopedia may contain active intended canon and actively installed canon only.
- Historical material is non-authoritative unless explicitly promoted by `docs/truth/*`.
- Core intelligence is local-first and deterministic through the Private Life Runtime / Intelligence Kernel.
- External/cloud LLMs are not core architecture.
- Release/TestFlight/App Store/device/accessibility/performance/privacy/legal claims require proof.

# Required phase sequence

Run these phases in order. Do not skip. Do not continue after a non-GREEN phase.

```text
Phase 0 — Safety snapshot
Phase 1 — README/front-door portals
Phase 2 — Frontend / Visual Encyclopedia authority consolidation
Phase 3 — Backend honesty cleanup
Phase 4 — Codex OS consolidation
Phase 5 — Historical/archive migration
Phase 6 — Active drift repair
Phase 7 — Gates and final proof
```

# Phase 0 — Safety snapshot

Objective: establish a safe baseline.

Allowed:
- Inspect branch, worktree, root tree, docs/front doors, prompts, scripts, reports, and active truth anchors.
- Generate `docs/status/repo-authority-cleanup-baseline.md`.

Required actions:
- Confirm current branch is `main`.
- Fail RED if unable to operate on `main`.
- Confirm worktree is clean except expected runner artifacts.
- Capture baseline stale phrase scan for: `Ambitions 2.0`, `Ambitions_2_0`, `Ambitions 3.0`, `Ambitions_3_0`, `Ambitions 4.0`, `Ambitions_4_0`, `Plan` as top-level IA, `Begin Focus`, `Start Focus`, `Open Focus`, `next best move`, `Your best next move`, `best next move`, active external/cloud LLM core claims, active Supabase/Expo provider claims, unproofed release claims.
- Capture baseline active front-door map.
- Capture candidate move/delete set without moving/deleting.

GREEN requires:
- Baseline report exists.
- Worktree safety is proven.
- Cleanup targets are classified.

# Phase 1 — README/front-door portals

Objective: make the repo understandable in under 60 seconds from root.

Required target portals:

```text
README.md
frontend/README.md
backend/README.md
codex-os/README.md
product-canon/README.md
validation/README.md
history/README.md
```

Root README must route exactly to:
- Frontend → `frontend/README.md`
- Visual canon / Visual Encyclopedia → `frontend/README.md`
- Backend → `backend/README.md`
- Codex OS → `codex-os/README.md`
- Product canon → `product-canon/README.md`
- Validation / proof / release gates → `validation/README.md`
- Historical archive → `history/README.md`

Required actions:
- Rewrite root README as a concise front door.
- Create/update portal READMEs.
- Neutralize competing docs front doors by converting them into redirects/supporting context, not active authority.
- Rewrite `docs/canon/README.md` so it cannot present Ambitions 2.0/3.0/4.0 or Plan-as-top-level as active canon.

GREEN requires:
- All portal links resolve.
- No active front-door doc presents Ambitions 2.0/3.0/4.0 as active.
- No active front-door doc presents Plan as a top-level destination.

# Phase 2 — Frontend / Visual Encyclopedia authority consolidation

Objective: make the Visual Encyclopedia the frontend front door and distinguish installed from intended canon.

Target:

```text
frontend/
  README.md
  installed-canon.md
  intended-canon.md
  visual-encyclopedia/
    README.md
    AMBITIONS_FRONT_END_ARCHITECTURE_ATLAS_AND_VISUAL_ENCYCLOPEDIA.md
```

Required actions:
- Rehome active `docs/canon/frontend/*` into `frontend/visual-encyclopedia/` using `git mv` where possible.
- Update inbound links.
- Leave minimal redirect stubs only where needed.
- Create `frontend/installed-canon.md` citing live source/test anchors.
- Create `frontend/intended-canon.md` citing Visual Encyclopedia, active visual moat spec, and truth files.
- Classify `docs/status/visual-canon-moat-installation-report.md` as proof/control-plane context only unless app proof exists.

GREEN requires:
- `frontend/README.md` is the active frontend front door.
- Active Visual Encyclopedia content lives under `frontend/`.
- Active Visual Encyclopedia distinguishes intended from installed.
- No active Visual Encyclopedia file presents Plan as top-level IA.

# Phase 3 — Backend honesty cleanup

Objective: remove false hosted-backend signals.

Required actions:
- Make `backend/README.md` the backend portal.
- State no active hosted personal-data backend exists unless current truth proves otherwise.
- State local runtime/domain/persistence is the active backend-equivalent.
- Inspect `.env.example`, `skills-lock.json`, and `.codex/SKILL_GOVERNANCE.md`.
- Delete/archive stale provider residue only after inbound-reference validation and rollback documentation.

GREEN requires:
- No root-visible stale Supabase/Expo provider setup remains as active architecture.
- Local-first posture is explicit.
- Any deletion/archive has rollback notes.

# Phase 4 — Codex OS consolidation

Objective: make Codex OS understandable without multiple competing front doors.

Required actions:
- Make `codex-os/README.md` the human Codex OS portal.
- Preserve `.codex/OPERATING_SYSTEM.md` as machine authority.
- Update `.codex/REPO_INVENTORY.md` to reflect root portals.
- Classify `docs/codex-os/*` as active/supporting/historical.
- Keep `docs/codex/CODEX_OS_INDEX.md` supporting, not competing.
- Ensure `.codex/runs/` is not active repo content.

GREEN requires:
- One visible Codex OS portal.
- Machine authority remains intact.
- Historical Codex material is not active.

# Phase 5 — Historical/archive migration

Objective: move historical/superseded material out of active view.

Required actions:
- Follow `docs/truth/HISTORICAL_POLICY.md` if stronger.
- Otherwise use `history/` buckets:
  - `history/product-iterations/`
  - `history/visual-explorations/`
  - `history/obsolete-batches/`
  - `history/superseded-canon/`
  - `history/reports/`
  - `history/prompts/`
- Move families one at a time.
- Candidate families include Ambitions 2.0/3.0/4.0, PXOS/future-canon families, old SI/ACUI trains, old prompt copies, old dry-run docs, stale reports.
- Add the historical disclaimer header to moved Markdown.
- Update inbound links.

Historical disclaimer:

```markdown
> Historical material. This file is retained for traceability only and is not active Ambitions canon. Active authority starts at `/README.md`, `/docs/truth/README.md`, and the relevant root portal.
```

GREEN requires:
- Historical material is visibly historical.
- Active front doors do not route to historical material except through `history/`.
- Link validation passes.

# Phase 6 — Active drift repair

Objective: fix active-path vocabulary drift and misleading user-facing copy.

Required actions:
- Search active paths for stale phrases listed in Phase 0.
- Classify every hit as active blocker, compatibility-only, historical-only, supporting reference, or false-claim risk.
- Repair active blockers.
- Swift source changes require build/test proof.
- Internal compatibility names may remain only if documented and non-user-facing.

Known likely targets:

```text
Native/AmbitionsWidgetExtension/NextStepWidget.swift
Native/Ambitions/Features/Plan/PlanScreen.swift
Native/Ambitions/App/AppTab.swift
Native/Ambitions/App/AmbitionsRootView.swift
docs/AGENTS.md
docs/canon/README.md
.env.example
skills-lock.json
```

GREEN requires:
- No banned active-path language remains except documented compatibility/historical allowlist.
- No user-facing banned CTA remains.
- No root-visible false backend/provider signal remains.
- Build/test proof exists for source changes.

# Phase 7 — Gates and final proof

Objective: prevent repo sprawl from returning.

Required actions:
- Create/update `docs/status/repo-authority-cleanup-final-report.md`.
- Create/update `docs/status/repo-authority-cleanup-active-path-allowlist.md`.
- Create or update deterministic repo-authority validation if needed at `scripts/ambitions-repo-authority-validate.py`.
- Run available validators:

```bash
python scripts/ambitions-vocabulary-drift-scan.py
python scripts/ambitions-moat-drift-scan.py
python scripts/ambitions-authority-supersession-check.py
python scripts/ambitions-codex-os-validate.py
python scripts/ambitions-repo-authority-validate.py
```

Missing optional scripts are recorded, not automatically fatal, unless the missing script is the only available proof for a changed scope.

GREEN requires:
- All applicable gates pass.
- Final report exists.
- Root README is clear.
- Frontend routes to Visual Encyclopedia.
- Backend is honest.
- Codex OS has one visible portal.
- Historical material is contained.
- No visible active-path sprawl remains.
- `git status --short` is clean after final commit, except ignored runner artifacts.

# Global forbidden scope

- Do not add a hosted backend.
- Do not add Supabase/Firebase/Expo/provider setup.
- Do not claim sync, release, TestFlight, App Store, device proof, accessibility proof, performance proof, privacy/legal proof, or production status without repo proof.
- Do not delete unique historical material with product/design trace value.
- Do not move active truth files.
- Do not remove active governance.
- Do not rewrite the runner unless a validator proves it is required and scope is explicitly expanded by a later prompt.

# Final output required

Return:

```text
Status: GREEN or RED
Batch: AMB-REPO-AUTHORITY-CLEANUP-RUN-ALL
Phase statuses:
0 Safety snapshot: GREEN/RED
1 Front-door portals: GREEN/RED
2 Frontend Visual Encyclopedia: GREEN/RED
3 Backend honesty: GREEN/RED
4 Codex OS consolidation: GREEN/RED
5 Historical/archive migration: GREEN/RED
6 Active drift repair: GREEN/RED
7 Gates/final proof: GREEN/RED
Files changed:
Validation:
Commit:
Rollback:
Final proof report:
```
