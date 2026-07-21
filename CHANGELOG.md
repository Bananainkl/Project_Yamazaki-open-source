# Changelog

## 0.6.9 - 2026-07-21

- Fixed auto-restart launching a second Yamazaki process when the app was already running.
- Replaced the direct executable LaunchAgent with a lightweight watchdog that checks for an existing instance before reopening the app.
- Added an application-level single-instance guard and migration for the legacy `com.itou.yamazaki.keepalive` LaunchAgent.
- Updated the local build/install script to pause Yamazaki launch agents while replacing the installed app.

## 0.6.8 - 2026-07-20

- Published the initial open-source macOS menu-bar OCR and screenshot-translation source release.
- Added MIT licensing, public documentation, and a redistribution-safe DMG script.
- Removed third-party application bundles from packaging.
