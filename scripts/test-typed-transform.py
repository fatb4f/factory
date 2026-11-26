"""Contract smoke test using a backend-free transform."""
from dataclasses import dataclass
import unittest

from runtime.typed_transform import (
    TransformContext, TransformLoss, TransformRejected, TransformResult, TypedTransform,
)


@dataclass(frozen=True, slots=True)
class Observation:
    label: str
    available_at: int


def project(value: Observation, *, context: TransformContext) -> TransformResult[str]:
    if value.available_at > context.known_at:
        raise TransformRejected("observation is not available at the knowledge cutoff")
    return TransformResult(
        value.label, (TransformLoss("/available_at", "not part of output"),), context.input_digests,
    )


class TypedTransformTest(unittest.TestCase):
    def test_loss_and_provenance_survive_translation(self):
        transform: TypedTransform[Observation, str] = project
        digests = ("sha256:" + "a" * 64,)
        result = transform(Observation("synthetic", 20), context=TransformContext(digests, 10, 20))
        self.assertEqual(result.value, "synthetic")
        self.assertEqual(result.input_digests, digests)
        self.assertEqual(result.losses[0].path, "/available_at")

    def test_unavailable_input_is_rejected(self):
        with self.assertRaises(TransformRejected):
            project(Observation("synthetic", 20), context=TransformContext((), 10, 19))


if __name__ == "__main__":
    unittest.main()
