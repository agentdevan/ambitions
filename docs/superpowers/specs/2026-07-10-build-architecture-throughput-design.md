# Ambitions Build Architecture and Throughput Design

Status: Implemented foundation with active measured-decomposition policy
Date: 2026-07-11
Decision record: `ADR-BUILD-001`
Scope: Xcode/Swift package startup, module decomposition, evidence-backed source destruction, build workflow, and development-throughput proof
Claim status: Implemented Yellow — the package relocation, cache/lane controls, TimeFoundation pilot, and warm focused loop have current evidence; broader decomposition and cache-invalidated build improvement remain unproven

## 1. Purpose

Ambitions needs a materially faster edit-build-test loop without weakening source ownership, runtime correctness, privacy, accessibility, deterministic testing, or proof honesty.

This work does not change product behavior. It preserves repo health so later work can improve:

```text
Intent -> Context -> Path -> Time Fit -> Reflow -> Action -> Proof -> Learning
```

The design has four linked parts:

1. Remove the repo-root Swift package scan.
2. Delete obsolete and duplicate source before it becomes module API.
3. Decompose only measured high-churn, compiler-closed cohorts into a balanced acyclic build graph.
4. Make build throughput a measured, regression-gated engineering property.

## 2. Evidence and problem statement

Implementation-start evidence, captured before the completed package relocation and pilot, established:

- `project.yml` declares the existing local Swift package with `path: .`.
- Xcode therefore treats the repository root as the local package container.
- `Native/Ambitions` contains 1,336 Swift files; `Native/AmbitionsTests` contains 419 Swift files.
- `Core` contains 693 Swift files and approximately 142,620 lines.
- `Surfaces` contains 240 Swift files and approximately 47,013 lines.
- Production source contains 121 numbered suffix files matching `+NN`.
- Production source contains 72 files over 400 lines, totaling 34,527 lines.
- Twenty-three Core files currently import `AmbitionsDesignSystem`, showing dependency-direction debt that must be resolved before Core becomes a clean leaf module.
- The current VM exposes four x86_64 CPUs and approximately 10.75 GB RAM.

Measured startup comparison on the same checkout and machine:

| Project/package shape | Command | Result |
|---|---|---:|
| Isolated local-package mirror | `xcodebuild -list -disableAutomaticPackageResolution -skipPackageUpdates -project Ambitions.xcodeproj` | 8.103 seconds |
| Canonical repo-root package | Same command | Still scanning after 196 seconds; stopped |

Historical retained local logs also show:

- a healthy incremental build lane taking 81.682 seconds while its only Swift compile task took 1.647 seconds;
- broad cached build-for-testing lanes taking roughly 9–10.5 minutes;
- one broad lane reporting 92 Swift compile tasks and 1,963 aggregate compiler-seconds;
- fresh cache/package identities forcing rebuilds beyond 20 minutes.

The 20-minute result is not the expected steady-state development loop. It combines discarded cache identity, package-graph churn, a repo-root package scan, a large monolithic target, and four-core hardware limits.

Current Xcode 26.6 evidence after the foundation pilot separates the remaining costs:

| Scenario | Result | Interpretation |
|---|---:|---|
| Cache-invalidated `AmbitionsUnitTests` build-for-testing | 439 seconds | Cold/full-target compile cost remains a separate optimization problem. |
| Immediate no-change build-for-testing repeat | 8 seconds | The steady-state compile lane is already fast when cache identity is preserved. |
| Retained health-selected hosted focused test | 21.262 seconds; 15/15 passed | The normal focused runner is within the provisional 30-second target on the configured healthy simulator. |

The attempted exact-folder `Core/Domain` extraction is not a dependency-closed module candidate. Its compiler probe produced 123 errors across 11 files and exposed reverse dependencies on 12 declarations owned by LocalRuntimeOS, Persistence, Today projection, and You projection. A broader conservative lexical pass found only 45 of the 166 census files independently separable; that estimate is supporting triage evidence, not compiler closure or extraction authorization. Current 250-commit churn is concentrated in App composition, LocalRuntimeOS, Time, Stage, and visible surfaces rather than the Domain folder as a whole.

## 3. Goals

- Preserve `project.yml` and XcodeGen as project authority.
- Preserve exact canonical source ownership under `Native/Ambitions/`.
- Move the existing design-system package out of the repository root.
- Use balanced modules to reduce incremental invalidation and enable parallel compilation.
- Delete duplicate, historical, superseded, and unnecessary compatibility source before module extraction.
- Make cross-module APIs small, explicit, testable, and `Sendable` where required.
- Preserve Swift 6 strict concurrency.
- Preserve local-first behavior and the runtime law:

```text
Command -> Event -> Projection -> Receipt -> Replay
```

- Benchmark every structural slice on one stable environment and DerivedData identity.
- Keep every migration slice independently reviewable, revertible, and bisectable.

## 4. Non-goals

- No user-facing IA, feature, copy, visual, or behavior change.
- No fifth surface, Capture destination, Motion destination, or new product architecture vocabulary.
- No package or module split merely to improve aesthetics.
- No mass-public API conversion to make compilation pass.
- No deletion based only on filename, age, a zero-result text search, or compiler warning.
- No clean-build or performance claim without current measurements.
- No device, accessibility, visual, release, TestFlight, or App Store claim.
- No physical-device gate for this build-only design; physical-device proof remains required wherever product or release truth requires it.

## 5. Architecture decisions

### 5.1 Relocate the existing design-system package

This specification is the linked package-boundary decision record and validation plan required by the Ambitions remediation freeze. It records the measured problem, proposed boundary, migration sequence, proof gates, failure handling, and rollback. Implementation must link back to `ADR-BUILD-001`; it must not create a second competing decision authority.

Move the existing root package intact before changing application modules:

```text
Package.swift
Sources/
AppUI/
```

to:

```text
Packages/AmbitionsDesignSystem/Package.swift
Packages/AmbitionsDesignSystem/Sources/
Packages/AmbitionsDesignSystem/AppUI/
```

Update `project.yml` to point to `Packages/AmbitionsDesignSystem` and update retained scripts and documentation that resolve the manifest or source paths.

This is a justified package-boundary change because it removes a measured multi-minute repository traversal. The relocation must be behavior-neutral and committed separately so its throughput effect is measurable and its rollback is one revert.

### 5.2 Preserve canonical source paths during app decomposition

Application source remains under the exact owners in the Final Architecture Tree:

```text
Native/Ambitions/App
Native/Ambitions/Stage
Native/Ambitions/Core
Native/Ambitions/Projection
Native/Ambitions/Language
Native/Ambitions/Trust
Native/Ambitions/Interaction
Native/Ambitions/Rendering
Native/Ambitions/DesignSystem
Native/Ambitions/Surfaces
Native/Ambitions/Composer
Native/Ambitions/Scenarios
Native/Ambitions/Diagnostics
Native/Ambitions/Quality
```

Module boundaries are implemented as XcodeGen-managed Swift framework targets referencing those canonical paths. Frameworks should link statically when the supported XcodeGen/Xcode configuration is verified. The first leaf extraction is a measured pilot; it must prove source-path preservation, correct linking, test discovery, resource behavior, and incremental benefit before the pattern is repeated.

The proposed module names are build-graph labels, not product language or permanent source-tree law. A boundary may be combined or adjusted when dependency evidence proves the initial split would create cycles, excessive API, or worse build performance.

### 5.3 Policy-authorized target evolution

There is no predetermined future target tree, target-name list, folder-to-target translation, or extraction sequence. The current generated target graph is recorded in `docs/qa/architecture/current-module-graph.json`. A future target may be proposed only for an explicit canonical source-file cohort whose status evaluates `authorized` under `docs/qa/architecture/module-candidate-policy.json`.

That policy file is the single numeric authority for prospective decomposition. A prospective candidate row is pointer-only: candidate ID, valid proposed target identifier, exact explicit source set and content hash, status, and SHA-256 references to typed JSON artifacts. It cannot authorize itself with duplicated booleans, counts, medians, timing rows, prose, or a hash of those assertions.

The retained gate parses candidate artifacts as untrusted inputs and recomputes their internal consistency; those files do not establish their own authority. The deterministic candidate identity binds candidate ID, proposed target, exact source set and hash, live full repository HEAD, `project.yml`, and the changed-file router authority. Every artifact repeats that identity and live authority binding, and evaluation requires a clean tracked worktree with repository-contained, non-symlink source and authority files. The history artifact must equal the live first-parent commit window and recomputed per-file touch maps. Compiler wrappers, graph rows, symbol graphs, route rows, test summaries, result-bundle metadata, raw logs, benchmark summaries, and review fingerprints remain integrity evidence subject to strict structural checks; a forged but structurally complete set still cannot authorize itself.

Authorization also requires a trusted verification provider whose execution environment is controlled outside the candidate artifacts. The CLI/default provider locates XcodeGen in that environment, runs `xcodegen dump --no-env`, derives every target node, target dependency edge, target product type, graph role, exact candidate source, and exact candidate dependency, and requires the proposed target to remain a framework. It then generates an ephemeral PBX from `project.yml` with environment expansion disabled and requires those source-truth nodes, edges, PBX product types, and complete source memberships to equal the ignored/untracked current generated `Ambitions.xcodeproj` derivative. Candidate-only membership agreement is insufficient. The provider separately invokes the live changed-file router for every candidate source and requires the exact declared module and hosted-integration selectors; an invalid route, stale membership, forbidden host reachability, missing or ambiguous live test suite, product-kind relabeling, or any full generated-project parity drift rejects the candidate. These live checks are semantic, but their executable, PATH, project, and process environment remain part of the external trust precondition rather than proof supplied by the candidate.

The default provider does not independently run and rederive compiler/symbolgraph declarations, `.xcresult` test identities, benchmark facts, or external review identity. If any such trusted provider fact is unavailable, the candidate is `observed`, never `authorized`; a mismatch is `rejected`. Programmatic provider injection exists for caller-controlled integrations and deterministic unit fixtures, not as a CLI artifact or flag. Handwritten reviewer identities, repository Git authorship, unsigned Git notes, and repository allowlists do not establish external review trust. Benchmark candidate cohorts bind the live HEAD, while every baseline cohort must bind a strict first-parent ancestor from the retained history window and therefore cannot reuse HEAD. Missing referenced artifacts remain `observed`; present malformed, swapped, escaped, or digest-mismatched artifacts are `rejected`. The current CLI/default trust ceiling authorizes zero future targets.

The generated graph must remain acyclic, canonical source ownership does not move merely to create a build boundary, and lower-level candidates cannot gain reverse dependencies on App, Stage, surfaces, or other upper owners. The policy deliberately avoids one target per folder or concept. Whole-folder `Core/Domain` remains rejected as a speed prerequisite; its reviewed census and failed compiler probe are supporting evidence, not target authority.

## 6. Destruction policy

### 6.1 Sequence

Destruction occurs in three places:

1. **Before decomposition:** create a source disposition inventory and remove proven global dead or historical source.
2. **During each extraction:** delete duplicate and superseded authority before moving survivors into the new target.
3. **After decomposition:** use explicit dependency and API boundaries to remove orphan adapters, temporary shims, unused target membership, and unused public declarations.

The controlling rule is:

```text
Do not modularize code that should be deleted.
```

### 6.2 Disposition classes

Every reviewed source file receives one disposition:

- canonical and retained;
- canonical but requires consolidation;
- misowned and required;
- duplicate authority;
- obsolete compatibility shim;
- historical residue;
- generated source;
- test/preview-only support;
- unknown pending stronger evidence.

Unknown files are not deleted merely to meet a count target.

### 6.3 Required deletion evidence

Deletion review must account for:

- static Swift references;
- Xcode target membership;
- App Intents and shortcut discovery;
- SwiftData model registration and migration use;
- Objective-C/runtime or reflection-based discovery;
- Widget and share-extension use;
- previews, fixtures, snapshot catalogs, and generated source;
- scripts and machine-readable registries;
- persistence compatibility and replay/migration requirements;
- current focused and integration tests.

A zero-result `rg` search is supporting evidence only.

### 6.4 Suffix and file-size debt

Numbered suffix files and files over the hard line cap are review inputs, not automatic deletion targets. Each extraction slice should collapse arbitrary fragments when one authority is easier to understand and compile as a coherent unit, while preserving legitimate focused extensions where consolidation would create a larger mixed-responsibility file.

No new `+02`, `+03`, or `+04` file and no new broad `Models.swift` file is allowed.

## 7. API and dependency discipline

- Declarations are `internal` by default.
- A declaration becomes `public` only when a named downstream target requires it.
- Every public declaration has a documented consumer and appropriate tests.
- Cross-module protocols live with the consumer-facing contract, not an arbitrary shared bucket.
- Runtime mutation authority remains under `Core/LocalRuntimeOS/`.
- Adapters do not become canonical mutation owners.
- UI modules consume projections and commands; they do not gain persistence authority.
- Test-only conveniences do not enter production APIs.
- `@testable import` may support module-local tests but does not justify broad production visibility.
- Dependency cycles fail the structural gate.

## 8. Development workflow

### 8.1 Stable cache identity

All retained build scripts use one repository-local DerivedData path:

```text
.codex/DerivedData/Ambitions
```

Do not create a fresh DerivedData directory per repair attempt. A clean build must be an explicit benchmark or repair action, not the default response to a compiler or test failure.

### 8.2 Single active lane

Before starting Xcode work, retained scripts verify that no other `xcodebuild`, `xctest`, or Ambitions test runner owns the lane. Concurrent independent builds against the same package/cache are rejected or serialized.

### 8.3 Build once, test repeatedly

The normal focused loop is:

1. Regenerate only when `scripts/ambitions-xcodegen-needed.sh` proves it is necessary.
2. Run one incremental `build-for-testing` after source changes.
3. Run focused `test-without-building` repeatedly until source changes again.
4. Run broader tests only at the risk-appropriate closeout gate.

### 8.4 Package resolution

Retained local commands use `-disableAutomaticPackageResolution` and `-skipPackageUpdates` after the package graph is known, while a distinct dependency-refresh lane performs deliberate resolution and records the lock state. No command may silently change dependency versions during a focused test loop.

## 9. Performance measurement design

### 9.1 Environment declaration

Every retained build-throughput result records:

- commit SHA and dirty-worktree state;
- macOS and Xcode version;
- SDK and simulator architecture;
- CPU count and memory;
- package graph identity;
- DerivedData path and warm/cold state;
- command, exit code, and raw log;
- source change class;
- wall time and Xcode timing summary;
- active competing build processes.

### 9.2 Benchmark scenarios

The benchmark suite measures:

1. project/package startup with `xcodebuild -list`;
2. no-change build-for-testing;
3. focused test-without-building;
4. one leaf-module implementation edit;
5. one surface implementation edit;
6. one runtime-contract implementation edit;
7. one test-only edit;
8. clean AmbitionsUnitTests build-for-testing;
9. full required closeout build/test lane.

Each scenario runs enough times to report median and worst observed result on the current constrained VM. Cold and warm results are not mixed.

### 9.3 Binding candidate thresholds

All numeric thresholds and cohort-size requirements that can authorize a future module live only in `docs/qa/architecture/module-candidate-policy.json`. This design names the required benchmark scenarios and evidence shape but does not duplicate their numeric values. A policy miss blocks module authorization; it does not imply product or release failure.

## 10. Quality and acceptance gates

Every implementation slice must include:

- laws and canonical source owners touched;
- package/module edges added or removed;
- files deleted, consolidated, moved, or retained;
- public API delta;
- compatibility shim inventory and removal target;
- XcodeGen regeneration proof;
- package description/resolution proof where applicable;
- dependency-cycle audit;
- module-local tests;
- affected runtime/integration tests;
- focused build/test evidence;
- governance, architecture, and accepted-Yellow audits;
- `git diff --check`;
- independent code/architecture review;
- before/after benchmark artifacts;
- rollback instructions;
- explicit unsupported claims.

Relocation or decomposition does not pass merely because files exist or the project compiles. Required behavior tests must remain executable and passing for the affected scope.

## 11. Migration sequence and commit boundaries

### Prerequisite — clean active source slice

Finish validation, independent review repair, and bounded commit of the currently dirty Today Task 6 slice. Module work must not begin while overlapping Core and Today source is uncommitted.

### Slice 1 — baseline and package relocation

- Capture canonical root-package startup and stable-cache build baselines.
- Reconfirm `ADR-BUILD-001` against the implementation-start commit and current environment.
- Relocate the existing design-system package without behavior changes.
- Update `project.yml`, scripts, and current build docs.
- Regenerate and validate.
- Commit separately with before/after startup proof.

### Slice 2 — measurement and dependency enforcement

- Extend retained benchmark tooling with the declared scenarios and environment metadata.
- Add a machine-readable build-module dependency graph or extend the current constitutional dependency registry without conflating product opportunities with build edges.
- Add cycle, target-membership, package-root, and public-API checks.
- Establish stable cache and single-lane guards.

### Slice 3 — source disposition and first destruction wave

- Produce a current working disposition ledger from live source.
- Delete globally proven historical and duplicate source.
- Preserve unknown or dynamically referenced source until stronger proof exists.
- Run affected behavior and migration/replay tests.

### Slice 4 — leaf-module pilot

- Correct Core-to-UI dependency direction for the pilot scope.
- Extract the smallest high-value acyclic leaf.
- Verify resources, test discovery, imports, linking, and runtime behavior.
- Benchmark leaf edit, no-change build, clean build, and focused tests.
- Continue only if quality remains intact and the boundary is neutral or beneficial for throughput.

### Slice 5 — policy-authorized dependency-closed cohorts

- Evaluate explicit source cohorts with `scripts/ambitions-module-candidate-gate.py` and the single policy authority.
- Compile the exact candidate source set with only declared lower/system dependencies before any target proposal.
- Reject folder-shaped candidates that require reverse edges, duplicate membership, broad public API, incomplete routes, or self-asserted proof.
- Extract only a candidate whose status is `authorized`; an `observed` or `rejected` record cannot justify source, target, or project changes.
- Delete duplicate authority during each extraction.
- Keep the runtime law and canonical source owners intact.
- Require a reviewed commit after each independently provable boundary.

### Slice 6 — final destruction and regression proof

- Remove temporary migration shims.
- Remove orphan target membership, adapters, imports, and public declarations.
- Run full dependency, governance, build, test, and benchmark gates.
- Reconcile implementation truth inventory if major source architecture changed.

## 12. Failure handling and rollback

- Each slice is a bounded commit and can be reverted independently.
- No mass move and behavior change share a commit.
- A failed module pilot is reverted rather than patched through with broad public APIs.
- A boundary producing cycles is redesigned before further extraction.
- A boundary producing a material clean or incremental build regression is combined, reordered, or reverted unless required for stronger architecture correctness and explicitly owner-approved.
- Temporary shims contain no product, runtime, projection, trust, or motion authority and have a named removal slice.
- Existing persistence schemas and runtime event identities do not change solely for module relocation.
- Generated `.xcodeproj` state is regenerated from `project.yml`; it is never treated as rollback authority.

## 13. Proof ceiling and non-claims

This design plus current artifacts proves only the implemented foundation and the active decision policy.

It does not prove:

- broader decomposition is implemented;
- a future module candidate is dependency-closed or beneficial;
- source destruction is safe or complete;
- build or test success;
- the provisional performance targets are achieved outside the specifically measured warm lanes;
- clean-build speed on other machines;
- CI, device, accessibility, visual, privacy/legal, TestFlight, App Store, or release readiness.

Those claims require the current implementation and proof artifacts defined above.

## 14. Design acceptance

Owner-approved direction:

- structural package relocation;
- balanced module decomposition only for measured high-churn, compiler-closed cohorts;
- evidence-backed destruction before, during, and after decomposition;
- speed improvements without lowering the existing code-quality and proof standards;
- whole-folder Domain extraction is not a focused-test prerequisite;
- cache-invalidated build cost remains a separate optimization from the already-fast warm loop.
