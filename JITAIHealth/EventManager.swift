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
    var busyTimes: [((Int, Int, Int), (Int, Int, Int))] = []
    
    
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
                    
                } else{
                    print("Access denied")
                }
            })
        default:
            print("Case Default")
        }
    }
    
    func resetBusyTimesArray() {
        busyTimes = []
    }
    
    // Helper function to convert seconds into HMS
    
    func secondsToHoursMinutesSeconds (seconds : Double) -> (Int, Int, Int) {
      return (Int(seconds) / 3600, (Int(seconds) % 3600) / 60, (Int(seconds) % 3600) % 60)
    }
    
    // Helper function to convert Date into HMS tuple
    
    func getHMSComponentsFromDate(date: Date!) -> (Int, Int, Int) {
        let current = Calendar.current
        
        let components = current.dateComponents([.hour, .minute, .second], from: date)
        
        return (components.hour!, components.minute!, components.second!)
    }
    
    // Main readEvents function, should be called every day at the same time of day.
    
    func readEvents() {
        let calendars = eventStore.calendars(for: .event)
        
        for calendar in calendars {
            print(calendar.title)
            let now = NSDate.now
            let oneDayAfter = NSDate(timeIntervalSinceNow: 24*3600)
            
            let predicate = eventStore.predicateForEvents(withStart: now as Date, end: oneDayAfter as Date, calendars: [calendar]) // read today's events in all calendars
            
            let events = eventStore.events(matching: predicate)
            
            print(events.count)
            
            for event in events {
                
                if !event.isAllDay {
                    
                    //print(event.startDate.compare(NSDate.now).rawValue)
                    
                    // Check if we are in start time
                    
                    if (event.startDate.compare(NSDate.now).rawValue > 0) {
                        
                        // If the event is still in the future
                        
                        print(event.title!)
                        
                        print(getHMSComponentsFromDate(date: event.startDate))
                        print(getHMSComponentsFromDate(date: event.endDate))
                        
                        let start = secondsToHoursMinutesSeconds(seconds: event.startDate.timeIntervalSinceNow)
                        let end = secondsToHoursMinutesSeconds(seconds: event.endDate.timeIntervalSinceNow)
                        
                        switch event.availability {
                            case .busy:
                                print("Busy") // Definitely pass times into array.
                                break
                            case .free:
                                print("Free") // Do not pass times into array.
                                break
                            case .tentative:
                                print("Tentative") // If event status is tentative?
                                break
                            case .unavailable:
                                print("Unavailable") // Assume add times
                                break
                            default:
                                print("nothing")
                        }
                        
                        print(event.status.rawValue) // .none = 0, .confirmed = 1, .tentative = 2 , .canceled = 3 probably not useful
                        
                    } else {
                        
                        // We are currently in event time, special case!
                        
                        print(event.title!)
                        
                        print(getHMSComponentsFromDate(date: event.startDate))
                        print(getHMSComponentsFromDate(date: event.endDate))
                        
                    }
                    
                    busyTimes.append((getHMSComponentsFromDate(date: event.startDate), getHMSComponentsFromDate(date: event.endDate)))
                }
            }
        }
    }
    
    

}
