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
    
    // Weather API Keys
    
    private let climacellBaseURL = "https://api.climacell.co/v3/locations"
    private let climacellRealtimeURL = "https://api.climacell.co/v3/weather/realtime"
    private let climacellAPIKey = "QmLFTZGhoHOiSGMjQtDNyqE7ZGfRiSB4"
    
    // Necessary location variables and distance measure.
    
    var locationManager:CLLocationManager
    var currentLocation:CLLocation?
    var newLocation:CLLocation?
    var nudgeOutcome:Bool
    
    var totalDistance:Int
    
    var updateTimer: Timer?
    
    var delegate: GeoLocationDelegate? // delegate adds ToggleUpdates method.
    
    override init()
    {
        nudgeOutcome = false
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        totalDistance = 0
        super.init()
        locationManager.delegate = self
        locationManager.requestLocation()
        locationManager.requestAlwaysAuthorization()
        delegate = self
        // Initialization, but dont start until user starts walking.
        //locationManager.startUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()// if only authorized when in use
        }
    }
    
     // Update location (user location changes)
    
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
            self.totalDistance += Int(self.newLocation?.distance(from: self.currentLocation!) ?? 0)  // increase totalDistance traveled.
            //decide to nudge or not
            
            // send data every so often
            
            //InterfaceController.vm.sendMessageToPhone(type: "walking", loc: InterfaceController.vm.fetchCurrentLocation(), data: ["time" : Date.init(), "distance" : totalDistance])
            
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
            
                // Above code fetches weather.
            
            print("Write walking nudge and weather data point")
            InterfaceController.vm.notifManager.pushNotificationToWatch(activity: "walking")
            print(distance as Any)
            self.nudgeOutcome = true
            
        }
        
    }
    
    // Main updating function called by Interface
    
    func pauseLocationUpdates(currentActivity: String)
    {
        // If sitting, user has finished walking
        if currentActivity == "sitting"
        {
            
            //self.writeLocationDistanceAndTimeToAlg(bounds: self.timeBounds)
            self.currentLocation = locationManager.location
            self.updateTimer = nil
            self.locationManager.stopUpdatingLocation()
            print("Stopping walking updates")
            self.nudgeOutcome = false
            self.totalDistance = 0
            
        }
        // If walking, user has just started walking
        if currentActivity == "walking"
        {
            self.locationManager.startUpdatingLocation()
            self.updateTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.writeWalkingData), userInfo: nil, repeats: true)
            print("Starting walking updates")
            print("Write start walking data point")
            
//            var weatherData: [String : Any] = [:]
//            weatherData = fetchWeatherData(latitude: currentLocation!.coordinate.latitude, longitude: currentLocation!.coordinate.longitude)
//
//            InterfaceController.vm.sendMessageToPhone(type: "start_walking", loc: InterfaceController.vm.fetchCurrentLocation(), data: ["time" : Date.init(), "weather" : weatherData])
        }
    }
    
    // This method writes a walking data point to the Interface controller with a set timer.
    @objc func writeWalkingData() {
        print("Writing walking data")
        InterfaceController.vm.sendMessageToPhone(type: "walking", loc: InterfaceController.vm.fetchCurrentLocation(), data: ["time" : Date.init(), "distance" : totalDistance])
    }
    
    // Delegate Method
    
    func toggleLocationUpdates(activity: String) {
        self.pauseLocationUpdates(currentActivity: activity)
    }
    
    // This method returns the user's current location.
    
    func fetchCurrentLocation() -> CLLocation? {
        locationManager.requestLocation()
        let cl: CLLocation? = locationManager.location
        //currentLocation = cl
        return cl ?? currentLocation
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
    
    // Fetch weather data method call when start walking or when threshold?
    
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
        // wait or conditional check?
        
        return dataFrame
    }
}
