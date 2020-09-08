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
}

class GeoLocationManager: NSObject, CLLocationManagerDelegate, GeoLocationDelegate
{
    
    var locationManager:CLLocationManager
    var currentLocation:CLLocation?
    var newLocation:CLLocation?
    var nudgeOutcome:Bool
    
    var delegate: GeoLocationDelegate?
    
    override init()
    {
        nudgeOutcome = false
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        super.init()
        locationManager.delegate = self
        locationManager.requestLocation()
        locationManager.requestAlwaysAuthorization()
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
            InterfaceController.vm.notifManager.pushNotificationToWatch(activity: "walking")
            print(distance)
            self.nudgeOutcome = true
            
        }
        
    }
    
    func pauseLocationUpdates(currentActivity: String)
    {
        if currentActivity == "sitting"
        {
            self.locationManager.stopUpdatingLocation()
            print("Stopping walking updates")
        }
        if currentActivity == "walking"
        {
            self.locationManager.startUpdatingLocation()
            print("Starting walking updates")
        }
    }
    
    func toggleLocationUpdates(activity: String) {
        self.pauseLocationUpdates(currentActivity: activity)
    }
}
