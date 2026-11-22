# Network Survey

This standalone Android app logs readings made available by the phone and can write local CSV files. It covers cellular, Wi-Fi and Bluetooth, including BLE.

## What you need

A supported Android phone with permissions for the selected observation types. The stock phone can provide survey records without an external SDR.

## Measurement workflow

Select the desired radios and local CSV output. Compare two short, timed stationary runs using the same settings. Check which signal metrics and timestamps are actually present. Analyze local exports in Termux or on the Chromebook. Account for location fields before sharing.

## Limits and interpretation

Android and the modem control scan cadence and field availability. Blank values mean unavailable. Phone telemetry cannot establish RF waveform shape or the cause of a change in signal level.

## Upstream references

[Network Survey user manual](https://networksurvey.app/manual/)
