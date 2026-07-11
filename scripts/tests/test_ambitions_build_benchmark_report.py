import importlib.util
import json
import math
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).parents[1] / "ambitions-build-benchmark-report.py"
BENCHMARK = Path(__file__).parents[1] / "ambitions-xcode-benchmark.sh"
REPO_ROOT = SCRIPT.parents[1]


def load_module():
    spec = importlib.util.spec_from_file_location("benchmark_report", SCRIPT)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class BenchmarkReportTests(unittest.TestCase):
    def setUp(self):
        self.module = load_module()
        self.sample_identity = {"commit": "abc", "package_path": "/repo/Package.resolved", "package_identity": "pkg-a", "derived_data": "/cache/a"}
        self.sample_number = 0

    def sample(self, state, duration, exit_code=0, **identity):
        self.sample_number += 1
        return {
            **self.sample_identity,
            "timestamp_utc": f"20260711T000000Z-{self.sample_number}",
            "lane": "fixture-focused",
            "command": "run fixture focused test",
            "scenario": "fixture-focused",
            **identity,
            "warm_cold": state,
            "duration_seconds": duration,
            "exit_code": exit_code,
        }

    def run_cli(self, root, samples, *, require_samples=None, fail_on_miss=False, output=True):
        sample_paths = []
        for index, sample in enumerate(samples, start=1):
            path = root / f"sample-{index}.json"
            path.write_text(json.dumps(sample), encoding="utf-8")
            sample_paths.append(path)
        command = [
            sys.executable,
            str(SCRIPT),
            *(str(path) for path in sample_paths),
            "--target-seconds",
            "30",
        ]
        if require_samples is not None:
            command.extend(["--require-samples", str(require_samples)])
        if fail_on_miss:
            command.append("--fail-on-miss")
        output_path = root / "report.json"
        if output:
            command.extend(["--output", str(output_path)])
        result = subprocess.run(command, cwd=REPO_ROOT, text=True, capture_output=True)
        return result, output_path

    def test_warm_and_cold_are_separate_with_median_worst_exits_and_target(self):
        report = self.module.build_report([
            self.sample("warm", 3), self.sample("warm", 7, 1), self.sample("warm", 5),
            self.sample("cold", 20), self.sample("cold", 10),
        ], target_seconds=6)
        self.assertEqual(report["warm"], {
            "sample_count": 3,
            "durations_seconds": [3.0, 7.0, 5.0],
            "median_seconds": 5,
            "worst_seconds": 7,
            "exits": [0, 1, 0],
            "target_seconds": 6,
            "target_state": "miss",
        })
        self.assertEqual(report["cold"]["median_seconds"], 15)
        self.assertEqual(report["cold"]["target_state"], "miss")

    def test_three_samples_with_median_30_meet_gate_and_report_worst(self):
        report = self.module.build_report(
            [self.sample("warm", 20), self.sample("warm", 30), self.sample("warm", 90)],
            target_seconds=30,
            require_samples=3,
        )
        self.assertEqual(report["warm"], {
            "sample_count": 3,
            "durations_seconds": [20.0, 30.0, 90.0],
            "median_seconds": 30,
            "worst_seconds": 90,
            "exits": [0, 0, 0],
            "target_seconds": 30,
            "required_sample_count": 3,
            "sample_count_state": "met",
            "miss_reasons": [],
            "target_state": "met",
        })

    def test_two_or_four_samples_fail_exact_count_gate(self):
        for count in (2, 4):
            with self.subTest(count=count):
                report = self.module.build_report(
                    [self.sample("warm", 10 + index) for index in range(count)],
                    target_seconds=30,
                    require_samples=3,
                )
                self.assertEqual(report["warm"]["sample_count_state"], "miss")
                self.assertEqual(report["warm"]["target_state"], "miss")
                self.assertEqual(report["warm"]["miss_reasons"], ["sample_count"])

    def test_median_over_30_fails_gate(self):
        report = self.module.build_report(
            [self.sample("warm", 30), self.sample("warm", 31), self.sample("warm", 32)],
            target_seconds=30,
            require_samples=3,
        )
        self.assertEqual(report["warm"]["median_seconds"], 31)
        self.assertEqual(report["warm"]["miss_reasons"], ["median"])
        self.assertEqual(report["warm"]["target_state"], "miss")

    def test_any_nonzero_exit_fails_gate(self):
        report = self.module.build_report(
            [self.sample("warm", 10), self.sample("warm", 11, 65), self.sample("warm", 12)],
            target_seconds=30,
            require_samples=3,
        )
        self.assertEqual(report["warm"]["exits"], [0, 65, 0])
        self.assertEqual(report["warm"]["miss_reasons"], ["nonzero_exit"])
        self.assertEqual(report["warm"]["target_state"], "miss")

    def test_mixed_commit_package_or_cache_identity_is_rejected(self):
        keys = {"commit": "def", "package_path": "/other", "package_identity": "pkg-b", "derived_data": "/cache/b"}
        for key, value in keys.items():
            with self.subTest(key=key):
                with self.assertRaisesRegex(ValueError, "mixed benchmark identities"):
                    self.module.build_report([self.sample("warm", 1), self.sample("warm", 2, **{key: value})], 5)

    def test_missing_identity_is_invalid_gate_evidence(self):
        for key in self.module.IDENTITY_KEYS:
            for value in (None, "", "   "):
                with self.subTest(key=key, value=value):
                    samples = [self.sample("warm", duration, **{key: value}) for duration in (10, 11, 12)]
                    with self.assertRaisesRegex(ValueError, "nonempty benchmark identity"):
                        self.module.build_report(samples, 30, require_samples=3)

    def test_mixed_warm_and_cold_samples_are_invalid_gate_evidence(self):
        samples = [self.sample("warm", 10), self.sample("warm", 11), self.sample("cold", 12)]
        with self.assertRaisesRegex(ValueError, "exactly one warm or cold cohort"):
            self.module.build_report(samples, 30, require_samples=3)

    def test_unknown_state_is_invalid_gate_evidence(self):
        samples = [self.sample("unknown", 10), self.sample("unknown", 11), self.sample("unknown", 12)]
        with self.assertRaisesRegex(ValueError, "exactly one warm or cold cohort"):
            self.module.build_report(samples, 30, require_samples=3)

    def test_negative_or_nonfinite_duration_is_invalid_evidence(self):
        for duration in (-1, math.inf, math.nan):
            with self.subTest(duration=duration):
                samples = [self.sample("warm", 10), self.sample("warm", 11), self.sample("warm", duration)]
                with self.assertRaisesRegex(ValueError, "finite nonnegative duration"):
                    self.module.build_report(samples, 30, require_samples=3)

    def test_negative_or_nonfinite_target_is_invalid_evidence(self):
        samples = [self.sample("warm", 10), self.sample("warm", 11), self.sample("warm", 12)]
        for target in (-1, math.inf, math.nan):
            with self.subTest(target=target):
                with self.assertRaisesRegex(ValueError, "finite nonnegative target"):
                    self.module.build_report(samples, target, require_samples=3)

    def test_duplicate_execution_identity_is_invalid_gate_evidence(self):
        samples = [self.sample("warm", 10), self.sample("warm", 11), self.sample("warm", 12)]
        for sample in samples:
            sample["timestamp_utc"] = "20260711T000000Z"
        with self.assertRaisesRegex(ValueError, "distinct execution identities"):
            self.module.build_report(samples, 30, require_samples=3)

    def test_missing_execution_identity_is_invalid_gate_evidence(self):
        samples = [self.sample("warm", 10), self.sample("warm", 11), self.sample("warm", 12)]
        samples[1]["timestamp_utc"] = ""
        with self.assertRaisesRegex(ValueError, "nonempty execution identity"):
            self.module.build_report(samples, 30, require_samples=3)

    def test_mixed_lane_command_or_scenario_is_invalid_gate_evidence(self):
        replacements = {
            "lane": "other-lane",
            "command": "run a different command",
            "scenario": "other-scenario",
        }
        for key, value in replacements.items():
            with self.subTest(key=key):
                samples = [self.sample("warm", 10), self.sample("warm", 11), self.sample("warm", 12)]
                samples[1][key] = value
                with self.assertRaisesRegex(ValueError, "identical nonempty cohort fields"):
                    self.module.build_report(samples, 30, require_samples=3)

    def test_missing_lane_command_or_scenario_is_invalid_gate_evidence(self):
        for key in ("lane", "command", "scenario"):
            with self.subTest(key=key):
                samples = [self.sample("warm", 10), self.sample("warm", 11), self.sample("warm", 12)]
                samples[1][key] = ""
                with self.assertRaisesRegex(ValueError, "identical nonempty cohort fields"):
                    self.module.build_report(samples, 30, require_samples=3)

    def test_informative_mode_remains_compatible_with_two_cohorts(self):
        report = self.module.build_report(
            [self.sample("warm", 10), self.sample("cold", 439)],
            target_seconds=30,
        )
        self.assertEqual(report["warm"]["target_state"], "met")
        self.assertEqual(report["cold"]["target_state"], "miss")
        self.assertNotIn("required_sample_count", report["warm"])

    def test_cli_successful_gate_writes_report_and_exits_zero(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            result, output_path = self.run_cli(
                root,
                [self.sample("warm", 20), self.sample("warm", 30), self.sample("warm", 90)],
                require_samples=3,
                fail_on_miss=True,
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            report = json.loads(output_path.read_text(encoding="utf-8"))
            self.assertEqual(report["warm"]["target_state"], "met")
            self.assertEqual(report["warm"]["worst_seconds"], 90)

    def test_cli_exits_one_on_gate_miss_after_writing_report(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            result, output_path = self.run_cli(
                root,
                [self.sample("warm", 31), self.sample("warm", 32)],
                require_samples=3,
                fail_on_miss=True,
            )
            self.assertEqual(result.returncode, 1, result.stderr)
            report = json.loads(output_path.read_text(encoding="utf-8"))
            self.assertEqual(report["warm"]["sample_count"], 2)
            self.assertEqual(report["warm"]["target_state"], "miss")
            self.assertEqual(report["warm"]["miss_reasons"], ["sample_count", "median"])

    def test_cli_gate_miss_is_informative_without_fail_on_miss(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            result, output_path = self.run_cli(
                root,
                [self.sample("warm", 31), self.sample("warm", 32), self.sample("warm", 33)],
                require_samples=3,
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(json.loads(output_path.read_text())["warm"]["target_state"], "miss")

    def test_cli_rejects_fail_on_miss_without_required_count(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            result, output_path = self.run_cli(
                root,
                [self.sample("warm", 10)],
                fail_on_miss=True,
            )
            self.assertEqual(result.returncode, 2)
            self.assertIn("--fail-on-miss requires --require-samples", result.stderr)
            self.assertFalse(output_path.exists())

    def test_cli_rejects_nonpositive_required_count(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            result, output_path = self.run_cli(
                root,
                [self.sample("warm", 10)],
                require_samples=0,
                fail_on_miss=True,
            )
            self.assertEqual(result.returncode, 2)
            self.assertIn("--require-samples must be positive", result.stderr)
            self.assertFalse(output_path.exists())

    def test_cli_invalid_identity_exits_two_without_writing_report(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            samples = [self.sample("warm", duration, commit="") for duration in (10, 11, 12)]
            result, output_path = self.run_cli(root, samples, require_samples=3, fail_on_miss=True)
            self.assertEqual(result.returncode, 2)
            self.assertIn("nonempty benchmark identity", result.stderr)
            self.assertFalse(output_path.exists())

    def test_cli_mixed_cohorts_exit_two_without_writing_report(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            samples = [self.sample("warm", 10), self.sample("warm", 11), self.sample("cold", 439)]
            result, output_path = self.run_cli(root, samples, require_samples=3, fail_on_miss=True)
            self.assertEqual(result.returncode, 2)
            self.assertIn("exactly one warm or cold cohort", result.stderr)
            self.assertFalse(output_path.exists())

    def test_cli_duplicate_execution_evidence_exits_two_without_writing_report(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            samples = [self.sample("warm", 10), self.sample("warm", 11), self.sample("warm", 12)]
            for sample in samples:
                sample["timestamp_utc"] = "20260711T000000Z"
            result, output_path = self.run_cli(root, samples, require_samples=3, fail_on_miss=True)
            self.assertEqual(result.returncode, 2)
            self.assertIn("distinct execution identities", result.stderr)
            self.assertFalse(output_path.exists())

    def test_cli_prints_informative_report_without_new_options(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            result, _ = self.run_cli(
                root,
                [self.sample("warm", 10), self.sample("cold", 439)],
                output=False,
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            report = json.loads(result.stdout)
            self.assertEqual(report["warm"]["target_state"], "met")
            self.assertEqual(report["cold"]["target_state"], "miss")

    def test_package_mutation_changes_captured_identity_and_cannot_group(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            package = root / "Packages/AmbitionsDesignSystem/Package.swift"
            package.parent.mkdir(parents=True)
            (root / "project.yml").write_text("packages:\n  AmbitionsDesignSystem:\n    path: Packages/AmbitionsDesignSystem\n")
            results = root / "results"
            fake_bin = root / "bin"
            fake_bin.mkdir()
            (fake_bin / "xcodebuild").write_text("#!/bin/sh\necho 'Xcode fixture'\n")
            os.chmod(fake_bin / "xcodebuild", 0o755)
            env = os.environ.copy()
            env["PATH"] = str(fake_bin) + os.pathsep + env["PATH"]
            env["AMBITIONS_REPO_ROOT"] = str(root)
            samples = []
            for batch, content in (("before", "one"), ("after", "two")):
                package.write_text(content)
                subprocess.run(
                    ["bash", str(BENCHMARK), "--results-dir", str(results), "--batch", batch, "--lane", "fixture", "--", "true"],
                    cwd=REPO_ROOT, env=env, check=True, capture_output=True, text=True,
                )
                summary = next((results / batch).glob("*/benchmark-summary.json"))
                samples.append(json.loads(summary.read_text()))
            self.assertNotEqual(samples[0]["package_identity"], samples[1]["package_identity"])
            with self.assertRaisesRegex(ValueError, "mixed benchmark identities"):
                self.module.build_report(samples, 10)

    def identity(self, root):
        env = os.environ.copy()
        env["AMBITIONS_REPO_ROOT"] = str(root)
        return subprocess.run(
            ["bash", str(BENCHMARK), "--identity"],
            cwd=REPO_ROOT, env=env, text=True, capture_output=True,
        )

    def manifest_fixture(self, root):
        package = root / "Packages/AmbitionsDesignSystem/Package.swift"
        package.parent.mkdir(parents=True)
        package.write_text("// swift-tools-version: 6.0\n")
        (root / "project.yml").write_text(
            "packages:\n  AmbitionsDesignSystem:\n    path: Packages/AmbitionsDesignSystem\n"
        )
        return package

    def test_identity_ignores_nested_build_and_tools_resolved_files(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            self.manifest_fixture(root)
            nested = root / "tools/mcp/.build/checkouts/dependency/Package.resolved"
            nested.parent.mkdir(parents=True)
            nested.write_text("wrong")
            result = self.identity(root)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn("package_identity_source=manifest-fallback", result.stdout)
            self.assertNotIn(str(nested), result.stdout)

    def test_canonical_workspace_resolved_wins(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            self.manifest_fixture(root)
            resolved = root / "Ambitions.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"
            resolved.parent.mkdir(parents=True)
            resolved.write_text("resolved")
            result = self.identity(root)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn("package_identity_source=workspace-resolved", result.stdout)
            self.assertIn(f"package_path={resolved}", result.stdout)

    def test_manifest_fallback_changes_with_manifest_and_project_input(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            package = self.manifest_fixture(root)
            first = self.identity(root).stdout
            package.write_text("// swift-tools-version: 6.1\n")
            second = self.identity(root).stdout
            (root / "project.yml").write_text("packages:\n  AmbitionsDesignSystem:\n    path: Packages/Other\n")
            third = self.identity(root).stdout
            self.assertNotEqual(first, second)
            self.assertNotEqual(second, third)

    def test_ambiguous_workspace_resolved_is_explicit(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            self.manifest_fixture(root)
            for path in (
                "Ambitions.xcworkspace/xcshareddata/swiftpm/Package.resolved",
                "Ambitions.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved",
            ):
                candidate = root / path
                candidate.parent.mkdir(parents=True)
                candidate.write_text(path)
            result = self.identity(root)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("package_identity_status=ambiguous", result.stdout)

    def test_absent_manifest_inputs_are_explicit(self):
        with tempfile.TemporaryDirectory() as temporary:
            result = self.identity(Path(temporary))
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("package_identity_status=unknown", result.stdout)

    def test_refresh_recomputes_identity_before_build_sample(self):
        source = BENCHMARK.read_text()
        refresh = source.index('run_step "refresh-packages"')
        recapture = source.index("capture_identity", refresh)
        build = source.index('run_step "build-for-testing"', refresh)
        self.assertLess(refresh, recapture)
        self.assertLess(recapture, build)


if __name__ == "__main__":
    unittest.main()
