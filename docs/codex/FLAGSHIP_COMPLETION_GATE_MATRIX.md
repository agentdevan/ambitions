# Flagship Completion Gate Matrix
<!-- markdownlint-disable MD013 -->

Status: Active-scope planning truth for FCP01-FCP30.
Date: 2026-05-05

## Purpose

This gate matrix defines the mandatory quality, safety, product, architecture, trust, accessibility, validation, and drift-prevention gates for Ambitions Flagship Completion Plan implementation.

No FCP implementation batch may be accepted unless every applicable gate is Green or explicitly documented as accepted Yellow with owner, reason, and repair path. Any hard Red stops the train.

## Gate Severity

- Green: complete and validated.
- Accepted Yellow: incomplete proof or advisory issue, but no product/safety/compatibility risk and explicit owner exists.
- Red: train-stopping failure.

## Universal Hard Red Gates

| Gate | Red condition |
|---|---|
| Top-Level Tab Gate | Adds, renames, hides, or replaces Today / Goals / Capture / Plan / You. |
| Deep-Not-Wide Gate | Creates new top-level surface or parallel workflow instead of deepening an existing owner. |
| Anti-Generic UI Gate | Dominant object is generic card stack, dashboard grid, calendar clone, task list, PM board, notes feed, or settings dump. |
| Release Claim Gate | Claims App Store, TestFlight, physical-device, public accessibility, privacy/legal, AI runtime, sync/cloud, or platform readiness without proof. |
| Trust / Source Gate | Recommendation, placement, reflow, closure, or proof action lacks source/trust/privacy explanation. |
| Hidden Mutation Gate | Meaningful user plan/data/recommendation changes happen without review, receipt, or explicit acceptance. |
| Compatibility Gate | Route/raw-value/import/export/persistence/schema/widget/AppIntent compatibility is broken without explicit CS owner proof. |
| Accessibility Gate | Meaning depends on color or motion alone, VoiceOver order is broken, or privacy-sensitive labels expose hidden detail. |
| Validation Gate | Implementation lacks focused tests/build validation or validation failure is unclassified. |
| File Boundary Gate | Broad unrelated files are edited, file-size Red is ignored, or owner boundary is violated. |

## Gate Matrix By Batch Type

### Docs / Planning Batches

Applies to: FCP01, FCP02, FCP03, FCP28 when audit-only, FCP29, FCP30.

Required gates:

- Source Truth Gate
- No Production Swift Gate
- No Behavior Claim Gate
- No Route/Raw/Persistence Gate
- No Dependency/Workflow Gate
- Registry/Context Consistency Gate
- Release Claim Gate
- Documentation Link Gate

Required validation:

- `git status --short`
- `git diff --check`
- docs link scan if available
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`
- explicit verification that no production Swift, project, route/raw, persistence/schema, workflow, dependency, signing, entitlement, or CI/config files changed

Accepted Yellow examples:

- local doc QA script unavailable in remote Codex environment
- historical advisory backlog unrelated to changed files

Red examples:

- docs claim app behavior was implemented
- docs authorize implementation outside named train without gate
- docs overwrite active status truth incorrectly

### Shared Design System Implementation Batches

Applies to: FCP06, FCP09, FCP12, FCP25, FCP26.

Required gates:

- Design System Purpose Gate
- Object Anatomy Gate
- Accessibility / Reduced Motion Gate
- Trust / Source Gate when receipt/proof/source is touched
- Preview Matrix Gate
- Focused Design-System Test Gate
- File Size / Extraction Gate
- Surface Composition Gate if wired into top-level screens
- No Runtime Overclaim Gate

Required validation:

- focused design-system tests
- changed preview compile check where available
- `xcodegen generate` if project files/generated references affected
- `scripts/build-local.sh`
- product drift scan
- release-claim scan
- accessibility/reduced-motion scan
- file-size/diff-size review

### Today Implementation Batches

Applies to: FCP05, FCP07, FCP16 Today integration, FCP21 Step Detail/Session parts.

Required gates:

- Today Ownership Gate
- Start Here / Reality Rail Primary Object Gate
- No Agenda Clone Gate
- Closure / Recovery No-Shame Gate
- Receipt / Proof Gate
- Privacy Redaction Gate
- Dynamic Type / VoiceOver / Reduced Motion Gate
- Focused Today Tests Gate

Required states:

- normal
- tight
- overloaded
- private
- no schedule
- source stale
- missing duration
- blocked/waiting
- recovery
- empty
- reduced motion
- accessibility Dynamic Type

Red examples:

- Start Here remains a generic recommendation card
- Today becomes agenda/task list
- missed steps become shame/overdue failure
- Start now fails to route to Step Session

### Goals Implementation Batches

Applies to: FCP10, FCP11, FCP12, FCP13, FCP20 Goals integration, FCP27 Goals integration.

Required gates:

- Goals Ownership Gate
- LifePath Thread Gate
- MissionControlTimeSpine Gate
- No Dashboard / PM Board Gate
- Proof / Source / Decision History Gate
- Alternate Path User Review Gate
- Accessibility / Dynamic Type Gate
- Focused Goals Tests Gate

Required states:

- active goal
- private goal
- proof-heavy
- blocker
- alternate path pressure
- stale source
- no proof
- reduced motion
- accessibility Dynamic Type

Red examples:

- Mission Control remains primary card grid
- lanes become metrics dashboard
- alternate path auto-reroutes without review

### Capture Implementation Batches

Applies to: FCP18, FCP19, FCP20 Capture integration, FCP21 Capture accessibility.

Required gates:

- Capture Ownership Gate
- Text-First Composer Gate
- No Inbox / Feed / Notes Gate
- Placement Review Gate
- Correction Receipt Gate
- No Hidden Learning Gate
- Privacy / Local Source Gate
- Focused Capture Tests Gate

Required states:

- empty needs-place
- typed route suggestion
- ambiguous route clarification
- private item
- placement corrected
- decide later
- error
- mic unavailable or connected
- reduced motion
- accessibility Dynamic Type

Red examples:

- automatic goal creation
- hidden personalization or learning claim
- route confidence percentage
- Capture becomes inbox/feed

### Plan Implementation Batches

Applies to: FCP14, FCP15, FCP16 Plan integration, FCP17 Plan integration, FCP27 Plan integration.

Required gates:

- Plan Ownership Gate
- LifeShape Contour Gate
- No Calendar Clone Gate
- No Silent Reflow Gate
- Protected Time Gate
- Capacity / Pressure / Recovery Gate
- Receipt Gate
- Focused Plan Tests Gate

Required states:

- open day
- tight day
- overloaded day
- protected time
- vacation/away
- late start
- source stale
- no calendar/setup
- reduced motion
- accessibility Dynamic Type

Red examples:

- dense calendar grid as primary Plan object
- silent rearrangement
- treating vacation as free time by default
- fake precision capacity math

### You / Profile Implementation Batches

Applies to: FCP17 You integration, FCP22, FCP23, FCP24, FCP27 You integration.

Required gates:

- You Ownership Gate
- Personal System Center Primary Object Gate
- No Settings Dump Gate
- Trust / Data / Memory Control Gate
- Availability Center Gate
- Appearance Studio Non-Behavior-Claim Gate
- Privacy Redaction Gate
- Focused Profile Tests Gate
- File Size / Extraction Gate

Required states:

- setup incomplete
- setup complete
- private mode
- denied permission
- local only
- stale memory/source
- receipt history empty
- unsaved appearance/default changes
- reduced motion
- accessibility Dynamic Type

Red examples:

- You root becomes generic settings list
- memory UI claims durable behavior not implemented
- export/delete/sync claims exceed implementation

## Object-Specific Gates

### Start Here Surface Gate

Must prove:

- Source-quality because line.
- Time-fit / buffer proof.
- Context Edge.
- Compressed Goal Thread.
- Receipt drawer seam.
- Start now / Open step action.
- Adjust plan / Why this? secondary action.
- Privacy redaction.
- Source stale review path.

Red if Start Here is only a renamed Hero Step card.

### Reality Rail Gate

Must prove:

- Start Here active node.
- Now / Next / Later as rail segments.
- Closure knots.
- Proof markers.
- Pressure edge.
- Empty and overloaded rail behavior.

Red if Today becomes agenda/task list.

### MissionControlTimeSpine Gate

Must prove:

- Spine primary object.
- Completed / Now / Friction / Next / Horizon order.
- Lane inspection without new destination.
- Proof marker, blocker knot, alternate branch.

Red if Mission Control is a card grid.

### LifeShape Contour Gate

Must prove:

- Contour, pocket, field, ridge anatomy.
- Protected time visibility.
- Pressure and recovery non-color meaning.
- No calendar grid primary.

Red if LifeShape is just a bar chart/card grid.

### Receipt Drawer Gate

Must prove:

- What happened.
- Why.
- Source.
- Freshness.
- Privacy.
- Change/no-change.
- Undo/correction/review.

Red if trust is only toast/snackbar.

### Closure Diamond Gate

Must prove:

- Completed.
- Still Counts.
- Moved / Rescheduled.
- Blocked / Waiting.
- Secondary fold.
- Receipt preview before confirmation.

Red if closure is done/failed binary.

## Final Train Acceptance

FCP30 may close only when:

- no unresolved Red remains
- all 25 objects are implemented or have accepted Yellow owner and repair path
- all five top-level tabs pass one-primary-object law
- all major states have previews and focused tests or accepted Yellow
- cross-surface proof/review is integrated or explicitly owner-deferred
- no public/release/platform/accessibility/privacy/AI claims exceed evidence
