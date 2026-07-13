import json
import shutil
from pathlib import Path


FIGMA_RECONCILIATION_SCREENSHOTS = (
    "vsp-01-authority-1-2.png",
    "vsp-02-current-15-2.png",
    "vsp-03-current-5-2.png",
    "vsp-04-current-14-2.png",
)


def copy_figma_reconciliation_evidence(
    repository_root: Path,
    destination_root: Path,
) -> None:
    """Copy every non-canon file bound by the tracked Figma reconciliation."""

    approval_source = repository_root / "docs/design/provenance/owner-approvals"
    approval_target = destination_root / "docs/design/provenance/owner-approvals"
    shutil.copytree(approval_source, approval_target, dirs_exist_ok=True)

    screenshot_source = (
        repository_root
        / "docs/qa/evidence/2026-06-29-vsp-north-star-figma/images"
    )
    screenshot_target = (
        destination_root
        / "docs/qa/evidence/2026-06-29-vsp-north-star-figma/images"
    )
    screenshot_target.mkdir(parents=True, exist_ok=True)
    for filename in FIGMA_RECONCILIATION_SCREENSHOTS:
        shutil.copy2(screenshot_source / filename, screenshot_target / filename)


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

    references = canon_root / "references"
    references.mkdir(parents=True, exist_ok=True)
    for filename, kind in (
        ("figma.toml", "figma"),
        ("linear.toml", "linear"),
        ("proof-sources.toml", "proof"),
    ):
        references.joinpath(filename).write_text(
            f'schema_version = 1\nkind = "{kind}"\nreferences = []\n',
            encoding="utf-8",
        )
