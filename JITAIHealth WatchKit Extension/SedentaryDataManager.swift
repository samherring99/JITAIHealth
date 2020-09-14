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
    
    var delegate: SedentaryDataDelegate?
    var timer: Timer?
    var elapsedMinutes: Int = 0
    var secondsTime: Int = 0
    
    var isSedentary = false
    
    override init()
    {
        super.init()
    }
    
    func toggleSedentaryTimer(activity: String) {
        
        if (activity == "sitting") {
            // timer = 0, start
            print("creating timer")
            isSedentary = true
            
            //elapsedMinutes = 0
            
            DispatchQueue.main.async {
                self.timer = Timer.scheduledTimer(timeInterval: 1800, target: self, selector: #selector(self.calculateNudge), userInfo: nil, repeats: false)
            }
        } else {
            isSedentary = false
            print("stopping timer")
            timer?.invalidate()
            //self.timer = nil
        }
        
    }

}

// remove all below code, change firing to 10 min intervals.

extension SedentaryDataManager {
    @objc func calculateNudge() {
        // fire timer
        
        //self.elapsedMinutes += 1
        
        //print(self.elapsedMinutes)
        
        if (!isSedentary) {
            timer?.invalidate()
            //elapsedMinutes = 0
        } else {
            print("fire")
            InterfaceController.vm.notifManager.pushNotificationToWatch(activity: "sitting")
        }
    }
}