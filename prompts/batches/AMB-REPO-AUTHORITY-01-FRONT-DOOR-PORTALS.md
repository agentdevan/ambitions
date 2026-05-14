<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

AMB-REPO-AUTHORITY-01-FRONT-DOOR-PORTALS

# Objective

Make the Ambitions repo understandable in under 60 seconds from the root README by installing a simple, authoritative portal structure:

```text
README.md
frontend/README.md
backend/README.md
codex-os/README.md
product-canon/README.md
validation/README.md
history/README.md
```

This phase must remove competing front-door confusion without performing historical migration yet.

# Runner command

```bash
make batch BATCH=AMB-REPO-AUTHORITY-01-FRONT-DOOR-PORTALS PROMPT=prompts/batches/AMB-REPO-AUTHORITY-01-FRONT-DOOR-PORTALS.md
```

# Active source truth to inspect

Inspect Phase 0 baseline first:

```text
docs/status/repo-authority-cleanup-baseline.md
README.md
AGENTS.md
docs/README.md
docs/AGENTS.md
docs/truth/README.md
docs/truth/IMPLEMENTATION_TRUTH.md
docs/truth/RELEASE_TRUTH.md
docs/truth/HISTORICAL_POLICY.md
docs/status/current-implementation-map.md
docs/status/repo-cleanup-index.md
docs/canon/README.md
docs/canon/frontend/README.md
docs/AmbitionsCanon/README.md
.codex/REPO_INVENTORY.md
```

# Allowed scope

```text
README.md
frontend/README.md
backend/README.md
codex-os/README.md
product-canon/README.md
validation/README.md
history/README.md
docs/README.md
docs/AGENTS.md
docs/canon/README.md
docs/status/repo-authority-cleanup-front-door-report.md
```

# Forbidden scope

- Do not move historical files yet.
- Do not move Visual Encyclopedia files yet.
- Do not delete files.
- Do not modify app source.
- Do not rewrite active truth files except to link from portal docs if already intended.
- Do not duplicate the Visual Encyclopedia into multiple active places.

# Required root README behavior

The root README must be concise and route exactly to:

- Frontend → `frontend/README.md`
- Visual canon / Visual Encyclopedia → `frontend/README.md`
- Backend → `backend/README.md`
- Codex OS → `codex-os/README.md`
- Product canon → `product-canon/README.md`
- Validation / proof / release gates → `validation/README.md`
- Historical archive → `history/README.md`

It must state:

- Ambitions is native iPhone-first and local-first.
- Active top-level IA is exactly Today / Goals / Capture / Time / You.
- Plan is not a top-level destination.
- Historical material is non-authoritative unless promoted by `docs/truth/*`.
- Release/TestFlight/App Store/device/accessibility/performance/privacy/legal claims require proof.

# Required portal behavior

- `frontend/README.md` must identify the Visual Encyclopedia as the frontend front door and point to current/next Phase 2 target.
- `backend/README.md` must be honest that no hosted personal-data backend is active unless repo truth proves otherwise.
- `codex-os/README.md` must route to `.codex/OPERATING_SYSTEM.md`, `.codex/REPO_INVENTORY.md`, `docs/codex/`, `prompts/batches/`, `scripts/`, and status/proof reports.
- `product-canon/README.md` must route to active product truth, especially `docs/truth/README.md`, without reactivating superseded docs.
- `validation/README.md` must route to validation/proof/release gates and state proof honesty requirements.
- `history/README.md` must state historical material is non-authoritative and identify the future migration target.

# Required actions

1. Read Phase 0 baseline and active truth.
2. Rewrite root README into a portal table of contents.
3. Create/update the six root portals.
4. Convert `docs/README.md` into a supporting docs map aligned to the root portals.
5. Neutralize `docs/AGENTS.md` if it conflicts with root `AGENTS.md`; preferred treatment is redirect/supporting note.
6. Rewrite `docs/canon/README.md` so it cannot present Ambitions 2.0/3.0/4.0 or Plan-as-top-level as active canon.
7. Write `docs/status/repo-authority-cleanup-front-door-report.md` with files changed, link map, validations, and rollback.

# Validation expectations

Run and record:

```bash
git status --short
test -f README.md
test -f frontend/README.md
test -f backend/README.md
test -f codex-os/README.md
test -f product-canon/README.md
test -f validation/README.md
test -f history/README.md
test -f docs/status/repo-authority-cleanup-front-door-report.md
grep -n "Today / Goals / Capture / Time / You" README.md
grep -n "Plan is not a top-level destination" README.md
grep -n "Visual Encyclopedia" README.md frontend/README.md
```

If link-check tooling exists, run it. If not, manually verify all README links touched in this phase.

# Visual proof expectations

None. This phase must not change UI.

# Hard Red stop conditions

- Phase 0 baseline is absent or RED.
- Root README still has confusing competing product-entry language.
- Any active front-door doc presents Ambitions 2.0/3.0/4.0 as active.
- Any active front-door doc presents Plan as top-level IA.
- Any required portal README is missing.
- Links added in this phase are broken.
- Scope touches files outside allowed scope.

# Rollback expectations

Report all changed files. If committed, rollback is:

```bash
git revert <commit>
```

If uncommitted, rollback is:

```bash
git checkout -- README.md frontend/README.md backend/README.md codex-os/README.md product-canon/README.md validation/README.md history/README.md docs/README.md docs/AGENTS.md docs/canon/README.md docs/status/repo-authority-cleanup-front-door-report.md
```

# GREEN criteria

- Root README is a clear front door.
- Six portal READMEs exist and resolve.
- Competing docs front doors are neutralized or rerouted.
- No active front door exposes obsolete canon as active.
- Validation and rollback are documented.
