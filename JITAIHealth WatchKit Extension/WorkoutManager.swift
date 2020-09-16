//
//  WorkoutManager.swift
//  JITAIHealth WatchKit Extension
//
//  Created by Sam Herring on 7/31/20.
//

import Foundation
import HealthKit
import CoreMotion

/**
 `WorkoutManagerDelegate` exists to inform delegates of swing data changes.
 These updates can be used to populate the user interface.
 */
protocol WorkoutManagerDelegate: class {
    //func didUpdateMovement(_ manager: WorkoutManager, data: [Double])
    func updateDataInController(_ manager: MotionManager, activity: Double, hr: Double)
}

// This class handles all healthKit information storing and workout tracking within the watch app.

class WorkoutManager: MotionManagerDelegate {
    
    // MARK: Properties
    let motionManager = MotionManager() // MotionManager instance to start motion data capture.
    let healthStore = HKHealthStore() // A general Health Store to track all movement data.
    
    let sampleType: Set<HKSampleType> = [HKSampleType.quantityType(forIdentifier: .heartRate)!] // Type of health sample data needed for heart rate detection.

    weak var delegate: WorkoutManagerDelegate? // This class' delegate.
    var session: HKWorkoutSession? // The main HKWorkoutSession, chage to ExtendedRuntime in future?
    
    var lastHeartRate = 0.0 // Storage for previous HR
    let beatCountPerMinute = HKUnit(from: "count/min") // HR units

    // MARK: Initialization
    
    init() {
        motionManager.delegate = self
        
        // Ask the user if we can utilize their health data in this app for heart rate (among others later)
        
        healthStore.requestAuthorization(toShare: sampleType, read: sampleType, completion: { (success, error) in
                    if success {
                        self.startHeartRateQuery(quantityTypeIdentifier: .heartRate)
                    }
                })
    }

    // MARK: WorkoutManager
    
    func startWorkout() {
        // If we have already started the workout, then do nothing.
        if (session != nil) {
            return
        }

        // Configure the workout session. Change these later?
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .play
        workoutConfiguration.locationType = .indoor

        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: workoutConfiguration) // Create HKWorkoutSession with created HealthStore
            
            // Run as extended session here?
            
        } catch {
            fatalError("Unable to create the workout session!")
        }

        // Start the workout session and device motion updates.
        
        session!.startActivity(with: Date.init()) // Start activity now
        motionManager.startUpdates() // Start updates in MotionManager.
    }

    func stopWorkout() {
        // If we have already stopped the workout, then do nothing.
        if (session == nil) {
            print("Session Already Nil")
            return
        }

        motionManager.stopUpdates()
        
        // Stop the device motion updates and workout session.
        session!.end()

        // Clear the workout session.
        session = nil
    }

    // MARK: MotionManagerDelegate
    
    // MotionManager and WorkoutManager delegates contain this function for the MotionManager to send activity data to the phone.
    
    func updateDataInController(_ manager: MotionManager, activity: Double) {
        delegate?.updateDataInController(manager, activity: activity, hr: lastHeartRate)
    }
    
    // This function begins querying for HR data in watch.
    
    public func startHeartRateQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier) {
        
        // Predicate for specific device
        
        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        
        // Create update handler with completion block to call process function.
        
        let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = {
            query, samples, deletedObjects, queryAnchor, error in
            
        // samples is result of HR query to watch with device predicate.
            guard let samples = samples as? [HKQuantitySample] else { return }
            
            //print("updating")
            
            self.process(samples, type: quantityTypeIdentifier) // Once recieved, process the samples.
        }
        
        // Create query to be executed on device.
        
        let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!, predicate: devicePredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
        
        query.updateHandler = updateHandler
        
        // Execute query with update and completion
        
        healthStore.execute(query)
    }
    
    // Function to process HR data within query
    
    private func process(_ samples: [HKQuantitySample], type: HKQuantityTypeIdentifier) {
        for sample in samples {
            if type == .heartRate { // If sample is HR data
                // Update variables, print
                
                lastHeartRate = sample.quantity.doubleValue(for: beatCountPerMinute)
                //print("❤ Last heart rate was: \(lastHeartRate)")
            }
            
            // Update UI labels (does nothing right now)
            //updateHeartRateLabel()
        }
    }

}
