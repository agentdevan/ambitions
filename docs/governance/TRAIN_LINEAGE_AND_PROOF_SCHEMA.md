# Ambitions Train Lineage And Proof Schema

Status: ACTIVE

---

# Purpose

Defines the exact schema required for final implementation-level reconciliation.

This schema exists so future reconciliation tooling can deterministically map:
- train → commits
- train → implementation files
- train → audits
- train → tests
- train → reports
- train → supersession lineage
- train → operational state

---

# Required Train Manifest Schema

Each train must eventually resolve into structured metadata.

Example structure:

```json
{
  "train_id": "PK28",
  "state": "QUEUED",
  "owner_domains": [
    "PlatformKernel",
    "Persistence"
  ],
  "prompt_files": [],
  "implementation_files": [],
  "commits": [],
  "audits": [],
  "reports": [],
  "tests": [],
  "supersedes": [],
  "superseded_by": [],
  "blocked_by": [],
  "next_trains": [],
  "release_claim_boundary": {
    "release_ready": false,
    "app_store_ready": false,
    "accessibility_certified": false
  }
}
```

---

# Required Global Outputs

Future generated outputs:

- execution_graph.json
- train_dependency_graph.json
- train_lineage_graph.json
- train_commit_graph.json
- proof_linkage_graph.json
- supersession_graph.json
- registry_projection.json

---

# Required Reconciliation Tooling

Future tooling responsibilities:

- traverse prompts
- traverse audits
- traverse reports
- traverse implementation paths
- traverse commits
- detect stale overlays
- detect orphan prompts
- detect duplicate operational states
- generate normalized registry projections

---

# Governance Rule

No train may remain operationally authoritative unless:
- lineage is known
- ownership is known
- supersession posture is known
- proof linkage is known
