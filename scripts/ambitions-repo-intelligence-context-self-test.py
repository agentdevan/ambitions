#!/usr/bin/env python3
"""Focused self-tests for repo-intelligence packet behavior."""
from __future__ import annotations

import importlib.util
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTEXT = ROOT / "scripts/ambitions-repo-intelligence-context.py"
CHECKER = ROOT / "scripts/ambitions-repo-intelligence-packet-check.py"
WORK = ROOT / "build/reports/repo-intelligence/self-test"


def load_module(path: Path, name: str):
    spec = importlib.util.spec_from_file_location(name, path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def write_prompt(name: str, body: str) -> Path:
    WORK.mkdir(parents=True, exist_ok=True)
    path = WORK / name
    path.write_text(body, encoding="utf-8")
    return path


def assert_true(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def main() -> int:
    context = load_module(CONTEXT, "repo_intelligence_context")
    checker = load_module(CHECKER, "repo_intelligence_packet_check")

    known_owner_prompt = write_prompt(
        "known-owner.md",
        """# IOS26-T04F-B01 - Time schedule owner test

## Allowed files/directories
- Native/Ambitions/Features/Time
- Native/Ambitions/Integrations/CalendarReminders
- build/reports/time-operations/

## Forbidden files/directories
- No Plan top-level IA.
- No silent schedule mutation.

## Validation commands
```bash
python3 scripts/ios26-flagship-preflight.py --batch IOS26-T04F-B01
python3 scripts/ios26-core-replacement-proof-shape-check.py --batch IOS26-T04F-B01
```

Create local schedule blocks with SourceRecord, Receipt, ReplayTrace, You inspection, reset/delete, deterministic test, and proof artifact coverage.
""",
    )
    packet, _markdown, md_path = context.build_packet("IOS26-T04F-B01", known_owner_prompt, WORK / "known-owner-context.md", use_cache=False)
    owner_ids = [row["owner_id"] for row in packet["owner_candidates"]]
    assert_true("time_root" in owner_ids, "known Time prompt did not emit time_root owner candidate")
    assert_true(packet["proof_lookup_matrix"], "known Time prompt did not emit proof lookup rows")
    assert_true(packet["runtime_wiring_checklist"], "runtime prompt did not emit wiring checklist")
    status, errors, _warnings = checker.check_packet(packet)
    assert_true(status == "GREEN", f"packet checker failed for known owner prompt: {errors}")

    unclassified_prompt = write_prompt(
        "unclassified-active-source.md",
        """# IOS26-SELF-TEST - Unclassified active source test

## Allowed files/directories
- Native/Ambitions/Domain/RepoIntelligenceSelfTestUnclassified.swift

## Forbidden files/directories
- No cloud LLM.

## Validation commands
```bash
python3 scripts/ambitions-champion-coverage-check.py --batch IOS26-SELF-TEST
```
""",
    )
    packet2, _markdown2, _md_path2 = context.build_packet("IOS26-SELF-TEST", unclassified_prompt, WORK / "unclassified-context.md", use_cache=False)
    risks = [row.get("risk") for row in packet2["advisory_red_risks"]]
    assert_true("unclassified active source" in risks, "unclassified active source prompt did not emit advisory Red risk")

    packet3, _markdown3, _md_path3 = context.build_packet("IOS26-T04F-B01", known_owner_prompt, md_path, use_cache=True)
    assert_true(packet3["cache_key"] == packet["cache_key"], "packet cache key changed without prompt/HEAD/CodeGraph status change")

    print("GREEN: repo-intelligence context self-test")
    print(f"wrote {md_path.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
