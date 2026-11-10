---
name: apple-release-verify
description: Verify Apple release artifacts, relevant signing, entitlements, packaging and release journeys using official tools, without publishing or modifying signing configuration.
license: MIT; see LICENSE
compatibility: Approved macOS release worker, Xcode, distribution profile and separately authorized signing identity access.
---

# Apple release verification

Inputs: approved distribution route, exact candidate artifact plus trusted
source/build/input identity, expected bundle inventory/entitlements, required
release scenarios and a run-owned evidence directory. Read these from consumer
policy/local verification; missing inputs block the applicable stage.
Native execution remains unverified on Linux. No upload/publication is authorized.

1. Default to verifying the supplied candidate without rebuilding or modifying it.
   Check its authenticated release manifest and source/toolchain/dependency locks.
   Hash file containers with the approved algorithm. An app directory requires
   the consumer's canonical tree manifest (paths, bytes, modes and symlink targets),
   not a hash of an arbitrary zip. Never silently substitute a rebuilt app.
2. Only when preparing a new candidate is in scope, run `apple-build-verify` with
   the approved archive/test configuration, locked dependencies and isolated
   DerivedData. This creates a distinct candidate ID. Read installed xcodebuild
   help and export options. Require the plist's destination to be explicitly
   `export`, rejecting `upload`, missing or unknown values before -exportArchive.
   Do not change signing settings, create credentials or enable automatic upload.

```sh
xcodebuild -workspace "$APPLE_WORKSPACE" -scheme "$APPLE_SCHEME" \
  -configuration "$APPLE_ARCHIVE_CONFIGURATION" \
  -destination "$APPLE_ARCHIVE_DESTINATION" \
  -derivedDataPath "$APPLE_DERIVED_DATA" -archivePath "$APPLE_ARCHIVE_PATH" archive
xcodebuild -exportArchive -archivePath "$APPLE_ARCHIVE_PATH" \
  -exportOptionsPlist "$APPLE_EXPORT_OPTIONS" -exportPath "$APPLE_EXPORT_DIRECTORY"
```

3. Inspect the actual final exported container. Unpack IPA/PKG/DMG only into
   run-owned locations using an approved installed-tool procedure; never run an
   installer to inspect it. Verify the complete expected code inventory, including
   app/appex/framework/XPC/login/helper/system-extension/dylib payloads. Missing
   package-specific extraction or inspection procedures block that route.
   Read installed codesign/spctl help; repeat identity/entitlement inspection for
   every relevant nested signed component, not only the top-level app:

```sh
codesign --verify --deep --strict --verbose=2 "$APPLE_APP_BUNDLE"
codesign --display --entitlements - "$APPLE_APP_BUNDLE"
codesign --display --verbose=4 "$APPLE_APP_BUNDLE"
```

4. Compare actual provisioning, App Groups, sandbox and Safari permissions with
   independent expectations. Developer ID verification requires an already
   notarized/stapled candidate and its authorized release-owner evidence.
   Missing notarization blocks; never improvise notarytool submission or upload.
   Apply the declared app/install/open Gatekeeper assessment and staple checks.
   Hash the final bytes after any separately authorized stapling/transformation;
   bind those hashes to the exact candidate and invalidate earlier artifact results.
5. Follow the approved installation/distribution route for final-artifact smoke
   and device checks. `xcodebuild test` normally builds a separate test product:
   that is source-built evidence, not proof of the exported candidate. App Store
   iOS artifacts need a supported distribution-stage installation. Report that
   stage blocked until separately authorized delivery and observation exist;
   never upload to TestFlight/App Store implicitly. Missing required sibling
   workflows (`apple-smoke-test`, `apple-device-matrix`) block those checks.
6. Where signing prevents attach/performance measurement, use an approved
   source/toolchain-matched profile build only for explicitly approved surrogate
   metrics. Record signing/entitlement/input differences and representation limits.
   Never label surrogate measurements as final-artifact evidence or relax signing.
7. Retain final artifact/tree digest, source/input identity, per-component signing
   output, export diagnostics, installation route and scenario results. Distinguish
   completed offline preflight from blocked distribution-stage checks. Redact
   private data and remove only run-owned scratch material, retaining evidence.

Acceptance: the exact candidate passes its approved distribution and release
checks, with no missing required evidence; no publication is performed.
[Provenance and hashes](provenance.json).
Archive/export reference: [Apple workflow](https://developer.apple.com/documentation/security/customizing-the-notarization-workflow).
