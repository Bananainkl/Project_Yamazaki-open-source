# Yamazaki 0.8.0

Yamazaki 0.8.0 delivers a ground-up redesign of the application's UI, UX, interactions, and fluid animations built natively on the macOS 26+ / macOS 27 SDK Liquid Glass architecture (`@Observable`, `GlassEffectContainer`, `NavigationSplitView`, and `ToolbarSpacer`).

## Highlights

- **Liquid Glass Menu-Bar Control Center**: Left-clicking the menu-bar icon now opens a native Liquid Glass Popover featuring one-click region OCR, region translation, clipboard image OCR, inline recognition profile & scan-direction controls, and an ephemeral in-memory recent history list (up to 8 snippets, never written to disk). Right-clicking preserves the classic compact `NSMenu`.
- **Non-Activating Floating HUD Capsule**: Instant borderless Liquid Glass toast feedback (`recognizing` → `copied` / `empty` / `permissionRequired` / `error`) using `GlassEffectContainer` matched-geometry morphing and SF Symbol animations without stealing keyboard focus.
- **Native Split-View Settings**: Rebuilt around `NavigationSplitView` + `.formStyle(.grouped)` with three-state semantic tokens (`Light`, `Dark`, `Increased Contrast` + `Reduce Transparency` + `Reduce Motion`), keycap shortcut recorders, visual scan-direction cards, discrete typography slider with live preview, and full keyboard/VoiceOver accessibility.
- **Dual-Mode Translation Studio**: Switch seamlessly between **Split Compare** (original screenshot with interactive bounding-box highlight synchronization alongside streaming translation cards) and **In-Place Overlay** (zoomable material pills anchored to source regions), with live target-language switching.
- **Resilient Local OCR Engine**: Modularized `FreeScanOCR` architecture preserving `v0.7.5` `--ocr-worker` subprocess isolation and idle background self-healing on macOS 27.

Minimum system requirement is now **macOS 26.0+**. Replacing an older ad-hoc-signed build in `/Applications/Yamazaki.app` may prompt macOS once to re-confirm Screen Recording access.
