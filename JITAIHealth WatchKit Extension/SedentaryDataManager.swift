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
    
    override init()
    {
        super.init()
    }
    
    func toggleSedentaryTimer(activity: String) {
        
        if (activity == "sitting") {
            // timer = 0, start
            print("creating timer")
            
            secondsTime = 0
            elapsedMinutes = 0
            
            DispatchQueue.main.async {
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
            }
        } else {
            print("stopping timer")
            timer?.invalidate()
        }
        
    }

}

extension SedentaryDataManager {
    @objc func updateTimer() {
        // fire timer
        self.secondsTime += 1
        
        //print(self.secondsTime)
        
        if self.secondsTime % 60 == 0 {
            
            self.elapsedMinutes += 1
            
            if (self.elapsedMinutes == 30) {
                timer?.invalidate()
                InterfaceController.vm.notifManager.pushNotificationToWatch(activity: "sitting")
            }
            
        }
    }
}
