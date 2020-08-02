//
//  ViewModel.swift
//  JITAIHealth WatchKit Extension
//
//  Created by Sam Herring on 7/31/20.
//

import Foundation

protocol ViewModelDelegate: class {
    func stopWorkoutUpdates()
}

// The ViewModel class allows for the sharing of key data elements between the SwiftUI View and the Hosting Controller

class ViewModel: ObservableObject {
    
    var delegate: ViewModelDelegate?
    
    func stopWorkoutUpdates() {
        delegate?.stopWorkoutUpdates()
    }
}
