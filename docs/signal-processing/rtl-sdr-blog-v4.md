# RTL-SDR Blog V4

The V4 is a USB receiver for recording I/Q samples or displaying spectrum within its tuning range of 500 kHz to 1.766 GHz.

## What you need

V4-compatible driver, host USB access and an antenna appropriate for the intended band. The manufacturer's stable bandwidth figure is 2.56 MHz.

## Measurement workflow

Use a known local FM broadcast as a first receive test. Set a center frequency, sample rate and gain, then inspect a short recording. Keep those parameters with the file. For a sweep, keep track of how long each frequency was observed.

## Limits and interpretation

The upper tuning limit excludes 2.4 GHz Bluetooth and ordinary 2.4/5/6 GHz Wi-Fi. A sweep samples frequencies at different times and can miss bursts. Receiver gain and antenna response affect apparent power.

## Upstream references

[Manufacturer datasheet (PDF)](https://www.rtl-sdr.com/wp-content/uploads/2024/12/RTLSDR_V4_Datasheet_V_1_0.pdf)
