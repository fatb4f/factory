# Nordic nRF Sniffer for Bluetooth LE

The Nordic sniffer firmware and Wireshark integration observe Bluetooth Low Energy advertisements and supported connections.

## What you need

A supported board such as the nRF52840 Dongle, the matching Nordic sniffer firmware, and the host software listed by Nordic. This is a vendor-provided option in the wider open-source tool ecosystem.

## Measurement workflow

Select the sniffer in Wireshark and begin with a sensor you control. Compare intervals between received advertisements while the sensor is stationary. Save the trace and note the sensor's configured advertising interval and sniffer setup.

## Limits and interpretation

This workflow covers BLE. Bluetooth Classic traffic requires different capture support. Packet loss and channel sampling can lengthen observed intervals. Encryption limits payload interpretation without the necessary keys.

## Upstream references

[Nordic supported hardware and tools](https://www.nordicsemi.com/Products/Development-tools/nRF-Sniffer-for-Bluetooth-LE)
