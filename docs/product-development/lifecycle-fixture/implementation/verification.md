# Verification

Run this exact automated structural check from the repository root:

```bash
python3 .agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py check docs/product-development/lifecycle-fixture --json
```

- Automated evidence: the command must exit 0 with `status` equal to `success`.
- Build evidence: N/A; this fixture changes no build input.
- Runtime evidence: N/A; this fixture changes no runtime behavior.
- Accessibility evidence: N/A; this fixture changes no rendered interface.
- Privacy evidence: confirm the fixture remains synthetic and contains no
  private user data.
- Migration evidence: N/A; this fixture changes no persistence schema.
- Performance evidence: N/A; this fixture executes no product workload.
- Device evidence: N/A; this fixture changes no device behavior.

A passing result proves only document structure, approval ordering,
traceability, and grooming-file presence. It is not runtime, accessibility,
device, release, or production proof.
