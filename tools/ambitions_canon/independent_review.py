"""Base-owned independent-review evidence validation."""

from __future__ import annotations

from collections.abc import Mapping, Sequence
from datetime import datetime, timezone
import json
import os
import re
import subprocess


CODEX_REVIEWER_ID = 199175422
CODEX_REVIEWER_LOGIN = "chatgpt-codex-connector[bot]"
OWNER_REVIEW_REQUEST_ID = 529921
OWNER_REVIEW_REQUEST_LOGIN = "agentdevan"


class IndependentReviewError(ValueError):
    """Stable fail-closed independent-review validation error."""


def validate_independent_review_payload(
    reviews: Sequence[Mapping[str, object]],
    comments_by_review: Mapping[int, Sequence[Mapping[str, object]]],
    *,
    expected_head_sha: str,
    reviews_has_next_page: bool,
    comments_with_next_page: frozenset[int],
    review_requests: Sequence[Mapping[str, object]] = (),
    clean_reactions: Sequence[Mapping[str, object]] = (),
) -> dict[str, object]:
    if not re.fullmatch(r"[0-9a-f]{40}", expected_head_sha):
        raise IndependentReviewError("REVIEW_HEAD_INVALID")
    if not isinstance(reviews_has_next_page, bool):
        raise IndependentReviewError("REVIEW_PAYLOAD_INVALID")
    if reviews_has_next_page:
        raise IndependentReviewError("REVIEW_PAGINATION_AMBIGUOUS")

    matching: list[Mapping[str, object]] = []
    for raw in reviews:
        if not isinstance(raw, Mapping):
            raise IndependentReviewError("REVIEW_PAYLOAD_INVALID")
        user = raw.get("user")
        if not isinstance(user, Mapping):
            raise IndependentReviewError("REVIEW_PAYLOAD_INVALID")
        if (
            user.get("id") == CODEX_REVIEWER_ID
            and user.get("login") == CODEX_REVIEWER_LOGIN
            and user.get("type") == "Bot"
            and raw.get("commit_id") == expected_head_sha
        ):
            matching.append(raw)
    expected_marker = f"**Reviewed commit:** `{expected_head_sha[:10]}`"
    for raw in matching:
        review_id = raw.get("id")
        if isinstance(review_id, bool) or not isinstance(review_id, int):
            raise IndependentReviewError("REVIEW_PAYLOAD_INVALID")
        if raw.get("state") != "COMMENTED":
            raise IndependentReviewError("REVIEW_STATE_INVALID")
        body = raw.get("body")
        if not isinstance(body, str) or expected_marker not in body:
            raise IndependentReviewError("REVIEW_HEAD_MARKER_INVALID")
        if review_id in comments_with_next_page:
            raise IndependentReviewError("REVIEW_PAGINATION_AMBIGUOUS")
        comments = comments_by_review.get(review_id)
        if not isinstance(comments, Sequence) or isinstance(
            comments, (str, bytes, bytearray)
        ):
            raise IndependentReviewError("REVIEW_PAYLOAD_INVALID")
        if comments:
            raise IndependentReviewError("REVIEW_FINDINGS_PRESENT")

    request_body = (
        "CODEX-INDEPENDENT-REVIEW-REQUEST\n"
        f"head={expected_head_sha}\n"
        "required=zero-critical-zero-important"
    )
    requests: list[tuple[datetime, int]] = []
    for raw in review_requests:
        if not isinstance(raw, Mapping):
            raise IndependentReviewError("REVIEW_PAYLOAD_INVALID")
        user = raw.get("user")
        if not isinstance(user, Mapping):
            raise IndependentReviewError("REVIEW_PAYLOAD_INVALID")
        if (
            user.get("id") == OWNER_REVIEW_REQUEST_ID
            and user.get("login") == OWNER_REVIEW_REQUEST_LOGIN
            and user.get("type") == "User"
            and raw.get("body") == request_body
        ):
            request_id = raw.get("id")
            if isinstance(request_id, bool) or not isinstance(request_id, int):
                raise IndependentReviewError("REVIEW_PAYLOAD_INVALID")
            requests.append(
                (_github_timestamp(raw.get("created_at")), request_id)
            )
    if not requests:
        raise IndependentReviewError("REVIEW_EXACT_HEAD_MISSING")

    reactions: list[tuple[datetime, int]] = []
    for raw in clean_reactions:
        if not isinstance(raw, Mapping):
            raise IndependentReviewError("REVIEW_PAYLOAD_INVALID")
        user = raw.get("user")
        if not isinstance(user, Mapping):
            raise IndependentReviewError("REVIEW_PAYLOAD_INVALID")
        if (
            user.get("id") == CODEX_REVIEWER_ID
            and user.get("login") == CODEX_REVIEWER_LOGIN
            and user.get("type") in {"Bot", "User"}
            and raw.get("content") == "+1"
        ):
            reaction_id = raw.get("id")
            if isinstance(reaction_id, bool) or not isinstance(reaction_id, int):
                raise IndependentReviewError("REVIEW_PAYLOAD_INVALID")
            reactions.append(
                (_github_timestamp(raw.get("created_at")), reaction_id)
            )
    qualifying = [
        (reaction_time, reaction_id, request_id)
        for request_time, request_id in requests
        for reaction_time, reaction_id in reactions
        if reaction_time > request_time
    ]
    if not qualifying:
        raise IndependentReviewError("REVIEW_CLEAN_REACTION_MISSING")
    _reaction_time, reaction_id, request_id = max(qualifying)
    result = _green_result(
        expected_head_sha=expected_head_sha,
        evidence_kind="owner-request-clean-reaction",
        evidence_id=reaction_id,
    )
    result["review_request_id"] = request_id
    return result


def _github_timestamp(value: object) -> datetime:
    if not isinstance(value, str) or not re.fullmatch(
        r"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z", value
    ):
        raise IndependentReviewError("REVIEW_TIMESTAMP_INVALID")
    try:
        parsed = datetime.strptime(value, "%Y-%m-%dT%H:%M:%SZ").replace(
            tzinfo=timezone.utc
        )
    except ValueError as exc:
        raise IndependentReviewError("REVIEW_TIMESTAMP_INVALID") from exc
    return parsed


def _green_result(
    *, expected_head_sha: str, evidence_kind: str, evidence_id: int
) -> dict[str, object]:
    return {
        "review_id": evidence_id,
        "evidence_kind": evidence_kind,
        "reviewer_id": CODEX_REVIEWER_ID,
        "reviewer_login": CODEX_REVIEWER_LOGIN,
        "reviewed_head_sha": expected_head_sha,
        "critical_findings": 0,
        "important_findings": 0,
        "inline_findings": 0,
    }


def fetch_independent_review_evidence(
    *,
    repository: str,
    pull_request_number: int,
    expected_head_sha: str,
    github_token: str,
) -> dict[str, object]:
    if not re.fullmatch(r"[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+", repository):
        raise IndependentReviewError("REVIEW_REPOSITORY_INVALID")
    if (
        isinstance(pull_request_number, bool)
        or not isinstance(pull_request_number, int)
        or pull_request_number <= 0
    ):
        raise IndependentReviewError("REVIEW_PULL_REQUEST_INVALID")
    if not isinstance(github_token, str) or not github_token:
        raise IndependentReviewError("REVIEW_TOKEN_MISSING")

    reviews = _gh_api_single_page(
        f"repos/{repository}/pulls/{pull_request_number}/reviews?per_page=100",
        github_token,
    )
    comments: dict[int, Sequence[Mapping[str, object]]] = {}
    for raw in reviews:
        if not isinstance(raw, Mapping):
            raise IndependentReviewError("REVIEW_API_INVALID")
        user = raw.get("user")
        if not isinstance(user, Mapping):
            raise IndependentReviewError("REVIEW_API_INVALID")
        review_id = raw.get("id")
        if (
            user.get("id") == CODEX_REVIEWER_ID
            and user.get("login") == CODEX_REVIEWER_LOGIN
            and raw.get("commit_id") == expected_head_sha
            and isinstance(review_id, int)
            and not isinstance(review_id, bool)
        ):
            comments[review_id] = _gh_api_single_page(
                f"repos/{repository}/pulls/{pull_request_number}/reviews/"
                f"{review_id}/comments?per_page=100",
                github_token,
            )
    review_requests = _gh_api_single_page(
        f"repos/{repository}/issues/{pull_request_number}/comments?per_page=100",
        github_token,
    )
    clean_reactions = _gh_api_single_page(
        f"repos/{repository}/issues/{pull_request_number}/reactions?per_page=100",
        github_token,
    )
    return validate_independent_review_payload(
        reviews,
        comments,
        expected_head_sha=expected_head_sha,
        reviews_has_next_page=False,
        comments_with_next_page=frozenset(),
        review_requests=review_requests,
        clean_reactions=clean_reactions,
    )


def _gh_api_single_page(
    endpoint: str,
    github_token: str,
) -> list[Mapping[str, object]]:
    environment = dict(os.environ)
    environment["GH_TOKEN"] = github_token
    try:
        completed = subprocess.run(
            ["gh", "api", "--paginate", "--slurp", endpoint],
            check=False,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            timeout=30,
            env=environment,
        )
    except (OSError, subprocess.SubprocessError) as exc:
        raise IndependentReviewError("REVIEW_API_FAILED") from exc
    if completed.returncode != 0:
        raise IndependentReviewError("REVIEW_API_FAILED")
    try:
        pages = json.loads(completed.stdout)
    except (UnicodeError, json.JSONDecodeError, TypeError) as exc:
        raise IndependentReviewError("REVIEW_API_INVALID") from exc
    if not isinstance(pages, list) or not pages or not all(
        isinstance(page, list) for page in pages
    ):
        raise IndependentReviewError("REVIEW_API_INVALID")
    if len(pages) != 1:
        raise IndependentReviewError("REVIEW_PAGINATION_AMBIGUOUS")
    page = pages[0]
    if not all(isinstance(item, Mapping) for item in page):
        raise IndependentReviewError("REVIEW_API_INVALID")
    return page


def main() -> int:
    try:
        repository = os.environ["AMBITIONS_CANON_REVIEW_REPOSITORY"]
        pull_request_number = int(
            os.environ["AMBITIONS_CANON_REVIEW_PULL_REQUEST"]
        )
        expected_head_sha = os.environ["AMBITIONS_CANON_REVIEW_HEAD_SHA"]
        github_token = os.environ["GH_TOKEN"]
        result = fetch_independent_review_evidence(
            repository=repository,
            pull_request_number=pull_request_number,
            expected_head_sha=expected_head_sha,
            github_token=github_token,
        )
        review_id = result.get("review_id")
        if isinstance(review_id, bool) or not isinstance(review_id, int):
            raise IndependentReviewError("REVIEW_RESULT_INVALID")
    except (KeyError, ValueError, IndependentReviewError) as exc:
        print(f"P0_BLOCKER INDEPENDENT_REVIEW_FAILED {exc}")
        return 1
    print(
        "GREEN independent review evidence "
        f"review_id={review_id} head={expected_head_sha}"
    )
    return 0
