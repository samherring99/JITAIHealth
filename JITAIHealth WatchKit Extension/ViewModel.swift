//
//  ViewModel.swift
//  JITAIHealth WatchKit Extension
//
//  Created by Sam Herring on 7/31/20.
//

import Foundation
import CoreLocation

// Delegate to pass methods around
protocol ViewModelDelegate: class {
    func stopWorkoutUpdates()
    func startExtendedSession()
    func sendMessageToPhone(type: String, loc: CLLocation?, data: [String : Any])
    func fetchCurrentLocation() -> CLLocation?
}

// The ViewModel class allows for the sharing of key data elements between the SwiftUI View and the Hosting Controller

class ViewModel: ObservableObject {
    
    var delegate: ViewModelDelegate? // delegate reference
    
    var notifManager = NotificationManager() // instance of notification manager for reference
    
    var currentActivity: String? // Placeholder for current activity from the user.
    
    var lastResponse: String? // Placeholder for user response
    
    //Delegate toggle updates method
    
    func stopWorkoutUpdates() {
        delegate?.stopWorkoutUpdates()
    }
    
    // Delegate start extended session method
    
    func startExtendedSession() {
        delegate?.startExtendedSession()
    }
    
    // Send message to phone (used in data passing)
    
    func sendMessageToPhone(type: String, loc: CLLocation?, data: [String : Any]) {
        delegate?.sendMessageToPhone(type: type, loc: loc, data: data)
    }
    
    // Method to return the user's current location.
    
    func fetchCurrentLocation() -> CLLocation? {
        return delegate?.fetchCurrentLocation()
    }
}
