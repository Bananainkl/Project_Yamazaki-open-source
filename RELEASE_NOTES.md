# Yamazaki 0.7.1

This release hardens OCR on macOS 27 when a captured screenshot carries an image representation that Vision cannot read directly.

## Changes

- Captured images are normalized to an opaque RGB bitmap before OCR.
- Vision OCR retries once with a bounded 4096px image after a reader failure and logs the retry outcome locally.
- The install script preserves strict code-signature verification when copying the app into `/Applications`.

Replacing an older ad-hoc-signed build may require Screen Recording access to be granted again.

---

# Yamazaki 0.7.0

This release restores Yamazaki OCR compatibility after upgrading to macOS 27.

## Changes

- Rebuilt with Xcode 27 and the macOS 27 SDK for the updated system text-recognition engine.
- Build caches are isolated by SDK version and stored outside FileProvider-backed folders.
- Release packaging strips extended metadata and verifies the app signature before creating the DMG.
- Verification mode now launches the exact newly built bundle.

After replacing an older ad-hoc-signed build, macOS may require Screen Recording access to be granted again. See the included installation guide for the reset command and permission steps.

Third-party screenshot applications are not included in this source repository or its DMG workflow.
