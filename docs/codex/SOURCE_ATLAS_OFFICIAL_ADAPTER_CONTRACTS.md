# Source Atlas Official Adapter Contracts

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: stale_or_unknown_active_status
> Prior recommended actions: Expedite
> Candidate references: AMB28-stale_or_unknown_active_status-26242079

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, rewrite-authority-before-proof
> Dispositions: rewrite-authority-before-proof, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

## Goal
Define official page/PDF and API adapter contracts for Data.gov catalog, O*NET, BLS, Census, USAJOBS, FEC, USAspending, and future sources. 

## Architectural Law
- **Factory Inputs Only**: Adapters are pack factory inputs. They run offline on a developer or builder machine to produce `.json` packs.
- **No Runtime App Dependency**: The Ambitions iOS app must **never** call these APIs directly. The app only consumes the resulting Source Atlas packs.
- **No App Bundle API Keys**: API keys for Data.gov, BLS, etc. are strictly forbidden from entering the iOS app bundle or the iOS app runtime.
- **No Confidence Collapse**: Official data must be ingested with its exact source ID and timestamp. It must not be generalized into an ambiguous "official" boolean without the provenance chain.

## Supported Sources
1. **Data.gov Catalog**: Generic CSV/JSON dataset adapters.
2. **O*NET**: Career prerequisites, skills, and tasks.
3. **BLS**: Employment projections and wage data.
4. **Census**: Demographic and economic baselines.
5. **USAJOBS**: Federal job requirements and GS-level prerequisites.
6. **FEC**: Campaign finance and election rules.
7. **USAspending**: Federal grant and contract rules.

## The Contract

Every adapter must implement the tooling contract defined in `tools/source-atlas/ambitions-official-adapter-contract.py`. 

The adapter must:
1. Provide a `source_id` matching a registered `SourceAtlasSourceRecord`.
2. Extract data without mutating the core meaning.
3. Output a list of claim dictionaries compatible with `SourceAtlasClaim` (e.g. `state="official"`, explicit `freshness`, specific `riskClass`).
4. Support generating the JSON output strictly offline after the initial data fetch.

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
