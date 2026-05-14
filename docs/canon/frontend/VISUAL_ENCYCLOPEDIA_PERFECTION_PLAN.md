# Visual Encyclopedia Perfection Plan

Status: Active control-plane plan

## Goal

Make the Ambitions frontend canon strict enough that the intended object-first product cannot drift into a generic task app, calendar clone, chatbot, dashboard, or settings clone.

## Non-Goals

- No production UI edits.
- No release/signing/TestFlight/App Store claims.
- No hosted CI activation.
- No new product strategy.

## Phases

1. Audit the current visual canon and classify the gaps.
2. Install object anatomy, label-off tests, and the vocabulary boundary.
3. Install source linkage, surface graph, and conflict ledgers.
4. Install transaction, recovery, proof, and anti-generic behavior laws.
5. Add validators and the dashboard generator.
6. Review the results and keep unresolved direction explicit.

## Artifacts

- `VISUAL_ENCYCLOPEDIA_RUTHLESS_AUDIT.md`
- `VISUAL_VOCABULARY_BOUNDARY.md`
- `VISUAL_SOURCE_LINKS.yaml`
- `trace/VISUAL_CONFLICT_LEDGER.md`
- `trace/VISUAL_SOURCE_LINKAGE_LEDGER.md`
- `trace/VISUAL_SURFACE_GRAPH_LEDGER.md`
- `objects/*_ANATOMY.md`
- `primitives/*.md`
- `behavior/*.md`
- `gates/NORTH_STAR_100_ACCEPTANCE_GATE.md`
- `scripts/ambitions-visual-*.py`

## Success Metrics

- Active IA remains `Today / Goals / Capture / Time / You`.
- Every top-level object has an anatomy doc and label-off signature.
- Priority recipes have source-linkage entries and source candidates.
- The surface graph exposes unresolved direction instead of hiding it.
- The dashboard shows coverage, residue, vocabulary violations, and remaining gaps.

## Validation Commands

- `python3 -m py_compile scripts/ambitions-visual-*.py`
- `python3 scripts/ambitions-visual-source-linkage-check.py`
- `python3 scripts/ambitions-visual-template-residue-check.py`
- `python3 scripts/ambitions-visual-vocabulary-boundary-check.py`
- `python3 scripts/ambitions-visual-surface-graph-check.py`
- `python3 scripts/ambitions-visual-dashboard.py`

## Handling Unresolved Direction

- Keep the gap named.
- Keep the target surface visible.
- Mark the status as `unresolved_direction` or `needs_direction`.
- Do not invent missing detail from generic UI patterns.

## Safe Update Rules

- Update the manifest and ledgers in the same patch as any new canon doc.
- Prefer additive supersession over destructive rewrites.
- Do not let the old recipe family go stale after adding new canonical docs.

## Rollback Expectations

- New docs may be deleted if they only duplicate existing canon.
- New scripts may be removed if a later batch replaces the control plane.
- Generated reports may be regenerated or deleted without affecting source truth.
