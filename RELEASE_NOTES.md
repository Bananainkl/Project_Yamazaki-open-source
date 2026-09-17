# Yamazaki 0.7.0

This release restores Yamazaki OCR compatibility after upgrading to macOS 27.

## Changes

- Rebuilt with Xcode 27 and the macOS 27 SDK for the updated system text-recognition engine.
- Build caches are isolated by SDK version and stored outside FileProvider-backed folders.
- Release packaging strips extended metadata and verifies the app signature before creating the DMG.
- Verification mode now launches the exact newly built bundle.

After replacing an older ad-hoc-signed build, macOS may require Screen Recording access to be granted again. See the included installation guide for the reset command and permission steps.

Third-party screenshot applications are not included in this source repository or its DMG workflow.
