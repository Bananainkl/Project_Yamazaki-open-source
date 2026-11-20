import AppKit
import SwiftUI

struct MenuBarPanelView: View {
  let model: AppStateModel
  let actions: SettingsActions
  let onDismissPanel: () -> Void

  @State private var copiedItemID: UUID?
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.colorSchemeContrast) private var contrast
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

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
    .fixedSize(horizontal: false, vertical: model.recentHistory.isEmpty)
    .environment(\.appearsActive, true)
    .environment(\.locale, LocalizedText.locale)
    .animation(DesignMotion.fluid(reduceMotion: reduceMotion), value: model.recentHistory.count)
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
            triggerAfterDismiss(actions.captureSelection)
          } label: {
            VStack(alignment: .leading, spacing: DesignSpacing.xs) {
              HStack {
                Image(systemName: "viewfinder")
                  .font(.system(size: 16, weight: .semibold))
                Spacer()
                Text(model.shortcutText)
                  .font(.system(size: 11, weight: .semibold, design: .rounded))
                  .opacity(0.88)
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
            triggerAfterDismiss(actions.translateSelection)
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
          triggerAfterDismiss(actions.recognizeClipboard)
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
        .frame(maxHeight: 216)
      }
    }
  }

  private func triggerAfterDismiss(_ action: @escaping () -> Void) {
    onDismissPanel()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
      action()
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
