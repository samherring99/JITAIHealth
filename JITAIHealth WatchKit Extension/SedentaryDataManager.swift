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
    
    var didFollow = false
    
    var isSedentary = false
    
    override init()
    {
        super.init()
    }
    
    func toggleSedentaryTimer(activity: String) {
        
        if (activity == "sitting") {
            // timer = 0, start
            isSedentary = true
            
            DispatchQueue.main.async {
                
                if (self.timer == nil) {
                    print("creating timer")
                    self.timer = Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(self.calculateNudge), userInfo: nil, repeats: false)
                }
                // Repeating timer every 30 min? 
            }
        } else {
            isSedentary = false
            print("not sitting")
            timer?.invalidate()
        }
        
    }

}

extension SedentaryDataManager {
    @objc func calculateNudge() {
        
        if (!isSedentary) {
            timer?.invalidate()
        } else {
            InterfaceController.vm.notifManager.pushNotificationToWatch(activity: "sitting")
            waitWithTimeForWalk(minutes: 10)
        }
    }
    
    func waitWithTimeForWalk(minutes: Int) {
        print("waiting")
        var seconds = 0
        DispatchQueue.main.async {
            let afterTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { (t) in
                
                seconds += 10
                
                print(seconds)
                
                if (InterfaceController.vm.currentActivity == "walking") {
                    self.didFollow = true
                    seconds = 0
                    t.invalidate()
                    self.timer = nil
                }
                
                if (seconds == minutes*60)  {
                    self.didFollow = false
                    seconds = 0
                    t.invalidate()
                    print("Failed")
                    self.timer = nil
                }
                
            }
        }
    }
    
}
