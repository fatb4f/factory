# inspectrum

Use inspectrum to zoom into a recording and measure pulse length, repetition period and symbol timing. Its views include amplitude, phase and frequency.

## What you need

A recording in a supported raw format with a known sample rate, or a SigMF recording. The application works offline on Arch without a connected radio.

## Measurement workflow

Open a short reference capture, select one burst on the spectrogram, and use the time cursors to measure its duration. Measure several successive start-to-start intervals. Record the interval range and sample rate so another reader can repeat the measurement.

## Limits and interpretation

A wrong sample rate scales the time and frequency axes incorrectly. Similar-looking bursts can belong to different protocols. Live capture requires a separate acquisition tool.

## Upstream references

[inspectrum project](https://github.com/miek/inspectrum) · [Arch package](https://archlinux.org/packages/extra/x86_64/inspectrum/)
