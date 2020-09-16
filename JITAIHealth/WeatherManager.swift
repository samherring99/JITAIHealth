//
//  WeatherManager.swift
//  JITAIHealth
//
//  Created by Sam Herring and Ajith Vemuri on 9/16/20.
//

import Foundation
import UIKit
import CoreLocation

class WeatherManager: NSObject {
    
    private let climacellBaseURL = "https://api.climacell.co/v3/locations"
    private let climacellRealtimeURL = "https://api.climacell.co/v3/weather/realtime"
    private let climacellAPIKey = "QmLFTZGhoHOiSGMjQtDNyqE7ZGfRiSB4"
    
    override init() {
        super.init()
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
