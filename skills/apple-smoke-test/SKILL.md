---
name: apple-smoke-test
description: Exercise application-specific iOS, macOS and Safari journeys on approved destinations, assert observable behavior, and retain native UI-test and screenshot evidence.
license: MIT; see LICENSE
metadata:
  compatibility: Approved native Apple build and test destination; actual UI actions depend on installed official capabilities.
---

# Apple smoke testing

Inputs: local verification skill/feature map, approved scenario IDs and assertions,
revision/build, destination, fixture/reset procedure and evidence directory.
Native execution remains unverified on Linux; screenshots alone are insufficient.

1. Resolve access path, preconditions, expected state transitions and required
   hardware from the feature map. Require independent requirement/contract IDs;
   do not rewrite expectations to match the implementation being tested.
2. Use `apple-build-verify` to build and run the declared smoke test plan with
   XCUITest through `xcodebuild`. Require expected tests to be discovered/executed.
   Interactive exploration uses advertised official Xcode MCP UI actions. If an
   action is unavailable, use an existing XCUITest scenario or report the gap.
   `simctl` is not a general tap, typing or accessibility-tree replacement.
3. Start with known fixtures and record permission/account state. Exercise the
   declared journey, asserting visible outcomes and relevant persisted state.
   Capture XCUITest attachments, logs and screenshots at meaningful transitions;
   include denial, cancellation and relaunch paths when the scenario requires them.
4. For Safari, verify extension enablement and host permissions on the actual
   target. Distinguish content script, background/service worker, native app
   extension and containing app. Test background unload/restart and the containing
   app not running; do not assume iOS containing-app push to JavaScript exists.
5. Record source/build identity, scenario/test IDs, destination/OS, fixture digest,
   assertions and native result bundles. Link artifacts to the CI run/Entire change
   when available; do not upload browsing content or personal data by default.
6. Reset only run-owned fixture/device state after evidence collection. Do not
   modify personal Safari settings or erase shared devices as a cleanup shortcut.

Acceptance: all mandatory observable assertions pass with current executed
evidence. Launch-only, reused screenshots, missing journeys or unavailable
required devices block. [Provenance and hashes](provenance.json).
Safari reference: [native messaging](https://developer.apple.com/documentation/safariservices/messaging-between-the-app-and-javascript-in-a-safari-web-extension).
