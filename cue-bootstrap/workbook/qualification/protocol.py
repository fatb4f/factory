from __future__ import annotations

import json
from typing import Any

from pydantic import ValidationError

from .models import ProbeRequest, ProcessObservation


def encode_request(request: ProbeRequest) -> bytes:
    return request.model_dump_json(exclude_none=True).encode("utf-8") + b"\n"


def decode_request(line: bytes, *, max_bytes: int = 1_048_576) -> ProbeRequest:
    if len(line) > max_bytes:
        raise ValueError("request frame exceeds max_bytes")
    return ProbeRequest.model_validate_json(line)


def decode_observation(
    data: bytes,
    *,
    request: ProbeRequest,
) -> ProcessObservation:
    if len(data) > request.limits.max_output_bytes:
        raise ValueError("response frame exceeds max_output_bytes")
    lines = [line for line in data.splitlines() if line.strip()]
    if len(lines) != 1:
        raise ValueError(f"expected one response frame, received {len(lines)}")
    observation = ProcessObservation.model_validate_json(lines[0])
    if observation.protocol != request.protocol:
        raise ValueError("response protocol mismatch")
    if observation.request_id != request.request_id:
        raise ValueError("response request_id mismatch")
    return observation


def compact_json(value: dict[str, Any]) -> str:
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False)


__all__ = [
    "ValidationError",
    "compact_json",
    "decode_observation",
    "decode_request",
    "encode_request",
]
