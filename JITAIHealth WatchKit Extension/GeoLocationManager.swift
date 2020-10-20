//
//  GeoLocationManager.swift
//  JITAIHealth WatchKit Extension
//
//  Created by Ajith Vemuri on 8/12/20.
//

import Foundation
import CoreLocation

protocol GeoLocationDelegate: class {
    func toggleLocationUpdates(activity: String)
    //func fetchCurrentLocation() -> CLLocation?
}

class GeoLocationManager: NSObject, CLLocationManagerDelegate, GeoLocationDelegate
{
    
    private let climacellBaseURL = "https://api.climacell.co/v3/locations"
    private let climacellRealtimeURL = "https://api.climacell.co/v3/weather/realtime"
    private let climacellAPIKey = "QmLFTZGhoHOiSGMjQtDNyqE7ZGfRiSB4"
    
    var locationManager:CLLocationManager
    var currentLocation:CLLocation?
    var newLocation:CLLocation?
    var nudgeOutcome:Bool
    
    var totalDistance:Int
    
    var timeBounds: (Date, Date)
    
    var delegate: GeoLocationDelegate?
    
    override init()
    {
        nudgeOutcome = false
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        totalDistance = 0
        timeBounds = (Date.distantPast, Date.distantFuture)
        super.init()
        locationManager.delegate = self
        locationManager.requestLocation()
        locationManager.requestAlwaysAuthorization()
        delegate = self
        //locationManager.startUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
     // Update location
    
    
      func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation])
      {
         let latestLocation = locations.last!
        
        if self.currentLocation == nil
        {
            self.currentLocation = latestLocation
        }
        else
        {
            self.newLocation = latestLocation
            self.totalDistance += Int(self.newLocation?.distance(from: self.currentLocation!) ?? 0)
            //decide to nudge or not
            if !self.nudgeOutcome
            {
                computeNudge(currentActivity: "walking", threshold: 200)
            }
            
        }
         
      }
      // Error handling for locationManager, this method is called when user denies authorization for location
      func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
      {
         if let error = error as? CLError, error.code == .denied
         {
            // Location updates are not authorized.
            //manager.stopMonitoringSignificantLocationChanges() Not supported in WatchOS
              print("Fail to load location")
              print(error.localizedDescription)
              return
         }
         // Notify the user of any errors.
      }
    // Check distance threshold and nudge
    func computeNudge(currentActivity:String, threshold:Int)
    {
        //Doesn't work when user does roundtrips within threshold distance
        let distance = self.currentLocation?.distance(from: self.newLocation!)
        if Int(distance!) >= threshold
        {
            var weatherData: [String : Any] = [:]
            weatherData = fetchWeatherData(latitude: currentLocation!.coordinate.latitude, longitude: currentLocation!.coordinate.longitude)
            InterfaceController.vm.sendMessageToPhone(type: "weather", loc: currentLocation!, data: weatherData)
            InterfaceController.vm.notifManager.pushNotificationToWatch(activity: "walking")
            print(distance as Any)
            self.nudgeOutcome = true
            
        }
        
    }
    
    func afterDetection() {
        
    }
    
    func writeLocationDistanceAndTimeToAlg(bounds: (Date, Date)) {
        if totalDistance > 0  && bounds.0 != Date.distantPast {
            print(totalDistance)
            print(bounds.0.distance(to: bounds.1))
        }
    }
    
    func pauseLocationUpdates(currentActivity: String)
    {
        if currentActivity == "sitting"
        {
            self.timeBounds.1 = Date.init()
            self.writeLocationDistanceAndTimeToAlg(bounds: self.timeBounds)
            self.locationManager.stopUpdatingLocation()
            print("Stopping walking updates")
            self.currentLocation = nil
            self.totalDistance = 0
            self.timeBounds = (Date.distantPast, Date.distantFuture)
            
        }
        if currentActivity == "walking"
        {
            self.timeBounds = (Date.distantPast, Date.distantFuture)
            self.locationManager.startUpdatingLocation()
            self.timeBounds.0 = Date.init()
            print("Starting walking updates")
        }
    }
    
    func toggleLocationUpdates(activity: String) {
        self.pauseLocationUpdates(currentActivity: activity)
    }
    
    func fetchCurrentLocation() -> CLLocation? {
        locationManager.requestLocation()
        let cl: CLLocation? = locationManager.location
        //currentLocation = cl
        return cl
    }
    
    // This method checks to see if the user is within a certain radius of any tags, returns them in a list if yes, returns nil if user is in no tag radius distances.
    
    func isWithinRadiusOfTag(radius: Double) -> [String] {
        
        var actual: [String] = []
        
        if UserDefaults.standard.stringArray(forKey: "names") != nil {
            var names: [String] = UserDefaults.standard.stringArray(forKey: "names")!
            
            names.append(contentsOf: ["Home", "Work", "Gym", "Park", "Grocery Store"])
            
            for i in 1...names.count - 1 {
                
                if UserDefaults.standard.stringArray(forKey: names[i] + "_lat") != nil &&
                    UserDefaults.standard.stringArray(forKey: names[i] + "_long") != nil {
                    
                    let lats = UserDefaults.standard.stringArray(forKey: names[i] + "_lat")!
                    let longs = UserDefaults.standard.stringArray(forKey: names[i] + "_long")!
                    
                    for a in 0...lats.count - 1 {
                        
                        if lats[a] != "" && lats[a] != "" {
                            let lat = Float(lats[a])
                            let long = Float(longs[a])
                            
                            let tagLocation = CLLocation(latitude: CLLocationDegrees(lat!), longitude: CLLocationDegrees(long!))
                            
                            let cl = fetchCurrentLocation()
                            
                            if cl != nil {
                                let distance = cl!.distance(from: tagLocation)
                                
                                if (Double(distance) < radius) {
                                    actual.append(names[i])
                                }
                            }
                            
                            
                        }
                        
                    }
                    
                }
            }
        }
        
        return Array(Set(actual)) as [String]
    }
    
    func fetchWeatherData(latitude: Double, longitude: Double) -> [String : Any] {
        // This is a pretty simple networking task, so the shared session will do.
        let session = URLSession.shared
        
        var dataFrame: [String : Any] = [:]
        
        //let weatherRequestURL = URL(string: "\(climacellBaseURL)?APPID=\(climacellAPIKey)&q=\(latitude),\(longitude)")
        
        // 'fields' parameter isfound in documentation to get the correct data we need.
        
        let weatherRequestURL = URL(string: "\(climacellRealtimeURL)?unit_system=si&fields=temp,wind_speed&apikey=\(climacellAPIKey)&lat=\(latitude)&lon=\(longitude)")
        
        // The data task retrieves the data.
        let dataTask = session.dataTask(with: weatherRequestURL! as URL)
        {
            (data: Data?, response: URLResponse?, error: Error?) in
          if let error = error
          {
            // Case 1: Error
            // We got some kind of error while trying to get data from the server.
            print("Error:\n\(error)")
          }
          else
          {
            // Case 2: Success
            // We got a response from the server!
            print("Raw data:\n\(data!)\n")
            let dataString = String(data: data!, encoding: String.Encoding.utf8)
            print("Human-readable data:\n\(dataString!)")
            dataFrame["test"] = dataString!
          }
        }
        
        // The data task is set up...launch it!
        dataTask.resume()
        
        return dataFrame
      }
}
