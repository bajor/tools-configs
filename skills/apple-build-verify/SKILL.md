---
name: apple-build-verify
description: Build and test approved iOS, macOS, and Safari native targets, inspect native failures and result bundles, and collect reproducible verification evidence.
license: MIT; see LICENSE
metadata:
  compatibility: macOS with the repository-approved Xcode and SDKs; interactive MCP requires approved Xcode access.
---

# Apple build verification

Inputs: approved source revision, target manifest, local verification skill,
scenario/test plan, configuration, destination, and unique evidence directory.
Recipes require validation against the installed tools; none ran on this Linux host.

1. Record `git rev-parse HEAD`, dirty status, `xcodebuild -version`, SDKs,
   developer directory and destination inventory. Confirm every pin matches.
   Inspect `man xcodebuild`, `xcrun simctl help` and `man xcresulttool` before
   using version-dependent options. Missing required SDK/tool/device blocks the run.
2. For supported interactive work, use Apple's `xcrun mcpbridge` connection.
   Inspect its actual tools/schema and target identity before invoking capabilities.
   Do not infer tools from third-party names or introduce another Xcode server.
   Unattended CI uses native CLI tools without an MCP/IDE session dependency.
3. Read target/scheme/test-plan identifiers from approved project configuration.
   Set the variables below to explicit manifest values and unused run-owned paths.
   For a project without a workspace use its approved `-project` alternative.

```sh
xcodebuild -workspace "$APPLE_WORKSPACE" -scheme "$APPLE_SCHEME" \
  -configuration "$APPLE_CONFIGURATION" -destination "$APPLE_DESTINATION" \
  -testPlan "$APPLE_TEST_PLAN" -derivedDataPath "$APPLE_DERIVED_DATA" \
  -resultBundlePath "$APPLE_RESULT_BUNDLE" test
```

4. Preserve the command's exit status and raw output. Inspect the result bundle
   with installed `xcresulttool` help-confirmed commands: record test identities,
   counts, failures, attachments and diagnostics. A saved bundle or zero tests
   does not prove a passing test run. Run the local verification skill's required
   compiler, architecture, zero-comment, property and mutation checks unchanged.
5. Diagnose exact failures before repairs. Preserve immutable domain inputs and
   explicit effect/state owners; do not silence concurrency failures or weaken gates.
6. Retain revision, command arguments, toolchain, destination, test results and
   artifact hashes. Clean only run-owned temporary resources after collection.

Acceptance: every required command and expected test passes for the recorded
revision, with inspectable artifacts; failed, skipped or missing evidence blocks.
Upstream sources and integrity inventory: [provenance.json](provenance.json).
Official references: [Apple CLI](https://developer.apple.com/documentation/xcode/xcode-command-line-tool-reference),
[external-agent access](https://developer.apple.com/documentation/xcode/giving-external-agents-access-to-xcode).
