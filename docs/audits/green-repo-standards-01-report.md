# GREEN-REPO-STANDARDS-01 Audit Report

## Scope and Boundaries

This patch implemented only the Phase 02 approved surface boundary:

- `docs/status/current-implementation-map.md`
- `docs/status/repo-cleanup-index.md`
- `Native/AmbitionsUITests/AmbitionsUITests.swift`
- `Native/Ambitions/AppIntents/OpenAmbitionsDestinationIntent.swift`
- `Native/Ambitions/App/ShellCommandModels.swift`
- `Native/AmbitionsTests/App/AppIntentRoutingTests.swift`

No changes were made to:

- `docs/truth/**`
- `AGENTS.md`
- `README.md`
- `docs/README.md`
- `Package.swift`
- `project.yml`
- `Sources/**`
- `AppUI/**`
- `tools/mcp/**`

## Authority and Status Repair

- Corrected stale active doc routing so `docs/truth/PRODUCT_DESIGN_TRUTH.md` and `docs/truth/README.md` are treated as active sources in implementation status map.
- Demoted `docs/AmbitionsCanon/README.md` from active product/design authority in cleanup index.
- Preserved `AmbitionsCanon/*` as supporting canon only.
- Preserved active top-level IA as `Today / Goals / Capture / Time / You` in patched docs and tests.

## Product IA Repair Outcomes

- `docs/status/current-implementation-map.md`: active product/design source truth now points to `docs/truth/PRODUCT_DESIGN_TRUTH.md`.
- `docs/status/repo-cleanup-index.md`: `docs/AmbitionsCanon/README.md` marked supporting-only.
- `Native/Ambitions/App/ShellCommandModels.swift`: surfaced source/copy uses `Time` / `Shape Time` for user-facing text and short title where appropriate.
- `Native/Ambitions/AppIntents/OpenAmbitionsDestinationIntent.swift`: user-facing destination labels use `Time`/`Shape Time` while preserving internal `.plan` enum case and compatibility raw route `ambitions://tab/plan`.
- `Native/AmbitionsUITests/AmbitionsUITests.swift`: tab assertions include `Time` in canonical destination checks; compatibility route assertions keep `ambitions://tab/plan` and internal identifiers.
- `Native/AmbitionsTests/App/AppIntentRoutingTests.swift`: active routing assertions classify `.plan` as compatibility and verify canonical user-facing labels as `Time`.

## Compatibility Seams Preserved

- Internal compatibility route remains `ambitions://tab/plan`.
- Internal feature ownership and identifiers for Plan-compatible internals remain (`.plan`, `plan.*`, `PlanScreen`, `plan`-scoped navigation path names).

## Risk Register (This phase)

| term/path | classification | action | remaining risk |
| --- | --- | --- | --- |
| `Plan` in legacy labels under compatibility routes/services | internal compatibility seam | preserved | Low — requires continued regression checks while user-facing drift remains time-based |
| `ambitions://tab/plan` | compatibility route | preserved | Low — visible docs/tests no longer treat it as user-facing tab copy |
| `Dashboard`, `Assistant`, `AI recommends`, `Mission Control`, `DayTimelineRail`, `score`, `streak` etc. | historical / supporting context outside current IA boundary | recorded in audit packet | Medium — requires broader audit pass to normalize repo-wide |

## Validation Summary

| area | evidence/log | result |
| --- | --- | --- |
| authority-route scan | `output/logs/green-repo-standards-01/ripgrep-authority-phrases.txt` | pass / remaining historical mention in `AGENTS.md` is compatible |
| Plan-tab UX scan | `output/logs/green-repo-standards-01/ripgrep-plan-tabs.txt` | pass / no tab-level user-facing `Plan` assertions found |
| compatibility-language scan | `output/logs/green-repo-standards-01/term-scan.txt` | pass / only compatibility or internal identifiers remain |
| git diff hygiene | `output/logs/green-repo-standards-01/git-diff-check.log` | pass |
| Phase 03 local build | `output/logs/green-repo-standards-01/phase03-review/xcodebuild-build.log` | pass |
| Phase 03 AppIntent routing tests | `output/logs/green-repo-standards-01/phase03-review/unit-tests.log` | pass / 8 tests |
| Phase 03 focused Time UI subset | `output/logs/green-repo-standards-01/phase03-review/ui-time-subset.log` | pass / 3 tests |
| Phase 04 repair preflight | `output/logs/green-repo-standards-01/phase04-repair/preflight.log` | pass / `STATUS: CLEAR` |
| Phase 04 repair local build | `output/logs/green-repo-standards-01/phase04-repair/xcodebuild-build.log` | pass |
| Phase 04 repair AppIntent routing tests | `output/logs/green-repo-standards-01/phase04-repair/unit-tests.log` | pass / 8 tests |
| Phase 04 repair focused Time UI subset | `output/logs/green-repo-standards-01/phase04-repair/ui-time-subset.log` | pass / 3 tests |
| Phase 04 repair runner self-check | `output/logs/green-repo-standards-01/phase04-repair/self-check.log` | pass |
| Phase 04 repair prompt audit | `output/logs/green-repo-standards-01/phase04-repair/prompt-audit.log` | exit 0 / accepted Yellow support-eval-template classification |
| Phase 04 repair git diff hygiene | `output/logs/green-repo-standards-01/phase04-repair/git-diff-check.log` | pass |

## Notes on Blockers

- Phase 02 full UI validation timed out; Phase 03 reran the focused Time/Plan affected UI subset successfully.
- Full `AmbitionsUITests` coverage remains a non-claim because this batch did not produce a complete passing full UI-suite log.
- No false claims were added for release readiness, accessibility proof, performance proof, device proof, privacy/legal approval, or production readiness.
- Visual proof is not produced in this phase; proof gap documented separately.
