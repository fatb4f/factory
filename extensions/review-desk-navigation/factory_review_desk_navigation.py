"""Read-only selection over the already authorized legal relationship view."""

from typing import Protocol

from runtime.typed_transform import TransformContext, TransformResult


class LegalView(Protocol):
    @property
    def links(self) -> list[dict[str, object]]: ...


def linked_objects(view: LegalView, *, context: TransformContext) -> TransformResult[list[dict[str, object]]]:
    return TransformResult(list(view.links), (), context.input_digests)
