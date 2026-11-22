# Wireshark

Inspect a packet trace to see when a device retried a Wi-Fi frame, or examine Bluetooth packets produced by a compatible capture source.

## What you need

An existing packet capture works offline. For live over-the-air Wi-Fi use a compatible monitor-mode radio tuned to the channel of your AP. Signal metadata depends on the device and driver.

## Measurement workflow

Open a trace from a known interval on your own network. Limit the display to the relevant transmitter and data frames. Compare the count marked `wlan.fc.retry == 1` with the total observed data frames from that transmitter. Inspect `radiotap.dbm_antsignal` if present. Compare time windows of equal length.

## Limits and interpretation

The observed retry fraction depends on which frames the receiver heard. Missing radiotap fields are unknown. Frame timing and signal level can support an interference hypothesis but cannot identify a non-Wi-Fi emitter.

## Upstream references

[Wi-Fi fields](https://www.wireshark.org/docs/dfref/w/wlan.html) · [Radiotap fields](https://www.wireshark.org/docs/dfref/r/radiotap.html)
