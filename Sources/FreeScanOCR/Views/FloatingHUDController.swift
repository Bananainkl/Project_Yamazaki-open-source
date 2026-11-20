import AppKit
import SwiftUI

struct FloatingHUDView: View {
  let model: AppStateModel
  let onAuthorizePermission: () -> Void

  @Namespace private var hudNamespace
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.colorSchemeContrast) private var contrast
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  var body: some View {
    let _ = model.uiRefreshToken
    let highLegibilityPrimary = colorScheme == .dark ? Color.white : Color.black
    let highLegibilitySecondary = colorScheme == .dark ? Color.white.opacity(0.76) : Color.black.opacity(0.68)

    GlassEffectContainer(spacing: DesignSpacing.xs) {
      if model.hudState != .hidden {
        hudCapsuleContent(primaryColor: highLegibilityPrimary, secondaryColor: highLegibilitySecondary)
          .padding(.horizontal, DesignSpacing.md)
          .padding(.vertical, 10)
          .adaptiveGlass(in: Capsule(), interactive: isInteractiveState)
          .glassEffectID("yamazaki-hud-pill", in: hudNamespace)
          .glassEffectTransition(.matchedGeometry)
      }
    }
    .environment(\.locale, LocalizedText.locale)
    .padding(DesignSpacing.sm)
    .animation(DesignMotion.fluid(reduceMotion: reduceMotion), value: model.hudState)
  }

  private var isInteractiveState: Bool {
    if case .permissionRequired = model.hudState {
      return true
    }
    return false
  }

  @ViewBuilder
  private func hudCapsuleContent(primaryColor: Color, secondaryColor: Color) -> some View {
    switch model.hudState {
    case .hidden:
      EmptyView()

    case .recognizing:
      HStack(spacing: DesignSpacing.xs) {
        ProgressView()
          .controlSize(.small)
        Text(LocalizedText.tr(.recognizingText))
          .font(.system(size: 13, weight: .semibold))
          .foregroundStyle(primaryColor)
          .lineLimit(1)
      }

    case .copied(let charCount, let preview, let eventID):
      HStack(spacing: DesignSpacing.xs) {
        Image(systemName: "checkmark.circle.fill")
          .font(.system(size: 15, weight: .semibold))
          .foregroundStyle(SemanticStatusKind.success.foregroundColor(scheme: colorScheme, contrast: contrast))
          .symbolEffect(.bounce, value: eventID)

        Text(LocalizedText.tr(.copiedCharsCount, charCount))
          .font(.system(size: 13, weight: .semibold))
          .foregroundStyle(primaryColor)
          .contentTransition(.numericText())
          .lineLimit(1)

        if !preview.isEmpty {
          Text("·")
            .foregroundStyle(secondaryColor)
          Text(preview)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(secondaryColor)
            .lineLimit(1)
            .frame(maxWidth: 220, alignment: .leading)
        }
      }

    case .emptyResult(let eventID):
      HStack(spacing: DesignSpacing.xs) {
        Image(systemName: "viewfinder.trianglebadge.exclamationmark")
          .font(.system(size: 15, weight: .semibold))
          .foregroundStyle(SemanticStatusKind.warning.foregroundColor(scheme: colorScheme, contrast: contrast))
          .symbolEffect(.bounce, value: eventID)

        Text(LocalizedText.tr(.noTextFound))
          .font(.system(size: 13, weight: .semibold))
          .foregroundStyle(primaryColor)
          .lineLimit(1)
      }

    case .permissionRequired:
      HStack(spacing: DesignSpacing.sm) {
        Image(systemName: "lock.shield.fill")
          .font(.system(size: 15, weight: .semibold))
          .foregroundStyle(SemanticStatusKind.warning.foregroundColor(scheme: colorScheme, contrast: contrast))

        Text(LocalizedText.tr(.needPermissionStatus))
          .font(.system(size: 13, weight: .semibold))
          .foregroundStyle(primaryColor)
          .lineLimit(1)

        Button(LocalizedText.tr(.grantPermissionButton)) {
          onAuthorizePermission()
        }
        .buttonStyle(.glassProminent)
        .controlSize(.small)
      }

    case .failed(let message, _):
      HStack(spacing: DesignSpacing.xs) {
        Image(systemName: "exclamationmark.octagon.fill")
          .font(.system(size: 15, weight: .semibold))
          .foregroundStyle(SemanticStatusKind.error.foregroundColor(scheme: colorScheme, contrast: contrast))

        Text(message)
          .font(.system(size: 12, weight: .medium))
          .foregroundStyle(primaryColor)
          .lineLimit(1)
          .frame(maxWidth: 320, alignment: .leading)
      }
    }
  }
}

@MainActor
final class FloatingHUDController {
  private let model: AppStateModel
  private let onAuthorizePermission: () -> Void
  private var panel: NSPanel?
  private var dismissTask: Task<Void, Never>?

  init(model: AppStateModel, onAuthorizePermission: @escaping () -> Void) {
    self.model = model
    self.onAuthorizePermission = onAuthorizePermission
  }

  func present(_ state: HUDPresentationState) {
    dismissTask?.cancel()
    dismissTask = nil

    guard AppPreferences.showFloatingHUD else {
      hideImmediately()
      return
    }

    ensurePanel()
    guard let panel else { return }

    model.hudState = state
    if case .permissionRequired = state {
      panel.ignoresMouseEvents = false
    } else {
      panel.ignoresMouseEvents = true
    }

    positionAtTopCenter(panel: panel)
    if !panel.isVisible {
      panel.alphaValue = 0
      panel.orderFrontRegardless()
      NSAnimationContext.runAnimationGroup { context in
        context.duration = 0.18
        panel.animator().alphaValue = 1
      }
    } else {
      panel.alphaValue = 1
      panel.orderFrontRegardless()
    }

    let autoDismissDelay: TimeInterval? = {
      switch state {
      case .hidden, .recognizing:
        return nil
      case .copied:
        return 2.1
      case .emptyResult:
        return 2.2
      case .permissionRequired:
        return 5.0
      case .failed:
        return 3.2
      }
    }()

    if let delay = autoDismissDelay {
      dismissTask = Task { @MainActor [weak self] in
        try? await Task.sleep(for: .seconds(delay))
        guard !Task.isCancelled else { return }
        self?.dismissAnimated()
      }
    }
  }

  func dismissAnimated() {
    dismissTask?.cancel()
    dismissTask = nil
    guard let panel, panel.isVisible else {
      model.hudState = .hidden
      return
    }

    NSAnimationContext.runAnimationGroup({ context in
      context.duration = 0.20
      panel.animator().alphaValue = 0
    }, completionHandler: { [weak self] in
      Task { @MainActor in
        self?.model.hudState = .hidden
        self?.panel?.orderOut(nil)
      }
    })
  }

  func hideImmediately() {
    dismissTask?.cancel()
    dismissTask = nil
    model.hudState = .hidden
    panel?.orderOut(nil)
  }

  private func ensurePanel() {
    guard panel == nil else { return }
    let panelWidth: CGFloat = 460
    let panelHeight: CGFloat = 68

    let panel = NSPanel(
      contentRect: NSRect(x: 0, y: 0, width: panelWidth, height: panelHeight),
      styleMask: [.borderless, .nonactivatingPanel],
      backing: .buffered,
      defer: false
    )
    panel.isFloatingPanel = true
    panel.level = .statusBar
    panel.backgroundColor = .clear
    panel.isOpaque = false
    panel.hasShadow = false
    panel.hidesOnDeactivate = false
    panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
    panel.contentView = NSHostingView(
      rootView: FloatingHUDView(model: model, onAuthorizePermission: onAuthorizePermission)
        .frame(width: panelWidth, height: panelHeight)
    )
    self.panel = panel
  }

  private func positionAtTopCenter(panel: NSPanel) {
    let mouseLocation = NSEvent.mouseLocation
    let activeScreen = NSScreen.screens.first(where: { NSMouseInRect(mouseLocation, $0.frame, false) })
      ?? NSScreen.main
      ?? NSScreen.screens.first
    guard let screen = activeScreen else { return }

    let visible = screen.visibleFrame
    let size = panel.frame.size
    let originX = visible.midX - size.width / 2
    let originY = visible.maxY - size.height - 12
    panel.setFrameOrigin(NSPoint(x: originX, y: originY))
  }
}
