# Local Repo Intelligence Policy

Status: Active local developer tooling policy.
Scope: Codex workflow acceleration only; not Ambitions app runtime.
Primary iOS 26 front door: `scripts/ios26-flagship-run-sequential.sh`.
Canonical child runner: `scripts/ambitions-codex-train.sh`.

This policy governs optional local advisory repo-intelligence tools for Ambitions Codex work. It does not authorize app runtime dependencies, hosted services, cloud AI, telemetry, secrets, paid services, release automation, or global machine configuration changes.

## Tool Roles

- CodeGraph: source graph, impact radius, symbol relationships, callers/callees, trace context, affected-test hints, and file structure.
- Semble: semantic plus lexical retrieval for code, docs, config snippets, and related-snippet discovery.
- Understand Anything: optional sandbox-only human dashboard, onboarding view, and architecture map.

These tools are developer tooling only. They are not Ambitions app features, runtime dependencies, source truth, release proof, accessibility proof, privacy proof, performance proof, or batch completion authority.

## Authority Hierarchy

1. `docs/truth/*`
2. `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
3. Frozen iOS 26 prompt hashes and prompt boundaries where active
4. `scripts/ios26-flagship-run-sequential.sh` as the primary sequence front door
5. `scripts/ambitions-codex-train.sh` as canonical child batch runner
6. Existing Ambitions Repo MCP and Proof MCP policies
7. Validation scripts, tests, proof artifacts, and audit reports
8. CodeGraph, Semble, and Understand Anything outputs as advisory inputs only

Never invert this hierarchy. Tool-derived findings must resolve to concrete repo paths and then be verified through direct file inspection, validation output, tests, or existing Ambitions proof artifacts before they can support a Green workflow claim.

## Local-Only Rules

- Do not run remote installers automatically.
- Do not run `curl | sh`, `curl | bash`, `irm | iex`, or equivalent remote execution.
- Do not mutate `~/.codex/config.toml`, `~/.claude`, Cursor settings, VS Code settings, shell profiles, global AGENTS files, or machine-global config.
- Do not add app runtime dependencies, Xcode project dependencies, Swift package dependencies, hosted CI, analytics, tracking, API keys, secrets, cloud services, paid services, or remote app behavior.
- Do not use Understand Anything inside default iOS 26 gates.

## Artifact Policy

Ignored local sidecars:

- `.codegraph/`
- `.understand-anything/`
- `.codex/local-indexes/`
- `.codex/repo-intelligence/tools/`
- `.codex/repo-intelligence/generated/`
- `.codex/repo-intelligence/tmp/`

Do not commit generated graph JSON, dashboards, tool DBs, caches, or local indexes. Committed docs, audit summaries, schemas, and scripts are allowed only when human-readable, source-reviewed, and not treated as proof.

## Green Yellow Red

Green:

- Policy, scripts, runner hooks, schema, and Make targets are installed and validated.
- iOS 26 sequential runner order and stop behavior are preserved.
- No generated sidecar artifacts are staged or tracked.

Yellow:

- CodeGraph, Semble, or Understand Anything is unavailable.
- Optional local indexes are missing.
- Workflow safely falls back to direct file reads, `rg`, validation scripts, and tests.

Red:

- Runner shape is broken.
- App runtime dependencies changed for these tools.
- Generated sidecar artifacts are staged or tracked.
- Advisory output is treated as proof or source truth.
- Understand Anything is used as a gate or proof source.
- Required policy, schema, or validator files are missing.

## Non-Claims

This policy does not claim release readiness, TestFlight readiness, App Store readiness, accessibility verification, privacy/legal approval, performance improvement, app behavior implementation, cloud/hosted service approval, or Ambitions-specific speed/cost gains without Ambitions-specific measurements.
