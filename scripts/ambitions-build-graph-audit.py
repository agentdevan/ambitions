#!/usr/bin/env python3
"""Audit target dependencies and local Swift package paths in an Xcode project."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import subprocess
import sys
from typing import Any, Iterable, NamedTuple


PBXObjects = dict[str, dict[str, Any]]
TargetEdge = tuple[str, str]
PackageProductEdge = tuple[str, str]


class BuildGraph(NamedTuple):
    package_paths: tuple[str, ...]
    nodes: tuple[str, ...]
    target_edges: tuple[TargetEdge, ...]
    package_product_edges: tuple[PackageProductEdge, ...]
    cycles: tuple[tuple[str, ...], ...]
    findings: tuple[str, ...]


def native_targets(objects: PBXObjects) -> dict[str, str]:
    """Return native target names mapped to their PBX object IDs."""
    return {
        value["name"]: object_id
        for object_id, value in objects.items()
        if value.get("isa") == "PBXNativeTarget"
        and isinstance(value.get("name"), str)
    }


def target_edges(objects: PBXObjects) -> set[TargetEdge]:
    """Return resolved native-target dependency edges as target-name pairs."""
    targets = native_targets(objects)
    names_by_id = {object_id: name for name, object_id in targets.items()}
    edges: set[TargetEdge] = set()

    for source_name, source_id in targets.items():
        source = objects[source_id]
        dependencies = source.get("dependencies", [])
        if not isinstance(dependencies, list):
            continue
        for dependency_id in dependencies:
            dependency = objects.get(dependency_id, {})
            if dependency.get("isa") != "PBXTargetDependency":
                continue
            destination_id = dependency.get("target")
            if not isinstance(destination_id, str):
                proxy = objects.get(dependency.get("targetProxy"), {})
                if proxy.get("isa") == "PBXContainerItemProxy":
                    destination_id = proxy.get("remoteGlobalIDString")
            destination_name = names_by_id.get(destination_id)
            if destination_name is not None:
                edges.add((source_name, destination_name))
    return edges


def package_paths(objects: PBXObjects) -> set[str]:
    """Return local Swift package paths declared by the project."""
    paths: set[str] = set()
    for value in objects.values():
        if value.get("isa") != "XCLocalSwiftPackageReference":
            continue
        path = value.get("relativePath", value.get("path"))
        if isinstance(path, str):
            paths.add(path)
    return paths


def package_product_edges(objects: PBXObjects) -> set[PackageProductEdge]:
    """Return valid target-to-Swift-package-product dependency edges."""
    edges: set[PackageProductEdge] = set()
    for target_name, target_id in native_targets(objects).items():
        dependency_ids = objects[target_id].get("packageProductDependencies", [])
        if not isinstance(dependency_ids, list):
            continue
        for dependency_id in dependency_ids:
            if not isinstance(dependency_id, str):
                continue
            dependency = objects.get(dependency_id, {})
            product_name = dependency.get("productName")
            if (
                dependency.get("isa") == "XCSwiftPackageProductDependency"
                and isinstance(product_name, str)
                and product_name
            ):
                edges.add((target_name, product_name))
    return edges


def _invalid_package_product_findings(objects: PBXObjects) -> list[str]:
    invalid: list[tuple[str, str]] = []
    for target_name, target_id in native_targets(objects).items():
        dependency_ids = objects[target_id].get("packageProductDependencies", [])
        if not isinstance(dependency_ids, list):
            invalid.append((target_name, "<malformed-list>"))
            continue
        for dependency_id in dependency_ids:
            reference = (
                dependency_id
                if isinstance(dependency_id, str)
                else repr(dependency_id)
            )
            dependency = (
                objects.get(dependency_id, {})
                if isinstance(dependency_id, str)
                else {}
            )
            if (
                dependency.get("isa") != "XCSwiftPackageProductDependency"
                or not isinstance(dependency.get("productName"), str)
                or not dependency.get("productName")
            ):
                invalid.append((target_name, reference))
    return [
        f"invalid package product dependency: {target_name} -> {reference}"
        for target_name, reference in sorted(invalid)
    ]


def _canonical_cycle(cycle: list[str]) -> tuple[str, ...]:
    body = cycle[:-1]
    rotations = [tuple(body[index:] + body[:index]) for index in range(len(body))]
    canonical = min(rotations)
    return canonical + (canonical[0],)


def dependency_cycles(edges: Iterable[TargetEdge]) -> list[tuple[str, ...]]:
    """Return deterministic, closed target dependency cycles."""
    adjacency: dict[str, set[str]] = {}
    for source, destination in edges:
        adjacency.setdefault(source, set()).add(destination)
        adjacency.setdefault(destination, set())

    found: set[tuple[str, ...]] = set()

    def visit(start: str, node: str, path: list[str], seen: set[str]) -> None:
        for destination in sorted(adjacency.get(node, set())):
            if destination == start:
                found.add(_canonical_cycle(path + [start]))
            elif destination not in seen and destination >= start:
                visit(start, destination, path + [destination], seen | {destination})

    for start in sorted(adjacency):
        visit(start, start, [start], {start})
    return sorted(found)


def audit(
    objects: PBXObjects,
    expected_package_path: str | None = None,
    required_targets: Iterable[str] = (),
    required_edges: Iterable[TargetEdge] = (),
) -> list[str]:
    """Return an ordered list of structural build-graph findings."""
    findings: list[str] = []
    paths = package_paths(objects)
    targets = native_targets(objects)
    edges = target_edges(objects)

    if "." in paths:
        findings.append("repo-root local package reference: .")
    if expected_package_path is not None and expected_package_path not in paths:
        findings.append(f"missing expected package path: {expected_package_path}")
    findings.extend(_invalid_package_product_findings(objects))
    findings.extend(
        f"missing required target: {name}"
        for name in sorted(set(required_targets))
        if name not in targets
    )
    findings.extend(
        f"missing required target edge: {source} -> {destination}"
        for source, destination in sorted(set(required_edges))
        if (source, destination) not in edges
    )
    findings.extend(
        f"target dependency cycle: {' -> '.join(cycle)}"
        for cycle in dependency_cycles(edges)
    )
    return findings


def _required_edge(value: str) -> TargetEdge:
    parts = value.split(":")
    if len(parts) != 2 or not all(parts):
        raise argparse.ArgumentTypeError("edge must use FROM:TO")
    return parts[0], parts[1]


def _load_objects(project: Path) -> PBXObjects:
    project_file = project / "project.pbxproj" if project.is_dir() else project
    completed = subprocess.run(
        ["plutil", "-convert", "json", "-o", "-", str(project_file)],
        check=True,
        capture_output=True,
        text=True,
    )
    document = json.loads(completed.stdout)
    objects = document.get("objects")
    if not isinstance(objects, dict):
        raise ValueError("converted project does not contain a PBX objects dictionary")
    return objects


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--project", required=True, type=Path)
    parser.add_argument("--expected-package-path")
    parser.add_argument("--require-target", action="append", default=[])
    parser.add_argument(
        "--require-edge", action="append", default=[], type=_required_edge
    )
    parser.add_argument("--json", action="store_true", dest="as_json")
    return parser


def main(argv: list[str] | None = None) -> int:
    args = _parser().parse_args(argv)
    try:
        objects = _load_objects(args.project)
    except (OSError, subprocess.CalledProcessError, json.JSONDecodeError, ValueError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 2

    targets = native_targets(objects)
    edges = target_edges(objects)
    paths = package_paths(objects)
    cycles = dependency_cycles(edges)
    findings = audit(
        objects,
        expected_package_path=args.expected_package_path,
        required_targets=args.require_target,
        required_edges=args.require_edge,
    )
    graph = BuildGraph(
        package_paths=tuple(sorted(paths)),
        nodes=tuple(sorted(targets)),
        target_edges=tuple(sorted(edges)),
        package_product_edges=tuple(sorted(package_product_edges(objects))),
        cycles=tuple(cycles),
        findings=tuple(findings),
    )
    result = {
        "packagePaths": list(graph.package_paths),
        "nodes": list(graph.nodes),
        "edges": [list(edge) for edge in graph.target_edges],
        "packageProductEdges": [list(edge) for edge in graph.package_product_edges],
        "cycles": [list(cycle) for cycle in graph.cycles],
        "findings": list(graph.findings),
    }

    if args.as_json:
        print(json.dumps(result, indent=2, sort_keys=True))
    else:
        print("Package paths:")
        for path in result["packagePaths"]:
            print(f"  {path}")
        print("Target nodes:")
        for node in result["nodes"]:
            print(f"  {node}")
        print("Target edges:")
        for source, destination in result["edges"]:
            print(f"  {source} -> {destination}")
        print("Package product edges:")
        for target, product in result["packageProductEdges"]:
            print(f"  {target} -> {product}")
        print("Dependency cycles:")
        for cycle in result["cycles"]:
            print(f"  {' -> '.join(cycle)}")
        print("Findings:")
        if findings:
            for finding in findings:
                print(f"  {finding}")
        else:
            print("  none")
    return 1 if findings else 0


if __name__ == "__main__":
    raise SystemExit(main())
