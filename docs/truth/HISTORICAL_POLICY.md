# HISTORICAL_POLICY.md

Status: Active historical cleanup and archive/delete/extract policy  
Scope: Historical docs, old canon, audits, handoffs, prompts, batch docs, skills, stale reports, cleanup, archive, deletion, quarantine, and traceability  
Applies to: Ambitions repo documentation, Codex material, historical implementation plans, old source-truth docs, provider skills, and cleanup PRs  
Owner posture: Cleanup authority, not product design, not implementation proof, not release proof  
Effective rule: Preserve useful active truth, preserve useful history as subordinate context, quarantine stale canon, and remove confusing material only through an explicitly scoped cleanup pass.

---

## 1. Purpose and Authority

This file defines how Ambitions handles historical material.

It exists to prevent:

- obsolete canon from controlling implementation
- old prompts from reviving abandoned direction
- batch docs from becoming release proof
- stale audits from becoming current evidence
- provider/backend skills from implying active architecture
- archive folders from becoming a second junk drawer
- Codex from reading too much stale context and drifting
- useful decisions from being lost during cleanup

This policy applies to:

- old canon
- docs
- audits
- reports
- handoff docs
- prompts
- batch-train docs
- `.codex` material
- `.agents` material
- skills
- provider/backend docs
- historical release claims
- old architecture plans
- old IA/visual language
- stale inventories
- generated reports

No file may claim historical authority over `docs/truth/*`.

---

## 2. Historical Material Definition

Historical material is any repo material that:

- predates the current truth hierarchy
- conflicts with `docs/truth/*`
- contains superseded product direction
- contains superseded IA/tab names
- contains superseded visual language
- contains old backend/provider assumptions
- contains old AI/cloud assumptions
- contains release claims without current proof
- describes planned work as if complete
- documents a completed past batch but not current source truth
- is a prompt rather than a maintained spec
- is an audit/report not tied to current commit/logs
- is duplicated elsewhere in active truth
- exists mainly for traceability

Examples:

```text
docs/canon/Ambitions_2_0*
docs/canon/Ambitions_3_0*
docs/canon/Ambitions_4_0*
PXOS docs
ACUI docs
SI docs
batch-train docs
old implementation plans
old handoffs
old audits
old prompts
stale file inventories
provider-specific skill packs
```

Historical material may be useful. It is not active authority.

Historical does not mean useless. Historical means subordinate.

## 2A. Historical Classification Vocabulary

Classify old or conflicting material before using it.

Allowed classifications:

| Classification | Meaning |
|---|---|
| Active authority | Current truth file, live source evidence, current project/test/script evidence, or current proof/log evidence that wins within its authority lane. |
| Supporting compatible material | Non-authority material that is compatible with `docs/truth/*` and still useful for routing, context, procedures, or traceability. |
| Historical reference | Old material retained to explain prior direction, decision history, batch history, research history, or cleanup context. |
| Stale current-source evidence | Live source, tests, routes, or names that describe current repo state but conflict with active product truth and therefore identify a migration gap, not active canon. |
| Migration target | Old source/doc terminology or structure that a separately scoped migration may update after impact review and validation planning. |
| Superseded prior canon | Former product, IA, architecture, visual, or process direction replaced by `docs/truth/*`. |
| Archive candidate | Historical material that may be moved only after useful concepts are extracted or intentionally rejected and the archive scope is approved. |
| Delete candidate | Material safe to delete only when a dedicated cleanup issue scopes the deletion, reusable value has been handled, no dependency remains, and rollback is clear. |

Old names may appear in migration notes, cleanup reports, or stale-source classification only.

---

## 3. Active Material Definition

Active material is material that currently defines or proves repo truth.

Active material includes:

```text
docs/truth/PRODUCT_DESIGN_TRUTH.md
docs/truth/IMPLEMENTATION_TRUTH.md
docs/truth/RELEASE_TRUTH.md
docs/truth/CODEX_PROCESS_TRUTH.md
docs/truth/HISTORICAL_POLICY.md
live Swift source
project.yml
Package.swift
current scripts
current tests
current resources
current entitlements
current privacy manifest
current validation logs/proof packets
```

Active material must be:

- current
- evidence-grounded
- maintained
- non-duplicative where practical
- linked from a clean docs front door
- consistent with truth hierarchy

Active material must not be buried under old docs.

---

## 4. Supporting Material Definition

Supporting material is non-authority material that remains useful because it:

- explains active source
- provides implementation context
- contains reusable detail not yet migrated
- documents a still-relevant decision
- helps route Codex to correct files
- supports traceability
- provides validation procedures
- contains historical proof that is clearly labeled as historical
- contains a checklist still aligned with truth files

Supporting material must:

- link to the relevant truth file
- state that it is supporting, not authority
- avoid conflicting claims
- avoid release overclaims
- be kept out of root/front-door noise unless needed

Examples:

```text
docs/native-build-and-release.md
AGENTS.md
docs/README.md
.codex/README.md
docs/codex/CODEX_OS_INDEX.md
selected route docs
selected validation protocols
selected architecture notes
```

Supporting material becomes historical or delete candidate when superseded.

---

## 5. Non-Authority Rule

Historical and supporting material cannot override:

```text
docs/truth/PRODUCT_DESIGN_TRUTH.md
docs/truth/IMPLEMENTATION_TRUTH.md
docs/truth/RELEASE_TRUTH.md
docs/truth/CODEX_PROCESS_TRUTH.md
docs/truth/HISTORICAL_POLICY.md
live source/project/test/script evidence
current validation logs
```

Required header for retained historical docs:

```markdown
> Historical note: This file is retained for traceability only.
> It is not active product, implementation, release, or Codex process authority.
> Current authority begins in `docs/truth/`.
```

Required header for retained supporting docs:

```markdown
> Supporting note: This file supports current Ambitions work but does not override `docs/truth/`.
```

---

## 6. Conflict Rule

When old material conflicts with active truth:

| Conflict | Winner |
|---|---|
| Old product direction vs Product Design Truth | Product Design Truth |
| Old implementation claim vs source | Live source |
| Old release claim vs proof | Current proof / Release Truth |
| Old process prompt vs Codex Process Truth | Codex Process Truth |
| Old cleanup advice vs Historical Policy | Historical Policy |
| Old README/status wording vs truth file | Truth file |
| Old audit vs current source/log | Current source/log |
| Old batch Green vs missing release proof | Missing proof wins |

Conflict must be resolved by:

1. demoting old file
2. extracting useful current value
3. rewriting or deleting conflicting claim
4. updating links
5. recording cleanup reason

---

## 6A. Prior IA, Capture, Pulse, Motion, and Time Quarantine

Active product/design truth wins over old canon docs, old research docs, old batch prompts, old audit docs, handoff docs, Linear-derived planning text, prior ChatGPT outputs, stale `AGENTS.md` copies, and stale source names when discussing product truth.

Current active top-level IA is:

```text
Today / Goals / Time / Motion / You
```

Global action:

```text
Capture
```

The old IA:

```text
Today / Goals / Capture / Time / You
```

is not active product truth. It may appear only as:

- historical context
- stale source-state evidence
- migration target
- superseded prior canon

Extract concepts; do not revive obsolete IA.

### Capture Quarantine

Old Capture-as-tab material may be reused only for:

- Atmosphere Composer substance
- capture-routing ideas
- composer-state modeling
- accessibility patterns
- proof/context attachment behavior
- non-inbox constraints

Old Capture-as-tab material must not be reused to justify:

- Capture tab
- Capture inbox as primary identity
- Capture feed
- persistent floating button as canonical
- plus-tab behavior
- chatbot-style Capture
- top-level Capture destination

Current Capture language should translate old useful material into global Capture, Atmosphere Composer, contextual surface-native entry points, quiet toolbar Capture fallback, and bottom composer seam only after activation.

### Pulse Quarantine

`Pulse` is prior working-name / historical context only.

Old Pulse material may be reused only for:

- proof/progress/inspection concepts
- proof/receipt primitives
- Motion Current inputs
- anti-dashboard/feed/XP lessons
- historical migration notes

Old Pulse material must not be reused to justify:

- Pulse tab
- active Pulse surface name
- analytics dashboard
- activity feed
- XP
- score
- streak
- productivity report
- social timeline
- generic progress chart

ProofPulse or proof/receipt primitives may be reusable only when they are not treated as evidence for a current Pulse tab or current Pulse surface. Reuse must translate the concept into Motion, Motion Current, proof/progress/inspection, what moved, proof, recovery, re-entry, or life-area development.

### Motion Preservation

Historical proof, progress, closure, receipt, review, and inspection material should be translated into:

- Motion
- Motion Current
- proof/progress/inspection
- what moved
- proof
- recovery
- re-entry
- life-area development

Motion must not be collapsed into dashboard, activity feed, XP, score, streak, productivity report, social timeline, generic progress chart, or shame/guilt framing.

### Time Preservation

Historical calendar, plan, scheduling, availability, and horizon material should be translated into:

- Time
- LifeShape Field
- Time Texture
- availability vs capacity
- pressure
- cognitive load
- physical energy
- transition friction
- protected time
- recovery need
- free-time quality
- execution lanes
- goal load

Historical Time/Plan/calendar material must not revive:

- calendar clone
- free/busy-only model
- productivity scoring
- schedule optimization dashboard
- calendar-density score
- AI scheduling score
- resource-allocation jargon

---

## 7. Extract-Then-Delete Policy

When old docs are useful, agents should extract reusable concepts, translate terminology to current canon, cite the old source as historical/supporting, avoid copying stale tab or IA names into active docs, avoid deleting historical docs unless explicitly scoped, and create migration notes when needed.

Use extract-then-delete when a file contains:

- one or two useful durable decisions
- large obsolete body
- old prompts or instructions
- old product direction now superseded
- release overclaims
- duplicated implementation plans
- provider/backend assumptions no longer active
- generated junk with small useful trace
- stale Codex context that confuses current runs

Process:

```text
[ ] Identify useful content.
[ ] Move useful content into active truth/supporting owner doc.
[ ] Record original path.
[ ] Confirm no current source/test/script dependency.
[ ] Confirm links updated or removed.
[ ] Delete file in dedicated cleanup pass.
[ ] Record deletion reason in cleanup report.
```

Do not extract-delete:

- source code
- tests
- project config
- resources
- entitlements
- privacy manifest
- current proof logs
- active truth files
- legally relevant release evidence

without explicit owner approval and replacement.

---

## 8. Extract-Then-Archive Policy

Use extract-then-archive when a file contains:

- substantial historical context
- major decision trail
- useful evidence of why a direction changed
- prior implementation analysis
- old product experiments worth preserving briefly
- batch history needed for traceability
- cleanup-sensitive material where deletion may be premature

Process:

```text
[ ] Extract active durable decisions.
[ ] Add historical header.
[ ] Move to archive location if approved.
[ ] Update links.
[ ] Add archive index entry.
[ ] Set review/expiration note.
[ ] Record replacement authority.
```

Archive should be a holding area, not permanent hoarding.

---

## 9. Direct Delete Policy

Old docs should not be deleted just because they are stale. Staleness is a classification signal, not a deletion approval.

Direct delete is allowed only when the file is:

- generated junk
- duplicate with no unique value
- broken stale artifact
- empty/near-empty placeholder
- obsolete prompt with no durable content
- stale inventory superseded by current inventory
- misleading release claim with no useful trace
- provider-specific material explicitly rejected and fully extracted
- archive material whose expiration review is complete

Direct delete requires:

```text
[ ] Dedicated cleanup scope.
[ ] Explicit user approval.
[ ] Search/link check.
[ ] Active truth already supersedes it.
[ ] Useful reusable concepts have been extracted or intentionally rejected.
[ ] Confirmation file is not active source/test/config/proof.
[ ] No source/proof/run artifact depends on it.
[ ] Deletion reason.
[ ] Rollback path.
```

Never directly delete:

- Swift source
- tests
- project config
- package manifest
- scripts
- resources
- entitlements
- privacy manifest
- current proof logs
- active truth files

as part of docs cleanup.

---

## 10. Quarantine Policy

Quarantine material when:

- it may contain useful history
- it conflicts with active truth
- owner is unclear
- deletion risk is non-trivial
- it may still be referenced by Codex
- it contains provider/backend/cloud assumptions
- it contains old release claims
- it contains stale workflow evidence
- it contains broad batch-train state

Quarantine behavior:

- keep out of root/front-door docs
- label as non-authority
- add conflict reason
- add review owner/date if possible
- prohibit use as active truth
- schedule extract/archive/delete decision

Known quarantine candidates:

```text
.agents/skills/supabase*
.agents/skills/supabase-postgres-best-practices/*
old Ambitions 3.0 / 4.0 canon
old PXOS / ACUI / SI docs
old batch train docs
old release candidate reports without current proof
stale tracked-file inventories
```

---

## 11. Archive Policy

Archive location should be explicit and structured.

Recommended archive structure:

```text
docs/archive/
  legacy-canon/
  old-batches/
  handoffs/
  audits/
  prompts/
  provider-experiments/
  release-history/
  stale-inventories/
```

Each archived file or folder must include:

```text
Original path:
Archived date:
Reason:
Replacement authority:
Useful content extracted to:
Active authority:
Expiration/review policy:
```

Archive files must not be linked as active source truth.

Docs front door should not route normal readers into archive unless explicitly seeking history.

---

## 12. Archive Expiration Policy

Archive is not permanent by default.

Default review windows:

| Archive Type | Default Review Window |
|---|---|
| old prompts | 30-60 days |
| stale inventories | 30-60 days |
| old batch docs | 60-120 days |
| handoffs | 90-180 days |
| audits/reports | 90-180 days |
| legacy canon | 120-180 days |
| provider experiments | 60-120 days |
| release history | retain as long as legally/productively useful |

At review, decide:

- keep as archive
- extract more and delete
- delete
- promote small section to supporting doc
- move to deeper cold archive

Archive should be deleted when:

- a cleanup issue explicitly scopes the deletion/archive
- useful content has been extracted
- no active links depend on it
- no source/proof/run artifact depends on it
- no current owner needs it
- it confuses Codex more than it helps
- it duplicates active truth
- it contains misleading claims
- rollback/traceability need has passed

---

## 13. Old Canon Policy

Old canon includes:

```text
docs/canon/Ambitions_2_0*
docs/canon/Ambitions_3_0*
docs/canon/Ambitions_4_0*
PXOS docs
ACUI docs
SI docs
legacy visual/IA docs
legacy product strategy docs
```

Policy:

- Old canon is historical unless explicitly promoted.
- Product Design Truth wins all product/design conflicts.
- Old canon may be mined for useful details only when compatible.
- Old canon must not revive old tab names, old visual systems, old AI/cloud architecture, old backend assumptions, or generic UI patterns.
- Old canon should be extracted into active truth/supporting docs, then archived or deleted.

Hard conflicts include:

```text
Plan as active top-level tab
Profile as active top-level tab
Captures as active top-level tab
Capture as active top-level tab
Pulse as active top-level tab or current surface name
DayTimelineRail as active product term
Hero Step Panel as active product term
generic dashboard/card-stack surfaces
external LLM as core architecture
custom hosted backend as core architecture
release-ready claims without proof
```

---

## 14. Old Batch Train Policy

Batch train docs are historical/process artifacts unless the current active batch truth explicitly promotes them.

Old deep-research, AESP, AFRI, and batch train material may still be valuable for traceability, planning history, issue context, or extraction of compatible concepts. It remains subordinate and may be used only where it does not conflict with active truth.

Rules:

- Batch docs do not prove implementation.
- Batch docs do not prove release readiness.
- Batch Green does not mean current source passes.
- Batch docs may inform traceability and planned work.
- Current source and current proof win.
- Active queue state may be supporting process evidence only.
- Old batch docs should be archived by train/family after extracting durable process rules.

Batch docs should not appear in the root README or active product front door.

---

## 15. Old Audit / Report Policy

Audits/reports are evidence of a past review, not current proof.

Use them for:

- traceability
- historical reasoning
- identifying gaps
- finding relevant source paths
- understanding why decisions were made

Do not use them as:

- current implementation proof
- current release proof
- current test pass proof
- current accessibility proof
- current performance proof
- current product authority

If an audit contains a useful current decision, extract it into:

```text
docs/truth/*
```

or a clearly supporting owner doc.

Then archive or delete the old audit according to value.

---

## 16. Old Handoff Policy

Handoff docs are historical/supporting by default.

Use them for:

- file-boundary history
- implementation planning trail
- decisions not yet extracted
- old context recovery

Do not use them to override:

- Product Design Truth
- Implementation Truth
- Release Truth
- Codex Process Truth
- Historical Policy
- live source

Handoff cleanup process:

```text
[ ] Identify live decisions.
[ ] Extract live decisions.
[ ] Mark as historical.
[ ] Archive/delete if approved.
[ ] Update docs links.
```

---

## 17. Old Prompt Policy

Prompts are not source truth.

Old prompts should usually be:

- extracted
- deleted
- or archived briefly

Delete prompts when:

- they are one-off execution instructions
- they contain stale context
- they say “implement everything” broadly
- they revive old product language
- they duplicate active process rules
- they contain no unique durable decision

Keep/archive prompts only when:

- they explain a still-useful operating pattern
- they capture a major historical decision
- they are needed for replaying a batch train
- they are explicitly referenced by active Codex process

Prompts must not be linked from the root README as current guidance.

---

## 18. Old Skill Policy

Skill docs in `.codex/skills` or `.agents/skills` are execution aids only.

Policy:

- Keep skills that align with current truth and are actively useful.
- Consolidate duplicate skills.
- Quarantine skills that imply obsolete architecture.
- Delete skills that duplicate active truth and add confusion.
- Provider-specific skills require explicit non-core labeling if kept.
- Skills cannot override truth files.

Known risk:

```text
.agents/skills/supabase*
.agents/skills/supabase-postgres-best-practices/*
```

These conflict with the local-only/no-custom-hosted-personal-backend core product direction if treated as active architecture. They should be quarantined, extracted if any generic database safety lesson is useful, then deleted or archived through a cleanup pass.

---

## 19. Old Backend / Provider Policy

Historical material that assumes or promotes:

- Supabase
- Firebase
- custom hosted accounts
- Postgres personal backend
- external SaaS backend
- server-side user profiling
- hosted personal data
- backend-required core intelligence

is conflicting with current core architecture unless explicitly scoped as non-core future extension.

Policy:

- Extract generic durable lessons if useful.
- Remove provider authority.
- Quarantine or delete provider-specific active guidance.
- Do not let provider docs remain in the Codex default path.
- Keep Cloudflare R2 separate: R2 is allowed only for read-only public freshness/reference packs, never user-private data.
- Keep Apple sync separate: Apple-native user-owned sync is allowed only when scoped and user-controlled.

---

## 20. Old AI / Cloud Policy

Historical material that assumes:

- OpenAI/API dependency
- external LLM core intelligence
- chatbot-first UI
- cloud AI recommendation
- opaque model confidence
- cloud memory
- server-side personalization

is conflicting with current product truth.

Policy:

- Extract any local deterministic intelligence ideas.
- Delete or archive cloud-LLM assumptions.
- Remove “AI assistant” UI framing from active docs.
- Do not keep external/cloud LLM docs in default Codex context.
- If optional future AI extension is scoped later, it must live outside core product truth and be documented separately.

Core rule:

```text
External/cloud LLMs are not part of core Ambitions.
```

---

## 21. Old Release Claim Policy

Any old file that claims or implies:

- production-ready
- release-ready
- App Store-ready
- TestFlight-ready
- device-verified
- fully tested
- fully accessible
- performance validated
- privacy approved
- legally approved
- signed archive ready
- CI-proven

must be rewritten, archived, or deleted unless current proof exists.

Process:

```text
[ ] Check RELEASE_TRUTH.md.
[ ] Check current proof packet.
[ ] If proof absent, rewrite claim as non-claim.
[ ] Extract useful release checklist if needed.
[ ] Archive/delete old overclaim.
```

Release history may be retained only if clearly labeled historical and not current proof.

---

## 21A. Historical Policy Non-Claims

This historical policy does not prove:

- source migration
- build/test success
- accessibility
- performance
- release readiness
- TestFlight readiness
- App Store readiness
- privacy/legal approval
- current source has adopted current IA
- current screenshots or visual baselines are approved
- current proof artifacts are sufficient for public claims

Historical policy changes are docs/governance changes unless a separate source-changing issue explicitly scopes source, tests, project files, scripts, package manifests, runtime behavior, user data, or product surfaces.

---

## 22. Naming Drift Cleanup Policy

Current active user-facing/product names:

```text
Today
Goals
Time
Motion
You
Reality Meridian
Start Here Surface
Recommended step
LifeShape Field
LifeShape Field / Time Texture
Motion Current
Global Capture
Atmosphere Composer
User System Profile
Trust Seam
Receipt Surface
Quiet Reflow
Still Counts
Needs a Place
Ready to Place
Grow into Goal
```

Known old/source compatibility names:

```text
Plan
Profile
Captures
Capture tab
Capture inbox
Pulse
ProofPulse
DayTimelineRail
Hero Step Panel
Mission Control
Insights
Habits
Dashboard
activity feed
XP
Assistant
AI recommends
best next move
overdue
failed
streak
score
```

Policy:

- Active UI/docs should use current names.
- Internal source compatibility names may remain temporarily where renaming is risky.
- Source renames require tests and migration plan.
- Docs cleanup should migrate language before broad source renames.
- Tests must be updated when user-facing labels change.
- Compatibility map must remain until migration completes.

Do not blindly rename:

```text
plan
profile
captures
```

across source without route/test/migration review.

---

## 23. Link and Reference Cleanup Policy

Any cleanup pass must update:

- README links
- docs index links
- AGENTS/read-order links
- Codex route links
- source-truth maps
- batch references
- handoff links
- archive index
- relative links inside moved files

Broken links create Codex drift.

Before deleting/moving:

```text
[ ] Search for incoming links.
[ ] Update active links.
[ ] Replace with truth-file link where possible.
[ ] Add archive link only when historical access is necessary.
[ ] Record link cleanup in report.
```

---

## 24. Traceability Minimum

Every archive/delete/extract action must record:

```text
Original path:
Action:
Reason:
Useful content extracted:
Replacement authority:
Conflicts resolved:
Links updated:
Approval:
Date:
Rollback/restoration path:
```

For direct delete, record:

```text
Why no useful content was extracted:
Search/link proof:
Safety checklist result:
```

Traceability may live in:

```text
docs/archive/INDEX.md
docs/audits/<cleanup-report>.md
docs/truth/HISTORICAL_POLICY.md updates
cleanup PR description
```

---

## 25. Cleanup PR Protocol

Cleanup PRs/passes must be dedicated unless user explicitly combines scope.

Cleanup PR structure:

```text
Title:
Scope:
Truth files applied:
Files archived:
Files deleted:
Files extracted:
Files marked historical:
Links updated:
Risks:
Validation:
Approval:
Claims not made:
```

Cleanup PRs must not:

- change app behavior
- refactor Swift source
- remove tests
- add providers
- change release posture
- hide old claims without replacement
- delete active proof
- delete source truth

If cleanup discovers source/release/product issues, report them separately unless in scope.

---

## 26. Deletion Safety Checklist

Before deleting a file:

```text
[ ] File is not live source.
[ ] File is not a test.
[ ] File is not project/package config.
[ ] File is not a script still referenced.
[ ] File is not a resource/asset/entitlement/privacy manifest.
[ ] File is not current proof/log evidence.
[ ] File is not active truth.
[ ] File is not linked from active docs, or links are updated.
[ ] File has been classified.
[ ] Useful content has been extracted or no useful content exists.
[ ] Replacement authority is identified.
[ ] User approval exists.
[ ] Rollback path exists.
```

If any item is false, do not delete.

---

## 27. `.codex` Consolidation Policy

`.codex` should become a support layer, not a competing operating system.

Policy:

- Keep high-value route/skill/validation assets.
- Consolidate operating truth into `CODEX_PROCESS_TRUTH.md`.
- Remove duplicate process rules after extraction.
- Quarantine obsolete or conflicting skills.
- Avoid adding more one-off skills.
- Avoid default context packs that include old canon drift.
- Keep `.codex/state/*` as compact mirrors only.
- Do not let `.codex` define product/design/implementation/release truth.
- Archive/delete stale `.codex` artifacts only through dedicated cleanup.

Consolidation targets:

```text
duplicate checklists
old prompts
stale route maps
obsolete batch reports
provider-conflicting skills
release-overclaim templates
old model-tier instructions that conflict with truth hierarchy
```

Do not delete `.codex` wholesale.

---

## 28. Repo Cleanliness Target

Final repo cleanliness goal:

```text
A small active truth core, a lean docs front door, live source as implementation truth, current proof as release truth, and historical material reduced to extracted value plus minimal traceability.
```

Target structure:

```text
docs/truth/
  PRODUCT_DESIGN_TRUTH.md
  IMPLEMENTATION_TRUTH.md
  RELEASE_TRUTH.md
  CODEX_PROCESS_TRUTH.md
  HISTORICAL_POLICY.md

docs/
  README.md
  native-build-and-release.md
  archive/                # limited, indexed, expiring where possible
  supporting owner docs   # only when active and non-duplicative

.codex/
  lean support routes/skills/checklists
  no duplicate truth authority

Native/
  source/test/config free of stale product-language leakage where feasible
```

Cleanliness success means:

- Codex reads fewer files to get correct truth.
- Old canon cannot override current direction.
- README is clear and not Frankenstein.
- Release claims are conservative.
- Historical docs are not default context.
- Provider/cloud/AI drift is blocked.
- Product names are coherent.
- Source compatibility debt is tracked, not hidden.
- Archive does not become permanent clutter.

---

## 29. Codex Rules for Applying This Policy

When applying this policy, Codex must:

1. Read all truth files first.
2. Inventory before cleanup.
3. Classify before moving/deleting.
4. Extract useful content before deletion/archive.
5. Avoid opportunistic cleanup during feature work.
6. Ask for explicit approval before destructive changes.
7. Preserve active source/tests/config/proof.
8. Update links.
9. Add historical/supporting headers.
10. Report what remains.
11. Avoid release/product claims.
12. Avoid broad archive dumping.
13. Prefer deletion after extraction when history has no remaining value.
14. Keep cleanup reversible.
15. Stop on uncertainty.

Hard Red:

```text
Deleting or moving files without classification, extraction review, link check, approval, and rollback path.
```

---

## 30. Codex Rules for Updating This File

Update this file when:

- cleanup policy changes
- archive structure changes
- deletion standards change
- old canon migration progresses
- `.codex` consolidation changes
- provider/backend/AI historical policy changes
- release claim cleanup rules change
- traceability requirements change
- new historical drift pattern is discovered

Update rules:

1. Keep the policy operational.
2. Do not turn archive into permanent storage by default.
3. Do not weaken deletion safety.
4. Do not allow historical files to regain authority.
5. Keep local-only architecture protected.
6. Keep release claims proof-bound.
7. Keep cleanup separate from feature implementation unless explicitly scoped.

Final rule:

```text
History is useful only when it makes the active repo clearer. If it makes Codex drift, extract its value and remove the clutter.
```
