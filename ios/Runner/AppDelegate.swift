import Flutter
import UIKit
import FirebaseMessaging

#if canImport(DeclaredAgeRange)
import DeclaredAgeRange
#endif

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let ageSignals = AgeSignalsBridge()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let registrar = self.registrar(forPlugin: "MemokoAgeSignals") {
      ageSignals.register(messenger: registrar.messenger())
    }

    // Set up push notification delegate after Flutter plugins are registered
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    // Register for remote notifications
    application.registerForRemoteNotifications()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Handle APNs token registration
  override func application(_ application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }
}

/// iOS side of the "memoko/age_signals" channel; Android's is MainActivity.kt.
///
/// US state app store laws (Texas SB 2420) ask apps to check the user's age
/// with the App Store's data. Apple's Declared Age Range answers on iOS 26+,
/// and its regulatory calls only in builds made with the iOS 26.2 SDK or
/// later; everywhere else this reports no signal and the app keeps using its
/// own age screen. The compiler guards follow the MIT-licensed
/// age_range_signals plugin (github.com/zigapovhe), which needs a newer
/// Flutter than this app uses: Xcode 26.2 ships Swift 6.2.3, Xcode 26.4
/// ships Swift 6.3.
///
/// The app never asks a parent for approval through PermissionKit: a minor
/// whose parent must approve significant changes simply never gets the ads
/// and the purchase that the change added.
final class AgeSignalsBridge {
  // AgeSignalsStatus values shared with Android.
  private static let statusShared = 1
  private static let statusNotShared = 2
  // SignificantChangeStatus.PENDING, shared with Android.
  private static let changePending = 2

  func register(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "memoko/age_signals", binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { return }
      switch call.method {
      case "requestAccess": self.requestAccess(result)
      case "check": self.check(result)
      case "acknowledgeUpdate": self.acknowledgeUpdate(call, result)
      default: result(FlutterMethodNotImplemented)
      }
    }
  }

  /// Asks iOS, without any UI, whether the law where the user lives requires
  /// an age range. Only then does "check" show Apple's sharing prompt, so
  /// people elsewhere never see it.
  private func requestAccess(_ result: @escaping FlutterResult) {
    #if canImport(DeclaredAgeRange) && compiler(>=6.3)
    if #available(iOS 26.4, *) {
      Task { @MainActor in
        do {
          let features = try await AgeRangeService.shared.requiredRegulatoryFeatures
          result([
            "status": features.contains(.declaredAgeRangeRequired)
              ? Self.statusShared : Self.statusNotShared,
            "parentalConsentRequired": features.contains(.significantAppChangeRequiresParentalConsent),
            "adultNotificationRequired": features.contains(.significantAppChangeRequiresAdultNotification),
          ])
        } catch {
          result(["errorCode": -1])
        }
      }
      return
    }
    #endif
    #if canImport(DeclaredAgeRange) && compiler(>=6.2.3)
    if #available(iOS 26.2, *) {
      Task { @MainActor in
        // Can hang on some 26.2 builds; the Dart side times out.
        let eligible = (try? await AgeRangeService.shared.isEligibleForAgeFeatures) ?? false
        result(["status": eligible ? Self.statusShared : Self.statusNotShared])
      }
      return
    }
    #endif
    result(["status": Self.statusNotShared])
  }

  /// Apple's age range for the user, with gates at 13, 16 and 18 (the
  /// Texas categories). Shows Apple's sharing prompt.
  private func check(_ result: @escaping FlutterResult) {
    #if canImport(DeclaredAgeRange)
    if #available(iOS 26.0, *) {
      Task { @MainActor in
        guard let presenter = Self.topViewController() else {
          result(["errorCode": -1])
          return
        }
        do {
          let response = try await AgeRangeService.shared.requestAgeRange(
            ageGates: 13, 16, 18,
            in: presenter
          )
          switch response {
          case .sharing(let range):
            var map: [String: Any] = [:]
            // A missing lower bound means "below the lowest gate".
            if let lower = range.lowerBound ?? (range.upperBound == nil ? nil : 0) {
              map["ageLower"] = lower
            }
            if let upper = range.upperBound {
              map["ageUpper"] = upper
            }
            var approvalRequired = false
            #if compiler(>=6.2.3)
            if #available(iOS 26.2, *) {
              approvalRequired = range.activeParentalControls.contains(.significantAppChangeApprovalRequired)
            }
            #endif
            if approvalRequired {
              map["significantChangeStatus"] = Self.changePending
            }
            result(map)
          case .declinedSharing:
            result(["errorCode": -2])
          @unknown default:
            result(["errorCode": -1])
          }
        } catch {
          result(["errorCode": -1])
        }
      }
      return
    }
    #endif
    result(["errorCode": -1])
  }

  /// Apple's sheet that tells an adult about a significant update, where
  /// the law asks for it. Returns whether it was shown.
  private func acknowledgeUpdate(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    #if canImport(DeclaredAgeRange) && compiler(>=6.3)
    if #available(iOS 26.4, *) {
      guard let args = call.arguments as? [String: Any],
            let description = args["description"] as? String,
            !description.isEmpty,
            let scene = Self.activeScene() else {
        result(false)
        return
      }
      Task { @MainActor in
        do {
          try await AgeRangeService.shared.showSignificantUpdateAcknowledgment(
            in: scene,
            updateDescription: description
          )
          result(true)
        } catch {
          result(false)
        }
      }
      return
    }
    #endif
    result(false)
  }

  private static func activeScene() -> UIWindowScene? {
    UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .first { $0.activationState == .foregroundActive }
  }

  private static func topViewController() -> UIViewController? {
    guard let root = activeScene()?.windows.first(where: { $0.isKeyWindow })?.rootViewController
      ?? UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController
    else { return nil }
    var top = root
    while let presented = top.presentedViewController {
      top = presented
    }
    return top
  }
}
