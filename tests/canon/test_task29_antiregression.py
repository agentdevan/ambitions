from __future__ import annotations

import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]

# Live consumers must route through active canon. Historical evidence and test
# fixtures retain exact old paths only as non-active provenance.
LIVE_CONSUMERS = (
    ".github/CODEOWNERS",
    ".github/workflows/ambitions-constitution-audit.yml",
    "AGENTS.md",
    "DesignTokens/README.md",
    "Native/Ambitions/Core/LocalRuntimeOS/Repair/ExportImportResetDataScopeMatrix.swift",
    "Packages/AmbitionsDesignSystem/Sources/Accessibility/AccessibilityAutomatedNutritionGate.swift",
    "README.md",
    "docs/canon/generated/CODEX_START_HERE.md",
    "docs/design/provenance/generated/source-path-inventory.generated.json",
    "docs/design/provenance/vsp-provenance.json",
    "docs/dev/toolkit-snapshots/toolkit-snapshot-20260623-0844.md",
    "docs/implementation/global_shell_full_bleed_manifest.yml",
    "docs/project-source/CHATGPT_AMBITIONS_PROJECT_SOURCE.md",
    "docs/qa/product-experience-scenario-gates.yaml",
    "docs/linear/current-state/2026-07-01-linear-coverage-map.json",
    "docs/linear/current-state/2026-07-01-repo-current-state-taxonomy.json",
    "docs/linear/current-state/2026-07-01-repo-current-state-taxonomy.md",
    "docs/skills/README.md",
    "docs/skills/figma-production-gate/SKILL.md",
    "docs/skills/ui-north-star-production-gate/SKILL.md",
    "scripts/ambitions-accepted-yellow-misuse-audit.py",
    "scripts/ambitions-architecture-inventory.py",
    "scripts/ambitions-constitution-audit.py",
    "scripts/ambitions-component-inventory-generate.py",
    "scripts/ambitions-device-proof-required.py",
    "scripts/ambitions-flagship-ios-standards-check.py",
    "scripts/ambitions-linear-green-claim-audit.py",
    "scripts/ambitions-local-first-boundary-scan.py",
    "scripts/ambitions-local-runtime-proof.py",
    "scripts/ambitions-quality-gate.py",
    "scripts/ambitions-skill-registry-check.py",
    "scripts/ambitions-truth-path-vocabulary-audit.py",
    "scripts/ambitions-visual-proof-gate.py",
    "scripts/ambitions-vocabulary-drift-scan.py",
    "scripts/ci/ambitions-pr-scope.py",
    "scripts/release-claim-safety-scan.sh",
    "scripts/tests/test_ambitions_authority_freeze_check.py",
    "scripts/tests/test_ambitions_pr_scope.py",
    "scripts/tests/test_ambitions_pr_xcode_scope.py",
    "tools/ambitions_canon/benchmark.py",
    "tools/ambitions_canon/render.py",
    "tools/mcp/ambitions_native_mcp/Sources/AmbitionsNativeMCPCore/AmbitionsNativeMCPCore.swift",
    "tools/openai/repo_brain/README.md",
    "tests/canon/test_search_consolidated_docket.py",
)


class Task29LegacyAuthorityAntiRegressionTests(unittest.TestCase):
    def test_live_consumers_do_not_route_to_purged_legacy_authority(self) -> None:
        offenders = []
        for path in LIVE_CONSUMERS:
            text = (ROOT / path).read_text(encoding="utf-8")
            if (
                "docs/truth/" in text
                or "docs/constitution/" in text
                or '/ "truth"' in text
                or '/ "constitution"' in text
            ):
                offenders.append(path)
        self.assertEqual(offenders, [])


if __name__ == "__main__":
    unittest.main()
