# Task 26 implementation report

Status: candidate frozen for exact high-risk review; Governance Yellow until that review is recorded.

## Scope delivered

- Activated canon revision 1 in `docs/canon/MANIFEST.toml` and made `docs/canon/` the sole normative repository root.
- Replaced repository front doors and the five retained skills with thin, non-authoritative routers/adapters.
- Added governed ChatGPT Project Instructions and deterministic ChatGPT-to-Codex and authorization-transition projections.
- Preserved the two exact reviewed Task 25 generated evidence artifacts in the active generator contract. Their bytes remain unchanged.
- Rebound only local Linear/Figma reconciliation authority-state evidence and downstream local SHA holders. No Linear or Figma inventory, read, write, or mutation was performed.
- Changed no Swift, Figma, Linear external state, workflow, protected-check, branch-protection, or ruleset surface. No file was deleted.

## Owner-direct boundary

Owner scope decision: `OWNER-TRAIN5-TASK26-SCOPE-2026-07-17T234045Z`.

Owner text SHA-256: `9691c2d6476147dc1913bf5404162b90c4e383c5ca6e533a13e6525a2b9a6119`.

The externally approved scope is exactly 42 sorted paths with manifest digest `ade805bb6d0059e66a0d54358c07da23daa1b70baaabe70d78a8896f6b2a636c`. The worktree was returned to clean base `63d65170632f775ddbd8d440f143a7b7654acda9` / tree `4abd231742d68a4f143205efabf9eb6c0b6f44f0` before the deterministic start record was created, then only those 42 paths were reapplied. The Task 26 task-policy expansion was removed; its base bytes are a verified Task 24 input, not the authority source. The owner-direct receipt is single-use and does not waive exact review, rollback, Gate C manifests, privacy/security, or proof honesty. Exact review remains pending. Direct integration and the cutover tag are not performed in this worktree.

## Focused TDD and covering evidence

- RED: `python3.12 -m unittest -v tests.canon.test_task26_cutover` failed on `shadow != active` before implementation.
- Repair RED: the focused contract rejected the missing owner scope/start-finalization record before the C/I repair.
- Repair GREEN: the same focused command passed one test in 227.353 seconds, including deterministic rejection of extra scope, reusable receipts, mutated candidate bytes, and stale active-mode canon content SHA.
- Covering set: the same three live-repository manifest, audit, and generated-render expectation tests passed in 41.303 seconds.
- Canon audit: Green; 62 documents, 473 requirements, 473 concept owners, authority state active.
- Canon build/generation: Green; the focused test includes deterministic `build_canon(..., check=True)`.
- Skill conformance: Green; five skills, registry digest `49dcca3435be63995852fd8f3c875411aed14972973a02490bc18ab497606d4a`.
- `git diff --check`: clean after the C/I repair.
- Task 25 preserved evidence: readiness SHA-256 `874707c870ab42590ed74d65c4e849a952cc8fad9b14def0d4560c898887adc0`; finalization SHA-256 `e48e3e9b9049a2ea0863d6f98a918efd30e13a38911ff05de683e4460d09ed63`.
- Governed Project Instructions SHA-256: `97ff5129fd5ba353958ebe9e24a97eb72ff4675c31df7f19119ff898998c1b23`.

Authority-sprawl remains Red only for the ten intentionally retained `docs/truth/` and `docs/constitution/` authority-like files. Task 26 marks them non-normative and routes no active work to them; deletion belongs to the separately authorized Task 27 purge. This task neither deletes them nor upgrades that check.

The final receipt validates the owner text and scope digest, exact clean base, Task 24 verifier implementation/schema/policy/command-manifest identities, Task 25 evidence, rollback tag identity, all 40 non-circular candidate paths with Git blob/mode/size/SHA-256, the two fixed circular review-only paths, candidate tree/delta/bundle, and the single-use start/finalization chain before rendering any transition claim. Its strict review-only state machine accepts either `pending` with absent package/receipt/candidate bindings or `complete_clean` with exactly zero Critical and Important findings, non-placeholder package and review-receipt SHA-256 digests, and exact reviewed candidate tree, candidate bundle, and scope-manifest bindings. A clean closure deterministically recomputes a distinct consumed, nonpending finalization ID from that closed payload while preserving the base, start, scope, verifier, Task 25, rollback, controls, and non-circular candidate evidence unchanged. The frozen candidate remains `pending`; no clean review receipt is asserted here.

## Explicit control posture

- `protected_ci_installed = false`
- `required_check_installed = false`
- `ruleset_inspected = false`
- `live_enforcement_proven = false`
- `post_merge_receipt_required = false`
- `gate_c = red`
- destructive approval: false
- purge approval: false

## Architecture and proof closeout

- Final Architecture Tree inspected: yes.
- Canonical owners touched: governance and generated documentation only under `docs/canon/`; no production architecture owner was changed.
- Files moved or created under product architecture: none.
- Old or non-canonical production paths removed: none.
- Compatibility shims: none.
- Yellow architecture debt: none introduced by this docs/tooling cutover.
- Next repair train: Task 27 for the governed legacy-authority purge; Task 28 for any separately approved external reconciliation work.
- No equivalent-folder or approximate-owner interpretation was used.

## Claim ceiling

This candidate establishes only a locally generated and focused-tested authority/routing cutover candidate. Governance Green remains conditional on the pending exact high-risk review of the frozen candidate. Protected CI, required checks, ruleset enforcement, live enforcement, destructive or purge approval, Gate C Green, product/runtime/visual/accessibility/privacy/legal/device/TestFlight/App Store readiness, and Release Green are unproven and not claimed.
