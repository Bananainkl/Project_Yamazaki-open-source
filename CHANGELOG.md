# Changelog

## 0.7.5 - 2026-11-20

- Add an isolated `--ocr-worker` subprocess fallback so OCR and screenshot translation keep working when the long-lived menu-bar process hits a stale macOS 27 `TextRecognition` / `E5RT` handle.
- Automatically schedule a non-disruptive idle background relaunch after subprocess recovery to restore a clean in-process OCR runtime without interrupting active windows or stealing focus.
- Harden capture process lifecycle, task cancellation tokens, and stale temporary file cleanup.
- Expand unit and subprocess resilience test coverage in `VisionOCRSupportTests`.

## 0.7.4 - 2026-11-03

- Prefer explicitly assigned Vision CPU compute on macOS 26+ before the system-default TextRecognition path.
- Add repeated regression coverage using the production mixed-language profile and narrow capture dimensions.

## 0.7.3 - 2026-11-02

- Explicitly bind Vision OCR fallback compute stages to CPU using the supported compute-device API.
- Log CPU fallback failures and add a generated-image OCR regression test.

## 0.7.2 - 2026-10-27

- Add a CPU-only Vision fallback for macOS 27 E5/ANE compute-operation failures.
- Exclude a pre-existing duplicate source copy that prevented SwiftPM builds.

## 0.7.1 - 2026-09-21

- Normalize captured screenshots to an opaque RGB bitmap before Vision OCR.
- Retry once with a bounded image when macOS 27 rejects the original image representation.
- Preserve strict signatures when installing into `/Applications` by avoiding Finder/FileProvider metadata.

## 0.7.0 - 2026-09-17

- Restored OCR compatibility on macOS 27 by rebuilding against Xcode 27 and the macOS 27 SDK.
- Isolated Swift build caches by SDK version so system upgrades cannot silently reuse stale compiler output.
- Moved build caches and DMG staging outside FileProvider-backed project folders to avoid build database and extended-attribute corruption.
- Added strict signature verification and metadata-free DMG staging before release packaging.
- Updated verification launches to open the exact newly built app bundle.

## 0.6.9 - 2026-07-21

- Fixed auto-restart launching a second Yamazaki process when the app was already running.
- Replaced the direct executable LaunchAgent with a lightweight watchdog that checks for an existing instance before reopening the app.
- Added an application-level single-instance guard and migration for the legacy `com.itou.yamazaki.keepalive` LaunchAgent.
- Updated the local build/install script to pause Yamazaki launch agents while replacing the installed app.

## 0.6.8 - 2026-07-20

- Published the initial open-source macOS menu-bar OCR and screenshot-translation source release.
- Added MIT licensing, public documentation, and a redistribution-safe DMG script.
- Removed third-party application bundles from packaging.
