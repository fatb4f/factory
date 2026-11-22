# Pixel and Chromebook integration

The baseline pairs an unrooted Pixel 7 with a stock ASUS Chromebook Plus CX34. Use the Pixel for eyes-free voice input, the CX34 as a desk terminal, and the KVM host for shared development. Use Crostini when the laptop needs to run Python locally. See [platform findings](platform.md) and the [device and power checks](validation.md).

| Layer | Owner | Normal operation |
| --- | --- | --- |
| Audio and voice | Pixel 7 with USB earbuds | Keep the microphone and ChatGPT audio on the Pixel while changing the compute target. |
| Unlock and accessibility | Each device's operating system | Pixel Face Unlock with Skip lock screen, Voice Access for commands, and TalkBack for feedback. Chromebook uses ChromeVox and can use Smart Lock with the already-unlocked, nearby Pixel when configured. |
| Desk and mobile terminals | ChromeOS Secure Shell and Termux OpenSSH | Connect independently to the same SSH host. Secure Shell can run with Crostini off. |
| Interactive session | KVM host | Run tmux and Xonsh on the host. Both clients can reattach to the same session. |
| Source and task state | GitHub and host-local Git worktrees | GitHub holds committed history. Each host owns its checkout and working changes. One task branch and worktree per active change in a repository. |
| Python environment | Each worktree | Recreate the environment from the repo's Python pin, `pyproject.toml`, and `uv.lock`. Keep a local `.venv` per worktree. |

## Device handoff

1. Pair the Pixel in ChromeOS Connected devices and test Smart Lock with the same Google account, Bluetooth enabled, and the phone unlocked. Verify whether a Chromebook confirmation is required. ChromeVox provides spoken output on the laptop.
2. With USB earbuds on the Pixel, test Face Unlock in the usual lighting and phone position. Enable Skip lock screen, Voice Access, and TalkBack. Test waking the phone and opening, starting, and ending a ChatGPT voice session. Reboot and low-light cases may need the device credential or another unlock method. The Pixel 6 has fingerprint unlock and lacks stock Face Unlock.
3. Open Secure Shell on the Chromebook or OpenSSH in Termux on the Pixel. After connecting to the KVM, open or resume `tmux new-session -A -s factory`. Verify the selected worktree before issuing commands. Disconnect one client and reattach from the other.
4. Keep device input, assistant conversation, and execution target as independent choices. The SSH handoff preserves the terminal session while the host stays running. An assistant must be explicitly connected to the desired workspace by its supported workflow.

## Repository and Python workflow

Keep one clone per repo on each host where a local checkout is needed. Different repositories have independent clones. Use linked worktrees for concurrent tasks in the same repo. Follow the [Factory task workflow](../codex-github-workflow.md) for branch naming and integration.

For each session, report the host, repo remote, branch, commit, worktree path, dirty status, and Python version. For remote workers on separate hosts, push a checkpoint or hand off a reviewed patch. A worktree path, unfinished edits, and tmux live state belong to the originating host.

Use `uv sync --locked` to provision per-worktree dependencies and `uv sync --check --locked` to verify the environment without syncing. Use `uv run --locked` when running project tools with sync allowed. Xonsh can provide the interactive commands. If discovery becomes repetitive, prototype a thin Python GitHub API adapter for repo metadata and delegate clone/worktree operations to Git. SSH starts or attaches to the host session. Reuse the existing Termux/Conch tooling where it fits.

## Sources

- [Pixel Face Unlock](https://support.google.com/pixelphone/answer/9517039)
- [Android Voice Access](https://support.google.com/accessibility/android/answer/6151848)
- [Android TalkBack](https://support.google.com/accessibility/android/answer/6283677)
- [ChromeOS Smart Lock](https://support.google.com/chromebook/answer/9617782) and [ChromeVox](https://support.google.com/chromebook/answer/7031755)
- [Chromium Secure Shell](https://chromium.googlesource.com/apps/libapps/) and [tmux](https://github.com/tmux/tmux)
- [uv locking and syncing](https://docs.astral.sh/uv/concepts/projects/sync/)
