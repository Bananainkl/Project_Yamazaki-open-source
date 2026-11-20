# Changelog

## 0.8.1 - 2026-11-20

- Replace `NSPopover` in the menu-bar Control Center with a screen-clamped floating `NSPanel` (`MenuBarControlPanelController`) so the panel top edge never overflows above the macOS menu bar or notch on macOS 27, and ensure first-click button responsiveness (`acceptsFirstMouse`).
- Fix Screen Recording permission requesting across rebuilt binaries by invoking `CGRequestScreenCaptureAccess()` once per process when preflight fails and automatically preferring a local `Apple Development` code-signing identity during local builds when available.
- Temporarily suspend global Carbon hotkeys while recording shortcuts in Settings so re-binding existing shortcuts does not trigger capture, and prevent ARC over-release when closing the Translation Studio window.

## 0.8.0 - 2026-11-20

- Redesign the entire application UI, UX, interactions, and animations targeting the native macOS 26+ / macOS 27 SDK Liquid Glass design system (`Glass`, `.glassEffect`, `GlassEffectContainer`, `.buttonStyle(.glass)` / `.buttonStyle(.glassProminent)`, `ToolbarSpacer`, and `@Observable`).
- Upgrade the menu-bar left-click experience to a Liquid Glass Control Center Popover with primary OCR/translation/clipboard cards, inline language profile and scan direction switchers, and an in-memory recent OCR history list with one-click re-copy (while preserving right-click native `NSMenu`).
- Add a non-activating Floating HUD Capsule (`NSPanel`) with matched-geometry Liquid Glass transitions and SF Symbol bounce effects for instant post-capture feedback.
- Rebuild the Settings window with `NavigationSplitView`, `.formStyle(.grouped)`, unified toolbar status badge, physical keycap shortcut recorders, interactive scan-direction cards, and live typography/layout preview while restoring full keyboard focus and VoiceOver navigation.
- Introduce the dual-mode Translation Studio (`Split Compare` with synchronized bounding-box highlights + streaming translation cards, and `In-Place Overlay` with zoomable material pills) plus live target-language re-translation.
- Modularize `FreeScanOCR` into `App`, `DesignSystem`, `Models`, `Services`, and `Views` while preserving the `v0.7.5` `--ocr-worker` subprocess isolation and idle background self-healing architecture.

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
