//
//  TagController.swift
//  JITAIHealth WatchKit Extension
//
//  Created by Sam Herring on 8/18/20.
//

import WatchKit
import Foundation


class TagController: WKInterfaceController {

    @IBOutlet var table: WKInterfaceTable!
    
    var locationList: [String]!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure the table  with list of possible locations
        
        locationList = ["Home", "Work", "Gym", "Park", "Other"]
        table.setNumberOfRows(locationList.count, withRowType: "locationRow")
        
        for index in 0..<table.numberOfRows {
            guard let controller = table.rowController(at: index) as? TagRowController else { continue }

          controller.location = locationList[index]
        }
        
        // Configure interface objects here.
    }
    
    // Called when the user selects a row
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        print("On Watch: " + locationList[rowIndex])
        InterfaceController.vm.sendTagToPhone(tag: locationList[rowIndex])
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
