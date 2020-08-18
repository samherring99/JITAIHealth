//
//  ViewModel.swift
//  JITAIHealth WatchKit Extension
//
//  Created by Sam Herring on 7/31/20.
//

import Foundation

protocol ViewModelDelegate: class {
    func stopWorkoutUpdates()
    func sendTagToPhone(tag: String)
}

// The ViewModel class allows for the sharing of key data elements between the SwiftUI View and the Hosting Controller

class ViewModel: ObservableObject {
    
    var delegate: ViewModelDelegate?
    
    var currentActivity: String?
    
    func stopWorkoutUpdates() {
        delegate?.stopWorkoutUpdates()
    }
    
    func sendTagToPhone(tag: String) {
        delegate?.sendTagToPhone(tag: tag)
    }
}
