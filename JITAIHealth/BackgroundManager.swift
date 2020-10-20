//
//  BackgroundManager.swift
//  JITAIHealth
//
//  Created by Sam Herring on 9/23/20.
//

import UIKit

class BackgroundManager: NSObject {
    
    // Build out datafile here, logging times, needs to run all in background!
    
    // Start of day method, call at some time in the morning.
    //      - pull events for the day, weather at start?
    //      - send event times to phone to prevent nudges during
    //      - start activity detection
    
    

    // Method called when weather context is pulled to write to file
    // - weather : [String : Any]
    // - time

    // These should happen at the same time for walking ^ v
    
    // Method called when a nudge is sent
    // - activity
    // - nudge type?
    // - time
    
    
    
    // Method called when a response is recieved
    // - response: String
    // - activity: String
    // - elapsed time: TimeInterval
    // - time
    

    
    // At the end of the day, call at night and/or when charging?
    //      - end activity detection
    //      - Send datafile to cloud

}
