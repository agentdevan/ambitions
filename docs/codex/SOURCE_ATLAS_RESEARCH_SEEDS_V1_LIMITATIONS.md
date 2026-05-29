# Source Atlas Research Seeds v1 Limitations

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof
> Dispositions: merge-before-proof, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Active limitations for Source Atlas Research Seeds v1.
Date: 2026-05-06

## Decision

Source Atlas Research Seeds v1 are accepted as research seed inputs only.

They are useful for:

- Goal phrase coverage
- Source Atlas graph backlog
- projection recipes
- QA fixtures
- source registry candidates
- Pack Factory schema examples
- Codex implementation planning

They are not production packs.

## Known limitations

### 1. Corpus name vs actual count

The uploaded source files use `10000` in the goal-corpus names, but the verified corpus contains `5,880` rows.

Importers must rename the files to:

- `source_atlas_goal_corpus_seed_5880.csv`
- `source_atlas_goal_corpus_seed_5880.jsonl`

Repo references must call this a representative seed corpus, not a verified top-10,000 global goal corpus.

### 2. Representative coverage, not frequency proof

The corpus appears to be a structured coverage matrix across domains/specific domains, not a statistically proven frequency-ranked list of the most common human goals.

Codex must not claim that these are objectively the top 10,000 goals.

### 3. Duplicates are expected

Some normalized goals repeat across domains and contexts.

Codex must not dedupe only by `normalized_goal`.

Preferred dedupe keys:

```text
domain + specific_domain + normalized_goal + goal_intent
```

or:

```text
cluster_id + normalized_goal + projection_recipe_id
```

### 4. U.S.-weighted source assumptions

Several source registry candidates and overlays are U.S.-weighted.

This is acceptable for v1 but must be labeled.

Do not imply global coverage.

### 5. Source registry candidates are not source truth

A source candidate is not an approved Source Atlas source.

Every candidate still needs:

- source authority review
- usage/licensing review where relevant
- source freshness policy
- claim support boundary
- adapter feasibility review
- no-claim review

### 6. Pseudo-sources are intentional

Some source values may use internal pseudo-source identifiers such as:

```text
ambitions://user-source-binder
ambitions://phrase-mining/community
```

These are not web URLs and must not be passed through normal URL validation.

They must be handled as internal markers for user-source or phrase-mining behavior.

### 7. High-risk domains remain review-bound

The following must remain strict-review/source-needed until verified:

- legal/civic
- education/certification
- career/licensing
- medical/health boundary
- financial boundary
- minor/student-sensitive
- professional-boundary
- deadline-sensitive

### 8. No production use until validators exist

Research seed data cannot ship as Source Atlas production packs until relevant Source Atlas gates exist and pass:

- schema validation
- claim state validation
- freshness policy validation
- pack duplication scan
- no one-pack-per-goal scan
- no-claim scan
- source registry candidate validation
- source/freshness UI rendered proof where visible

## Hard no-claim language

Do not say:

- Source Atlas covers every goal.
- Source Atlas contains the 10,000 most common goals.
- Research Seeds v1 are official source packs.
- Source registry candidates are approved authoritative sources.
- Any legal/career/education/certification requirement is complete/current from this seed package alone.

Allowed language:

- Source Atlas Research Seeds v1 provide a representative initial corpus and backlog.
- The seed package helps Codex create Pack Factory inputs, QA fixtures, and graph-piece implementation tasks.
- Official/current claims remain blocked until Source Atlas validation and source review pass.

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
