---
name: apple-release-verify
description: Verify Apple release artifacts, relevant signing, entitlements, packaging and release journeys using official tools, without publishing or modifying signing configuration.
license: MIT; see LICENSE
metadata:
  compatibility: Approved macOS release worker, Xcode, distribution profile and separately authorized signing identity access.
---

# Apple release verification

Inputs: approved source revision, distribution route, archive/bundle, expected
bundle IDs/entitlements, release tests/matrix and run-owned evidence directory.
Native release execution remains unverified on Linux.

1. Use `apple-build-verify` for an approved Release configuration and native
   archive/export test procedure. Verify exact source/artifact identity. Do not
   change signing settings, create credentials, publish, or release implicitly.
2. Inspect installed `codesign`/`spctl` help and verify the built bundle:

```sh
codesign --verify --deep --strict --verbose=2 "$APPLE_APP_BUNDLE"
codesign --display --entitlements :- "$APPLE_APP_BUNDLE"
codesign --display --verbose=4 "$APPLE_APP_BUNDLE"
```

3. Compare effective identities, provisioning/entitlements and nested app/extension
   signatures with approved expectations, including App Groups, sandbox and Safari
   permissions. A valid signature alone does not establish correct capabilities.
4. For a Developer ID macOS artifact, run its declared Gatekeeper assessment
   (`spctl --assess --type execute --verbose "$APPLE_APP_BUNDLE"`). If a notarized
   release is required, inspect `xcrun stapler` help and validate its staple ticket.
   App Store/iOS routes use their own approved export/provisioning checks; do not
   apply Developer ID assumptions to every distribution channel.
5. Run release-specific user journeys and required physical compatibility rows
   through `apple-smoke-test` and `apple-device-matrix`; require applicable
   `apple-performance` evidence for the final artifact/configuration.
6. Retain artifact digest, source/toolchain identity, signature/entitlement output,
   export diagnostics and test results with private signing data redacted.
   Remove only run-owned temporary material; never export private keys as evidence.

Acceptance: the exact candidate passes its approved distribution and release
checks, with no missing required evidence; no publication is performed.
[Provenance and hashes](provenance.json).
