# TorchSig

TorchSig provides RF datasets, signal generation, impairments and transformations for PyTorch experiments.

## What you need

A Python environment for offline experiments and labeled examples for scoring. A held-out real recording is valuable for checking whether a simulated result transfers.

## Measurement workflow

Begin with the same detection task and test split as a simple [GNU Radio](gnu-radio.md) threshold baseline. Vary SNR and include noise-only intervals. Report detection recall and false alarms per minute, with the event-matching rule and test duration.

## Limits and interpretation

An accurate result on synthetic examples may fail under real receiver gain changes, interference or clock error. Dataset labels describe training classes. They do not identify who transmitted a signal.

## Upstream references

[TorchSig project](https://torchsig.com/index.html) · [Toolkit documentation](https://torchsig.readthedocs.io/latest/)
