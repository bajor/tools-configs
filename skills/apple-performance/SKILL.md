---
name: apple-performance
description: Capture reproducible Instruments and XCTest measurements for native Apple startup, responsiveness, CPU, memory and model inference, and compare source-pinned baselines without hiding uncertainty.
license: MIT; see LICENSE
metadata:
  compatibility: Approved macOS/Xcode profiling environment; hardware-sensitive claims require physical target devices.
---

# Apple performance verification

Inputs: feature-map performance scenario, baseline/candidate revisions, approved
budget/comparison method, fixtures/model hashes and physical-device configuration.
Read the adapted [profiling workflow](references/profiling-workflow.md).
No Apple profile or measurement was executed on this Linux host.

1. Discover installed Instruments templates/devices using `xcrun xctrace` after
   reading `man xctrace`. Record exact toolchain, template and export schema.
   Build source-matched Release/profile artifacts and retain symbols.
2. Verify installed help supports the recording recipe, select the approved
   template/device, launch the fixed scenario and attach to its recorded process:

```sh
xcrun xctrace record --template "$APPLE_TRACE_TEMPLATE" \
  --device "$APPLE_TRACE_DEVICE" --attach "$APPLE_PID" \
  --time-limit "$APPLE_TRACE_DURATION" --output "$APPLE_TRACE_PATH"
```

3. Record CPU, allocations/memory, startup, hitches/rendering/main-thread work,
   model load/inference signposts and relevant disk/network/energy/thermal data
   only where supported. Run declared XCTest metric scenarios as appropriate.
   Export required tables with installed schema-aware commands; reject empty or
   incompatible exports. Retain original traces, results, symbols and raw samples.
4. Compare paired baseline/candidate runs on the same device/OS/configuration,
   fixture, power/thermal state and background workload. Record warmups,
   repetitions, variability and the approved thresholds. Noise or missing samples
   produces an inconclusive result under the declared bounded rerun policy.
5. Use simulator captures for diagnosis, never hardware performance claims.
   Attribute suspected SwiftUI invalidation/identity/main-thread work using traces
   before changing it; verify a repair by repeating the identical scenario.
6. Stop only run-owned capture processes and restore their fixtures after upload
   or retention. Never publish private model inputs or browsing content in traces.

Acceptance: comparable measurements meet the independently approved policy with
source/device identity and inspectable evidence; missing required metrics or
unresolved noise blocks the applicable performance gate. [Provenance](provenance.json).
