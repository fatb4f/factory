# GopherTrunk

The project documents Android ARM binaries that run in Termux and can sweep received power or capture receiver samples.

## What you need

On a stock Pixel, the documented live path uses an external compatible RTL-SDR attached over USB OTG and an Android driver app serving `rtl_tcp` on loopback. Use a native Android release newer than v1.2.3.

## Measurement workflow

Confirm reception of a known local FM broadcast. Sweep a short range, save the frequency and relative power observations to CSV, and repeat with fixed receiver gain and antenna placement. Check for dropped samples before comparing runs.

## Limits and interpretation

The external tuner determines frequency coverage. A swept power measurement is time-staggered. The maintainers document Android build and dropped-sample caveats. The exact Pixel setup has not been tested for this guide.

## Upstream references

[Android and Termux workflow](https://gophertrunk.org/termux.html) · [Project releases](https://github.com/MattCheramie/GopherTrunk/releases)
