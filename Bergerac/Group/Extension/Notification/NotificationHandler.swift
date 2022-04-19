//
//  NotificationHandler.swift
//  NotificationTest
//
//  Created by Dmitry Mikhalchenkov on 23.10.2019.
//  Copyright © 2019 Dmitry MIkhaltchenkov. All rights reserved.
//

import Cocoa
import UserNotifications

class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        var text = ""
        switch response.actionIdentifier {
        case NotificationActionsEnum.bye.rawValue:
            text = NSLocalizedString("Bye", comment: "")
        case NotificationActionsEnum.sayHello.rawValue:
            text = NSLocalizedString("Hello", comment: "")
        default:
            text = "WTF?"
        }
        
        let alert = NSAlert()
        alert.informativeText = "Pushed button: \(text)"
        alert.messageText = "Notification actions"
        alert.runModal()

        completionHandler()
    }
    
    // Ensure the notifications are always shown
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler(UNNotificationPresentationOptions.banner)
    }
}
