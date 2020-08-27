//
//  NotificationManager.swift
//  JITAIHealth
//
//  Created by Sam Herring on 8/19/20.
//

import Foundation
import UserNotifications
import UIKit

class NotificationManager: NSObject  {
    
    // This class currently handles all notification pushing for the application and extension.
    
    override init() {
        super.init()
    }
    
    
    
    // The below method creates and adds a test notification.
    
    func pushNotificationToWatch() {
        print("CALLED")
        let content = UNMutableNotificationContent()
        content.title = "This is a Test Title!"
        content.body = "This is a test nudge!"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(identifier: "test", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        //UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
    }
}
