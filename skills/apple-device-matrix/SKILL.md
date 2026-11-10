---
name: apple-device-matrix
description: Verify declared Apple application compatibility across available simulators, physical devices, macOS and Safari configurations, and report missing required matrix entries as blockers.
license: MIT; see LICENSE
metadata:
  compatibility: Approved macOS workers, Xcode runtimes and paired physical devices for the requested matrix tier.
---

# Apple device matrix

Inputs: approved platform/target metadata, feature-map scenarios, PR/scheduled/
release tier, required device/OS/configuration rows and evidence directory.
The matrix and native commands remain unexecuted on Linux.

1. Compare declared platforms with actual project targets, extension entitlements
   and package/platform declarations. A mismatch blocks selection; names alone
   do not determine whether a repository contains Apple targets.
2. Record `xcodebuild -version`, `xcodebuild -showsdks` and simulator inventories:

```sh
xcrun simctl list devices --json
xcrun simctl list runtimes --json
xcrun devicectl help
```

3. Inspect installed `devicectl` help for supported physical-device listing and
   operations; record pairing/Developer Mode/signing prerequisites. Match exact
   destination identifiers and runtime versions to approved rows. Never replace
   an unavailable row with a newer OS or simulator without a reviewed decision.
4. Run fast declared simulator/Mac journeys on PRs; use extended OS/screen-size,
   iPhone/iPad orientation, Safari/profile, accessibility and language rows on
   scheduled/release runs. Only select configurations supported by the shipped app.
   Use `apple-smoke-test` for journeys and `apple-performance` for physical-device
   hardware metrics; a simulator cannot establish device energy/GPU/thermal behavior.
5. Record each row's tests, outcomes, device/OS/Xcode, scenario/build hashes and
   artifacts. Required unavailable, skipped or inconclusive rows block that tier;
   optional coverage remains explicitly reported without being counted as executed.
6. Shut down/delete only simulators created by this run after collecting artifacts.
   Restore run fixtures; quarantine failed cleanup resources before reuse.

Acceptance: all required matrix rows have executed, source-matched passing
evidence; inventory, permission or cleanup failures remain visible.
[Provenance and hashes](provenance.json).
