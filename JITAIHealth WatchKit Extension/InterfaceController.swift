//
//  InterfaceController.swift
//  JITAIHealth WatchKit Extension
//
//  Created by Sam Herring on 7/31/20.
//

import WatchKit
import Foundation
import WatchConnectivity

// This is the main view controller for the Watch interface.

class InterfaceController: WKInterfaceController, WCSessionDelegate, WorkoutManagerDelegate, WKExtendedRuntimeSessionDelegate, ViewModelDelegate, SedentaryDataDelegate, GeoLocationDelegate {
    
    
    // MARK: - Initialization
    
    @IBOutlet var activityLabel: WKInterfaceLabel!
    
    var geoManager = GeoLocationManager()
    var sedManager = SedentaryDataManager()
    
    var previousActivity = -2.0
    
    let workoutManager = WorkoutManager() // Instance of a WorkoutManager to start workouts and motion
    var active = false // boolean indicating application active status
    var running = false // boolean indicating workout active status.
    
    static var vm = ViewModel() // Viewmodel instance for data passing
    
    var currentHR = 0
    
    var session = WCSession.default
    var extSession = WKExtendedRuntimeSession() // Extended runtime session instance
    
    var sessionTimer: Timer?

    override func awake(withContext context: Any?) {
        // Configure interface objects here. This method is called when the application is opened.
        
        session.delegate = self
        workoutManager.delegate = self
        extSession.delegate = self
        //geoManager.delegate = self
        sedManager.delegate = self
        InterfaceController.vm.delegate = self
        toggleSession()
        session.activate()
        print(extSession.state.rawValue)
    }
    
    // MARK: - Session code
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Session started")
        // Indicates WCSession starting with phone
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        // Recieved message data from phone.
    }
    
    // This method is used to start/stop extended session WorkoutManager use with a boolean variable.
    
    func toggleSession() {
        DispatchQueue.main.async {
            if !self.running {
                print("Workout started")
                self.workoutManager.startWorkout()
                self.running = true
            } else {
                print("Workout stopped")
                self.workoutManager.stopWorkout()
                self.running = false
            }
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        //print("Open")
        active = true
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        //print("Close")
        active = false
    }
    
    // This method is called in MotionManager to send activity data when updates happen.
    
    func updateDataInController(_ manager: MotionManager, activity: Double, hr: Double) {
        let currentLocation = InterfaceController.vm.fetchCurrentLocation()
        
        // Send data array of Doubles with activity float, heart rate, location latitute and location longitude
        
        let dataArray = [activity, hr, Double(currentLocation?.coordinate.latitude ?? -1.0), Double(currentLocation?.coordinate.longitude ?? -1.0)] as [Double]
        let data = Data(fromArray: dataArray)
        
        self.activityLabel.setText(InterfaceController.vm.currentActivity)
        
        // send currentLocation ->  (lat, long) + "START or END"
        
        if (activity == 0.0) {
            //nterfaceController.vm.startExtendedSession()
            //self.workoutManager.stopWorkout()
            //self.extSession.start()
            
            // call geomanager method to write start/end time and location into algorithm.
            
        } else if (activity == 1.0) {
            //self.workoutManager.startWorkout()
            //self.extSession.invalidate()
            self.sessionTimer = nil
        }
        
        self.toggleSedentaryTimer(activity: InterfaceController.vm.currentActivity ?? "")
        
        self.toggleLocationUpdates(activity: InterfaceController.vm.currentActivity ?? "")
        
        self.session.sendMessageData(data, replyHandler: nil, errorHandler: nil)
    }
    
    // Called from Interface controller through delegate to stop extended workout updates after application is closed.
    
    func stopWorkoutUpdates() {
        workoutManager.stopWorkout()
    }
    
    func toggleLocationUpdates(activity: String) {
        geoManager.toggleLocationUpdates(activity: activity)
    }
    
    func toggleSedentaryTimer(activity: String) {
        sedManager.toggleSedentaryTimer(activity: activity)
    }
    
    func startExtendedSession() {
        
        print(extSession.state.rawValue)
        
        if extSession.state.rawValue == 0 {
            extSession.start()
        }
        
    }
    
    // This is called from the Tag Controller when a location tag is pressed to send the data to the phone app.
    
    func sendMessageToPhone(tag: String, loc: CLLocation?, response: String) {
        var context: [String] = []
        
        if loc != nil {
            context = geoManager.isWithinRadiusOfTag(radius: 100.0)
        }
        
        let dataArray = ["type" : tag, "loc_context" : context, "response" : response] as [String : Any]
        
        self.session.sendMessage(dataArray, replyHandler: nil, errorHandler: { error in
            print(error)
        })
    }
    
    func fetchCurrentLocation() -> CLLocation? {
        return geoManager.fetchCurrentLocation()
    }
    
    @IBAction func stopExtendedSession() {
        InterfaceController.vm.stopWorkoutUpdates()
        self.extSession.invalidate()
        self.activityLabel.setText("quit app now")
    }
    
    // MARK: - Extended Runtime
    
    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: Error?) {
        
        print(reason)
        
    }
    
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("Started extended session")
        // Indicates the extended runtime has started.
        
//        DispatchQueue.main.async {
//            self.sessionTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { (t) in
//                self.toggleSedentaryTimer(activity: InterfaceController.vm.currentActivity ?? "")
//            }
//        }
        
    }
    
    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        // Indicates the end of the extended runtime sesssion.
        print("Extended session ended")
        self.sessionTimer = nil
    }
    
    

}

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
