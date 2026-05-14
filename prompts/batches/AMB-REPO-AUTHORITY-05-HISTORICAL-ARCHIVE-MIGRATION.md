<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

AMB-REPO-AUTHORITY-05-HISTORICAL-ARCHIVE-MIGRATION

# Objective

Move historical, superseded, duplicated, and obsolete Ambitions material out of active view without destroying useful product/design traceability.

This phase must make historical material visibly non-authoritative, update inbound links, preserve rollback, and keep active canon paths clean.

# Runner command

```bash
make batch BATCH=AMB-REPO-AUTHORITY-05-HISTORICAL-ARCHIVE-MIGRATION PROMPT=prompts/batches/AMB-REPO-AUTHORITY-05-HISTORICAL-ARCHIVE-MIGRATION.md
```

# Active source truth to inspect

```text
docs/status/repo-authority-cleanup-baseline.md
docs/status/repo-authority-cleanup-front-door-report.md
docs/status/repo-authority-cleanup-frontend-visual-encyclopedia-report.md
docs/status/repo-authority-cleanup-backend-honesty-report.md
docs/status/repo-authority-cleanup-codex-os-report.md
docs/truth/HISTORICAL_POLICY.md
docs/status/quarantine-archive-folder-plan.md
docs/status/archive-and-stale-material-ledger.md
docs/canon/README.md
docs/canon/
docs/AmbitionsCanon/
docs/codex-os/
docs/codex/
prompts/
build/reports/
history/README.md
```

# Allowed scope

```text
history/**
docs/archive/**
docs/canon/**
docs/AmbitionsCanon/**
docs/codex-os/**
docs/codex/**
prompts/**
build/reports/**
docs/status/archive-and-stale-material-ledger.md
docs/status/repo-authority-cleanup-historical-archive-report.md
README.md
docs/README.md
history/README.md
validation/README.md
```

Only move files that are clearly classified as historical/archive candidates and only after inbound-reference validation.

# Forbidden scope

- Do not delete unique historical material with product/design trace value.
- Do not move active truth files from `docs/truth/*`.
- Do not move live app source.
- Do not move active Visual Encyclopedia files under `frontend/`.
- Do not move active batch prompts needed by current trains.
- Do not leave old Ambitions 2.0/3.0/4.0 material reachable as active guidance.
- Do not claim historical migration is complete unless link validation and archive disclaimers pass.

# Required archive policy

Follow `docs/truth/HISTORICAL_POLICY.md` if it is stricter or more current.

If no stronger policy exists, use:

```text
history/
  README.md
  product-iterations/
  visual-explorations/
  obsolete-batches/
  superseded-canon/
  reports/
  prompts/
```

Moved Markdown files must receive this header unless the repo has a stronger standard:

```markdown
> Historical material. This file is retained for traceability only and is not active Ambitions canon. Active authority starts at `/README.md`, `/docs/truth/README.md`, and the relevant root portal.
```

# Required candidate families to classify

Classify before moving:

- `docs/canon/Ambitions_2_0*`
- `docs/canon/Ambitions_3_0*`
- `docs/canon/Ambitions_4_0*`
- PXOS/future-canon families
- obsolete SI/ACUI design trains
- old visual explorations
- old prompt families
- old dry-run docs
- stale reports
- duplicate generated reports
- any material that conflicts with Today / Goals / Capture / Time / You
- any material that presents Plan as a top-level destination

# Required actions

1. Confirm Phases 0–4 are GREEN or stop RED.
2. Read the historical policy and all archive ledgers.
3. Build a migration table with: current path, observed purpose, authority class, target path, inbound links, risk, and rollback.
4. Move historical families one family at a time using `git mv` where possible.
5. Add historical disclaimer headers to moved Markdown files.
6. Update inbound links from active docs to either active replacements or historical archive paths.
7. Leave redirect stubs only where necessary and only if they clearly state non-authoritative historical status.
8. Update `history/README.md` with archive bucket rules.
9. Update `docs/status/archive-and-stale-material-ledger.md` if present.
10. Write `docs/status/repo-authority-cleanup-historical-archive-report.md` with moved files, deferred files, risks, validations, and rollback.

# Validation expectations

Run and record:

```bash
git status --short
test -f history/README.md
test -f docs/status/repo-authority-cleanup-historical-archive-report.md
grep -R "Historical material" history docs/archive 2>/dev/null || true
```

Run active-path scans proving historical language is not presented as active:

```bash
! grep -R "Ambitions 2.0" README.md frontend backend codex-os product-canon validation 2>/dev/null
! grep -R "Ambitions 3.0" README.md frontend backend codex-os product-canon validation 2>/dev/null
! grep -R "Ambitions 4.0" README.md frontend backend codex-os product-canon validation 2>/dev/null
! grep -R "Plan is a top-level" README.md frontend backend codex-os product-canon validation 2>/dev/null
```

If link-check tooling exists, run it against all touched Markdown. If no tool exists, manually verify every touched link.

# Visual proof expectations

None. This phase must not change UI.

# Hard Red stop conditions

- Any prior phase is not GREEN.
- Active truth files are moved.
- Unique historical material is deleted instead of archived.
- Active front doors still route to superseded material as active guidance.
- Moved Markdown lacks historical disclaimer unless a stronger repo policy applies.
- Link validation fails.
- Migration table or rollback path is missing.

# Rollback expectations

If committed, rollback is:

```bash
git revert <commit>
```

If uncommitted, provide exact `git mv` reversal commands and `git checkout --` restore commands for every touched file.

# GREEN criteria

- Historical material is visibly historical.
- Active front doors route to historical material only through `history/` or approved archive paths.
- Ambitions 2.0/3.0/4.0 and obsolete Plan-top-level material are not active guidance.
- Links and archive disclaimers pass validation.
- Archive ledger/report is updated.
