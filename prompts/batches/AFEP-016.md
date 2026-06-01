<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AFEP-016 - Privacy-Layered Search and Continuation Index

## Batch ID

AFEP-016

## Linear Issue

AMB-410 - AFEP-016 - Privacy-Layered Search and Continuation Index

## Objective

Build privacy-layered Spotlight/search and continuation indexing around Ambitions canonical objects without leaking private life data, while preserving exact reopen routing or graceful fallback to Today, Goals, Capture, Time, and You.

## Active Source Truth

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- Live source, tests, runner guard reports, and current wrapper logs beat stale docs or old batch claims.

## Required Actions

- Define indexable metadata classes for canonical object search records using existing privacy, redaction, external route, continuation, command, proof/provenance, and local-first owners.
- Add canonical object search records for Today, Goals, Capture, Time, and You without creating a parallel indexing/search engine.
- Add continuation tokens and reopen fallback so search/continuation can reopen exact objects where current source proves identifiers, and can gracefully fall back to canonical roots otherwise.
- Add redaction and export rules that keep raw goal text, capture text, schedule detail, notes, proof content, receipts, Personal Vault data, and local-learning data out of external metadata unless current source explicitly proves safe bounded disclosure.
- Preserve SourceRecord, Receipt, ReplayTrace, and What Ambitions Knows inspection wiring wherever search, continuation, proof, recovery, or reopen behavior touches runtime state.
- Preserve rollback to AFRI search/continuation routes if metadata, redaction, routing, privacy, or platform validation gates fail.
- Store the search index privacy matrix, continuation routing packet, and reopen fallback test report under `build/reports/afep/AFEP-016/`.

## Acceptance Gates

- Search and continuation use the canonical object grammar: Today / Goals / Capture / Time / You.
- Safe metadata boundaries are explicit for every indexable record and continuation token.
- Exact reopen routing exists where proven by current source, with graceful fallback to canonical roots when exact reopening cannot be proven.
- User-facing language stays canonical: `Start here`, `Recommended step`, `Start now`, `Open step`, `step`, `Today`, `Goals`, `Capture`, `Time`, `You`, `User System Profile`, `proof`, `recovery`, `receipt`, and `inspection`.
- No source path claims Spotlight production readiness, Siri/device invocation, widget/Live Activity rendering, privacy/legal approval, release readiness, TestFlight/App Store readiness, CI proof, accessibility conformance, or full-suite proof without current evidence.

## Allowed Scope

- Existing canonical search/indexing, App Intent, Shortcut, external routing, shell command, command execution, continuation, widget/extension metadata, proof/provenance, privacy, redaction, local-first, and focused test owners under `Native/Ambitions/App`, `Native/Ambitions/Domain`, `Native/Ambitions/ExternalSnapshots`, `Native/Ambitions/Services`, `Native/AmbitionsWidgetExtension`, `Native/AmbitionsTests`, `Sources/`, and `AppUI/Sources`.
- AFEP proof report files under `build/reports/afep/AFEP-016/`.
- This prompt and concept-lock or champion-coverage entries only if the guard requires explicit AFEP-016 permission for locked canonical owners.

## Forbidden Scope

- Do not create a parallel search engine, indexing engine, continuation engine, routing engine, proof ledger, privacy owner, redaction owner, persistence owner, continuity owner, shell command owner, or design-system fork.
- Do not change top-level IA; active IA remains Today / Goals / Capture / Time / You.
- Do not reintroduce `Plan` as a user-facing top-level IA.
- Do not expose raw goal text, schedule detail, private notes, capture text, proof content, receipts, runtime snapshots, local-learning data, Personal Vault data, or protected-storage fields through search metadata, continuation tokens, route URLs, fixtures, logs, screenshots, reports, Spotlight payloads, widgets, or notification payloads.
- Do not silently mutate user data from search or continuation without an inspectable confirmation/receipt path that current source proves.
- Do not add cloud model, hosted inference, analytics, backend, account, tracking, paid service, hosted CI, signing, App Store, telemetry, or network indexing dependencies.
- Do not claim release, device, accessibility conformance, performance, privacy/legal, Spotlight/platform invocation, Shortcuts/Siri readiness, CI, TestFlight, App Store, screenshot proof, or broad full-suite proof without current evidence.

## Validation

- Run champion coverage and parallel implementation guard pre/post.
- Run `xcodegen generate`.
- Run `make xcode-build-for-testing BATCH=AFEP-016`.
- Run focused test lanes for search/index privacy boundaries, continuation routing, external route parsing, shell command routing, canonical root fallback, redaction/export rules, and any changed canonical owner tests.
- Run `git diff --check`.
- If Spotlight invocation, device search, widget/Live Activity rendering, screenshot proof, or exact reopen proof is planned but not captured, record it as a Yellow boundary, not as rendered or device proof.

## Proof Artifacts

- `build/reports/afep/AFEP-016/search-index-privacy-matrix.md`
- `build/reports/afep/AFEP-016/continuation-routing-packet.md`
- `build/reports/afep/AFEP-016/reopen-fallback-test-report.md`

## Rollback / Failure Behavior

Disable the elevated index and retain AFRI search/continuation routes if metadata redaction, privacy boundaries, canonical routing, fallback behavior, exact reopen routing, test coverage, or platform proof gates fail. On Red, stop with the smallest safe repair rather than widening into broad platform, routing, app shell, privacy, proof, persistence, widget, or extension cleanup.

## Hard Red

- Private content is exposed through search metadata, continuation tokens, route URLs, fixtures, logs, screenshots, reports, Spotlight payloads, widgets, or notification payloads.
- Search or continuation routes to the wrong canonical root or reintroduces `Plan` as a user-facing top-level destination.
- Search or continuation actions silently mutate user data without current confirmation and receipt evidence.
- Parallel search, indexing, continuation, routing, privacy, redaction, proof, persistence, continuity, or design-system owners.
- Top-level IA changes.
- Required cloud model, backend, analytics, tracking, hosted inference, account, network indexing, or telemetry dependencies.
- Unproven Spotlight invocation, Siri/Shortcuts invocation, device, platform, restoration, screenshot, accessibility, privacy/legal, release, CI, or full-suite claims.
