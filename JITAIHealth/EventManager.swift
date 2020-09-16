//
//  EventManager.swift
//  JITAIHealth
//
//  Created by Sam Herring on 9/1/20.
//

import UIKit
import EventKit

class EventManager: NSObject {
    
    let eventStore = EKEventStore()
    
    override init() {
        super.init()
        authorize()
    }
    
    // Authorize with the user to read event data, will only need to happen once as readEvents is called within, so it is called every time app is reinitialized.
    
    func authorize() {
        
        print("Authorizing")
        
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            readEvents()
        case .denied:
            print("Access denied")
        case .notDetermined:
            
            eventStore.requestAccess(to: .event, completion: { (granted: Bool, NSError) -> Void in
                if granted {
                    self.readEvents()
                    
                }else{
                    print("Access denied")
                }
            })
        default:
            print("Case Default")
        }
    }
    
    func readEvents() {
        let calendars = eventStore.calendars(for: .event)
        
        for calendar in calendars {
            let oneMonthAgo = NSDate(timeIntervalSinceNow: -30*24*3600)
            let oneMonthAfter = NSDate(timeIntervalSinceNow: +30*24*3600)
            
            let predicate = eventStore.predicateForEvents(withStart: oneMonthAgo as Date, end: oneMonthAfter as Date, calendars: [calendar])
            
            let events = eventStore.events(matching: predicate)
            
            for event in events {
                print(event.title as Any)
                print(event.startDate as Any)
                print(event.endDate as Any)
            }
        }
    }
    
    

}
