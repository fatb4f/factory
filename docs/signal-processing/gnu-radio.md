# GNU Radio

Connect signal sources, filters and measurements into reusable flowgraphs. Simulated inputs and recorded files let you develop a detector before buying a receiver.

## What you need

GNU Radio on a supported system. Arch distributes `gnuradio`. Live capture also needs a compatible hardware interface.

## Measurement workflow

Create a repeatable offline baseline using a generated tone and noise. Filter the band of interest, estimate power over a fixed time window, and compare it to a threshold. Run the same settings on a labeled recording and count missed events and extra detections.

## Limits and interpretation

Results depend on sample rate, gain, window length and threshold. Record those settings alongside the recording. Successful simulation gives no performance guarantee on live hardware.

## Upstream references

[GNU Radio overview](https://www.gnuradio.org/about/) · [Arch package](https://archlinux.org/packages/extra/x86_64/gnuradio/)
