# Source Atlas Official Adapter Contracts

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
