# Ambitions Codex Skill Governance

Status: Active skill governance router  
Scope: Skill classification, metadata expectations, allowed loading, review status, deleted provider-skill record, and future skill cleanup plan  
Authority: Subordinate to `docs/truth/*`, `.codex/OPERATING_SYSTEM.md`, and `.codex/DEPARTMENT_REGISTRY.md`  
Updated: 2026-05-14

This file makes skills operable without pretending every skill has been line-reviewed. Skills are support tools, not product truth, implementation proof, validation proof, release proof, or approval to change app behavior.

## 1. Skill Classification Model

| Classification | Meaning | Use rule |
| --- | --- | --- |
| Active operating support | Supports truth routing, evidence, validation, build triage, repo hygiene, repair, or scoped review | May be used when compatible with `docs/truth/*` and task scope |
| Candidate implementation builder | Can help build product/source surfaces | Use only when an active batch explicitly selects it and allowed paths are clear |
| Historical/supporting | Useful context or older skill material | Do not auto-load; mine only after classification |
| Deprecated | Known stale, risky, duplicated, or superseded | Do not use unless a cleanup batch is reviewing it |
| Archived | Retained for traceability only | Do not use as active guidance |
| Removed/deleted provider skill | External provider skill removed from active path | Do not recreate without explicit owner approval and truth-compatible architecture review |

## 2. Skill Metadata Schema

Future skill headers should use this schema:

```yaml
---
status: active | candidate | historical | deprecated | archived
scope: product | design | ios | backend | qa | release | repo-hygiene | visual-qa | build | privacy | accessibility | copy | evidence | codex-process
applies_to: current-truth | AFI | legacy-ACUI | Ambitions-3.0-history | Ambitions-4.0-history | generic
requires:
forbidden_claims:
allowed_paths:
forbidden_paths:
auto_load: yes | no
batch_select_required: yes | no
review_status: unreviewed | skimmed | line-reviewed
last_reviewed:
---
```

No skill may claim broader authority than `docs/truth/*`.

## 3. Current Skill Inventory Summary

Scan snapshot:

- `.codex/skills/` contains hundreds of skill entries: markdown skill files plus directory-based skills with `SKILL.md`.
- `.codex/manifests/skills-routing-map.yml` classifies current route families as active or candidate.
- `docs/status/codex-agents-skill-inventory.md` records provider skill deletion.
- This pass did not line-review every skill.

Current route-family summary from repo evidence:

| Family | Current status | Use rule |
| --- | --- | --- |
| Truth Steward | Active operating support | Truth wiring, stale-doc cleanup, source/canon drift only |
| Build Sheriff | Active operating support | Build/toolchain/XcodeGen triage with raw logs |
| Batch Conductor | Active operating support | Global batch train, resume, repair, closeout |
| Evidence Reviewer | Active operating support | Evidence hierarchy and release-claim firewall |
| Product Implementation Builder | Candidate | Use only when an active batch selects exact owner files |

## 4. Skills Allowed To Auto-Load

Auto-load only when the task clearly matches and paths are safe:

- truth routing and stale-doc skills
- evidence/no-claim skills
- build/test triage skills for local validation
- repo hygiene and file inventory classifiers
- batch closeout/reporting skills
- accessibility/privacy/copy review skills for inspection or explicit QA gates

Auto-load does not authorize source mutation.

## 5. Skills Requiring Explicit Batch Selection

These require an active batch or explicit owner instruction:

- product implementation builders
- SwiftUI surface builders/polishers
- domain model extension builders
- persistence/build target writers
- platform extension builders
- release readiness gate runners
- visual implementation or screenshot proof runs that mutate source
- any skill whose allowed paths include production source

## 6. Skills That Must Not Be Used

Do not use:

- deleted provider skills
- skills that imply Supabase/Postgres/provider/backend activation
- skills that add hosted CI, analytics, telemetry, external LLM, sync/account, or user-data servers without approval
- historical Ambitions 3.0/4.0/PXOS/ACUI/SI skills as active truth
- any skill whose guidance conflicts with `docs/truth/*`

## 7. Deleted Provider Skill Record

Deleted from active skill paths:

- `.agents/skills/supabase/`
- the deleted provider skill path for the legacy database best-practices pack

Current rule:

- Do not recreate them.
- Do not auto-load provider material for Ambitions core work.
- Do not infer backend/Supabase/Postgres architecture from stale docs or memory.
- Reintroduction requires explicit owner approval, architecture review, privacy/security review, and truth-file compatibility.
- `skills-lock.json` is not active architecture. If it contains provider residue, treat that residue as historical cleanup material only.

Resolved provider-inventory item:

- `docs/audits/tracked-files.txt` was regenerated from `git ls-files` on
  2026-05-10 and no longer lists deleted provider paths.
- A full-file automated scan of 345 `.codex/skills` markdown files found zero
  deleted provider root references.

## 8. Line-Review Tracker

Current review truth:

- Every `.codex/skills` markdown file was full-file scanned on 2026-05-10 for
  deleted provider root references.
- This governance pass does not certify skill quality, but the remaining
  metadata/header review is optional improvement work rather than a blocking
  Yellow item.
- Skills without metadata or explicit review status are treated as
  `unreviewed` for auto-load purposes until proven otherwise.
- Candidate implementation skills are not safe for autonomous source mutation without active batch selection.

| Area | Review status |
| --- | --- |
| Provider deletion state | Skimmed from status docs and path checks |
| `skills-routing-map.yml` families | Skimmed |
| Full `.codex/skills/` tree | Full-file automated provider-root scan complete; metadata/content review remains optional future improvement |
| Directory-based repo-local skills used by this run | Skimmed only as needed |

## 9. Future Metadata Header Pass Plan

Run later in small batches:

| Batch | Scope | Goal |
| --- | --- | --- |
| A | Truth, evidence, release-claim skills | Add metadata and line-review high-risk claim skills |
| B | Build, Xcode, test, validation skills | Add validation boundaries and dangerous-command notes |
| C | Design, copy, accessibility, privacy skills | Add product-truth and no-claim guardrails |
| D | Product/source implementation builder skills | Add explicit batch-selection and allowed-path rules |
| E | Remaining skills | Classify historical/deprecated/archive candidates |

## 10. Future Folder Split Plan

Do not move skills until metadata and inbound references are complete.

Future target folders:

```text
.codex/skills/active/
.codex/skills/candidate/
.codex/skills/historical/
.codex/skills/archived/
```

Move preconditions:

1. inbound reference search
2. metadata header present
3. replacement import/load path documented
4. rollback plan
5. owner approval for high-risk or broad moves

## 11. Current Skill Governance Handoff

Next target artifact after skill governance:

```text
.codex/BATCH_TRAIN_REGISTRY.md
```

Resolved status: no provider-root skill references remain in `.codex/skills`,
the active next-action lanes are reconciled in `.codex/GLOBAL_BATCH_TRAIN.md`,
large-file authority is governed by overrides and registries, and the Repo MCP
source-truth stack has been updated to include `docs/truth/*`.
