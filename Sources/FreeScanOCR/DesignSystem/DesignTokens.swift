import AppKit
import SwiftUI

enum DesignSpacing {
  static let xxs: CGFloat = 4
  static let xs: CGFloat = 8
  static let sm: CGFloat = 12
  static let md: CGFloat = 16
  static let lg: CGFloat = 20
  static let xl: CGFloat = 24
  static let xxl: CGFloat = 32
}

enum DesignRadius {
  static let xs: CGFloat = 8
  static let sm: CGFloat = 12
  static let md: CGFloat = 16
  static let lg: CGFloat = 20
  static let pill: CGFloat = 999
}

enum SemanticStatusKind: Equatable, Sendable {
  case ready
  case active
  case success
  case warning
  case error

  var symbolName: String {
    switch self {
    case .ready: return "checkmark.seal"
    case .active: return "rays"
    case .success: return "checkmark.circle.fill"
    case .warning: return "exclamationmark.triangle.fill"
    case .error: return "xmark.octagon.fill"
    }
  }

  func foregroundColor(scheme: ColorScheme, contrast: ColorSchemeContrast) -> Color {
    let isHighContrast = (contrast == .increased)
    switch self {
    case .ready:
      return isHighContrast ? .primary : .secondary
    case .active:
      return .accentColor
    case .success:
      return isHighContrast
        ? (scheme == .dark ? Color(red: 0.35, green: 0.95, blue: 0.52) : Color(red: 0.04, green: 0.50, blue: 0.18))
        : .green
    case .warning:
      return isHighContrast
        ? (scheme == .dark ? Color(red: 1.0, green: 0.80, blue: 0.25) : Color(red: 0.68, green: 0.36, blue: 0.0))
        : .orange
    case .error:
      return isHighContrast
        ? (scheme == .dark ? Color(red: 1.0, green: 0.42, blue: 0.40) : Color(red: 0.76, green: 0.08, blue: 0.08))
        : .red
    }
  }
}

struct DesignTheme {
  let colorScheme: ColorScheme
  let contrast: ColorSchemeContrast
  let reduceTransparency: Bool
  let reduceMotion: Bool

  var isHighContrast: Bool {
    contrast == .increased
  }

  var prefersOpaqueSurfaces: Bool {
    reduceTransparency || contrast == .increased
  }

  var hairlineBorderColor: Color {
    if isHighContrast {
      return Color.primary.opacity(colorScheme == .dark ? 0.52 : 0.42)
    }
    return Color.primary.opacity(colorScheme == .dark ? 0.14 : 0.09)
  }

  var hairlineWidth: CGFloat {
    isHighContrast ? 1.5 : 1.0
  }

  var cardBackgroundColor: Color {
    if prefersOpaqueSurfaces {
      return Color(nsColor: .controlBackgroundColor)
    }
    return Color(nsColor: .quaternaryLabelColor).opacity(colorScheme == .dark ? 0.32 : 0.22)
  }

  var selectedCardBackgroundColor: Color {
    if isHighContrast {
      return Color.accentColor.opacity(colorScheme == .dark ? 0.34 : 0.20)
    }
    return Color.accentColor.opacity(colorScheme == .dark ? 0.20 : 0.12)
  }

  var selectedBorderColor: Color {
    isHighContrast ? Color.accentColor : Color.accentColor.opacity(0.65)
  }

  var keycapBackgroundColor: Color {
    if prefersOpaqueSurfaces {
      return Color(nsColor: .textBackgroundColor)
    }
    return Color.primary.opacity(colorScheme == .dark ? 0.12 : 0.06)
  }
}

enum DesignMotion {
  static func snappy(reduceMotion: Bool) -> Animation? {
    reduceMotion ? .easeOut(duration: 0.10) : .spring(duration: 0.26, bounce: 0.16)
  }

  static func fluid(reduceMotion: Bool) -> Animation? {
    reduceMotion ? .easeOut(duration: 0.14) : .spring(duration: 0.36, bounce: 0.12)
  }

  static func gentle(reduceMotion: Bool) -> Animation? {
    reduceMotion ? .easeOut(duration: 0.16) : .spring(duration: 0.42, bounce: 0.06)
  }
}

private struct AdaptiveGlassModifier<S: InsettableShape>: ViewModifier {
  let shape: S
  let interactive: Bool
  let tint: Color?

  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.colorSchemeContrast) private var contrast
  @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

  @ViewBuilder
  func body(content: Content) -> some View {
    let theme = DesignTheme(
      colorScheme: colorScheme,
      contrast: contrast,
      reduceTransparency: reduceTransparency,
      reduceMotion: false
    )

    if theme.prefersOpaqueSurfaces {
      content
        .background(theme.cardBackgroundColor, in: shape)
        .overlay(shape.strokeBorder(theme.hairlineBorderColor, lineWidth: theme.hairlineWidth))
    } else {
      let baseGlass: Glass = interactive ? Glass.regular.interactive() : Glass.regular
      let configuredGlass: Glass = tint.map { baseGlass.tint($0) } ?? baseGlass
      content
        .glassEffect(configuredGlass, in: shape)
    }
  }
}

private struct AdaptiveSurfaceCardModifier: ViewModifier {
  let cornerRadius: CGFloat
  let isSelected: Bool

  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.colorSchemeContrast) private var contrast
  @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

  @ViewBuilder
  func body(content: Content) -> some View {
    let theme = DesignTheme(
      colorScheme: colorScheme,
      contrast: contrast,
      reduceTransparency: reduceTransparency,
      reduceMotion: false
    )
    let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

    content
      .background(isSelected ? theme.selectedCardBackgroundColor : theme.cardBackgroundColor, in: shape)
      .overlay(
        shape.strokeBorder(
          isSelected ? theme.selectedBorderColor : theme.hairlineBorderColor,
          lineWidth: isSelected ? max(1.5, theme.hairlineWidth) : theme.hairlineWidth
        )
      )
  }
}

extension View {
  func adaptiveGlass<S: InsettableShape>(
    in shape: S,
    interactive: Bool = false,
    tint: Color? = nil
  ) -> some View {
    modifier(AdaptiveGlassModifier(shape: shape, interactive: interactive, tint: tint))
  }

  func adaptiveCard(cornerRadius: CGFloat = DesignRadius.md, isSelected: Bool = false) -> some View {
    modifier(AdaptiveSurfaceCardModifier(cornerRadius: cornerRadius, isSelected: isSelected))
  }
}

struct KeycapBadgesView: View {
  let shortcutText: String

  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.colorSchemeContrast) private var contrast
  @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

  private var tokens: [String] {
    var result: [String] = []
    var remaining = ""
    let modifiers: Set<Character> = ["⌃", "⌥", "⇧", "⌘"]
    for ch in shortcutText {
      if modifiers.contains(ch) {
        result.append(String(ch))
      } else {
        remaining.append(ch)
      }
    }
    let trimmed = remaining.trimmingCharacters(in: .whitespaces)
    if !trimmed.isEmpty {
      result.append(trimmed)
    }
    return result.isEmpty ? [shortcutText] : result
  }

  var body: some View {
    let theme = DesignTheme(
      colorScheme: colorScheme,
      contrast: contrast,
      reduceTransparency: reduceTransparency,
      reduceMotion: false
    )
    HStack(spacing: 4) {
      ForEach(Array(tokens.enumerated()), id: \.offset) { _, token in
        Text(token)
          .font(.system(size: 13, weight: .semibold, design: .rounded))
          .foregroundStyle(.primary)
          .padding(.horizontal, token.count > 1 ? 8 : 7)
          .frame(minWidth: 26, minHeight: 26)
          .background(
            theme.keycapBackgroundColor,
            in: RoundedRectangle(cornerRadius: 7, style: .continuous)
          )
          .overlay(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
              .strokeBorder(theme.hairlineBorderColor, lineWidth: theme.hairlineWidth)
          )
      }
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(shortcutText)
  }
}
