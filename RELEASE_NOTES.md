# Yamazaki 0.7.5

This release eliminates recurring macOS 27 `TextRecognition.CRImageReaderError` stalls in long-running menu-bar sessions by isolating fallback OCR in a short-lived worker subprocess and self-healing the resident process when idle.

## Changes

- Add an isolated `--ocr-worker` subprocess execution path that completes OCR and screenshot translation cleanly whenever the resident process encounters a stale `TextRecognition` / `E5RT` runtime state.
- Schedule an automatic, focus-preserving background relaunch when idle (with a 60-second cooldown) so subsequent requests return to the fast in-process path.
- Harden `screencapture` process tracking, async task cancellation tokens, and startup temporary file cleanup.
- Expand automated `VisionOCRSupportTests` coverage for worker CLI serialization, subprocess timeouts, and degraded-runtime failover.

The app remains local and clipboard-first. Replacing an older ad-hoc-signed build may require Screen Recording access to be granted again.
