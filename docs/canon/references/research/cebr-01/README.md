# CEBR-01 research reference

Status: request-only research design reference. These files are not normative
authority, do not authorize implementation, and do not claim patentability or
release readiness. The normative interpretation is limited to the CEBR-01
canon specifications and the active `docs/canon/` registry.

## Contents

- `CEBR-01_Codex_Design_Technical_Manual.md` — inert design and technical
  manual supplied for canon analysis.
- `CEBR-01_Invention_Disclosure_Package.docx` — confidential research draft
  supplied for inventor/counsel context; it is not legal advice.
- `CEBR-01_Machine_Contract.yaml` — inert machine-readable design contract.

The supplied ZIP is transport-only and is intentionally not copied into the
repository. It contains byte-identical copies of the three files above and no
additional source:

| Source | SHA-256 | Bytes |
| --- | --- | ---: |
| `CEBR-01_Codex_Design_Technical_Manual.md` | `699065ff99d4191b5be0d82f2383b87f99359d3265e1197fe95f47b5fd65eae2` | 42533 |
| `CEBR-01_Invention_Disclosure_Package.docx` | `80a8f723394951790abaebcb274c945f04052ca16b1327a7b2189e61a264786a` | 64006 |
| `CEBR-01_Machine_Contract.yaml` | `3cf7e94350ee3c62b29fca9d940587165c62e6e2115347463f825543269ba35e` | 14808 |
| transport ZIP (not imported) | `847b3f5a160a9f5eb161594fa34ddc3d1cdf88f7aaa5aad7600b731c61fc6728` | 80604 |

## Provenance and boundaries

- Supplied repository revision: `7dbf554876c686e62525a85d762fec04b67a4af4`.
- Integration base: `1ee4188a63ad2b3b6914857d97cd07625d10a32a`.
- Active canon content SHA at integration planning: `a1c987a4e753f42a852e0558b5e201cd1168e4b08e5deb9286b341dfbaaaea13`.
- Source frontmatter and the machine contract declare `normative: false`,
  `authority: none`, and `implementation_authorized: false`.
- Candidate source paths named by the package are hints, not source ownership.
  Any future implementation requires a separate scoped task and current
  source-owner review.
- The package contains public research references and confidential invention
  disclosure material. It is stored as inert bytes; no embedded code, macro,
  executable, private key, or external-effect hook is imported or run.

## Canon design-intent ceiling

The companion specifications bind only the design intent needed to preserve
one canonical local graph, revision-bound branch deltas, operational
certificates, bounded re-certification, user-controlled candidate selection,
and one causal promotion transaction. They do not establish implementation,
runtime, visual, accessibility, performance, device, legal, patentability,
external-system, merge, or release proof.
