<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-19279448, AMB28-same_source_file_targeted_by_multiple_active_batches-3188896, AMB28-same_source_file_targeted_by_multiple_active_batches-50973887, AMB28-same_source_file_targeted_by_multiple_active_batches-8527029, AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->
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
