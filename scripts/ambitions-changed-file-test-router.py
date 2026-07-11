#!/usr/bin/env python3
"""Plan and optionally run the smallest evidence-backed tests for changed files."""

from __future__ import annotations

import argparse
import importlib.util
import json
import re
import subprocess
import sys
from collections import defaultdict
from pathlib import Path, PurePosixPath
from typing import Callable, NamedTuple, Sequence


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_CONFIG = ROOT / "scripts/ambitions-changed-file-test-routes.json"
LANE_ORDER = ("script", "module", "integration", "ui")
SWIFT_TEST_TARGETS = {
    "Native/AmbitionsModuleTests": "AmbitionsModuleTests",
    "Native/AmbitionsTests": "AmbitionsTests",
    "Native/AmbitionsUITests": "AmbitionsUITests",
}
PRODUCTION_ROOTS = (
    "Native/Ambitions",
    "Native/AmbitionsShareExtension",
    "Native/AmbitionsWidgetExtension",
    "Packages/AmbitionsDesignSystem/Sources",
    "Packages/AmbitionsDesignSystem/AppUI/Sources",
)


class ConfigurationError(ValueError):
    """Malformed route configuration or project evidence."""


class Change(NamedTuple):
    status: str
    path: str
    old_path: str | None = None


class Evidence(NamedTuple):
    memberships: dict[str, tuple[str, ...]]
    nodes: tuple[str, ...]
    edges: tuple[tuple[str, str], ...]
    cycles: tuple[tuple[str, ...], ...]


def _load_script(path: Path, name: str):
    spec = importlib.util.spec_from_file_location(name, path)
    if spec is None or spec.loader is None:
        raise ConfigurationError(f"cannot load audit module: {path}")
    module = importlib.util.module_from_spec(spec)
    sys.modules[name] = module
    spec.loader.exec_module(module)
    return module


def load_live_evidence(root: Path, project: Path) -> Evidence:
    """Reuse the retained audits to read current PBX membership and graph facts."""
    try:
        source_audit = _load_script(
            root / "scripts/ambitions-source-disposition-audit.py",
            "ambitions_source_disposition_audit_for_router",
        )
        graph_audit = _load_script(
            root / "scripts/ambitions-build-graph-audit.py",
            "ambitions_build_graph_audit_for_router",
        )
        document = source_audit.load_pbx_json(project)
        memberships = source_audit.target_membership_from_pbx_json(document)
        objects = graph_audit._load_objects(project)
        nodes = tuple(sorted(graph_audit.native_targets(objects)))
        edges = tuple(sorted(graph_audit.target_edges(objects)))
        cycles = tuple(tuple(cycle) for cycle in graph_audit.dependency_cycles(edges))
    except (OSError, ValueError, KeyError, subprocess.CalledProcessError, json.JSONDecodeError) as error:
        raise ConfigurationError(f"invalid live project evidence: {error}") from error
    if not memberships or not nodes:
        raise ConfigurationError("live project evidence has no target membership or nodes")
    return Evidence(
        memberships={path: tuple(sorted(targets)) for path, targets in memberships.items()},
        nodes=nodes,
        edges=edges,
        cycles=cycles,
    )


def load_config(path: Path) -> dict:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise ConfigurationError(f"invalid route config: {error}") from error
    if not isinstance(payload, dict) or payload.get("schemaVersion") != 1:
        raise ConfigurationError("route config must use schemaVersion 1")
    if not isinstance(payload.get("testTargets"), dict) or not isinstance(payload.get("routes"), list):
        raise ConfigurationError("route config requires testTargets and routes")

    def require_strings(value, label: str, *, allow_empty: bool = True) -> list[str]:
        if (
            not isinstance(value, list)
            or (not allow_empty and not value)
            or not all(isinstance(item, str) and item for item in value)
        ):
            raise ConfigurationError(f"{label} must be a list of nonempty strings")
        return value

    require_strings(payload.get("documentationPatterns", []), "documentationPatterns")
    require_strings(payload.get("projectEvidencePatterns", []), "projectEvidencePatterns")
    required_edges = payload.get("requiredEdges", [])
    if (
        not isinstance(required_edges, list)
        or not all(
            isinstance(edge, list)
            and len(edge) == 2
            and all(isinstance(node, str) and node for node in edge)
            for edge in required_edges
        )
    ):
        raise ConfigurationError("requiredEdges must contain two-node string pairs")
    for target_name, target in payload["testTargets"].items():
        if not isinstance(target_name, str) or not isinstance(target, dict):
            raise ConfigurationError("testTargets must map names to objects")
        if target.get("kind") not in {"module", "integration", "ui"}:
            raise ConfigurationError(f"test target {target_name} has invalid kind")
        if not isinstance(target.get("scheme"), str) or not target["scheme"]:
            raise ConfigurationError(f"test target {target_name} requires a scheme")
        require_strings(target.get("forbiddenReachability", []), f"test target {target_name} forbiddenReachability")
    tooling_routes = payload.get("toolingRoutes", [])
    if not isinstance(tooling_routes, list):
        raise ConfigurationError("toolingRoutes must be a list")
    tooling_ids: set[str] = set()
    for route in tooling_routes:
        if not isinstance(route, dict) or not isinstance(route.get("id"), str) or not route["id"]:
            raise ConfigurationError("each tooling route requires an id")
        if route["id"] in tooling_ids:
            raise ConfigurationError(f"duplicate tooling route id: {route['id']}")
        tooling_ids.add(route["id"])
        require_strings(route.get("patterns"), f"tooling route {route['id']} patterns", allow_empty=False)
        require_strings(route.get("pythonTests"), f"tooling route {route['id']} pythonTests", allow_empty=False)
    membership_routes = payload.get("membershipRoutes", [])
    if not isinstance(membership_routes, list):
        raise ConfigurationError("membershipRoutes must be a list")
    membership_ids: set[str] = set()
    for route in membership_routes:
        if not isinstance(route, dict) or not isinstance(route.get("id"), str) or not route["id"]:
            raise ConfigurationError("each membership route requires an id")
        if route["id"] in membership_ids:
            raise ConfigurationError(f"duplicate membership route id: {route['id']}")
        membership_ids.add(route["id"])
        require_strings(
            route.get("requiredMembership"),
            f"membership route {route['id']} requiredMembership",
            allow_empty=False,
        )
        for lane in ("module", "integration", "ui"):
            require_strings(route.get(lane, []), f"membership route {route['id']} {lane} filters")
    route_ids: set[str] = set()
    for route in payload["routes"]:
        if not isinstance(route, dict) or not isinstance(route.get("id"), str):
            raise ConfigurationError("each route requires an id")
        if route["id"] in route_ids:
            raise ConfigurationError(f"duplicate route id: {route['id']}")
        route_ids.add(route["id"])
        require_strings(route.get("patterns"), f"route {route['id']} patterns", allow_empty=False)
        if not isinstance(route.get("specificity"), int):
            raise ConfigurationError(f"route {route['id']} requires integer specificity")
        require_strings(route.get("requiredMembership", []), f"route {route['id']} requiredMembership")
        for lane in ("module", "integration", "ui"):
            require_strings(route.get(lane, []), f"route {route['id']} {lane} filters")
    return payload


def _glob_regex(pattern: str) -> re.Pattern[str]:
    output = ""
    index = 0
    while index < len(pattern):
        character = pattern[index]
        if character == "*":
            if index + 1 < len(pattern) and pattern[index + 1] == "*":
                output += ".*"
                index += 2
            else:
                output += "[^/]*"
                index += 1
        elif character == "?":
            output += "[^/]"
            index += 1
        else:
            output += re.escape(character)
            index += 1
    return re.compile(f"^{output}$")


def _matches(path: str, patterns: Sequence[str]) -> bool:
    return any(_glob_regex(pattern).match(path) for pattern in patterns)


def _normalized(path: str) -> str | None:
    if not path or "\\" in path or path.startswith("/"):
        return None
    normalized = PurePosixPath(path).as_posix()
    if normalized == "." or ".." in PurePosixPath(normalized).parts:
        return None
    return normalized


XCTEST_SUITE_RE = re.compile(
    r"\bclass\s+([A-Za-z_]\w*)[^\n{]*:\s*[^\n{]*[A-Za-z_]\w*TestCase\b"
)
SWIFT_TESTING_SUITE_RE = re.compile(
    r"@Suite(?:\s*\([^)]*\))?\s*(?:(?:@\w+(?:\([^)]*\))?\s*)*)(?:final\s+)?(?:struct|class|actor)\s+([A-Za-z_]\w*)",
    re.MULTILINE,
)
SWIFT_TESTING_CONTAINER_RE = re.compile(
    r"\b(?:struct|class|actor)\s+([A-Za-z_]\w*Tests)\b"
)


def swift_test_suites(path: Path) -> tuple[str, ...]:
    try:
        text = path.read_text(encoding="utf-8")
    except OSError:
        return ()
    xctest_suites = {suite for suite in XCTEST_SUITE_RE.findall(text) if suite.endswith("Tests")}
    swift_testing_suites = set(SWIFT_TESTING_SUITE_RE.findall(text))
    if re.search(r"(?m)^\s*import\s+Testing\s*$", text) and re.search(r"@Test\b", text):
        swift_testing_suites.update(SWIFT_TESTING_CONTAINER_RE.findall(text))
    return tuple(sorted(xctest_suites | swift_testing_suites))


def _test_target_for_path(path: str) -> str | None:
    for root, target in SWIFT_TEST_TARGETS.items():
        if path == root or path.startswith(root + "/"):
            return target
    return None


def _suite_index(root: Path) -> dict[tuple[str, str], tuple[str, ...]]:
    found: defaultdict[tuple[str, str], list[str]] = defaultdict(list)
    for test_root, target in SWIFT_TEST_TARGETS.items():
        directory = root / test_root
        if not directory.exists():
            continue
        for path in sorted(directory.rglob("*.swift")):
            relative = path.relative_to(root).as_posix()
            for suite in swift_test_suites(path):
                found[(target, suite)].append(relative)
    return {key: tuple(paths) for key, paths in found.items()}


def _finding(code: str, path: str, detail: str) -> dict[str, str]:
    return {"code": code, "path": path, "detail": detail}


def _route_for_path(path: str, config: dict) -> tuple[dict | None, str | None]:
    matches = [route for route in config["routes"] if _matches(path, route["patterns"])]
    if not matches:
        return None, None
    specificity = max(route["specificity"] for route in matches)
    strongest = [route for route in matches if route["specificity"] == specificity]
    if len(strongest) != 1:
        return None, "ambiguous_route"
    return strongest[0], None


def _tooling_route_for_path(path: str, config: dict) -> tuple[dict | None, str | None]:
    matches = [route for route in config.get("toolingRoutes", []) if _matches(path, route["patterns"])]
    if len(matches) > 1:
        return None, "ambiguous_tooling_route"
    return (matches[0], None) if matches else (None, None)


def _membership_route_for_targets(membership: Sequence[str], config: dict) -> tuple[dict | None, str | None]:
    normalized = tuple(sorted(membership))
    matches = [
        route
        for route in config.get("membershipRoutes", [])
        if tuple(sorted(route["requiredMembership"])) == normalized
    ]
    if len(matches) > 1:
        return None, "ambiguous_membership_route"
    return (matches[0], None) if matches else (None, None)


def _transitive_reachability(start: str, edges: Sequence[tuple[str, str]]) -> set[str]:
    adjacency: defaultdict[str, set[str]] = defaultdict(set)
    for source, destination in edges:
        adjacency[source].add(destination)
    reached: set[str] = set()
    pending = list(adjacency[start])
    while pending:
        node = pending.pop()
        if node in reached:
            continue
        reached.add(node)
        pending.extend(adjacency[node] - reached)
    return reached


def _append_unique(destination: list[str], values: Sequence[str]) -> None:
    for value in values:
        if value not in destination:
            destination.append(value)


def _validate_selected_suites(
    root: Path,
    lane_tests: dict[str, list[str]],
    evidence: Evidence,
    findings: list[dict[str, str]],
) -> None:
    index = _suite_index(root)
    expected_targets = {
        "module": "AmbitionsModuleTests",
        "integration": "AmbitionsTests",
        "ui": "AmbitionsUITests",
    }
    for lane, filters in lane_tests.items():
        if lane not in expected_targets:
            continue
        expected_target = expected_targets[lane]
        for test_filter in filters:
            if test_filter == expected_target:
                if expected_target not in evidence.nodes:
                    findings.append(
                        _finding(
                            "test_target_not_live",
                            test_filter,
                            f"target-only selector for {lane} is absent from the live graph",
                        )
                    )
                continue
            target, separator, suite = test_filter.partition("/")
            if not separator or target != expected_target or not suite:
                findings.append(_finding("invalid_test_filter", test_filter, f"filter is incompatible with {lane}"))
                continue
            locations = index.get((target, suite), ())
            if len(locations) != 1:
                findings.append(
                    _finding(
                        "test_suite_not_unique",
                        test_filter,
                        f"expected one live declaration, found {len(locations)}",
                    )
                )


def _xcode_commands(batch: str, lane: str, scheme: str, tests: Sequence[str]) -> list[list[str]]:
    prebuild = [
        "bash",
        "scripts/ambitions-xcode-build-for-testing.sh",
        "--batch",
        f"{batch}-{lane.upper()}-PREBUILD",
        "--scheme",
        scheme,
    ]
    focused = [
        "bash",
        "scripts/ambitions-xcode-test-focused.sh",
        "--batch",
        f"{batch}-{lane.upper()}",
        "--scheme",
        scheme,
    ]
    for test_filter in tests:
        focused.extend(("--only-testing", test_filter))
    focused.extend(("--without-building", "--timeout", "2m", "--kill-after", "15s"))
    return [prebuild, focused]


def plan_changes(
    root: Path,
    changes: Sequence[Change],
    config: dict,
    evidence: Evidence,
    batch: str = "CHANGED-FILE",
) -> dict:
    findings: list[dict[str, str]] = []
    lane_tests = {lane: [] for lane in LANE_ORDER}
    script_modules: list[str] = []
    considered_paths: list[str] = []

    if evidence.cycles:
        findings.append(_finding("project_graph_cycle", config.get("project", ""), "live target graph is cyclic"))

    def inspect_path(path_value: str, status: str, rename_side: str | None = None) -> None:
        normalized = _normalized(path_value)
        if normalized is None:
            findings.append(_finding("invalid_path", path_value, "path must be normalized and repo-relative"))
            return
        considered_paths.append(normalized)
        if _matches(normalized, config.get("projectEvidencePatterns", [])):
            findings.append(_finding("project_evidence_changed", normalized, "project or test-plan changes require an explicit reviewed route"))
            return
        if _matches(normalized, config.get("documentationPatterns", [])):
            return
        tooling_route, tooling_error = _tooling_route_for_path(normalized, config)
        if tooling_error:
            findings.append(_finding(tooling_error, normalized, "multiple explicit tooling routes matched"))
            return
        if tooling_route is not None:
            _append_unique(script_modules, tooling_route["pythonTests"])
            return
        if normalized.startswith("scripts/tests/") and normalized.endswith(".py"):
            module = normalized[:-3].replace("/", ".")
            source = root / normalized
            if not source.exists() or not re.search(r"\b(?:class\s+\w+\s*\([^)]*(?:TestCase|unittest\.TestCase)[^)]*\)|def\s+test_\w+)", source.read_text(encoding="utf-8", errors="replace")):
                findings.append(_finding("test_support_without_suite", normalized, "Python test file has no discoverable test"))
            elif module not in script_modules:
                script_modules.append(module)
            return
        if normalized.startswith("scripts/") and normalized.endswith(".py"):
            expected_name = f"test_{PurePosixPath(normalized).stem.replace('-', '_')}.py"
            candidates = sorted((root / "scripts/tests").rglob(expected_name)) if (root / "scripts/tests").exists() else []
            if len(candidates) == 1:
                module = candidates[0].relative_to(root).with_suffix("").as_posix().replace("/", ".")
                _append_unique(script_modules, [module])
            elif len(candidates) > 1:
                findings.append(_finding("ambiguous_python_test_route", normalized, f"found {len(candidates)} exact test files"))
            else:
                findings.append(_finding("unrouted_path", normalized, f"missing exact scripts/tests/{expected_name}"))
            return
        test_target = _test_target_for_path(normalized)
        if test_target is not None and normalized.endswith(".swift"):
            source = root / normalized
            suites = swift_test_suites(source)
            if not suites:
                findings.append(_finding("test_support_without_suite", normalized, "Swift test file has no declared test suite"))
                return
            membership = evidence.memberships.get(normalized, ())
            if status not in {"D", "R-old"} and test_target not in membership:
                findings.append(_finding("source_not_in_live_membership", normalized, f"expected membership in {test_target}"))
                return
            target_config = config["testTargets"].get(test_target)
            if not target_config:
                findings.append(_finding("unknown_test_target", normalized, test_target))
                return
            lane = target_config["kind"]
            _append_unique(lane_tests[lane], [f"{test_target}/{suite}" for suite in suites])
            return
        membership = evidence.memberships.get(normalized, ()) if status not in {"D", "R-old"} else ()
        if membership and status not in {"D", "R-old"} and not (root / normalized).is_file():
            findings.append(
                _finding(
                    "live_membership_source_missing",
                    normalized,
                    "live PBX membership references a missing source file",
                )
            )
            return
        membership_route, membership_error = _membership_route_for_targets(membership, config)
        if membership_error:
            findings.append(_finding(membership_error, normalized, "multiple live-membership routes matched"))
            return
        route, route_error = (membership_route, None) if membership_route is not None else _route_for_path(normalized, config)
        if route_error:
            code = "rename_path_uncovered" if rename_side else route_error
            findings.append(_finding(code, normalized, "multiple equal-specificity routes matched"))
            return
        if route is None:
            if rename_side:
                findings.append(_finding("rename_path_uncovered", normalized, f"{rename_side} rename path has no explicit route"))
            elif any(normalized == production or normalized.startswith(production + "/") for production in PRODUCTION_ROOTS):
                findings.append(_finding("unknown_production_path", normalized, "no explicit production route"))
            else:
                findings.append(_finding("unrouted_path", normalized, "no explicit no-test or test route"))
            return
        if status not in {"D", "R-old"}:
            if not membership:
                findings.append(_finding("source_not_in_live_membership", normalized, "source is absent from live PBX membership"))
                return
            required = tuple(sorted(route.get("requiredMembership", [])))
            if tuple(sorted(membership)) != required:
                findings.append(
                    _finding(
                        "stale_route_membership",
                        normalized,
                        f"expected {list(required)}, found {list(membership)}",
                    )
                )
                return
        for lane in ("module", "integration", "ui"):
            _append_unique(lane_tests[lane], route.get(lane, []))

    for change in changes:
        status = change.status.upper()
        if status == "R":
            if not change.old_path:
                findings.append(_finding("rename_path_uncovered", change.path, "rename is missing its old path"))
                continue
            inspect_path(change.old_path, "R-old", "old")
            inspect_path(change.path, "R-new", "new")
        else:
            inspect_path(change.path, status)

    if lane_tests["module"]:
        module_target = "AmbitionsModuleTests"
        target_config = config["testTargets"].get(module_target, {})
        if module_target not in evidence.nodes:
            findings.append(_finding("module_test_target_missing", module_target, "target is absent from live graph"))
        reached = _transitive_reachability(module_target, evidence.edges)
        forbidden = sorted(reached.intersection(target_config.get("forbiddenReachability", [])))
        if forbidden:
            findings.append(
                _finding(
                    "module_test_target_is_hosted",
                    module_target,
                    "transitively reaches " + ", ".join(forbidden),
                )
            )
        live_edges = set(evidence.edges)
        for source, destination in config.get("requiredEdges", []):
            if (source, destination) not in live_edges:
                findings.append(
                    _finding(
                        "required_module_edge_missing",
                        f"{source}->{destination}",
                        "required live target edge is absent",
                    )
                )

    for module in script_modules:
        module_path = root / (module.replace(".", "/") + ".py")
        if not module_path.is_file():
            findings.append(_finding("python_test_module_missing", module, "configured Python test module is absent"))
            continue
        text = module_path.read_text(encoding="utf-8", errors="replace")
        if not re.search(r"\b(?:class\s+\w+\s*\([^)]*(?:TestCase|unittest\.TestCase)[^)]*\)|def\s+test_\w+)", text):
            findings.append(_finding("test_support_without_suite", module, "configured Python module has no discoverable test"))

    _validate_selected_suites(root, lane_tests, evidence, findings)
    if findings:
        return {
            "schema_version": 1,
            "status": "invalid",
            "paths": considered_paths,
            "lanes": [],
            "commands": [],
            "findings": findings,
            "executed": False,
        }

    lanes: list[dict] = []
    commands: list[list[str]] = []
    if script_modules:
        command = ["python3", "-m", "unittest", *script_modules, "-v"]
        lanes.append({"kind": "script", "scheme": None, "tests": list(script_modules), "commands": [command]})
        commands.append(command)
    scheme_by_lane = {
        target["kind"]: target["scheme"]
        for target in config["testTargets"].values()
        if target.get("kind") in {"module", "integration", "ui"}
    }
    for lane in ("module", "integration", "ui"):
        tests = lane_tests[lane]
        if not tests:
            continue
        scheme = scheme_by_lane[lane]
        lane_commands = _xcode_commands(batch, lane, scheme, tests)
        lanes.append({"kind": lane, "scheme": scheme, "tests": tests, "commands": lane_commands})
        commands.extend(lane_commands)
    return {
        "schema_version": 1,
        "status": "planned" if commands else "no_tests",
        "paths": considered_paths,
        "lanes": lanes,
        "commands": commands,
        "findings": [],
        "executed": False,
    }


def execute_plan(
    plan: dict,
    runner: Callable[[Sequence[str]], int | subprocess.CompletedProcess] | None = None,
) -> int:
    if plan.get("status") == "invalid":
        return 1
    if runner is None:
        runner = lambda command: subprocess.run(list(command), cwd=ROOT, shell=False).returncode
    for command in plan.get("commands", []):
        result = runner(command)
        return_code = result.returncode if isinstance(result, subprocess.CompletedProcess) else int(result)
        if return_code != 0:
            return return_code
    return 0


def _parse_name_status(payload: bytes) -> list[Change]:
    tokens = payload.decode("utf-8", errors="surrogateescape").split("\0")
    if tokens and tokens[-1] == "":
        tokens.pop()
    changes: list[Change] = []
    index = 0
    while index < len(tokens):
        status = tokens[index]
        index += 1
        if not status or index >= len(tokens):
            raise ConfigurationError("malformed git name-status output")
        code = status[0]
        if code in {"R", "C"}:
            if index + 1 >= len(tokens):
                raise ConfigurationError("malformed git rename output")
            old_path, new_path = tokens[index], tokens[index + 1]
            index += 2
            changes.append(Change("R", new_path, old_path=old_path))
        else:
            changes.append(Change(code, tokens[index]))
            index += 1
    return changes


def _git_changes(root: Path, base: str | None, head: str) -> list[Change]:
    revision = f"{base}...{head}" if base else "HEAD"
    tracked = subprocess.run(
        ["git", "diff", "--name-status", "-z", "--find-renames", revision],
        cwd=root,
        check=True,
        capture_output=True,
    )
    changes = _parse_name_status(tracked.stdout)
    if base is None:
        untracked = subprocess.run(
            ["git", "ls-files", "--others", "--exclude-standard", "-z"],
            cwd=root,
            check=True,
            capture_output=True,
        )
        for path in untracked.stdout.decode("utf-8", errors="surrogateescape").split("\0"):
            if path:
                changes.append(Change("A", path))
    return changes


def _default_batch(root: Path) -> str:
    result = subprocess.run(
        ["git", "rev-parse", "--short=12", "HEAD"],
        cwd=root,
        capture_output=True,
        text=True,
    )
    identity = result.stdout.strip() if result.returncode == 0 else "WORKTREE"
    return f"CHANGED-FILE-{identity}"


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--path", action="append", default=[])
    parser.add_argument("--rename", action="append", nargs=2, metavar=("OLD", "NEW"), default=[])
    parser.add_argument("--base")
    parser.add_argument("--head", default="HEAD")
    parser.add_argument("--worktree", action="store_true")
    parser.add_argument("--project", type=Path, default=Path("Ambitions.xcodeproj"))
    parser.add_argument("--config", "--routes", dest="config", type=Path, default=DEFAULT_CONFIG)
    parser.add_argument("--batch")
    parser.add_argument("--execute", action="store_true")
    parser.add_argument("--json", action="store_true", dest="as_json")
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    args = _parser().parse_args(argv)
    if (args.path or args.rename) and (args.base or args.worktree):
        print("error: explicit paths cannot be combined with --base or --worktree", file=sys.stderr)
        return 2
    if args.worktree and args.base:
        print("error: --worktree cannot be combined with --base", file=sys.stderr)
        return 2
    if not args.base and args.head != "HEAD":
        print("error: nondefault --head requires --base", file=sys.stderr)
        return 2
    try:
        config = load_config(args.config)
        project = args.project if args.project.is_absolute() else ROOT / args.project
        evidence = load_live_evidence(ROOT, project)
        if args.path or args.rename:
            changes = [Change("M", path) for path in args.path]
            changes.extend(Change("R", new, old_path=old) for old, new in args.rename)
        else:
            changes = _git_changes(ROOT, args.base, args.head)
    except (ConfigurationError, OSError, subprocess.CalledProcessError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 2
    plan = plan_changes(ROOT, changes, config, evidence, batch=args.batch or _default_batch(ROOT))
    status = 1 if plan["status"] == "invalid" else 0
    if args.execute and status == 0:
        status = execute_plan(plan)
        plan["executed"] = True
        plan["execution_exit"] = status
    if args.as_json:
        print(json.dumps(plan, indent=2, sort_keys=True))
    else:
        print(f"status={plan['status']}")
        for lane in plan["lanes"]:
            print(f"{lane['kind']}: {', '.join(lane['tests'])}")
        for finding in plan["findings"]:
            print(f"{finding['code']}: {finding['path']}: {finding['detail']}")
    return status


if __name__ == "__main__":
    raise SystemExit(main())
