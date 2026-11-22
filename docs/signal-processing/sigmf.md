# SigMF

SigMF describes sampled signals and their capture context using JSON metadata paired with a sample dataset. It can carry annotations and a dataset hash.

## What you need

Recorded samples, their precise datatype and byte order, and knowledge of sample rate and tuning. Record timestamps when available and identify their clock.

## Measurement workflow

Keep the `.sigmf-data` and `.sigmf-meta` pair together. Record `core:datatype`, `core:sample_rate`, capture `core:sample_start` and, for a tuned RF capture, `core:frequency`. Mark a burst by sample start and count. Reopen the pair and check that count divided by sample rate reproduces its duration.

## Limits and interpretation

Format validation checks structure. Correct units, tuning, clock alignment and receiver calibration still depend on the acquisition record. Missing metadata cannot be reconstructed from a filename alone.

## Upstream references

[SigMF specification, fields and extensions](https://sigmf.org/)
