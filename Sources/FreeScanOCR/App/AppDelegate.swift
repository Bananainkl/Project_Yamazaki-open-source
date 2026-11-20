import AppKit
import Carbon.HIToolbox
import CoreGraphics
import Foundation
import OSLog
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
  private let lifecycleLogger = Logger(subsystem: "com.itou.yamazaki", category: "Lifecycle")

  private var hotKeyRef: EventHotKeyRef?
  private var translateHotKeyRef: EventHotKeyRef?
  private var eventHandlerRef: EventHandlerRef?

  private var statusItem: NSStatusItem?
  private lazy var menuBarPanelController = MenuBarControlPanelController(
    model: stateModel,
    actionsProvider: { [weak self] in
      guard let self else { return Self.noopActions }
      return self.makeActions()
    }
  )

  private var settingsWindow: NSWindow?
  private var settingsCloseObserver: NSObjectProtocol?
  private var translationWindow: NSWindow?
  private lazy var hudController = FloatingHUDController(
    model: stateModel,
    onAuthorizePermission: { [weak self] in
      self?.openScreenCaptureSystemSettings()
    }
  )

  private var hotKey = HotKeyPreference.load()
  private var translateHotKey = HotKeyPreference.loadTranslation()
  private let ocrService = OCRService()
  let stateModel = AppStateModel()

  private var isRunningCapture = false
  private var isShowingPermissionAlert = false
  private var hasRequestedScreenCaptureInProcess = false

  private var currentOCRTask: Task<Void, Never>?
  private var activeOCRTaskID: UUID?
  private var currentTranslationTask: Task<Void, Never>?
  private var activeTranslationTaskID: UUID?
  private var currentCaptureProcess: Process?
  private var lastCaptureTime: Date = .distantPast
  private let captureDebounceInterval: TimeInterval = 0.3
  private var isSelfHealScheduled = false

  func applicationDidFinishLaunching(_ notification: Notification) {
    if let qaIndex = CommandLine.arguments.firstIndex(of: "--visual-qa"),
       qaIndex + 1 < CommandLine.arguments.count {
      let outDir = CommandLine.arguments[qaIndex + 1]
      Task { @MainActor in
        await VisualQARunner.captureAllScreens(into: outDir)
        NSApp.terminate(nil)
      }
      return
    }

    guard isPrimaryApplicationInstance else {
      NSApp.terminate(nil)
      return
    }

    NSApp.setActivationPolicy(.accessory)
    ocrService.onSelfHealNeeded = { [weak self] error in
      Task { @MainActor in
        self?.scheduleSelfHealIfNeeded(triggerError: error)
      }
    }

    syncStateFromPreferences()
    updateStatus(LocalizedText.tr(.shortcutEnabled, hotKey.displayText), kind: .ready)

    if AppPreferences.startAtLogin || AppPreferences.autoRestart {
      LaunchAgentService.refreshLaunchAgent()
    }

    cleanupOldTempFiles()
    configureStatusItem()
    registerHotKey()

    if CommandLine.arguments.contains("--open-panel-on-launch") {
      Task { @MainActor [weak self] in
        try? await Task.sleep(for: .milliseconds(350))
        if let self, let button = self.statusItem?.button {
          self.syncStateFromPreferences()
          self.menuBarPanelController.show(relativeTo: button)
        }
      }
    }
  }

  func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    showMainWindow()
    return true
  }

  func applicationWillTerminate(_ notification: Notification) {
    menuBarPanelController.close()
    if let settingsCloseObserver {
      NotificationCenter.default.removeObserver(settingsCloseObserver)
      self.settingsCloseObserver = nil
    }
    hudController.hideImmediately()

    activeOCRTaskID = nil
    currentOCRTask?.cancel()
    currentOCRTask = nil

    activeTranslationTaskID = nil
    currentTranslationTask?.cancel()
    currentTranslationTask = nil

    ocrService.cancelActiveWorker()
    if let process = currentCaptureProcess, process.isRunning {
      process.terminate()
    }
    currentCaptureProcess = nil

    translationWindow?.close()
    translationWindow = nil

    if let hotKeyRef {
      UnregisterEventHotKey(hotKeyRef)
    }
    if let translateHotKeyRef {
      UnregisterEventHotKey(translateHotKeyRef)
    }
    if let eventHandlerRef {
      RemoveEventHandler(eventHandlerRef)
    }
  }

  private var isPrimaryApplicationInstance: Bool {
    guard let bundleIdentifier = Bundle.main.bundleIdentifier else { return true }
    let currentPID = ProcessInfo.processInfo.processIdentifier
    let runningPIDs = NSRunningApplication
      .runningApplications(withBundleIdentifier: bundleIdentifier)
      .map(\.processIdentifier)
    return runningPIDs.min() == currentPID
  }

  private func cleanupOldTempFiles() {
    DispatchQueue.global(qos: .utility).async {
      let tempDir = FileManager.default.temporaryDirectory
      guard let contents = try? FileManager.default.contentsOfDirectory(
        at: tempDir,
        includingPropertiesForKeys: [.creationDateKey],
        options: []
      ) else { return }

      for url in contents {
        let name = url.lastPathComponent
        let isYamazakiTemp = name.hasPrefix("yamazaki-capture-") || name.hasPrefix("yamazaki-ocr-worker-")
        let isExpectedExt = url.pathExtension == "png" || url.pathExtension == "json"
        guard isYamazakiTemp && isExpectedExt else { continue }
        let isOld = (try? url.resourceValues(forKeys: [.creationDateKey]).creationDate)
          .map { Date().timeIntervalSince($0) > 3600 } ?? false
        if isOld {
          try? FileManager.default.removeItem(at: url)
        }
      }
    }
  }

  private static let noopActions = SettingsActions(
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

  func makeActions() -> SettingsActions {
    SettingsActions(
      startShortcutRecording: { [weak self] in
        self?.suspendHotKeys()
        self?.updateStatus(LocalizedText.tr(.pressNewShortcut), kind: .active)
      },
      startTranslationShortcutRecording: { [weak self] in
        self?.suspendHotKeys()
        self?.updateStatus(LocalizedText.tr(.pressNewShortcut), kind: .active)
      },
      cancelShortcutRecording: { [weak self] in
        self?.registerHotKey()
      },
      setShortcut: { [weak self] shortcut in
        self?.setHotKey(shortcut)
      },
      setTranslationShortcut: { [weak self] shortcut in
        self?.setTranslationHotKey(shortcut)
      },
      resetDefaultShortcut: { [weak self] in
        self?.setHotKey(HotKeyPreference.defaultShortcut())
      },
      resetDefaultTranslationShortcut: { [weak self] in
        self?.setTranslationHotKey(HotKeyPreference.defaultTranslationShortcut())
      },
      invalidShortcut: { [weak self] in
        self?.updateStatus(LocalizedText.tr(.invalidShortcut), kind: .warning)
      },
      captureSelection: { [weak self] in
        self?.dismissPanelThenPerform { $0.captureSelection() }
      },
      translateSelection: { [weak self] in
        self?.dismissPanelThenPerform { $0.captureTranslationSelection() }
      },
      recognizeClipboard: { [weak self] in
        self?.menuBarPanelController.close()
        self?.recognizeClipboardImage()
      },
      openSettings: { [weak self] in
        self?.showMainWindow()
      },
      openPermissionSettings: { [weak self] in
        self?.openScreenCaptureSystemSettings()
      },
      quitApp: {
        NSApp.terminate(nil)
      },
      setMuteSound: { [weak self] isMuted in
        AppPreferences.muteSuccessSound = isMuted
        self?.stateModel.muteSuccessSound = isMuted
      },
      setShowFloatingHUD: { [weak self] isEnabled in
        AppPreferences.showFloatingHUD = isEnabled
        self?.stateModel.showFloatingHUD = isEnabled
        if !isEnabled {
          self?.hudController.hideImmediately()
        }
      },
      setIgnoreWatermarkText: { [weak self] isEnabled in
        AppPreferences.ignoreWatermarkText = isEnabled
        self?.stateModel.ignoreWatermarkText = isEnabled
      },
      setStartAtLogin: { [weak self] isEnabled in
        LaunchAgentService.setStartAtLoginEnabled(isEnabled)
        self?.stateModel.startAtLogin = isEnabled
        self?.updateStatus(LocalizedText.tr(isEnabled ? .startAtLoginEnabled : .startAtLoginDisabled), kind: .ready)
      },
      setAutoRestart: { [weak self] isEnabled in
        LaunchAgentService.setAutoRestartEnabled(isEnabled)
        self?.stateModel.autoRestart = isEnabled
        self?.updateStatus(LocalizedText.tr(isEnabled ? .autoRestartEnabled : .autoRestartDisabled), kind: .ready)
      },
      setLanguageMode: { [weak self] mode in
        AppPreferences.languageMode = mode
        self?.stateModel.languageMode = mode
        self?.updateStatus(LocalizedText.tr(.recognitionLanguageSet, mode.title), kind: .ready)
      },
      setTranslationLanguage: { [weak self] language in
        AppPreferences.translationLanguage = language
        self?.stateModel.translationLanguage = language
        self?.updateStatus(LocalizedText.tr(.translationLanguageSet, language.title), kind: .ready)
      },
      setUILanguage: { [weak self] language in
        AppPreferences.uiLanguage = language
        self?.stateModel.uiLanguage = language
        self?.stateModel.uiRefreshToken = UUID()
        self?.refreshLocalizedChrome()
      },
      setTextDirection: { [weak self] direction in
        AppPreferences.textDirection = direction
        self?.stateModel.textDirection = direction
        self?.updateStatus(LocalizedText.tr(.textDirectionSet, direction.title), kind: .ready)
      },
      setResultLayout: { [weak self] layout in
        AppPreferences.resultLayout = layout
        self?.stateModel.resultLayout = layout
        self?.updateStatus(LocalizedText.tr(.resultLayoutSet, layout.title), kind: .ready)
      },
      setResultFontSize: { [weak self] size in
        let clamped = max(10, min(28, size))
        AppPreferences.resultFontSize = clamped
        self?.stateModel.resultFontSize = clamped
      },
      copyTextToPasteboard: { [weak self] text in
        guard let self, !text.isEmpty else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        let charCount = text.unicodeScalars.filter { !$0.properties.isWhitespace }.count
        self.updateStatus(LocalizedText.tr(.copiedCharsCount, charCount), kind: .success)
        self.playSuccessSound()
      }
    )
  }

  private func dismissPanelThenPerform(_ block: @escaping (AppDelegate) -> Void) {
    let wasPanelVisible = menuBarPanelController.isVisible
    menuBarPanelController.close()
    if wasPanelVisible {
      Task { @MainActor [weak self] in
        try? await Task.sleep(for: .milliseconds(80))
        guard let self else { return }
        block(self)
      }
    } else {
      block(self)
    }
  }

  private func configureStatusItem() {
    let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    if let button = item.button {
      button.image = statusBarImage(named: "viewfinder")
      button.toolTip = "\(ProductInfo.appName) · \(LocalizedText.tr(.captureWithShortcut, hotKey.displayText))"
      button.target = self
      button.action = #selector(handleStatusBarButton(_:))
      button.sendAction(on: [.leftMouseUp, .rightMouseUp])
      button.setAccessibilityLabel(ProductInfo.appName)
    }
    self.statusItem = item
  }

  @objc private func handleStatusBarButton(_ sender: NSStatusBarButton) {
    let currentEvent = NSApp.currentEvent
    let isRightClick = (currentEvent?.type == .rightMouseUp) || (currentEvent?.modifierFlags.contains(.control) == true)

    if isRightClick {
      menuBarPanelController.close()
      let menu = buildQuickContextMenu()
      menu.popUp(positioning: nil, at: NSPoint(x: 0, y: sender.bounds.height + 4), in: sender)
      return
    }

    syncStateFromPreferences()
    menuBarPanelController.toggle(relativeTo: sender)
  }

  private func buildQuickContextMenu() -> NSMenu {
    let menu = NSMenu()

    let captureItem = NSMenuItem(
      title: LocalizedText.tr(.captureWithShortcut, hotKey.displayText),
      action: #selector(captureSelectionFromMenu),
      keyEquivalent: ""
    )
    captureItem.target = self
    captureItem.image = NSImage(systemSymbolName: "viewfinder", accessibilityDescription: nil)
    menu.addItem(captureItem)

    let translateItem = NSMenuItem(
      title: LocalizedText.tr(.translateWithShortcut, translateHotKey.displayText),
      action: #selector(translateSelectionFromMenu),
      keyEquivalent: ""
    )
    translateItem.target = self
    translateItem.image = NSImage(systemSymbolName: "translate", accessibilityDescription: nil)
    menu.addItem(translateItem)

    let clipboardItem = NSMenuItem(
      title: LocalizedText.tr(.recognizeClipboard),
      action: #selector(recognizeClipboardFromMenu),
      keyEquivalent: ""
    )
    clipboardItem.target = self
    clipboardItem.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: nil)
    menu.addItem(clipboardItem)

    menu.addItem(.separator())

    let statusItem = NSMenuItem(title: stateModel.status, action: nil, keyEquivalent: "")
    statusItem.isEnabled = false
    menu.addItem(statusItem)

    menu.addItem(.separator())

    let settingsItem = NSMenuItem(
      title: LocalizedText.tr(.openSettings),
      action: #selector(openSettingsFromMenu),
      keyEquivalent: ","
    )
    settingsItem.target = self
    settingsItem.image = NSImage(systemSymbolName: "gearshape", accessibilityDescription: nil)
    menu.addItem(settingsItem)

    let quitItem = NSMenuItem(
      title: LocalizedText.tr(.quitApp, ProductInfo.appName),
      action: #selector(quitFromMenu),
      keyEquivalent: "q"
    )
    quitItem.target = self
    menu.addItem(quitItem)

    return menu
  }

  @objc private func openSettingsFromMenu() { showMainWindow() }
  @objc private func captureSelectionFromMenu() { captureSelection() }
  @objc private func translateSelectionFromMenu() { captureTranslationSelection() }
  @objc private func recognizeClipboardFromMenu() { recognizeClipboardImage() }
  @objc private func quitFromMenu() { NSApp.terminate(nil) }

  func showMainWindow(initialSection: SettingsSection = .general) {
    menuBarPanelController.close()
    syncStateFromPreferences()

    if let settingsWindow {
      settingsWindow.title = LocalizedText.tr(.appSettings, ProductInfo.appName)
      settingsWindow.makeKeyAndOrderFront(nil)
      NSApp.activate(ignoringOtherApps: true)
      return
    }

    let window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 840, height: 620),
      styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
      backing: .buffered,
      defer: false
    )
    window.title = LocalizedText.tr(.appSettings, ProductInfo.appName)
    window.toolbarStyle = .unified
    window.minSize = NSSize(width: 760, height: 540)
    window.isReleasedWhenClosed = false
    window.center()
    window.contentViewController = NSHostingController(
      rootView: SettingsRootView(
        model: stateModel,
        actions: makeActions(),
        initialSection: initialSection
      )
    )

    settingsCloseObserver = NotificationCenter.default.addObserver(
      forName: NSWindow.willCloseNotification,
      object: window,
      queue: .main
    ) { [weak self] _ in
      Task { @MainActor [weak self] in
        self?.registerHotKey()
      }
    }

    self.settingsWindow = window
    window.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
  }

  private func syncStateFromPreferences() {
    stateModel.shortcutText = hotKey.displayText
    stateModel.translationShortcutText = translateHotKey.displayText
    stateModel.uiLanguage = AppPreferences.uiLanguage
    stateModel.muteSuccessSound = AppPreferences.muteSuccessSound
    stateModel.showFloatingHUD = AppPreferences.showFloatingHUD
    stateModel.ignoreWatermarkText = AppPreferences.ignoreWatermarkText
    stateModel.startAtLogin = AppPreferences.startAtLogin
    stateModel.autoRestart = AppPreferences.autoRestart
    stateModel.languageMode = AppPreferences.languageMode
    stateModel.translationLanguage = AppPreferences.translationLanguage
    stateModel.textDirection = AppPreferences.textDirection
    stateModel.resultLayout = AppPreferences.resultLayout
    stateModel.resultFontSize = AppPreferences.resultFontSize
  }

  private func refreshLocalizedChrome() {
    statusItem?.button?.toolTip = "\(ProductInfo.appName) · \(LocalizedText.tr(.captureWithShortcut, hotKey.displayText))"
    settingsWindow?.title = LocalizedText.tr(.appSettings, ProductInfo.appName)
    translationWindow?.title = LocalizedText.tr(.translateSelection)
    updateStatus(LocalizedText.tr(.shortcutEnabled, hotKey.displayText), kind: .ready)
  }

  private func suspendHotKeys() {
    if let hotKeyRef {
      UnregisterEventHotKey(hotKeyRef)
      self.hotKeyRef = nil
    }
    if let translateHotKeyRef {
      UnregisterEventHotKey(translateHotKeyRef)
      self.translateHotKeyRef = nil
    }
  }

  private func registerHotKey() {
    suspendHotKeys()

    if eventHandlerRef == nil {
      var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
      let selfPointer = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())

      InstallEventHandler(
        GetApplicationEventTarget(),
        { _, event, userData in
          guard let userData else { return noErr }
          var hotKeyID = EventHotKeyID()
          GetEventParameter(
            event,
            EventParamName(kEventParamDirectObject),
            EventParamType(typeEventHotKeyID),
            nil,
            MemoryLayout<EventHotKeyID>.size,
            nil,
            &hotKeyID
          )

          let appDelegate = Unmanaged<AppDelegate>.fromOpaque(userData).takeUnretainedValue()
          if hotKeyID.id == 1 {
            Task { @MainActor in
              appDelegate.captureSelection()
            }
          } else if hotKeyID.id == 2 {
            Task { @MainActor in
              appDelegate.captureTranslationSelection()
            }
          }
          return noErr
        },
        1,
        &eventType,
        selfPointer,
        &eventHandlerRef
      )
    }

    let hotKeyID = EventHotKeyID(signature: fourCharacterCode("FSOC"), id: 1)
    let status = RegisterEventHotKey(
      UInt32(hotKey.keyCode),
      UInt32(hotKey.carbonModifiers),
      hotKeyID,
      GetApplicationEventTarget(),
      0,
      &hotKeyRef
    )

    let translateHotKeyID = EventHotKeyID(signature: fourCharacterCode("FSTR"), id: 2)
    let translateStatus = RegisterEventHotKey(
      UInt32(translateHotKey.keyCode),
      UInt32(translateHotKey.carbonModifiers),
      translateHotKeyID,
      GetApplicationEventTarget(),
      0,
      &translateHotKeyRef
    )

    if status == noErr && translateStatus == noErr {
      updateStatus(LocalizedText.tr(.shortcutEnabled, hotKey.displayText), kind: .ready)
      statusItem?.button?.toolTip = "\(ProductInfo.appName) · \(LocalizedText.tr(.captureWithShortcut, hotKey.displayText))"
    } else {
      updateStatus(LocalizedText.tr(.invalidShortcut), kind: .warning)
    }
  }

  private func canRegisterHotKey(_ shortcut: HotKeyPreference, signature: String, id: UInt32) -> Bool {
    var temporaryRef: EventHotKeyRef?
    let hotKeyID = EventHotKeyID(signature: fourCharacterCode(signature), id: id)
    let status = RegisterEventHotKey(
      UInt32(shortcut.keyCode),
      UInt32(shortcut.carbonModifiers),
      hotKeyID,
      GetApplicationEventTarget(),
      0,
      &temporaryRef
    )
    if let temporaryRef {
      UnregisterEventHotKey(temporaryRef)
    }
    return status == noErr
  }

  private func setHotKey(_ shortcut: HotKeyPreference) {
    if shortcut == hotKey {
      registerHotKey()
      return
    }
    guard shortcut != translateHotKey else {
      registerHotKey()
      updateStatus(LocalizedText.tr(.invalidShortcut), kind: .warning)
      return
    }
    guard canRegisterHotKey(shortcut, signature: "FSOC", id: 1) else {
      registerHotKey()
      updateStatus(LocalizedText.tr(.invalidShortcut), kind: .warning)
      return
    }
    hotKey = shortcut
    hotKey.save()
    stateModel.shortcutText = shortcut.displayText
    registerHotKey()
  }

  private func setTranslationHotKey(_ shortcut: HotKeyPreference) {
    if shortcut == translateHotKey {
      registerHotKey()
      return
    }
    guard shortcut != hotKey else {
      registerHotKey()
      updateStatus(LocalizedText.tr(.invalidShortcut), kind: .warning)
      return
    }
    guard canRegisterHotKey(shortcut, signature: "FSTR", id: 2) else {
      registerHotKey()
      updateStatus(LocalizedText.tr(.invalidShortcut), kind: .warning)
      return
    }
    translateHotKey = shortcut
    translateHotKey.saveTranslation()
    stateModel.translationShortcutText = shortcut.displayText
    registerHotKey()
  }

  private func captureSelection() {
    let now = Date()
    guard now.timeIntervalSince(lastCaptureTime) >= captureDebounceInterval else { return }
    lastCaptureTime = now
    menuBarPanelController.close()

    captureScreenSelection { [weak self] image in
      self?.recognizeImageToClipboard(image, sourceKind: .regionOCR)
    }
  }

  private func captureTranslationSelection() {
    let now = Date()
    guard now.timeIntervalSince(lastCaptureTime) >= captureDebounceInterval else { return }
    lastCaptureTime = now
    menuBarPanelController.close()

    captureScreenSelection { [weak self] image in
      self?.presentTranslationPreview(for: image)
    }
  }

  private func captureScreenSelection(completion: @escaping (NSImage) -> Void) {
    guard !isRunningCapture else { return }
    guard ensureScreenCapturePermission() else { return }

    if let previousProcess = currentCaptureProcess, previousProcess.isRunning {
      previousProcess.terminate()
      currentCaptureProcess = nil
    }

    let captureURL = FileManager.default.temporaryDirectory
      .appendingPathComponent("yamazaki-capture-\(UUID().uuidString)")
      .appendingPathExtension("png")

    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
    process.arguments = ["-i", "-x", captureURL.path]

    currentCaptureProcess = process
    isRunningCapture = true
    updateStatus(LocalizedText.tr(.captureSelection), kind: .active)

    let serviceQueue = DispatchQueue.global(qos: .userInitiated)
    serviceQueue.async { [weak self] in
      defer {
        try? FileManager.default.removeItem(at: captureURL)
      }

      do {
        try process.run()
        process.waitUntilExit()
      } catch {
        Task { @MainActor [weak self] in
          guard let self else { return }
          if self.currentCaptureProcess === process {
            self.currentCaptureProcess = nil
          }
          self.isRunningCapture = false
          let msg = LocalizedText.tr(.recognitionFailed, error.localizedDescription)
          self.updateStatus(msg, kind: .error)
          self.hudController.present(.failed(message: msg, eventID: UUID()))
        }
        return
      }

      let capturedImage: NSImage?
      if process.terminationStatus == 0,
         let data = try? Data(contentsOf: captureURL) {
        capturedImage = NSImage(data: data)
      } else {
        capturedImage = nil
      }

      Task { @MainActor [weak self] in
        guard let self else { return }
        if self.currentCaptureProcess === process {
          self.currentCaptureProcess = nil
        }
        self.isRunningCapture = false

        if process.terminationStatus == 0 {
          if let image = capturedImage {
            completion(image)
          } else {
            self.updateStatus(LocalizedText.tr(.shortcutEnabled, self.hotKey.displayText), kind: .ready)
          }
        } else {
          self.updateStatus(LocalizedText.tr(.shortcutEnabled, self.hotKey.displayText), kind: .ready)
        }
      }
    }
  }

  private func ensureScreenCapturePermission() -> Bool {
    if CGPreflightScreenCaptureAccess() {
      return true
    }

    updateStatus(LocalizedText.tr(.needPermissionStatus), kind: .warning)

    if !hasRequestedScreenCaptureInProcess {
      hasRequestedScreenCaptureInProcess = true
      AppPreferences.didRequestScreenCapturePermission = true
      if CGRequestScreenCaptureAccess() {
        updateStatus(LocalizedText.tr(.shortcutEnabled, hotKey.displayText), kind: .ready)
        return true
      }
    }

    hudController.hideImmediately()
    showScreenCapturePermissionAlert()
    return false
  }

  private func openScreenCaptureSystemSettings() {
    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
      NSWorkspace.shared.open(url)
    }
  }

  private func showScreenCapturePermissionAlert() {
    guard !isShowingPermissionAlert else { return }
    isShowingPermissionAlert = true
    NSApp.activate(ignoringOtherApps: true)

    let alert = NSAlert()
    alert.messageText = LocalizedText.tr(.permissionTitle)
    alert.informativeText = LocalizedText.tr(.permissionMessage, ProductInfo.appName)
    alert.alertStyle = .informational
    alert.addButton(withTitle: LocalizedText.tr(.grantPermissionButton))
    alert.addButton(withTitle: LocalizedText.tr(.ok))

    let response = alert.runModal()
    isShowingPermissionAlert = false
    if response == .alertFirstButtonReturn {
      openScreenCaptureSystemSettings()
    }
  }

  private func recognizeClipboardImage() {
    guard let image = NSPasteboard.general.readObjects(forClasses: [NSImage.self])?.first as? NSImage else {
      updateStatus(LocalizedText.tr(.noClipboardImage), kind: .warning)
      hudController.present(.failed(message: LocalizedText.tr(.noClipboardImage), eventID: UUID()))
      return
    }
    recognizeImageToClipboard(image, sourceKind: .clipboardOCR)
  }

  private func recognizeImageToClipboard(_ image: NSImage, sourceKind: CaptureSourceKind) {
    currentOCRTask?.cancel()
    ocrService.cancelActiveWorker()

    let taskID = UUID()
    activeOCRTaskID = taskID
    updateStatus(LocalizedText.tr(.recognizingText), kind: .active)
    statusItem?.button?.image = statusBarImage(named: "text.viewfinder")
    hudController.present(.recognizing)

    let service = ocrService
    currentOCRTask = Task.detached(priority: .userInitiated) { [weak self] in
      guard !Task.isCancelled else { return }

      do {
        let text = try service.recognizeText(in: image)
        guard !Task.isCancelled else { return }

        await MainActor.run { [weak self] in
          guard let self, self.activeOCRTaskID == taskID else { return }

          if text.isEmpty {
            self.updateStatus(LocalizedText.tr(.noTextFound), kind: .warning)
            self.statusItem?.button?.image = self.statusBarImage(named: "viewfinder")
            self.hudController.present(.emptyResult(eventID: UUID()))
          } else {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(text, forType: .string)
            self.stateModel.recordHistory(text: text, sourceKind: sourceKind)
            let charCount = text.unicodeScalars.filter { !$0.properties.isWhitespace }.count
            let preview = self.stateModel.recentHistory.first?.singleLinePreview ?? ""
            self.updateStatus(LocalizedText.tr(.copiedCharsCount, charCount), kind: .success)
            self.playSuccessSound()
            self.flashSuccessIcon()
            self.hudController.present(.copied(charCount: charCount, preview: preview, eventID: UUID()))
          }

          self.activeOCRTaskID = nil
          self.currentOCRTask = nil
        }
      } catch {
        guard !Task.isCancelled else { return }

        await MainActor.run { [weak self] in
          guard let self, self.activeOCRTaskID == taskID else { return }
          let msg = LocalizedText.tr(.recognitionFailed, error.localizedDescription)
          self.updateStatus(msg, kind: .error)
          self.statusItem?.button?.image = self.statusBarImage(named: "exclamationmark.triangle")
          self.hudController.present(.failed(message: msg, eventID: UUID()))
          self.activeOCRTaskID = nil
          self.currentOCRTask = nil
        }
      }
    }
  }

  private func presentTranslationPreview(for image: NSImage) {
    currentTranslationTask?.cancel()
    ocrService.cancelActiveWorker()

    let taskID = UUID()
    activeTranslationTaskID = taskID
    updateStatus(LocalizedText.tr(.recognizingText), kind: .active)
    hudController.present(.recognizing)

    let service = ocrService
    currentTranslationTask = Task.detached(priority: .userInitiated) { [weak self] in
      guard !Task.isCancelled else { return }

      do {
        let lines = try service.recognizePositionedText(in: image)
        guard !Task.isCancelled else { return }

        await MainActor.run { [weak self] in
          guard let self, self.activeTranslationTaskID == taskID else { return }
          self.hudController.dismissAnimated()
          let combinedSource = lines.map(\.text).joined(separator: "\n")
          if !combinedSource.isEmpty {
            self.stateModel.recordHistory(text: combinedSource, sourceKind: .translation)
          }
          self.showTranslationWindow(image: image, lines: lines)
          self.updateStatus(LocalizedText.tr(.shortcutEnabled, self.hotKey.displayText), kind: .ready)
          self.activeTranslationTaskID = nil
          self.currentTranslationTask = nil
        }
      } catch {
        guard !Task.isCancelled else { return }

        await MainActor.run { [weak self] in
          guard let self, self.activeTranslationTaskID == taskID else { return }
          let msg = LocalizedText.tr(.recognitionFailed, error.localizedDescription)
          self.updateStatus(msg, kind: .error)
          self.hudController.present(.failed(message: msg, eventID: UUID()))
          self.activeTranslationTaskID = nil
          self.currentTranslationTask = nil
        }
      }
    }
  }

  private func showTranslationWindow(image: NSImage, lines: [RecognizedTextLine]) {
    translationWindow?.close()

    let window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 920, height: 600),
      styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
      backing: .buffered,
      defer: false
    )
    window.title = LocalizedText.tr(.translateSelection)
    window.toolbarStyle = .unified
    window.minSize = NSSize(width: 680, height: 460)
    window.isReleasedWhenClosed = false
    window.center()
    window.contentViewController = NSHostingController(
      rootView: TranslationStudioView(
        image: image,
        lines: lines,
        initialTargetLanguage: AppPreferences.translationLanguage,
        model: stateModel,
        onTargetLanguageChanged: { [weak self] newLang in
          AppPreferences.translationLanguage = newLang
          self?.stateModel.translationLanguage = newLang
        },
        onCopyText: { [weak self] copiedText in
          guard let self, !copiedText.isEmpty else { return }
          NSPasteboard.general.clearContents()
          NSPasteboard.general.setString(copiedText, forType: .string)
          let count = copiedText.unicodeScalars.filter { !$0.properties.isWhitespace }.count
          self.updateStatus(LocalizedText.tr(.copiedCharsCount, count), kind: .success)
          self.playSuccessSound()
          self.hudController.present(.copied(charCount: count, preview: "", eventID: UUID()))
        }
      )
    )
    translationWindow = window
    window.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
  }

  private func scheduleSelfHealIfNeeded(triggerError: Error) {
    guard !isSelfHealScheduled else { return }
    isSelfHealScheduled = true
    lifecycleLogger.warning(
      "In-process OCR degraded (\(triggerError.localizedDescription, privacy: .public)); subprocess worker succeeded. Scheduling idle self-heal relaunch."
    )
    scheduleIdleSelfHealCheck(after: 3.0)
  }

  private func scheduleIdleSelfHealCheck(after delay: TimeInterval) {
    Task { @MainActor [weak self] in
      try? await Task.sleep(for: .seconds(delay))
      self?.attemptIdleSelfHealRelaunch()
    }
  }

  private func attemptIdleSelfHealRelaunch() {
    let cooldownKey = "LastSelfHealRelaunchTimestamp"
    let now = Date().timeIntervalSince1970
    let lastRelaunch = UserDefaults.standard.double(forKey: cooldownKey)
    if lastRelaunch > 0 && (now - lastRelaunch) < 60 {
      scheduleIdleSelfHealCheck(after: max(5, 60 - (now - lastRelaunch)))
      return
    }

    let hasVisibleWindow =
      (settingsWindow?.isVisible == true) ||
      (translationWindow?.isVisible == true) ||
      menuBarPanelController.isVisible

    let isBusy =
      isRunningCapture ||
      currentOCRTask != nil ||
      currentTranslationTask != nil ||
      isShowingPermissionAlert ||
      hasVisibleWindow

    guard !isBusy else {
      scheduleIdleSelfHealCheck(after: 5.0)
      return
    }

    let bundlePath = Bundle.main.bundlePath
    guard bundlePath.hasSuffix(".app"),
          FileManager.default.fileExists(atPath: bundlePath) else {
      return
    }

    UserDefaults.standard.set(now, forKey: cooldownKey)
    UserDefaults.standard.synchronize()

    let currentPID = String(ProcessInfo.processInfo.processIdentifier)
    let relaunchScript = """
    old_pid="$1"
    app_path="$2"
    i=0
    while /bin/kill -0 "$old_pid" 2>/dev/null && [ "$i" -lt 50 ]; do
      /bin/sleep 0.1
      i=$((i + 1))
    done
    /usr/bin/open -g "$app_path"
    """

    let relauncher = Process()
    relauncher.executableURL = URL(fileURLWithPath: "/bin/sh")
    relauncher.arguments = ["-c", relaunchScript, "yamazaki-self-heal", currentPID, bundlePath]
    relauncher.standardInput = FileHandle.nullDevice
    relauncher.standardOutput = FileHandle.nullDevice
    relauncher.standardError = FileHandle.nullDevice

    do {
      try relauncher.run()
      lifecycleLogger.info("Executing background self-heal relaunch for \(bundlePath, privacy: .public)")
      NSApp.terminate(nil)
    } catch {
      lifecycleLogger.error("Failed to launch self-heal helper: \(error.localizedDescription, privacy: .public)")
      isSelfHealScheduled = false
    }
  }

  private func updateStatus(_ status: String, kind: SemanticStatusKind) {
    stateModel.status = status
    stateModel.statusKind = kind
    stateModel.statusEventCounter &+= 1
  }

  private func playSuccessSound() {
    guard !AppPreferences.muteSuccessSound else { return }
    let candidates = [
      "/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/system/Shutter.aif",
      "/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/system/Screen Capture.aif",
      "/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/system/Grab.aif"
    ]
    let sound = candidates.lazy.compactMap { NSSound(contentsOfFile: $0, byReference: true) }.first
      ?? NSSound(named: NSSound.Name("Tink"))
    sound?.volume = 0.36
    sound?.play()
  }

  private func flashSuccessIcon() {
    statusItem?.button?.image = statusBarImage(named: "checkmark.circle.fill")
    Task { @MainActor [weak self] in
      try? await Task.sleep(for: .seconds(1.2))
      guard let self else { return }
      self.statusItem?.button?.image = self.statusBarImage(named: "viewfinder")
    }
  }

  private func statusBarImage(named symbolName: String) -> NSImage? {
    let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: ProductInfo.appName)
      ?? NSImage(systemSymbolName: "viewfinder", accessibilityDescription: ProductInfo.appName)
    image?.isTemplate = true
    return image
  }
}
