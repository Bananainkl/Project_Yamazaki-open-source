import AppKit
import SwiftUI

@MainActor
enum VisualQARunner {
  static func captureAllScreens(into directoryPath: String) async {
    NSApp.setActivationPolicy(.regular)
    NSApp.activate(ignoringOtherApps: true)

    let outputDir = URL(fileURLWithPath: directoryPath)
    try? FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)

    let model = AppStateModel()
    model.shortcutText = "⌘2"
    model.translationShortcutText = "⌘3"
    model.status = LocalizedText.tr(.shortcutEnabled, "⌘2")
    model.statusKind = .ready

    let noopActions = SettingsActions(
      startShortcutRecording: {},
      startTranslationShortcutRecording: {},
      cancelShortcutRecording: {},
      setShortcut: { _ in },
      setTranslationShortcut: { _ in },
      resetDefaultShortcut: {},
      resetDefaultTranslationShortcut: {},
      invalidShortcut: {},
      captureSelection: {},
      translateSelection: {},
      recognizeClipboard: {},
      openSettings: {},
      openPermissionSettings: {},
      quitApp: {},
      setMuteSound: { _ in },
      setShowFloatingHUD: { _ in },
      setIgnoreWatermarkText: { _ in },
      setStartAtLogin: { _ in },
      setAutoRestart: { _ in },
      setLanguageMode: { _ in },
      setTranslationLanguage: { _ in },
      setUILanguage: { _ in },
      setTextDirection: { _ in },
      setResultLayout: { _ in },
      setResultFontSize: { _ in },
      copyTextToPasteboard: { _ in }
    )

    // 1. Menu Bar Panel (Empty Light & Populated Dark — auto-fitted height)
    await snapshotWindow(
      rootView: MenuBarPanelView(model: model, actions: noopActions, onDismissPanel: {}),
      size: nil,
      appearanceName: .aqua,
      titled: false,
      to: outputDir.appendingPathComponent("01-menubar-empty-light.png")
    )

    model.recordHistory(
      text: "Yamazaki 采用 macOS 27 原生 Liquid Glass 与 Vision 离线引擎，支持简/繁/英/日混合识别。",
      sourceKind: .regionOCR
    )
    model.recordHistory(
      text: "Swift 6.4 · NavigationSplitView · GlassEffectContainer · Zero Cloud Upload",
      sourceKind: .clipboardOCR
    )

    await snapshotWindow(
      rootView: MenuBarPanelView(model: model, actions: noopActions),
      size: nil,
      appearanceName: .darkAqua,
      titled: false,
      to: outputDir.appendingPathComponent("02-menubar-populated-dark.png")
    )

    // 2. Settings Window (General, Shortcuts, Scan Direction, Typography & Layout)
    await snapshotWindow(
      rootView: SettingsRootView(model: model, actions: noopActions, initialSection: .general),
      size: NSSize(width: 840, height: 620),
      appearanceName: .aqua,
      titled: true,
      title: LocalizedText.tr(.appSettings, ProductInfo.appName),
      to: outputDir.appendingPathComponent("03-settings-general-light.png")
    )

    await snapshotWindow(
      rootView: SettingsRootView(model: model, actions: noopActions, initialSection: .hotKey),
      size: NSSize(width: 840, height: 620),
      appearanceName: .darkAqua,
      titled: true,
      title: LocalizedText.tr(.appSettings, ProductInfo.appName),
      to: outputDir.appendingPathComponent("04-settings-shortcuts-dark.png")
    )

    await snapshotWindow(
      rootView: SettingsRootView(model: model, actions: noopActions, initialSection: .textDirection),
      size: NSSize(width: 760, height: 540),
      appearanceName: .darkAqua,
      titled: true,
      title: LocalizedText.tr(.appSettings, ProductInfo.appName),
      to: outputDir.appendingPathComponent("05-settings-direction-minsize-dark.png")
    )

    await snapshotWindow(
      rootView: SettingsRootView(model: model, actions: noopActions, initialSection: .resultLayout),
      size: NSSize(width: 840, height: 620),
      appearanceName: .aqua,
      titled: true,
      title: LocalizedText.tr(.appSettings, ProductInfo.appName),
      to: outputDir.appendingPathComponent("06-settings-layout-light.png")
    )

    // 3. Floating HUD Capsule
    model.hudState = .copied(charCount: 42, preview: "Yamazaki 离线识别结果已写入剪贴板", eventID: UUID())
    await snapshotWindow(
      rootView: FloatingHUDView(model: model, onAuthorizePermission: {}),
      size: NSSize(width: 460, height: 72),
      appearanceName: .darkAqua,
      titled: false,
      to: outputDir.appendingPathComponent("07-hud-copied-dark.png")
    )

    // 4. Translation Studio (Split Compare Dark & In-Place Overlay Light)
    let sampleImage = makeSampleDocumentImage()
    let line1 = RecognizedTextLine(text: "Native macOS 27 Liquid Glass Architecture", box: CGRect(x: 0.07, y: 0.66, width: 0.78, height: 0.13))
    let line2 = RecognizedTextLine(text: "On-device Vision OCR with isolated subprocess self-healing.", box: CGRect(x: 0.07, y: 0.43, width: 0.82, height: 0.11))
    let line3 = RecognizedTextLine(text: "100% private — screenshots never leave your Mac.", box: CGRect(x: 0.07, y: 0.21, width: 0.74, height: 0.11))
    let sampleLines = [line1, line2, line3]
    let sampleTranslations: [UUID: String] = [
      line1.id: "macOS 27 原生 Liquid Glass 液态玻璃架构",
      line2.id: "设备端离线 Vision 识别，内置独立子进程自愈恢复机制。",
      line3.id: "100% 隐私安全 —— 截图永远不会离开你的 Mac。"
    ]

    await snapshotWindow(
      rootView: TranslationStudioView(
        image: sampleImage,
        lines: sampleLines,
        initialTargetLanguage: .simplifiedChinese,
        prefilledTranslations: sampleTranslations,
        initialDisplayMode: .splitCompare,
        model: model,
        onTargetLanguageChanged: { _ in },
        onCopyText: { _ in }
      ),
      size: NSSize(width: 920, height: 580),
      appearanceName: .darkAqua,
      titled: true,
      title: LocalizedText.tr(.translateSelection),
      to: outputDir.appendingPathComponent("08-translation-split-dark.png")
    )

    await snapshotWindow(
      rootView: TranslationStudioView(
        image: sampleImage,
        lines: sampleLines,
        initialTargetLanguage: .simplifiedChinese,
        prefilledTranslations: sampleTranslations,
        initialDisplayMode: .overlay,
        model: model,
        onTargetLanguageChanged: { _ in },
        onCopyText: { _ in }
      ),
      size: NSSize(width: 920, height: 580),
      appearanceName: .aqua,
      titled: true,
      title: LocalizedText.tr(.translateSelection),
      to: outputDir.appendingPathComponent("09-translation-overlay-light.png")
    )
  }

  private static func snapshotWindow<V: View>(
    rootView: V,
    size: NSSize?,
    appearanceName: NSAppearance.Name,
    titled: Bool,
    title: String = "",
    to outputURL: URL
  ) async {
    let style: NSWindow.StyleMask = titled
      ? [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView]
      : [.borderless]

    let controller = NSHostingController(
      rootView: rootView
        .environment(\.colorScheme, appearanceName == .darkAqua ? .dark : .light)
    )
    let resolvedSize = size ?? controller.view.fittingSize

    let window = KeyableSnapshotWindow(
      contentRect: NSRect(origin: NSPoint(x: 140, y: 140), size: resolvedSize),
      styleMask: style,
      backing: .buffered,
      defer: false
    )
    window.appearance = NSAppearance(named: appearanceName)
    window.isReleasedWhenClosed = false
    if titled {
      window.title = title
      window.toolbarStyle = .unified
    } else {
      window.backgroundColor = .clear
      window.isOpaque = false
    }
    window.contentViewController = controller
    if let size {
      window.setContentSize(size)
    } else {
      controller.view.layoutSubtreeIfNeeded()
      window.setContentSize(controller.view.fittingSize)
    }
    window.makeKeyAndOrderFront(nil)
    if !titled {
      window.makeFirstResponder(nil)
    }
    NSApp.activate(ignoringOtherApps: true)

    try? await Task.sleep(for: .milliseconds(360))

    let winID = window.windowNumber
    var capturedWithCompositor = false
    if winID > 0 {
      let proc = Process()
      proc.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
      proc.arguments = ["-x", "-o", "-l", String(winID), outputURL.path]
      try? proc.run()
      proc.waitUntilExit()
      if proc.terminationStatus == 0, FileManager.default.fileExists(atPath: outputURL.path) {
        capturedWithCompositor = true
      }
    }

    if !capturedWithCompositor, let targetView = window.contentView?.superview ?? window.contentView {
      let bounds = targetView.bounds
      if let rep = targetView.bitmapImageRepForCachingDisplay(in: bounds) {
        targetView.cacheDisplay(in: bounds, to: rep)
        if let png = rep.representation(using: .png, properties: [:]) {
          try? png.write(to: outputURL)
        }
      }
    }

    window.orderOut(nil)
  }

  private static func makeSampleDocumentImage() -> NSImage {
    let size = NSSize(width: 680, height: 360)
    let image = NSImage(size: size)
    image.lockFocus()
    NSColor(calibratedWhite: 0.96, alpha: 1).setFill()
    NSRect(origin: .zero, size: size).fill()

    let titleAttrs: [NSAttributedString.Key: Any] = [
      .font: NSFont.systemFont(ofSize: 24, weight: .bold),
      .foregroundColor: NSColor(calibratedWhite: 0.12, alpha: 1)
    ]
    let bodyAttrs: [NSAttributedString.Key: Any] = [
      .font: NSFont.systemFont(ofSize: 17, weight: .regular),
      .foregroundColor: NSColor(calibratedWhite: 0.25, alpha: 1)
    ]
    ("Native macOS 27 Liquid Glass Architecture" as NSString).draw(at: NSPoint(x: 48, y: 245), withAttributes: titleAttrs)
    ("On-device Vision OCR with isolated subprocess self-healing." as NSString).draw(at: NSPoint(x: 48, y: 160), withAttributes: bodyAttrs)
    ("100% private — screenshots never leave your Mac." as NSString).draw(at: NSPoint(x: 48, y: 80), withAttributes: bodyAttrs)
    image.unlockFocus()
    return image
  }
}

private final class KeyableSnapshotWindow: NSWindow {
  override var canBecomeKey: Bool { true }
  override var canBecomeMain: Bool { true }
}
