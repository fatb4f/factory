# ALFA AWUS036ACM

This USB adapter uses the MediaTek MT7612U chipset. A second physical Wi-Fi radio allows the laptop to stay connected while observing an independently selected channel.

## What you need

An accessible USB port and a Linux host with the mainline driver and firmware for the exact adapter. This model covers 2.4 and 5 GHz.

## Measurement workflow

Confirm the full model suffix before purchase. After attachment, use [iw](iw.md) to identify the second physical radio and check its modes. For a receive test, keep it on the channel of your own AP while opening a short capture in [Wireshark](wireshark.md). Confirm that the reported channel matches the AP.

## Limits and interpretation

Its bands exclude 6 GHz. A different antenna changes reception within the supported bands. This adapter delivers Wi-Fi frames and driver metadata rather than arbitrary waveform samples. A channel-hopping capture can miss short events.

## Upstream references

[ALFA model specifications](https://docs.alfa.com.tw/Product/AWUS036ACM/) · [ALFA Linux driver support](https://docs.alfa.com.tw/Support/Linux/MT7612U/)
