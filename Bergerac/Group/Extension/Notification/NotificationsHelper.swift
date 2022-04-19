



import AppKit
import UserNotifications

/// This protocol gives guidlines to create a notification.
@available(tvOS, unavailable)
public protocol Notifiable {
    
    /// Identifiable id.
    var id: UUID { get } // swiftlint:disable:this identifier_name
    
    /// Notification title.
    var title: String { get set }
    
    /// Notification body.
    var body: String { get set }
    
    /// Notification subtitle.
    var subtitle: String { get set }
    
    /// Notification badge count.
    var badge: NSNumber { get set }
    
    /// Notification sound.
    @available(iOS 10.0, OSX 10.14, watchOS 3.0, *)
    var sound: UNNotificationSound? { get set }
    
    /// Notification meta data.
    var userInfo: [String: String] { get set }
    
    /// Notification category identifier.
    var categoryIdentifier: String { get set }
    
    /// Notification attachment path.
    var attachment: String? { get set }
    
    /// Notification attachment identifier.
    var attachmentIdentifier: String? { get set }
}

/// A helper struct with all the methods you need to create a user notification.
@available(iOS 10.0, OSX 10.14, tvOS 10.0, watchOS 3.0, *)
@available(tvOS, unavailable)
public struct NotificationsHelper {
    
    public init() {}
    
    private var notifications = [Notifiable]()
    
    /// This function checks if user has granted permission to get notifications.
    /// ~~~
    /// // Usage
    /// let notificationsHelper = NotificationsHelper()
    /// notificationsHelper.requestPermission(for: [.alert, .sound, .badge])
    /// ~~~
    /// - Parameters:
    ///     - authorization: provide `UNAuthorizationOptions`. By default it is `[]`.
    /// - Returns: `void`
    public func requestPermission(for authorization: UNAuthorizationOptions = []) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(
            options: authorization) { (permissionGranted, error) in
            guard let checkedError = error else {
                if !permissionGranted {
                    print("Notification permission denied")
                }
//                else {
//                    print("Notification permission granted")
//                }
                return
            }
            print("ERROR:::", checkedError.localizedDescription)
        }
    }
    
    ///  This function adds a notification to the notifications array
    ///  - Parameters:
    ///       - notification: provide a `Notifiable` type to *notification*
    ///  - Returns: `void`
    public mutating func addNotification(_ notification: Notifiable) {
        notifications.append(notification)
    }
    
    /// This function schedules a notification for a certain time interval
    /// - Precondition: Must add a notification to the notifications array
    /// - Parameters:
    ///      - timeInterval: *timeInterval* to schedule notification
    ///      - repeats: if notification should repeat
    /// Returns: `void`
    
    func scheduleNotification(timeInterval: Double, repeats: Bool)  {
        
        guard (repeats == true && timeInterval > 60) || (repeats == false && timeInterval > 0) else { return }
        
        let notifyCategoryIdentifier = "test"
        
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Test notification"
        content.body = "Message of test notification"
        content.categoryIdentifier = notifyCategoryIdentifier
        content.userInfo = ["customData": "test"]
        content.sound = UNNotificationSound.default
        
        //Create image with solid color
        let url = createImage(NSColor(red: 1, green: 0, blue: 0, alpha: 0.5), NSSize(width: 50, height: 50))
        
        //Add this image to attachment of notification for show in alert
        if let attachment = try? UNNotificationAttachment(identifier: "test", url: url, options: nil) {
            content.attachments = [attachment]
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: repeats)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    func createImage(_ color: NSColor, _ size: NSSize) -> URL {
        let image = NSImage(size: size)
        image.lockFocus()
        color.drawSwatch(in: NSRect(x: 0, y: 0, width: size.width, height: size.height))
        image.unlockFocus()
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("curtain", isDirectory: false)
        let _ = image.writeToFile(file: url, usingType: .png)
        return url;
    }

}
