# Ambitions Build Architecture and Throughput Design

Status: Owner-approved implementation direction
Date: 2026-07-10
Decision record: `ADR-BUILD-001`
Scope: Xcode/Swift package startup, module decomposition, evidence-backed source destruction, build workflow, and development-throughput proof
Claim status: Aspirational until source changes and current measurements prove each implemented slice

## 1. Purpose

Ambitions needs a materially faster edit-build-test loop without weakening source ownership, runtime correctness, privacy, accessibility, deterministic testing, or proof honesty.

This work does not change product behavior. It preserves repo health so later work can improve:

```text
Intent -> Context -> Path -> Time Fit -> Reflow -> Action -> Proof -> Learning
```

The design has four linked parts:

1. Remove the repo-root Swift package scan.
2. Delete obsolete and duplicate source before it becomes module API.
3. Decompose the monolithic application into a balanced acyclic build graph.
4. Make build throughput a measured, regression-gated engineering property.

## 2. Evidence and problem statement

Current live evidence establishes:

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

### 5.3 Balanced target graph

The target graph should converge toward:

```text
AmbitionsDomain
  Core/Domain
  Core/Time

AmbitionsLanguage
  Language

AmbitionsRuntime
  Core/LocalRuntimeOS
  depends on AmbitionsDomain

AmbitionsProjection
  Projection
  depends on AmbitionsDomain and narrow runtime contracts

AmbitionsUIFoundation
  DesignSystem
  Interaction
  Rendering
  depends on AmbitionsDomain and AmbitionsLanguage where required

AmbitionsTrust
AmbitionsComposer
AmbitionsToday
AmbitionsGoals
AmbitionsTime
AmbitionsYou
  depend on the minimum required domain, runtime-contract,
  projection, language, and UI-foundation modules

AmbitionsStage
  Stage
  composes surface modules without owning their product policy

Ambitions
  App
  executable composition and dependency assembly only

AmbitionsTestSupport
  deterministic shared fixtures and test builders only
```

The dependency graph must be acyclic. Lower modules cannot import Stage, App, Composer, Trust, or Surfaces. `Core` imports of UI/design-system types must be removed through ownership correction or narrow domain contracts before Domain and Runtime extraction.

The graph intentionally avoids one target per folder or per concept. Too many targets increase module loading, linking, and API maintenance. New targets must earn their existence through ownership clarity and measured incremental-build improvement.

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

### 9.3 Provisional targets

These are design targets, not current performance claims:

| Scenario | Provisional target |
|---|---:|
| Project/package startup | ≤15 seconds |
| No-change focused invocation | ≤30 seconds |
| Focused test-without-building | ≤30 seconds |
| Leaf-module edit through focused proof | ≤60 seconds |
| Single-surface edit through focused proof | ≤90 seconds |
| Runtime edit through affected contract proof | ≤180 seconds |
| Clean unit-test build | At least 2× faster than measured pre-change baseline |

Absolute clean-build thresholds become binding only after the baseline and first decomposition pilot establish repeatable measurements. A result outside tolerance blocks the throughput claim; it does not imply product or release failure.

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

### Slice 5 — domain, runtime, projection, and UI foundations

- Extract low-level modules in dependency order.
- Delete duplicate authority during each extraction.
- Keep the runtime law and canonical source owners intact.
- Require a reviewed commit after each independently provable boundary.

### Slice 6 — Trust, Composer, and surface modules

- Extract Trust and Capture.
- Extract Today, Goals, Time, and You independently.
- Prove each surface still receives runtime projections and submits commands without gaining storage authority.

### Slice 7 — Stage and app composition

- Extract Stage after surfaces are stable.
- Reduce the app target to entry point, root scene, dependency assembly, feature flags, and platform composition.

### Slice 8 — final destruction and regression proof

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

This approved design proves only the intended approach.

It does not prove:

- package relocation is implemented;
- any module exists or is correctly wired;
- source destruction is safe or complete;
- build or test success;
- the provisional performance targets are achieved;
- clean-build speed on other machines;
- CI, device, accessibility, visual, privacy/legal, TestFlight, App Store, or release readiness.

Those claims require the current implementation and proof artifacts defined above.

## 14. Design acceptance

Owner-approved direction:

- structural package relocation;
- balanced module decomposition now rather than after all modernization;
- evidence-backed destruction before, during, and after decomposition;
- speed improvements without lowering the existing code-quality and proof standards;
- package relocation first, after the current dirty Today slice reaches a clean reviewed commit boundary.
