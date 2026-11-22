# iw

Use `iw` on native Linux to see which Wi-Fi capabilities the kernel exposes and how the current association is performing.

## What you need

An interface visible to the host wireless stack. The Arch package is `iw`.

## Measurement workflow

Run `iw dev` to get the interface name. Run `iw list` and inspect the bands and **Supported interface modes** for that radio. With the laptop connected, run `iw dev <interface> link` after substituting the real interface name. Record the connected frequency and signal level at two fixed locations.

## Limits and interpretation

An interface may support monitor mode on only some bands or under limited concurrent configurations. A link-strength reading represents the associated network. It cannot measure energy from arbitrary emitters.

## Upstream references

[Linux Wireless iw reference](https://wireless.docs.kernel.org/en/latest/en/users/documentation/iw.html) · [Wireless modes](https://wireless.docs.kernel.org/en/latest/en/users/documentation/modes.html)
