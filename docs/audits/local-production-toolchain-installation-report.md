# Local Production Toolchain Installation Report

Date: 2026-05-08
Result: Installed local proof/tooling layer with external prerequisite Yellows
Type: Codex OS / MCP / local production tooling

## Active Batch Before / After

Before:

- Current batch: `PK02 Architecture Boundary Scanner / Accepted Yellow`
- Next eligible batch: `PK03 AppUnitOfWork Foundation`

After:

- Current batch preserved: `PK02 Architecture Boundary Scanner / Accepted Yellow`
- Next eligible batch preserved: `PK03 AppUnitOfWork Foundation`

No active-batch state file was overwritten.

## Files Created

Created MCP/tooling:

- `tools/mcp/ambitions_proof_mcp/`
- `tools/mcp/ambitions_visual_mcp/`
- `tools/mcp/ambitions_accessibility_mcp/`
- `tools/mcp/ambitions_fixture_mcp/`
- `tools/mcp/ambitions_source_atlas_mcp/`
- `tools/mcp/ambitions_release_truth_mcp/`
- `.xcodebuildmcp/config.yaml`

Created proof folders:

- `output/visual-proof/.gitkeep`
- `output/visual-proof/baselines/.gitkeep`
- `output/visual-proof/latest/.gitkeep`
- `output/visual-proof/diffs/.gitkeep`
- `output/visual-proof/reports/.gitkeep`

Created fixture stubs:

- `fixtures/ambitions-twins/busy-new-job.json`
- `fixtures/ambitions-twins/creative-builder.json`
- `fixtures/ambitions-twins/overloaded-mover.json`
- `fixtures/ambitions-twins/manual-privacy-user.json`
- `fixtures/ambitions-twins/long-term-drifter.json`
- `fixtures/ambitions-twins/source-heavy-career-switcher.json`
- `fixtures/ambitions-twins/travel-week-user.json`

Created docs/audits/policies:

- `docs/codex/MCP02_CONTROLLED_PROOF_MCP.md`
- `docs/codex/MCP03_VISUAL_PROOF_MCP_PLAN.md`
- `docs/codex/MCP04_ACCESSIBILITY_SHADOW_MCP_PLAN.md`
- `docs/codex/MCP05_AMBITIONS_TWIN_FIXTURE_MCP_PLAN.md`
- `docs/codex/MCP06_SOURCE_ATLAS_PACK_MCP_PLAN.md`
- `docs/codex/MCP07_RELEASE_TRUTH_MCP_PLAN.md`
- `docs/codex/MCP_EXTERNAL_SERVER_SETUP.md`
- `docs/codex/GITHUB_NATIVE_TOOLING_POLICY.md`
- `docs/codex/workflow-templates/*.yml.example`
- `docs/codex/batches/MCP02_Controlled_Proof_MCP_Prompt.md`
- `docs/codex/batches/MCP03_Visual_Proof_MCP_Prompt.md`
- `docs/codex/batches/MCP04_Accessibility_Shadow_MCP_Prompt.md`
- `docs/codex/batches/MCP05_Ambitions_Twin_Fixture_MCP_Prompt.md`
- `docs/codex/batches/MCP06_Source_Atlas_Pack_MCP_Prompt.md`
- `docs/codex/batches/MCP07_Release_Truth_MCP_Prompt.md`
- `docs/codex/batches/GH01_GitHub_Native_Tooling_Policy_Prompt.md`
- `docs/audits/mcp01-local-validation-report.md`
- `docs/audits/mcp-codex-local-registration-report.md`
- `docs/audits/mcp-external-server-setup-report.md`
- `docs/audits/mcp02-controlled-proof-mcp-report.md`
- `docs/audits/mcp03-visual-proof-mcp-scaffold-report.md`
- `docs/audits/mcp04-accessibility-shadow-mcp-scaffold-report.md`
- `docs/audits/mcp05-ambitions-twin-fixture-mcp-scaffold-report.md`
- `docs/audits/mcp06-source-atlas-pack-mcp-scaffold-report.md`
- `docs/audits/mcp07-release-truth-mcp-scaffold-report.md`
- `docs/audits/gh01-github-native-tooling-policy-report.md`

## Files Updated

- `AGENTS.md`
- `docs/README.md`
- `docs/codex/README.md`
- `docs/codex/MCP_CODEX_SETUP.md`
- `docs/codex/MCP_LOCAL_PRODUCTION_OS_PLAN.md`

## Commands Run

```bash
git status --short
git pull --ff-only
python3 tools/mcp/ambitions_repo_mcp/server.py --self-test
python3 -m pytest tools/mcp/ambitions_repo_mcp/tests
codex mcp list
codex mcp add ambitionsRepo -- python3 /Users/devan/Documents/GitHub/ambitions/tools/mcp/ambitions_repo_mcp/server.py
codex mcp add openaiDeveloperDocs --url https://developers.openai.com/mcp
which xcodebuildmcp || true
xcodebuildmcp --version || true
which docker || true
docker --version || true
python3 tools/mcp/ambitions_proof_mcp/server.py --self-test
python3 -m pytest tools/mcp/ambitions_proof_mcp/tests
python3 -m py_compile tools/mcp/ambitions_repo_mcp/server.py tools/mcp/ambitions_proof_mcp/server.py
python3 -m json.tool fixtures/ambitions-twins/*.json
```

Manual JSON-RPC smoke tests were run for MCP01 and MCP02.

## Commands Not Run And Why

- `./scripts/build-local.sh`: not run because no app-source batch required a build.
- `xcodegen generate`: not run because project generation inputs were not changed.
- simulator capture/build/run: not run because MCP03 is scaffold only and baseline XcodeBuildMCP simulator workflow was not expanded.
- GitHub MCP Docker run: not run because Docker was unavailable and no token was created.
- hosted CI workflows: not added or run because hosted CI requires explicit cost/security approval.

## MCP Servers Installed

- `ambitionsRepo`: registered in Codex and verified by `codex mcp list`.
- `openaiDeveloperDocs`: registered in Codex and verified by `codex mcp list`.
- `ambitions_proof_mcp`: repo-local server created and self-tested, not auto-registered in Codex.

## MCP Servers Scaffolded Only

- `ambitions_visual_mcp`
- `ambitions_accessibility_mcp`
- `ambitions_fixture_mcp`
- `ambitions_source_atlas_mcp`
- `ambitions_release_truth_mcp`

## Codex Config Changes

Codex global MCP config was changed through `codex mcp add` for `ambitionsRepo` and `openaiDeveloperDocs`.

No GitHub token, secret, or write-capable MCP was added.

## GitHub Human Actions Required

- Enable Dependabot alerts in GitHub settings if desired.
- Create a fine-grained read-only GitHub token only if GitHub MCP is approved for local read-only use.
- Install Docker or choose an approved official GitHub MCP launch path before GitHub MCP setup.
- Approve any hosted CI, CodeQL, Dependabot config, or self-hosted runner policy before enabling it.

## Security Boundaries

- No hosted AI.
- No telemetry or analytics.
- No user-data servers.
- No generic shell MCP.
- No write-capable MCP tools.
- No network/source scraping MCP.
- No secrets access.
- No signing, App Store upload, TestFlight, or release automation.
- No hosted CI workflow files.

## EFC Applicability

EFC applicability: invoked for tooling/governance proof.

Product proof, accessibility proof, release proof, device proof, legal/privacy proof, and production app behavior are non-claims for this run.

## Rollback Path

Revert the files listed above and remove Codex MCP entries if needed:

```bash
codex mcp remove ambitionsRepo
codex mcp remove openaiDeveloperDocs
```

No app data, app source, schema, project generation, signing, entitlement, hosted workflow, or runtime rollback is required.

## Next Recommended Action

Run:

```bash
codex mcp list
```

Then start the next tooling batch by registering `ambitionsProof` only after reviewing the MCP02 server surface.
