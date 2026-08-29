# Session start

Capture only the fields needed to establish the run baseline.

Required:

- session identity;
- start timestamp;
- session intent.

Capture when stated or quickly observable:

- planned exercises;
- energy available, 0-4;
- cognitive availability, 0-4;
- gait state;
- hinge and knee-flexion availability;
- residual DOMS, 0-5 by named region.

Do not ask for absent optional fields merely to complete the schema. Unknown state remains omitted or `unobserved`.

Normalize into `#SessionStart` and wrap in `#CaptureEnvelope` when persisting conversational capture.
