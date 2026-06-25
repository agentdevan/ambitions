# Source Atlas Lakehouse Workbench

Status: candidate seed factory for Source Atlas Foundry
Scope: generate, validate, audit, and compile large review-bound candidate goal-intent corpora
Owner posture: local developer tooling only, not official source truth or runtime pathing authority

## Role In The Foundry

The lakehouse is useful as a large candidate generator. It is not the Foundry itself and it must not publish stable Source Atlas packs.

Correct pipeline:

```text
generated or imported candidate data
  -> schema and safety validation
  -> clean/rejected partition
  -> DuckDB QA audit
  -> candidate manifest
  -> Foundry handoff
  -> official-source review
  -> reviewed pack compiler
  -> R2 staging plan
  -> stable promotion gate
```

Candidate records may help Ambitions understand the shape of user intent and coverage gaps. They are blocked from step generation and remain below official public/reference source adapters until reviewed.

## Local Storage

Runs default to:

```text
output/source-atlas/lakehouse-runs/<run_id>/
```

Override with:

```bash
export AMBITIONS_SOURCE_ATLAS_RUNS_DIR=/absolute/local/path
```

Run structure:

- `raw/`: request JSONL files and batch output snapshots.
- `clean/`: validated candidate records and optional Parquet tables.
- `rejected/`: records rejected for private data, secrets, shaming language, or unsafe runtime fields.
- `reports/`: DuckDB QA database, audit reports, dry-run R2 command previews, and performance notes.
- `publish/source-atlas/v1/candidates/<run_id>/`: Foundry-aligned candidate manifest, candidate intent index, domain index, and handoff artifact.

`output/source-atlas/` is ignored by git.

## Safety Gates

The workbench rejects or blocks:

- private data, email addresses, phone numbers, and API-key-like secrets
- shame, streak, guilt, and fake urgency phrasing
- `production_use`
- `stores_final_schedule`
- `official` or `official/current` evidence labels
- step-generation runtime roles
- candidate paths that imply stable packs, current manifests, private data, or seeds as production artifacts

Allowed runtime eligibility is limited to intent matching:

```json
{
  "runtime_eligible": true,
  "runtime_role": "intent_matching_only",
  "blocked_for_step_generation": true
}
```

## Commands

Install local test dependencies:

```bash
brew install pydantic
python3 -m pip install --user --break-system-packages duckdb
```

Run tests:

```bash
python3 -m pytest tools/source-atlas/lakehouse-workbench/tests
```

Run the Foundry after candidate review:

```bash
python3 tools/source-atlas/source-atlas-foundry.py doctor
python3 tools/source-atlas/source-atlas-foundry.py compile-demo \
  --output-root output/source-atlas/foundry \
  --version-id source-atlas-foundry-demo \
  --channel staging
```

## R2 Boundary

Lakehouse publisher previews candidate upload commands only. It does not read credentials and does not promote stable packs.

Stable R2 publication must use Foundry validation, hash/signature checks, revocation checks, privacy boundary checks, and a promotion gate.
