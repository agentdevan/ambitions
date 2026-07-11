import importlib.util
import hashlib
import contextlib
import io
import json
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "scripts" / "ambitions-module-candidate-gate.py"
POLICY = ROOT / "docs" / "qa" / "architecture" / "module-candidate-policy.json"


def load_gate():
    spec = importlib.util.spec_from_file_location("ambitions_module_candidate_gate", SCRIPT)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


class ModuleCandidateGateTests(unittest.TestCase):
    def setUp(self) -> None:
        self.gate = load_gate()
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.paths = [
            "Native/Ambitions/Core/Time/A.swift",
            "Native/Ambitions/Core/Time/B.swift",
        ]
        for index, relative in enumerate(self.paths):
            path = self.root / relative
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(f"struct Candidate{index} {{}}\n", encoding="utf-8")

    def thresholds(self) -> dict:
        return {
            "historyMaximumFirstParentCommits": 250,
            "historyMinimumFirstParentCommits": 100,
            "productionHighChurnPercentile": 0.90,
            "benchmarkSamplesPerCohort": 3,
            "moduleTestMedianMaximumSeconds": 30.0,
            "leafProofMedianMaximumSeconds": 60.0,
            "leafProofMinimumHostedImprovementFraction": 0.25,
            "candidateWorstMaximumHostedRatio": 1.0,
            "appNoChangeMaximumRegressionFraction": 0.10,
        }

    def identity(self, source_hash: str) -> dict:
        return {
            "commit": "a" * 40,
            "sourceContentHash": source_hash,
            "packageIdentity": "resolved:fixture",
            "derivedDataPath": ".codex/DerivedData/Ambitions",
            "cacheState": "warm",
        }

    def bind(self, payload: dict) -> dict:
        payload["evidenceDigest"] = self.gate.evidence_digest(payload)
        return payload

    def artifact(self, relative: str, contents: str) -> tuple[str, str]:
        path = self.root / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(contents, encoding="utf-8")
        return relative, "sha256:" + hashlib.sha256(path.read_bytes()).hexdigest()

    def samples(self, durations: list[float], source_hash: str, scenario: str = "scenario") -> list[dict]:
        identity = self.identity(source_hash)
        rows = []
        for index, value in enumerate(durations, start=1):
            artifact = self.artifact(
                f".codex/evidence/benchmarks/{scenario}-{index}.json",
                f"{scenario} run {index} duration {value}\n",
            )
            rows.append(self.bind({
                **identity,
                "runID": f"{scenario}-{index}",
                "lane": scenario,
                "scenario": scenario,
                "command": f"run {scenario}",
                "exitCode": 0,
                "executedTests": 1,
                "durationSeconds": value,
                "artifact": artifact[0],
                "artifactDigest": artifact[1],
            }))
        return rows

    def authorized_candidate(self) -> dict:
        source_hash = self.gate.source_set_hash(self.root, self.paths)
        commits = [f"{index:040x}" for index in range(1, 101)]
        compiler_artifact = self.artifact(".codex/evidence/compiler.json", "compiler closure passed\n")
        graph_artifact = self.artifact(".codex/evidence/graph.json", "acyclic hostless graph\n")
        api_artifact = self.artifact(".codex/evidence/public-api.json", "two compiler declarations approved\n")
        routes_artifact = self.artifact(".codex/evidence/routes.json", "all candidate files routed\n")
        module_artifact = self.artifact(".codex/evidence/module-tests.json", "four module tests passed\n")
        integration_artifact = self.artifact(".codex/evidence/integration-tests.json", "eight integration tests passed\n")
        review_artifact = self.artifact(".codex/evidence/review.md", "No Critical or Important findings.\n")
        history_artifact = self.artifact(".codex/evidence/history.json", "100 first-parent commits before extraction\n")
        candidate = {
            "id": "candidate-time-hot-leaf",
            "status": "authorized",
            "proposedTarget": "AmbitionsHotLeaf",
            "prospectiveGateEvidence": True,
            "sourceSet": {
                "selection": "explicit_files",
                "files": list(self.paths),
                "contentHash": source_hash,
            },
            "history": {
                "sourceContentHash": source_hash,
                "preExtractionHead": commits[0],
                "extractionCommit": "f" * 40,
                "availableFirstParentCommits": 100,
                "windowCommitCount": 100,
                "firstParentCommits": commits,
                "candidateFileTouches": {path: value for path, value in zip(self.paths, [12, 14])},
                "productionFileTouches": [10] * 10 + [1] * 90,
                "artifact": history_artifact[0],
                "artifactDigest": history_artifact[1],
            },
            "compilerClosure": {
                "kind": "compiler_build",
                "status": "passed",
                "sourceContentHash": source_hash,
                "artifact": compiler_artifact[0],
                "artifactDigest": compiler_artifact[1],
            },
            "graph": {
                "acyclic": True,
                "singleProductionMembership": True,
                "hostlessModuleTests": True,
                "appReachableFromModuleTests": False,
                "sourceContentHash": source_hash,
                "artifact": graph_artifact[0],
                "artifactDigest": graph_artifact[1],
            },
            "publicAPI": {
                "status": "approved",
                "sourceContentHash": source_hash,
                "artifact": api_artifact[0],
                "approvedContractCount": 2,
                "compilerPublicDeclarationCount": 2,
                "unapprovedContractCount": 0,
                "artifactDigest": api_artifact[1],
            },
            "changedFileRoutes": {
                "status": "complete",
                "sourceContentHash": source_hash,
                "artifact": routes_artifact[0],
                "artifactDigest": routes_artifact[1],
                "coveredSourceFiles": list(self.paths),
                "unroutedFileCount": 0,
            },
            "tests": {
                "module": {"status": "passed", "executed": 4, "sourceContentHash": source_hash, "artifact": module_artifact[0], "artifactDigest": module_artifact[1]},
                "integration": {"status": "passed", "executed": 8, "sourceContentHash": source_hash, "artifact": integration_artifact[0], "artifactDigest": integration_artifact[1]},
            },
            "review": {
                "status": "approved",
                "sourceContentHash": source_hash,
                "artifact": review_artifact[0],
                "criticalFindings": 0,
                "importantFindings": 0,
                "artifactDigest": review_artifact[1],
            },
            "benchmarks": {
                "moduleTest": self.samples([10.0, 12.0, 14.0], source_hash, "module-test"),
                "leafProofCandidate": self.samples([30.0, 36.0, 40.0], source_hash, "leaf-candidate"),
                "leafProofHostedBaseline": self.samples([60.0, 60.0, 65.0], source_hash, "leaf-hosted"),
                "appNoChangeCandidate": self.samples([20.0, 21.0, 22.0], source_hash, "app-candidate"),
                "appNoChangeBaseline": self.samples([20.0, 20.0, 21.0], source_hash, "app-baseline"),
            },
        }
        candidate["history"] = self.bind(candidate["history"])
        for key in ("compilerClosure", "graph", "publicAPI", "changedFileRoutes"):
            candidate[key] = self.bind(candidate[key])
        candidate["tests"]["module"] = self.bind(candidate["tests"]["module"])
        candidate["tests"]["integration"] = self.bind(candidate["tests"]["integration"])
        candidate["review"] = self.bind(candidate["review"])
        return candidate

    def result(self, candidate: dict):
        return self.gate.evaluate_candidate(self.root, self.thresholds(), candidate)

    def test_folder_only_candidate_is_rejected(self) -> None:
        candidate = self.authorized_candidate()
        candidate["sourceSet"]["selection"] = "folder_derived"
        result = self.result(candidate)
        self.assertEqual(result.status, "rejected")
        self.assertIn("source set is folder-derived rather than explicit", result.findings)

        stale = self.authorized_candidate()
        stale["sourceSet"]["selection"] = "folder_derived"
        stale["sourceSet"]["contentHash"] = "sha256:" + "0" * 64
        result = self.result(stale)
        self.assertIn("source content hash is stale", result.findings)

    def test_missing_duplicate_or_noncanonical_source_is_rejected(self) -> None:
        for files, expected in [
            ([*self.paths, self.paths[0]], "source set contains duplicate paths"),
            (["Native/Ambitions/Features/Legacy.swift"], "noncanonical source path: Native/Ambitions/Features/Legacy.swift"),
            (["Native/Ambitions/Core/Time/Missing.swift"], "source file is missing: Native/Ambitions/Core/Time/Missing.swift"),
        ]:
            with self.subTest(files=files):
                candidate = self.authorized_candidate()
                candidate["sourceSet"]["files"] = files
                result = self.result(candidate)
                self.assertEqual(result.status, "rejected")
                self.assertIn(expected, result.findings)

        empty = self.authorized_candidate()
        empty["sourceSet"]["files"] = []
        result = self.result(empty)
        self.assertEqual(result.status, "rejected")
        self.assertIn("source set is empty", result.findings)

    def test_fewer_than_100_history_commits_is_rejected(self) -> None:
        candidate = self.authorized_candidate()
        candidate["history"]["availableFirstParentCommits"] = 99
        candidate["history"]["firstParentCommits"] = candidate["history"]["firstParentCommits"][:99]
        candidate["history"]["windowCommitCount"] = 99
        candidate["history"] = self.bind({key: value for key, value in candidate["history"].items() if key != "evidenceDigest"})
        result = self.result(candidate)
        self.assertEqual(result.status, "rejected")
        self.assertIn("first-parent history has fewer commits than policy minimum", result.findings)

    def test_extraction_commit_cannot_inflate_baseline_churn(self) -> None:
        candidate = self.authorized_candidate()
        candidate["history"]["extractionCommit"] = candidate["history"]["firstParentCommits"][1]
        candidate["history"] = self.bind({key: value for key, value in candidate["history"].items() if key != "evidenceDigest"})
        result = self.result(candidate)
        self.assertEqual(result.status, "rejected")
        self.assertIn("extraction commit is included in the pre-extraction history window", result.findings)

    def test_low_churn_candidate_is_rejected(self) -> None:
        candidate = self.authorized_candidate()
        candidate["history"]["candidateFileTouches"] = {path: 2 for path in self.paths}
        candidate["history"] = self.bind({key: value for key, value in candidate["history"].items() if key != "evidenceDigest"})
        result = self.result(candidate)
        self.assertEqual(result.status, "rejected")
        self.assertIn("candidate median file touches are below the production high-churn cohort", result.findings)

    def test_import_only_or_stale_compiler_closure_is_not_proof(self) -> None:
        import_only = self.authorized_candidate()
        import_only["compilerClosure"]["kind"] = "import_scan"
        import_only["compilerClosure"] = self.bind({key: value for key, value in import_only["compilerClosure"].items() if key != "evidenceDigest"})
        self.assertEqual(self.result(import_only).status, "rejected")

        stale = self.authorized_candidate()
        stale["compilerClosure"]["sourceContentHash"] = "sha256:" + "0" * 64
        stale["compilerClosure"] = self.bind({key: value for key, value in stale["compilerClosure"].items() if key != "evidenceDigest"})
        result = self.result(stale)
        self.assertEqual(result.status, "observed")
        self.assertIn("compiler closure evidence is stale for the source set", result.findings)

    def test_cycle_duplicate_membership_or_app_reach_is_rejected(self) -> None:
        mutations = [
            ("acyclic", False, "candidate target graph contains a cycle"),
            ("singleProductionMembership", False, "candidate source lacks single production membership"),
            ("hostlessModuleTests", False, "module tests are not hostless"),
            ("appReachableFromModuleTests", True, "module tests can reach the app target"),
        ]
        for key, value, expected in mutations:
            with self.subTest(key=key):
                candidate = self.authorized_candidate()
                candidate["graph"][key] = value
                candidate["graph"] = self.bind({name: item for name, item in candidate["graph"].items() if name != "evidenceDigest"})
                result = self.result(candidate)
                self.assertEqual(result.status, "rejected")
                self.assertIn(expected, result.findings)

    def test_unapproved_public_api_or_missing_route_is_rejected(self) -> None:
        public = self.authorized_candidate()
        public["publicAPI"]["status"] = "unapproved"
        public["publicAPI"] = self.bind({key: value for key, value in public["publicAPI"].items() if key != "evidenceDigest"})
        self.assertEqual(self.result(public).status, "rejected")

        route = self.authorized_candidate()
        route["changedFileRoutes"]["unroutedFileCount"] = 1
        route["changedFileRoutes"] = self.bind({key: value for key, value in route["changedFileRoutes"].items() if key != "evidenceDigest"})
        result = self.result(route)
        self.assertEqual(result.status, "rejected")
        self.assertIn("changed-file routes do not cover the complete source set", result.findings)

    def test_zero_test_or_failing_test_proof_is_rejected(self) -> None:
        zero = self.authorized_candidate()
        zero["tests"]["module"]["executed"] = 0
        zero["tests"]["module"] = self.bind({key: value for key, value in zero["tests"]["module"].items() if key != "evidenceDigest"})
        self.assertEqual(self.result(zero).status, "rejected")

        failed = self.authorized_candidate()
        failed["tests"]["integration"]["status"] = "failed"
        failed["tests"]["integration"] = self.bind({key: value for key, value in failed["tests"]["integration"].items() if key != "evidenceDigest"})
        result = self.result(failed)
        self.assertEqual(result.status, "rejected")
        self.assertIn("integration test proof did not pass", result.findings)

    def test_benchmark_sets_require_exactly_three_stable_samples(self) -> None:
        short = self.authorized_candidate()
        short["benchmarks"]["moduleTest"] = short["benchmarks"]["moduleTest"][:2]
        self.assertEqual(self.result(short).status, "observed")

        mixed = self.authorized_candidate()
        mixed["benchmarks"]["leafProofCandidate"][1]["packageIdentity"] = "resolved:different"
        result = self.result(mixed)
        self.assertEqual(result.status, "rejected")
        self.assertIn("benchmark samples do not share one stable identity", result.findings)

    def test_leaf_module_or_app_regression_threshold_miss_is_rejected(self) -> None:
        cases = []
        module = self.authorized_candidate()
        module["benchmarks"]["moduleTest"] = self.samples([31.0, 32.0, 33.0], module["sourceSet"]["contentHash"], "module-test")
        cases.append(module)
        leaf = self.authorized_candidate()
        leaf["benchmarks"]["leafProofCandidate"] = self.samples([61.0, 62.0, 63.0], leaf["sourceSet"]["contentHash"], "leaf-candidate")
        cases.append(leaf)
        worst = self.authorized_candidate()
        worst["benchmarks"]["leafProofCandidate"] = self.samples([30.0, 35.0, 70.0], worst["sourceSet"]["contentHash"], "leaf-candidate")
        cases.append(worst)
        app = self.authorized_candidate()
        app["benchmarks"]["appNoChangeCandidate"] = self.samples([24.0, 25.0, 26.0], app["sourceSet"]["contentHash"], "app-candidate")
        cases.append(app)
        for candidate in cases:
            with self.subTest(candidate=candidate["benchmarks"]):
                self.assertEqual(self.result(candidate).status, "rejected")

    def test_explicit_high_churn_closed_faster_candidate_is_authorized(self) -> None:
        result = self.result(self.authorized_candidate())
        self.assertEqual(result.status, "authorized")
        self.assertEqual(result.findings, ())

    def test_history_window_is_unique_ordered_and_digest_bound(self) -> None:
        duplicate = self.authorized_candidate()
        duplicate["history"]["firstParentCommits"][2] = duplicate["history"]["firstParentCommits"][1]
        duplicate["history"] = self.bind({key: value for key, value in duplicate["history"].items() if key != "evidenceDigest"})
        self.assertEqual(self.result(duplicate).status, "rejected")

        wrong_head = self.authorized_candidate()
        wrong_head["history"]["preExtractionHead"] = wrong_head["history"]["firstParentCommits"][1]
        wrong_head["history"] = self.bind({key: value for key, value in wrong_head["history"].items() if key != "evidenceDigest"})
        self.assertEqual(self.result(wrong_head).status, "rejected")

        tampered = self.authorized_candidate()
        tampered["history"]["candidateFileTouches"][self.paths[0]] = 99
        self.assertEqual(self.result(tampered).status, "rejected")

    def test_public_api_count_and_route_source_binding_are_exact(self) -> None:
        public = self.authorized_candidate()
        public["publicAPI"]["compilerPublicDeclarationCount"] = 3
        public["publicAPI"] = self.bind({key: value for key, value in public["publicAPI"].items() if key != "evidenceDigest"})
        self.assertEqual(self.result(public).status, "rejected")

        route = self.authorized_candidate()
        route["changedFileRoutes"]["coveredSourceFiles"] = self.paths[:1]
        route["changedFileRoutes"] = self.bind({key: value for key, value in route["changedFileRoutes"].items() if key != "evidenceDigest"})
        self.assertEqual(self.result(route).status, "rejected")

    def test_replayed_or_nonzero_benchmark_sample_is_rejected(self) -> None:
        replayed = self.authorized_candidate()
        replayed["benchmarks"]["moduleTest"][1]["runID"] = replayed["benchmarks"]["moduleTest"][0]["runID"]
        replayed["benchmarks"]["moduleTest"][1] = self.bind({key: value for key, value in replayed["benchmarks"]["moduleTest"][1].items() if key != "evidenceDigest"})
        self.assertEqual(self.result(replayed).status, "rejected")

        failed = self.authorized_candidate()
        failed["benchmarks"]["leafProofCandidate"][0]["exitCode"] = 1
        failed["benchmarks"]["leafProofCandidate"][0] = self.bind({key: value for key, value in failed["benchmarks"]["leafProofCandidate"][0].items() if key != "evidenceDigest"})
        self.assertEqual(self.result(failed).status, "rejected")

        nonfinite = self.authorized_candidate()
        nonfinite["benchmarks"]["moduleTest"][0]["durationSeconds"] = float("nan")
        nonfinite["benchmarks"]["moduleTest"][0] = self.bind({key: value for key, value in nonfinite["benchmarks"]["moduleTest"][0].items() if key != "evidenceDigest"})
        with self.assertRaises(self.gate.EvidenceFormatError):
            self.result(nonfinite)

    def test_tampered_structured_proof_is_not_authorized(self) -> None:
        candidate = self.authorized_candidate()
        candidate["graph"]["artifact"] = ".codex/graph/tampered.json"
        result = self.result(candidate)
        self.assertEqual(result.status, "rejected")
        self.assertIn("graph evidence digest is invalid", result.findings)

    def test_missing_or_mismatched_linked_artifact_is_rejected(self) -> None:
        missing = self.authorized_candidate()
        (self.root / missing["compilerClosure"]["artifact"]).unlink()
        result = self.result(missing)
        self.assertEqual(result.status, "rejected")
        self.assertIn("compiler closure artifact is missing", result.findings)

        mismatched = self.authorized_candidate()
        (self.root / mismatched["graph"]["artifact"]).write_text("tampered\n", encoding="utf-8")
        result = self.result(mismatched)
        self.assertEqual(result.status, "rejected")
        self.assertIn("graph artifact digest does not match file", result.findings)

        history = self.authorized_candidate()
        (self.root / history["history"]["artifact"]).unlink()
        result = self.result(history)
        self.assertEqual(result.status, "rejected")
        self.assertIn("history artifact is missing", result.findings)

        benchmark = self.authorized_candidate()
        sample = benchmark["benchmarks"]["moduleTest"][0]
        (self.root / sample["artifact"]).write_text("tampered benchmark\n", encoding="utf-8")
        result = self.result(benchmark)
        self.assertEqual(result.status, "rejected")
        self.assertIn("benchmark sample artifact digest does not match file", result.findings)

    def test_completed_time_pilot_remains_observed_not_future_authority(self) -> None:
        policy = json.loads(POLICY.read_text(encoding="utf-8"))
        result = self.gate.evaluate_policy(ROOT, policy)
        time = next(row for row in result.candidates if row.candidate_id == "ambitions-time-foundation-pilot")
        self.assertEqual(time.status, "observed")
        self.assertNotIn("AmbitionsTimeFoundation", result.authorized_targets)

    def test_current_whole_domain_candidate_remains_unauthorized(self) -> None:
        policy = json.loads(POLICY.read_text(encoding="utf-8"))
        result = self.gate.evaluate_policy(ROOT, policy)
        domain = next(row for row in result.candidates if row.candidate_id == "whole-core-domain")
        self.assertEqual(domain.status, "rejected")
        self.assertIn("source set is folder-derived rather than explicit", domain.findings)
        self.assertIn("compiler closure did not pass", domain.findings)
        self.assertIn("candidate median file touches are below the production high-churn cohort", domain.findings)
        self.assertEqual(policy["supportingEvidence"]["domainCensusFileCount"], 166)
        self.assertEqual(policy["supportingEvidence"]["domainConservativeSeparabilityCount"], 45)

    def test_policy_only_evaluation_authorizes_no_future_target(self) -> None:
        candidate = self.authorized_candidate()
        candidate["status"] = "observed"
        candidate["prospectiveGateEvidence"] = False
        candidate.pop("proposedTarget")
        policy = {
            "schemaVersion": 1,
            "thresholds": self.thresholds(),
            "candidates": [candidate],
            "authorizedFutureTargets": [],
        }
        result = self.gate.evaluate_policy(self.root, policy)
        self.assertTrue(result.ok)
        self.assertEqual(result.authorized_targets, ())

    def test_malformed_evidence_exits_two(self) -> None:
        malformed = self.root / "malformed.json"
        malformed.write_text('{"schemaVersion": 1, "thresholds": []}', encoding="utf-8")
        with contextlib.redirect_stdout(io.StringIO()):
            status = self.gate.main(["--policy", str(malformed), "--json", "--root", str(self.root)])
        self.assertEqual(status, 2)


if __name__ == "__main__":
    unittest.main()
