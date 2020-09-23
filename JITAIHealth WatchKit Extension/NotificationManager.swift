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
        UNUserNotificationCenter.current().delegate = self
    }
    
    // The below method creates and pushes a notification to the watch.
    
    func pushNotificationToWatch(activity: String) {
        
        print("called~")
        
        //UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        //UNNotificationAction
        content.title = "Hey there..."
        content.body = "It looks like you have been " + activity + "  for a while."
        
        if activity == "sitting" { content.subtitle = "You should stand up!" } else { content.subtitle = "Let's make it a longer walk!" }
        
        content.sound = UNNotificationSound.defaultCritical
        content.categoryIdentifier = "nudge"
        content.userInfo["customData"] = "test data"
        
        let confirm = UNNotificationAction(identifier: "confirm", title: "Yes, I am " + activity, options: [])
        
        let deny = UNNotificationAction(identifier: "deny", title: "No, I am not " + activity, options: .destructive)
        
        let category = UNNotificationCategory(identifier: "nudge", actions: [confirm, deny], intentIdentifiers: [], options: .customDismissAction)

        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
        
        let request = UNNotificationRequest(identifier: "test", content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            print(error)
        }
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        //user clicked a response
        
        let userInfo = response.notification.request.content.userInfo

            if let customData = userInfo["customData"] as? String {
                print("Custom data received: \(customData)")
                InterfaceController.vm.lastResponse = response.actionIdentifier
                switch response.actionIdentifier {
                case UNNotificationDefaultActionIdentifier:
                    print("Default identifier")
                    break
                case "confirm":
                    print("user confirmed")
                    break
                case "deny":
                    print("user denied")
                    break
                case UNNotificationDismissActionIdentifier:
                    print("user dismissed")
                    break
                default:
                    break
                }
            }
    }
}
