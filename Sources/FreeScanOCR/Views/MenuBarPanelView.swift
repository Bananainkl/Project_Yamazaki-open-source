import AppKit
import Carbon.HIToolbox
import SwiftUI

struct MenuBarPanelView: View {
  let model: AppStateModel
  let actions: SettingsActions
  var onDismissPanel: () -> Void = {}
  var onLayoutChanged: () -> Void = {}

  @State private var copiedItemID: UUID?
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.colorSchemeContrast) private var contrast
  @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  private var historyViewportHeight: CGFloat {
    switch model.recentHistory.count {
    case 0: return 0
    case 1: return 80
    case 2: return 158
    default: return 220
    }
  }

  var body: some View {
    let _ = model.uiRefreshToken
    VStack(alignment: .leading, spacing: DesignSpacing.md) {
      headerSection

      primaryActionsCluster

      quickProfileStrip

      Divider()

      recentHistorySection
    }
    .padding(DesignSpacing.md)
    .frame(width: 368)
    .fixedSize(horizontal: false, vertical: true)
    .background {
      ZStack {
        if reduceTransparency || contrast == .increased {
          RoundedRectangle(cornerRadius: DesignRadius.lg, style: .continuous)
            .fill(Color(nsColor: .windowBackgroundColor))
        } else {
          VisualEffectPanelBackground(material: .popover, cornerRadius: DesignRadius.lg)
        }

        RoundedRectangle(cornerRadius: DesignRadius.lg, style: .continuous)
          .strokeBorder(
            colorScheme == .dark
              ? Color.white.opacity(contrast == .increased ? 0.34 : 0.16)
              : Color.black.opacity(contrast == .increased ? 0.24 : 0.10),
            lineWidth: contrast == .increased ? 1.5 : 0.8
          )
      }
    }
    .clipShape(RoundedRectangle(cornerRadius: DesignRadius.lg, style: .continuous))
    .environment(\.appearsActive, true)
    .environment(\.locale, LocalizedText.locale)
    .onChange(of: model.recentHistory.count) { _, _ in
      onLayoutChanged()
    }
    .onChange(of: model.uiRefreshToken) { _, _ in
      onLayoutChanged()
    }
  }

  private var headerSection: some View {
    HStack(spacing: DesignSpacing.xs) {
      Image(systemName: "viewfinder")
        .font(.system(size: 15, weight: .bold))
        .foregroundStyle(Color.accentColor)
        .frame(width: 26, height: 26)
        .adaptiveCard(cornerRadius: DesignRadius.xs)

      VStack(alignment: .leading, spacing: 2) {
        Text(ProductInfo.appName)
          .font(.system(size: 14, weight: .bold))
          .foregroundStyle(.primary)

        HStack(spacing: 5) {
          Circle()
            .fill(model.statusKind.foregroundColor(scheme: colorScheme, contrast: contrast))
            .frame(width: 6, height: 6)
          Text(model.status)
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .contentTransition(.interpolate)
        }
      }

      Spacer(minLength: DesignSpacing.xs)

      Button {
        onDismissPanel()
        actions.openSettings()
      } label: {
        Image(systemName: "gearshape")
          .font(.system(size: 13, weight: .semibold))
          .frame(width: 28, height: 28)
      }
      .buttonStyle(.glass)
      .buttonBorderShape(.circle)
      .help(LocalizedText.tr(.openSettings))
      .accessibilityLabel(LocalizedText.tr(.openSettings))

      Button {
        onDismissPanel()
        actions.quitApp()
      } label: {
        Image(systemName: "power")
          .font(.system(size: 12, weight: .semibold))
          .frame(width: 28, height: 28)
      }
      .buttonStyle(.glass)
      .buttonBorderShape(.circle)
      .help(LocalizedText.tr(.quitApp, ProductInfo.appName))
      .accessibilityLabel(LocalizedText.tr(.quitApp, ProductInfo.appName))
    }
  }

  private var primaryActionsCluster: some View {
    GlassEffectContainer(spacing: DesignSpacing.xs) {
      VStack(spacing: DesignSpacing.xs) {
        HStack(spacing: DesignSpacing.xs) {
          Button {
            actions.captureSelection()
          } label: {
            VStack(alignment: .leading, spacing: DesignSpacing.xs) {
              HStack {
                Image(systemName: "viewfinder")
                  .font(.system(size: 16, weight: .semibold))
                Spacer()
                Text(model.shortcutText)
                  .font(.system(size: 11, weight: .semibold, design: .rounded))
                  .opacity(0.90)
              }
              Text(LocalizedText.tr(.captureSelection))
                .font(.system(size: 13, weight: .semibold))
                .lineLimit(1)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
          }
          .buttonStyle(.glassProminent)
          .buttonBorderShape(.roundedRectangle(radius: DesignRadius.md))

          Button {
            actions.translateSelection()
          } label: {
            VStack(alignment: .leading, spacing: DesignSpacing.xs) {
              HStack {
                Image(systemName: "translate")
                  .font(.system(size: 16, weight: .semibold))
                Spacer()
                Text(model.translationShortcutText)
                  .font(.system(size: 11, weight: .semibold, design: .rounded))
                  .foregroundStyle(.secondary)
              }
              Text(LocalizedText.tr(.translateSelection))
                .font(.system(size: 13, weight: .semibold))
                .lineLimit(1)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
          }
          .buttonStyle(.glass)
          .buttonBorderShape(.roundedRectangle(radius: DesignRadius.md))
        }

        Button {
          actions.recognizeClipboard()
        } label: {
          HStack(spacing: DesignSpacing.xs) {
            Image(systemName: "doc.on.clipboard")
              .font(.system(size: 13, weight: .semibold))
            Text(LocalizedText.tr(.recognizeClipboard))
              .font(.system(size: 12, weight: .semibold))
              .lineLimit(1)
            Spacer()
            Image(systemName: "chevron.right")
              .font(.system(size: 10, weight: .semibold))
              .foregroundStyle(.tertiary)
          }
          .padding(.vertical, 4)
          .padding(.horizontal, 4)
          .frame(maxWidth: .infinity)
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.roundedRectangle(radius: DesignRadius.sm))
      }
    }
  }

  private var quickProfileStrip: some View {
    HStack(spacing: DesignSpacing.xs) {
      Image(systemName: "globe")
        .font(.system(size: 12, weight: .medium))
        .foregroundStyle(.secondary)

      Picker(LocalizedText.tr(.quickSettings), selection: Binding(
        get: { model.languageMode },
        set: { mode in
          model.languageMode = mode
          actions.setLanguageMode(mode)
        }
      )) {
        ForEach(AppPreferences.LanguageMode.allCases, id: \.self) { mode in
          Text(mode.title).tag(mode)
        }
      }
      .labelsHidden()
      .controlSize(.small)
      .frame(maxWidth: .infinity, alignment: .leading)

      Picker(LocalizedText.tr(.textDirection), selection: Binding(
        get: { model.textDirection },
        set: { direction in
          model.textDirection = direction
          actions.setTextDirection(direction)
        }
      )) {
        Image(systemName: "text.alignleft")
          .help(LocalizedText.tr(.horizontalScan))
          .tag(AppPreferences.TextDirection.horizontal)
        Image(systemName: "text.word.spacing")
          .help(LocalizedText.tr(.verticalScan))
          .tag(AppPreferences.TextDirection.vertical)
      }
      .pickerStyle(.segmented)
      .labelsHidden()
      .controlSize(.small)
      .frame(width: 68)
    }
  }

  @ViewBuilder
  private var recentHistorySection: some View {
    VStack(alignment: .leading, spacing: DesignSpacing.xs) {
      HStack {
        Text(LocalizedText.tr(.recentCaptures))
          .font(.system(size: 12, weight: .semibold))
          .foregroundStyle(.secondary)

        Spacer()

        if !model.recentHistory.isEmpty {
          Button(LocalizedText.tr(.clearHistory)) {
            withAnimation(DesignMotion.snappy(reduceMotion: reduceMotion)) {
              model.clearHistory()
            }
          }
          .buttonStyle(.plain)
          .font(.system(size: 11, weight: .semibold))
          .foregroundStyle(Color.accentColor)
        }
      }

      if model.recentHistory.isEmpty {
        VStack(spacing: DesignSpacing.xs) {
          Image(systemName: "text.viewfinder")
            .font(.system(size: 24, weight: .regular))
            .foregroundStyle(.tertiary)
          Text(LocalizedText.tr(.emptyHistoryTitle))
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.primary)
          Text(LocalizedText.tr(.emptyHistorySubtitle, model.shortcutText))
            .font(.system(size: 11, weight: .regular))
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, DesignSpacing.lg)
        .padding(.horizontal, DesignSpacing.md)
        .frame(maxWidth: .infinity)
        .adaptiveCard(cornerRadius: DesignRadius.md)
      } else {
        ScrollView(.vertical, showsIndicators: true) {
          LazyVStack(spacing: DesignSpacing.xs) {
            ForEach(model.recentHistory) { item in
              HistorySnippetRow(
                item: item,
                isCopied: copiedItemID == item.id,
                onCopy: {
                  actions.copyTextToPasteboard(item.text)
                  withAnimation(DesignMotion.snappy(reduceMotion: reduceMotion)) {
                    copiedItemID = item.id
                  }
                  Task { @MainActor in
                    try? await Task.sleep(for: .seconds(1.3))
                    if copiedItemID == item.id {
                      withAnimation(DesignMotion.snappy(reduceMotion: reduceMotion)) {
                        copiedItemID = nil
                      }
                    }
                  }
                }
              )
            }
          }
          .padding(.top, 2)
          .padding(.bottom, 6)
        }
        .frame(height: historyViewportHeight)
      }
    }
  }
}

private struct HistorySnippetRow: View {
  let item: OCRHistoryItem
  let isCopied: Bool
  let onCopy: () -> Void

  @State private var isHovered = false

  var body: some View {
    Button(action: onCopy) {
      HStack(alignment: .top, spacing: DesignSpacing.xs) {
        Image(systemName: item.sourceKind.symbolName)
          .font(.system(size: 12, weight: .semibold))
          .foregroundStyle(.secondary)
          .frame(width: 18, height: 18)
          .padding(.top, 1)

        VStack(alignment: .leading, spacing: 4) {
          Text(item.singleLinePreview)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.primary)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)

          HStack(spacing: 6) {
            Text(LocalizedText.tr(.charactersUnit, item.characterCount))
              .font(.system(size: 10, weight: .medium))
              .foregroundStyle(.tertiary)
            Text("·")
              .foregroundStyle(.quaternary)
            Text(LocalizedText.relativeTime(since: item.createdAt))
              .font(.system(size: 10, weight: .regular))
              .foregroundStyle(.tertiary)
          }
        }

        Image(systemName: isCopied ? "checkmark.circle.fill" : "doc.on.doc")
          .font(.system(size: 13, weight: .semibold))
          .foregroundStyle(isCopied ? .green : (isHovered ? Color.accentColor : .secondary))
          .contentTransition(.symbolEffect(.replace))
          .frame(width: 22, height: 22)
      }
      .padding(10)
      .adaptiveCard(cornerRadius: DesignRadius.sm, isSelected: isHovered || isCopied)
      .contentShape(RoundedRectangle(cornerRadius: DesignRadius.sm, style: .continuous))
    }
    .buttonStyle(.plain)
    .onHover { hovering in
      isHovered = hovering
    }
    .accessibilityLabel(item.singleLinePreview)
  }
}

private struct VisualEffectPanelBackground: NSViewRepresentable {
  let material: NSVisualEffectView.Material
  let cornerRadius: CGFloat

  func makeNSView(context: Context) -> NSVisualEffectView {
    let view = NSVisualEffectView()
    view.material = material
    view.blendingMode = .behindWindow
    view.state = .active
    view.wantsLayer = true
    view.layer?.cornerRadius = cornerRadius
    view.layer?.cornerCurve = .continuous
    view.layer?.masksToBounds = true
    return view
  }

  func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
    nsView.material = material
    nsView.state = .active
    nsView.layer?.cornerRadius = cornerRadius
  }
}

// MARK: - Native Screen-Clamped Menu Bar Control Center Panel

@MainActor
final class MenuBarControlPanelController {
  private let model: AppStateModel
  private let actionsProvider: () -> SettingsActions
  private var panel: KeyableMenuBarPanel?
  private var hostingView: FirstMouseHostingView<MenuBarPanelView>?
  private weak var lastAnchorButton: NSStatusBarButton?
  private var globalClickMonitor: Any?
  private var localEventMonitor: Any?
  private var resignActiveObserver: NSObjectProtocol?

  init(model: AppStateModel, actionsProvider: @escaping () -> SettingsActions) {
    self.model = model
    self.actionsProvider = actionsProvider
  }

  var isVisible: Bool {
    panel?.isVisible == true
  }

  func toggle(relativeTo button: NSStatusBarButton) {
    if isVisible {
      close()
    } else {
      show(relativeTo: button)
    }
  }

  func show(relativeTo button: NSStatusBarButton) {
    ensurePanel()
    guard let panel, let hostingView else { return }

    lastAnchorButton = button
    positionPanel(panel, hostingView: hostingView, relativeTo: button)

    NSApp.activate(ignoringOtherApps: true)
    panel.alphaValue = 1
    panel.makeKeyAndOrderFront(nil)
    panel.makeFirstResponder(nil)
    installDismissMonitors()
  }

  func close() {
    removeDismissMonitors()
    panel?.orderOut(nil)
  }

  private func ensurePanel() {
    guard panel == nil else { return }

    let panel = KeyableMenuBarPanel(
      contentRect: NSRect(x: 0, y: 0, width: 368, height: 384),
      styleMask: [.borderless, .nonactivatingPanel],
      backing: .buffered,
      defer: false
    )
    panel.onEscapePressed = { [weak self] in
      self?.close()
    }
    panel.isFloatingPanel = true
    panel.level = .popUpMenu
    panel.backgroundColor = .clear
    panel.isOpaque = false
    panel.hasShadow = true
    panel.hidesOnDeactivate = false
    panel.isReleasedWhenClosed = false
    panel.collectionBehavior = [.transient, .moveToActiveSpace, .fullScreenAuxiliary, .ignoresCycle]

    let rootView = MenuBarPanelView(
      model: model,
      actions: actionsProvider(),
      onDismissPanel: { [weak self] in
        self?.close()
      },
      onLayoutChanged: { [weak self] in
        Task { @MainActor [weak self] in
          self?.refreshSizeKeepingTopEdge()
        }
      }
    )

    let hosting = FirstMouseHostingView(rootView: rootView)
    panel.contentView = hosting
    self.panel = panel
    self.hostingView = hosting
  }

  private func refreshSizeKeepingTopEdge() {
    guard let panel, panel.isVisible, let hostingView, let button = lastAnchorButton else { return }
    positionPanel(panel, hostingView: hostingView, relativeTo: button)
  }

  private func positionPanel(
    _ panel: NSPanel,
    hostingView: NSHostingView<MenuBarPanelView>,
    relativeTo button: NSStatusBarButton
  ) {
    hostingView.invalidateIntrinsicContentSize()
    hostingView.layoutSubtreeIfNeeded()
    let fitting = hostingView.fittingSize
    let width: CGFloat = 368
    let height: CGFloat = max(280, min(ceil(fitting.height), 540))

    let buttonWindow = button.window
    let screen = buttonWindow?.screen
      ?? NSScreen.screens.first(where: { NSMouseInRect(NSEvent.mouseLocation, $0.frame, false) })
      ?? NSScreen.main
      ?? NSScreen.screens.first

    let visibleFrame = screen?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)

    let anchorScreenRect: NSRect = {
      if let buttonWindow {
        let rectInWindow = button.convert(button.bounds, to: nil)
        return buttonWindow.convertToScreen(rectInWindow)
      }
      let mouse = NSEvent.mouseLocation
      return NSRect(x: mouse.x - 14, y: visibleFrame.maxY, width: 28, height: 24)
    }()

    // Guarantee top edge is ALWAYS strictly below BOTH the status item button AND screen.visibleFrame.maxY (menu bar / notch bottom).
    let maxTopY = min(anchorScreenRect.minY - 6, visibleFrame.maxY - 6)
    let originY = max(visibleFrame.minY + 8, maxTopY - height)
    let idealX = anchorScreenRect.midX - width / 2
    let originX = min(max(idealX, visibleFrame.minX + 8), visibleFrame.maxX - width - 8)

    panel.setFrame(
      NSRect(x: round(originX), y: round(originY), width: width, height: height),
      display: true
    )
  }

  private func installDismissMonitors() {
    removeDismissMonitors()

    globalClickMonitor = NSEvent.addGlobalMonitorForEvents(
      matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown]
    ) { [weak self] _ in
      Task { @MainActor [weak self] in
        self?.close()
      }
    }

    localEventMonitor = NSEvent.addLocalMonitorForEvents(
      matching: [.keyDown, .leftMouseDown, .rightMouseDown]
    ) { [weak self] event in
      guard let self, self.isVisible else { return event }
      if event.type == .keyDown && event.keyCode == UInt16(kVK_Escape) {
        self.close()
        return nil
      }
      if event.type == .leftMouseDown || event.type == .rightMouseDown {
        if let eventWindow = event.window,
           eventWindow !== self.panel,
           eventWindow !== self.lastAnchorButton?.window,
           eventWindow.level == .normal {
          self.close()
        }
      }
      return event
    }

    resignActiveObserver = NotificationCenter.default.addObserver(
      forName: NSApplication.didResignActiveNotification,
      object: NSApp,
      queue: .main
    ) { [weak self] _ in
      Task { @MainActor [weak self] in
        self?.close()
      }
    }
  }

  private func removeDismissMonitors() {
    if let globalClickMonitor {
      NSEvent.removeMonitor(globalClickMonitor)
      self.globalClickMonitor = nil
    }
    if let localEventMonitor {
      NSEvent.removeMonitor(localEventMonitor)
      self.localEventMonitor = nil
    }
    if let resignActiveObserver {
      NotificationCenter.default.removeObserver(resignActiveObserver)
      self.resignActiveObserver = nil
    }
  }
}

private final class KeyableMenuBarPanel: NSPanel {
  var onEscapePressed: (() -> Void)?

  override var canBecomeKey: Bool { true }
  override var canBecomeMain: Bool { false }

  override func cancelOperation(_ sender: Any?) {
    onEscapePressed?()
  }
}

private final class FirstMouseHostingView<Content: View>: NSHostingView<Content> {
  override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
    true
  }
}
