#!/usr/bin/env python3
"""Aggregate local eval-like JSON or JSONL result summaries."""
from __future__ import annotations

import argparse
import json
from pathlib import Path


def load_records(path: Path) -> list[dict]:
    if path.suffix == ".jsonl":
        records = []
        for lineno, line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
            if not line.strip():
                continue
            try:
                item = json.loads(line)
            except json.JSONDecodeError as exc:
                raise ValueError(f"Invalid JSONL {path}:{lineno}: {exc}") from exc
            if isinstance(item, dict):
                records.append(item)
        return records

    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        raise ValueError(f"Invalid JSON {path}: {exc}") from exc

    if isinstance(data, dict):
        return data.get("results", []) if isinstance(data.get("results"), list) else []
    return data if isinstance(data, list) else []


def verdict_for(record: dict) -> str | None:
    verdict = record.get("verdict")
    if isinstance(verdict, str):
        return verdict
    expected = record.get("expected")
    if isinstance(expected, dict) and isinstance(expected.get("verdict"), str):
        return expected["verdict"]
    return None


def main() -> int:
    parser = argparse.ArgumentParser(description="Score local report JSON data")
    parser.add_argument("report", nargs="+", help="Path(s) to JSON report")
    args = parser.parse_args()

    for path_s in args.report:
        path = Path(path_s)
        if not path.exists():
            print(f"Missing: {path}")
            return 1
        try:
            records = load_records(path)
        except ValueError as exc:
            print(exc)
            return 1

        pass_count = sum(1 for r in records if verdict_for(r) == "pass")
        fail_count = sum(1 for r in records if verdict_for(r) == "fail")
        unknown_count = len(records) - pass_count - fail_count
        print(
            json.dumps(
                {
                    "path": str(path),
                    "total": len(records),
                    "pass": pass_count,
                    "fail": fail_count,
                    "unknown": unknown_count,
                },
                indent=2,
            )
        )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
