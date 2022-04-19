//
//  notificationCenter.swift
//  Bergerac
//
//  Created by thierryH24 on 15/01/2022.
//

import AppKit
import UserNotifications



final class notificationCenter : NSObject {
    
    static let shared = notificationCenter()

    private var center: UNUserNotificationCenter?
    private let notifyCategoryIdentifier = "test"
    
    func initNotifications() {
        guard let center = self.center else { return }
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                    // Define the custom actions.
                let byeAction = UNNotificationAction(identifier: NotificationActionsEnum.bye.rawValue, title: NSLocalizedString("Bye", comment: ""), options: UNNotificationActionOptions(rawValue: 0))
                let helloAction = UNNotificationAction(identifier: NotificationActionsEnum.sayHello.rawValue, title: NSLocalizedString("Hello", comment: ""), options: UNNotificationActionOptions(rawValue: 0))
                
                    // Define the notification type
                let testCategory = UNNotificationCategory(identifier: self.notifyCategoryIdentifier, actions: [byeAction, helloAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: .customDismissAction)
                center.setNotificationCategories([testCategory])
                
            } else {
                print("Authorization denied!  ", error?.localizedDescription ?? "error")
                return
            }
        }
    }

    func generateNotification (title:String, body:String, subtitle:String, sound:Bool)
    {
        let notificationCenter = UNUserNotificationCenter.current();
        notificationCenter.getNotificationSettings
        { (settings) in
            if settings.authorizationStatus == .authorized
            {
                //print ("Notifications Still Allowed");
                // build the banner
                let content = UNMutableNotificationContent()
                content.title = title
                content.body = body
                content.subtitle = subtitle
//                content.launchImageName = "AppIcon-1"

                if sound == true {
                    content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "eventually.m4r"))
                }
                content.badge = NSNumber(value: 20)
                    // could add .userInfo
                
                    // define when banner will appear - this is set to 1 second - note you cannot set this to zero
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false);
                
                // Create the request
                let uuidString = UUID().uuidString ;
                let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger);
                
                    // Schedule the request with the system.
                notificationCenter.add(request, withCompletionHandler:
                    { (error) in
                    if error != nil
                    {
                            // Something went wrong
                    }
                })
//                    print ("Notification Generated");
            }
        }
    }
}
