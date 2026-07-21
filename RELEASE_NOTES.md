# Yamazaki 0.6.9

This release fixes duplicate app processes caused by enabling automatic restart while Yamazaki was already running.

## Changes

- Auto-restart now uses a lightweight watchdog that checks whether Yamazaki is already running before reopening it.
- A second application-level guard rejects later duplicate launches.
- Existing `com.itou.yamazaki.keepalive` launch agents are migrated to the new watchdog configuration.
- Local install scripts stop launch agents before replacing the app bundle.

Third-party screenshot applications are not included in this source repository or its DMG workflow.
