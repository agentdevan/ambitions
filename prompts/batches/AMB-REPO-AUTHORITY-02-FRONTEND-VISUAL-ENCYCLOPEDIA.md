<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

AMB-REPO-AUTHORITY-02-FRONTEND-VISUAL-ENCYCLOPEDIA

# Objective

Make the Visual Encyclopedia the active frontend front door and ensure active frontend documentation contains only active intended canon or actively installed canon.

This phase must remove ambiguity between installed app truth, intended visual canon, historical explorations, proof/control-plane reports, and obsolete visual variants.

# Runner command

```bash
make batch BATCH=AMB-REPO-AUTHORITY-02-FRONTEND-VISUAL-ENCYCLOPEDIA PROMPT=prompts/batches/AMB-REPO-AUTHORITY-02-FRONTEND-VISUAL-ENCYCLOPEDIA.md
```

# Active source truth to inspect

```text
docs/status/repo-authority-cleanup-baseline.md
docs/status/repo-authority-cleanup-front-door-report.md
README.md
frontend/README.md
docs/canon/frontend/README.md
docs/canon/frontend/AMBITIONS_FRONT_END_ARCHITECTURE_ATLAS_AND_VISUAL_ENCYCLOPEDIA.md
docs/AmbitionsCanon/20_Visual_Canon_Moat_Implementation_Spec.md
docs/status/current-implementation-map.md
docs/status/visual-canon-moat-installation-report.md
docs/truth/README.md
docs/truth/IMPLEMENTATION_TRUTH.md
docs/truth/PRODUCT_MOAT_TRUTH.md
Native/Ambitions/App/AppTab.swift
Native/Ambitions/App/AmbitionsRootView.swift
Native/AmbitionsUITests/AmbitionsUITests.swift
```

# Allowed scope

```text
frontend/**
docs/canon/frontend/README.md
docs/status/repo-authority-cleanup-frontend-visual-encyclopedia-report.md
README.md
docs/README.md
product-canon/README.md
validation/README.md
history/README.md
```

Only update other Markdown files if required to repair links to moved Visual Encyclopedia files.

# Forbidden scope

- Do not modify app source in this phase.
- Do not redesign UI.
- Do not preserve obsolete visual explorations as active guidance.
- Do not expose Ambitions 2.0/3.0/4.0 as active frontend truth.
- Do not duplicate the same canon into multiple active paths.
- Do not claim app implementation proof unless the repo contains source/test evidence.

# Required target shape

```text
frontend/
  README.md
  installed-canon.md
  intended-canon.md
  visual-encyclopedia/
    README.md
    AMBITIONS_FRONT_END_ARCHITECTURE_ATLAS_AND_VISUAL_ENCYCLOPEDIA.md
```

Additional active Visual Encyclopedia files may live under `frontend/visual-encyclopedia/` only if they are active intended canon or active installed canon.

# Required actions

1. Confirm Phases 0 and 1 are GREEN.
2. Inspect all current `docs/canon/frontend/*` files.
3. Classify each frontend file as:
   - active intended visual canon
   - active installed visual canon
   - supporting reference
   - historical visual exploration
   - obsolete/archive candidate
   - unknown / needs human decision
4. Rehome active `docs/canon/frontend/*` into `frontend/visual-encyclopedia/` using `git mv` where possible.
5. Leave a minimal redirect stub at `docs/canon/frontend/README.md` only if inbound links require it. The stub must point to `frontend/README.md` and must not duplicate active canon.
6. Create/update `frontend/installed-canon.md` with only currently installed app truth, citing live source/test anchors:
   - `Native/Ambitions/App/AppTab.swift`
   - `Native/Ambitions/App/AmbitionsRootView.swift`
   - `Native/AmbitionsUITests/AmbitionsUITests.swift`
   - `docs/status/current-implementation-map.md`
7. Create/update `frontend/intended-canon.md` with intended visual canon, citing:
   - `frontend/visual-encyclopedia/`
   - `docs/AmbitionsCanon/20_Visual_Canon_Moat_Implementation_Spec.md`
   - `docs/truth/*`
8. Ensure the Visual Encyclopedia states:
   - active IA is Today / Goals / Capture / Time / You
   - Plan is not a top-level destination
   - screenshots/mockups are not implementation proof unless tied to source/test evidence
   - historical visual explorations are non-authoritative
9. Update links from old `docs/canon/frontend` paths to new `frontend/visual-encyclopedia` paths.
10. Write `docs/status/repo-authority-cleanup-frontend-visual-encyclopedia-report.md` with classifications, moved files, link updates, validation, rollback, and unresolved decisions.

# Validation expectations

Run and record:

```bash
git status --short
test -f frontend/README.md
test -f frontend/installed-canon.md
test -f frontend/intended-canon.md
test -d frontend/visual-encyclopedia
test -f frontend/visual-encyclopedia/README.md
test -f docs/status/repo-authority-cleanup-frontend-visual-encyclopedia-report.md
grep -R "Today / Goals / Capture / Time / You" frontend
! grep -R "Plan is a top-level" frontend
! grep -R "Ambitions 2.0" frontend/visual-encyclopedia || true
```

If a link-check tool exists, run it against all touched Markdown. If no tool exists, manually verify every touched link.

# Visual proof expectations

None, unless this phase unexpectedly changes UI source. UI source changes are forbidden here.

# Hard Red stop conditions

- Phase 0 or Phase 1 is not GREEN.
- Active Visual Encyclopedia still lives primarily under `docs/canon/frontend` after this phase.
- Active frontend content presents Plan as top-level IA.
- Active frontend content presents Ambitions 2.0/3.0/4.0 as current truth.
- Installed and intended canon are not separated.
- Link updates fail.
- Scope touches app source.

# Rollback expectations

Record every moved/created file. If committed, rollback is:

```bash
git revert <commit>
```

If uncommitted, use `git status --short` plus `git mv` reversal commands for moved files and `git checkout --` for modified docs.

# GREEN criteria

- `frontend/README.md` is the active frontend/visual front door.
- Active Visual Encyclopedia content lives under `frontend/visual-encyclopedia/`.
- Installed versus intended frontend canon is explicit.
- Historical/obsolete visual material is not active.
- Links and validation pass.
