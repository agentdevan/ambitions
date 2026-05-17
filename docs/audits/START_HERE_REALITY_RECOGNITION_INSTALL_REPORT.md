# Start Here Reality Recognition Install Report

Status: Yellow — docs/canon and runner prompt installed; SwiftUI/runtime implementation not yet proven
Installed: 2026-05-16
Scope: Frontend visual encyclopedia canon, Today recipe authority wiring, chrome ledger, and runner-compatible implementation batch prompt

## Summary

Installed the mature Start Here reality-recognition plan into the Ambitions repo as active frontend canon and execution guidance.

The central canon rule is now explicit:

> Start Here recognizes scheduled reality before it recommends anything.

A scheduled step currently inside its time window must render as `Active step`, not `Recommended step`. `Recommended step` is valid only when Ambitions selects from unscheduled possible work.

## Files Installed / Updated

| Path | Status | Purpose |
| --- | --- | --- |
| `frontend/visual-encyclopedia/START_HERE_REALITY_RECOGNITION_DOCTRINE.md` | created | Active doctrine defining Start Here state labels, resolver precedence, scheduled-vs-recommended boundaries, receipt source rules, ADHD copy rules, edge cases, implementation phases, validation gates, and hard red conditions. |
| `frontend/visual-encyclopedia/FRONTEND_AUTHORITY_INDEX.md` | updated | Wires the doctrine into active frontend authority and locks it ahead of lower-level Today recipes for Start Here copy/state decisions. |
| `frontend/visual-encyclopedia/recipes/today/README.md` | updated | Adds Today-specific portal guidance so Today implementation starts from Reality Meridian plus Start Here reality recognition. |
| `frontend/visual-encyclopedia/trace/CHROME_ENRICHMENT_INSTALL_LEDGER.md` | updated | Records the Start Here reality-recognition refinement, validation gates, red stop conditions, and next runner batch. |
| `prompts/batches/START-HERE-REALITY-RECOGNITION-01.md` | created | Runner-compatible Ambitions Codex prompt for implementation through `scripts/ambitions-codex-train.sh`. |
| `docs/audits/START_HERE_REALITY_RECOGNITION_INSTALL_REPORT.md` | created | This release-honest install receipt. |

## Commit Trail

- `2171a1ec0ec4a9936768b124bd66119a1a9464d8` — Install Start Here reality recognition doctrine
- `0cc38aabcd933047e0f6dd9741af65b1524d3bda` — Wire Start Here reality recognition into frontend authority index
- `42bed3af6aaedf9da979b12e6c47a33b887ffcf2` — Install Start Here reality recognition batch prompt
- `231d8759f2d05f39d9a985af40bff8c96821d247` — Lock Start Here reality recognition in Today recipe portal
- `2acb1ad8736fc538d82dd88ef67bfbc63c255800` — Record Start Here reality recognition install in chrome ledger

## Canon Decisions Now Installed

1. Start Here is a reality-recognition aperture, not a generic recommendation card.
2. Scheduled-current work renders as `Active step`.
3. User-started work renders as `In progress`.
4. Upcoming scheduled work renders as `Up next`.
5. Unscheduled local selection renders as `Recommended step`.
6. `best next step`, `next best move`, `optimal move`, `AI pick`, `Overdue`, `Failed`, and `Behind` are forbidden Start Here labels/copy patterns.
7. Receipt source must match state authority.
8. Reality Meridian must visually prove the Start Here state.
9. Start Here UI must be resolver-derived rather than inferred ad hoc from task data.
10. The next implementation path must go through the Ambitions runner.

## Required Resolver Model

Future implementation should define or align to these concepts:

- `StartHereMode`
- `StartHereAuthority`
- `TemporalRelation`
- `StartHereCTA`
- `ReceiptSource`
- `ReceiptSignal`

Resolver output must include:

- display label
- primary object/title
- explanation copy
- primary CTA
- secondary CTA
- receipt source
- receipt signals
- visual tone/state
- accessibility label

## Required State Matrix

| State | Correct label | Primary CTA |
| --- | --- | --- |
| Explicit user-started session | `In progress` | `Resume` |
| Scheduled step active now | `Active step` | `Start now` |
| Scheduled item soon | `Up next` | `Open step` |
| Open unscheduled window with selected fit | `Recommended step` | `Start now` |
| Prior loop unresolved | `Needs closure` | `Close loop` |
| Plan drift or broken fit | `Recovery` | `Recover plan` |
| Protected block active | `Protected time` | `View block` |
| Away/vacation active | `Away mode` | `View commitments` |
| Hard calendar/schedule event active | `Current commitment` | `View commitment` |
| Competing scheduled/hard items | `Schedule conflict` | `Resolve conflict` |
| Missing context | `Set up today` | `Add schedule` |

## Proof Boundary

This install is docs/canon and runner prompt only.

It does not prove:

- SwiftUI implementation
- Start Here resolver existence in source
- Today preview parity
- simulator/device behavior
- screenshot parity
- VoiceOver conformance
- Dynamic Type conformance
- Reduce Motion conformance
- performance
- release readiness
- shipped behavior

## Validation Not Run

No local repo checkout, build, Swift tests, previews, simulator screenshots, or accessibility tooling were run in this install pass. The GitHub connector installed docs directly on `main` via contents API.

## Next Runner Command

```bash
scripts/ambitions-codex-train.sh START-HERE-REALITY-RECOGNITION-01 prompts/batches/START-HERE-REALITY-RECOGNITION-01.md
```

or:

```bash
make batch BATCH=START-HERE-REALITY-RECOGNITION-01 PROMPT=prompts/batches/START-HERE-REALITY-RECOGNITION-01.md
```

## Acceptance Bar For Next Implementation Batch

The next batch is acceptable only when Ambitions cannot accidentally render a scheduled-current step as `Recommended step` in the Today Start Here surface without a test, preview, proof report, or explicit Yellow/Red failure.

## Rollback Notes

The install is path-scoped to docs/canon and prompts. If rollback is required, revert the commits listed above or remove/update only the files listed in this report. Do not weaken higher truth files to accommodate this doctrine; update this doctrine if a higher authority conflict is discovered.
