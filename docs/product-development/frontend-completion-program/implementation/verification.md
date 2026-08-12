# UFP verification plan

## Evidence rules

The sole operational ledger is
`/Users/devan/.codex/output/Ambitions_Maximum_Polish_Program/PROGRAM.json`.
Record each command, result, artifact path, exact revision, device/OS, and
scope there. Fixture, Simulator, device, runtime, accessibility, and release
evidence are distinct and must never be substituted for one another.

Native Foundry proof is limited to deterministic fixture/render/proof evidence.
It cannot prove production persistence, mutation, privacy, restoration,
physical-device behavior, or release quality.

## Verification matrix

| Area | Required evidence | UFP milestones | N/A policy |
| --- | --- | --- | --- |
| Lifecycle/docs | `git diff --check`; `python3 scripts/ambitions_product_docs.py check` when available; link/path checks; unique REQ traceability | UFP-0, final | If the lifecycle script is absent, record absence and run Markdown/link checks instead. |
| Ledger | JSON parse/schema, UFP-0…UFP-8 dependency/owner/exit/proof validation, no repo shadow ledger | UFP-0, every gate | N/A: never. |
| Source/static | `git diff --check`, SwiftLint/static analysis/secrets scan, final-byte import/dependency/reference scans | UFP-0, UFP-4–8 | N/A only if no production Swift changes; still run docs/reference checks. |
| Package/build | `swift build/test --package-path Packages/AmbitionsPresentation`; XcodeGen regeneration after `project.yml`; app/extension build | UFP-1–8 as changed | N/A only where affected target does not exist; record target inventory. |
| Fixture/visual | primary directions, 47-screen coverage, deterministic fixture unit tests, host UI journeys, state screenshots, hard-kill/taste review, system/complete-frontend owner approval | UFP-1–5 | N/A: never for fixture-system work. |
| Runtime | projection/intent/receipt/recovery integration; persistence, idempotency, revision conflict, replay, restoration | UFP-6 | N/A before production wiring only; never for reconstructed route. |
| Migration | schema compatibility, idempotency, interrupted migration, replay/count/reference parity, rollback | UFP-6, UFP-8 | N/A only where final-byte contract confirms no persisted schema/data change. |
| Privacy/security | local-first/offline/private state tests; privacy manifest/dependency scan; no unreviewed external UI package | UFP-1–8 | N/A: no, every production route must retain the boundary. |
| Accessibility | VoiceOver, Dynamic Type, target size, focus/keyboard, contrast/transparency, Reduce Motion, Switch Control, RTL/localization | UFP-2, UFP-5, UFP-6, UFP-8 | N/A only for a noninteractive artifact; explain in ledger. |
| Performance | launch/scroll/animation responsiveness, memory/energy observation, no unbounded render/recompute | UFP-6, UFP-8 | N/A only for documentation-only task. |
| Simulator | named scheme, OS, device, build, UI and visual geometry/copy comparison | UFP-2, UFP-5, UFP-6 | N/A only if no executable UI target exists. |
| Physical iPhone | reach, touch, system gestures, keyboard, OLED/material, haptics, scroll/motion, VoiceOver and real performance | UFP-6, UFP-8 | N/A before production source exists; never at release. |
| Legacy deletion/release | replacement parity, rollback rehearsal, zero live legacy refs, package/target/assets cleanup | UFP-7 | N/A: never for UFP-7. |
| Release closure | release archive/run, final device/accessibility/privacy/performance/localization/migration proof, explicit release approval | UFP-8 | N/A: never. |

## Required gate checks

### Complete-fixture-frontend gate (UFP-5 → UFP-6)

1. UFP-1 primary directions, UFP-2 47-screen coverage, UFP-3 unified grammar,
   and UFP-4 canonical source/dispositions are complete.
2. Every fixture entry renders source-identical canonical UI through synthetic
   adapters; production target import scans find no Native Foundry dependency.
3. The owner explicitly approves the complete fixture-driven frontend/design
   system and `approvals.frontend_design` is true.
4. `frontend-complete` tracker gate passes; runtime integration remains an
   independent approval.

Failure result: production wiring remains blocked and work returns to the
responsible UFP-1…UFP-5 milestone. A Foundry suite pass alone is not a gate.

### Runtime-integration gate (UFP-6 → UFP-7)

1. Independent runtime-integration approval is true before integration starts.
2. Today is first; all remaining vertical slices use real local-runtime adapters
   without duplicate route/state/mutation/restoration authority.
3. Each final-byte slice passes runtime, replay, persistence, recovery,
   migration where applicable, privacy, accessibility, and Simulator checks.
4. `runtime-integration` tracker gate passes; it does not imply cutover.

Failure result: UFP-7 cutover/deletion remains blocked and no legacy source is removed.

### Atomic cutover/deletion gate (UFP-7 → UFP-8)

1. Explicit production-cutover and legacy-deletion approvals are true.
2. One atomic cutover deletes every classified legacy frontend source,
   component, target, dependency, asset, wrapper, route, preview, UI test,
   flag, and unclassified frontend artifact.
3. Final-byte scans prove zero legacy; target/package/assets resolve; replacement
   parity and rollback rehearsal are recorded; `cutover` tracker gate passes.
4. UFP-8 then records physical-iPhone/manual accessibility, performance/energy,
   privacy, localization/RTL, migration, archive, and release approval evidence.

## Minimum command patterns

Use the current repository’s exact workflow names and schemes after rebasing.
Typical non-destructive checks are:

```sh
git diff --check
python3 scripts/ambitions-canon.py check
swift test --package-path Packages/AmbitionsPresentation
swift build --package-path Packages/AmbitionsPresentation
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=<current device>' build
```

Run `xcodegen generate` only when `project.yml` changes. Run focused tests
first, then the changed-scope Code Quality lanes. Add the actual Simulator ID,
scheme, derived-data/result-bundle paths, and output outcome to the ledger;
never reuse stale evidence after source changes.

## Verification self-review

**PASS.** The plan names automated, build, fixture, runtime, privacy,
migration, accessibility, performance, Simulator, physical-device, deletion,
and release evidence; it distinguishes each proof ceiling and supplies explicit
N/A rules.
