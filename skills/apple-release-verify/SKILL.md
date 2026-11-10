---
name: apple-release-verify
description: Verify Apple release artifacts, relevant signing, entitlements, packaging and release journeys using official tools, without publishing or modifying signing configuration.
license: MIT; see LICENSE
compatibility: Approved macOS release worker, Xcode, distribution profile and separately authorized signing identity access.
---

# Apple release verification

Inputs: approved source revision, distribution route, archive/bundle, expected
bundle IDs/entitlements, release tests/matrix and run-owned evidence directory.
Native release execution remains unverified on Linux.

1. Require a clean source snapshot and run the consumer's Release test plan via
   `apple-build-verify`. Read installed `xcodebuild` help and the approved export
   options before archiving. Use new run-owned paths and existing authorized
   signing access; do not change signing configuration, credentials or publish.

```sh
xcodebuild -workspace "$APPLE_WORKSPACE" -scheme "$APPLE_SCHEME" \
  -configuration Release -destination "$APPLE_ARCHIVE_DESTINATION" \
  -archivePath "$APPLE_ARCHIVE_PATH" archive
xcodebuild -exportArchive -archivePath "$APPLE_ARCHIVE_PATH" \
  -exportOptionsPlist "$APPLE_EXPORT_OPTIONS" -exportPath "$APPLE_EXPORT_DIRECTORY"
```

2. Hash and inspect the actual exported package, not a DerivedData test product.
   For iOS, unpack the exported IPA into a run-owned directory using installed
   official archive tools. Enumerate every contained app/appex/framework and
   compare expected identities. Inspect installed `codesign`/`spctl` help:


```sh
codesign --verify --deep --strict --verbose=2 "$APPLE_APP_BUNDLE"
codesign --display --entitlements - "$APPLE_APP_BUNDLE"
codesign --display --verbose=4 "$APPLE_APP_BUNDLE"
```

3. Repeat signature, identity and entitlement inspection for each nested app and
   extension, including provisioning, App Groups, sandbox and Safari permissions.
   Verify every expected bundle is present. A top-level signature or entitlement
   display cannot establish nested capabilities. Retain each bundle's output.
4. Apply distribution-specific checks to the exported container. Developer ID
   requires the declared notarization/stapling and Gatekeeper evidence. Inspect
   installed help: app assessment uses `spctl --assess --type execute`; a PKG
   needs `pkgutil --check-signature` and install assessment; a DMG needs its
   declared open assessment and staple validation. Record the assessed source
   and reject an unexpected signing/notarization route. Missing package-specific
   procedures block release. App Store/iOS use approved provisioning/export checks.
5. Run release-specific user journeys and required physical compatibility rows
   through available `apple-smoke-test` and `apple-device-matrix` workflows.
   Require final exported-artifact smoke evidence. Where distribution signing
   prevents attach/profiling, identify the source/toolchain-matched profile build,
   its signing/entitlement differences and approved representativeness limits.
   Never attribute that trace to the final artifact or change release signing.
6. Retain artifact digest, source/toolchain identity, signature/entitlement output,
   export diagnostics and test results with private signing data redacted.
   Remove only run-owned temporary material; never export private keys as evidence.

Acceptance: the exact candidate passes its approved distribution and release
checks, with no missing required evidence; no publication is performed.
[Provenance and hashes](provenance.json).
Archive/export reference: [Apple workflow](https://developer.apple.com/documentation/security/customizing-the-notarization-workflow).
