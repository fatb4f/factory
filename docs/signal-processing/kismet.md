# Kismet

Kismet combines observations from multiple supported sources, retains packet and device history in a kismetdb file, and can feed later packet analysis.

## What you need

For Linux Wi-Fi monitoring, check monitor-mode and band support. A standard Linux Bluetooth HCI adapter can supply discovery observations. Source capabilities vary.

## Measurement workflow

Choose a question such as whether retries coincide with a dropout on your AP. Select the matching Wi-Fi source, hold the channel fixed for the event, and note the capture interval. Compare the trace in [Wireshark](wireshark.md). For BLE discovery, record which HCI source produced the results.

## Limits and interpretation

The generic Linux Bluetooth source performs active discovery and reports advertised attributes. Passive BLE packet capture requires suitable sniffer hardware. A Wi-Fi survey cannot measure all energy in a band. Upstream's October 2026 release added capture options and memory improvements. Check the installed version before assuming feature parity.

## Upstream references

[Kismet downloads and release notes](https://www.kismetwireless.net/download/) · [Linux Wi-Fi source](https://www.kismetwireless.net/docs/readme/datasources/wifi-linux/) · [Bluetooth HCI source](https://www.kismetwireless.net/docs/readme/datasources/bluetooth-hci-bluetooth/)
