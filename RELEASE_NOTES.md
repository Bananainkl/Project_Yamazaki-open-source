# Yamazaki 0.8.1

Yamazaki 0.8.1 fixes a critical macOS 27 `NSPopover` positioning regression where the menu-bar Control Center could expand above the top edge of the display, and improves Screen Recording permission persistence and shortcut recording reliability.

## Changes

- **Screen-Clamped Menu-Bar Control Center**: Replace `NSPopover` with a dedicated `MenuBarControlPanelController` (`NSPanel` + `NSVisualEffectView` `.popover` material + `FirstMouseHostingView`) whose top edge is strictly clamped below both the status item and `NSScreen.visibleFrame.maxY`, eliminating header clipping and `_NSGlassEffectWindow` warnings.
- **Reliable Permission & Signing Flow**: Request Screen Recording access once per process when `CGPreflightScreenCaptureAccess()` returns `false` instead of suppressing system prompts behind a stale `UserDefaults` flag, and automatically sign local builds with an `Apple Development` identity when available in Keychain (while keeping distributable DMGs ad-hoc signed).
- **Shortcut Recorder & Window Lifecycle Hardening**: Pause global Carbon hotkeys during Settings shortcut recording and mark the Translation Studio window `isReleasedWhenClosed = false`.
