import contextlib
import copy
import hashlib
import importlib.util
import io
import json
import subprocess
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
    @classmethod
    def setUpClass(cls) -> None:
        cls.temporary = tempfile.TemporaryDirectory()
        cls.root = Path(cls.temporary.name)
        cls.paths = [
            "Native/Ambitions/Core/Time/A.swift",
            "Native/Ambitions/Core/Time/B.swift",
        ]
        cls.other_sources = [
            "Native/Ambitions/App/App.swift",
            "Native/Ambitions/Core/Time/Cold.swift",
            "Native/Ambitions/Quality/ModuleProof.swift",
            "Native/Ambitions/Quality/IntegrationProof.swift",
        ]
        for index, relative in enumerate(cls.paths + cls.other_sources):
            path = cls.root / relative
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(f"struct Fixture{index} {{}}\n", encoding="utf-8")
        (cls.root / "project.yml").write_text("name: Fixture\n", encoding="utf-8")
        route_config = cls.root / "scripts" / "ambitions-changed-file-test-routes.json"
        route_config.parent.mkdir(parents=True, exist_ok=True)
        route_config.write_text('{"routes": []}\n', encoding="utf-8")
        cls.git("init", "-q")
        cls.git("config", "user.email", "fixture@example.com")
        cls.git("config", "user.name", "Fixture")
        cls.git("add", "Native", "project.yml", "scripts/ambitions-changed-file-test-routes.json")
        cls.git("commit", "-q", "-m", "fixture 1")
        for number in range(2, 101):
            for relative in cls.paths:
                with (cls.root / relative).open("a", encoding="utf-8") as source:
                    source.write(f"// touch {number}\n")
            cls.git("add", *cls.paths)
            cls.git("commit", "-q", "-m", f"fixture {number}")

    @classmethod
    def tearDownClass(cls) -> None:
        cls.temporary.cleanup()

    @classmethod
    def git(cls, *arguments: str) -> str:
        return subprocess.run(
            ["git", *arguments],
            cwd=cls.root,
            check=True,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        ).stdout.strip()

    def setUp(self) -> None:
        self.gate = load_gate()
        for evidence in self.root.glob(".evidence*"):
            if evidence.is_dir():
                for path in sorted(evidence.rglob("*"), reverse=True):
                    if path.is_symlink() or path.is_file():
                        path.unlink()
                    elif path.is_dir():
                        path.rmdir()
                evidence.rmdir()

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

    def identity(self, candidate_id: str, target: str, files: list[str], source_hash: str) -> str:
        authority_hashes = self.authority_hashes()
        payload = {
            "candidateID": candidate_id,
            "proposedTarget": target,
            "repositoryHead": self.git("rev-parse", "HEAD"),
            "authorityHashes": authority_hashes,
            "sourceContentHash": source_hash,
            "sourceFiles": sorted(files),
        }
        encoded = json.dumps(payload, sort_keys=True, separators=(",", ":")).encode()
        return "sha256:" + hashlib.sha256(encoded).hexdigest()

    def authority_hashes(self) -> dict[str, str]:
        authority_hashes = {}
        for relative in ("project.yml", "scripts/ambitions-changed-file-test-routes.json"):
            authority_hashes[relative] = "sha256:" + hashlib.sha256((self.root / relative).read_bytes()).hexdigest()
        return authority_hashes

    def common(self, artifact_type: str, candidate_id: str, target: str, source_hash: str) -> dict:
        return {
            "schemaVersion": 1,
            "artifactType": artifact_type,
            "candidateID": candidate_id,
            "candidateIdentity": self.identity(candidate_id, target, self.paths, source_hash),
            "proposedTarget": target,
            "repositoryHead": self.git("rev-parse", "HEAD"),
            "authorityHashes": self.authority_hashes(),
            "sourceFiles": sorted(self.paths),
            "sourceContentHash": source_hash,
        }

    def artifact(self, relative: str, payload: dict) -> dict:
        return self.file_reference(relative, json.dumps(payload, indent=2, sort_keys=True) + "\n")

    def file_reference(self, relative: str, contents: str) -> dict:
        path = self.root / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(contents, encoding="utf-8")
        return {
            "path": relative,
            "sha256": "sha256:" + hashlib.sha256(path.read_bytes()).hexdigest(),
        }

    def mutate_artifact(self, reference: dict, mutation) -> None:
        path = self.root / reference["path"]
        payload = json.loads(path.read_text(encoding="utf-8"))
        mutation(payload)
        path.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
        reference["sha256"] = "sha256:" + hashlib.sha256(path.read_bytes()).hexdigest()

    def mutate_nested_artifact(self, candidate: dict, artifact_key: str, reference_key: str, mutation) -> None:
        self.mutate_reference_in_wrapper(candidate["artifacts"][artifact_key], reference_key, mutation)

    def mutate_reference_in_wrapper(self, wrapper_ref: dict, reference_key: str, mutation) -> None:
        wrapper_path = self.root / wrapper_ref["path"]
        wrapper = json.loads(wrapper_path.read_text(encoding="utf-8"))
        self.mutate_artifact(wrapper[reference_key], mutation)
        wrapper_path.write_text(json.dumps(wrapper, indent=2, sort_keys=True) + "\n", encoding="utf-8")
        wrapper_ref["sha256"] = "sha256:" + hashlib.sha256(wrapper_path.read_bytes()).hexdigest()

    def mutate_benchmark_summary(self, candidate: dict, cohort: str, index: int, mutation) -> None:
        wrapper_ref = candidate["artifacts"]["benchmarks"][cohort][index]
        self.mutate_reference_in_wrapper(wrapper_ref, "benchmarkSummary", mutation)

    def mutate_benchmark_result(self, candidate: dict, cohort: str, index: int, mutation) -> None:
        wrapper_ref = candidate["artifacts"]["benchmarks"][cohort][index]
        self.mutate_reference_in_wrapper(wrapper_ref, "resultSummary", mutation)

    def refresh_review_fingerprints(self, candidate: dict) -> None:
        queue = [
            reference
            for key, value in candidate["artifacts"].items()
            if key != "review"
            for reference in (value.values() if key == "benchmarks" else [value])
        ]
        queue = [reference for value in queue for reference in (value if isinstance(value, list) else [value])]
        fingerprints = {}
        while queue:
            reference = queue.pop()
            if not isinstance(reference, dict) or set(reference) != {"path", "sha256"}:
                continue
            if reference["path"] in fingerprints:
                continue
            fingerprints[reference["path"]] = reference["sha256"]
            path = self.root / reference["path"]
            try:
                payload = json.loads(path.read_text(encoding="utf-8"))
            except (OSError, UnicodeDecodeError, json.JSONDecodeError):
                continue

            def visit(value) -> None:
                if isinstance(value, dict):
                    if set(value) == {"path", "sha256"}:
                        queue.append(value)
                    else:
                        for nested in value.values():
                            visit(nested)
                elif isinstance(value, list):
                    for nested in value:
                        visit(nested)

            visit(payload)
        self.mutate_artifact(
            candidate["artifacts"]["review"],
            lambda row: row.update(reviewedArtifacts=fingerprints),
        )

    @staticmethod
    def signature_hash(fragments: list[dict]) -> str:
        encoded = json.dumps(fragments, sort_keys=True, separators=(",", ":")).encode()
        return "sha256:" + hashlib.sha256(encoded).hexdigest()

    def authorized_candidate(
        self,
        candidate_id: str = "candidate-time-hot-leaf",
        target: str = "AmbitionsHotLeaf",
        evidence_dir: str = ".evidence",
        absolute_derived_data: bool = False,
    ) -> dict:
        source_hash = self.gate.source_set_hash(self.root, self.paths)
        head = self.git("rev-parse", "HEAD")
        commits = self.git(
            "rev-list", "--first-parent", "--max-count=250", "HEAD"
        ).splitlines()
        def common(kind: str) -> dict:
            return self.common(kind, candidate_id, target, source_hash)

        history = {
            **common("history"),
            "repositoryHead": head,
            "firstParentCommits": commits,
            "candidateFileTouches": {path: 100 for path in self.paths},
            "productionFileTouches": {
                **{path: 100 for path in self.paths},
                **{path: 1 for path in self.other_sources},
            },
        }
        compiler_result = self.artifact(f"{evidence_dir}/raw/compiler-result.json", {
            "argv": ["swiftc", "-module-name", target, *self.paths],
            "exit_code": 0,
            "stdout": "CompileSwift normal arm64",
            "stderr": "",
            "diagnostics": [],
        })
        compiler = {
            **common("compiler"),
            "compilerResult": compiler_result,
            "declaredDependencies": [],
        }
        graph = {
            **common("graph"),
            "nodes": [
                {"name": "Ambitions", "kind": "application"},
                {"name": "AmbitionsWidgetExtension", "kind": "extension"},
                {"name": "AmbitionsTests", "kind": "integration-test"},
                {"name": target, "kind": "production"},
                {"name": f"{target}Tests", "kind": "module-test"},
            ],
            "edges": [
                {"from": "Ambitions", "to": target},
                {"from": "AmbitionsTests", "to": "Ambitions"},
                {"from": "AmbitionsTests", "to": target},
                {"from": f"{target}Tests", "to": target},
            ],
            "sourceMemberships": {path: [target] for path in self.paths},
            "moduleTestTarget": f"{target}Tests",
            "integrationTestTarget": "AmbitionsTests",
            "applicationTargets": ["Ambitions"],
            "extensionTargets": ["AmbitionsWidgetExtension"],
        }
        symbol_rows = []
        approved_contracts = []
        for declaration in ("CandidateA", "CandidateB"):
            fragments = [
                {"kind": "keyword", "spelling": "public"},
                {"kind": "text", "spelling": " struct "},
                {"kind": "identifier", "spelling": declaration},
            ]
            signature = self.signature_hash(fragments)
            symbol_rows.append({
                "identifier": {"precise": f"s:{declaration}"},
                "declarationFragments": fragments,
                "accessLevel": "public",
            })
            approved_contracts.append({
                "usr": f"s:{declaration}",
                "signatureHash": signature,
                "consumerTarget": "Ambitions",
                "consumerFiles": ["Native/Ambitions/App/App.swift"],
            })
        symbol_graph = self.artifact(f"{evidence_dir}/raw/candidate.symbols.json", {
            "metadata": {"formatVersion": {"major": 0, "minor": 6, "patch": 0}},
            "module": {"name": target},
            "symbols": symbol_rows,
        })
        public_api = {
            **common("public-api"),
            "symbolGraph": symbol_graph,
            "approvedContracts": approved_contracts,
        }
        routes = {
            **common("routes"),
            "routes": [
                {
                    "sourceFile": path,
                    "moduleTests": [f"{target}Tests.test{index}"],
                    "hostedIntegrationTests": [f"AmbitionsTests.test{index}"],
                }
                for index, path in enumerate(self.paths, start=1)
            ],
        }
        module_test_ids = [f"{target}Tests.test{index}" for index in range(1, len(self.paths) + 1)]
        integration_test_ids = [f"AmbitionsTests.test{index}" for index in range(1, len(self.paths) + 1)]
        module_result_id = "module-result-1"
        integration_result_id = "integration-result-1"
        module_bundle = f"{evidence_dir}/results/module.xcresult"
        integration_bundle = f"{evidence_dir}/results/integration.xcresult"
        module_info = self.file_reference(
            f"{module_bundle}/Info.plist",
            f'<?xml version="1.0" encoding="UTF-8"?><plist version="1.0"><dict><key>rootId</key><dict><key>hash</key><string>{module_result_id}</string></dict></dict></plist>\n',
        )
        integration_info = self.file_reference(
            f"{integration_bundle}/Info.plist",
            f'<?xml version="1.0" encoding="UTF-8"?><plist version="1.0"><dict><key>rootId</key><dict><key>hash</key><string>{integration_result_id}</string></dict></dict></plist>\n',
        )
        module_log = self.file_reference(
            f"{evidence_dir}/logs/module.log",
            "".join(f"Test Case '{identifier}' passed\n" for identifier in module_test_ids)
            + f"Executed {len(module_test_ids)} tests, with 0 failures\n",
        )
        integration_log = self.file_reference(
            f"{evidence_dir}/logs/integration.log",
            "".join(f"Test Case '{identifier}' passed\n" for identifier in integration_test_ids)
            + f"Executed {len(integration_test_ids)} tests, with 0 failures\n",
        )
        module_tests = {
            **common("test-result"),
            "lane": "module",
            "testTarget": f"{target}Tests",
            "exitCode": 0,
            "executedTests": len(module_test_ids),
            "executedTestIdentifiers": module_test_ids,
            "resultID": module_result_id,
            "resultBundlePath": module_bundle,
            "resultInfoPlist": module_info,
            "rawLog": module_log,
        }
        integration_tests = {
            **common("test-result"),
            "lane": "hosted-integration",
            "testTarget": "AmbitionsTests",
            "exitCode": 0,
            "executedTests": len(integration_test_ids),
            "executedTestIdentifiers": integration_test_ids,
            "resultID": integration_result_id,
            "resultBundlePath": integration_bundle,
            "resultInfoPlist": integration_info,
            "rawLog": integration_log,
        }
        artifacts = {
            "history": self.artifact(f"{evidence_dir}/history.json", history),
            "compiler": self.artifact(f"{evidence_dir}/compiler.json", compiler),
            "graph": self.artifact(f"{evidence_dir}/graph.json", graph),
            "publicAPI": self.artifact(f"{evidence_dir}/public-api.json", public_api),
            "routes": self.artifact(f"{evidence_dir}/routes.json", routes),
            "moduleTests": self.artifact(f"{evidence_dir}/module-tests.json", module_tests),
            "integrationTests": self.artifact(f"{evidence_dir}/integration-tests.json", integration_tests),
            "benchmarks": {},
        }
        durations = {
            "moduleTest": [10.0, 11.0, 12.0],
            "leafProofCandidate": [30.0, 31.0, 32.0],
            "leafProofHostedBaseline": [50.0, 51.0, 52.0],
            "appNoChangeCandidate": [20.0, 21.0, 22.0],
            "appNoChangeBaseline": [20.0, 21.0, 22.0],
        }
        benchmark_nested_refs = []
        benchmark_counter = 0
        for cohort, values in durations.items():
            references = []
            for index, duration in enumerate(values, start=1):
                benchmark_counter += 1
                execution_id = f"20260711T{benchmark_counter:06d}Z"
                benchmark_commit = commits[-1] if cohort.endswith("Baseline") else head
                raw_summary = self.artifact(f"{evidence_dir}/benchmarks/raw/{cohort}-{index}-benchmark-summary.json", {
                    "timestamp_utc": execution_id,
                    "commit": benchmark_commit,
                    "package_identity": "resolved:fixture-v1",
                    "xcode_version": "Xcode 26.6 Build version 17F113",
                    "macos_version": "26.5.1",
                    "cpu": "Fixture CPU",
                    "derived_data": (
                        str(self.root / ".codex/DerivedData/Ambitions")
                        if absolute_derived_data
                        else ".codex/DerivedData/Ambitions"
                    ),
                    "warm_cold": "warm",
                    "lane": f"lane-{cohort}",
                    "scenario": cohort,
                    "command": f"xcodebuild {cohort}",
                    "exit_code": 0,
                    "duration_seconds": duration,
                })
                if cohort in ("appNoChangeCandidate", "appNoChangeBaseline"):
                    build_log = self.file_reference(
                        f"{evidence_dir}/benchmarks/logs/{cohort}-{index}.log", "** BUILD SUCCEEDED **\n"
                    )
                    result_summary = self.artifact(f"{evidence_dir}/benchmarks/results/{cohort}-{index}-build.json", {
                        "result_kind": "build-for-testing",
                        "exit_code": 0,
                        "build_succeeded": True,
                        "benchmark_execution_id": execution_id,
                        "benchmark_commit": benchmark_commit,
                        "cohort": cohort,
                        "raw_log": build_log,
                    })
                    benchmark_nested_refs.extend((raw_summary, result_summary, build_log))
                else:
                    result_id = f"{cohort}-result-{index}"
                    test_id = f"{cohort}Tests.test{index}"
                    bundle = f"{evidence_dir}/benchmarks/results/{cohort}-{index}.xcresult"
                    info = self.file_reference(
                        f"{bundle}/Info.plist",
                        f'<?xml version="1.0" encoding="UTF-8"?><plist version="1.0"><dict><key>rootId</key><dict><key>hash</key><string>{result_id}</string></dict></dict></plist>\n',
                    )
                    raw_log = self.file_reference(
                        f"{evidence_dir}/benchmarks/logs/{cohort}-{index}.log",
                        f"Test Case '{test_id}' passed\nExecuted 1 test, with 0 failures\n",
                    )
                    result_summary = self.artifact(f"{evidence_dir}/benchmarks/results/{cohort}-{index}-focused.json", {
                        "result_kind": "focused-test",
                        "exit_code": 0,
                        "executed_tests": 1,
                        "executed_test_identifiers": [test_id],
                        "result_id": result_id,
                        "simulator_udid": "00000000-0000-0000-0000-000000000001",
                        "benchmark_execution_id": execution_id,
                        "benchmark_commit": benchmark_commit,
                        "cohort": cohort,
                        "result_bundle_path": bundle,
                        "result_info_plist": info,
                        "raw_log": raw_log,
                    })
                    benchmark_nested_refs.extend((raw_summary, result_summary, info, raw_log))
                sample = {
                    **common("benchmark-sample"),
                    "cohort": cohort,
                    "benchmarkSummary": raw_summary,
                    "resultSummary": result_summary,
                }
                references.append(self.artifact(f"{evidence_dir}/benchmarks/{cohort}-{index}.json", sample))
            artifacts["benchmarks"][cohort] = references

        reviewed_artifacts = {
            reference["path"]: reference["sha256"]
            for key, value in artifacts.items()
            if key != "benchmarks"
            for reference in [value]
        }
        for references in artifacts["benchmarks"].values():
            reviewed_artifacts.update({reference["path"]: reference["sha256"] for reference in references})
        reviewed_artifacts.update({
            reference["path"]: reference["sha256"]
            for reference in (
                compiler_result, symbol_graph,
                module_info, module_log, integration_info, integration_log,
                *benchmark_nested_refs,
            )
        })
        review = {
            **common("review"),
            "author": "implementation-agent",
            "reviewer": "independent-reviewer",
            "status": "approved",
            "criticalFindings": [],
            "importantFindings": [],
            "reviewedArtifacts": reviewed_artifacts,
        }
        artifacts["review"] = self.artifact(f"{evidence_dir}/review.json", review)

        return {
            "id": candidate_id,
            "status": "authorized",
            "proposedTarget": target,
            "prospectiveGateEvidence": True,
            "sourceSet": {
                "selection": "explicit_files",
                "files": sorted(self.paths),
                "contentHash": source_hash,
            },
            "artifacts": artifacts,
        }

    def result(self, candidate: dict):
        return self.gate.evaluate_candidate(self.root, self.thresholds(), candidate)

    def policy(self, candidate: dict) -> dict:
        return {
            "schemaVersion": 1,
            "thresholds": self.thresholds(),
            "candidates": [candidate],
            "authorizedFutureTargets": [candidate["proposedTarget"]],
        }

    def test_typed_artifacts_in_live_git_repo_authorize_candidate(self) -> None:
        result = self.result(self.authorized_candidate())
        self.assertEqual(result.status, "authorized", result.findings)

    def test_proposed_target_is_valid_identifier_and_identity_bound(self) -> None:
        invalid = self.authorized_candidate()
        invalid["proposedTarget"] = "../UnreviewedTarget"
        with self.assertRaisesRegex(self.gate.EvidenceFormatError, "valid Swift target identifier"):
            self.result(invalid)

        changed = self.authorized_candidate()
        changed["proposedTarget"] = "AmbitionsUnreviewedTarget"
        result = self.result(changed)
        self.assertEqual(result.status, "rejected")
        self.assertIn("history artifact candidate identity does not match candidate", result.findings)

    def test_candidate_requires_exact_boolean_and_nonempty_source_set(self) -> None:
        candidate = self.authorized_candidate()
        candidate["prospectiveGateEvidence"] = "true"
        with self.assertRaisesRegex(self.gate.EvidenceFormatError, "prospectiveGateEvidence must be a boolean"):
            self.result(candidate)

        empty = self.authorized_candidate()
        empty["sourceSet"]["files"] = []
        result = self.result(empty)
        self.assertEqual(result.status, "rejected")
        self.assertIn("source set is empty", result.findings)

    def test_candidate_source_cannot_resolve_through_repository_external_symlink(self) -> None:
        candidate = self.authorized_candidate()
        source = self.root / self.paths[0]
        original = source.read_bytes()
        with tempfile.TemporaryDirectory() as directory:
            external = Path(directory) / "External.swift"
            external.write_bytes(original)
            source.unlink()
            source.symlink_to(external)
            try:
                result = self.result(candidate)
            finally:
                source.unlink()
                source.write_bytes(original)
        self.assertEqual(result.status, "rejected")
        self.assertIn("source path is a symlink or resolves outside repository", result.findings)

    def test_history_is_recomputed_from_live_first_parent_git(self) -> None:
        candidate = self.authorized_candidate()
        self.mutate_artifact(candidate["artifacts"]["history"], lambda row: row["firstParentCommits"].reverse())
        result = self.result(candidate)
        self.assertIn("history artifact first-parent window does not match live Git", result.findings)

        candidate = self.authorized_candidate()
        self.mutate_artifact(
            candidate["artifacts"]["history"],
            lambda row: row["candidateFileTouches"].update({self.paths[0]: 1}),
        )
        result = self.result(candidate)
        self.assertIn("history artifact touch maps do not match live Git", result.findings)

    def test_history_requires_real_git_root_and_current_head(self) -> None:
        candidate = self.authorized_candidate()
        self.mutate_artifact(candidate["artifacts"]["history"], lambda row: row.update(repositoryHead="a" * 40))
        self.assertIn("history artifact head does not match live Git", self.result(candidate).findings)

        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for relative in self.paths:
                path = root / relative
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_bytes((self.root / relative).read_bytes())
            result = self.gate.evaluate_candidate(root, self.thresholds(), self.authorized_candidate())
            policy_path = root / "policy.json"
            policy_path.write_text(json.dumps(self.policy(self.authorized_candidate())), encoding="utf-8")
            with contextlib.redirect_stdout(io.StringIO()):
                cli_status = self.gate.main(["--policy", str(policy_path), "--json", "--root", str(root)])
        self.assertEqual(result.status, "rejected")
        self.assertIn("authorization requires the supplied root to be a Git repository root", result.findings)
        self.assertEqual(cli_status, 1)

    def test_authorization_rejects_dirty_tracked_worktree(self) -> None:
        candidate = self.authorized_candidate()
        project = self.root / "project.yml"
        original = project.read_text(encoding="utf-8")
        try:
            project.write_text(original + "dirty: true\n", encoding="utf-8")
            result = self.result(candidate)
        finally:
            project.write_text(original, encoding="utf-8")
        self.assertEqual(result.status, "rejected")
        self.assertIn("authorization requires a clean tracked worktree", result.findings)

    def test_compiler_artifact_derives_success_and_dependencies(self) -> None:
        probes = (
            (lambda row: row.update(exit_code=1), "compiler invocation did not exit successfully"),
            (
                lambda row: row.update(stderr="error: unresolved symbol"),
                "compiler artifact reports error diagnostics",
            ),
            (
                lambda row: row["diagnostics"].append({"severity": [], "message": "invalid"}),
                "compiler diagnostics require typed severity and message",
            ),
            (lambda row: row.update(argv=[]), "compiler invocation must be a nonempty string array"),
            (
                lambda row: row["argv"].__setitem__(0, "true"),
                "compiler invocation does not use Swift compiler",
            ),
            (
                lambda row: row["argv"].__setitem__(0, "/tmp/fake/swiftc"),
                "compiler invocation does not use Swift compiler",
            ),
            (
                lambda row: row["argv"].__setitem__(2, "OtherTarget"),
                "compiler invocation module name does not match proposed target",
            ),
            (
                lambda row: row["argv"].pop(),
                "compiler invocation source paths do not match exact source set",
            ),
        )
        for mutation, finding in probes:
            with self.subTest(finding=finding):
                candidate = self.authorized_candidate()
                self.mutate_nested_artifact(candidate, "compiler", "compilerResult", mutation)
                self.assertIn(finding, self.result(candidate).findings)

        candidate = self.authorized_candidate()
        self.mutate_artifact(
            candidate["artifacts"]["compiler"],
            lambda row: row.update(declaredDependencies=["MissingDependency"]),
        )
        self.assertIn("compiler dependencies do not match graph target edges", self.result(candidate).findings)

    def test_graph_derives_cycle_membership_and_hostless_reachability(self) -> None:
        probes = (
            (
                lambda row: row["edges"].append({"from": row["proposedTarget"], "to": "Ambitions"}),
                "candidate target graph contains a cycle",
            ),
            (
                lambda row: row["sourceMemberships"].update({self.paths[0]: [row["proposedTarget"], "Ambitions"]}),
                "candidate source lacks exactly one production membership",
            ),
            (
                lambda row: row["edges"].append({"from": row["moduleTestTarget"], "to": "Ambitions"}),
                "module tests can reach an application or extension target",
            ),
        )
        for mutation, finding in probes:
            with self.subTest(finding=finding):
                candidate = self.authorized_candidate()
                self.mutate_artifact(candidate["artifacts"]["graph"], mutation)
                self.assertIn(finding, self.result(candidate).findings)

    def test_graph_endpoint_types_reject_without_uncaught_exception(self) -> None:
        probes = (
            (lambda row: row["edges"][0].update({"from": []}), "graph edges require nonempty string endpoints"),
            (lambda row: row.update(moduleTestTarget=[]), "graph target names must be nonempty strings"),
        )
        for mutation, finding in probes:
            with self.subTest(finding=finding):
                candidate = self.authorized_candidate()
                self.mutate_artifact(candidate["artifacts"]["graph"], mutation)
                result = self.result(candidate)
                self.assertEqual(result.status, "rejected")
                self.assertIn(finding, "\n".join(result.findings))

    def test_public_api_requires_one_contract_and_consumer_per_declaration(self) -> None:
        missing = self.authorized_candidate()
        self.mutate_artifact(missing["artifacts"]["publicAPI"], lambda row: row["approvedContracts"].pop())
        self.assertIn(
            "compiler-public declarations lack exactly one approved consumer contract",
            self.result(missing).findings,
        )

        duplicate = self.authorized_candidate()
        self.mutate_artifact(
            duplicate["artifacts"]["publicAPI"],
            lambda row: row["approvedContracts"].append(copy.deepcopy(row["approvedContracts"][0])),
        )
        self.assertIn(
            "compiler-public declarations lack exactly one approved consumer contract",
            self.result(duplicate).findings,
        )

        empty = self.authorized_candidate()
        self.mutate_nested_artifact(empty, "publicAPI", "symbolGraph", lambda row: row.update(symbols=[]))
        self.assertIn("symbol graph contains no compiler-public declarations", self.result(empty).findings)

        escaped = self.authorized_candidate()
        self.mutate_artifact(
            escaped["artifacts"]["publicAPI"],
            lambda row: row["approvedContracts"][0].update(consumerFiles=["/etc/passwd"]),
        )
        self.assertIn("approved contract consumer file is not repository-contained", self.result(escaped).findings)

    def test_routes_derive_exact_module_and_hosted_coverage(self) -> None:
        probes = (
            (lambda row: row["routes"].pop(), "changed-file routes do not cover the exact source set"),
            (lambda row: row["routes"][0].update(moduleTests=[]), "changed-file route lacks module test proof"),
            (
                lambda row: row["routes"][0].update(hostedIntegrationTests=[]),
                "changed-file route lacks hosted integration proof",
            ),
        )
        for mutation, finding in probes:
            with self.subTest(finding=finding):
                candidate = self.authorized_candidate()
                self.mutate_artifact(candidate["artifacts"]["routes"], mutation)
                self.assertIn(finding, self.result(candidate).findings)

        invented = self.authorized_candidate()
        self.mutate_artifact(
            invented["artifacts"]["routes"],
            lambda row: row["routes"][0].update(moduleTests=["InventedTests.testNothing"]),
        )
        self.assertIn("changed-file route names a module test that did not execute", self.result(invented).findings)

    def test_test_artifacts_require_typed_lane_target_success_and_identity(self) -> None:
        probes = (
            ("moduleTests", lambda row: row.update(lane="hosted-integration"), "module test artifact lane is invalid"),
            ("moduleTests", lambda row: row.update(testTarget="OtherTests"), "module test target does not match graph"),
            ("integrationTests", lambda row: row.update(exitCode=1), "integration test proof did not pass"),
            ("integrationTests", lambda row: row.update(executedTests=0), "integration test proof executed zero tests"),
            ("integrationTests", lambda row: row.update(resultID="module-result-1"), "test result identities are replayed"),
        )
        for artifact, mutation, finding in probes:
            with self.subTest(finding=finding):
                candidate = self.authorized_candidate()
                self.mutate_artifact(candidate["artifacts"][artifact], mutation)
                self.assertIn(finding, self.result(candidate).findings)

    def test_test_artifacts_require_hash_bound_result_bundle_and_raw_log(self) -> None:
        missing = self.authorized_candidate()
        module_payload = json.loads(
            (self.root / missing["artifacts"]["moduleTests"]["path"]).read_text(encoding="utf-8")
        )
        (self.root / module_payload["rawLog"]["path"]).unlink()
        result = self.result(missing)
        self.assertEqual(result.status, "observed")
        self.assertIn("module test raw log artifact is missing", result.findings)

        tampered = self.authorized_candidate()
        module_payload = json.loads(
            (self.root / tampered["artifacts"]["moduleTests"]["path"]).read_text(encoding="utf-8")
        )
        (self.root / module_payload["resultInfoPlist"]["path"]).write_text("tampered\n", encoding="utf-8")
        result = self.result(tampered)
        self.assertEqual(result.status, "rejected")
        self.assertIn("module test result Info.plist artifact digest does not match file", result.findings)

        invented = self.authorized_candidate()
        self.mutate_artifact(invented["artifacts"]["moduleTests"], lambda row: row.update(executedTests=99))
        self.assertIn("module test executed count does not match raw log", self.result(invented).findings)

    def test_review_requires_independent_approval_and_zero_blocking_arrays(self) -> None:
        probes = (
            (lambda row: row.update(reviewer=row["author"]), "independent review author and reviewer must differ"),
            (lambda row: row.update(status="changes-requested"), "independent review is not approved"),
            (lambda row: row["criticalFindings"].append("critical"), "independent review retains blocking findings"),
            (lambda row: row.update(importantFindings=0), "review importantFindings must be an array"),
        )
        for mutation, finding in probes:
            with self.subTest(finding=finding):
                candidate = self.authorized_candidate()
                self.mutate_artifact(candidate["artifacts"]["review"], mutation)
                self.assertIn(finding, self.result(candidate).findings)

    def test_review_fingerprints_every_authorizing_artifact(self) -> None:
        candidate = self.authorized_candidate()
        self.mutate_nested_artifact(
            candidate,
            "compiler",
            "compilerResult",
            lambda row: row.update(stdout="different successful compiler transcript"),
        )
        result = self.result(candidate)
        self.assertEqual(result.status, "rejected")
        self.assertIn("independent review artifact fingerprints do not match candidate evidence", result.findings)

    def test_every_authorizing_artifact_is_bound_to_live_head_and_authorities(self) -> None:
        candidate = self.authorized_candidate()
        self.mutate_artifact(candidate["artifacts"]["graph"], lambda row: row.update(repositoryHead="a" * 40))
        self.assertIn("graph artifact repository HEAD does not match live Git", self.result(candidate).findings)

        candidate = self.authorized_candidate()
        self.mutate_artifact(
            candidate["artifacts"]["routes"],
            lambda row: row["authorityHashes"].update({"project.yml": "sha256:" + "0" * 64}),
        )
        self.assertIn("routes artifact authority hashes do not match live files", self.result(candidate).findings)

    def test_benchmarks_require_exact_three_distinct_typed_warm_live_samples(self) -> None:
        candidate = self.authorized_candidate()
        candidate["artifacts"]["benchmarks"]["moduleTest"].pop()
        self.assertIn("benchmark cohort moduleTest does not have the policy sample count", self.result(candidate).findings)

        probes = (
            (lambda row: row.update(timestamp_utc="20260711T000001Z"), "benchmark samples contain replayed execution identifiers"),
            (lambda row: row.update(commit="short"), "benchmark commit must be a full live Git SHA"),
            (lambda row: row.update(commit="a" * 40), "benchmark commit does not match live Git HEAD"),
            (lambda row: row.update(warm_cold="cold"), "benchmark sample is not warm-cache evidence"),
            (lambda row: row.update(derived_data="/tmp/DerivedData"), "benchmark sample uses noncanonical DerivedData"),
            (lambda row: row.update(exit_code=1), "benchmark sample is not a successful run"),
        )
        for mutation, finding in probes:
            with self.subTest(finding=finding):
                candidate = self.authorized_candidate()
                self.mutate_benchmark_summary(candidate, "moduleTest", 1, mutation)
                self.assertIn(finding, self.result(candidate).findings)

    def test_benchmark_cohorts_require_stable_command_lane_scenario_package_and_identity(self) -> None:
        probes = (
            (lambda row: row.update(command="different"), "benchmark cohort moduleTest mixes command, lane, or scenario"),
            (lambda row: row.update(lane="different"), "benchmark cohort moduleTest mixes command, lane, or scenario"),
            (lambda row: row.update(scenario="different"), "benchmark cohort moduleTest mixes command, lane, or scenario"),
            (lambda row: row.update(package_identity="different"), "benchmark samples do not share one comparable environment identity"),
            (lambda row: row.update(xcode_version="different"), "benchmark samples do not share one comparable environment identity"),
        )
        for mutation, finding in probes:
            with self.subTest(finding=finding):
                candidate = self.authorized_candidate()
                self.mutate_benchmark_summary(candidate, "moduleTest", 1, mutation)
                self.assertIn(finding, self.result(candidate).findings)

        candidate = self.authorized_candidate()
        ref = candidate["artifacts"]["benchmarks"]["moduleTest"][1]
        self.mutate_artifact(ref, lambda row: row.update(candidateIdentity="sha256:" + "0" * 64))
        self.assertIn("benchmark sample artifact candidate identity does not match candidate", self.result(candidate).findings)

    def test_benchmark_thresholds_are_derived_from_artifact_durations(self) -> None:
        probes = (
            ("moduleTest", [31.0, 32.0, 33.0], "module test median exceeds policy maximum"),
            ("leafProofCandidate", [61.0, 62.0, 63.0], "leaf proof median exceeds policy maximum"),
            ("leafProofCandidate", [39.0, 40.0, 41.0], "leaf proof median lacks the required hosted improvement"),
            ("appNoChangeCandidate", [24.0, 25.0, 26.0], "app no-change median regression exceeds policy maximum"),
        )
        for cohort, durations, finding in probes:
            with self.subTest(finding=finding):
                candidate = self.authorized_candidate()
                for index, duration in enumerate(durations):
                    self.mutate_benchmark_summary(
                        candidate, cohort, index, lambda row, value=duration: row.update(duration_seconds=value)
                    )
                self.assertIn(finding, self.result(candidate).findings)

    def test_benchmark_wrappers_require_hash_bound_raw_and_result_summaries(self) -> None:
        missing = self.authorized_candidate()
        wrapper_ref = missing["artifacts"]["benchmarks"]["moduleTest"][0]
        wrapper = json.loads((self.root / wrapper_ref["path"]).read_text(encoding="utf-8"))
        (self.root / wrapper["benchmarkSummary"]["path"]).unlink()
        result = self.result(missing)
        self.assertEqual(result.status, "observed")
        self.assertIn("benchmark raw summary artifact is missing", result.findings)

        zero = self.authorized_candidate()
        self.mutate_benchmark_result(zero, "moduleTest", 0, lambda row: row.update(executed_tests=0))
        self.assertIn("benchmark test result executed zero tests", self.result(zero).findings)

        failed_build = self.authorized_candidate()
        self.mutate_benchmark_result(
            failed_build, "appNoChangeCandidate", 0, lambda row: row.update(build_succeeded=False)
        )
        self.assertIn("benchmark build result did not succeed", self.result(failed_build).findings)

        swapped = self.authorized_candidate()
        refs = swapped["artifacts"]["benchmarks"]["moduleTest"][:2]
        wrappers = [json.loads((self.root / ref["path"]).read_text(encoding="utf-8")) for ref in refs]
        wrappers[0]["resultSummary"], wrappers[1]["resultSummary"] = (
            wrappers[1]["resultSummary"], wrappers[0]["resultSummary"]
        )
        for ref, wrapper in zip(refs, wrappers):
            path = self.root / ref["path"]
            path.write_text(json.dumps(wrapper, indent=2, sort_keys=True) + "\n", encoding="utf-8")
            ref["sha256"] = "sha256:" + hashlib.sha256(path.read_bytes()).hexdigest()
        self.refresh_review_fingerprints(swapped)
        self.assertIn("benchmark result summary does not bind its raw execution", self.result(swapped).findings)

    def test_benchmark_accepts_canonical_absolute_derived_data_path(self) -> None:
        result = self.result(self.authorized_candidate(absolute_derived_data=True))
        self.assertEqual(result.status, "authorized", result.findings)

    def test_missing_artifact_is_observed_but_tampered_or_invalid_artifact_is_rejected(self) -> None:
        missing = self.authorized_candidate()
        (self.root / missing["artifacts"]["compiler"]["path"]).unlink()
        result = self.result(missing)
        self.assertEqual(result.status, "observed")
        self.assertIn("compiler artifact is missing", result.findings)

        tampered = self.authorized_candidate()
        (self.root / tampered["artifacts"]["compiler"]["path"]).write_text("{}\n", encoding="utf-8")
        result = self.result(tampered)
        self.assertEqual(result.status, "rejected")
        self.assertIn("compiler artifact digest does not match file", result.findings)

        invalid = self.authorized_candidate()
        self.mutate_nested_artifact(invalid, "compiler", "compilerResult", lambda row: row.update(exit_code=True))
        result = self.result(invalid)
        self.assertEqual(result.status, "rejected")
        self.assertIn("compiler artifact schema is invalid", "\n".join(result.findings))

    def test_artifact_references_are_hash_bound_and_contained_in_root(self) -> None:
        outside = self.authorized_candidate()
        outside["artifacts"]["graph"]["path"] = "../graph.json"
        self.assertIn("graph artifact is outside the repository root", self.result(outside).findings)

        malformed = self.authorized_candidate()
        malformed["artifacts"]["graph"]["sha256"] = "invalid"
        self.assertIn("graph artifact reference is invalid", self.result(malformed).findings)

        broken = self.authorized_candidate()
        graph_path = self.root / broken["artifacts"]["graph"]["path"]
        graph_path.unlink()
        graph_path.symlink_to(self.root / ".evidence/does-not-exist.json")
        result = self.result(broken)
        self.assertEqual(result.status, "rejected")
        self.assertIn("graph artifact is outside the repository root", result.findings)

    def test_supporting_evidence_references_are_validated_when_present(self) -> None:
        candidate = self.authorized_candidate()
        candidate["supportingEvidence"] = [{"path": ".evidence/missing.json", "sha256": "sha256:" + "0" * 64}]
        self.assertIn("supporting evidence artifact is missing", self.result(candidate).findings)

        retained = self.root / ".evidence" / "retained.json"
        retained.write_text("{}\n", encoding="utf-8")
        candidate["supportingEvidence"] = [{"path": ".evidence/retained.json", "sha256": "sha256:" + "0" * 64}]
        self.assertIn("supporting evidence artifact digest does not match file", self.result(candidate).findings)

    def test_policy_authorization_is_derived_and_declared_set_must_match(self) -> None:
        candidate = self.authorized_candidate()
        result = self.gate.evaluate_policy(self.root, self.policy(candidate))
        self.assertTrue(result.ok, result.findings)
        self.assertEqual(result.authorized_targets, ("AmbitionsHotLeaf",))

        policy = self.policy(self.authorized_candidate())
        policy["authorizedFutureTargets"] = []
        result = self.gate.evaluate_policy(self.root, policy)
        self.assertFalse(result.ok)
        self.assertIn("authorizedFutureTargets does not equal the evaluated authorized target set", result.findings)

    def test_policy_rejects_duplicate_proposed_targets_across_candidates(self) -> None:
        first = self.authorized_candidate()
        second = self.authorized_candidate(
            candidate_id="candidate-time-hot-leaf-two",
            target="AmbitionsHotLeaf",
            evidence_dir=".evidence-two",
        )
        policy = {
            "schemaVersion": 1,
            "thresholds": self.thresholds(),
            "candidates": [first, second],
            "authorizedFutureTargets": ["AmbitionsHotLeaf"],
        }
        with self.assertRaisesRegex(self.gate.EvidenceFormatError, "proposedTarget values must be unique"):
            self.gate.evaluate_policy(self.root, policy)

    def test_current_policy_passes_with_time_observed_domain_rejected_and_no_target(self) -> None:
        policy = json.loads(POLICY.read_text(encoding="utf-8"))
        result = self.gate.evaluate_policy(ROOT, policy)
        self.assertTrue(result.ok, result.findings)
        self.assertEqual(result.authorized_targets, ())
        statuses = {row.candidate_id: row.status for row in result.candidates}
        self.assertEqual(statuses["ambitions-time-foundation-pilot"], "observed")
        self.assertEqual(statuses["whole-core-domain"], "rejected")

    def test_malformed_policy_and_nonfinite_threshold_exit_two(self) -> None:
        for payload in (
            {"schemaVersion": 1, "thresholds": []},
            {
                "schemaVersion": 1,
                "thresholds": {**self.thresholds(), "moduleTestMedianMaximumSeconds": float("nan")},
                "candidates": [],
                "authorizedFutureTargets": [],
            },
        ):
            with self.subTest(payload=payload):
                malformed = self.root / "malformed.json"
                malformed.write_text(json.dumps(payload), encoding="utf-8")
                with contextlib.redirect_stdout(io.StringIO()):
                    status = self.gate.main(["--policy", str(malformed), "--json", "--root", str(self.root)])
                self.assertEqual(status, 2)

    def test_malformed_target_shape_and_duplicate_json_keys_exit_two(self) -> None:
        candidate = self.authorized_candidate()
        candidate["proposedTarget"] = []
        malformed = self.root / "malformed-target.json"
        malformed.write_text(
            json.dumps({
                "schemaVersion": 1,
                "thresholds": self.thresholds(),
                "candidates": [candidate],
                "authorizedFutureTargets": [],
            }),
            encoding="utf-8",
        )
        with contextlib.redirect_stdout(io.StringIO()):
            status = self.gate.main(["--policy", str(malformed), "--json", "--root", str(self.root)])
        self.assertEqual(status, 2)

        duplicate = self.root / "duplicate-key.json"
        duplicate.write_text(
            '{"schemaVersion":1,"schemaVersion":1,"thresholds":{},"candidates":[],"authorizedFutureTargets":[]}',
            encoding="utf-8",
        )
        with contextlib.redirect_stdout(io.StringIO()):
            status = self.gate.main(["--policy", str(duplicate), "--json", "--root", str(self.root)])
        self.assertEqual(status, 2)

    def test_unhashable_candidate_status_and_disqualifier_shapes_exit_two(self) -> None:
        probes = (
            lambda row: row.update(status=[]),
            lambda row: row.update(affirmativeDisqualifiers=[[]]),
        )
        for index, mutation in enumerate(probes):
            candidate = self.authorized_candidate()
            mutation(candidate)
            path = self.root / f"malformed-candidate-{index}.json"
            path.write_text(json.dumps({
                "schemaVersion": 1,
                "thresholds": self.thresholds(),
                "candidates": [candidate],
                "authorizedFutureTargets": [],
            }), encoding="utf-8")
            with contextlib.redirect_stdout(io.StringIO()):
                status = self.gate.main(["--policy", str(path), "--json", "--root", str(self.root)])
            self.assertEqual(status, 2)


if __name__ == "__main__":
    unittest.main()
