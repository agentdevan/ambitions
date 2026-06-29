# Source Atlas Adapter + Broad Coverage Train 01 Evidence

Status: Yellow

deterministic fixture mode passed locally; live API fetch and production R2 upload not run

## Scope Completed

- Adapter SDK, terms registry, distribution gate, deterministic adapter fixtures, broad occupational foundation pack, scenario overlay, review queue, coverage ledger v2 inputs, and no-false-completion tests.

## Counts

- Adapters implemented: O*NET, BLS, Wikidata, OpenAlex, restricted-source policy
- Terms registry entries: 5
- Fixtures added: 60
- Normalized counts: {'claims': 38, 'requirements': 19, 'provenance': 4, 'atoms': 95, 'edges': 60, 'lattices': 1, 'recipes': 1}
- Crosswalk count: 10
- Review queue items: 6

## Validation Commands

- `git diff --check`
- `bash scripts/ci/ambitions-pr-review-local.sh --continue`
- `python3 scripts/ambitions-green-standard-audit.py`
- `python3 scripts/source-atlas-boundary-audit.py`
- `python3 scripts/source-atlas-no-private-graph-egress-audit.py`
- `python3 -m pytest tools/source-atlas/foundry tools/source-atlas/tests`
- `python3 tools/source-atlas/coverage-ledger.py`
- `python3 tools/source-atlas/source-atlas-foundry.py doctor`
- `python3 tools/source-atlas/source-atlas-foundry.py catalog`
- `python3 tools/source-atlas/source-atlas-foundry.py terms-registry`
- `python3 tools/source-atlas/source-atlas-foundry.py adapter-fixtures --output-root tools/source-atlas/fixtures/adapters`
- `python3 tools/source-atlas/source-atlas-foundry.py run-adapters --source-state current`
- `python3 tools/source-atlas/source-atlas-foundry.py broad-occupation-pack --output-root tools/source-atlas/generated --docs-root docs/qa/source-atlas`

## Non-Claims

- does not claim full Source Atlas project Green
- does not claim release readiness, App Store readiness, account readiness, legal/privacy approval, or complete runtime Green
- does not claim known issue closure
- does not create final user paths
- does not create final schedules
- does not create Step lists
- not a private user-data backend
- not private life graph storage
- not an official legal, medical, financial, or admissions decision
- not runtime recommendation proof by itself
- not R2 release readiness
- not accessibility, privacy, or legal approval

## Risks

- live API fetch not run without keys or explicit network validation scope
- USAJOBS remains lookup-only and not packable
- scenario coverage remains partial where official regulated source lanes are not included

## Rollback

Revert broad foundation modules, generated adapter fixtures, generated broad occupational foundation artifacts, coverage ledger updates, review queue, and this evidence packet.
