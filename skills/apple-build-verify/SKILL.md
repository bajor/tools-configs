---
name: apple-build-verify
description: Build and test approved iOS, macOS, and Safari native targets, inspect native failures and result bundles, and collect reproducible verification evidence.
license: MIT; see LICENSE
compatibility: macOS with the repository-approved Xcode and SDKs; interactive MCP requires approved Xcode access.
---

# Apple build verification

Inputs: approved source revision, target manifest, local verification skill,
scenario/test plan, configuration, destination, and unique evidence directory.
Resolve these inputs from the consumer's AGENTS.md, project configuration and
local verification skill; a target manifest means that existing target/scheme/
configuration/destination inventory, not a required new file format. Missing
required inputs block the run. Do not fabricate expected tests or scenarios.
Recipes require installed-tool validation; none ran on this Linux host.

1. Record `git rev-parse HEAD`, dirty status, `xcodebuild -version`, SDKs,
   developer directory and destination inventory. Confirm every pin matches.
   Release/CI evidence requires a clean independently materialized source tree.
   For local dirty-tree diagnosis, retain a private binary diff against HEAD and
   an untracked-file path/digest inventory; identify results by HEAD plus those
   digests, never by HEAD alone. Include the actual build-input closure, including
   relevant ignored/generated inputs and configuration. If it cannot be
   identified, evidence is diagnostic only and cannot authorize release or CI.
   Exclude sensitive artifacts from public uploads.
   Inspect `man xcodebuild`, `xcrun simctl help` and `man xcresulttool` before
   using version-dependent options. Missing required SDK/tool/device blocks the run.
   Require recorded dependency locks/resolved versions and help-qualified locked
   resolution flags. A tool that re-resolves dependencies without review blocks
   reproducibility; never update locks or fetch new versions implicitly.
2. For supported interactive work, use Apple's `xcrun mcpbridge` connection.
   Use an already approved connection; this workflow does not authorize MCP,
   IDE permission or account configuration changes. If unavailable, use official
   CLI for supported actions and report blocked interactive-only capabilities.
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
   consumer-declared compiler, architecture, property and other checks unchanged.
5. Diagnose exact failures before authorized repairs. Preserve the consumer's
   state/effect boundaries; do not silence concurrency failures or weaken gates.
   After any repair, refresh source/input identity and rerun affected commands
   before attributing acceptance to the repaired bytes.
6. Retain revision, command arguments, toolchain, destination, test results and
   artifact hashes. Clean only run-owned temporary resources after collection.

Acceptance: every required command and expected test passes for the recorded
source identity, with inspectable artifacts. Required failed/skipped/missing tests
block. Policy-declared optional or platform-inapplicable tests are reported with
their reasons; they cannot satisfy a mandatory scenario.
Upstream sources and integrity inventory: [provenance.json](provenance.json).
Official references: [Apple CLI](https://developer.apple.com/documentation/xcode/xcode-command-line-tool-reference),
[external-agent access](https://developer.apple.com/documentation/xcode/giving-external-agents-access-to-xcode).
