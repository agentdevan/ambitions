#!/usr/bin/env python3
"""Aggregate comparable Ambitions build benchmark samples."""

import argparse
import json
import math
import statistics
from pathlib import Path


IDENTITY_KEYS = ("commit", "package_path", "package_identity", "derived_data")
COHORT_STATES = ("warm", "cold")
COHORT_IDENTITY_KEYS = ("lane", "command", "scenario")
EXECUTION_IDENTITY_KEYS = ("run_id", "timestamp_utc")


def nonempty_text(value):
    return isinstance(value, str) and bool(value.strip())


def execution_identity(sample):
    for key in EXECUTION_IDENTITY_KEYS:
        value = sample.get(key)
        if nonempty_text(value):
            return f"{key}:{value}"
    return None


def exact_exit_code(value):
    if type(value) is not int:
        raise ValueError("exit_code must be an exact integer")
    return value


def load_samples(sample_paths):
    samples = []
    for name in sample_paths:
        path = Path(name)
        try:
            source = path.read_text(encoding="utf-8")
        except (OSError, UnicodeError) as error:
            raise ValueError(f"unable to read benchmark sample {path}: {error}") from error
        try:
            data = json.loads(source)
        except json.JSONDecodeError as error:
            raise ValueError(
                f"invalid JSON benchmark sample {path}: {error.msg}"
            ) from error
        entries = data if isinstance(data, list) else [data]
        if any(not isinstance(entry, dict) for entry in entries):
            raise ValueError(f"benchmark samples must be JSON objects: {path}")
        samples.extend(entries)
    return samples


def build_report(samples, target_seconds, require_samples=None):
    if not samples:
        raise ValueError("no benchmark samples")
    if any(not isinstance(sample, dict) for sample in samples):
        raise ValueError("benchmark samples must be JSON objects")
    try:
        target_seconds = float(target_seconds)
    except (TypeError, ValueError) as error:
        raise ValueError("benchmark requires finite nonnegative target seconds") from error
    if not math.isfinite(target_seconds) or target_seconds < 0:
        raise ValueError("benchmark requires finite nonnegative target seconds")
    if require_samples is not None and require_samples <= 0:
        raise ValueError("required sample count must be positive")

    identities = {tuple(sample.get(key) for key in IDENTITY_KEYS) for sample in samples}
    if len(identities) != 1:
        raise ValueError("mixed benchmark identities (commit/package/cache)")

    identity = dict(zip(IDENTITY_KEYS, next(iter(identities))))
    if require_samples is not None:
        missing_identity = [key for key, value in identity.items() if not nonempty_text(value)]
        if missing_identity:
            raise ValueError(
                "gate requires nonempty benchmark identity fields: "
                + ", ".join(missing_identity)
            )
        cohort_states = {sample.get("warm_cold") for sample in samples}
        if len(cohort_states) != 1 or not cohort_states.issubset(COHORT_STATES):
            raise ValueError("gate requires exactly one warm or cold cohort")

        cohort_identities = {
            tuple(sample.get(key) for key in COHORT_IDENTITY_KEYS)
            for sample in samples
        }
        if len(cohort_identities) != 1 or any(
            not nonempty_text(value) for value in next(iter(cohort_identities))
        ):
            raise ValueError(
                "gate requires identical nonempty cohort fields: "
                + ", ".join(COHORT_IDENTITY_KEYS)
            )

        execution_identities = [execution_identity(sample) for sample in samples]
        if any(identity is None for identity in execution_identities):
            raise ValueError(
                "gate requires a nonempty execution identity from run_id or timestamp_utc"
            )
        if len(set(execution_identities)) != len(execution_identities):
            raise ValueError("gate requires distinct execution identities for every sample")

    report = {"identity": identity}
    if require_samples is not None:
        report["cohort_identity"] = dict(
            zip(COHORT_IDENTITY_KEYS, next(iter(cohort_identities)))
        )
        report["execution_identities"] = execution_identities
    for state in COHORT_STATES:
        selected = [sample for sample in samples if sample.get("warm_cold") == state]
        if not selected:
            continue
        try:
            durations = [float(sample["duration_seconds"]) for sample in selected]
        except (KeyError, TypeError, ValueError) as error:
            raise ValueError(f"invalid {state} benchmark sample: {error}") from error
        exits = [exact_exit_code(sample.get("exit_code")) for sample in selected]
        if any(not math.isfinite(duration) or duration < 0 for duration in durations):
            raise ValueError(
                f"invalid {state} benchmark sample: expected finite nonnegative duration"
            )
        median = statistics.median(durations)
        worst = max(durations)
        cohort = {
            "sample_count": len(selected),
            "durations_seconds": durations,
            "median_seconds": median,
            "worst_seconds": worst,
            "exits": exits,
            "target_seconds": target_seconds,
        }
        miss_reasons = []
        if require_samples is not None:
            cohort["required_sample_count"] = require_samples
            cohort["sample_count_state"] = (
                "met" if len(selected) == require_samples else "miss"
            )
            if len(selected) != require_samples:
                miss_reasons.append("sample_count")
        if any(exit_code != 0 for exit_code in exits):
            miss_reasons.append("nonzero_exit")
        if median > target_seconds:
            miss_reasons.append("median")
        if require_samples is not None:
            cohort["miss_reasons"] = miss_reasons
        cohort["target_state"] = "miss" if miss_reasons else "met"
        report[state] = cohort
    return report


def report_misses_gate(report):
    cohorts = [report[state] for state in COHORT_STATES if state in report]
    return len(cohorts) != 1 or cohorts[0]["target_state"] != "met"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("samples", nargs="+")
    parser.add_argument("--target-seconds", type=float, required=True)
    parser.add_argument("--require-samples", type=int)
    parser.add_argument("--fail-on-miss", action="store_true")
    parser.add_argument("--output")
    args = parser.parse_args()
    if args.fail_on_miss and args.require_samples is None:
        parser.error("--fail-on-miss requires --require-samples")
    if args.require_samples is not None and args.require_samples <= 0:
        parser.error("--require-samples must be positive")

    try:
        samples = load_samples(args.samples)
        report = build_report(
            samples,
            args.target_seconds,
            require_samples=args.require_samples,
        )
    except ValueError as error:
        parser.error(str(error))
    payload = json.dumps(report, indent=2, sort_keys=True) + "\n"
    if args.output:
        Path(args.output).write_text(payload, encoding="utf-8")
    else:
        print(payload, end="")
    if args.fail_on_miss and report_misses_gate(report):
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
