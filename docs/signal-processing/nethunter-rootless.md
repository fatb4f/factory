# Kali NetHunter Rootless

The rootless edition provides a Kali command-line environment on stock Android. It can be useful for inspecting saved traces with familiar Linux tools.

## What you need

An unrooted Android phone, Termux and adequate storage for the Kali userspace and selected tools.

## Measurement workflow

Choose a short saved capture with known contents. Open it in an installed offline analysis tool inside NetHunter and check packet count and timestamps against a desktop reading. This tests file access and the analysis environment before any live collection decisions.

## Limits and interpretation

The Android kernel and hardware access remain decisive. Kali's edition matrix reserves features such as Bluetooth Arsenal and Wi-Fi injection for the full edition with a supported custom kernel. A rootless install does not establish monitor-mode access on the Pixel.

## Upstream references

[Rootless edition](https://www.kali.org/docs/nethunter/nethunter-rootless/) · [Edition comparison](https://www.kali.org/docs/nethunter/)
