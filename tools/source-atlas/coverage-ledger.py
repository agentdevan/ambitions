#!/usr/bin/env python3
"""Generate the retained Source Atlas Coverage Ledger.

The ledger is a roll-up over live repo artifacts. It is not production coverage,
R2 readiness, release proof, privacy/legal approval, or known-issue closure.
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from datetime import date
from pathlib import Path
from typing import Any


REPO_ROOT = Path(__file__).resolve().parents[2]
SOURCE_ATLAS_ROOT = REPO_ROOT / "tools" / "source-atlas"
sys.path.insert(0, str(SOURCE_ATLAS_ROOT))

from foundry.m09_validation import (  # noqa: E402
    KNOWN_ISSUE_IDS,
    REQUIRED_SOURCE_STATES,
    _known_issue_row,
    validate_command_matrix,
    validate_golden_benchmark_matrix,
    validate_source_state_repair_fixtures,
)
from foundry.registry import PATHWAY_SEEDS, SOURCE_REGISTRY  # noqa: E402


DEFAULT_OUTPUT = REPO_ROOT / "docs" / "qa" / "source-atlas" / "SOURCE_ATLAS_COVERAGE_LEDGER.md"
M09_MATRIX = REPO_ROOT / "docs" / "qa" / "source-atlas" / "2026-06-26-m09-validation-command-matrix.json"
M09_GOLDEN = REPO_ROOT / "tools" / "source-atlas" / "fixtures" / "m09" / "golden-benchmark-matrix.json"
M09_REPAIR = REPO_ROOT / "tools" / "source-atlas" / "fixtures" / "m09" / "source-state-repair-fixtures.json"
PRODUCTION_R2_PROOF = REPO_ROOT / "docs" / "qa" / "source-atlas" / "production-r2-operations-proof.json"
PRODUCTION_R2_PROOF_MD = REPO_ROOT / "docs" / "qa" / "source-atlas" / "production-r2-operations-proof.md"
SCENARIO_GATES = REPO_ROOT / "docs" / "qa" / "product-experience-scenario-gates.yaml"

NON_CLAIMS = [
    "does not claim stable-channel R2 production freshness",
    "does not claim Source Atlas packs are production-ready",
    "does not claim app-side R2 fetch/cache/entitlement gating is validated",
    "does not claim R2 privacy boundary is release-validated",
    "does not claim account readiness, TestFlight readiness, App Store readiness, device proof, or accessibility conformance",
    "does not close known issues",
]


def rel(path: Path) -> str:
    try:
        return str(path.relative_to(REPO_ROOT))
    except ValueError:
        return str(path)


def read_json(path: Path) -> Any:
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def git_sha() -> str:
    try:
        return subprocess.check_output(
            ["git", "rev-parse", "--short", "HEAD"],
            cwd=REPO_ROOT,
            text=True,
            stderr=subprocess.DEVNULL,
        ).strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        return "unknown"


def source_registry_rollup() -> dict[str, Any]:
    adapters = sorted({source.get("adapter", "unknown") for source in SOURCE_REGISTRY})
    authority_tiers = sorted({source.get("authorityTier", "unknown") for source in SOURCE_REGISTRY})
    domains = sorted({domain for source in SOURCE_REGISTRY for domain in source.get("domains", [])})
    claims = [claim for pathway in PATHWAY_SEEDS for claim in pathway.get("claims", [])]
    requirements = [req for pathway in PATHWAY_SEEDS for req in pathway.get("requirements", [])]
    source_links = sorted({source_id for pathway in PATHWAY_SEEDS for source_id in pathway.get("sourceIDs", [])})
    freshness_values = sorted({claim.get("freshness", "unknown") for claim in claims})
    return {
        "source_count": len(SOURCE_REGISTRY),
        "adapter_count": len(adapters),
        "authority_tier_count": len(authority_tiers),
        "domain_count": len(domains),
        "pathway_seed_count": len(PATHWAY_SEEDS),
        "claim_count": len(claims),
        "requirement_count": len(requirements),
        "pathway_source_link_count": len(source_links),
        "freshness_values": freshness_values,
        "adapters": adapters,
    }


def scenario_gate_rollup() -> dict[str, Any]:
    text = SCENARIO_GATES.read_text(encoding="utf-8")
    blocks = re.split(r"\n\s*-\s+id:\s+", "\n" + text)
    gates: list[dict[str, str]] = []
    for block in blocks[1:]:
        gate_id = block.splitlines()[0].strip().strip('"')
        if not gate_id.startswith(("source_atlas_", "source_inspection_", "source_freshness_")):
            continue
        status_match = re.search(r'current_status:\s+"?([^"\n]+)"?', block)
        group_match = re.search(r'group:\s+"?([^"\n]+)"?', block)
        gates.append({
            "id": gate_id,
            "status": status_match.group(1).strip() if status_match else "Unknown",
            "group": group_match.group(1).strip() if group_match else "Unknown",
        })
    status_counts: dict[str, int] = {}
    for gate in gates:
        status_counts[gate["status"]] = status_counts.get(gate["status"], 0) + 1
    return {"gates": gates, "status_counts": status_counts}


def native_source_rollup() -> dict[str, Any]:
    source_files = sorted((REPO_ROOT / "Native" / "Ambitions").rglob("*SourceAtlas*.swift"))
    test_files = sorted((REPO_ROOT / "Native" / "AmbitionsTests").rglob("*SourceAtlas*.swift"))
    owners = {
        "Core/Domain": 0,
        "Core/Persistence": 0,
        "Core/Runtime": 0,
        "Projection": 0,
        "DesignSystem": 0,
        "Tests": len(test_files),
    }
    for path in source_files:
        relative = rel(path)
        for owner in list(owners):
            if owner != "Tests" and f"Native/Ambitions/{owner}/" in relative:
                owners[owner] += 1
                break
    return {
        "source_file_count": len(source_files),
        "test_file_count": len(test_files),
        "owners": owners,
        "sample_sources": [rel(path) for path in source_files[:8]],
        "sample_tests": [rel(path) for path in test_files[:8]],
    }


def coverage_universe_rollup() -> dict[str, Any]:
    roots = {
        "config": REPO_ROOT / "source-atlas" / "coverage",
        "schemas": REPO_ROOT / "source-atlas" / "schemas",
        "reports": REPO_ROOT / "source-atlas" / "reports",
        "fixtures": REPO_ROOT / "source-atlas" / "fixtures",
        "receipts": REPO_ROOT / "source-atlas" / "generated" / "receipts",
    }
    wrappers = sorted(SOURCE_ATLAS_ROOT.glob("coverage*.py"))
    missing = [rel(path) for path in roots.values() if not path.exists()]
    fixture_count = len(list(roots["fixtures"].rglob("*.json"))) if roots["fixtures"].exists() else 0
    receipt_count = len(list(roots["receipts"].rglob("*.json"))) if roots["receipts"].exists() else 0
    status = "Yellow" if missing else "Source Green"
    return {
        "status": status,
        "wrapper_count": len(wrappers),
        "missing_roots": missing,
        "fixture_count": fixture_count,
        "receipt_count": receipt_count,
        "wrapper_paths": [rel(path) for path in wrappers],
    }


def validation_rollup() -> dict[str, Any]:
    command_result = validate_command_matrix(M09_MATRIX, REPO_ROOT)
    golden_result = validate_golden_benchmark_matrix(M09_GOLDEN)
    repair_result = validate_source_state_repair_fixtures(M09_REPAIR)
    validations = {
        "commandMatrix": command_result,
        "goldenBenchmarks": golden_result,
        "sourceStateRepair": repair_result,
    }
    known_issue_rows = [_known_issue_row(issue_id, validations) for issue_id in KNOWN_ISSUE_IDS]
    matrix = read_json(M09_MATRIX)
    commands = matrix.get("commands", [])
    areas = sorted({command.get("area", "unknown") for command in commands})
    not_available = [command for command in commands if command.get("availability") == "not_available"]
    return {
        "command_result": command_result,
        "golden_result": golden_result,
        "repair_result": repair_result,
        "known_issue_rows": known_issue_rows,
        "command_count": len(commands),
        "available_command_count": sum(1 for command in commands if command.get("availability") == "available"),
        "not_available_command_count": len(not_available),
        "areas": areas,
        "not_available": not_available,
    }


def foundry_contract_rollup() -> dict[str, Any]:
    contracts = sorted((SOURCE_ATLAS_ROOT / "foundry" / "contracts").glob("*.json"))
    fixture_roots = {
        "boundary_valid": SOURCE_ATLAS_ROOT / "fixtures" / "boundary" / "valid",
        "boundary_invalid": SOURCE_ATLAS_ROOT / "fixtures" / "boundary" / "invalid",
        "r2_valid": SOURCE_ATLAS_ROOT / "fixtures" / "r2" / "valid",
        "r2_invalid": SOURCE_ATLAS_ROOT / "fixtures" / "r2" / "invalid",
    }
    return {
        "contract_count": len(contracts),
        "contracts": [rel(path) for path in contracts],
        "fixture_counts": {
            name: len(list(path.glob("*.json"))) if path.exists() else 0
            for name, path in fixture_roots.items()
        },
        "operation_fixture_count": len(list((SOURCE_ATLAS_ROOT / "fixtures" / "r2" / "operations").rglob("*.json"))),
    }


def production_r2_rollup() -> dict[str, Any]:
    if not PRODUCTION_R2_PROOF.exists():
        return {
            "present": False,
            "status": "Missing",
            "green_scope": "none",
            "operation_count": 0,
            "green_or_passed_operation_count": 0,
            "readback_checksum_count": 0,
            "proof_prefix": "unproven",
            "non_claims": ["production R2 operations proof absent"],
        }
    proof = read_json(PRODUCTION_R2_PROOF)
    operations = proof.get("operations", [])
    passed_statuses = {"Green", "Passed"}
    privacy = proof.get("privacyProof", {})
    return {
        "present": True,
        "status": proof.get("status", "Unknown"),
        "green_scope": proof.get("greenScope", "Source Atlas Production R2 Operations Proof only"),
        "operation_count": len(operations),
        "green_or_passed_operation_count": sum(1 for item in operations if item.get("status") in passed_statuses),
        "readback_checksum_count": privacy.get("readbackChecksumCount", 0),
        "proof_prefix": proof.get("environmentInventory", {}).get("productionProofPrefix", "unknown"),
        "non_claims": proof.get("nonClaims", []),
        "proof_doc": rel(PRODUCTION_R2_PROOF_MD),
    }


def status_for(validations: dict[str, Any], coverage: dict[str, Any]) -> str:
    if not all([
        validations["command_result"].get("valid"),
        validations["golden_result"].get("valid"),
        validations["repair_result"].get("valid"),
    ]):
        return "Red"
    if coverage["missing_roots"]:
        return "Yellow"
    return "Source Green"


def table_row(values: list[str]) -> str:
    return "| " + " | ".join(values) + " |"


def render(output: Path) -> str:
    registry = source_registry_rollup()
    scenarios = scenario_gate_rollup()
    native = native_source_rollup()
    coverage = coverage_universe_rollup()
    validations = validation_rollup()
    contracts = foundry_contract_rollup()
    production_r2 = production_r2_rollup()
    status = status_for(validations, coverage)
    known_keep_open = sum(1 for row in validations["known_issue_rows"] if not row["closeKnownIssue"])
    source_gate_rows = scenarios["gates"]

    lines = [
        "# Source Atlas Coverage Ledger",
        "",
        "Status: " + status,
        "Generated: " + date.today().isoformat(),
        "Input commit: " + git_sha(),
        "Owner posture: Retained coverage/proof roll-up, not product canon, production coverage proof, R2 readiness proof, privacy/legal approval, release proof, or known-issue closure.",
        "",
        "This ledger rolls up the current Source Atlas registry, product-experience scenario gates, native source states, claim/provenance/freshness posture, validation commands, R2 readiness gates, and known-issue routing. It must stay conservative: source-present, locally validated, or generated coverage artifacts do not prove production freshness, app-side R2 behavior, entitlement gating, privacy/legal approval, device behavior, accessibility conformance, or release readiness.",
        "",
        "## Non-Claims",
        "",
    ]
    lines.extend(f"- {item}" for item in NON_CLAIMS)

    lines.extend([
        "",
        "## Roll-Up",
        "",
        table_row(["Layer", "Current live coverage", "Status ceiling", "Primary evidence"]),
        table_row(["---", "---", "---", "---"]),
        table_row([
            "Registry",
            f"{registry['source_count']} sources, {registry['adapter_count']} adapter lanes, {registry['pathway_seed_count']} pathway seeds, {registry['claim_count']} claims, {registry['requirement_count']} requirements",
            "Source/tooling coverage only",
            "`tools/source-atlas/foundry/registry.py`",
        ]),
        table_row([
            "Scenarios",
            f"{len(source_gate_rows)} Source-related product gates; {validations['golden_result']['scenarioCount']} M09 golden scenarios x {validations['golden_result']['variantCount']} source-state variants",
            "Scenario/contract coverage only",
            "`docs/qa/product-experience-scenario-gates.yaml`, `tools/source-atlas/fixtures/m09/golden-benchmark-matrix.json`",
        ]),
        table_row([
            "Source states",
            ", ".join(REQUIRED_SOURCE_STATES),
            "Local repair-routing proof only",
            "`tools/source-atlas/foundry/m09_validation.py`, `tools/source-atlas/fixtures/m09/source-state-repair-fixtures.json`",
        ]),
        table_row([
            "Claims, provenance, freshness",
            f"{registry['claim_count']} seed claims; freshness values: {', '.join(registry['freshness_values']) or 'none'}",
            "Seed/source-record proof only",
            "`tools/source-atlas/foundry/registry.py`, `tools/source-atlas/foundry/contracts/*`",
        ]),
        table_row([
            "Native source",
            f"{native['source_file_count']} SourceAtlas source files and {native['test_file_count']} SourceAtlas test files",
            "Source/test presence; no release proof",
            "`Native/Ambitions/**/SourceAtlas*.swift`, `Native/AmbitionsTests/**/SourceAtlas*.swift`",
        ]),
        table_row([
            "Validation",
            f"{validations['available_command_count']} available M09 commands, {validations['not_available_command_count']} unavailable command, {len(validations['areas'])} areas",
            "Local validation matrix proof only",
            "`docs/qa/source-atlas/2026-06-26-m09-validation-command-matrix.json`",
        ]),
        table_row([
            "R2 readiness",
            f"{contracts['contract_count']} contracts; production operations proof status {production_r2['status']} for `{production_r2['proof_prefix']}`",
            "Green only for validation-prefix operations proof; Yellow for app/runtime/release readiness",
            "`tools/source-atlas/foundry/contracts`, `docs/qa/source-atlas/production-r2-operations-proof.md`",
        ]),
        table_row([
            "Known issues",
            f"{len(validations['known_issue_rows'])} routed; {known_keep_open} keep-open recommendations",
            "Routing only; no closure",
            "`tools/source-atlas/foundry/m09_validation.py`",
        ]),
    ])

    lines.extend([
        "",
        "## Coverage Tooling Audit",
        "",
        table_row(["Tooling area", "Observed", "Ledger finding"]),
        table_row(["---", "---", "---"]),
        table_row([
            "Coverage command wrappers",
            f"{coverage['wrapper_count']} wrappers: " + ", ".join(f"`{path}`" for path in coverage["wrapper_paths"]),
            "Wrappers are present and route through `tools/source-atlas/coverage.py`.",
        ]),
        table_row([
            "Coverage Universe config/report roots",
            "Missing: " + (", ".join(f"`{path}`" for path in coverage["missing_roots"]) if coverage["missing_roots"] else "none"),
            "Yellow while required config/schema/report roots are absent; do not claim full Coverage Universe reproducibility.",
        ]),
        table_row([
            "Coverage fixtures and receipts",
            f"{coverage['fixture_count']} fixture JSON files; {coverage['receipt_count']} generated receipt JSON files",
            "Deterministic proof inputs only; not runtime or release proof.",
        ]),
        table_row([
            "Foundry contracts and boundary fixtures",
            f"{contracts['contract_count']} contracts; fixture counts {json.dumps(contracts['fixture_counts'], sort_keys=True)}; {contracts['operation_fixture_count']} R2 operation fixtures",
            "Local schema/boundary proof surface exists; stable-channel freshness and app-side R2 remain unproven.",
        ]),
    ])

    lines.extend([
        "",
        "## Source-Related Scenario Gates",
        "",
        table_row(["Gate", "Group", "Current status"]),
        table_row(["---", "---", "---"]),
    ])
    for gate in source_gate_rows:
        lines.append(table_row([f"`{gate['id']}`", gate["group"], gate["status"]]))

    lines.extend([
        "",
        "## Validation Matrix",
        "",
        table_row(["Validation surface", "Valid", "Count / status", "Evidence"]),
        table_row(["---", "---", "---", "---"]),
        table_row([
            "Command matrix",
            str(validations["command_result"].get("valid")),
            f"{validations['command_count']} commands across {len(validations['areas'])} areas",
            "`docs/qa/source-atlas/2026-06-26-m09-validation-command-matrix.json`",
        ]),
        table_row([
            "Golden benchmarks",
            str(validations["golden_result"].get("valid")),
            f"{validations['golden_result']['scenarioCount']} scenarios, {validations['golden_result']['expandedCaseCount']} expanded source-state cases",
            "`tools/source-atlas/fixtures/m09/golden-benchmark-matrix.json`",
        ]),
        table_row([
            "Source-state repair",
            str(validations["repair_result"].get("valid")),
            f"{validations['repair_result']['fixtureCount']} fixtures; states {', '.join(validations['repair_result']['statesCovered'])}",
            "`tools/source-atlas/fixtures/m09/source-state-repair-fixtures.json`",
        ]),
    ])
    if validations["not_available"]:
        lines.extend(["", "Unavailable validation entries are explicit non-claims:"])
        for command in validations["not_available"]:
            lines.append(f"- `{command['id']}`: {command.get('notAvailableReason', 'not available')}")

    lines.extend([
        "",
        "## R2 Readiness Map",
        "",
        table_row(["R2 / freshness capability", "Current coverage", "Claim ceiling"]),
        table_row(["---", "---", "---"]),
        table_row(["Object layout", "`tools/source-atlas/foundry/contracts/r2-object-layout.json`", "Contract shape only"]),
        table_row(["Release manifest", "`tools/source-atlas/foundry/contracts/release-manifest-schema.json`", "Schema shape only"]),
        table_row(["Freshness manifest", "`tools/source-atlas/foundry/contracts/freshness-manifest-schema.json`", "Schema shape only"]),
        table_row(["Revocation", "`tools/source-atlas/foundry/contracts/revocation-manifest-schema.json`", "Schema shape only"]),
        table_row(["Last known good", "`tools/source-atlas/foundry/contracts/last-known-good-schema.json`", "Schema shape only"]),
        table_row(["Promotion gate", "`source-atlas-foundry.py promotion-gate`", "Dry-run only"]),
        table_row([
            "Production R2 operations proof",
            f"`{production_r2['proof_doc'] if production_r2['present'] else rel(PRODUCTION_R2_PROOF)}`; {production_r2['green_or_passed_operation_count']} of {production_r2['operation_count']} operations Green/Passed; {production_r2['readback_checksum_count']} readback checksums matched",
            production_r2["green_scope"] if production_r2["present"] else "Missing",
        ]),
        table_row(["M09 production R2 upload", "`m09.production.r2.upload` is not_available", "Not run in M09; superseded only by the separate AMB-1429 operations-proof scope"]),
        table_row(["App-side fetch/cache/entitlement/privacy proof", "No release proof in this ledger", "Unproven"]),
    ])

    lines.extend([
        "",
        "## Known Issue Routing",
        "",
        table_row(["Issue", "Route status", "Covered by", "Closure"]),
        table_row(["---", "---", "---", "---"]),
    ])
    for row in validations["known_issue_rows"]:
        lines.append(table_row([
            f"`{row['issueID']}`",
            row["routeStatus"],
            ", ".join(row["coveredBy"]),
            "keep open" if not row["closeKnownIssue"] else "close",
        ]))

    lines.extend([
        "",
        "## Native Source Ownership Snapshot",
        "",
        table_row(["Canonical owner", "SourceAtlas file count"]),
        table_row(["---", "---"]),
    ])
    for owner, count in native["owners"].items():
        lines.append(table_row([owner, str(count)]))

    lines.extend([
        "",
        "Sample native source evidence:",
        "",
    ])
    lines.extend(f"- `{path}`" for path in native["sample_sources"])
    lines.extend(["", "Sample native test evidence:", ""])
    lines.extend(f"- `{path}`" for path in native["sample_tests"])

    lines.extend([
        "",
        "## Next Repair Gates",
        "",
        "- Restore or intentionally replace the missing Coverage Universe config/schema/report roots before claiming reproducible Coverage Universe coverage.",
        "- Keep M09 production R2 upload unavailable until a scoped promotion gate run is approved and current proof is produced.",
        "- Add app-side request-shape, fetch/cache, entitlement, quarantine/revocation, last-known-good, offline fallback, and privacy-boundary proof before any R2 readiness claim.",
        "- Keep known issues open until their owning implementation or release proof exists outside this routing ledger.",
        "",
        "## Rollback",
        "",
        f"Revert `{rel(Path(__file__))}` and `{rel(output)}`. No source, runtime behavior, R2 object, account flow, or Xcode project setting is changed by this ledger.",
        "",
    ])
    return "\n".join(lines)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Generate Source Atlas Coverage Ledger")
    parser.add_argument("--output", default=str(DEFAULT_OUTPUT))
    args = parser.parse_args(argv)
    output = Path(args.output)
    markdown = render(output)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(markdown, encoding="utf-8")
    print(f"Wrote {rel(output)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
