# Device and power checks

These are proposed checks. Device-specific results are pending.

## Accessibility and continuity

| Trial | Pass condition |
| --- | --- |
| Pixel everyday unlock | Wake and face-unlock with the phone positioned as normally used, then open ChatGPT by voice and receive audible confirmation. Record touches and screen glances. |
| Voice microphone handoff | Start and end a voice conversation, then successfully issue a Voice Access command. Repeat with earbuds reconnected. |
| Pixel exceptions | Repeat in low light and after a reboot. Record when credential or fingerprint fallback is needed. |
| ChromeOS pairing | Test Smart Lock with the nearby Pixel unlocked, then again locked or out of range. Record prompts, required touches, and spoken feedback. |
| Session handoff | Start a long-running command in KVM tmux from the Chromebook. Disconnect, reconnect from the Pixel, and verify the same process, host, branch, commit, and worktree. Repeat in reverse. |
| Offline fallback | In Crostini, use a prehydrated Python environment and run a representative project command with network disconnected. Record which dependencies required advance setup. |
| Cross-host environment parity | Run the same repo command on KVM and Crostini with the same commit, Python version, lockfile, and dependency groups. Record exit status and output differences. |

## Laptop battery

Use [ChromeOS Diagnostics](https://support.google.com/chromebook/answer/10566784) for host battery readings. For each run, unplug the CX34, hold display brightness and network steady, use the same foreground tabs, and start within a comparable battery charge band. Let startup activity settle before idle readings.

| State | Trial |
| --- | --- |
| VM off | Idle on ChromeOS with Termina stopped. |
| VM idle | Repeat with Termina running and local project apps idle. |
| Local job | Run a fixed Python workload in Crostini. |
| Remote job | Run the same commit, input, and command on the KVM over Secure Shell with Termina off. Include any usual input/output transfer time. |

Use equal windows for the idle cases and the same number of completed jobs for the workload cases. Repeat each case at least three times and alternate order. If the reading is too coarse, lengthen the window or repeat the job in a batch.

Record ChromeOS version, battery health, state, start/end charge, elapsed time, discharge rate or energy if available, job result, and notes. Report median and spread for idle discharge per hour and laptop battery cost per completed job. Keep reported units and avoid converting percentage points to watt-hours without a recorded capacity assumption. The offload test measures CX34 battery use. KVM energy would require separate host measurements.
