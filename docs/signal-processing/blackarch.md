# BlackArch

BlackArch supplies an additional Arch package repository. Use its package list to identify an individual tool and its dependencies.

## What you need

A native Arch installation for Arch package management. For offline RF work, standard Arch repositories already carry several of the tools in this guide.

## Measurement workflow

Start with `iw`, `bluez`, `bluez-utils`, and `wireshark-qt` for the radios the host already sees. For recordings, look up `inspectrum` in Arch Extra. Consider BlackArch when you have identified a particular package you need.

## Limits and interpretation

Adding a software repository leaves antenna response, tuner range, monitor-mode support and the host kernel's access to the radio unchanged. A full tool collection adds little to a first offline measurement.

## Upstream references

[BlackArch package options](https://blackarch.org/downloads.html) · [inspectrum in Arch Extra](https://archlinux.org/packages/extra/x86_64/inspectrum/)
