//
//  ViewModel.swift
//  JITAIHealth WatchKit Extension
//
//  Created by Sam Herring on 7/31/20.
//

import Foundation
import CoreLocation

protocol ViewModelDelegate: class {
    func stopWorkoutUpdates()
    func sendTagToPhone(tag: String, loc: CLLocation?)
    func fetchCurrentLocation() -> CLLocation?
}

// The ViewModel class allows for the sharing of key data elements between the SwiftUI View and the Hosting Controller

class ViewModel: ObservableObject {
    
    var delegate: ViewModelDelegate?
    
    var notifManager = NotificationManager()
    
    var currentActivity: String?
    
    func stopWorkoutUpdates() {
        delegate?.stopWorkoutUpdates()
    }
    
    func sendTagToPhone(tag: String, loc: CLLocation?) {
        delegate?.sendTagToPhone(tag: tag, loc: loc)
    }
    
    func fetchCurrentLocation() -> CLLocation? {
        return delegate?.fetchCurrentLocation()
    }
}
