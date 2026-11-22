# Sniffle

Sniffle is an open-source Bluetooth LE sniffer with a Python host interface and a Wireshark-compatible capture path.

## What you need

A supported TI CC1352 or CC26x2 board with compatible firmware. Select the exact board from upstream's list.

## Measurement workflow

Observe advertisements from a known BLE peripheral while it is in a known state. Save the trace, compare interarrival times, and note the PHY and which advertising channels were observed. Repeat the test at the same distance before interpreting an apparent gap.

## Limits and interpretation

Its protocol scope is BLE. Sampling across channels, signal loss and PHY support affect the capture. A missing or encrypted application payload is insufficient evidence of a device failure.

## Upstream references

[Sniffle capabilities, supported boards and capture formats](https://github.com/nccgroup/Sniffle)
