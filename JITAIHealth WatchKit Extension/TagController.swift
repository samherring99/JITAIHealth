//
//  TagController.swift
//  JITAIHealth WatchKit Extension
//
//  Created by Sam Herring on 8/18/20.
//

import WatchKit
import Foundation


class TagController: WKInterfaceController, GeoLocationDelegate {

    @IBOutlet var table: WKInterfaceTable!
    
    @IBOutlet var entryField: WKInterfaceTextField!
    
    var locationList: [String]!
    
    var delegate: GeoLocationDelegate?
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure the table  with list of possible locations
        
        locationList = ["Home", "Work", "Gym", "Park", "Grocery Store"]
        table.setNumberOfRows(locationList.count, withRowType: "locationRow")
        
        for index in 0..<table.numberOfRows {
            guard let controller = table.rowController(at: index) as? TagRowController else { continue }

          controller.location = locationList[index]
        }
        
        entryField.setWidth(contentFrame.width)
        entryField.setText("")
        entryField.setPlaceholder("Other")
        entryField.setTextColor(UIColor.darkGray)
        
        // Configure interface objects here.
    }
    
    // Called when the user selects a row
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        print("On Watch: " + locationList[rowIndex])
        let current: CLLocation? = InterfaceController.vm.fetchCurrentLocation()
        InterfaceController.vm.sendTagToPhone(tag: locationList[rowIndex], loc: current)
        self.dismiss()
    }
    
    @IBAction func didEnter(_ value: NSString?) {
        print(value!)
        self.dismiss()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func toggleLocationUpdates(activity: String) {
        delegate?.toggleLocationUpdates(activity: activity)
    }

}
