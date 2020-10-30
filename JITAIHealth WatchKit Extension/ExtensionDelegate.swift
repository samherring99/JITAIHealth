//
//  ExtensionDelegate.swift
//  JITAIHealth WatchKit Extension
//
//  Created by Sam Herring on 7/31/20.
//

import WatchKit
import UserNotifications
import UIKit
import CoreData

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        setupRemoteNotifications()
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
        
        //InterfaceControlle
        
        // Start extended session here
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                // Be sure to complete the relevant-shortcut task once you're done.
                relevantShortcutTask.setTaskCompletedWithSnapshot(false)
            case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                // Be sure to complete the intent-did-run task once you're done.
                intentDidRunTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
            let container = NSPersistentContainer(name: "JITAIStore")
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container
        }()

        // MARK: - Core Data Saving support
        func saveContext () {
            let context = persistentContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }

}

// MARK:  - Notification Methods

extension ExtensionDelegate: UNUserNotificationCenterDelegate {

    func setupRemoteNotifications() {

        UNUserNotificationCenter.current().delegate = self

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in

            print("Permission granted: \(granted)")

            guard granted else {
                DispatchQueue.main.async {
                    self.showNotificationsNotGrantedAlert()
                    return
                }
                return
            }

            self.getNotificationSettings()
        }
    }
    
    private func getNotificationSettings() {
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            
            print("Notification settings: \(settings)")
            
            guard settings.authorizationStatus == .authorized else { return }
            
            DispatchQueue.main.async {
                WKExtension.shared().registerForRemoteNotifications()
                //self.onRemoteNotificationRegistration()
            }
        }
    }
    
    func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
        
        // Convert token to string
        let deviceTokenString = deviceToken.map { data in String(format: "%02.2hhx", data) }.joined()
        
        print("Device Token: \(deviceTokenString)")
        
        //UserSettings.shared.deviceToken = deviceTokenString
    }
    
    func didReceiveRemoteNotification(_ userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (WKBackgroundFetchResult) -> Void) {
        print("Remote recieved")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

            print("Will present notification...")

            //let categoryIdentifier = notification.request.content.categoryIdentifier
            //center.add(notification.request, withCompletionHandler: nil)

        completionHandler([.banner, .badge, .sound])
            
        }
    
    private func showNotificationsNotGrantedAlert() {
        
        let settingsActionTitle = NSLocalizedString("Settings", comment: "")
        let cancelActionTitle = NSLocalizedString("Cancel", comment: "")
        let message = NSLocalizedString("You need to grant a permission from notification settings.", comment: "")
        let title = NSLocalizedString("Push Notifications Off", comment: "")
        
        let settingsAction = WKAlertAction(title: settingsActionTitle, style: .default) {
            
            print("[WATCH PUSH NOTIFICATIONS] Go to Notification Settings")
        }
        
        let cancelAction = WKAlertAction(title: cancelActionTitle, style: .cancel) {
            print("[WATCH PUSH NOTIFICATIONS] Cancel to go to Notification Settings")
        }
        
        WKExtension.shared().rootInterfaceController?.presentAlert(withTitle: title, message: message, preferredStyle: .alert, actions: [settingsAction, cancelAction])
    }
    
    
        
}
