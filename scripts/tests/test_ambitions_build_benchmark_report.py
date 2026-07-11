import importlib.util
import json
import os
import subprocess
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

    def sample(self, state, duration, exit_code=0, **identity):
        return {**self.sample_identity, **identity, "warm_cold": state, "duration_seconds": duration, "exit_code": exit_code}

    def test_warm_and_cold_are_separate_with_median_worst_exits_and_target(self):
        report = self.module.build_report([
            self.sample("warm", 3), self.sample("warm", 7, 1), self.sample("warm", 5),
            self.sample("cold", 20), self.sample("cold", 10),
        ], target_seconds=6)
        self.assertEqual(report["warm"], {"sample_count": 3, "median_seconds": 5, "worst_seconds": 7, "exits": [0, 1, 0], "target_state": "miss"})
        self.assertEqual(report["cold"]["median_seconds"], 15)
        self.assertEqual(report["cold"]["target_state"], "miss")

    def test_mixed_commit_package_or_cache_identity_is_rejected(self):
        keys = {"commit": "def", "package_path": "/other", "package_identity": "pkg-b", "derived_data": "/cache/b"}
        for key, value in keys.items():
            with self.subTest(key=key):
                with self.assertRaisesRegex(ValueError, "mixed benchmark identities"):
                    self.module.build_report([self.sample("warm", 1), self.sample("warm", 2, **{key: value})], 5)

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
