import FirebaseCore
import FirebaseMessaging
import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, MessagingDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()

    // FCM: APNs token bridge + foreground notifications
    Messaging.messaging().delegate = self
    UNUserNotificationCenter.current().delegate = self

    GeneratedPluginRegistrant.register(with: self)

    // Permission Dart se (requestPermission); phir APNs register — token FCM ke liye zaroori
    application.registerForRemoteNotifications()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// APNs device token → Firebase (bina iske iOS par FCM token nahi milta)
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    debugPrint("APNs register failed: \(error.localizedDescription)")
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }

  // MARK: - UNUserNotificationCenterDelegate (foreground banner)
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .badge, .sound, .list])
    } else {
      completionHandler([.alert, .badge, .sound])
    }
  }

  // MARK: - MessagingDelegate (optional: token refresh log)
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    debugPrint("FCM registration token: \(fcmToken ?? "")")
    NotificationCenter.default.post(
      name: Notification.Name("FCMToken"),
      object: nil,
      userInfo: ["token": fcmToken ?? ""]
    )
  }
}
