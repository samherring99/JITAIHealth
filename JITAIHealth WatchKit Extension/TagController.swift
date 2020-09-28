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
    
    @IBOutlet var entryField: WKInterfaceTextField!
    
    var locationList: [String]!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure the table  with list of possible locations
        
        locationList = ["Home", "Work", "Gym", "Park", "Grocery Store"]
        
        if UserDefaults.standard.stringArray(forKey: "names") != nil {
            let customList = UserDefaults.standard.stringArray(forKey: "names")
            for i in 0...(customList?.count ?? 1) - 1 {
                if !locationList.contains(customList![i]) && customList![i] != "" {
                    locationList.append(customList![i])
                }
            }
        } else {
            UserDefaults.standard.set([""], forKey: "names")
        }
        
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
        saveTagNameAndCoords(name: locationList[rowIndex])
        self.dismiss()
    }
    
    // This method saves the tag custom name and coordinates of any tag to UserDefaults
    
    func saveTagNameAndCoords(name: String) {
        
        var names: [String] = UserDefaults.standard.stringArray(forKey: "names")!
        
        if !locationList.contains(name) { names.append(name as String) }
        
        let noDupes = Array(Set(arrayLiteral: names))
        UserDefaults.standard.set(noDupes[0], forKey: "names")
        
        let coords = fetchAndTagLocation(title: name as String)
        
        if UserDefaults.standard.stringArray(forKey: name + "_lat") == nil &&
            UserDefaults.standard.stringArray(forKey: name + "_long") == nil {
            UserDefaults.standard.set([String(coords.coordinate.latitude)], forKey: name + "_lat")
            UserDefaults.standard.set([String(coords.coordinate.longitude)], forKey: name + "_long")
        } else {
            var lats: [String] = UserDefaults.standard.stringArray(forKey: name + "_lat")!
            var longs: [String] = UserDefaults.standard.stringArray(forKey: name + "_long")!
            lats.append(String(coords.coordinate.latitude))
            longs.append(String(coords.coordinate.longitude))
            UserDefaults.standard.set(lats, forKey: name + "_lat")
            UserDefaults.standard.set(longs, forKey: name + "_long")
        }
        
        //clearAllUserDefaults()
        
        
    }
    
    func clearAllUserDefaults() {
        var names: [String] = UserDefaults.standard.stringArray(forKey: "names")!
        
        for j in 1...names.count {
            UserDefaults.standard.set(nil, forKey: names[j] + "_lat")
            UserDefaults.standard.set(nil, forKey: names[j] + "_long")
        }
        
        UserDefaults.standard.set(nil, forKey: "names")
    }
    
    // Custom tag entered
    @IBAction func didEnter(_ value: NSString?) {
        print(value!)
        
        if value != nil {
            saveTagNameAndCoords(name: value! as String)
        }
    
        self.dismiss()
    }
    
    func fetchAndTagLocation(title: String) -> CLLocation  {
        let current: CLLocation? = InterfaceController.vm.fetchCurrentLocation()
        return current!
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
