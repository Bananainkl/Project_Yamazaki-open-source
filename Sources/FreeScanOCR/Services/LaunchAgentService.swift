import Foundation

enum LaunchAgentService {
  private static let label = "com.itou.yamazaki.watchdog"
  private static let legacyLabel = "com.itou.yamazaki.keepalive"

  private static var agentURL: URL {
    FileManager.default.homeDirectoryForCurrentUser
      .appendingPathComponent("Library/LaunchAgents/\(label).plist")
  }

  private static var legacyAgentURL: URL {
    FileManager.default.homeDirectoryForCurrentUser
      .appendingPathComponent("Library/LaunchAgents/\(legacyLabel).plist")
  }

  private static var launchdDomain: String {
    "gui/\(getuid())"
  }

  static func setStartAtLoginEnabled(_ isEnabled: Bool) {
    AppPreferences.startAtLogin = isEnabled
    refreshLaunchAgent()
  }

  static func setAutoRestartEnabled(_ isEnabled: Bool) {
    AppPreferences.autoRestart = isEnabled
    refreshLaunchAgent()
  }

  static func refreshLaunchAgent() {
    guard AppPreferences.startAtLogin || AppPreferences.autoRestart else {
      unloadAndRemove()
      return
    }
    installAndLoad()
  }

  private static func installAndLoad() {
    guard writePlist() else { return }
    runLaunchctl(arguments: ["bootout", "\(launchdDomain)/\(label)"])
    runLaunchctl(arguments: ["bootstrap", launchdDomain, agentURL.path])
    removeLegacyAgent()
  }

  @discardableResult
  private static func writePlist() -> Bool {
    guard let appBundlePath = preferredAppBundlePath() else { return false }
    let mode = AppPreferences.autoRestart ? "watch" : "launch-once"
    let watcherScript = """
    app_path="$1"
    mode="$2"

    launch_if_needed() {
      if ! /usr/bin/pgrep -x Yamazaki >/dev/null 2>&1; then
        /usr/bin/open -g "$app_path"
      fi
    }

    launch_if_needed
    if [ "$mode" = "watch" ]; then
      while :; do
        /bin/sleep 2
        launch_if_needed
      done
    fi
    """
    let plist: [String: Any] = [
      "Label": label,
      "ProgramArguments": [
        "/bin/sh",
        "-c",
        watcherScript,
        "yamazaki-watchdog",
        appBundlePath,
        mode
      ],
      "RunAtLoad": true,
      "KeepAlive": AppPreferences.autoRestart,
      "LimitLoadToSessionType": "Aqua",
      "ProcessType": "Background",
      "ThrottleInterval": 2
    ]

    do {
      let data = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
      try FileManager.default.createDirectory(
        at: agentURL.deletingLastPathComponent(),
        withIntermediateDirectories: true
      )
      try data.write(to: agentURL, options: .atomic)
      return true
    } catch {
      NSLog("Failed to install LaunchAgent: \(error.localizedDescription)")
      return false
    }
  }

  private static func unloadAndRemove() {
    runLaunchctl(arguments: ["bootout", "\(launchdDomain)/\(label)"])
    try? FileManager.default.removeItem(at: agentURL)
    removeLegacyAgent()
  }

  private static func preferredAppBundlePath() -> String? {
    let installedPath = "/Applications/\(ProductInfo.appName).app"
    if FileManager.default.fileExists(atPath: installedPath) {
      return installedPath
    }
    let bundlePath = Bundle.main.bundlePath
    return FileManager.default.fileExists(atPath: bundlePath) ? bundlePath : nil
  }

  private static func removeLegacyAgent() {
    try? FileManager.default.removeItem(at: legacyAgentURL)
    runLaunchctlAsync(arguments: ["bootout", "\(launchdDomain)/\(legacyLabel)"])
  }

  private static func runLaunchctl(arguments: [String]) {
    DispatchQueue.global(qos: .utility).async {
      let process = Process()
      process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
      process.arguments = arguments
      do {
        try process.run()
        process.waitUntilExit()
      } catch {
        NSLog("launchctl failed: \(error.localizedDescription)")
      }
    }
  }

  private static func runLaunchctlAsync(arguments: [String]) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
    process.arguments = arguments
    try? process.run()
  }
}
