//
//  NotificationManager.swift
//  JITAIHealth
//
//  Created by Sam Herring on 8/19/20.
//

import Foundation
import UserNotifications
import UIKit

class NotificationManager: NSObject, UNUserNotificationCenterDelegate  {
    
    // This class currently handles all notification pushing for the application and extension.
    
    override init() {
        super.init()
        //registerCategories()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        let confirm = UNNotificationAction(identifier: "confirm", title: "Yes, I am", options: .authenticationRequired)
        
        let deny = UNNotificationAction(identifier: "deny", title: "No, I am not", options: .destructive)
        
        let category = UNNotificationCategory(identifier: "nudge", actions: [confirm], intentIdentifiers: [])

        center.setNotificationCategories([category])
    }
    
    // The below method creates and pushes a notificationto the watch.
    
    func pushNotificationToWatch(activity: String) {
        
        let content = UNMutableNotificationContent()
        //UNNotificationAction
        content.title = "Hey there..."
        content.body = "It looks like you have been " + activity + "  for a while."
        
        if activity == "sitting" { content.subtitle = "You should stand up!" } else { content.subtitle = "Let's make it a longer walk!" }
        
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "nudge"
        content.userInfo["customData"] = "test data"
        
        let confirm = UNNotificationAction(identifier: "confirm", title: "Yes, I am " + activity, options: [])
        
        let deny = UNNotificationAction(identifier: "deny", title: "No, I am not " + activity, options: .destructive)
        
        let category = UNNotificationCategory(identifier: "nudge", actions: [confirm, deny], intentIdentifiers: [], options: .customDismissAction)

        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(identifier: "test", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        //UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //user clicked a response
        
        let userInfo = response.notification.request.content.userInfo

            if let customData = userInfo["customData"] as? String {
                print("Custom data received: \(customData)")

                switch response.actionIdentifier {
                case UNNotificationDefaultActionIdentifier:
                    print("Default identifier")
                    
                case "confirm":
                    print("user confirmed")
                    
                case "deny":
                    print("user denied")
                    
                case UNNotificationDismissActionIdentifier:
                    print("user dismissed")
                    
                default:
                    break
                }
            }
    }
}
