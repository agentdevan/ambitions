"""Command line entry point for Source Atlas Foundry."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

from . import __version__
from .adapters import ADAPTER_VERSION, harvest_sources
from .compiler import compile_bundle
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, read_json, write_json
from .publisher import build_r2_plan, execute_r2_plan, write_r2_plan
from .registry import PATHWAY_SEEDS, SOURCE_REGISTRY
from .validator import validate_bundle

try:
    from dotenv import load_dotenv
except ModuleNotFoundError:
    def load_dotenv(*_args: object, **_kwargs: object) -> bool:
        return False


def print_json(value: Any) -> None:
    print(json.dumps(value, indent=2, sort_keys=True, ensure_ascii=False))


def load_foundry_env() -> list[str]:
    source_atlas_root = Path(__file__).resolve().parents[1]
    repo_root = source_atlas_root.parents[1]
    candidates = [
        repo_root / ".env",
        source_atlas_root / ".env",
        Path(__file__).resolve().parent / ".env",
    ]
    loaded: list[str] = []
    for candidate in candidates:
        if candidate.exists() and load_dotenv(candidate, override=False):
            loaded.append(str(candidate))
    return loaded


def doctor() -> dict[str, Any]:
    return {
        "tool": "source-atlas-foundry",
        "version": __version__,
        "sourceCount": len(SOURCE_REGISTRY),
        "pathwaySeedCount": len(PATHWAY_SEEDS),
        "adapterVersion": ADAPTER_VERSION,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": NON_CLAIMS,
        "r2Posture": {
            "default": "staging plan only",
            "directUpload": "requires --execute and --confirm-public-reference-only",
            "credentialHandling": "no credentials are read, stored, or printed by the foundry",
        },
        "envFiles": load_foundry_env(),
        "sourceLanes": sorted({source["adapter"] for source in SOURCE_REGISTRY}),
        "highImpactExamples": [pathway["id"] for pathway in PATHWAY_SEEDS],
    }


def main(argv: list[str] | None = None) -> int:
    load_foundry_env()
    parser = argparse.ArgumentParser(description="Source Atlas Foundry")
    sub = parser.add_subparsers(dest="command", required=True)

    sub.add_parser("doctor")
    sub.add_parser("catalog")

    harvest_parser = sub.add_parser("harvest")
    harvest_parser.add_argument("--output-root", required=True)
    harvest_parser.add_argument("--run-id", required=True)
    harvest_parser.add_argument("--source", action="append", dest="sources")
    harvest_parser.add_argument("--limit", type=int, default=25)

    compile_parser = sub.add_parser("compile")
    compile_parser.add_argument("--output-root", required=True)
    compile_parser.add_argument("--version-id", required=True)
    compile_parser.add_argument("--channel", default="staging")
    compile_parser.add_argument("--harvest-root")

    validate_parser = sub.add_parser("validate")
    validate_parser.add_argument("--bundle-root", required=True)

    plan_parser = sub.add_parser("r2-plan")
    plan_parser.add_argument("--bundle-root", required=True)
    plan_parser.add_argument("--bucket", required=True)
    plan_parser.add_argument("--prefix", default="source-atlas/v1")
    plan_parser.add_argument("--channel", default="staging")
    plan_parser.add_argument("--output")

    upload_parser = sub.add_parser("upload-r2")
    upload_parser.add_argument("--plan", required=True)
    upload_parser.add_argument("--execute", action="store_true")
    upload_parser.add_argument("--confirm-public-reference-only", action="store_true")

    explain_parser = sub.add_parser("explain")
    explain_parser.add_argument("--focus", choices=["architecture", "automation", "runtime-boundary"], default="architecture")

    args = parser.parse_args(argv)
    if args.command == "doctor":
        print_json(doctor())
        return 0
    if args.command == "catalog":
        print_json({"sources": SOURCE_REGISTRY, "pathwaySeeds": PATHWAY_SEEDS, "privacyBoundary": PRIVACY_BOUNDARY})
        return 0
    if args.command == "harvest":
        result = harvest_sources(Path(args.output_root), args.run_id, source_ids=args.sources, limit=args.limit)
        print_json(result)
        return 0 if result["privacyScan"]["passed"] else 1
    if args.command == "compile":
        result = compile_bundle(
            Path(args.output_root),
            args.version_id,
            args.channel,
            harvest_root=Path(args.harvest_root) if args.harvest_root else None,
        )
        print_json(result)
        return 0
    if args.command == "validate":
        result = validate_bundle(Path(args.bundle_root))
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "r2-plan":
        bundle_root = Path(args.bundle_root)
        if args.output:
            result = write_r2_plan(bundle_root, args.bucket, args.prefix, args.channel, Path(args.output))
            result["planPath"] = args.output
        else:
            result = build_r2_plan(bundle_root, args.bucket, args.prefix, args.channel)
        print_json(result)
        return 0 if result["validForUpload"] else 1
    if args.command == "upload-r2":
        plan = read_json(Path(args.plan))
        result = execute_r2_plan(plan, execute=args.execute, confirm_public_reference_only=args.confirm_public_reference_only)
        print_json(result)
        return 0 if result.get("success") else 1
    if args.command == "explain":
        print_json(explain(args.focus))
        return 0
    return 1


def explain(focus: str) -> dict[str, Any]:
    if focus == "automation":
        return {
            "focus": focus,
            "lanes": [
                "official source adapters fetch or snapshot public/reference sources",
                "normalizers emit SourceRecord, ClaimRecord, RequirementRecord, PathwayRecord, and SkillAtom data",
                "validators reject private context, unsupported claim states, missing provenance, and unsafe runtime roles",
                "compiler writes immutable versioned bundles",
                "R2 staging plan uploads candidate bundles only after validation",
                "promotion should be handled by a Cloudflare Worker gate before stable channel exposure",
            ],
        }
    if focus == "runtime-boundary":
        return {
            "focus": focus,
            "law": "Source Atlas knows public/reference structure; Private Life Runtime knows the user; the join happens locally.",
            "forbidden": [
                "private user context in source requests",
                "private life graph in R2",
                "R2 as personal-data backend",
                "packs as user-visible marketplace center",
            ],
        }
    return {
        "focus": focus,
        "layers": [
            "source registry",
            "adapter snapshots",
            "claim graph",
            "requirement graph",
            "pathway lattice",
            "skill transfer graph",
            "freshness broker",
            "bundle compiler",
            "R2 staging plan",
            "promotion receipt",
            "local runtime verifier/cache",
        ],
    }


if __name__ == "__main__":
    raise SystemExit(main())
