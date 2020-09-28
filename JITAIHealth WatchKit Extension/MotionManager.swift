//
//  MotionManager.swift
//  JITAIHealth WatchKit Extension
//
//  Created by Sam Herring on 7/31/20.
//

import Foundation
import CoreMotion
import WatchKit

/**
 `MotionManagerDelegate` exists to inform delegates of motion changes.
 These contexts can be used to enable application specific behavior.
 */
protocol MotionManagerDelegate: class {
    //func didUpdateMovement(_ manager: MotionManager, data: [Double])
    func updateDataInController(_ manager: MotionManager, activity: Double)
}

class MotionManager {
    // MARK: Properties
    
    let motionActivityManager = CMMotionActivityManager()
    let queue = OperationQueue()
    let wristLocationIsLeft = WKInterfaceDevice.current().wristLocation == .left

    // MARK: Application Specific Constants
    
    weak var delegate: MotionManagerDelegate?

    var recentDetection = false
    
    var previousDetection = -2.0

    // MARK: Initialization
    
    init() {
        // Serial queue for sample handling and calculations.
        queue.maxConcurrentOperationCount = 1
        queue.name = "MotionActivityManagerQueue"
    }

    // MARK: Motion Manager

    func startUpdates() {
        
        var prediction = -1.0
        
        print("Starting updates")
        
        
        if !CMMotionActivityManager.isActivityAvailable() {
            return
        }
        
        motionActivityManager.startActivityUpdates(to: queue) { (activity) in
            
            if (activity?.walking)! {
                //print("User is walking")
                InterfaceController.vm.currentActivity = "walking"
                prediction = 1.0
            }
            
            //Check driving for fall through
            
            if (activity?.automotive)! {
                InterfaceController.vm.currentActivity = "driving"
                prediction = -1.0
            }
            
            if (activity?.stationary)! {
                //print("User is sitting")
                
                InterfaceController.vm.currentActivity = "sitting"
                prediction = 0.0
                
            }
            
            if (activity?.unknown)! {
                //print("Unknown activity")
                InterfaceController.vm.currentActivity = "unknown"
                prediction = -1.0
            }
            
            if prediction != self.previousDetection {
                self.sendDatatoDelegate(activity: prediction)
                self.previousDetection = prediction
            }
            
            
            // Send message activity
            
            
            
        }
        
    }
    
    func stopUpdates() {
        motionActivityManager.stopActivityUpdates()
    }

    // MARK: Data and Delegate Management
    
    // Resets all variables and updates movement data in hosting controller.
    
    func resetAllState() {
        recentDetection = false
    }
    
    func sendDatatoDelegate(activity: Double) {
        delegate?.updateDataInController(self, activity: activity)
    }
    
}
