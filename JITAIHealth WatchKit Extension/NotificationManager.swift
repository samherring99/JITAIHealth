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
    
    var secondsElapsed = 0 // Placeholder for duration
    
    var secondsTimer: Timer? // TImer to measure duration
    
    var nudgeType = "" // Placeholder for nudge type
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    // The below method creates and pushes a notification to the watch.
    
    func pushNotificationToWatch(activity: String) {
        
        print("called~")
        
        //UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        InterfaceController.vm.sendMessageToPhone(type: "nudge", loc: InterfaceController.vm.fetchCurrentLocation(), data: ["time" : Date.init(), "nudge_type" : activity])
        
        nudgeType = activity
        
        secondsTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (t) in self.secondsElapsed += 1 } // Start Timer
        
        
        // CREATE NOTIFICATION - Can all be changed/reordered to fit our needs
        
        let content = UNMutableNotificationContent()
        content.title = "Hey there..."
        content.body = "It looks like you have been " + activity + "  for a while."
        
        if activity == "sitting" { content.subtitle = "You should stand up!" } else { content.subtitle = "Let's make it a longer walk!" }
        
        content.sound = UNNotificationSound.defaultCritical
        content.categoryIdentifier = "nudge"
        content.userInfo["customData"] = "test data"
        
        let confirm = UNNotificationAction(identifier: "confirm", title: "Yes, I am " + activity, options: []) // First button and title
        
        let deny = UNNotificationAction(identifier: "deny", title: "No, I am not " + activity, options: .destructive) // Second button and title
        
        let category = UNNotificationCategory(identifier: "nudge", actions: [confirm, deny], intentIdentifiers: [], options: .customDismissAction)

        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30, repeats: false)
        
        let request = UNNotificationRequest(identifier: "nudgeRequest", content: content, trigger: nil) // Send a nudge request with our data with no trigger (instant).
        
        UNUserNotificationCenter.current().add(request) { (error) in
            print(error)
        }
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // This method is called when a user clicked a response to nudge
        
        secondsTimer?.invalidate()
        
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
                // switch for types of responses
            }
        
        InterfaceController.vm.sendMessageToPhone(type: "response", loc: InterfaceController.vm.fetchCurrentLocation(), data: ["time" : Date.init(), "response" : response.actionIdentifier, "response_time" : secondsElapsed])
        
        print(nudgeType)
        print(secondsElapsed)
        print(response.actionIdentifier)
        
        UNUserNotificationCenter.current().removeAllDeliveredNotifications() // Nudge has been responded to so delete.
    }
    
    
}
