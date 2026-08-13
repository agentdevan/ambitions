# Evaluation-Only Implementation Tasks

> These tasks are grooming, not execution authority. Each task must be completed
> and verified independently when Devan separately hands this package to Codex.
> Every task inherits the approved Design isolation contract: no dependency,
> source, resource, build-phase, composition-root, or archive edge may be added
> from any shipping app, extension, production package, or release target to
> `tools/ambitions-intelligence-evaluation/`.

## Global execution rules

- Work only in `tools/ambitions-intelligence-evaluation/` except for the final
  redacted QA evidence packet named by Task 20. Do not modify Research, Scope,
  Design, canon, `Native/Ambitions/`, `Packages/`, root `project.yml`, shipping
  schemes, or release resources.
- Use synthetic/canonical fixtures only. Do not mount, read, copy, export, or
  infer from production user stores or correction data.
- The matrix is deterministic, `NLEmbedding`, Arctic XS, BGE Small EN v1.5,
  MiniLM L6 v2, conditional mxbai, and separate Core Spotlight only.
- No model conversion or task execution begins merely because these documents
  exist.
- Every task begins by running `Scripts/check_isolation.py` once available and
  ends with it passing. A discovered need for a production edge stops the task
  and returns to Design.
- Research performance figures are experimental comparison points only and
  cannot become acceptance or release thresholds.

Use these exact roots and commands throughout:

```bash
evaluation_root=tools/ambitions-intelligence-evaluation
python3 "$evaluation_root/Scripts/check_isolation.py"
xcodegen generate --spec "$evaluation_root/BenchmarkHost/project.yml" --project "$evaluation_root/BenchmarkHost/Generated"
xcodebuild -project "$evaluation_root/BenchmarkHost/Generated/AmbitionsIntelligenceEvaluationBenchmarkHost.xcodeproj" -scheme AmbitionsIntelligenceEvaluationBenchmarkHost -configuration Release -destination "id=$AMB_EVAL_DEVICE_ID" test
```

Focused Swift tests use SwiftPM's `--filter` option with the concrete test types
named in each task.
`AMB_EVAL_DEVICE_ID` must be a validated connected device identifier before a
physical-device command runs.

1. **Create the isolated evaluation package, schemas, and graph guard.**
   Files: create `tools/ambitions-intelligence-evaluation/Package.swift`,
   `README.md`, `.gitignore`, the four `Schemas/*.schema.json` files,
   `Sources/AmbitionsIntelligenceEvaluationContracts/EvaluationIdentity.swift`,
   `EvaluationModels.swift`, `EvaluationProvider.swift`,
   `EvaluationResults.swift`,
   `Tests/AmbitionsIntelligenceEvaluationContractsTests/EvaluationIdentityTests.swift`,
   `EvaluationProviderBoundaryTests.swift`, `EvaluationSchemaTests.swift`, and
   `Scripts/check_isolation.py`.
   Dependencies: none. Trace: `REQ-002`, `REQ-011`, `REQ-013`, `REQ-014`,
   `REQ-018`, `REQ-024`, `REQ-027`; Design “Framework-neutral computation contracts,”
   “Initial physical boundary,” and “Evaluation isolation contract.” Acceptance:
   the package exposes only evaluation value types/provider reads, builds on
   macOS 15 and iOS 26, has no product/network/write API, and the graph checker
   proves no reverse shipping edge, root project entry, archive copy, or release
   resource. Tests/checks: `swift test --package-path
   tools/ambitions-intelligence-evaluation --filter
   AmbitionsIntelligenceEvaluationContractsTests`; run `python3
   tools/ambitions-intelligence-evaluation/Scripts/check_isolation.py` and
   `git diff --check`. Environment: macOS. Frontend: none — evaluation-only,
   non-shipping. Shipping dependency introduction: prohibited.

2. **Implement immutable suite/run identity and atomic reporting primitives.**
   Files: create `Sources/AmbitionsIntelligenceEvaluationCore/SuiteLoader.swift`,
   `ReportWriter.swift`, `Manifests/suite-v1.json`, and
   `Tests/AmbitionsIntelligenceEvaluationCoreTests/SuiteIdentityTests.swift` and
   `ReportWriterTests.swift`. Dependencies: Task 1. Trace: `REQ-013`, `REQ-014`,
   `REQ-020`, `REQ-022`; Design “Evaluation architecture,” “Persistence,
   migrations, concurrency, and replay,” and “Evidence handoff.” Acceptance:
   canonical JSON digests bind fixtures, arms, provider/preprocessing,
   conversion/precision, code/build, OS/device, scale, seed, calibration/fusion,
   and evidence dimensions; partial output is explicitly invalid; writes are
   atomic; the report permits no-winner. Tests/checks: focused `swift test`
   filters for both files, schema validation of `suite-v1.json`, isolation check,
   and `git diff --check`. Environment: macOS. Frontend: none — evaluation-only,
   non-shipping. Shipping dependency introduction: prohibited.

3. **Create the canonical synthetic fixture release.**
   Files: create `Fixtures/v1/manifest.json`, `search-corpus.jsonl`,
   `search-judgments.jsonl`, `capture-corpus.jsonl`,
   `capture-judgments.jsonl`, `mutation-canaries.json`,
   `privacy-canaries.json`, `spotlight-policy.json`, `reference-texts.jsonl`, plus
   `Tests/AmbitionsIntelligenceEvaluationCoreTests/FixtureReleaseTests.swift`.
   Dependencies: Tasks 1–2. Trace: `REQ-003`–`REQ-009`, `REQ-013`, `REQ-014`,
   `REQ-018`, `REQ-019`; Design “Fixtures and test authority,” Search/Capture
   boundaries, and quality/safety partitions. Acceptance: deterministic English
   tuning/holdout partitions cover all named Search/Capture, privacy, deletion,
   staleness, family, action, ambiguity, correction, and unsafe-assumption slices;
   every file is digest-bound; no real person/content or production identifier is
   present. Tests/checks: fixture schema/digest/partition/leak/coverage tests and
   two identical regenerations produce byte-identical output. Environment:
   macOS. Frontend: none — fixture data only. Shipping dependency introduction: prohibited.

4. **Implement mutation and privacy/egress canaries.**
   Files: create `Sources/AmbitionsIntelligenceEvaluationCore/MutationCanaries.swift`,
   `PrivacyCanaries.swift`,
   `Tests/AmbitionsIntelligenceEvaluationCoreTests/MutationCanaryTests.swift`,
   `PrivacyCanaryTests.swift`, and
   `Scripts/inspect_run.py`. Dependencies: Tasks 1–3. Trace: `REQ-001`,
   `REQ-002`, `REQ-004`, `REQ-007`, `REQ-014`, `REQ-018`, `REQ-019`; Design
   “Authority topology,” “Evaluation isolation contract,” and privacy proof.
   Acceptance: canaries hard-fail attempted Event/Projection/Receipt/Capture/
   Goal/Step/correction/Search-action writes, production-path access, network
   creation, content-bearing logs/reports, unauthorized Spotlight donation, and
   authority claims. Tests/checks: each prohibited capability has a failing
   injected test; a clean synthetic run passes; isolation checker passes.
   Environment: macOS and simulator for platform hooks. Frontend: none —
   evaluation-only. Shipping dependency introduction: prohibited.

5. **Implement and lock the deterministic Search/Capture baseline.**
   Files: create
   `Sources/AmbitionsIntelligenceEvaluationDeterministic/DeterministicSearchAdapter.swift`,
   `DeterministicCaptureAdapter.swift`,
   `Tests/AmbitionsIntelligenceEvaluationDeterministicTests/DeterministicSearchAdapterTests.swift`,
   `DeterministicCaptureAdapterTests.swift`, `FixtureOracleParityTests.swift`,
   `Fixtures/v1/deterministic-search-oracle.jsonl`,
   `deterministic-capture-oracle.jsonl`, and
   `Manifests/providers/deterministic.json`. Dependencies: Tasks 1–4.
   Trace: `REQ-001`, `REQ-003`–`REQ-008`, `REQ-013`, `REQ-014`; Design
   “Deterministic baseline,” Search/Capture integration boundaries. Acceptance:
   fixture-side behavior matches golden outputs from current `FTSIndex`,
   `ResultRanker`, `SemanticLocalIndex`, `SearchActionValidator`, and
   `CaptureClassifier` focused tests; source hashes are recorded; baseline
   abstains/needs-triage where current rules do and writes nothing. Tests/checks:
   package deterministic tests plus focused current
   `SearchTests`, `RuntimeCanonicalSearchTests`, and `CaptureRoutingTests`; any
   source-hash drift invalidates rather than silently refreshing the oracle.
   Environment: macOS package tests and iOS simulator for current focused tests.
   Frontend: none — baseline adapter only. Shipping dependency introduction: prohibited.

6. **Implement the `NLEmbedding` evaluation adapter.**
   Files: create
   `Sources/AmbitionsIntelligenceEvaluationNaturalLanguage/NLEmbeddingAdapter.swift`,
   `Tests/AmbitionsIntelligenceEvaluationNaturalLanguageTests/NLEmbeddingAdapterTests.swift`,
   `NLEmbeddingAvailabilityTests.swift`, and
   `Manifests/providers/nlembedding.json`. Dependencies: Tasks 1–4. Trace:
   `REQ-009`, `REQ-010`, `REQ-013`, `REQ-014`, `REQ-016`, `REQ-021`, `REQ-027`;
   Design “Provider boundary.” Acceptance: local English sentence embedding,
   dimension, resolved OS/language revision evidence, normalization experiment,
   cancellation, and abstention/unavailability are typed; no assets, network,
   account, or product fallback behavior is introduced. Tests/checks: focused
   package tests on macOS and simulator, airplane-mode device case later bound to
   Task 17. Environment: macOS, simulator, physical iPhone for final runtime.
   Frontend: none — evaluation adapter. Shipping dependency introduction: prohibited.

7. **Build the shared offline conversion and reference-validation lane.**
   Files: create every `Conversion/*` file named in `plan.md`,
   `Sources/AmbitionsIntelligenceEvaluationCoreML/CoreMLCandidateAdapter.swift`,
   `ValidatedTokenizer.swift`,
   `Tests/AmbitionsIntelligenceEvaluationCoreMLTests/CoreMLCandidateAdapterTests.swift`,
   `ValidatedTokenizerTests.swift`, `InvalidConversionQuarantineTests.swift`,
   `Manifests/security/conversion-policy.json`, `Scripts/check_provenance.py`,
   and `Scripts/collect_archive_sizes.py`. Dependencies:
   Tasks 1–4. Trace: `REQ-011`, `REQ-013`, `REQ-014`, `REQ-016`, `REQ-020`;
   Design “External Core ML candidates,” conversion/provenance proof. Acceptance:
   locked tools; immutable local inputs only; allowlisted safetensors/JSON/text;
   rejection of mutable revision, remote code, pickle, unknown executable,
   unpinned or escaping paths; tokenizer/mask/truncation/prompt/pooling/
   normalization/dimension/vector/precision comparison; invalid conversion
   quarantine. Tests/checks: `python3 -m unittest discover -s
   tools/ambitions-intelligence-evaluation/Conversion/tests -p 'test_*.py'`,
   focused Core ML Swift tests with synthetic tiny fixtures, isolation check.
   Environment: macOS; no candidate conversion yet. Frontend: none — offline
   conversion tooling. Shipping dependency introduction: prohibited.

8. **Convert and validate Snowflake Arctic Embed XS independently.**
   Files: complete `Manifests/providers/arctic-xs.json`; create
   `Manifests/licenses/arctic-xs-LICENSE.txt`, `arctic-xs-NOTICE.txt`,
   `Manifests/security/arctic-xs.json`, and
   `Tests/AmbitionsIntelligenceEvaluationCoreMLTests/ArcticXSReferenceTests.swift`;
   generate ignored `Artifacts/arctic-xs/{inputs,converted,compiled}/` and
   `Runs/arctic-xs/reference-validation.json`. Dependencies: Task 7. Trace: `REQ-011`, `REQ-013`,
   `REQ-014`, `REQ-020`, `REQ-022`; Design closed matrix and conversion proof.
   Acceptance: exact reviewed checkpoint/files/hashes and converter identity;
   tokenizer, query prefix, 512-token truncation, CLS pooling, normalization,
   384 dimensions, reference vectors, and tested precision variants validated;
   invalid variants quarantined. Tests/checks: Arctic-only converter and Swift
   reference tests, provenance/security checks, offline load test, isolation
   check. Environment: macOS then simulator/device functional load. Frontend:
   none — evaluation asset only. Shipping dependency introduction: prohibited.

9. **Convert and validate BGE Small EN v1.5 independently.**
   Files: complete `Manifests/providers/bge-small-en-v1.5.json`; create
   `Manifests/licenses/bge-small-en-v1.5-LICENSE.txt`,
   `bge-small-en-v1.5-NOTICE.txt`, `Manifests/security/bge-small-en-v1.5.json`,
   and `Tests/AmbitionsIntelligenceEvaluationCoreMLTests/BGESmallReferenceTests.swift`;
   generate ignored `Artifacts/bge-small-en-v1.5/{inputs,converted,compiled}/`
   and `Runs/bge-small-en-v1.5/reference-validation.json`. Dependencies:
   Task 7. Trace: `REQ-011`, `REQ-013`, `REQ-014`, `REQ-020`, `REQ-022`;
   Design closed matrix and conversion proof. Acceptance: exact checkpoint/files/hashes;
   tokenizer, optional retrieval prompt experiment identity, truncation, CLS
   pooling, normalization, 384 dimensions, reference vectors, clustered-score
   calibration warning, and precision variants validated; invalid variants
   quarantined. Tests/checks: BGE-only reference/conversion/offline/isolation
   checks. Environment: macOS then simulator/device functional load. Frontend:
   none — evaluation asset only. Shipping dependency introduction: prohibited.

10. **Convert and validate all-MiniLM-L6-v2 independently.**
    Files: complete `Manifests/providers/minilm-l6-v2.json`; create
    `Manifests/licenses/minilm-l6-v2-LICENSE.txt`, `minilm-l6-v2-NOTICE.txt`,
    `Manifests/security/minilm-l6-v2.json`, and
    `Tests/AmbitionsIntelligenceEvaluationCoreMLTests/MiniLML6V2ReferenceTests.swift`;
    generate ignored `Artifacts/minilm-l6-v2/{inputs,converted,compiled}/` and
    `Runs/minilm-l6-v2/reference-validation.json`. Dependencies: Task 7.
    Trace: `REQ-011`, `REQ-013`, `REQ-014`, `REQ-020`, `REQ-022`;
    Design closed matrix and conversion proof. Acceptance: exact checkpoint/files/hashes; WordPiece,
    declared 256-wordpiece behavior, attention-mask mean pooling, normalization,
    384 dimensions, reference vectors, and precision variants validated; invalid
    variants quarantined. Tests/checks: MiniLM-only reference/conversion/offline/
    isolation checks. Environment: macOS then simulator/device functional load.
    Frontend: none — evaluation asset only. Shipping dependency introduction: prohibited.

11. **Decide conditional mxbai admission without expanding the tranche.**
    Files: complete `Manifests/providers/mxbai-xsmall-conditional.json` and create
    `Reports/mxbai-admission.json` only during execution; create
    `Tests/AmbitionsIntelligenceEvaluationCoreMLTests/MXBaiAdmissionTests.swift`;
    if admitted, create `Manifests/licenses/mxbai-xsmall-LICENSE.txt`,
    `mxbai-xsmall-NOTICE.txt`, `Manifests/security/mxbai-xsmall.json`, and
    generate ignored `Artifacts/mxbai-xsmall/` and
    `Runs/mxbai-xsmall/reference-validation.json`—no new target, framework,
    corpus, milestone, or schema. Dependencies: Tasks 7–10. Trace:
    `REQ-011`, `REQ-013`, `REQ-014`; Design “Conditional mxbai admission.”
    Acceptance: every approved low-cost condition is explicitly true or mxbai is
    recorded `excluded_by_scope` and no assets are acquired. Tests/checks:
    admission schema/policy test and isolation check; admitted path must pass the
    same reference suite with no new architecture. Environment: macOS; optional
    device only if admitted. Frontend: none — admission gate. Shipping dependency introduction: prohibited.

12. **Implement Search quality, safety, hydration, and stability evaluation.**
    Files: create `Sources/AmbitionsIntelligenceEvaluationCore/SearchEvaluationHarness.swift`,
    `Metrics.swift`, `QualityRunner.swift`,
    `Tests/AmbitionsIntelligenceEvaluationCoreTests/SearchEvaluationHarnessTests.swift`,
    `SearchMetricsTests.swift`, `SearchSafetyTests.swift`, and
    `SearchStabilityTests.swift`. Dependencies: Tasks
    3–11. Trace: `REQ-003`–`REQ-005`, `REQ-010`–`REQ-014`, `REQ-018`, `REQ-019`;
    Design Search harness and quality proof. Acceptance: identical arm partitions;
    exact/prefix preservation, paraphrase/zero-overlap, hard negatives, related
    objects, duplicates, Goal relevance, Recall@K/MRR/NDCG, privacy/family/
    local-only/deleted/tombstoned/stale handling, fixture hydration, pure action
    revalidation, and stability reported; holdout isolated; Core Spotlight not
    silently combined. Tests/checks: metric golden tests, all hard-failure cases,
    repeated-run byte stability, package Search suite. Environment: macOS;
    platform arms also simulator/device. Frontend: none — evaluation harness.
    Shipping dependency introduction: prohibited.

13. **Implement Capture quality, calibration, and abstention evaluation.**
    Files: create `Sources/AmbitionsIntelligenceEvaluationCore/CaptureEvaluationHarness.swift`,
    `Tests/AmbitionsIntelligenceEvaluationCoreTests/CaptureEvaluationHarnessTests.swift`,
    `CaptureMetricsTests.swift`, `CaptureCalibrationTests.swift`, and
    `CaptureAbstentionTests.swift`. Dependencies: Tasks 3–11. Trace: `REQ-006`–`REQ-011`, `REQ-013`,
    `REQ-014`; Design Capture harness and quality proof. Acceptance: route
    evidence, per-class precision/recall/F1, duplicates, Goal association/no-
    association, ambiguity, calibration, risk-coverage, abstention, selective
    accuracy, correction, useful coverage, unsafe assumptions, and deterministic
    precedence are reported; no route/correction is persisted or auto-accepted.
    Tests/checks: confusion/calibration/risk-coverage golden tests, abstention and
    zero-mutation canaries, repeated-run stability. Environment: macOS and
    simulator/device for platform arms. Frontend: none — evaluation harness.
    Shipping dependency introduction: prohibited.

14. **Measure exact scanning at 1K, 10K, and supported 100K scales.**
    Files: create `Sources/AmbitionsIntelligenceEvaluationCore/ScaleCorpusGenerator.swift`,
    `ExactVectorScanner.swift`,
    `Tests/AmbitionsIntelligenceEvaluationCoreTests/ScaleCorpusGeneratorTests.swift`,
    `ExactVectorScannerTests.swift`, `ExactScanCancellationTests.swift`, and
    ignored `Runs/scale/{1000,10000,100000}/`. Dependencies: Tasks 2–4 and at
    least one valid embedding arm; full comparison follows Tasks 8–10. Trace:
    `REQ-013`, `REQ-019`, `REQ-021`, `REQ-022`; Design scale rule. Acceptance:
    deterministic scale digests; exact correctness; build/incremental throughput,
    vector/metadata/staged/high-water bytes, latency distribution, memory, and
    cancellation measured separately; disposable row-major format explicitly
    nonprecedential. Tests/checks: deterministic generation, brute-force oracle,
    cancellation, corruption, and scale smoke tests; real-device measurement in
    Task 17. Environment: macOS, simulator functional, physical iPhone runtime.
    Frontend: none — scale experiment. Shipping dependency introduction: prohibited.

15. **Run the ANN admission gate; implement only if exact scan is insufficient.**
    Files: first create only ignored `Reports/ann-admission.json`. If and only if
    the approved trigger is demonstrated, create
    `Sources/AmbitionsIntelligenceEvaluationANN/DisposableANNIndex.swift` and
    `Tests/AmbitionsIntelligenceEvaluationANNTests/DisposableANNIndexTests.swift`
    without changing production files or contracts. Dependencies:
    Task 14 physical-device evidence. Trace: `REQ-013`, `REQ-014`, `REQ-022`;
    Design exact-first ANN condition. Acceptance: absent trigger yields
    `not_triggered` and no ANN source target; a triggered comparison names failing
    scale/device/distribution/question and remains disposable/nonselective.
    Tests/checks: policy test asserts no ANN target before trigger; if triggered,
    compare recall, latency, memory, storage, build/update, cancellation, and
    corruption against exact scan. Environment: macOS and the triggering physical
    device. Frontend: none — conditional evaluation experiment. Shipping dependency introduction: prohibited.

16. **Implement the isolated Core Spotlight evaluation arm.**
    Files: create `BenchmarkHost/project.yml`, `Sources/BenchmarkApp.swift`,
    `BenchmarkCoordinator.swift`, `BenchmarkScenario.swift`,
    `BenchmarkSignposts.swift`, `CoreSpotlightEvaluationArm.swift`,
    `ResourcePressureController.swift`,
    `Tests/CoreSpotlightIsolationTests.swift`, and
    `CoreSpotlightPolicyTests.swift`. Dependencies: Tasks 1–4 and 12. Trace: `REQ-004`,
    `REQ-012`–`REQ-014`, `REQ-018`, `REQ-019`, `REQ-023`, `REQ-024`, `REQ-027`; Design Core
    Spotlight isolation. Acceptance: unique run domain/index and test-only IDs;
    only authorized synthetic fixtures donated; no production ID/content/store;
    returned candidates undergo canonical-fixture privacy/identity/family/
    deletion/tombstone/staleness validation; cleanup on success/failure/cancel/
    relaunch; separately labelled results. Tests/checks: XcodeGen host generation,
    simulator isolation/donation/suppression/teardown/recovery tests, post-run
    query confirms domain empty, graph/archive isolation check. Environment:
    simulator and physical iPhone. Frontend: none — test-only host with no product
    surface. Shipping dependency introduction: prohibited.

17. **Implement offline, asset, cancellation, lifecycle, and pressure matrix.**
    Files: complete `BenchmarkHost/Sources/BenchmarkCoordinator.swift`,
    `BenchmarkScenario.swift`, `ResourcePressureController.swift`; create
    `BenchmarkHost/Tests/BenchmarkCoordinatorTests.swift`,
    `OfflineFailureMatrixTests.swift`, and
    `Manifests/offline-failure-matrix-v1.json`. Dependencies: Tasks 5–16 as applicable. Trace: `REQ-001`,
    `REQ-010`, `REQ-013`, `REQ-014`, `REQ-016`, `REQ-017`, `REQ-020`, `REQ-021`,
    `REQ-023`, `REQ-027`; Design provider/asset/lifecycle recovery. Acceptance:
    airplane mode; absent/never-acquired/interrupted/missing/corrupt/incompatible/
    revoked/reclaimed asset; cancellation; memory warning/pressure; protected-data
    state; foreground/background; expiration; crash/relaunch; and Spotlight
    recovery leave deterministic runs available, partial runs invalid, and
    canonical state impossible. Tests/checks: focused scenario tests plus recorded
    simulator and physical-device matrix; no blind sleeps/retry-to-pass.
    Environment: macOS for pure injection, simulator, physical iPhone. Frontend:
    none — evaluation host states only. Shipping dependency introduction: prohibited.

18. **Complete provenance, license, NOTICE, and security evidence.**
    Files: complete every candidate license/NOTICE and security file named by
    Tasks 8–11 plus `Manifests/security/nlembedding.json`,
    `core-spotlight.json`, `Scripts/check_provenance.py`, and
    `Scripts/collect_archive_sizes.py`; create
    `Conversion/tests/test_provenance_security.py`.
    Dependencies: Tasks 7–11 and 16. Trace: `REQ-013`, `REQ-014`, `REQ-016`,
    `REQ-018`, `REQ-020`; Design provenance/supply-chain proof. Acceptance: every
    arm binds immutable origin/revision/files/hashes/toolchain/compiled hash,
    license/NOTICE/commercial-use review, scan/revocation; runtime Hub/account/
    token/network absent; remote code, pickle, unknown executable, and unreviewed
    downloads rejected; archive/install evidence proves no shipping copy.
    Tests/checks: provenance/security negative fixtures, offline rerun, dependency
    scan, archive inspection, license inventory review. Environment: macOS and
    produced simulator/device archives. Frontend: none — manifests and audits.
    Shipping dependency introduction: prohibited.

19. **Measure Release-build runtime, memory, storage, energy, thermal, and Low Power Mode.**
    Files: complete `BenchmarkHost/Sources/BenchmarkApp.swift` and
    `BenchmarkSignposts.swift`; create
    `BenchmarkHost/Tests/BenchmarkSignpostsTests.swift`,
    `PhysicalDeviceRunManifestTests.swift`,
    `Manifests/physical-device-matrix-v1.json`; generate ignored
    `Runs/devices/` and `Artifacts/instruments/`. Dependencies:
    Tasks 6, 8–10, 12–18; Task 11 only if admitted. Trace: `REQ-013`, `REQ-014`,
    `REQ-021`, `REQ-022`, `REQ-027`; Design physical-device protocol. Acceptance:
    oldest iOS 26 class (iPhone 11, SE-class when practical), middle non-Pro
    (iPhone 14/15), and current Pro class cover phase-separated cold/warm load,
    tokenization, inference, build/incremental, exact scan, fusion/hydration,
    cancellation, peak/high-water memory, storage/archive, compute placement,
    energy, thermal, Low Power Mode, lifecycle, and scales; simulator results are
    labelled functional only. Tests/checks: Release host build, signpost interval
    completeness, repeated randomized/cooldown device runs, Instruments/Power
    Profiler attachment digests, no invented percentage or unlabeled hypothesis.
    Environment: physical iPhones; simulator only for host functionality.
    Frontend: none — non-shipping benchmark host. Shipping dependency introduction: prohibited.

20. **Synthesize the eleven-question report, dispose artifacts, and hand off evidence.**
    Files: create `Scripts/synthesize_report.py`, `Scripts/cleanup.py`,
    `Scripts/tests/test_synthesize_report.py`, and `test_cleanup.py`; emit ignored
    report during execution and, after review, one
    redacted packet at
    `docs/qa/evidence/ambitions-private-semantic-intelligence-evaluation-v1/`
    containing
    report JSON/Markdown, manifest, aggregate metrics, hard failures, limitations,
    provenance/license inventory, device summaries, and attachment digests—not
    models, vectors, fixture text, or private content. Dependencies: Tasks 1–19,
    with Tasks 11 and 15 conditionally skipped by policy. Trace: all `REQ-001`
    through `REQ-027`—including the evaluation N/A/deferred proof for `REQ-024`
    and `REQ-025`—especially `REQ-013`–`REQ-015`;
    Design “Evidence handoff and Design amendment gate.” Acceptance: all eleven
    questions answered; each arm and “no external model” remain possible; shared-
    embedding ceiling, size/distribution data, hard disqualifiers, uncertainty,
    experimental Research comparison labels, and IQSE handoff present; Spotlight,
    assets, compiled caches, vector stores, builds, and partial runs removed;
    Design remains unchanged pending amendment. Tests/checks: report schema/
    completeness/bias/redaction tests, cleanup idempotence and failure recovery,
    post-clean isolation/Spotlight/no-asset scans, product-doc check, `git diff
    --check`. Environment: macOS plus verification of device artifacts. Frontend:
    none — evidence handoff only. Shipping dependency introduction: prohibited.

## Task trace summary

| Evidence phase | Tasks |
|---|---|
| Isolation, contracts, identity, fixtures, canaries | 1–4 |
| Baselines and candidate fidelity | 5–11 |
| Search/Capture quality and scale | 12–15 |
| Spotlight, failure/offline, provenance | 16–18 |
| Physical-device measurement and handoff | 19–20 |

Every `REQ-013` question is closed by at least one task: Search quality (12),
Search safety (4, 12, 16), Capture quality (13), shared-embedding ceiling
(12–13, 20), conversion fidelity (7–11), runtime (17, 19), scale (14–15, 19),
failure/offline (17), storage/distribution (14, 18–20), provenance/licensing
(7–11, 18), and decision result (20).
