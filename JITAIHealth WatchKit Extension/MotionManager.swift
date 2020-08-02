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
    
    let motionActivityManager = CMMotionActivityManager() // TESTING
    let queue = OperationQueue()
    let wristLocationIsLeft = WKInterfaceDevice.current().wristLocation == .left

    // MARK: Application Specific Constants
    
    weak var delegate: MotionManagerDelegate?

    var recentDetection = false

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
                print("User is walking")
                prediction = 1.0
            }
            if (activity?.stationary)! {
                print("User is sitting")
                prediction = 0.0
            }
            if (activity?.unknown)! {
                print("Unknown activity")
                prediction = -1.0
            }
            
            self.sendDatatoDelegate(activity: prediction)
            
        }
        
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
