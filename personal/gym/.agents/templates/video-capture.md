# Video capture

Register the video or image as a `#MediaArtifact` before attaching derived observations.

Capture when known:

- capture timestamp;
- perspective;
- duration/frame rate/resolution;
- device identifier;
- URI or digest if the media is persisted externally;
- session/exposure association through linked observations.

Video-derived values such as joint angles, torso/pelvis orientation, ROM landmarks, repetition timing, velocity, or symmetry are separate `#Measurement` records with `provenance.sourceKind: video` and a media reference.

Do not treat computer-vision output as causal interpretation. Preserve model uncertainty as `approximate` provenance unless a measurement is directly calibrated.
