"""Production-grade deterministic public-reference adapters for Source Atlas."""

from __future__ import annotations

from pathlib import Path
from typing import Any

from .adapter_sdk import (
    AUTHORITY_TIERS,
    CONFIDENCE_STATES,
    SOURCE_STATES,
    AdapterRunContext,
    SourceAdapter,
    output_checksum,
    write_fixture,
)
from .model import PRIVACY_BOUNDARY, stable_id, utc_now
from .schemas import SCHEMA_KINDS
from .terms_registry import policy_gate_for_output, terms_entry


ADAPTER_IDS = {
    "onet.database": "onet_public_reference_adapter",
    "bls.public.data.api": "bls_public_labor_adapter",
    "wikidata.crosswalk": "wikidata_crosswalk_adapter",
    "openalex.dataset": "openalex_research_context_adapter",
    "usajobs.search": "restricted_source_policy_adapter",
}


OCCUPATION_FIXTURES = [
    {"canonical": "occupation.software_engineer", "onet": "15-1252.00", "bls": "15-1252", "label": "Software Developers", "wikidata": "Q80993", "openalex": "T10860", "confidence": "high", "domain": "software"},
    {"canonical": "occupation.registered_nurse", "onet": "29-1141.00", "bls": "29-1141", "label": "Registered Nurses", "wikidata": "Q186360", "openalex": "T11191", "confidence": "high", "domain": "healthcare"},
    {"canonical": "occupation.airline_pilot", "onet": "53-2011.00", "bls": "53-2011", "label": "Airline Pilots, Copilots, and Flight Engineers", "wikidata": "Q2095549", "openalex": "T12372", "confidence": "medium", "domain": "aviation"},
    {"canonical": "occupation.teacher", "onet": "25-2031.00", "bls": "25-2031", "label": "Secondary School Teachers", "wikidata": "Q37226", "openalex": "T10236", "confidence": "medium", "domain": "education"},
    {"canonical": "occupation.electrician", "onet": "47-2111.00", "bls": "47-2111", "label": "Electricians", "wikidata": "Q175310", "openalex": None, "confidence": "high", "domain": "trades"},
    {"canonical": "occupation.lawyer", "onet": "23-1011.00", "bls": "23-1011", "label": "Lawyers", "wikidata": "Q40348", "openalex": "T10084", "confidence": "medium", "domain": "law"},
    {"canonical": "occupation.audio_engineer", "onet": "27-4014.00", "bls": "27-4014", "label": "Sound Engineering Technicians", "wikidata": "Q946996", "openalex": "T11419", "confidence": "medium", "domain": "music"},
    {"canonical": "occupation.small_business_owner", "onet": "11-1021.00", "bls": "11-1021", "label": "General and Operations Managers", "wikidata": "Q131512", "openalex": "T10033", "confidence": "low", "domain": "business"},
    {"canonical": "occupation.music_artist", "onet": "27-2042.00", "bls": "27-2042", "label": "Musicians and Singers", "wikidata": "Q639669", "openalex": "T11176", "confidence": "medium", "domain": "music"},
    {"canonical": "occupation.astronaut", "onet": "19-2012.00", "bls": None, "label": "Physicists and Astronomers / Astronaut candidate context", "wikidata": "Q11631", "openalex": "T10187", "confidence": "review_required", "domain": "space"},
]

SKILL_FIXTURES = [
    "critical thinking",
    "active learning",
    "complex problem solving",
    "communication",
    "systems analysis",
    "monitoring",
    "coordination",
    "quality control analysis",
    "operation monitoring",
    "instruction",
    "equipment maintenance",
    "judgment and decision making",
]

KNOWLEDGE_FIXTURES = [
    "engineering and technology",
    "mathematics",
    "medicine and dentistry",
    "education and training",
    "law and government",
    "business and management",
    "communications and media",
]

SCENARIOS = [
    "NASA astronaut",
    "nurse",
    "pilot",
    "teacher",
    "software engineer",
    "small business owner",
    "music artist",
    "audio engineer",
    "marathon runner",
    "electrician/apprenticeship",
    "lawyer",
    "medical school path",
    "career pivot",
    "still-counts pivot",
]


class FixturePublicReferenceAdapter(SourceAdapter):
    source_id = ""
    adapter_id = ""
    domain = ""

    def discover(self, context: AdapterRunContext) -> dict[str, Any]:
        entry = terms_entry(self.source_id)
        return {
            "sourceID": self.source_id,
            "sourceURL": entry["source_url"],
            "termsURL": entry["terms_url"],
            "sourceState": context.source_state,
            "fixtureMode": context.fixture_mode,
        }

    def fetch(self, discovered: dict[str, Any], context: AdapterRunContext) -> dict[str, Any]:
        return {
            "sourceID": self.source_id,
            "adapterID": self.adapter_id,
            "fetchedAt": context.resolved_at(),
            "sourceState": context.source_state,
            "raw": self._raw_fixture(context.source_state),
            "discovered": discovered,
        }

    def parse(self, fetched: dict[str, Any], context: AdapterRunContext) -> dict[str, Any]:
        raw = fetched["raw"]
        if context.source_state == "malformed":
            return {"valid": False, "error": "malformed fixture payload", "records": []}
        return {"valid": True, "records": raw.get("records", []), "signals": raw.get("signals", {})}

    def normalize(self, parsed: dict[str, Any], context: AdapterRunContext) -> dict[str, Any]:
        created_at = context.resolved_at()
        entry = terms_entry(self.source_id)
        state = self._source_state(context.source_state)
        normalized = {
            "schemaVersion": 1,
            "kind": "ambitions.sourceAtlas.adapterOutput.v1",
            "sourceID": self.source_id,
            "adapterID": self.adapter_id,
            "domain": self.domain,
            "dataClass": "official_public_source",
            "publicReferenceOnly": True,
            "createdAt": created_at,
            "sourceState": state,
            "terms": _terms_slice(entry),
            "claims": [],
            "requirements": [],
            "atoms": [],
            "edges": [],
            "lattices": [],
            "recipes": [],
            "sourceStates": [state],
            "coverageRecords": [],
            "crosswalks": [],
            "nonClaims": _non_claims(),
        }
        if not parsed.get("valid"):
            normalized["sourceState"]["packEligible"] = False
            normalized["sourceState"]["blockedReasons"].append(parsed.get("error", "parse failed"))
            return normalized
        self._populate_normalized(normalized, parsed["records"], context)
        if context.source_state == "missing-provenance":
            normalized["claims"][0]["provenanceIDs"] = []
        if context.source_state == "private-field-injected":
            normalized["syntheticRejectedArtifact"] = {"dataClass": "non_public_adapter_fixture", "marker": "reject"}
        return normalized

    def validate_terms(self, normalized: dict[str, Any], context: AdapterRunContext) -> dict[str, Any]:
        return policy_gate_for_output(self.source_id, normalized)

    def emit_provenance(self, normalized: dict[str, Any], context: AdapterRunContext) -> list[dict[str, Any]]:
        entry = terms_entry(self.source_id)
        if context.source_state == "missing-provenance":
            return []
        basis = {"sourceID": self.source_id, "adapterID": self.adapter_id, "state": context.source_state, "version": normalized.get("createdAt")}
        return [
            {
                "schemaVersion": 1,
                "kind": SCHEMA_KINDS["provenance"],
                "id": stable_id("provenance", basis),
                "versionID": "adapter-broad-coverage-train-01",
                "sourceID": self.source_id,
                "sourceURL": entry["source_url"],
                "publisher": entry["publisher"],
                "locator": entry["source_url"],
                "retrievedAt": context.resolved_at(),
                "contentHash": output_checksum(normalized.get("claims", []) + normalized.get("atoms", [])),
                "authorityTier": entry["authority_tier"],
                "license": entry["license"],
                "termsURL": entry["terms_url"],
                "freshnessCadence": entry["freshness_cadence"],
                "sourceState": context.source_state,
                "jurisdiction": entry["jurisdiction"],
                "dataClass": "public_provenance",
                "publicReferenceOnly": True,
            }
        ]

    def emit_coverage(self, normalized: dict[str, Any], context: AdapterRunContext) -> dict[str, Any]:
        claims = normalized.get("claims", [])
        requirements = normalized.get("requirements", [])
        atoms = normalized.get("atoms", [])
        crosswalks = normalized.get("crosswalks", [])
        blocked = not normalized.get("sourceState", {}).get("packEligible", False)
        return {
            "schemaVersion": 1,
            "kind": "ambitions.sourceAtlas.coverageRecord.v2",
            "domain": self.domain,
            "sourceLane": self.source_id,
            "adapter": self.adapter_id,
            "scenarioCoverage": scenario_overlay_for_outputs(normalized),
            "sourceAuthority": terms_entry(self.source_id)["authority_tier"],
            "jurisdiction": terms_entry(self.source_id)["jurisdiction"],
            "sourceCount": 1,
            "claimCount": len(claims),
            "requirementCount": len(requirements),
            "atomCount": len(atoms),
            "edgeCount": len(normalized.get("edges", [])),
            "crosswalkCount": len(crosswalks),
            "provenanceCompleteness": bool(normalized.get("provenance")),
            "licenseStatus": normalized["terms"]["termsReviewStatus"],
            "redistributionStatus": normalized["terms"]["redistributionPolicy"],
            "freshnessStatus": context.source_state,
            "sourceStateCoverage": SOURCE_STATES,
            "unsupportedClaims": sum(1 for claim in claims if claim.get("confidence") == "unsupported"),
            "conflictedClaims": sum(1 for claim in claims if claim.get("confidence") == "conflicted"),
            "reviewRequiredClaims": sum(1 for claim in claims if claim.get("reviewRequirement")),
            "staleCriticalClaims": sum(1 for claim in claims if claim.get("sourceState") == "stale-critical"),
            "noFalseCompletionCoverage": True,
            "packReadiness": "blocked" if blocked else "candidate",
            "r2Readiness": "blocked" if blocked else "candidate_local_only",
            "evidenceArtifactPaths": [],
            "dataClass": "public_freshness",
            "publicReferenceOnly": True,
        }

    def emit_fixtures(self, output_root: Path) -> list[dict[str, Any]]:
        written: list[dict[str, Any]] = []
        for state in SOURCE_STATES:
            payload = self.run(AdapterRunContext(source_state=state, fixture_mode=True, created_at="2026-06-27T00:00:00Z"))
            expected_valid = state not in {"private-field-injected"}
            expected_codes = ["unsupported_data_class"] if state == "private-field-injected" else []
            path = output_root / self.source_id / f"{state}.json"
            written.append(write_fixture(path, payload, expected_valid, expected_codes))
        return written

    def emit_pack_candidates(self, normalized: dict[str, Any], context: AdapterRunContext) -> list[dict[str, Any]]:
        gate = policy_gate_for_output(self.source_id, normalized)
        if not gate["packable"] or context.source_state != "current" or not normalized.get("provenance"):
            return []
        return [
            {
                "schemaVersion": 1,
                "kind": "ambitions.sourceAtlas.packCandidate.v1",
                "id": stable_id("pack_candidate", {"sourceID": self.source_id, "adapterID": self.adapter_id}),
                "sourceID": self.source_id,
                "adapterID": self.adapter_id,
                "domain": self.domain,
                "recordCounts": {
                    "claims": len(normalized.get("claims", [])),
                    "requirements": len(normalized.get("requirements", [])),
                    "atoms": len(normalized.get("atoms", [])),
                    "edges": len(normalized.get("edges", [])),
                    "crosswalks": len(normalized.get("crosswalks", [])),
                },
                "termsGate": gate,
                "doesNotStoreFinalUserPath": True,
                "doesNotCreateFinalSchedule": True,
                "dataClass": "public_reference_claim",
                "publicReferenceOnly": True,
            }
        ]

    def _source_state(self, state: str) -> dict[str, Any]:
        blocked_states = {"unavailable", "stale-critical", "conflicted", "revoked", "unsupported", "malformed", "rate-limited", "terms-blocked", "missing-provenance", "private-field-injected"}
        reasons = []
        if state in blocked_states:
            reasons.append(f"source_state_{state}_blocks_pack_output")
        return {
            "state": state,
            "packEligible": state not in blocked_states,
            "runtimeEligible": state == "current",
            "blockedReasons": reasons,
            "dataClass": "public_freshness",
            "publicReferenceOnly": True,
        }

    def _raw_fixture(self, state: str) -> dict[str, Any]:
        if state in {"unavailable", "rate-limited", "terms-blocked", "unsupported", "revoked"}:
            return {"records": [], "signals": {"state": state}}
        return {"records": self._base_records(), "signals": {"state": state}}

    def _base_records(self) -> list[dict[str, Any]]:
        raise NotImplementedError("concrete adapters must provide deterministic fixture records")

    def _populate_normalized(self, normalized: dict[str, Any], records: list[dict[str, Any]], context: AdapterRunContext) -> None:
        raise NotImplementedError


class OnetAdapter(FixturePublicReferenceAdapter):
    source_id = "onet.database"
    adapter_id = ADAPTER_IDS[source_id]
    domain = "occupation"

    def _base_records(self) -> list[dict[str, Any]]:
        return OCCUPATION_FIXTURES

    def _populate_normalized(self, normalized: dict[str, Any], records: list[dict[str, Any]], context: AdapterRunContext) -> None:
        provenance_id = stable_id("provenance", {"sourceID": self.source_id, "adapterID": self.adapter_id, "state": context.source_state})
        for item in records:
            claim = _claim(self.source_id, item["canonical"], f"{item['label']} is represented in O*NET occupation and skill taxonomy fixtures.", "occupation_taxonomy", item["confidence"], context.source_state, [provenance_id])
            normalized["claims"].append(claim)
            normalized["requirements"].append(_requirement(self.source_id, item["canonical"], claim["id"], "public_occupation_context", [provenance_id], context.source_state))
            normalized["atoms"].append(_atom(self.source_id, item["canonical"], item["label"], "occupation", [provenance_id]))
            for skill in SKILL_FIXTURES[:6]:
                skill_atom = _atom(self.source_id, f"{item['canonical']}.{skill}", skill, "skill", [provenance_id])
                normalized["atoms"].append(skill_atom)
                normalized["edges"].append(_edge(self.source_id, item["canonical"], normalized["atoms"][-2]["id"], skill_atom["id"], "uses_skill", [provenance_id]))
        normalized["atoms"].extend(_atom(self.source_id, f"knowledge.{name}", name, "knowledge", [provenance_id]) for name in KNOWLEDGE_FIXTURES)
        normalized["lattices"].append(_lattice(self.source_id, normalized["atoms"], normalized["edges"], []))
        normalized["recipes"].append(_recipe(self.source_id, "Broad occupational foundation recipe", normalized["atoms"][:10], normalized["requirements"], [provenance_id]))


class BlsAdapter(FixturePublicReferenceAdapter):
    source_id = "bls.public.data.api"
    adapter_id = ADAPTER_IDS[source_id]
    domain = "labor_market"

    def _base_records(self) -> list[dict[str, Any]]:
        return [item for item in OCCUPATION_FIXTURES if item.get("bls")]

    def _populate_normalized(self, normalized: dict[str, Any], records: list[dict[str, Any]], context: AdapterRunContext) -> None:
        provenance_id = stable_id("provenance", {"sourceID": self.source_id, "adapterID": self.adapter_id, "state": context.source_state})
        normalized["apiLanes"] = {"v1": "no_key_public_requests", "v2": "registration_key_required_for_higher_limits", "fixtureTestsRequireCredentials": False}
        for item in records:
            claim = _claim(self.source_id, item["canonical"], f"{item['label']} has BLS/SOC labor-market context available for public reference.", "labor_market_context", "high", context.source_state, [provenance_id])
            normalized["claims"].append(claim)
            normalized["requirements"].append(_requirement(self.source_id, item["canonical"], claim["id"], "labor_context_reference", [provenance_id], context.source_state))
            normalized["atoms"].append(_atom(self.source_id, f"bls.{item['bls']}", f"SOC {item['bls']}", "occupation_code", [provenance_id]))


class WikidataAdapter(FixturePublicReferenceAdapter):
    source_id = "wikidata.crosswalk"
    adapter_id = ADAPTER_IDS[source_id]
    domain = "entity_crosswalk"

    def _base_records(self) -> list[dict[str, Any]]:
        return [item for item in OCCUPATION_FIXTURES if item.get("wikidata")]

    def _populate_normalized(self, normalized: dict[str, Any], records: list[dict[str, Any]], context: AdapterRunContext) -> None:
        provenance_id = stable_id("provenance", {"sourceID": self.source_id, "adapterID": self.adapter_id, "state": context.source_state})
        for item in records:
            confidence = "conflicted" if item["canonical"] == "occupation.astronaut" and context.source_state == "conflicted" else item["confidence"]
            normalized["crosswalks"].append(_crosswalk(item, confidence, [provenance_id]))
            normalized["claims"].append(_claim(self.source_id, item["canonical"], f"{item['label']} has Wikidata entity crosswalk candidate {item['wikidata']}.", "entity_label_crosswalk", confidence, context.source_state, [provenance_id]))


class OpenAlexAdapter(FixturePublicReferenceAdapter):
    source_id = "openalex.dataset"
    adapter_id = ADAPTER_IDS[source_id]
    domain = "scholarly_reference"

    def _base_records(self) -> list[dict[str, Any]]:
        return [item for item in OCCUPATION_FIXTURES if item.get("openalex")]

    def _populate_normalized(self, normalized: dict[str, Any], records: list[dict[str, Any]], context: AdapterRunContext) -> None:
        provenance_id = stable_id("provenance", {"sourceID": self.source_id, "adapterID": self.adapter_id, "state": context.source_state})
        normalized["offlineBulkOption"] = {"represented": True, "route": "OpenAlex snapshot", "fixtureTestsRequireCredentials": False}
        for item in records:
            normalized["claims"].append(_claim(self.source_id, item["canonical"], f"{item['label']} has OpenAlex research topic context candidate {item['openalex']}.", "research_topic_context", "medium", context.source_state, [provenance_id]))
            normalized["atoms"].append(_atom(self.source_id, f"openalex.{item['openalex']}", item["openalex"], "research_topic", [provenance_id]))


class RestrictedSourcePolicyAdapter(FixturePublicReferenceAdapter):
    source_id = "usajobs.search"
    adapter_id = ADAPTER_IDS[source_id]
    domain = "restricted_policy"

    def _base_records(self) -> list[dict[str, Any]]:
        return [{"source": "USAJOBS", "policy": "lookup_only_not_packable"}]

    def _populate_normalized(self, normalized: dict[str, Any], records: list[dict[str, Any]], context: AdapterRunContext) -> None:
        provenance_id = stable_id("provenance", {"sourceID": self.source_id, "adapterID": self.adapter_id, "state": context.source_state})
        normalized["sourceState"]["packEligible"] = False
        normalized["sourceState"]["blockedReasons"].append("restricted_terms_not_redistributable")
        normalized["claims"].append(_claim(self.source_id, "restricted.usajobs", "USAJOBS is represented as lookup-only until redistributable terms are explicitly reviewed.", "restricted_source_policy", "review_required", "terms-blocked", [provenance_id], review=True))


def adapter_instances() -> list[SourceAdapter]:
    return [OnetAdapter(), BlsAdapter(), WikidataAdapter(), OpenAlexAdapter(), RestrictedSourcePolicyAdapter()]


def run_all_adapters(source_state: str = "current", created_at: str | None = None) -> list[dict[str, Any]]:
    context = AdapterRunContext(source_state=source_state, fixture_mode=True, created_at=created_at or utc_now())
    return [adapter.run(context) for adapter in adapter_instances()]


def emit_all_adapter_fixtures(output_root: Path) -> dict[str, Any]:
    written: list[dict[str, Any]] = []
    for adapter in adapter_instances():
        written.extend(adapter.emit_fixtures(output_root))
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.adapterFixtureManifest.v1",
        "fixtureCount": len(written),
        "sourceStates": SOURCE_STATES,
        "fixtures": written,
    }


def scenario_overlay_for_outputs(output: dict[str, Any]) -> list[dict[str, Any]]:
    source_state = output.get("sourceState", {}).get("state", "unsupported")
    domain = output.get("domain")
    rows: list[dict[str, Any]] = []
    for scenario in SCENARIOS:
        status = "partially covered"
        reason = "public foundation references available, no user path generated"
        if source_state == "stale":
            status, reason = "stale", "source state is stale"
        elif source_state == "stale-critical":
            status, reason = "stale-critical", "critical stale source blocked from runtime use"
        elif source_state in {"unavailable", "unsupported", "malformed", "rate-limited"}:
            status, reason = "unsupported", f"source state {source_state}"
        elif source_state == "terms-blocked" or output.get("terms", {}).get("redistributionPolicy") == "lookup_only_not_packable":
            status, reason = "not packable due to terms", "terms registry blocks redistribution"
        elif source_state == "conflicted":
            status, reason = "review required", "conflicted source claims route to review"
        elif scenario == "marathon runner":
            status, reason = "missing official source", "athletic training source lane not included in Train 01"
        elif scenario in {"career pivot", "still-counts pivot"} and domain in {"occupation", "entity_crosswalk"}:
            status, reason = "covered", "transfer and crosswalk atoms can support local composition later"
        rows.append({"scenario": scenario, "coverage": status, "reason": reason, "doesNotCreateUserPath": True})
    return rows


def review_queue_items(outputs: list[dict[str, Any]]) -> list[dict[str, Any]]:
    items: list[dict[str, Any]] = []
    for output in outputs:
        source_id = output["sourceID"]
        for claim in output.get("claims", []):
            if claim.get("reviewRequirement") or claim.get("confidence") in {"low", "conflicted", "review_required"}:
                items.append(_review_item(source_id, claim["id"], "low-confidence or conflicted claim", claim.get("confidence", "review_required")))
            if claim.get("sourceState") in {"stale-critical", "revoked"}:
                items.append(_review_item(source_id, claim["id"], "stale-critical or revoked fact", claim.get("sourceState")))
        gate = output.get("termsValidation", {})
        if not gate.get("packable", False):
            items.append(_review_item(source_id, f"terms.{source_id}", "restricted terms or unclear license", "review_required"))
    return items


def _terms_slice(entry: dict[str, Any]) -> dict[str, Any]:
    return {
        "sourceID": entry["source_id"],
        "publisher": entry["publisher"],
        "license": entry["license"],
        "licenseVersion": entry["license_version"],
        "termsURL": entry["terms_url"],
        "authorityTier": entry["authority_tier"],
        "redistributionPolicy": entry["redistribution_policy"],
        "r2PackPolicy": entry["r2_pack_policy"],
        "attributionRequired": entry["attribution_required"],
        "freshnessCadence": entry["freshness_cadence"],
        "termsReviewStatus": entry["terms_review_status"],
        "lastTermsReviewed": entry["last_terms_reviewed"],
        "reviewRequired": entry["review_required"],
    }


def _claim(source_id: str, key: str, text: str, claim_type: str, confidence: str, source_state: str, provenance_ids: list[str], review: bool = False) -> dict[str, Any]:
    assert confidence in CONFIDENCE_STATES
    entry = terms_entry(source_id)
    return {
        "schemaVersion": 1,
        "kind": SCHEMA_KINDS["claim"],
        "id": stable_id("claim", {"sourceID": source_id, "key": key, "type": claim_type}),
        "versionID": "adapter-broad-coverage-train-01",
        "text": text,
        "claimType": claim_type,
        "state": "source_backed" if confidence not in {"unsupported", "conflicted", "review_required"} else "candidate",
        "freshness": "current" if source_state == "current" else source_state,
        "sourceIDs": [source_id],
        "provenanceIDs": provenance_ids,
        "sourceID": source_id,
        "sourceURL": entry["source_url"],
        "publisher": entry["publisher"],
        "authorityTier": entry["authority_tier"],
        "licenseTermsReference": entry["terms_url"],
        "freshnessCadence": entry["freshness_cadence"],
        "sourceState": source_state,
        "jurisdiction": entry["jurisdiction"],
        "confidence": confidence,
        "reviewRequirement": review or confidence in {"low", "conflicted", "review_required"},
        "checksum": stable_id("claim.checksum", {"text": text, "source": source_id}).split(".", 1)[1],
        "dataClass": "public_reference_claim",
        "publicReferenceOnly": True,
    }


def _requirement(source_id: str, key: str, claim_id: str, gate_type: str, provenance_ids: list[str], source_state: str) -> dict[str, Any]:
    return {
        "schemaVersion": 1,
        "kind": SCHEMA_KINDS["requirement"],
        "id": stable_id("requirement", {"sourceID": source_id, "key": key, "gate": gate_type}),
        "versionID": "adapter-broad-coverage-train-01",
        "claimID": claim_id,
        "gateType": gate_type,
        "structuredRule": {"type": "public_reference_only", "sourceState": source_state, "doesNotCreateRuntimeStep": True},
        "sourceIDs": [source_id],
        "provenanceIDs": provenance_ids,
        "dataClass": "public_requirement",
        "publicReferenceOnly": True,
    }


def _atom(source_id: str, key: str, label: str, atom_type: str, provenance_ids: list[str]) -> dict[str, Any]:
    return {
        "schemaVersion": 1,
        "kind": SCHEMA_KINDS["atom"],
        "id": stable_id("atom", {"sourceID": source_id, "key": key, "label": label}),
        "versionID": "adapter-broad-coverage-train-01",
        "label": label,
        "atomType": atom_type,
        "sourceIDs": [source_id],
        "provenanceIDs": provenance_ids,
        "dataClass": "public_atom_edge_lattice",
        "publicReferenceOnly": True,
    }


def _edge(source_id: str, key: str, from_atom_id: str, to_atom_id: str, relationship: str, provenance_ids: list[str]) -> dict[str, Any]:
    return {
        "schemaVersion": 1,
        "kind": SCHEMA_KINDS["edge"],
        "id": stable_id("edge", {"sourceID": source_id, "key": key, "from": from_atom_id, "to": to_atom_id, "relationship": relationship}),
        "versionID": "adapter-broad-coverage-train-01",
        "fromAtomID": from_atom_id,
        "toAtomID": to_atom_id,
        "relationship": relationship,
        "sourceIDs": [source_id],
        "provenanceIDs": provenance_ids,
        "dataClass": "public_atom_edge_lattice",
        "publicReferenceOnly": True,
    }


def _lattice(source_id: str, atoms: list[dict[str, Any]], edges: list[dict[str, Any]], recipes: list[dict[str, Any]]) -> dict[str, Any]:
    return {
        "schemaVersion": 1,
        "kind": SCHEMA_KINDS["lattice"],
        "id": stable_id("lattice", {"sourceID": source_id, "atomCount": len(atoms), "edgeCount": len(edges)}),
        "versionID": "adapter-broad-coverage-train-01",
        "atomIDs": [atom["id"] for atom in atoms],
        "edgeIDs": [edge["id"] for edge in edges],
        "recipeIDs": [recipe["id"] for recipe in recipes],
        "dataClass": "public_atom_edge_lattice",
        "publicReferenceOnly": True,
    }


def _recipe(source_id: str, title: str, atoms: list[dict[str, Any]], requirements: list[dict[str, Any]], provenance_ids: list[str]) -> dict[str, Any]:
    return {
        "schemaVersion": 1,
        "kind": SCHEMA_KINDS["recipe"],
        "id": stable_id("recipe", {"sourceID": source_id, "title": title}),
        "versionID": "adapter-broad-coverage-train-01",
        "title": title,
        "inputAtomIDs": [atom["id"] for atom in atoms[:5]],
        "outputAtomIDs": [atom["id"] for atom in atoms[5:10]],
        "requirementIDs": [item["id"] for item in requirements],
        "sourceIDs": [source_id],
        "provenanceIDs": provenance_ids,
        "doesNotStoreFinalUserPath": True,
        "doesNotCreateFinalSchedule": True,
        "localRuntimeJoinRequired": True,
        "dataClass": "public_recipe",
        "publicReferenceOnly": True,
    }


def _crosswalk(item: dict[str, Any], confidence: str, provenance_ids: list[str]) -> dict[str, Any]:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.entityCrosswalk.v1",
        "id": stable_id("crosswalk", item),
        "canonicalOccupationID": item["canonical"],
        "onetOccupationCode": item.get("onet"),
        "blsSocCode": item.get("bls"),
        "wikidataQID": item.get("wikidata"),
        "openAlexID": item.get("openalex"),
        "label": item["label"],
        "candidates": [
            {"source": "onet", "id": item.get("onet"), "confidence": item["confidence"]},
            {"source": "bls", "id": item.get("bls"), "confidence": item["confidence"] if item.get("bls") else "unsupported"},
            {"source": "wikidata", "id": item.get("wikidata"), "confidence": confidence},
            {"source": "openalex", "id": item.get("openalex"), "confidence": item["confidence"] if item.get("openalex") else "unsupported"},
        ],
        "confidence": confidence,
        "ambiguityPreserved": True,
        "silentWinnerSelectionAllowed": False,
        "reviewRequired": confidence in {"low", "conflicted", "review_required"},
        "sourceIDs": ["wikidata.crosswalk"],
        "provenanceIDs": provenance_ids,
        "dataClass": "public_ontology",
        "publicReferenceOnly": True,
    }


def _review_item(source_id: str, item_id: str, reason: str, status: str) -> dict[str, Any]:
    category = "regulated_claim" if any(term in item_id for term in ["lawyer", "nurse", "medical"]) else "source_review"
    return {
        "id": stable_id("review", {"sourceID": source_id, "itemID": item_id, "reason": reason}),
        "sourceID": source_id,
        "itemID": item_id,
        "category": category,
        "reason": reason,
        "status": status,
        "requiresHumanReview": True,
        "dataClass": "public_provenance",
        "publicReferenceOnly": True,
    }


def _non_claims() -> list[str]:
    return [
        "does not create final user paths",
        "does not create final schedules",
        "does not create Step lists",
        "does not gather private user data",
        "does not claim legal, privacy, release, or R2 production readiness",
    ]
