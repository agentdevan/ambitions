#!/usr/bin/env python3
"""Aggregate comparable Ambitions build benchmark samples."""

import argparse
import json
import statistics
from pathlib import Path


IDENTITY_KEYS = ("commit", "package_path", "package_identity", "derived_data")


def build_report(samples, target_seconds):
    if not samples:
        raise ValueError("no benchmark samples")
    identities = {tuple(sample.get(key) for key in IDENTITY_KEYS) for sample in samples}
    if len(identities) != 1:
        raise ValueError("mixed benchmark identities (commit/package/cache)")
    report = {"identity": dict(zip(IDENTITY_KEYS, next(iter(identities))))}
    for state in ("warm", "cold"):
        selected = [sample for sample in samples if sample.get("warm_cold") == state]
        if not selected:
            continue
        durations = [float(sample["duration_seconds"]) for sample in selected]
        median = statistics.median(durations)
        worst = max(durations)
        report[state] = {
            "sample_count": len(selected),
            "median_seconds": median,
            "worst_seconds": worst,
            "exits": [int(sample["exit_code"]) for sample in selected],
            "target_state": "met" if median <= target_seconds and all(int(s["exit_code"]) == 0 for s in selected) else "miss",
        }
    return report


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("samples", nargs="+")
    parser.add_argument("--target-seconds", type=float, required=True)
    parser.add_argument("--output")
    args = parser.parse_args()
    samples = []
    for name in args.samples:
        data = json.loads(Path(name).read_text(encoding="utf-8"))
        samples.extend(data if isinstance(data, list) else [data])
    try:
        payload = json.dumps(build_report(samples, args.target_seconds), indent=2, sort_keys=True) + "\n"
    except ValueError as error:
        parser.error(str(error))
    if args.output:
        Path(args.output).write_text(payload, encoding="utf-8")
    else:
        print(payload, end="")


if __name__ == "__main__":
    main()
