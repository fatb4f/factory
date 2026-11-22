# SDRangel

SDRangel displays spectra and spectrograms and can measure channel power, adjacent-channel power and occupied bandwidth.

## What you need

An SDR supported by the chosen input plugin and capable of both the tuning frequency and instantaneous bandwidth needed for the measurement.

## Measurement workflow

Tune to the band of interest, fix gain and sample rate, and capture equal baseline and test intervals. Record center frequency, usable span and resolution along with the observed change. For Wi-Fi coexistence, time-align observations with a packet trace from the same channel.

## Limits and interpretation

A waterfall shows energy in the observed span. It cannot establish the transmitter's identity or intent. Absolute power comparisons need calibration, and a swept receiver leaves time gaps between visits.

## Upstream references

[SDRangel analysis features](https://www.sdrangel.org/)
