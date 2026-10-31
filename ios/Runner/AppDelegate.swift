import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    excludePreferencesFromBackup()
    NotificationCenter.default.addObserver(
      self, selector: #selector(applicationBecameActive),
      name: UIApplication.didBecomeActiveNotification, object: nil
    )
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  @objc private func applicationBecameActive() {
    excludePreferencesFromBackup()
  }

  // Flutter's shared_preferences plugin uses standard UserDefaults. Some
  // settings contain personal nutrition information. Excluding the parent
  // directory also covers defaults files that are atomically replaced later.
  private func excludePreferencesFromBackup() {
    do {
      let library = try FileManager.default.url(
        for: .libraryDirectory, in: .userDomainMask,
        appropriateFor: nil, create: true
      )
      var preferences = library.appendingPathComponent("Preferences", isDirectory: true)
      try FileManager.default.createDirectory(
        at: preferences, withIntermediateDirectories: true
      )
      var values = URLResourceValues()
      values.isExcludedFromBackup = true
      try preferences.setResourceValues(values)
    } catch {
      NSLog("Could not exclude app preferences from backup: %@", String(describing: error))
    }
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
