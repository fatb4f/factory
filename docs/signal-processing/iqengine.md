# IQEngine

Explore public recordings or open a local SigMF recording and visualize its spectrum in a browser. This is the lowest-friction starting point on a Chromebook.

## What you need

A browser and either a public example or a local sample file with compatible metadata. Browser memory and performance depend on the file and device.

## Measurement workflow

Open a public recording, note the center frequency and sample rate, and zoom into a repeatable feature. Record its start time, duration and frequency span. Use the same file in [inspectrum](inspectrum.md) to cross-check the time measurement.

## Limits and interpretation

A saved recording contains only its original time interval and bandwidth. Local-file visualization is client-side. Optional backend plugins have a different execution boundary.

## Upstream references

[IQEngine](https://www.iqengine.org/) · [Project README](https://github.com/IQEngine/IQEngine) · [Plugin execution model](https://iqengine.org/about)
