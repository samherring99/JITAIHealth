//
//  ViewController.swift
//  JITAIHealth
//
//  Created by Sam Herring on 7/31/20.
//

import UIKit
import WatchConnectivity
import UserNotifications
import CoreLocation

class ViewController: UIViewController, WCSessionDelegate {
    
    // MARK: -  Initialization
    
    @IBOutlet var hrLabel: UILabel!
    @IBOutlet var activityLabel: UILabel!
    
    var session : WCSession? // WatchConnectivity Session
    
    var dataSource = [String]()
    
    var eventManager = EventManager()
    var weatherManager = WeatherManager()
    
    var previousActivity = -4.0
    
    //var geoManager = GeoLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
            
            // Above code activates the WC Session, below is debug UI
            
            activityLabel.text = "active"
            hrLabel.text = "recieving"
        }
    }
    
    // MARK: - WCSession code
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
        // WCSession is activated, watch and phone are connected.
        print("Session active")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("recieving")
        print(message["name"] as! String) //Here is where we want to do stuff with our location tags, can also change/add data if needed.
        let locationString: String = message["location"] as! String
        print(locationString)
        let latLong: [Substring] = locationString.split(separator: " ")
        
        // save latLong string to userData here^
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        
        let recievedData : [Double] = messageData.toArray(type: Double.self)
        
        // Update handler for WCSession message passing, called when phone recieves message update from watch.
        
        // Below is main case to display watch message.
        
        var activityTitle = ""
        
        DispatchQueue.main.async {
            switch recievedData[0] {
            case 0.0:
                print("sitting")
                activityTitle = "sitting"
                
            case 1.0:
                print("walking")
                activityTitle = "walking"
                
                if recievedData[2] != -1.0 && recievedData[3] != -1.0 {
                    
                    let weatherData: [String : Any] = self.weatherManager.fetchWeatherData(latitude: Double(recievedData[2]), longitude: Double(recievedData[3]))
                    print(weatherData)
                    
                }
                
            default:
                print("unknown")
                activityTitle = "unknown"
            }
            
            self.activityLabel.text = activityTitle
            
            print(recievedData[1])
            
            self.hrLabel.text = "HR: \(recievedData[1]) ❤️"
            
        }
        

    }
    
    // This method calls the manager's reference to toggle location updates.
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        // Session is connected but not active in watch.
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // Session is disconnected from watch.
    }
    
}

// External data utilities for message sending.  ALSO KEEP

// MARK: - Extensions

extension Data {

    init<T>(from value: T) {
        self = Swift.withUnsafeBytes(of: value) { Data($0) }
    }
    
    func to<T>(type: T.Type) -> T? where T: ExpressibleByIntegerLiteral {
        var value: T = 0
        guard count >= MemoryLayout.size(ofValue: value) else { return nil }
        _ = Swift.withUnsafeMutableBytes(of: &value, { copyBytes(to: $0)} )
        return value
    }
    
    init<T>(fromArray values: [T]) {
        self = values.withUnsafeBytes { Data($0) }
    }
    
    func toArray<T>(type: T.Type) -> [T] where T: ExpressibleByIntegerLiteral {
        var array = Array<T>(repeating: 0, count: self.count/MemoryLayout<T>.stride)
        _ = array.withUnsafeMutableBytes { copyBytes(to: $0) }
        return array
    }
}

