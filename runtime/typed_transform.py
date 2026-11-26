"""Experimental backend-neutral transform port. This module admits no facts."""
from dataclasses import dataclass
from typing import Generic, Protocol, TypeVar

_Input = TypeVar("_Input", contravariant=True)
_Output = TypeVar("_Output", covariant=True)


@dataclass(frozen=True, slots=True)
class TransformContext:
    input_digests: tuple[str, ...]
    valid_at: int
    known_at: int


@dataclass(frozen=True, slots=True)
class TransformLoss:
    path: str
    reason: str


@dataclass(frozen=True, slots=True)
class TransformResult(Generic[_Output]):
    value: _Output
    losses: tuple[TransformLoss, ...]
    input_digests: tuple[str, ...]


class TransformRejected(ValueError):
    """Inputs cannot be translated without violating the transform contract."""


class TypedTransform(Protocol[_Input, _Output]):
    def __call__(self, value: _Input, *, context: TransformContext) -> TransformResult[_Output]: ...
