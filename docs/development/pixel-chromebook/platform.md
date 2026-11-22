# Chromebook compatibility and migration

Research snapshot for November 15, 2026. Chromium lists **Marasov** as the CX3402CBA/CX3402CVA device codename on the **Brya** baseboard family. ASUS Canada's CX34 specs list a 1080p webcam with privacy shutter. They provide no documented Face Unlock or fingerprint reader for those variants. Google says model eligibility and migration paths for Googlebook OS will be announced later. The search surfaced no official CX34 eligibility or upgrade procedure. Google lists June 2032 ChromeOS updates for the CX3402CBA. Check the device's update schedule for the actual SKU.

If restoring the recovered unit, back up local files and Linux data first. Use Powerwash to reset a working stock ChromeOS install. Use ChromeOS Recovery if a ChromeOS reinstall is needed. Re-pair the Pixel and qualify the accessibility flow before evaluating a different OS.

| Environment | What it runs | Relevance to CX34 |
| --- | --- | --- |
| ChromeOS Developer Mode / VT2 | Host console for ChromeOS debugging | The virtual terminal likely recalled in conversation. Stock Linux and Secure Shell workflows can begin without Developer Mode. |
| Crostini / Termina | Debian container inside the ChromeOS-managed Termina VM | Local Python and offline use. Save work before shutting down Linux. From Crosh, `vmc stop termina` stops the default VM when that name is in use. |
| Bruschetta | ChromeOS-managed third-party guest VM, with policy-controlled installation | Closest match for a direct guest without a Crostini container. Availability on the stock CX34 was unverified. |
| Secure Shell / remote KVM | SSH client on ChromeOS and Linux execution on the remote host | Preserves local stock pairing and omits the local Linux VM during remote work. |

## Community work

| Project | Reported result and limit |
| --- | --- |
| [Project Churro](https://github.com/alesimula/project-churro) | Public scripts convert an official recovery image locally for generic x86-64 UEFI. The documented target is Alder Lake or newer. Its Arrow Lake USB test reported Wi-Fi and USB input, with sound and touchpad missing. CX34 CPU generation is in range, but Marasov remains unverified. |
| [gbOS86](https://github.com/linuxkid473/gbos-x86) | Generic Intel port with reports for older laptops such as ThinkPad T470 and Dell Latitude 5300. Some device authentication services have software substitutes. Stock authentication, Pixel integration, and hardware-backed security on the CX34 are unverified. |
| [gbos-x86-port](https://github.com/fukayatti/gbos-x86-port) | Documents a KVM proof of concept and a Ryzen 7 5700U bare-metal test. Useful for evaluating the OS in a disposable KVM guest before considering any hardware changes. |
| [MrChromebox](https://docs.mrchromebox.tech/docs/supported-devices.html) and [Chrultrabook](https://github.com/chrultrabook) | Board-specific firmware and Linux/Windows repurposing across Chromebook generations. Marasov is listed for RW_LEGACY and full UEFI. That listing establishes firmware availability. Guest driver support and Googlebook OS compatibility require separate evidence. |
| [openFyde](https://github.com/openFyde) and [Brunch](https://github.com/sebanc/brunch) | Related Chromium OS and ChromeOS reuse projects. openFyde publishes device-specific overlays. Brunch assembles a generic PC ChromeOS image from recovery media. |

An [unofficial ASUS Chromebook Plus boot report](https://www.reddit.com/r/Googlebook/comments/1x5rcb1/got_googlebookos_running_on_my_asus_chromebook/) was updated to say Wi-Fi and sound worked. The exact board and working Pixel pairing were unverified. Public porting code and Google's recovery image have separate provenance and licensing.

## Sources

- [Chromium device table](https://new.chromium.org/chromium-os/developer-library/reference/development/developer-information-for-chrome-os-devices/)
- [ASUS Canada CX34 specifications](https://www.asus.com/ca-en/laptops/for-home/chromebook/asus-chromebook-plus-cx34-cx3402/techspec/)
- [Googlebook migration guidance](https://support.google.com/chrome/a/answer/16634428) and [ChromeOS update policy](https://support.google.com/chrome/a/answer/6220366)
- [ChromeOS factory reset](https://support.google.com/chromebook/answer/183084) and [Chromebook recovery](https://support.google.com/chromebook/answer/1080595)
- [ChromeOS Developer Mode](https://new.chromium.org/chromium-os/developer-library/guides/device/developer-mode/) and [Crostini containers and VMs](https://new.chromium.org/chromium-os/developer-library/guides/containers/containers-and-vms/)
- [Bruschetta installer policy](https://chromeenterprise.google/intl/en_ca/policies/bruschetta-installer-configuration/)
