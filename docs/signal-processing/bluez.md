# BlueZ

The Linux Bluetooth stack includes `bluetoothctl` for controller and device state and `btmon` for events between the host and its Bluetooth controller.

## What you need

A Bluetooth controller exposed to Linux, the BlueZ service for `bluetoothctl`, and suitable privileges to read the monitor socket for `btmon`. Arch packages the two utilities in `bluez-utils`.

## Measurement workflow

Check `bluetoothctl show`. Start `btmon` with monitor permissions, then reconnect a headset or sensor you own. Mark the time of the failure and inspect connection or disconnection events. For offline review, use `btmon -w session.btsnoop` during a short test.

## Limits and interpretation

HCI shows the controller's view. Events, status codes and local data can explain a host-side failure. A missing event cannot establish that a remote device was silent over the air. For on-air BLE timing use the [Nordic sniffer](nordic-ble-sniffer.md) or [Sniffle](sniffle.md).

## Upstream references

[BlueZ btmon reference](https://github.com/bluez/bluez/wiki/btmon) · [Arch bluez-utils contents](https://archlinux.org/packages/extra/x86_64/bluez-utils/files/)
