# RF signal processing and wireless assessment

Choose the input that can answer the question. A Pixel survey can show a change in its reported signal level. A Wi-Fi capture can show retries on a particular channel. A software-defined radio (SDR) can show how power varied across its tuned band. Relating those observations requires compatible time and frequency coverage.

## Start with the measurement

| Question | Input and first tool | Check before interpreting |
| --- | --- | --- |
| What did the phone observe during a dropout? | Android survey records from [Network Survey](network-survey.md) or [Termux:API](termux-api.md) | Available fields, observation age, scan cadence, and permissions |
| Did my access point or client retry frames? | Monitor-mode trace on the AP's channel, read in [Wireshark](wireshark.md) | Sender, channel, capture loss, and number of observed data frames |
| Did my BLE sensor advertise at the expected interval? | An on-air trace from [Sniffle](sniffle.md) or the [Nordic BLE sniffer](nordic-ble-sniffer.md) | Advertising channels, PHY, and missed packets |
| What occupied the band during that interval? | Live spectrum from [SDRangel](sdrangel.md) or a saved I/Q recording in [inspectrum](inspectrum.md) | Center frequency, instantaneous bandwidth, gain and sample rate |
| Can a detector recognize repeat occurrences? | A labeled recording or simulation in [GNU Radio](gnu-radio.md), with optional [TorchSig](torchsig.md) experiments | Held-out examples, missed events, false alarms and duration observed |

I/Q samples preserve the received waveform as two component values per sample. Hardware and sample settings bound what can be measured later. A packet trace preserves decoded frames and any metadata the capture driver supplied. An OS survey preserves observations exposed by that operating system.

## Chromebook and Pixel setup

Factory’s [Pixel and Chromebook integration guide](../development/pixel-chromebook/README.md) describes stock ChromeOS with an unrooted Pixel. **Native Arch** is an alternate host assumed by the Linux radio workflows here. On native Arch, check `iw dev`, `iw list`, and `bluetoothctl show` before buying hardware. Under ChromeOS/Crostini, verify that the guest can see the required hardware. IQEngine in a browser and offline recordings are useful with either host arrangement. [Google’s Chromebook Linux guide](https://support.google.com/chromebook/answer/9145439)

An antenna changes reception within the receiver’s supported frequencies. The chipset, filters, firmware and driver determine the available tuning and capture modes. A second Wi-Fi radio helps when the first must stay connected on a different channel. Choose an SDR by both tuning range and the bandwidth it can observe at one time. The [RTL-SDR Blog V4](rtl-sdr-blog-v4.md) is a useful example of why those two specifications matter.

### Host radios and packet analysis

| Guide | Use it for |
| --- | --- |
| [iw](iw.md) | Wi-Fi driver and link checks |
| [BlackArch](blackarch.md) | Arch tool selection |
| [ALFA AWUS036ACM](alfa-awus036acm.md) | Dual-band Wi-Fi capture adapter |
| [BlueZ](bluez.md) | Local Bluetooth controller diagnostics |
| [Wireshark](wireshark.md) | Packet timing and Wi-Fi retries |
| [Kismet](kismet.md) | Multi-radio surveys and wireless monitoring |
| [Nordic nRF Sniffer for Bluetooth LE](nordic-ble-sniffer.md) | On-air BLE measurements with Nordic hardware |
| [Sniffle](sniffle.md) | BLE capture with TI radios |

### Waveforms, metadata and reusable frameworks

| Guide | Use it for |
| --- | --- |
| [RTL-SDR Blog V4](rtl-sdr-blog-v4.md) | Receive-only SDR selection |
| [SDRangel](sdrangel.md) | Live spectrum and channel-power measurements |
| [inspectrum](inspectrum.md) | Measure recorded bursts |
| [IQEngine](iqengine.md) | Browser inspection of I/Q recordings |
| [SigMF](sigmf.md) | Portable recording metadata |
| [GNU Radio](gnu-radio.md) | Reusable signal-processing flowgraphs |
| [FISSURE](fissure.md) | Integrated RF analysis framework |
| [WHAD](whad.md) | Reusable wireless protocol analysis |
| [TorchSig](torchsig.md) | Evaluate learned signal detectors |

### Android and Termux

| Guide | Use it for |
| --- | --- |
| [Network Survey](network-survey.md) | Android Wi-Fi, Bluetooth and cellular observations |
| [Termux:API](termux-api.md) | Scriptable Android radio observations |
| [GopherTrunk](gophertrunk.md) | Receiver-based RF measurements in Termux |
| [Kali NetHunter Rootless](nethunter-rootless.md) | Kali userspace inside Termux |
| [Lazymux](lazymux.md) | Termux tool installer |

## Worked example: an intermittent Wi-Fi dropout

1. Establish a baseline on your AP's channel. Record AP channel and width, receiver location, time interval, and which interface collected each source. Synchronize clocks or record the timing uncertainty. Use the same placement in the comparison run.
2. Capture the same channel during a dropout. For a single transmitter, count observed data frames and those marked as retries. Report both counts and their ratio. If an SDR covers that channel, compare the matching interval on its waterfall. Document partial frequency coverage or gaps.
3. Repeat with a suspected household interference source under your control switched off, then on again. Hold traffic and placement as constant as practicable. Timed repetition makes the hypothesis testable. A coincident burst alone cannot identify a source or establish deliberate interference.

## Validation status

The guides describe upstream-documented capabilities. This survey did not measure performance on a specific Chromebook, Pixel, adapter, or receiver. Keep original captures local, with receiver settings and timestamps, and use public reference recordings for shareable examples. This directory contains documentation only.
