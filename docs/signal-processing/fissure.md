# FISSURE

FISSURE combines a dashboard, signal identification and a reusable library of flowgraphs and tools. It is the closest architectural match in this survey to a modular RF assessment workbench.

## What you need

Use an upstream-supported Linux environment. Ubuntu 24.04 is a documented option. On a native Arch laptop, an Ubuntu VM with saved recordings separates evaluation from host radio drivers.

## Measurement workflow

Start in the I/Q inspection tools with a known recording. Measure a burst, filter its band, and save the input parameters and flowgraph choice. Apply the same settings to a second recording and compare timing or occupied bandwidth. Use a live receive source only after verifying its hardware support.

## Limits and interpretation

Individual modules depend on their own tools, drivers and sample formats. A working dashboard does not demonstrate USB passthrough or complete frequency coverage. Signal classification is a hypothesis that needs a reference signal or independent evidence.

## Upstream references

[FISSURE documentation](https://fissure.readthedocs.io/en/latest/) · [Installation](https://fissure.readthedocs.io/en/latest/pages/installation.html) · [Hardware capabilities](https://fissure.readthedocs.io/en/latest/pages/hardware.html)
