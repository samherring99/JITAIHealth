//
//  SedentaryDataManager.swift
//  JITAIHealth WatchKit Extension
//
//  Created by Sam Herring on 8/26/20.
//

import WatchKit

protocol SedentaryDataDelegate: class {
    func toggleSedentaryTimer(activity: String)
}

// This sedentary inference manager simply starts a timer when the user's activity is "sitting" and sends a nudge notification at 30 minutes of stationary activity.

class SedentaryDataManager: NSObject, SedentaryDataDelegate {
    
    // delegate to import toggle function
    var delegate: SedentaryDataDelegate?
    
    var timer: Timer? // Sedentary timer instance
    var elapsedMinutes: Int = 0 // placeholder for duration
    
    var didFollow = false // Did the user respond to the nudge and follow through?
    
    var isSedentary = false
    
    override init()
    {
        super.init()
    }
    
    // Main updating method for sedentary data.
    
    func toggleSedentaryTimer(activity: String) {
        
        if (activity == "sitting") {
            
            isSedentary = true
            
            DispatchQueue.main.async {
                
                if (self.timer == nil) {
                    // User has just started sitting
                    print("creating timer")
                    print("Write start sitting data point")
                    
                    InterfaceController.vm.sendMessageToPhone(type: "start_sitting", loc: InterfaceController.vm.fetchCurrentLocation(), data: ["time" : Date.init()])
                    
                    self.timer = Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(self.calculateNudge), userInfo: nil, repeats: false) // 30 min timer that calls calculateNudge
                }
            }
        } else {
            // User has gotten up from sitting
            isSedentary = false
            timer?.invalidate()
            timer = nil
        }
        
    }

}

// MARK: Extensions

extension SedentaryDataManager {
    
    // Method called with 30 min timer, checks if user is still sitting, if yes notify, if not then move on.
    
    @objc func calculateNudge() {
        
        if (!isSedentary) {
            timer?.invalidate()
        } else {
            InterfaceController.vm.notifManager.pushNotificationToWatch(activity: "sitting")
            waitWithTimeForWalk(minutes: 10)
        }
    }
    
    // This method uses a given time limit to wait for the user to stand up from sitting
    
    func waitWithTimeForWalk(minutes: Int) {
        var seconds = 0
        DispatchQueue.main.async {
            let afterTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { (t) in
                
                seconds += 10
                
                print(seconds)
                
                if (InterfaceController.vm.currentActivity != "sitting") {
                    // User stood up and moved around
                    print("Write success sitting nudge data point")
                    
                    InterfaceController.vm.sendMessageToPhone(type: "sitting_follow", loc: InterfaceController.vm.fetchCurrentLocation(), data: ["time" : Date.init(), "success" : true, "time_elapsed" : seconds])
                    
                    self.didFollow = true
                    seconds = 0
                    t.invalidate()
                    self.timer = nil
                }
                
                if (seconds == minutes*60)  {
                    // User remained seated for the duration of the time limit.
                    self.didFollow = false
                    t.invalidate()
                    
                    print("Write failure user kept sitting data point")
                    
                    InterfaceController.vm.sendMessageToPhone(type: "sitting_follow", loc: InterfaceController.vm.fetchCurrentLocation(), data: ["time" : Date.init(), "success" : false, "time_elapsed" : seconds])
                    
                    seconds = 0
                    self.timer = nil
                    self.toggleSedentaryTimer(activity: InterfaceController.vm.currentActivity ?? "")
                }
                
            }
        }
    }
    
}
