"""Read-only selection over the already authorized legal relationship view."""

from runtime.typed_transform import TransformResult


def linked_objects(view, *, context):
    return TransformResult(list(view.links), (), context.input_digests)
