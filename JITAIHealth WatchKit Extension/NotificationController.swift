//
//  NotificationController.swift
//  JITAIHealth WatchKit Extension
//
//  Created by Sam Herring on 7/31/20.
//

import WatchKit
import Foundation
import UserNotifications

class NotificationController: WKUserNotificationInterfaceController {
    
    // Not really used as all notifications are programatically created.

    override init() {
        // Initialize variables here.
        super.init()
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }

    override func didReceive(_ notification: UNNotification) {
        // This method is called when a notification needs to be presented.
        // Implement it if you use a dynamic notification interface.
        // Populate your dynamic notification interface as quickly as possible.
        //print(notification.request)
        
        //notification.request.content.categoryIdentifie
    }
}
