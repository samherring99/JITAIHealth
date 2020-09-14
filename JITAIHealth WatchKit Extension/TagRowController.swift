//
//  TagRowController.swift
//  JITAIHealth WatchKit Extension
//
//  Created by Sam Herring on 8/18/20.
//

import WatchKit

class TagRowController: NSObject {
    
    @IBOutlet var locationLabel: WKInterfaceLabel!
    
    //  This controller represents the 'cell' view for the WKInterfaceTable using a property observer.
    
    var location: String? {
      didSet {
        guard let location = location else { return }
        locationLabel.setText(location)
        
      }
    }

}
