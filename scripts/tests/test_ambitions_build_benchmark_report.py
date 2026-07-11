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
        self.identity = {"commit": "abc", "package_path": "/repo/Package.resolved", "package_identity": "pkg-a", "derived_data": "/cache/a"}

    def sample(self, state, duration, exit_code=0, **identity):
        return {**self.identity, **identity, "warm_cold": state, "duration_seconds": duration, "exit_code": exit_code}

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
            package = root / "Package.resolved"
            results = root / "results"
            fake_bin = root / "bin"
            fake_bin.mkdir()
            (fake_bin / "xcodebuild").write_text("#!/bin/sh\necho 'Xcode fixture'\n")
            os.chmod(fake_bin / "xcodebuild", 0o755)
            env = os.environ.copy()
            env["PATH"] = str(fake_bin) + os.pathsep + env["PATH"]
            env["AMBITIONS_PACKAGE_RESOLVED_PATH"] = str(package)
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

    def test_refresh_recomputes_identity_before_build_sample(self):
        source = BENCHMARK.read_text()
        refresh = source.index('run_step "refresh-packages"')
        recapture = source.index("capture_identity", refresh)
        build = source.index('run_step "build-for-testing"', refresh)
        self.assertLess(refresh, recapture)
        self.assertLess(recapture, build)


if __name__ == "__main__":
    unittest.main()
