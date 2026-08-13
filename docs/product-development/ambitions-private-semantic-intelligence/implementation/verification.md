# Evaluation-Tranche Verification Contract

## Closure rule

The evaluation tranche closes only when every applicable item below has current,
reviewable evidence bound to an immutable suite/run identity. A skipped item must
be explicitly `not_applicable` with its approved reason. Missing, stale, partial,
simulator-substituted, or content-bearing evidence cannot be promoted to pass.

Hard failure in shipping isolation, canonical authority, deterministic
availability, privacy/egress, identity/action safety, deletion/staleness,
conversion validity, immutable provenance, or license/security disqualifies the
affected arm regardless of aggregate quality. The evaluation report grants no
production, release, or Design-amendment approval.

Product frontend and accessibility proof are N/A for this evaluation-only
tranche: it modifies no Search/Capture surface and creates no settings child.
The benchmark host is automation-only test infrastructure. Approved product
VoiceOver, Dynamic Type, focus, motion, and control requirements remain binding
on later production grooming after amended Design; this N/A cannot waive them.

## Structural isolation

Prove all of the following:

- all tranche code/assets are under `tools/ambitions-intelligence-evaluation/`
  except the final redacted non-production evidence packet;
- no shipping app, widget, share extension, app intent, production package,
  production test host, or release scheme depends on the evaluation package;
- root `project.yml`, `Native/Ambitions/`, `Packages/`, app composition roots,
  entitlements, copy phases, bundle resources, and archive configuration contain
  no evaluation path, product, model, tokenizer, fixture, vector, or report;
- the standalone benchmark host uses its own project, bundle identity, derived
  data, resources, and archive and is absent from release products;
- root package resolution and release archive contain no transitive evaluation
  dependency/resource; and
- module-candidate policy remains unchanged and the tool creates no production
  package-extraction precedent.

Required evidence: dependency graphs, root/tree path scan, Xcode build-setting
and copy-phase inspection, package dump, shipping archive file list/size report,
standalone-host archive list, `Scripts/check_isolation.py` output, and a three-
artifact product-doc checker pass.

## Canonical authority and mutation safety

Contract and injected-canary tests must prove no arm can:

- append an Event;
- mutate a Projection or canonical store;
- create a Receipt or History record;
- create/update/delete Capture, Goal, Step, deadline, dependency, priority, or
  placement state;
- write/read production correction state;
- validate, mint, authorize, or execute a production Search action;
- access production repositories, generation stores, command clients, or raw
  app paths; or
- create Search, Capture, persistence, runtime, delivery, package, or product
  authority.

The evaluation contracts must expose none of those capabilities. Baseline action
and hydration tests operate on fixture authority only. Focused existing Search
and Capture tests remain green as behavioral oracles and are not replaced.

## Matrix, fixture, and run identity

- Required arms are exactly deterministic, `NLEmbedding`, Arctic XS, BGE Small
  EN v1.5, and MiniLM L6 v2; no additional or generative/multilingual arm exists.
- mxbai is absent unless every low-incremental-cost condition has an affirmative
  immutable admission report; otherwise it is `excluded_by_scope` before asset
  acquisition.
- Core Spotlight is separately labelled, not merged into provider selection.
- Every fixture is synthetic/canonical, English-labelled, partitioned, digest-
  bound, source/privacy/revision/family annotated, and free of production IDs or
  user data.
- Tuning and holdout partitions are disjoint.
- Run identity binds suite/fixture/arm/provider/preprocessing/conversion/
  precision/runtime/OS/device/build/scale/seed/fusion/calibration/code digests.
- Interruption produces an invalid partial run; evidence from different
  identities is never combined silently.

## Search evidence

For each applicable arm and each declared Search slice, report raw denominators,
distributions, per-query redacted outcomes, aggregate metrics, confidence or
bootstrap intervals where used, failures, and limitations:

- exact title and strong-prefix preservation, including top-result preservation;
- lexical retrieval and zero-token-overlap paraphrase retrieval;
- related-but-irrelevant hard negatives and related-object discovery;
- duplicate/near-duplicate precision and recall;
- Goal relevance;
- Recall@1/3/5/10, MRR, and NDCG where graded relevance makes it useful;
- privacy, owner/family, and local-only filtering before and after return;
- deleted, tombstoned, stale-revision, source-generation, and changed-object
  handling;
- fixture-side canonical hydration/identity validation;
- pure action revalidation against active fixture revision and policy;
- deterministic exact/prefix precedence and no model-only action authority; and
- stable tie-breaking, repeatability, cancellation, and stale-query suppression.

Zero tolerance: privacy-ineligible/deleted/tombstoned result, fabricated identity,
stale action eligibility, deterministic blockage, canonical mutation, or fourth
Search authority.

## Capture evidence

For each applicable arm and declared Capture slice, report:

- route-prototype evidence for Step, Goal, and Needs a Place;
- per-class precision, recall, F1, and confusion matrix;
- duplicate precision/recall;
- Goal-association Recall@K/MRR and no-association precision;
- ambiguity/conflict recognition;
- calibration metric and risk-coverage curve;
- abstention rate, selective accuracy, and useful coverage;
- correction/change/none-of-these behavior;
- unsafe-assumption and auto-accept rates;
- deterministic classifier/date/explicit-input precedence;
- unsupported/mixed-language abstention; and
- stale-draft/evidence rejection after revision or cancellation.

Zero tolerance: semantic evidence persists/accepts a route, writes correction
state, creates a Goal/Step, overrides a hard deterministic fact, or becomes a
second Capture authority.

## Shared-embedding ceiling

The same provider identity and fixture release must be evaluated across Search
and Capture. The report must show whether one embedding provider materially
improves both at useful coverage without a classifier/LLM, including slice-level
regressions and device/storage burden. “Materially” is assessed transparently in
the amended Design; the tranche does not import a Research hypothesis as a
release threshold.

## External conversion fidelity

For Arctic, BGE, MiniLM, and admitted mxbai, verify:

- exact publisher, repository, immutable checkpoint revision, file allowlist,
  and SHA-256 for every input;
- exact converter/tokenizer/runtime versions and environment lock;
- tokenizer vocabulary/config hashes, token IDs, masks, special tokens, and
  attention behavior;
- truncation length and boundary cases;
- query/document prompting where applicable;
- pooling implementation and mask handling;
- normalization and similarity semantics;
- embedding dimension;
- representative reference vectors and similarity ordering;
- every measured compression/precision variant plus converted and compiled
  hashes; and
- quarantine of any variant beyond its predeclared numerical tolerance.

Quality/device results from a quarantined or unvalidated conversion are invalid.
Validation is evaluation-only and selects no production tokenizer, precision,
model, package, or delivery mechanism.

## Privacy, security, and provenance

Prove:

- the evaluation host has no access to live production stores, app groups,
  backups, correction ledgers, or private user files;
- no private content, query, Capture text, vector, raw score, content-bound
  candidate ID, fixture text, or diagnostic leaves the local evaluation context
  through network, logs, analytics, crash material, shared report, screenshot,
  clipboard, widget, Spotlight, or implicit export;
- no runtime Hugging Face/HTTP access, account, token, mutable revision,
  `trust_remote_code`, pickle-dependent loading, unreviewed executable download,
  or unknown file is required;
- all public acquisition occurs before offline evaluation from immutable local
  assets and is captured in provenance;
- license, copyright, NOTICE, attribution, commercial-use review, security scan,
  compatibility, and revocation are complete for every arm/variant;
- report redaction preserves aggregate evidence while removing content; and
- provenance and results bind to the existing intelligence-quality/safety
  evaluation identity through the non-authoritative handoff.

## Core Spotlight evaluation isolation

- The domain/index and identifiers are derived from test run identity and are
  test-only.
- Private production data and production IDs never enter Spotlight.
- Fixtures marked ineligible are never donated.
- Only explicitly authorized synthetic/canonical fixtures are donated.
- Allowed returned candidates still pass Ambitions fixture-side privacy,
  identity, family, revision, deletion, tombstone, and staleness validation.
- Spotlight results remain separately reported and create no product authority
  or production persistence.
- Teardown deletes the run domain after success, assertion failure,
  cancellation, expiration, crash/relaunch recovery, and explicit cleanup.
- A final query/inspection proves no test content remains.

## Offline and failure matrix

For every applicable arm, exercise and report:

- airplane mode and no account/token;
- model/OS asset never present or absent;
- interrupted acquisition/staging;
- missing, corrupt, incompatible, revoked, deleted/reclaimed asset;
- provider unavailability and invalid conversion quarantine;
- query/draft revision, cancellation, dismissal, and app deactivation;
- memory warning/pressure and protected-data unavailability;
- Low Power Mode;
- nominal/fair/serious/critical thermal pressure where safely inducible;
- foreground/background transition and background expiration;
- disk pressure/partial write;
- crash and relaunch; and
- Core Spotlight cleanup interruption/recovery.

Expected invariant: deterministic fixture evaluation remains available or is the
explicit safe result; semantic work cancels/abstains; partial evidence is invalid;
no canonical state can change. Never-downloaded/absent assets are evidence, not
a requirement to implement product download UX.

## Scale, exact scan, and conditional ANN

At deterministic 1K, 10K, and supported 100K synthetic scales, record:

- fixture/generator digest and vector distribution;
- exact-scan retrieval correctness against the brute-force oracle;
- initial build and incremental throughput;
- tokenization/inference and scan/fusion/hydration phase timings;
- p50/p95 and full distributions where useful;
- cancellation responsiveness;
- active, staged, rollback/high-water vector and metadata bytes;
- peak/high-water memory and allocation evidence; and
- device/OS/build/thermal/Low Power Mode identity.

Exact scanning is measured first. The ANN task is `not_triggered` unless reviewed
physical-device evidence demonstrates exact-scan insufficiency at a supported
scale for an approved evidence question. If triggered, ANN remains a disposable
comparison and reports recall, latency, memory, storage, build/update,
cancellation, and failure against exact scan; it selects no production index or
vector format.

## Physical-device performance, energy, and thermal evidence

Use Release configuration on:

- oldest supported iOS 26 class: iPhone 11; SE-class additionally when practical;
- middle non-Pro class: iPhone 14 or 15; and
- current Pro/Apple-Intelligence-capable class.

Measure phase-separated cold/warm verification/compile/load, tokenization,
inference, indexing/build, incremental update, exact scan, fusion, hydration,
cancellation, peak/high-water memory, storage/archive/model/tokenizer/compiled
cache/vector bytes, compute placement evidence, energy, thermal progression, Low
Power Mode, background expiration, lifecycle, and failure recovery. Record
repeated trials after cooldown and randomized arm order where practical.

Simulator evidence is functional only. Simulator cannot satisfy memory,
compute-placement, energy, thermal, or device-latency claims. Do not claim exact
battery percentages without direct evidence. Research latency, RSS, storage,
cancellation, energy, and thermal values may appear only as explicitly labelled
experimental comparison points with no product, Scope, Design, or release
authority.

## Storage and distribution evidence

Report separately for each valid arm/variant:

- source checkpoint and tokenizer inputs;
- converted model and tokenizer;
- compiled/specialized cache;
- active/staged/rollback/high-water vector/index artifacts at each scale;
- standalone benchmark-host archive and installed size; and
- delta against an identical host with no model/resource.

Also prove the shipping app/archive delta is zero. This tranche reports data and
does not choose bundle, Apple-hosted/managed asset delivery, optional download,
device tiers, production cache, or update/rollback design.

## Exact eleven-question closeout table

The final report must contain one complete section for each `REQ-013` question:

| Question | Mandatory evidence |
|---|---|
| 1. Search quality | Search metric/slice report for deterministic, `NLEmbedding`, every valid required external candidate, and separate Spotlight |
| 2. Search safety | Hard filters, hydration, deletion/staleness, identity/action and mutation-canary results |
| 3. Capture quality | Classification/association/duplicate/calibration/abstention/correction/selective-accuracy report |
| 4. Shared-embedding ceiling | Paired Search/Capture benefit, coverage, regression, burden, and no-classifier/LLM conclusion |
| 5. Conversion fidelity | Candidate reference-numeric and quarantine reports |
| 6. Runtime behavior | Physical-device cold/warm, throughput, cancellation, memory/storage/compute/energy/thermal/LPM/lifecycle evidence |
| 7. Scale behavior | 1K/10K/supported-100K exact results and conditional ANN admission/result |
| 8. Failure/offline | Full airplane/asset/pressure/cancel/background/crash/recovery matrix |
| 9. Storage/distribution | Converted/tokenizer/cache/index/archive/installed measurements without a delivery choice |
| 10. Provenance/licensing | Immutable hashes, reproduction, scans, license/NOTICE, offline/no-token proof |
| 11. Decision result | Arm-by-arm user-value lift, hard failures, device burden, uncertainty, and unbiased conclusion |

## Decision neutrality and handoff

The synthesis must permit, without penalty or wording bias:

- an external model wins;
- `NLEmbedding` is sufficient;
- deterministic-only is preferable; or
- no external candidate qualifies.

Arctic is a benchmark candidate, not the presumed winner. Public leaderboard
rank does not select an arm. An external model may be recommended to amended
Design only if it has valid conversion/provenance/license evidence, no hard
failure, material paired Ambitions value, and measured device/storage burden
that amended Design can assess. The evaluation itself sets no production budget.

The final redacted packet contains run/suite identities, aggregate results,
hard failures, limitations, provenance/license/security summaries, physical-
device distributions, storage evidence, conditional-gate outcomes, IQSE handoff,
and attachment digests. It contains no model, tokenizer, vector store, fixture
text, private content, production ID, release verdict, or implementation
authorization.

After review, amended Design must decide external model or none, production
Search owner/index, physical boundary, provider/preprocessing/fusion/calibration,
persistence/migration/deletion/rollback, delivery if applicable, measured
budgets/device coverage, and exact canon/build/test/frontend impacts. Devan must
re-approve amended Design before production grooming.

## Disposal and final verification

Run cleanup on normal closeout and failure recovery. Verify removal of:

- Spotlight test domains/items;
- staged source assets, model/tokenizer conversions, compiled caches;
- vector/index/ANN stores;
- standalone-host DerivedData/archives and temporary signing material;
- incomplete/invalid runs and content-bearing diagnostics; and
- any accidental shipping graph/resource reference.

Cleanup is idempotent. Only the reviewed redacted evidence and immutable public
provenance/license records remain. Evaluation code remains quarantined or is
deleted; wholesale promotion is prohibited.

Final checks include the product-doc lifecycle checker, package/tool focused
tests, standalone host tests/builds, isolation/provenance/privacy/mutation scans,
shipping and standalone archive inspection, report-schema and eleven-question
completeness, post-clean Spotlight query, `git diff --check`, and review that the
repository diff contains no production/canon/frontend expansion.

Run these exact closure commands from the repository root, recording exit status
and test counts where available:

```bash
evaluation_root=tools/ambitions-intelligence-evaluation
python3 .agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py check docs/product-development/ambitions-private-semantic-intelligence --json
swift test --package-path "$evaluation_root"
python3 -m unittest discover -s "$evaluation_root/Conversion/tests" -p 'test_*.py'
python3 -m unittest discover -s "$evaluation_root/Scripts/tests" -p 'test_*.py'
python3 "$evaluation_root/Scripts/check_isolation.py"
python3 "$evaluation_root/Scripts/check_provenance.py"
xcodegen generate --spec "$evaluation_root/BenchmarkHost/project.yml" --project "$evaluation_root/BenchmarkHost/Generated"
xcodebuild -project "$evaluation_root/BenchmarkHost/Generated/AmbitionsIntelligenceEvaluationBenchmarkHost.xcodeproj" -scheme AmbitionsIntelligenceEvaluationBenchmarkHost -configuration Release -destination "id=$AMB_EVAL_DEVICE_ID" test
python3 "$evaluation_root/Scripts/synthesize_report.py" --suite "$evaluation_root/Manifests/suite-v1.json" --runs "$evaluation_root/Runs" --output "$evaluation_root/Reports/final"
python3 "$evaluation_root/Scripts/cleanup.py" --root "$evaluation_root"
python3 "$evaluation_root/Scripts/check_isolation.py"
git diff --check
```

The physical-device command is repeated with `AMB_EVAL_DEVICE_ID` set to each
reviewed tier's connected identifier. Instruments/Power Profiler capture remains
a recorded physical-device procedure because `xcodebuild` alone cannot establish
energy, thermal, memory, or compute-placement evidence.

## Verification self-review

**PASS.** This contract proves structural non-shipping isolation, zero canonical
authority, complete Search/Capture/conversion/privacy/offline/scale/device
evidence, all eleven `REQ-013` answers, exact-first conditional ANN behavior,
Core Spotlight isolation/cleanup, decision neutrality, and Research-threshold
nonauthority. It cannot pass by selecting Arctic or any external model.
