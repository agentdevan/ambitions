import json
from pathlib import Path


def write_required_governance_artifacts(
    canon_root: Path,
    *,
    canon_revision: int,
    requirement_ids: tuple[str, ...] = (),
) -> None:
    ledger = canon_root / "decisions" / "SUPERSESSION_LEDGER.toml"
    ledger.parent.mkdir(parents=True, exist_ok=True)
    ledger.write_text("schema_version = 1\nentries = []\n", encoding="utf-8")

    reference_index = canon_root / "migration" / "impact-reference-index.json"
    reference_index.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "authority_references": [],
        "canon_revision": canon_revision,
        "indexed_requirement_ids": sorted(set(requirement_ids)),
        "schema_version": 1,
        "specification_gaps": [],
        "task_packs": [],
    }
    reference_index.write_text(
        json.dumps(payload, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )
