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
    func startExtendedSession()
    func sendMessageToPhone(type: String, loc: CLLocation?, data: [String : Any])
    func fetchCurrentLocation() -> CLLocation?
}

// The ViewModel class allows for the sharing of key data elements between the SwiftUI View and the Hosting Controller

class ViewModel: ObservableObject {
    
    var delegate: ViewModelDelegate?
    
    var notifManager = NotificationManager()
    
    var currentActivity: String?
    
    var lastResponse: String?
    
    func stopWorkoutUpdates() {
        delegate?.stopWorkoutUpdates()
    }
    
    func startExtendedSession() {
        delegate?.startExtendedSession()
    }
    
    func sendMessageToPhone(type: String, loc: CLLocation?, data: [String : Any]) {
        delegate?.sendMessageToPhone(type: type, loc: loc, data: data)
    }
    
    func fetchCurrentLocation() -> CLLocation? {
        return delegate?.fetchCurrentLocation()
    }
}
