# Dual-scale capture

Use `#DualLoadSample` for simultaneous left/right load readings.

Capture:

- raw left value;
- raw right value;
- identical units for both channels;
- timestamp when available;
- stance/test description;
- scale/device provenance.

Prefer repeated samples or a short stable window rather than a single hand-selected reading when the device permits it.

Do not store derived imbalance percentage, preferred side, center-of-load, or correction state in the raw sample. Those belong to analysis projections and must retain references to the source samples.
