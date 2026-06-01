Status: ACTIVE
Owner: Governance OS
Authority Tier: active
Supersedes: none
Superseded By: none
Proof Expectation: docs-only
Cleanup Destination: none
Expected Lifetime: permanent

# Active Authority Map

Authority precedence for current Ambitions repo work:

1. `docs/truth/README.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. `docs/truth/PRODUCT_MOAT_TRUTH.md`
4. `docs/truth/IMPLEMENTATION_TRUTH.md`
5. `docs/truth/RELEASE_TRUTH.md`
6. `docs/truth/CODEX_PROCESS_TRUTH.md`
7. `docs/truth/HISTORICAL_POLICY.md`
8. `AGENTS.md`
9. live source, tests, scripts, `project.yml`, and `Package.swift`
10. `docs/codex/AFRI_ACTIVE_AUTHORITY_MANIFEST.json`
11. `docs/governance/*`
12. `.codex/os/*`
13. generated outputs under `docs/governance/generated/` and `build/codex-os/`

Current flagship names and seams:

- Active top-level IA: Today / Goals / Capture / Time / You
- Compatibility seam: Plan
- Personal System Center: You
- Trust requirements: privacy, receipts, correction, export/import, local-first behavior

Operational rule:

- If generated outputs disagree with truth or source, regenerate or repair the generator.
- Use `python3 scripts/ambitions-afri-authority-manifest-validate.py` for the AFRI authority/automation manifest gate.
- Use `python3 scripts/ambitions-afri-stale-doc-detector.py` for the focused stale-doc detector gate.
