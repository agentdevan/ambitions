# Ambitions Constitution Annexes

Status: Wave 0 draft in PR #23  
Parent authority: `docs/truth/PRODUCT_DESIGN_TRUTH.md`

This directory turns the Ambitions Product Constitution into an enforceable engineering system.

## Files

- `ENGINEERING_CONSTITUTION.md` — Articles 25–43: persistence, concurrency, determinism, intelligence quality, frontend, design system, performance, reliability, security, CloudKit, testing, release, localization, supply chain, entitlements, lifecycle, Codex departments, enforcement, evolution.
- `opportunity-register.json` — mandatory launch baseline: 18 P0 + 100 P1 opportunities.
- `laws.json` — stable law registry.
- `law-source-map.json` — law-to-owner routing.
- `law-test-map.json` — law-to-test/proof obligations.
- `scenarios.json` — initial constitutional scenario corpus.
- `performance-budgets.json` — required budget registry; numeric values remain blocked pending device/data calibration.
- `data-classification.json` — initial data-classification and allowed-location policy.
- `dependency-graph.json` — machine-readable blocking graph.
- `LINEAR_COVERAGE_MAP.md` — initial Project mapping and proposed new Projects.
- `WAVE_0_READBACK.md` — claim-bounded closeout/readback.

## Authority

The parent Constitution remains supreme for product/design law. This annex may add engineering specificity but may not weaken it.

Live source and `IMPLEMENTATION_TRUTH.md` own current implementation status. `RELEASE_TRUTH.md` owns release claims.

## Launch gate

```text
18 / 18 P0 = First-Class Green
100 / 100 P1 = First-Class Green
Accepted Yellow at final launch = forbidden
```

## Audit

```bash
python3 scripts/ambitions-constitution-audit.py
```

Wave 0 validates registry integrity only. It does not claim the opportunities are implemented.
