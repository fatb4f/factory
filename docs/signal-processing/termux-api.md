# Termux:API

The official Android add-on and its Termux client package expose selected Android APIs to shell scripts, including Wi-Fi and cellular observations.

## What you need

Install the add-on from the same signing source as the main Termux app, install the `termux-api` client package, and grant relevant Android permissions.

## Measurement workflow

Use `termux-wifi-connectioninfo` for the current association, `termux-wifi-scaninfo` for visible scan results, and `termux-telephony-cellinfo` for available cellular records. Record the collection time and keep the original JSON. Compare the fields that actually exist across two runs.

## Limits and interpretation

Operating-system permissions, caching, scan throttling and modem support affect results. A new shell invocation can return an earlier scan. These interfaces expose OS observations rather than Wi-Fi frames, raw cellular signaling, or I/Q samples.

## Upstream references

[Official Android add-on](https://github.com/termux/termux-api) · [Official client commands](https://github.com/termux/termux-api-package/blob/master/CMakeLists.txt)
