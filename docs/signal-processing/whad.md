# WHAD

WHAD provides a Python library and a shared device protocol. A connector can discover the domains and capabilities exposed by compatible radio firmware. Supported examples include BLE and Zigbee.

## What you need

A WHAD-supported adapter with firmware implementing the intended domain and receive capability. Choose the adapter for the protocol you need.

## Measurement workflow

For a known BLE sensor, check the adapter capabilities, observe its advertising reports, then inspect the decoded fields and event spacing. Record the adapter, firmware and protocol domain so another device can repeat the workflow.

## Limits and interpretation

Capabilities vary by firmware, radio and domain. Seeing a BLE advertisement does not establish arbitrary spectrum coverage, Bluetooth Classic support, or access to the contents of an encrypted connection.

## Upstream references

[WHAD supported protocols](https://whad.io/) · [Devices and connectors](https://whad.readthedocs.io/en/latest/api/device.html)
