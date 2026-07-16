import json
import shutil
import subprocess
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
    """Copy every non-canon file bound by the tracked visual-authority inputs."""

    subprocess.run(("git", "init", "-q"), cwd=destination_root, check=True)
    source_git_common = Path(
        subprocess.run(
            ("git", "rev-parse", "--path-format=absolute", "--git-common-dir"),
            cwd=repository_root,
            check=True,
            capture_output=True,
            text=True,
        ).stdout.strip()
    )
    alternates = destination_root / ".git/objects/info/alternates"
    alternates.parent.mkdir(parents=True, exist_ok=True)
    alternates.write_text(
        f"{(source_git_common / 'objects').resolve().as_posix()}\n",
        encoding="utf-8",
    )

    platform_source = (
        repository_root / "docs/platform/APPLE_PLATFORM_SOURCE_ATLAS_IOS.md"
    )
    platform_target = (
        destination_root / "docs/platform/APPLE_PLATFORM_SOURCE_ATLAS_IOS.md"
    )
    platform_target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(platform_source, platform_target)

    repair_matrix_source = (
        repository_root
        / "tests/canon/fixtures/visual-blueprint-phase1-repair-matrix.json"
    )
    repair_matrix_target = (
        destination_root
        / "tests/canon/fixtures/visual-blueprint-phase1-repair-matrix.json"
    )
    repair_matrix_target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(repair_matrix_source, repair_matrix_target)

    visual_evidence_source = (
        repository_root
        / "docs/qa/evidence/2026-07-14-canon-visual-authority-rebaseline"
    )
    visual_evidence_target = (
        destination_root
        / "docs/qa/evidence/2026-07-14-canon-visual-authority-rebaseline"
    )
    shutil.copytree(
        visual_evidence_source,
        visual_evidence_target,
        dirs_exist_ok=True,
    )

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
