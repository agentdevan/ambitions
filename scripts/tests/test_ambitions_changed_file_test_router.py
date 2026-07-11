import importlib.util
import json
import subprocess
import tempfile
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
ROUTER_PATH = REPO_ROOT / "scripts/ambitions-changed-file-test-router.py"
CONFIG_PATH = REPO_ROOT / "scripts/ambitions-changed-file-test-routes.json"

SPEC = importlib.util.spec_from_file_location("ambitions_changed_file_test_router", ROUTER_PATH)
assert SPEC is not None and SPEC.loader is not None
ROUTER = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(ROUTER)


class ChangedFileTestRouterTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.config = ROUTER.load_config(CONFIG_PATH)
        cls.evidence = ROUTER.load_live_evidence(REPO_ROOT, REPO_ROOT / "Ambitions.xcodeproj")

    def plan_live(self, *changes):
        return ROUTER.plan_changes(
            REPO_ROOT,
            list(changes),
            self.config,
            self.evidence,
            batch="ROUTER-TEST",
        )

    @staticmethod
    def filters(plan, kind):
        lane = next(lane for lane in plan["lanes"] if lane["kind"] == kind)
        return lane["tests"]

    def test_time_target_member_routes_module_then_six_hosted_suites_without_ui(self):
        plan = self.plan_live(ROUTER.Change("M", "Native/Ambitions/Core/Time/RuntimeTickPolicy.swift"))

        self.assertEqual(plan["status"], "planned", plan)
        self.assertEqual([lane["kind"] for lane in plan["lanes"]], ["module", "integration"])
        self.assertEqual(self.filters(plan, "module"), ["AmbitionsModuleTests/TimeFoundationModuleTests"])
        self.assertEqual(
            self.filters(plan, "integration"),
            [
                "AmbitionsTests/LifeShapeAntiFakeAuditTests",
                "AmbitionsTests/TimeClockTests",
                "AmbitionsTests/TodayClockTests",
                "AmbitionsTests/TodayFreshGoalVisibilityTests",
                "AmbitionsTests/TodayRealityMeridianExperienceElevationTests",
                "AmbitionsTests/TodayRecoveryViewModelTests",
            ],
        )

    def test_time_foundation_routing_follows_live_membership_not_folder(self):
        moved_path = "Native/Ambitions/Core/Domain/FixedPoint.swift"
        memberships = dict(self.evidence.memberships)
        memberships[moved_path] = ("AmbitionsTimeFoundation",)
        evidence = ROUTER.Evidence(
            memberships=memberships,
            nodes=self.evidence.nodes,
            edges=self.evidence.edges,
            cycles=(),
        )
        plan = ROUTER.plan_changes(
            REPO_ROOT,
            [ROUTER.Change("M", moved_path)],
            self.config,
            evidence,
            batch="ROUTER-TEST",
        )

        self.assertEqual(plan["status"], "planned", plan)
        self.assertEqual([lane["kind"] for lane in plan["lanes"]], ["module", "integration"])

    def test_app_owned_time_member_routes_hosted_integration_only(self):
        plan = self.plan_live(ROUTER.Change("M", "Native/Ambitions/Core/Time/LifeShapeBucketizer.swift"))

        self.assertEqual(plan["status"], "planned", plan)
        self.assertEqual([lane["kind"] for lane in plan["lanes"]], ["integration"])
        self.assertEqual(self.filters(plan, "integration"), ["AmbitionsTests/LifeShapeBucketizerTests"])

    def test_domain_source_routes_app_hosted_only_while_domain_module_is_absent(self):
        plan = self.plan_live(ROUTER.Change("M", "Native/Ambitions/Core/Domain/FixedPoint.swift"))

        self.assertEqual(plan["status"], "planned", plan)
        self.assertEqual([lane["kind"] for lane in plan["lanes"]], ["integration"])
        self.assertNotIn("AmbitionsDomain", json.dumps(plan))
        self.assertNotIn("DomainModuleBoundaryTests", json.dumps(plan))
        self.assertEqual(self.filters(plan, "integration"), ["AmbitionsTests"])

    def test_fixed_point_cannot_omit_direct_consumers_because_route_selects_entire_hosted_target(self):
        plan = self.plan_live(ROUTER.Change("M", "Native/Ambitions/Core/Domain/FixedPoint.swift"))

        self.assertEqual(plan["status"], "planned", plan)
        self.assertEqual(self.filters(plan, "integration"), ["AmbitionsTests"])
        launch = next(command for command in plan["commands"] if "scripts/ambitions-xcode-test-focused.sh" in command)
        self.assertEqual(launch.count("--only-testing"), 1)
        self.assertIn("AmbitionsTests", launch)
        self.assertNotIn("AmbitionsTests/OpenCapacityEngineTests", launch)
        self.assertNotIn("AmbitionsTests/ProtectionEngineTests", launch)

    def test_target_only_selector_must_match_its_lane_and_live_target(self):
        config = json.loads(CONFIG_PATH.read_text(encoding="utf-8"))
        domain_route = next(route for route in config["routes"] if route["id"] == "domain-hosted-integration")
        domain_route["integration"] = ["AmbitionsUITests"]
        plan = ROUTER.plan_changes(
            REPO_ROOT,
            [ROUTER.Change("M", "Native/Ambitions/Core/Domain/FixedPoint.swift")],
            config,
            self.evidence,
        )

        self.assertEqual(plan["status"], "invalid")
        self.assertEqual(plan["commands"], [])
        self.assertIn("invalid_test_filter", {finding["code"] for finding in plan["findings"]})

    def test_changed_module_test_routes_only_hostless_module_lane(self):
        plan = self.plan_live(ROUTER.Change("M", "Native/AmbitionsModuleTests/TimeFoundationModuleTests.swift"))

        self.assertEqual(plan["status"], "planned", plan)
        self.assertEqual([lane["kind"] for lane in plan["lanes"]], ["module"])
        self.assertEqual(self.filters(plan, "module"), ["AmbitionsModuleTests/TimeFoundationModuleTests"])

    def test_direct_unit_and_ui_test_files_derive_declared_suites(self):
        unit = self.plan_live(ROUTER.Change("M", "Native/AmbitionsTests/Domain/CoreDomainCanonicalOwnershipTests.swift"))
        ui = self.plan_live(ROUTER.Change("M", "Native/AmbitionsUITests/TodaySurfaceUITests.swift"))

        self.assertEqual(self.filters(unit, "integration"), ["AmbitionsTests/CoreDomainCanonicalOwnershipTests"])
        self.assertEqual(self.filters(ui, "ui"), ["AmbitionsUITests/TodaySurfaceUITests"])

    def test_swift_testing_suite_is_discovered(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            path = root / "Native/AmbitionsTests/ExampleTestingSuite.swift"
            path.parent.mkdir(parents=True)
            path.write_text("import Testing\n@Suite struct CalendarContracts { @Test func works() {} }\n", encoding="utf-8")
            evidence = ROUTER.Evidence(
                memberships={path.relative_to(root).as_posix(): ("AmbitionsTests",)},
                nodes=("Ambitions", "AmbitionsTests"),
                edges=(("AmbitionsTests", "Ambitions"),),
                cycles=(),
            )
            plan = ROUTER.plan_changes(
                root,
                [ROUTER.Change("M", path.relative_to(root).as_posix())],
                self.config,
                evidence,
                batch="ROUTER-TEST",
            )

        self.assertEqual(plan["status"], "planned", plan)
        self.assertEqual(self.filters(plan, "integration"), ["AmbitionsTests/CalendarContracts"])

    def test_live_swift_testing_container_without_suite_attribute_is_discovered(self):
        plan = self.plan_live(
            ROUTER.Change("M", "Native/AmbitionsTests/LocalRuntimeOS/Repair/RepairPlanEngineTests.swift")
        )

        self.assertEqual(plan["status"], "planned", plan)
        self.assertEqual(self.filters(plan, "integration"), ["AmbitionsTests/RepairPlanTestingTests"])

    def test_each_canonical_surface_has_an_explicit_ui_route(self):
        cases = {
            "Native/Ambitions/Surfaces/Today/TodaySurface.swift": "AmbitionsUITests/TodaySurfaceUITests",
            "Native/Ambitions/Surfaces/Goals/GoalsSurface.swift": "AmbitionsUITests/GoalsSurfaceUITests",
            "Native/Ambitions/Surfaces/Time/TimeSurface.swift": "AmbitionsUITests/TimeSurfaceUITests",
            "Native/Ambitions/Surfaces/You/YouSurface.swift": "AmbitionsUITests/YouSurfaceUITests",
            "Native/Ambitions/Composer/Capture/CaptureSurface.swift": "AmbitionsUITests/CaptureComposerUITests",
            "Native/Ambitions/Stage/AmbitionsStage.swift": "AmbitionsUITests/BootstrapShellUITests",
        }
        for path, expected in cases.items():
            with self.subTest(path=path):
                plan = self.plan_live(ROUTER.Change("M", path))
                self.assertEqual(plan["status"], "planned", plan)
                self.assertEqual([lane["kind"] for lane in plan["lanes"]], ["integration", "ui"])
                self.assertIn(expected, self.filters(plan, "ui"))

        calendar = self.plan_live(
            ROUTER.Change("M", "Native/Ambitions/Surfaces/Time/Projection/TimeCalendarAwarenessSupport.swift")
        )
        noncalendar = self.plan_live(ROUTER.Change("M", "Native/Ambitions/Surfaces/Time/TimeSurface.swift"))
        self.assertIn("AmbitionsUITests/TimeCalendarGradeUITests", self.filters(calendar, "ui"))
        self.assertNotIn("AmbitionsUITests/TimeCalendarGradeUITests", self.filters(noncalendar, "ui"))

    def test_docs_only_routes_no_xcode(self):
        plan = self.plan_live(ROUTER.Change("M", "docs/README.md"))

        self.assertEqual(plan["status"], "no_tests", plan)
        self.assertEqual(plan["lanes"], [])
        self.assertEqual(plan["commands"], [])

    def test_unknown_production_path_fails_closed(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            path = root / "Native/Ambitions/Core/Unrouted.swift"
            path.parent.mkdir(parents=True)
            path.write_text("struct Unrouted {}\n", encoding="utf-8")
            evidence = ROUTER.Evidence(
                memberships={path.relative_to(root).as_posix(): ("Ambitions",)},
                nodes=("Ambitions",),
                edges=(),
                cycles=(),
            )
            plan = ROUTER.plan_changes(root, [ROUTER.Change("M", path.relative_to(root).as_posix())], self.config, evidence)

        self.assertEqual(plan["status"], "invalid")
        self.assertEqual(plan["commands"], [])
        self.assertIn("unknown_production_path", {finding["code"] for finding in plan["findings"]})

    def test_test_support_file_without_suite_fails_closed(self):
        plan = self.plan_live(ROUTER.Change("M", "Native/AmbitionsUITests/AmbitionsShellUITestSupport.swift"))

        self.assertEqual(plan["status"], "invalid")
        self.assertEqual(plan["commands"], [])
        self.assertIn("test_support_without_suite", {finding["code"] for finding in plan["findings"]})

    def test_ambiguous_equal_specificity_routes_fail_closed(self):
        config = dict(self.config)
        config["routes"] = [
            {"id": "a", "patterns": ["Native/Ambitions/Core/Domain/**"], "specificity": 100, "requiredMembership": ["Ambitions"], "integration": ["AmbitionsTests/CoreDomainCanonicalOwnershipTests"]},
            {"id": "b", "patterns": ["Native/Ambitions/Core/Domain/**"], "specificity": 100, "requiredMembership": ["Ambitions"], "integration": ["AmbitionsTests/DomainFoundationTests"]},
        ]
        plan = ROUTER.plan_changes(
            REPO_ROOT,
            [ROUTER.Change("M", "Native/Ambitions/Core/Domain/FixedPoint.swift")],
            config,
            self.evidence,
        )

        self.assertEqual(plan["status"], "invalid")
        self.assertEqual(plan["commands"], [])
        self.assertIn("ambiguous_route", {finding["code"] for finding in plan["findings"]})

    def test_new_source_without_live_membership_fails_closed(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            path = root / "Native/Ambitions/Core/Time/NewClock.swift"
            path.parent.mkdir(parents=True)
            path.write_text("struct NewClock {}\n", encoding="utf-8")
            evidence = ROUTER.Evidence(memberships={}, nodes=self.evidence.nodes, edges=self.evidence.edges, cycles=())
            plan = ROUTER.plan_changes(root, [ROUTER.Change("A", path.relative_to(root).as_posix())], self.config, evidence)

        self.assertEqual(plan["status"], "invalid")
        self.assertEqual(plan["commands"], [])
        self.assertIn("source_not_in_live_membership", {finding["code"] for finding in plan["findings"]})

    def test_stale_membership_for_missing_source_fails_closed(self):
        missing_path = "Native/Ambitions/Core/MovedClock.swift"
        memberships = dict(self.evidence.memberships)
        memberships[missing_path] = ("AmbitionsTimeFoundation",)
        evidence = ROUTER.Evidence(
            memberships=memberships,
            nodes=self.evidence.nodes,
            edges=self.evidence.edges,
            cycles=(),
        )
        plan = ROUTER.plan_changes(
            REPO_ROOT,
            [ROUTER.Change("M", missing_path)],
            self.config,
            evidence,
        )

        self.assertEqual(plan["status"], "invalid")
        self.assertEqual(plan["commands"], [])
        self.assertIn("live_membership_source_missing", {finding["code"] for finding in plan["findings"]})

    def test_rename_requires_old_and_new_path_coverage(self):
        plan = self.plan_live(
            ROUTER.Change(
                "R",
                "Native/Ambitions/Core/Time/RuntimeTickPolicy.swift",
                old_path="Native/Ambitions/Core/UnroutedClock.swift",
            )
        )

        self.assertEqual(plan["status"], "invalid")
        self.assertEqual(plan["commands"], [])
        self.assertIn("rename_path_uncovered", {finding["code"] for finding in plan["findings"]})

    def test_mixed_change_set_orders_module_hosted_then_ui(self):
        plan = self.plan_live(
            ROUTER.Change("M", "Native/Ambitions/Core/Time/RuntimeTickPolicy.swift"),
            ROUTER.Change("M", "Native/Ambitions/Surfaces/Today/TodaySurface.swift"),
        )

        self.assertEqual(plan["status"], "planned", plan)
        self.assertEqual([lane["kind"] for lane in plan["lanes"]], ["module", "integration", "ui"])

    def test_module_target_reaching_app_is_not_hostless(self):
        evidence = ROUTER.Evidence(
            memberships=self.evidence.memberships,
            nodes=self.evidence.nodes,
            edges=self.evidence.edges + (("AmbitionsModuleTests", "Ambitions"),),
            cycles=(),
        )
        plan = ROUTER.plan_changes(
            REPO_ROOT,
            [ROUTER.Change("M", "Native/Ambitions/Core/Time/RuntimeTickPolicy.swift")],
            self.config,
            evidence,
        )

        self.assertEqual(plan["status"], "invalid")
        self.assertEqual(plan["commands"], [])
        self.assertIn("module_test_target_is_hosted", {finding["code"] for finding in plan["findings"]})

    def test_time_module_route_requires_all_live_dependency_edges(self):
        evidence = ROUTER.Evidence(
            memberships=self.evidence.memberships,
            nodes=self.evidence.nodes,
            edges=tuple(edge for edge in self.evidence.edges if edge != ("AmbitionsTests", "AmbitionsTimeFoundation")),
            cycles=(),
        )
        plan = ROUTER.plan_changes(
            REPO_ROOT,
            [ROUTER.Change("M", "Native/Ambitions/Core/Time/RuntimeTickPolicy.swift")],
            self.config,
            evidence,
        )

        self.assertEqual(plan["status"], "invalid")
        self.assertEqual(plan["commands"], [])
        self.assertIn("required_module_edge_missing", {finding["code"] for finding in plan["findings"]})

    def test_project_or_test_plan_change_requires_explicit_route(self):
        for path in ("project.yml", "Ambitions.xcodeproj/project.pbxproj", "Native/AmbitionsTests/AmbitionsTests.xctestplan"):
            with self.subTest(path=path):
                plan = self.plan_live(ROUTER.Change("M", path))
                self.assertEqual(plan["status"], "invalid")
                self.assertEqual(plan["commands"], [])
                self.assertIn("project_evidence_changed", {finding["code"] for finding in plan["findings"]})

    def test_any_invalid_path_prevents_all_execution(self):
        plan = self.plan_live(
            ROUTER.Change("M", "Native/Ambitions/Core/Time/RuntimeTickPolicy.swift"),
            ROUTER.Change("M", "Native/Ambitions/Core/Unrouted.swift"),
        )
        executed = []
        status = ROUTER.execute_plan(plan, runner=lambda command: executed.append(command) or 0)

        self.assertEqual(plan["status"], "invalid")
        self.assertEqual(plan["commands"], [])
        self.assertNotEqual(status, 0)
        self.assertEqual(executed, [])

    def test_each_selected_scheme_batches_all_suites_into_one_test_launch(self):
        plan = self.plan_live(ROUTER.Change("M", "Native/Ambitions/Core/Time/RuntimeTickPolicy.swift"))

        launches = [command for command in plan["commands"] if "scripts/ambitions-xcode-test-focused.sh" in command]
        prebuilds = [command for command in plan["commands"] if "scripts/ambitions-xcode-build-for-testing.sh" in command]
        self.assertEqual(len(launches), 2)
        self.assertEqual(len(prebuilds), 2)
        self.assertEqual(sum(arg == "--only-testing" for arg in launches[0]), 1)
        self.assertEqual(sum(arg == "--only-testing" for arg in launches[1]), 6)

    def test_duplicate_selectors_dedupe_without_reordering(self):
        plan = self.plan_live(
            ROUTER.Change("M", "Native/Ambitions/Core/Time/RuntimeTickPolicy.swift"),
            ROUTER.Change("M", "Native/Ambitions/Core/Time/SystemClock.swift"),
        )

        self.assertEqual(len(self.filters(plan, "module")), 1)
        self.assertEqual(len(self.filters(plan, "integration")), 6)

    def test_dry_run_commands_are_the_exact_shell_false_execution_argv(self):
        plan = self.plan_live(ROUTER.Change("M", "Native/Ambitions/Core/Time/RuntimeTickPolicy.swift"))
        observed = []

        status = ROUTER.execute_plan(plan, runner=lambda command: observed.append(list(command)) or 0)

        self.assertEqual(status, 0)
        self.assertEqual(observed, plan["commands"])

    def test_failed_module_prebuild_stops_all_later_commands(self):
        plan = self.plan_live(
            ROUTER.Change("M", "Native/Ambitions/Core/Time/RuntimeTickPolicy.swift"),
            ROUTER.Change("M", "Native/Ambitions/Surfaces/Today/TodaySurface.swift"),
        )
        observed = []

        status = ROUTER.execute_plan(plan, runner=lambda command: observed.append(list(command)) or 31)

        self.assertEqual(status, 31)
        self.assertEqual(observed, [plan["commands"][0]])

    def test_python_script_test_routes_to_exact_module(self):
        plan = self.plan_live(ROUTER.Change("M", "scripts/tests/test_ambitions_build_graph_audit.py"))

        self.assertEqual(plan["status"], "planned", plan)
        self.assertEqual([lane["kind"] for lane in plan["lanes"]], ["script"])
        self.assertEqual(plan["commands"], [["python3", "-m", "unittest", "scripts.tests.test_ambitions_build_graph_audit", "-v"]])

    def test_python_tool_routes_to_its_single_exact_test_module(self):
        plan = self.plan_live(ROUTER.Change("M", "scripts/ambitions-build-graph-audit.py"))

        self.assertEqual(plan["status"], "planned", plan)
        self.assertEqual(plan["commands"], [["python3", "-m", "unittest", "scripts.tests.test_ambitions_build_graph_audit", "-v"]])

    def test_focused_and_router_tooling_paths_have_explicit_python_routes(self):
        cases = {
            "scripts/ambitions-xcode-test-focused.sh": "scripts.tests.test_ambitions_xcode_runner_reliability",
            ".xcodebuildmcp/config.yaml": "scripts.tests.test_ambitions_xcode_runner_reliability",
            "scripts/ambitions-changed-file-test-router.py": "scripts.tests.test_ambitions_changed_file_test_router",
            "scripts/ambitions-changed-file-test-routes.json": "scripts.tests.test_ambitions_changed_file_test_router",
        }
        for path, expected in cases.items():
            with self.subTest(path=path):
                plan = self.plan_live(ROUTER.Change("M", path))
                self.assertEqual(plan["status"], "planned", plan)
                self.assertEqual(plan["commands"], [["python3", "-m", "unittest", expected, "-v"]])

    def test_bounded_xcodebuild_routes_to_reliability_and_lane_lock_tests_only(self):
        bounded = self.plan_live(ROUTER.Change("M", "scripts/ambitions-bounded-xcodebuild.sh"))
        focused = self.plan_live(ROUTER.Change("M", "scripts/ambitions-xcode-test-focused.sh"))

        self.assertEqual(
            bounded["commands"],
            [[
                "python3",
                "-m",
                "unittest",
                "scripts.tests.test_ambitions_xcode_runner_reliability",
                "scripts.tests.test_ambitions_xcode_lane_lock",
                "-v",
            ]],
        )
        self.assertEqual(
            focused["commands"],
            [["python3", "-m", "unittest", "scripts.tests.test_ambitions_xcode_runner_reliability", "-v"]],
        )

    def test_result_extraction_and_prebuild_tooling_have_exact_python_routes(self):
        cases = {
            "scripts/ambitions-xcode-result-extract.sh": [
                "scripts.tests.test_ambitions_xcode_result_extract",
                "scripts.tests.test_ambitions_xcode_runner_reliability",
            ],
            "scripts/ambitions-xcode-build-for-testing.sh": [
                "scripts.tests.test_ambitions_xcode_runner_reliability",
            ],
        }

        for path, expected_tests in cases.items():
            with self.subTest(path=path):
                plan = self.plan_live(ROUTER.Change("M", path))
                self.assertEqual(plan["status"], "planned", plan)
                self.assertEqual(
                    plan["commands"],
                    [["python3", "-m", "unittest", *expected_tests, "-v"]],
                )


class ChangedFileTestRouterCLITests(unittest.TestCase):
    def test_malformed_config_exits_two(self):
        with tempfile.NamedTemporaryFile("w", suffix=".json", delete=False) as config:
            config.write("not-json")
            config_path = Path(config.name)
        try:
            result = subprocess.run(
                ["python3", str(ROUTER_PATH), "--config", str(config_path), "--path", "docs/README.md", "--json"],
                cwd=REPO_ROOT,
                capture_output=True,
                text=True,
            )
        finally:
            config_path.unlink(missing_ok=True)

        self.assertEqual(result.returncode, 2, result.stdout + result.stderr)

    def test_routes_alias_and_explicit_worktree_are_accepted(self):
        parsed = ROUTER._parser().parse_args(["--routes", str(CONFIG_PATH), "--worktree", "--json"])

        self.assertEqual(parsed.config, CONFIG_PATH)
        self.assertTrue(parsed.worktree)

    def test_nondefault_head_without_base_is_rejected(self):
        result = subprocess.run(
            ["python3", str(ROUTER_PATH), "--head", "HEAD~1", "--json"],
            cwd=REPO_ROOT,
            capture_output=True,
            text=True,
        )

        self.assertEqual(result.returncode, 2, result.stdout + result.stderr)

    def test_malformed_route_field_type_exits_two(self):
        payload = json.loads(CONFIG_PATH.read_text(encoding="utf-8"))
        payload["routes"][0]["patterns"] = [42]
        with tempfile.NamedTemporaryFile("w", suffix=".json", delete=False) as config:
            json.dump(payload, config)
            config_path = Path(config.name)
        try:
            result = subprocess.run(
                ["python3", str(ROUTER_PATH), "--config", str(config_path), "--path", "docs/README.md", "--json"],
                cwd=REPO_ROOT,
                capture_output=True,
                text=True,
            )
        finally:
            config_path.unlink(missing_ok=True)

        self.assertEqual(result.returncode, 2, result.stdout + result.stderr)


if __name__ == "__main__":
    unittest.main()
